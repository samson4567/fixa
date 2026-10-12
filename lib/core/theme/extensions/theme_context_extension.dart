import 'package:flutter/material.dart';

import 'app_theme_colors.dart';

extension ThemeContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  AppThemeColors get appThemeColors =>
      theme.extension<AppThemeColors>() ?? AppThemeColors.light;
}
