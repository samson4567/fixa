import 'package:flutter/material.dart';

import '../../core/theme/tokens/app_colors.dart';
import '../../core/theme/tokens/app_scale.dart';
import '../../core/theme/tokens/app_typography.dart';

class AppFormErrorText extends StatelessWidget {
  const AppFormErrorText({
    super.key,
    required this.message,
    this.padding = const EdgeInsets.only(top: 4),
    this.color = AppColors.error,
    this.fontSize = 12,
  });

  final String message;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: padding,
      child: Text(
        message,
        style: AppTypography.textTheme(
          brightness,
          context: context,
        ).bodyMedium?.copyWith(
              color: color,
              fontSize: AppScale.text(context, fontSize),
            ),
      ),
    );
  }
}
