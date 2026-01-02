import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_colors.dart';

/// Floating add button that sits above the bottom navigation bar
class RippleAddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RippleAddButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.rippleBlue, Color(0xFF4A8FE7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.rippleBlue.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: const Center(
            child: Icon(
              PhosphorIconsBold.plus,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
