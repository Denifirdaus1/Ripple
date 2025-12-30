import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ripple_button.dart';
import '../../../../core/widgets/ripple_input.dart';
import '../../domain/entities/todo.dart';

class TodoEditSheet extends StatefulWidget {
  final Todo? initialTodo;
  final ValueChanged<Todo> onSave;

  const TodoEditSheet({super.key, this.initialTodo, required this.onSave});

  @override
  State<TodoEditSheet> createState() => _TodoEditSheetState();
}

class _TodoEditSheetState extends State<TodoEditSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late TodoPriority _priority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTodo?.title ?? '');
    _descController = TextEditingController(text: widget.initialTodo?.description ?? '');
    _priority = widget.initialTodo?.priority ?? TodoPriority.none;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.isEmpty) return;
    
    final todo = widget.initialTodo?.copyWith(
      title: _titleController.text,
      description: _descController.text,
      priority: _priority,
      updatedAt: DateTime.now(),
    ) ?? Todo(
      id: '', // Will be assigned by Repo/DB or helper
      userId: '', // Will be assigned by Repo
      title: _titleController.text,
      description: _descController.text,
      priority: _priority,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    widget.onSave(todo);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.initialTodo == null ? 'New Task' : 'Edit Task',
            style: AppTypography.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          RippleInput(
            hintText: 'What needs to be done?',
            controller: _titleController,
          ),
          const SizedBox(height: 12),
          RippleInput(
            hintText: 'Notes (optional)',
            controller: _descController,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Text('Priority', style: AppTypography.textTheme.labelLarge),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                 _PriorityChip(
                  label: 'None', 
                  color: AppColors.softGray, 
                  isSelected: _priority == TodoPriority.none,
                  onTap: () => setState(() => _priority = TodoPriority.none),
                ),
                const SizedBox(width: 8),
                _PriorityChip(
                  label: 'High', 
                  color: AppColors.coralPink.withValues(alpha: 0.2), 
                  selectedColor: AppColors.coralPink,
                  isSelected: _priority == TodoPriority.high,
                  onTap: () => setState(() => _priority = TodoPriority.high),
                ),
                const SizedBox(width: 8),
                _PriorityChip(
                  label: 'Medium', 
                  color: AppColors.warmTangerine.withValues(alpha: 0.2), 
                  selectedColor: AppColors.warmTangerine,
                  isSelected: _priority == TodoPriority.medium,
                  onTap: () => setState(() => _priority = TodoPriority.medium),
                ),
                const SizedBox(width: 8),
                _PriorityChip(
                  label: 'Low', 
                  color: AppColors.rippleBlue.withValues(alpha: 0.2), 
                  selectedColor: AppColors.rippleBlue,
                  isSelected: _priority == TodoPriority.low,
                  onTap: () => setState(() => _priority = TodoPriority.low),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          RippleButton(
            text: 'Save Task',
            onPressed: _submit,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? selectedColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriorityChip({
    required this.label,
    required this.color,
    this.selectedColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? (selectedColor ?? color) : color,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.black12) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected && selectedColor != null ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
