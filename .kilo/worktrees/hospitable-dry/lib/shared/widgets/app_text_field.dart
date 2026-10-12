import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/tokens/app_scale.dart';
import '../../core/theme/tokens/app_spacing.dart' as token_spacing;
import '../../core/theme/app_typography.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.prefixIconConstraints,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.width,
    this.height,
    this.textStyle,
    this.hintStyle,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.backgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderWidth = 1,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.inputFormatters,
    this.filled,
    this.fillColor,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.borderRadius = 8,
    this.contentPadding,
    this.enabled = true,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final BoxConstraints? prefixIconConstraints;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double borderWidth;
  final int? maxLength;
  final TextAlign textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final bool? filled;
  final Color? fillColor;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final bool enabled;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        fillColor ?? backgroundColor ?? AppColors.authInputBackground;
    final effectiveBorderColor = borderColor ?? AppColors.authInputBorder;
    final effectiveFocusedBorderColor =
        focusedBorderColor ?? AppColors.authInputBorder;
    final effectiveErrorBorderColor = errorBorderColor ?? AppColors.error;
    final effectiveRadius = AppScale.radius(context, borderRadius);

    final textField = TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: obscureText ? 1 : maxLines,
      textInputAction: textInputAction,
      onChanged: onChanged,
      readOnly: readOnly,
      onTap: onTap,
      enabled: enabled,
      style:
          textStyle ??
          AppTypography.authFieldInput.copyWith(
            fontSize: AppScale.text(context, 17),
          ),
      maxLength: maxLength,
      textAlign: textAlign,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle:
            hintStyle ??
            AppTypography.authFieldHint.copyWith(
              fontSize: AppScale.text(context, 16),
            ),
        prefixIcon: prefixIcon,
        prefixIconConstraints: prefixIconConstraints,
        suffixIcon: suffixIcon,
        counterText: '',
        filled: filled ?? true,
        fillColor: effectiveBackgroundColor,
        contentPadding:
            contentPadding ??
            EdgeInsets.symmetric(
              horizontal: token_spacing.AppSpacing.xl(context),
              vertical: token_spacing.AppSpacing.lg(context),
            ),
        border:
            border ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(effectiveRadius),
              borderSide: BorderSide(
                color: effectiveBorderColor,
                width: borderWidth,
              ),
            ),
        enabledBorder:
            enabledBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(effectiveRadius),
              borderSide: BorderSide(
                color: effectiveBorderColor,
                width: borderWidth,
              ),
            ),
        focusedBorder:
            focusedBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(effectiveRadius),
              borderSide: BorderSide(
                color: effectiveFocusedBorderColor,
                width: borderWidth,
              ),
            ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(effectiveRadius),
          borderSide: BorderSide(
            color: effectiveErrorBorderColor,
            width: borderWidth,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(effectiveRadius),
          borderSide: BorderSide(
            color: effectiveErrorBorderColor,
            width: borderWidth,
          ),
        ),
      ),
    );

    if (height == null) {
      return SizedBox(width: width, child: textField);
    }

    return SizedBox(
      width: width,
      height: AppScale.size(context, height!),
      child: textField,
    );
  }
}
