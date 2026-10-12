import 'package:flutter/material.dart';

import 'package:fixa/core/theme/app_colors.dart';
import 'package:fixa/core/theme/app_typography.dart';

class AppLoadingOverlay {
  AppLoadingOverlay._();

  static BuildContext? _dialogContext;
  static NavigatorState? _dialogNavigator;
  static final Set<String> _openedDestinations = <String>{'home'};

  static void resetNavigationState() {
    _openedDestinations
      ..clear()
      ..add('home');
  }

  static void show(
    BuildContext context, {
    String title = 'Getting things ready',
    String subtitle = 'Please wait a moment',
  }) {
    if (_dialogContext != null) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.white.withValues(alpha: 0.92),
      builder: (dialogContext) {
        _dialogContext = dialogContext;
        _dialogNavigator = Navigator.of(dialogContext, rootNavigator: true);
        return PopScope(
          canPop: false,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 68,
                    height: 68,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const SizedBox(
                          width: 68,
                          height: 68,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            backgroundColor: Color(0xFFFFE4E4),
                            strokeWidth: 3,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.home_rounded,
                            color: AppColors.white,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTypography.authBody.copyWith(
                      color: AppColors.authText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.authBody.copyWith(
                      color: AppColors.mutedInk,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      _dialogContext = null;
      _dialogNavigator = null;
    });
  }

  static void hide() {
    final dialogNavigator = _dialogNavigator;
    _dialogContext = null;
    _dialogNavigator = null;

    if (dialogNavigator == null || !dialogNavigator.mounted) {
      return;
    }

    if (dialogNavigator.canPop()) {
      dialogNavigator.pop();
    }
  }

  static Future<T?> push<T>(
    BuildContext context,
    Route<T> route, {
    String title = 'Opening your page',
    String? destinationKey,
  }) async {
    if (destinationKey != null &&
        _openedDestinations.contains(destinationKey)) {
      return Navigator.of(context).push<T>(route);
    }

    show(context, title: title, subtitle: 'Loading your latest information');
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!context.mounted) {
      hide();
      return null;
    }
    hide();
    if (destinationKey != null) {
      _openedDestinations.add(destinationKey);
    }
    return Navigator.of(context).push<T>(route);
  }

  static Future<T?> replace<T, TO>(
    BuildContext context,
    Route<T> route, {
    String title = 'Opening your page',
    String? destinationKey,
  }) async {
    if (destinationKey != null &&
        _openedDestinations.contains(destinationKey)) {
      return Navigator.of(context).pushReplacement<T, TO>(route);
    }

    show(context, title: title, subtitle: 'Loading your latest information');
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!context.mounted) {
      hide();
      return null;
    }
    hide();
    if (destinationKey != null) {
      _openedDestinations.add(destinationKey);
    }
    return Navigator.of(context).pushReplacement<T, TO>(route);
  }
}
