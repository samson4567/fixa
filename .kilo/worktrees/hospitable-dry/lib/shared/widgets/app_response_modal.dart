import 'package:flutter/material.dart';

import 'package:fixa/core/theme/app_colors.dart';
import 'package:fixa/core/theme/app_typography.dart';

Future<void> showAppResponseModal(
  BuildContext context, {
  required String message,
  bool isError = false,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 42),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300,
        padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: (isError ? AppColors.error : AppColors.primary)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isError ? Icons.error_outline_rounded : Icons.check_rounded,
                color: isError ? AppColors.error : AppColors.primary,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTypography.authBody.copyWith(
                  color: AppColors.authText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close_rounded, size: 19),
            ),
          ],
        ),
      ),
    ),
  );
}
