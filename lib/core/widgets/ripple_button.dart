import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum RippleButtonType { primary, secondary, ghost, danger, outlined }
enum RippleButtonVariant { filled, outlined }

class RippleButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final RippleButtonType type;
  final RippleButtonVariant variant;
  final IconData? icon;
  final bool isLoading;

  const RippleButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = RippleButtonType.primary,
    this.variant = RippleButtonVariant.filled,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine styles based on type
    Color backgroundColor;
    Color foregroundColor;
    Color? borderColor;

    switch (type) {
      case RippleButtonType.primary:
        backgroundColor = AppColors.rippleBlue;
        foregroundColor = Colors.white;
        borderColor = null;
        break;
      case RippleButtonType.secondary:
        backgroundColor = AppColors.softGray;
        foregroundColor = AppColors.inkBlack;
        borderColor = null;
        break;
      case RippleButtonType.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.rippleBlue;
        borderColor = null;
        break;
      case RippleButtonType.danger:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.coralPink;
        borderColor = AppColors.coralPink.withValues(alpha: 0.3);
        break;
      case RippleButtonType.outlined:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.inkBlack;
        borderColor = AppColors.outlineGray;
        break;
    }

    // Override based on variant
    if (variant == RippleButtonVariant.outlined) {
      backgroundColor = Colors.transparent;
      borderColor = AppColors.outlineGray;
      // Ensure text is visible for outlined buttons (default to inkDark if it was white)
      if (foregroundColor == Colors.white) {
        foregroundColor = AppColors.inkBlack;
      }
    }

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        else if (icon != null) ...[
          Icon(icon, size: 20, color: foregroundColor),
          const SizedBox(width: 8),
        ],
        if (!isLoading)
          Text(text),
      ],
    );

    final style = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      textStyle: AppTypography.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: borderColor != null
            ? BorderSide(color: borderColor)
            : BorderSide.none,
      ),
    );

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: content,
    );
  }
}
