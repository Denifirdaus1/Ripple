import 'package:flutter/material.dart';
import '../theme/app_typography.dart';
import '../theme/app_colors.dart';

class RipplePageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const RipplePageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.textTheme.headlineLarge,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
