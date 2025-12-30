import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/milestone.dart';

class MilestoneTimeline extends StatelessWidget {
  final List<Milestone> milestones;
  final void Function(Milestone milestone, bool isCompleted) onMilestoneToggle;
  final void Function(String milestoneId) onMilestoneDelete;

  const MilestoneTimeline({
    super.key,
    required this.milestones,
    required this.onMilestoneToggle,
    required this.onMilestoneDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(milestones.length, (index) {
        final milestone = milestones[index];
        final isLast = index == milestones.length - 1;
        return _MilestoneTimelineItem(
          milestone: milestone,
          isLast: isLast,
          onToggle: (isCompleted) => onMilestoneToggle(milestone, isCompleted),
          onDelete: () => onMilestoneDelete(milestone.id),
        );
      }),
    );
  }
}

class _MilestoneTimelineItem extends StatelessWidget {
  final Milestone milestone;
  final bool isLast;
  final void Function(bool isCompleted) onToggle;
  final VoidCallback onDelete;

  const _MilestoneTimelineItem({
    required this.milestone,
    required this.isLast,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator column
          _buildIndicatorColumn(),
          const SizedBox(width: 12),
          // Content card
          Expanded(child: _buildContentCard(context)),
        ],
      ),
    );
  }

  Widget _buildIndicatorColumn() {
    return Column(
      children: [
        // Indicator Circle
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: milestone.isCompleted ? AppColors.successGreen : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: milestone.isCompleted ? AppColors.successGreen : AppColors.softGray,
              width: 2,
            ),
          ),
          child: milestone.isCompleted
              ? const Icon(PhosphorIconsFill.check, size: 16, color: Colors.white)
              : null,
        ),
        // Connecting line
        if (!isLast)
          Expanded(
            child: Container(
              width: 2,
              color: AppColors.softGray,
            ),
          ),
      ],
    );
  }

  Widget _buildContentCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softGray.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Expanded(
                child: Text(
                  milestone.title,
                  style: AppTypography.bodyBold?.copyWith(
                    color: AppColors.inkBlack,
                    decoration: milestone.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              // Checkbox
              GestureDetector(
                onTap: () => onToggle(!milestone.isCompleted),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: milestone.isCompleted ? AppColors.successGreen : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: milestone.isCompleted ? AppColors.successGreen : AppColors.softGray,
                      width: 2,
                    ),
                  ),
                  child: milestone.isCompleted
                      ? const Icon(PhosphorIconsFill.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
            ],
          ),
          // Target Date
          if (milestone.targetDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(PhosphorIconsRegular.calendarBlank, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(milestone.targetDate!),
                    style: AppTypography.caption?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          // Delete button row
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onDelete,
                child: Icon(PhosphorIconsRegular.trash, size: 18, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
