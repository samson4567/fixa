import 'package:fixa/core/theme/tokens/app_colors.dart';
import 'package:flutter/material.dart';

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.surfaceRaised,
    required this.surfaceMuted,
    required this.inputBackground,
    required this.inputBorder,
    required this.borderSubtle,
    required this.socialButtonBackground,
    required this.closeButtonBackground,
    required this.ring,
    required this.successSurface,
    required this.warningSurface,
    required this.errorSurface,
  });

  final Color surfaceRaised;
  final Color surfaceMuted;
  final Color inputBackground;
  final Color inputBorder;
  final Color borderSubtle;
  final Color socialButtonBackground;
  final Color closeButtonBackground;
  final Color ring;
  final Color successSurface;
  final Color warningSurface;
  final Color errorSurface;

  static const AppThemeColors light = AppThemeColors(
    surfaceRaised: AppColors.lightSurface,
    surfaceMuted: AppColors.lightBackground,
    inputBackground: AppColors.authInputBackground,
    inputBorder: AppColors.authInputBorder,
    borderSubtle: AppColors.lightBorder,
    socialButtonBackground: AppColors.lightInput,
    closeButtonBackground: AppColors.closeButtonBackground,
    ring: AppColors.primary,
    successSurface: AppColors.successSurfaceLight,
    warningSurface: AppColors.warningSurfaceLight,
    errorSurface: AppColors.errorSurfaceLight,
  );

  static const AppThemeColors dark = AppThemeColors(
    surfaceRaised: AppColors.darkSurface,
    surfaceMuted: AppColors.darkBackground,
    inputBackground: AppColors.authInputBackground,
    inputBorder: AppColors.authInputBorder,
    borderSubtle: AppColors.darkBorder,
    socialButtonBackground: AppColors.white,
    closeButtonBackground: AppColors.closeButtonBackgroundDark,
    ring: AppColors.primary,
    successSurface: AppColors.successSurface,
    warningSurface: AppColors.warningSurface,
    errorSurface: AppColors.errorSurface,
  );

  @override
  AppThemeColors copyWith({
    Color? surfaceRaised,
    Color? surfaceMuted,
    Color? inputBackground,
    Color? inputBorder,
    Color? borderSubtle,
    Color? socialButtonBackground,
    Color? closeButtonBackground,
    Color? ring,
    Color? successSurface,
    Color? warningSurface,
    Color? errorSurface,
  }) {
    return AppThemeColors(
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      inputBackground: inputBackground ?? this.inputBackground,
      inputBorder: inputBorder ?? this.inputBorder,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      socialButtonBackground:
          socialButtonBackground ?? this.socialButtonBackground,
      closeButtonBackground:
          closeButtonBackground ?? this.closeButtonBackground,
      ring: ring ?? this.ring,
      successSurface: successSurface ?? this.successSurface,
      warningSurface: warningSurface ?? this.warningSurface,
      errorSurface: errorSurface ?? this.errorSurface,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) {
      return this;
    }

    return AppThemeColors(
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      socialButtonBackground: Color.lerp(
        socialButtonBackground,
        other.socialButtonBackground,
        t,
      )!,
      closeButtonBackground: Color.lerp(
        closeButtonBackground,
        other.closeButtonBackground,
        t,
      )!,
      ring: Color.lerp(ring, other.ring, t)!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      errorSurface: Color.lerp(errorSurface, other.errorSurface, t)!,
    );
  }
}
