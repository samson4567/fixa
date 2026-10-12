import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'app_text_field.dart';

class InlineActionTextField extends StatelessWidget {
  const InlineActionTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.onTap,
  });

  final TextEditingController controller;
  final String hintText;
  final Widget icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.inputWidth,
      height: AppSpacing.inputHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.textFieldBorder, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: AppTextField(
                  controller: controller,
                  hintText: hintText,
                  textStyle: AppTypography.authFieldInput,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
            SizedBox(
              width: 58,
              height: double.infinity,
              child: Material(
                color: const Color(0xFF08A000),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(7),
                  bottomRight: Radius.circular(7),
                ),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                  child: Center(child: icon),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
