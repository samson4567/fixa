import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_scale.dart';

final class AppTypography {
  const AppTypography._();

  static const String primaryFontFamily = 'Poppins';
  static const String secondaryFontFamily = 'Lato';
  static const List<String> fontFamilyFallback = <String>[
    secondaryFontFamily,
    'SF Pro Text',
    'Segoe UI',
    'Roboto',
  ];

  static TextTheme textTheme(
    Brightness brightness, {
    BuildContext? context,
  }) {
    final Color textColor = brightness == Brightness.dark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final Color mutedTextColor = brightness == Brightness.dark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    TextStyle style({
      required double size,
      required FontWeight weight,
      Color? color,
      double height = 1.4,
      double? letterSpacing,
    }) {
      final resolvedSize =
          context == null ? size : AppScale.text(context, size);
      return TextStyle(
        fontFamily: primaryFontFamily,
        fontFamilyFallback: fontFamilyFallback,
        fontSize: resolvedSize,
        fontWeight: weight,
        height: height,
        color: color ?? textColor,
        letterSpacing: letterSpacing,
      );
    }

    return TextTheme(
      headlineLarge: style(
        size: 42,
        weight: FontWeight.w500,
        height: 1.1,
        letterSpacing: -0.4,
      ),
      displayLarge: style(
        size: 31,
        weight: FontWeight.w700,
        // height: 1.15,
        // letterSpacing: -0.3,
      ),
      displayMedium: style(
        size: 20,
        weight: FontWeight.w600,
        height: 1.2,
      ),
      displaySmall: style(
        size: 16,
        weight: FontWeight.w600,
        height: 1.25,
      ),
      titleLarge: style(
        size: 20,
        weight: FontWeight.w900,
        height: 1.25,
      ),
      titleMedium: style(
        size: 16,
        weight: FontWeight.w500,
        height: 1.3,
      ),
      titleSmall: style(
        size: 14,
        weight: FontWeight.w500,
        height: 1.3,
      ),
      bodyLarge: style(
        size: 16,
        weight: FontWeight.w500,
        height: 1.45,
      ),
      bodyMedium: style(
        size: 12,
        weight: FontWeight.w400,
        height: 1.45,
      ),
      bodySmall: style(
        size: 10,
        weight: FontWeight.w400,
        height: 1.4,
        color: mutedTextColor,
      ),
      labelLarge: style(
        size: 20,
        weight: FontWeight.w500,
        height: 1.2,
      ),
      labelMedium: style(
        size: 14,
        weight: FontWeight.w400,
        height: 1.2,
      ),
      labelSmall: style(
        size: 16,
        weight: FontWeight.w400,
        height: 1.2,
      ),
    );
  }

  static TextStyle hintStyle(
    Brightness brightness, {
    BuildContext? context,
  }) {
    final color = brightness == Brightness.dark
        ? AppColors.darkTextHint
        : AppColors.lightTextHint;

    return TextStyle(
      fontFamily: primaryFontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: context == null ? null : AppScale.text(context, 16),
      color: color,
    );
  }

  static TextStyle secondaryStyle({
    required double size,
    required FontWeight weight,
    required Color color,
    BuildContext? context,
    double height = 1.4,
    double? letterSpacing,
  }) {
    final resolvedSize = context == null ? size : AppScale.text(context, size);
    return TextStyle(
      fontFamily: secondaryFontFamily,
      fontFamilyFallback: const <String>[
        'Poppins',
        'SF Pro Text',
        'Segoe UI',
        'Roboto',
      ],
      fontSize: resolvedSize,
      fontWeight: weight,
      height: height,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}
