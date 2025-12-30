import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/todo/presentation/pages/todos_page.dart';
import '../../features/todo/presentation/pages/focus_timer_page.dart';
import '../../features/notes/presentation/pages/notes_page.dart';
import '../../features/notes/presentation/pages/note_editor_page.dart';
import '../../features/milestone/presentation/pages/goals_dashboard_page.dart';
import '../../features/milestone/presentation/pages/goal_detail_page.dart';
import '../../features/milestone/presentation/bloc/milestone_detail_bloc.dart';
import '../injection/injection_container.dart';
// import '../../features/kitchen_sink.dart'; 
// import '../../features/home/presentation/pages/home_page.dart'; // Will create later

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
        GoRoute(
          path: '/',
          builder: (context, state) => const TodosPage(),
        ),
        GoRoute(
          path: '/focus',
          builder: (context, state) => const FocusTimerPage(),
        ),
        GoRoute(
          path: '/notes',
          builder: (context, state) => const NotesPage(),
          routes: [
            GoRoute(
              path: 'editor/:noteId',
              builder: (context, state) {
                final noteId = state.pathParameters['noteId']!;
                return NoteEditorPage(noteId: noteId);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/goals',
          builder: (context, state) => const GoalsDashboardPage(),
          routes: [
            GoRoute(
              path: ':goalId',
              builder: (context, state) {
                final goalId = state.pathParameters['goalId']!;
                return BlocProvider(
                  create: (_) => sl<MilestoneDetailBloc>()
                    ..add(MilestoneDetailSubscriptionRequested(goalId)),
                  child: GoalDetailPage(goalId: goalId),
                );
              },
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
