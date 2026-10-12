import 'package:flutter/material.dart';

import '../../core/theme/tokens/app_colors.dart';
import '../../core/theme/tokens/app_scale.dart';
import '../../core/theme/tokens/app_typography.dart';

class AppFormLabel extends StatelessWidget {
  const AppFormLabel({
    super.key,
    required this.text,
    this.color,
    this.fontSize = 13,
  });

  final String text;
  final Color? color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.textTheme(
        Theme.of(context).brightness,
        context: context,
      ).labelMedium?.copyWith(
            color: color ?? AppColors.authFormLabel,
            fontSize: AppScale.text(context, fontSize),
            fontWeight: FontWeight.w400,
            height: 1.5,
            letterSpacing: 0,
          ),
    );
  }
}
