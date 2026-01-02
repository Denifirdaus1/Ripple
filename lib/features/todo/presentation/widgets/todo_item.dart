import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ripple_card.dart';
import '../../domain/entities/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final ValueChanged<bool?>? onCheckboxChanged;
  final VoidCallback? onTap;
  final VoidCallback? onStartFocus;

  const TodoItem({
    super.key,
    required this.todo,
    this.onCheckboxChanged,
    this.onTap,
    this.onStartFocus,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RippleCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: todo.isCompleted ? AppColors.softGray : Colors.white,
        child: Row(
          children: [
            // Checkbox
            Transform.scale(
              scale: 1.2,
              child: Checkbox(
                value: todo.isCompleted,
                onChanged: onCheckboxChanged,
                activeColor: AppColors.rippleBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                side: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.5), width: 1.5),
              ),
            ),
            const SizedBox(width: 8),

            // Title & Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          todo.title,
                          style: AppTypography.textTheme.bodyLarge?.copyWith(
                            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                            color: todo.isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      // Focus Mode indicator
                      if (todo.focusEnabled && !todo.isCompleted)
                        GestureDetector(
                          onTap: onStartFocus,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: AppColors.rippleBlue.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  PhosphorIcons.timer(PhosphorIconsStyle.fill),
                                  size: 14,
                                  color: AppColors.rippleBlue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${todo.focusDurationMinutes ?? 25}m',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.rippleBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (todo.description != null && todo.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      todo.description!,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Priority Indicator (always shown)
            const SizedBox(width: 8),
            Icon(
              PhosphorIcons.flag(PhosphorIconsStyle.fill),
              size: 16,
              color: _priorityColor(todo.priority),
            ),
          ],
        ),
      ),
    );
  }

  Color _priorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return AppColors.coralPink;
      case TodoPriority.medium:
        return AppColors.warmTangerine;
      case TodoPriority.low:
        return AppColors.rippleBlue;
    }
  }
}
