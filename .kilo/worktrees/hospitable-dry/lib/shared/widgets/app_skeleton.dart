import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppSkeletonTheme extends StatelessWidget {
  const AppSkeletonTheme({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final effectiveBaseColor = baseColor ??
        (brightness == Brightness.dark
            ? const Color(0xFF16181B)
            : const Color(0xFFE7E9EE));
    final effectiveHighlightColor = highlightColor ??
        (brightness == Brightness.dark
            ? const Color(0xFF23262B)
            : const Color(0xFFF5F6FA));

    return Shimmer.fromColors(
      baseColor: effectiveBaseColor,
      highlightColor: effectiveHighlightColor,
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}

class AppSkeletonBox extends StatelessWidget {
  const AppSkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 12,
    this.color = Colors.white,
  });

  final double width;
  final double height;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
