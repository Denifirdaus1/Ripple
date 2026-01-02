import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/todo.dart';
import '../bloc/todos_overview_bloc.dart';

/// Detail page for a specific Todo, accessed via notification deep link
class TodoDetailPage extends StatelessWidget {
  final String todoId;
  
  const TodoDetailPage({super.key, required this.todoId});

  @override
  Widget build(BuildContext context) {
    debugPrint('TodoDetailPage: Building with todoId=$todoId');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Detail'),
        backgroundColor: AppColors.paperWhite,
        foregroundColor: AppColors.inkBlack,
        elevation: 0,
      ),
      body: BlocBuilder<TodosOverviewBloc, TodosOverviewState>(
        builder: (context, state) {
          debugPrint('TodoDetailPage: State has ${state.todos.length} todos');
          
          // Find the todo with matching id
          final todo = state.todos.where((t) => t.id == todoId).firstOrNull;
          
          if (todo == null) {
            debugPrint('TodoDetailPage: Todo not found for id=$todoId');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIconsRegular.magnifyingGlass,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Todo not found',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }
          
          debugPrint('TodoDetailPage: Found todo "${todo.title}"');
          return _TodoDetailContent(todo: todo);
        },
      ),
    );
  }
}

class _TodoDetailContent extends StatelessWidget {
  final Todo todo;
  
  const _TodoDetailContent({required this.todo});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Section
          Row(
            children: [
              Icon(
                todo.isCompleted 
                    ? PhosphorIconsFill.checkCircle 
                    : PhosphorIconsRegular.circle,
                color: todo.isCompleted ? AppColors.sageGreen : AppColors.rippleBlue,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  todo.title,
                  style: AppTypography.textTheme.headlineSmall?.copyWith(
                    decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                    color: todo.isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Priority Badge
          _InfoRow(
            icon: PhosphorIconsRegular.flag,
            label: 'Priority',
            value: _priorityLabel(todo.priority),
            valueColor: _priorityColor(todo.priority),
          ),
          
          // Schedule Info
          if (todo.isScheduled && todo.startTime != null) ...[
            const SizedBox(height: 16),
            _InfoRow(
              icon: PhosphorIconsRegular.calendarBlank,
              label: 'Date',
              value: DateFormat('EEEE, MMM dd, yyyy').format(todo.scheduledDate!),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: PhosphorIconsRegular.clock,
              label: 'Time',
              value: '${DateFormat.jm().format(todo.startTime!)} - ${DateFormat.jm().format(todo.endTime!)}',
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: PhosphorIconsRegular.bellRinging,
              label: 'Reminder',
              value: _reminderLabel(todo.reminderMinutes),
            ),
          ],
          
          // Focus Mode
          if (todo.focusEnabled) ...[
            const SizedBox(height: 16),
            _InfoRow(
              icon: PhosphorIconsRegular.timer,
              label: 'Focus Mode',
              value: '${todo.focusDurationMinutes} minutes',
            ),
          ],
          
          // Description
          if (todo.description != null && todo.description!.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Description',
              style: AppTypography.textTheme.titleSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              todo.description!,
              style: AppTypography.textTheme.bodyLarge,
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Toggle completion using copyWith pattern
                final updatedTodo = todo.copyWith(
                  isCompleted: !todo.isCompleted,
                  completedAt: !todo.isCompleted ? DateTime.now() : null,
                );
                debugPrint('TodoDetailPage: Toggling completion for "${todo.title}" to ${updatedTodo.isCompleted}');
                
                context.read<TodosOverviewBloc>().add(
                  TodosOverviewTodoSaved(updatedTodo),
                );
              },
              icon: Icon(
                todo.isCompleted ? PhosphorIconsRegular.arrowCounterClockwise : PhosphorIconsRegular.check,
              ),
              label: Text(todo.isCompleted ? 'Mark as Incomplete' : 'Mark as Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: todo.isCompleted ? AppColors.warmTangerine : AppColors.rippleBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _priorityLabel(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high: return 'High';
      case TodoPriority.medium: return 'Medium';
      case TodoPriority.low: return 'Low';
    }
  }
  
  Color _priorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high: return AppColors.coralPink;
      case TodoPriority.medium: return AppColors.warmTangerine;
      case TodoPriority.low: return AppColors.sageGreen;
    }
  }
  
  String _reminderLabel(int minutes) {
    if (minutes >= 60) {
      return '${minutes ~/ 60} hour before';
    }
    return '$minutes min before';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
