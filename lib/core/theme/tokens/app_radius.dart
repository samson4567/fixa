import 'package:fixa/core/theme/tokens/app_scale.dart';
import 'package:flutter/material.dart';

final class AppRadius {
  const AppRadius._();

  static double sm(BuildContext context) => AppScale.radius(context, 8);
  static double md(BuildContext context) => AppScale.radius(context, 12);
  static double lg(BuildContext context) => AppScale.radius(context, 16);
  static double xl(BuildContext context) => AppScale.radius(context, 20);
  static double pill(BuildContext context) => AppScale.radius(context, 23);
}
