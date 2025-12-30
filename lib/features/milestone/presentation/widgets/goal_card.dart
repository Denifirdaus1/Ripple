import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ripple_card.dart';
import '../../domain/entities/goal.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RippleCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.rippleBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(PhosphorIconsFill.flag, color: AppColors.rippleBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  goal.title,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (goal.description != null && goal.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              goal.description!,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          // Progress Bar
          LinearProgressIndicator(
            value: goal.progress,
            backgroundColor: AppColors.softGray,
            color: AppColors.rippleBlue,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(goal.progress * 100).toInt()}%',
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
