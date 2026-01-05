import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// Single toolbar icon button widget
class ToolbarIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final bool isEnabled;
  final VoidCallback? onTap;
  final double size;

  const ToolbarIcon({
    super.key,
    required this.icon,
    this.isActive = false,
    this.isEnabled = true,
    this.onTap,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final effectivelyEnabled = isEnabled && onTap != null;
    
    return GestureDetector(
      onTap: effectivelyEnabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: size,
          color: !effectivelyEnabled
              ? AppColors.textSecondary.withOpacity(0.3)
              : (isActive ? AppColors.rippleBlue : AppColors.textPrimary),
        ),
      ),
    );
  }
}
