import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/ripple_bottom_navbar.dart';
import '../widgets/ripple_add_button.dart';
import '../../features/todo/presentation/bloc/todos_overview_bloc.dart';
import '../../features/todo/presentation/widgets/todo_edit_sheet.dart';
import '../../features/milestone/presentation/bloc/goal_list_bloc.dart';
import '../../features/milestone/domain/entities/goal.dart';
import '../services/notification_service.dart';
import '../services/timezone_service.dart';
import 'package:get_it/get_it.dart';

/// Main shell page with bottom navigation bar for the 4 main features
class MainShell extends StatefulWidget {
  final Widget child;
  
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  
  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  void _initNotifications() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      GetIt.I<NotificationService>().initialize(userId);
      // Sync detected timezone to user's profile
      GetIt.I<TimezoneService>().syncToProfile(userId);
    }
  }

  int _calculateCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/notes')) return 1;
    if (location.startsWith('/focus')) return 2;
    if (location.startsWith('/goals')) return 3;
    return 0; // Default to Todo
  }

  void _onNavTapped(int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/notes');
        break;
      case 2:
        context.go('/focus');
        break;
      case 3:
        context.go('/goals');
        break;
    }
  }

  void _onAddPressed() {
    final currentIndex = _calculateCurrentIndex(context);
    
    switch (currentIndex) {
      case 0: // Todo
        final viewMode = context.read<TodosOverviewBloc>().state.viewMode;
        // If in schedule mode, default to now. If in list mode, null (not scheduled).
        final scheduledTime = viewMode == TodosViewMode.schedule ? DateTime.now() : null;
        _showTodoEditSheet(scheduledTime: scheduledTime);
        break;
      case 1: // Notes
        context.push('/notes/editor/new');
        break;
      case 2: // Focus - no add action needed
        break;
      case 3: // Milestone
        _showAddGoalDialog();
        break;
    }
  }

  void _showTodoEditSheet({DateTime? scheduledTime}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return TodoEditSheet(
          scheduledTime: scheduledTime,
          onSave: (newTodo) {
            final userId = Supabase.instance.client.auth.currentUser?.id;
            if (userId != null && newTodo.userId.isEmpty) {
              final todoWithUser = newTodo.copyWith(userId: userId);
              context.read<TodosOverviewBloc>().add(TodosOverviewTodoSaved(todoWithUser));
            } else {
              context.read<TodosOverviewBloc>().add(TodosOverviewTodoSaved(newTodo));
            }
          },
        );
      },
    );
  }

  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<GoalListBloc>(),
        child: const _AddGoalDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateCurrentIndex(context);
    
    // Hide FAB on Focus tab and Note Editor (keyboard issue)
    final location = GoRouterState.of(context).uri.toString();
    final isNoteEditor = location.contains('/notes/editor');
    final shouldShowFab = currentIndex != 2 && !isNoteEditor;
    
    return Scaffold(
      body: widget.child,
      floatingActionButton: shouldShowFab
          ? RippleAddButton(onPressed: _onAddPressed)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: RippleBottomNavbar(
        currentIndex: currentIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}

/// Dialog for adding a new goal (duplicated from goals_dashboard_page for now)
class _AddGoalDialog extends StatefulWidget {
  const _AddGoalDialog();

  @override
  State<_AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<_AddGoalDialog> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isNotEmpty) {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      final newGoal = Goal(
        id: '',
        userId: userId,
        title: title,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      context.read<GoalListBloc>().add(GoalListGoalCreated(newGoal));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Goal'),
      content: TextField(
        controller: _titleController,
        decoration: const InputDecoration(hintText: 'e.g. Learn Flutter'),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Create'),
        ),
      ],
    );
  }
}
