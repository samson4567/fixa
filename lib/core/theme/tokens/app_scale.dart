import 'dart:ui';

import 'package:fixa/core/theme/tokens/app_breakpoints.dart';
import 'package:flutter/material.dart';

final class AppScale {
  const AppScale._();

  static double text(BuildContext context, double base) {
    final widthScale = _widthScale(
      context,
      min: 0.94,
      max: 1.08,
      tabletMax: 1.10,
    );
    final systemScale = _systemTextScale(context).clamp(0.95, 1.20);
    final softenedSystemScale = lerpDouble(1, systemScale, 0.7)!;
    final compactFactor = _compactFactor(context, compact: 0.94, short: 0.97);
    final finalScale = (widthScale * softenedSystemScale * compactFactor).clamp(
      0.88,
      1.20,
    );
    return base * finalScale;
  }

  static double space(BuildContext context, double base) {
    final scale = _widthScale(context, min: 0.94, max: 1.10, tabletMax: 1.12);
    return base * scale * _compactFactor(context, compact: 0.90, short: 0.96);
  }

  static double size(BuildContext context, double base) {
    final scale = _widthScale(context, min: 0.95, max: 1.06, tabletMax: 1.08);
    return base * scale * _compactFactor(context, compact: 0.92, short: 0.97);
  }

  static double radius(BuildContext context, double base) {
    final scale = _widthScale(context, min: 0.98, max: 1.04, tabletMax: 1.04);
    return base * scale * _compactFactor(context, compact: 0.96, short: 0.98);
  }

  static double _widthScale(
    BuildContext context, {
    required double min,
    required double max,
    required double tabletMax,
  }) {
    final widthRatio =
        AppBreakpoints.screenWidth(context) / AppBreakpoints.designWidth;
    final upperBound = AppBreakpoints.isTablet(context) ? tabletMax : max;
    return widthRatio.clamp(min, upperBound);
  }

  static double _systemTextScale(BuildContext context) {
    const probeSize = 16.0;
    final scaled = MediaQuery.textScalerOf(context).scale(probeSize);
    return scaled / probeSize;
  }

  static double _compactFactor(
    BuildContext context, {
    required double compact,
    required double short,
  }) {
    if (AppBreakpoints.isCompactPhone(context)) {
      return compact;
    }
    if (AppBreakpoints.isShortPhone(context)) {
      return short;
    }
    return 1;
  }
}
