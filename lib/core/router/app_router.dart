import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/main_shell.dart';
import '../../features/todo/presentation/pages/todos_page.dart';
import '../../features/todo/presentation/pages/todo_detail_page.dart';
import '../../features/todo/presentation/pages/focus_timer_page.dart';
import '../../features/notes/presentation/pages/notes_page.dart';
import '../../features/notes/presentation/pages/note_editor_page.dart';
import '../../features/milestone/presentation/pages/goals_dashboard_page.dart';
import '../../features/milestone/presentation/pages/goal_detail_page.dart';
import '../../features/milestone/presentation/bloc/milestone_detail_bloc.dart';
import '../injection/injection_container.dart';

class AppRouter {
  static GoRouter router(BuildContext context) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(context.read<AuthBloc>().stream),
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        final isLoggedIn = authState is Authenticated;
        final isLoggingIn = state.uri.toString() == '/login';

        if (authState is AuthUnknown) return null; // Wait for check

        if (!isLoggedIn && !isLoggingIn) return '/login';
        if (isLoggedIn && isLoggingIn) return '/';

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        // Note Editor - outside shell for full screen editing
        GoRoute(
          path: '/notes/editor/:noteId',
          builder: (context, state) {
            final noteId = state.pathParameters['noteId']!;
            return NoteEditorPage(noteId: noteId);
          },
        ),
        // Goal Detail - outside shell for full screen detail
        GoRoute(
          path: '/goals/:goalId',
          builder: (context, state) {
            final goalId = state.pathParameters['goalId']!;
            return BlocProvider(
              create: (_) => sl<MilestoneDetailBloc>()
                ..add(MilestoneDetailSubscriptionRequested(goalId)),
              child: GoalDetailPage(goalId: goalId),
            );
          },
        ),
        // Todo Detail - for notification deep linking
        GoRoute(
          path: '/todo/:todoId',
          builder: (context, state) {
            final todoId = state.pathParameters['todoId']!;
            return TodoDetailPage(todoId: todoId);
          },
        ),
        // Main Shell with Bottom Navigation
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: TodosPage(),
              ),
            ),
            GoRoute(
              path: '/notes',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: NotesPage(),
              ),
            ),
            GoRoute(
              path: '/focus',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: FocusTimerPage(),
              ),
            ),
            GoRoute(
              path: '/goals',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: GoalsDashboardPage(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Helper for RefreshListenable
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
