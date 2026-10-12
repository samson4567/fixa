import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'app_form_error_text.dart';
import 'app_text_field.dart';

class AuthFieldSection extends StatelessWidget {
  const AuthFieldSection({
    super.key,
    required this.title,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.errorMessage,
    this.onChanged,
  });

  final String title;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final String? errorMessage;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 114),
      child: SizedBox(
        width: AppSpacing.authHeroWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.authHeroHorizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppTypography.authFieldTitle),
              const SizedBox(height: AppSpacing.inputGap),
              AppTextField(
                controller: controller,
                hintText: hintText,
                keyboardType: keyboardType,
                width: AppSpacing.inputWidth,
                textStyle: AppTypography.authFieldInput,
                onChanged: onChanged,
              ),
              if (errorMessage != null && errorMessage!.trim().isNotEmpty)
                AppFormErrorText(message: errorMessage!),
            ],
          ),
        ),
      ),
    );
  }
}
