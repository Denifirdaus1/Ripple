import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class RippleInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int maxLines;

  const RippleInput({
    super.key,
    this.label,
    this.hint,
    this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          maxLines: maxLines,
          style: AppTypography.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint ?? hintText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textSecondary)
                : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
