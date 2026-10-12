import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fixa/core/routing/app_routes.dart';
import 'package:fixa/core/theme/app_colors.dart';
import 'package:fixa/core/theme/app_spacing.dart';
import 'package:fixa/core/theme/app_typography.dart';
import 'package:fixa/shared/widgets/auth_flow_scaffold.dart';
import 'package:fixa/shared/widgets/verification_code_field.dart';

class ResetPasswordVerificationPage extends StatefulWidget {
  const ResetPasswordVerificationPage({super.key, this.email});

  final String? email;

  @override
  State<ResetPasswordVerificationPage> createState() =>
      _ResetPasswordVerificationPageState();
}

class _ResetPasswordVerificationPageState
    extends State<ResetPasswordVerificationPage> {
  static const int _otpLength = 4;
  String _code = '';

  bool get _isComplete => _code.length == _otpLength;

  @override
  Widget build(BuildContext context) {
    final email = widget.email?.trim() ?? '';

    return AuthFlowScaffold(
      buttonLabel: 'Continue',
      onButtonPressed: _isComplete && email.isNotEmpty
          ? () => context.push(
                AppRoutes.resetPassword,
                extra: {'email': email, 'otp': _code},
              )
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.authHeroHorizontalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter verification code',
              style: AppTypography.authFieldTitle.copyWith(
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'A 4 digit code has been sent to your email, enter the code to continue',
              style: AppTypography.authBody.copyWith(color: AppColors.ink),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                'Enter code',
                style: AppTypography.authFieldTitle.copyWith(
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: VerificationCodeField(
                length: _otpLength,
                onChanged: (value) {
                  setState(() {
                    _code = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
