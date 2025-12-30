import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ripple_page_header.dart';
import '../../domain/entities/todo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../core/injection/injection_container.dart';
import '../bloc/todos_overview_bloc.dart';
import '../widgets/todo_edit_sheet.dart';
import '../widgets/todo_item.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({super.key});

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  @override
  void initState() {
    super.initState();
    // Initialize Notification Service and Sync Token
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      sl<NotificationService>().initialize(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditSheet(context),
        backgroundColor: AppColors.rippleBlue,
        child: const Icon(PhosphorIconsFill.plus, color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: RipplePageHeader(
              title: 'Tasks',
              subtitle: 'Stay focused and organized.',
              action: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(PhosphorIconsRegular.flag, size: 22),
                    tooltip: 'Goals',
                    onPressed: () => context.push('/goals'),
                  ),
                  IconButton(
                    icon: const Icon(PhosphorIconsRegular.notePencil, size: 22),
                    tooltip: 'Notes',
                    onPressed: () => context.push('/notes'), 
                  ),
                  IconButton(
                    icon: const Icon(PhosphorIconsRegular.signOut),
                    tooltip: 'Logout',
                    onPressed: () {
                       context.read<AuthBloc>().add(AuthLogoutRequested());
                    },
                  ),
                ],
              ),
            ),
          ),
          // Filter Chips
          SliverToBoxAdapter(
            child: _TodosFilterBar(),
          ),
          // Todo List
          BlocBuilder<TodosOverviewBloc, TodosOverviewState>(
            builder: (context, state) {
              if (state.status == TodosOverviewStatus.loading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              final todos = state.filteredTodos.toList();
              
              if (todos.isEmpty) {
                if (state.status == TodosOverviewStatus.initial) {
                   return const SliverFillRemaining(
                    child: Center(child: Text('Loading tasks...')),
                  );
                }
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No tasks found.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final todo = todos[index];
                      return TodoItem(
                        todo: todo,
                        onCheckboxChanged: (val) {
                          context.read<TodosOverviewBloc>().add(
                            TodosOverviewTodoSaved(
                              todo.copyWith(
                                isCompleted: val ?? false,
                                completedAt: (val ?? false) ? DateTime.now() : null,
                              ),
                            ),
                          );
                        },
                        onTap: () {
                          // Tap to edit or start focus?
                          // Let's open Focus Timer on tap for now, or edit sheet?
                          // MVP: Tap to edit. Long press to focus?
                          // For now, let's just edit on tap.
                          _openEditSheet(context, todo: todo);
                        },
                      );
                    },
                    childCount: todos.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openEditSheet(BuildContext context, {Todo? todo}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return TodoEditSheet(
          initialTodo: todo,
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
}

class _TodosFilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentFilter = context.select((TodosOverviewBloc bloc) => bloc.state.filter);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _FilterChip(
            label: 'All', 
            isSelected: currentFilter == TodosViewFilter.all,
            onTap: () => context.read<TodosOverviewBloc>().add(const TodosOverviewFilterChanged(TodosViewFilter.all)),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Active', 
            isSelected: currentFilter == TodosViewFilter.active,
            onTap: () => context.read<TodosOverviewBloc>().add(const TodosOverviewFilterChanged(TodosViewFilter.active)),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Done', 
            isSelected: currentFilter == TodosViewFilter.completed,
            onTap: () => context.read<TodosOverviewBloc>().add(const TodosOverviewFilterChanged(TodosViewFilter.completed)),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.inkBlack : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.inkBlack : AppColors.softGray),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
