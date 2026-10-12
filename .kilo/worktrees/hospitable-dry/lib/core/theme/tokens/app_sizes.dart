import 'package:fixa/core/theme/tokens/app_scale.dart';
import 'package:flutter/material.dart';

final class AppSizes {
  const AppSizes._();

  static double buttonHeight(BuildContext context) =>
      AppScale.size(context, 60);
  static double compactButtonHeight(BuildContext context) =>
      AppScale.size(context, 36);
  static double inputHeight(BuildContext context) => AppScale.size(context, 52);
  static double tallInputHeight(BuildContext context) =>
      AppScale.size(context, 56);
  static double interactiveTouchTarget(BuildContext context) =>
      AppScale.size(context, 44);
  static double otpFieldWidth(BuildContext context) =>
      AppScale.size(context, 40);
  static double otpFieldHeight(BuildContext context) =>
      AppScale.size(context, 50);
  static double iconSm(BuildContext context) => AppScale.size(context, 16);
  static double iconMd(BuildContext context) => AppScale.size(context, 20);
  static double iconLg(BuildContext context) => AppScale.size(context, 24);
}
