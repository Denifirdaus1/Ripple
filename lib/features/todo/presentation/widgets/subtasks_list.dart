import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/todo.dart';
import '../bloc/todos_overview_bloc.dart';

/// Widget that displays subtasks for a parent todo
class SubtasksList extends StatefulWidget {
  final Todo parentTodo;
  final List<Todo> allTodos;

  const SubtasksList({
    super.key,
    required this.parentTodo,
    required this.allTodos,
  });

  @override
  State<SubtasksList> createState() => _SubtasksListState();
}

class _SubtasksListState extends State<SubtasksList> {
  bool _isExpanded = true;
  final TextEditingController _newSubtaskController = TextEditingController();
  bool _isAddingSubtask = false;

  List<Todo> get subtasks => widget.allTodos
      .where((t) => t.parentTodoId == widget.parentTodo.id)
      .toList();

  @override
  void dispose() {
    _newSubtaskController.dispose();
    super.dispose();
  }

  void _addSubtask() {
    if (_newSubtaskController.text.trim().isEmpty) return;

    final newSubtask = Todo(
      id: '',
      userId: widget.parentTodo.userId,
      title: _newSubtaskController.text.trim(),
      parentTodoId: widget.parentTodo.id,
      priority: widget.parentTodo.priority,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<TodosOverviewBloc>().add(TodosOverviewTodoSaved(newSubtask));
    _newSubtaskController.clear();
    setState(() => _isAddingSubtask = false);
  }

  void _toggleSubtaskCompletion(Todo subtask) {
    final updated = subtask.copyWith(
      isCompleted: !subtask.isCompleted,
      completedAt: !subtask.isCompleted ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );
    context.read<TodosOverviewBloc>().add(TodosOverviewTodoSaved(updated));
  }

  @override
  Widget build(BuildContext context) {
    final hasSubtasks = subtasks.isNotEmpty;
    final completedCount = subtasks.where((t) => t.isCompleted).length;
    final totalCount = subtasks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        InkWell(
          onTap: hasSubtasks
              ? () => setState(() => _isExpanded = !_isExpanded)
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  _isExpanded
                      ? PhosphorIconsRegular.caretDown
                      : PhosphorIconsRegular.caretRight,
                  size: 16,
                  color: hasSubtasks
                      ? AppColors.textSecondary
                      : Colors.transparent,
                ),
                const SizedBox(width: 8),
                Icon(
                  PhosphorIconsRegular.listChecks,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Subtasks',
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (hasSubtasks) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.softGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$completedCount/$totalCount',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                // Add subtask button
                IconButton(
                  icon: Icon(
                    PhosphorIconsRegular.plus,
                    size: 18,
                    color: AppColors.rippleBlue,
                  ),
                  onPressed: () => setState(() => _isAddingSubtask = true),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),

        // Subtasks list
        if (_isExpanded && hasSubtasks)
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Column(
              children: subtasks
                  .map((subtask) => _buildSubtaskItem(subtask))
                  .toList(),
            ),
          ),

        // Add subtask input
        if (_isAddingSubtask)
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newSubtaskController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Add subtask...',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.outlineGray),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.outlineGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.rippleBlue),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                    style: AppTypography.textTheme.bodyMedium,
                    onSubmitted: (_) => _addSubtask(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    PhosphorIconsRegular.check,
                    color: AppColors.sageGreen,
                  ),
                  onPressed: _addSubtask,
                ),
                IconButton(
                  icon: Icon(
                    PhosphorIconsRegular.x,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    _newSubtaskController.clear();
                    setState(() => _isAddingSubtask = false);
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSubtaskItem(Todo subtask) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: () => _toggleSubtaskCompletion(subtask),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: subtask.isCompleted
                    ? AppColors.sageGreen
                    : Colors.transparent,
                border: Border.all(
                  color: subtask.isCompleted
                      ? AppColors.sageGreen
                      : AppColors.outlineGray,
                  width: 2,
                ),
              ),
              child: subtask.isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Text(
              subtask.title,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                decoration: subtask.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: subtask.isCompleted
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
          ),
          // Delete button
          IconButton(
            icon: Icon(
              PhosphorIconsRegular.trash,
              size: 16,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              context.read<TodosOverviewBloc>().add(
                TodosOverviewTodoDeleted(subtask),
              );
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
