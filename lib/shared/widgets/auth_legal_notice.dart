import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class AuthLegalNotice extends StatelessWidget {
  const AuthLegalNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTypography.legalNotice.copyWith(color: AppColors.ink);
    final linkStyle = baseStyle.copyWith(
      color: AppColors.primary,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.underline,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          const TextSpan(
            text:
                'By signing up, signing in or continuing, I agree to AMASS’s ',
          ),
          TextSpan(text: 'Terms of Use', style: linkStyle),
          const TextSpan(text: ' and '),
          TextSpan(text: 'Privacy Policy.', style: linkStyle),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
