import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/theme/app_theme.dart';
import 'core/injection/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_navigation_service.dart';
import 'core/services/remote_config_service.dart';
import 'core/widgets/maintenance_screen.dart';
import 'core/utils/notification_logger.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/todo/presentation/bloc/todos_overview_bloc.dart';
import 'features/todo/presentation/bloc/focus_timer_cubit.dart';
import 'features/notes/presentation/bloc/note_bloc.dart';
import 'features/milestone/presentation/bloc/goal_list_bloc.dart';
import 'features/folder/presentation/bloc/folder_bloc.dart';

class RippleApp extends StatefulWidget {
  const RippleApp({super.key});

  @override
  State<RippleApp> createState() => _RippleAppState();
}

class _RippleAppState extends State<RippleApp> {
  @override
  void initState() {
    super.initState();
    // Setup FCM interaction handlers after widget tree is ready
    _setupInteractedMessage();
  }

  /// Setup handlers for notification interactions
  /// This MUST be in StatefulWidget for proper lifecycle management
  Future<void> _setupInteractedMessage() async {
    NotificationLogger.init('Setting up FCM interaction handlers in app.dart');

    // 1. Handle notification tap when app was TERMINATED
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      NotificationLogger.fcmInitialMessage(
        initialMessage.notification?.title,
        initialMessage.data,
      );
      _handleMessage(initialMessage);
    }

    // 2. Handle notification tap when app is in BACKGROUND
    // This listener stays active for the app's lifecycle
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      NotificationLogger.fcmOpenedApp(
        message.notification?.title,
        message.data,
      );
      _handleMessage(message);
    });
  }

  /// Handle incoming message and navigate to appropriate screen
  void _handleMessage(RemoteMessage message) {
    final todoId = message.data['todo_id'] as String?;
    NotificationLogger.init('_handleMessage called with todo_id: $todoId');

    if (todoId != null && todoId.isNotEmpty) {
      // Use Future.delayed to ensure navigation happens after build
      Future.delayed(const Duration(milliseconds: 500), () {
        NotificationNavigationService.navigateToTodo(todoId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth Bloc - subscribes immediately to listen for auth state
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(AuthSubscriptionRequested()),
        ),
        // Focus Timer Cubit - Global singleton for background timer
        BlocProvider<FocusTimerCubit>(create: (_) => sl<FocusTimerCubit>()),
        // Data Blocs - DO NOT auto-subscribe, will be triggered by auth listener
        BlocProvider<TodosOverviewBloc>(create: (_) => sl<TodosOverviewBloc>()),
        BlocProvider<NoteBloc>(create: (_) => sl<NoteBloc>()),
        BlocProvider<GoalListBloc>(create: (_) => sl<GoalListBloc>()),
        BlocProvider<FolderBloc>(create: (_) => sl<FolderBloc>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) {
          // Listen when auth state transitions between Authenticated and non-Authenticated
          final wasAuthenticated = previous is Authenticated;
          final isAuthenticated = current is Authenticated;
          return wasAuthenticated != isAuthenticated;
        },
        listener: (context, state) {
          if (state is Authenticated) {
            // User just logged in - trigger data subscriptions
            context.read<TodosOverviewBloc>().add(
              TodosOverviewSubscriptionRequested(),
            );
            context.read<NoteBloc>().add(NoteSubscriptionRequested());
            context.read<GoalListBloc>().add(GoalListSubscriptionRequested());
            context.read<FolderBloc>().add(FolderSubscriptionRequested());
          } else if (state is Unauthenticated) {
            // User logged out - clear all data
            context.read<TodosOverviewBloc>().add(
              TodosOverviewClearRequested(),
            );
            context.read<NoteBloc>().add(NoteClearRequested());
            context.read<GoalListBloc>().add(GoalListClearRequested());
            context.read<FolderBloc>().add(FolderClearRequested());
          }
        },
        child: Builder(
          builder: (context) {
            final router = AppRouter.router(context);
            return MaterialApp.router(
              title: 'Ripple',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              routerConfig: router,
              // Set navigator key for notification navigation
              builder: (context, child) {
                // Check maintenance mode
                if (RemoteConfigService.instance.isMaintenanceMode) {
                  return const MaintenanceScreen();
                }
                // Store context for notification navigation service
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  NotificationNavigationService.processPendingNavigation(
                    context,
                  );
                });
                return child ?? const SizedBox.shrink();
              },
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                FlutterQuillLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en', 'US'), Locale('id', 'ID')],
            );
          },
        ),
      ),
    );
  }
}
