import 'package:fixa/core/theme/tokens/app_scale.dart';
import 'package:flutter/material.dart';

final class AppSpacing {
  const AppSpacing._();

  static double xxs(BuildContext context) => AppScale.space(context, 2);
  static double xs(BuildContext context) => AppScale.space(context, 4);
  static double sm(BuildContext context) => AppScale.space(context, 8);
  static double md(BuildContext context) => AppScale.space(context, 12);
  static double lg(BuildContext context) => AppScale.space(context, 16);
  static double xl(BuildContext context) => AppScale.space(context, 20);
  static double xxl(BuildContext context) => AppScale.space(context, 24);
  static double section(BuildContext context) => AppScale.space(context, 32);
  static double hero(BuildContext context) => AppScale.space(context, 40);
  static double page(BuildContext context) => AppScale.space(context, 48);
}
