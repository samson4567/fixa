import 'package:fixa/core/theme/tokens/app_breakpoints.dart';
import 'package:fixa/core/theme/tokens/app_scale.dart';
import 'package:flutter/material.dart';

enum AppContentSurface { auth, wallet, feed, streamOverlay }

final class AppLayout {
  const AppLayout._();

  static double horizontalPadding(BuildContext context) {
    return switch (AppBreakpoints.deviceClass(context)) {
      AppDeviceClass.compactPhone => AppScale.space(context, 16),
      AppDeviceClass.basePhone => AppScale.space(context, 20),
      AppDeviceClass.largePhone => AppScale.space(context, 24),
      AppDeviceClass.tablet => AppScale.space(context, 32),
    };
  }

  static double maxContentWidth(
    BuildContext context,
    AppContentSurface surface,
  ) {
    if (!AppBreakpoints.isTablet(context)) {
      return double.infinity;
    }
    return switch (surface) {
      AppContentSurface.auth => 520,
      AppContentSurface.wallet => 680,
      AppContentSurface.feed => 720,
      AppContentSurface.streamOverlay => 720,
    };
  }
}
