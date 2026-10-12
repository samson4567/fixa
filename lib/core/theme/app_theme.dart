import 'package:fixa/core/storage/app_preference_service.dart';
import 'package:fixa/core/theme/extensions/app_theme_colors.dart';
import 'package:fixa/core/theme/tokens/app_colors.dart';
import 'package:fixa/core/theme/tokens/app_typography.dart';
import 'package:flutter/material.dart';

final customAppTheme = CustomAppTheme();

class CustomAppTheme extends ChangeNotifier {
  static const String _themeModePreferenceKey = 'app_theme_mode';

  AppPreferenceService? _appPreferenceService;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isLightMode => _themeMode == ThemeMode.light;

  Future<void> init(AppPreferenceService appPreferenceService) async {
    _appPreferenceService = appPreferenceService;
    final savedMode = appPreferenceService.getValue<String>(
      _themeModePreferenceKey,
    );
    _themeMode = _parseThemeMode(savedMode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) {
      return;
    }

    _themeMode = mode;
    notifyListeners();
    await _appPreferenceService?.saveValue(_themeModePreferenceKey, mode.name);
  }

  Future<void> setLightMode(bool enabled) async {
    await setThemeMode(enabled ? ThemeMode.light : ThemeMode.dark);
  }

  ThemeMode _parseThemeMode(String? rawValue) {
    switch (rawValue) {
      case 'system':
        return ThemeMode.system;
      case 'light':
        return ThemeMode.light;
      case 'dark':
      default:
        return rawValue == null ? ThemeMode.system : ThemeMode.dark;
    }
  }

  ThemeData darkTheme(BuildContext context) {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primary,
      surface: AppColors.darkSurface,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.darkTextPrimary,
      onError: AppColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      splashFactory: NoSplash.splashFactory,
      extensions: const <ThemeExtension<dynamic>>[AppThemeColors.dark],
      fontFamily: AppTypography.primaryFontFamily,
      fontFamilyFallback: AppTypography.fontFamilyFallback,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: colorScheme,
      cardColor: AppColors.darkSurface,
      dividerColor: AppColors.darkBorder,
      textTheme: AppTypography.textTheme(Brightness.dark, context: context),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        surfaceTintColor: AppColors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: _buttonStyleWithoutOverlay(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _buttonStyleWithoutOverlay(),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _buttonStyleWithoutOverlay(),
      ),
      textButtonTheme: TextButtonThemeData(style: _buttonStyleWithoutOverlay()),
      iconButtonTheme: IconButtonThemeData(
        style: _iconButtonStyleWithoutOverlay(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        fillColor: AppColors.darkInput,
        hintStyle: AppTypography.hintStyle(Brightness.dark, context: context),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.transparent),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.transparent),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.45);
          }
          return AppColors.darkBorder;
        }),
      ),
      splashColor: AppColors.transparent,
      highlightColor: AppColors.transparent,
      hoverColor: AppColors.transparent,
      focusColor: AppColors.transparent,
    );
  }

  ThemeData lightTheme(BuildContext context) {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primary,
      surface: AppColors.lightSurface,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.lightTextPrimary,
      onError: AppColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      splashFactory: NoSplash.splashFactory,
      extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
      fontFamily: AppTypography.primaryFontFamily,
      fontFamilyFallback: AppTypography.fontFamilyFallback,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: colorScheme,
      cardColor: AppColors.lightSurface,
      dividerColor: AppColors.lightBorder,
      textTheme: AppTypography.textTheme(Brightness.light, context: context),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        surfaceTintColor: AppColors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: _buttonStyleWithoutOverlay(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _buttonStyleWithoutOverlay(),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _buttonStyleWithoutOverlay(),
      ),
      textButtonTheme: TextButtonThemeData(style: _buttonStyleWithoutOverlay()),
      iconButtonTheme: IconButtonThemeData(
        style: _iconButtonStyleWithoutOverlay(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightInput,
        hintStyle: AppTypography.hintStyle(Brightness.light, context: context),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.35);
          }
          return AppColors.lightBorder;
        }),
      ),
      splashColor: AppColors.transparent,
      highlightColor: AppColors.transparent,
      hoverColor: AppColors.transparent,
      focusColor: AppColors.transparent,
    );
  }

  ButtonStyle _buttonStyleWithoutOverlay() {
    return ButtonStyle(
      splashFactory: NoSplash.splashFactory,
      overlayColor: const WidgetStatePropertyAll(AppColors.transparent),
    );
  }

  ButtonStyle _iconButtonStyleWithoutOverlay() {
    return ButtonStyle(
      splashFactory: NoSplash.splashFactory,
      overlayColor: const WidgetStatePropertyAll(AppColors.transparent),
    );
  }
}
