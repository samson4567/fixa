import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final buttonChild = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon!,
              const SizedBox(width: AppSpacing.buttonGap),
              Text(label),
            ],
          );

    return SizedBox(
      width: width ?? AppSpacing.buttonWidth,
      height: AppSpacing.buttonHeight,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.disabled,
          foregroundColor: AppColors.white,
          textStyle: AppTypography.authButtonLabel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: buttonChild,
      ),
    );
  }
}
