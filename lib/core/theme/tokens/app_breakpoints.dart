import 'package:flutter/material.dart';

enum AppDeviceClass {
  compactPhone,
  basePhone,
  largePhone,
  tablet,
}

final class AppBreakpoints {
  const AppBreakpoints._();

  static const double designWidth = 440;
  static const double compactPhoneMaxWidth = 389;
  static const double basePhoneMaxWidth = 479;
  static const double largePhoneMaxWidth = 599;
  static const double tabletMinWidth = 600;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static AppDeviceClass deviceClass(BuildContext context) {
    final width = screenWidth(context);
    if (width <= compactPhoneMaxWidth) {
      return AppDeviceClass.compactPhone;
    }
    if (width <= basePhoneMaxWidth) {
      return AppDeviceClass.basePhone;
    }
    if (width <= largePhoneMaxWidth) {
      return AppDeviceClass.largePhone;
    }
    return AppDeviceClass.tablet;
  }

  static bool isTablet(BuildContext context) =>
      deviceClass(context) == AppDeviceClass.tablet;

  static bool isCompactPhone(BuildContext context) =>
      deviceClass(context) == AppDeviceClass.compactPhone;

  static bool isShortPhone(BuildContext context) =>
      !isTablet(context) && screenHeight(context) <= 700;

  static bool isCompactScreen(BuildContext context) =>
      isCompactPhone(context) || isShortPhone(context);
}
