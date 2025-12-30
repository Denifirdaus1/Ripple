import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RippleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const RippleCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.outlineGray,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: card,
        ),
      );
    }

    return card;
  }
}
