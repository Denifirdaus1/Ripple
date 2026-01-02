import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'core/theme/app_theme.dart';
import 'core/injection/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_navigation_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/todo/presentation/bloc/todos_overview_bloc.dart';
import 'features/todo/presentation/bloc/focus_timer_cubit.dart';
import 'features/notes/presentation/bloc/note_bloc.dart';
import 'features/milestone/presentation/bloc/goal_list_bloc.dart';

class RippleApp extends StatelessWidget {
  const RippleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth Bloc - subscribes immediately to listen for auth state
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(AuthSubscriptionRequested()),
        ),
        // Focus Timer Cubit - Global singleton for background timer
        BlocProvider<FocusTimerCubit>(
          create: (_) => sl<FocusTimerCubit>(),
        ),
        // Data Blocs - DO NOT auto-subscribe, will be triggered by auth listener
        BlocProvider<TodosOverviewBloc>(
          create: (_) => sl<TodosOverviewBloc>(),
        ),
        BlocProvider<NoteBloc>(
          create: (_) => sl<NoteBloc>(),
        ),
        BlocProvider<GoalListBloc>(
          create: (_) => sl<GoalListBloc>(),
        ),
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
            context.read<TodosOverviewBloc>().add(TodosOverviewSubscriptionRequested());
            context.read<NoteBloc>().add(NoteSubscriptionRequested());
            context.read<GoalListBloc>().add(GoalListSubscriptionRequested());
          } else if (state is Unauthenticated) {
            // User logged out - clear all data
            context.read<TodosOverviewBloc>().add(TodosOverviewClearRequested());
            context.read<NoteBloc>().add(NoteClearRequested());
            context.read<GoalListBloc>().add(GoalListClearRequested());
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
                // Store context for notification navigation service
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  NotificationNavigationService.processPendingNavigation(context);
                });
                return child ?? const SizedBox.shrink();
              },
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                FlutterQuillLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', 'US'),
                Locale('id', 'ID'),
              ],
            );
          },
        ),
      ),
    );
  }
}
