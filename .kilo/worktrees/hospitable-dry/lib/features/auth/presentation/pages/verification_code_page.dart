import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:fixa/core/app_state/app_state_cubit.dart';
import 'package:fixa/core/routing/app_routes.dart';
import 'package:fixa/core/theme/app_colors.dart';
import 'package:fixa/core/theme/app_spacing.dart';
import 'package:fixa/core/theme/app_typography.dart';
import 'package:fixa/features/auth/presentation/cubit/register_verify_cubit.dart';
import 'package:fixa/shared/widgets/app_loading_overlay.dart';
import 'package:fixa/shared/widgets/auth_flow_scaffold.dart';
import 'package:fixa/shared/widgets/verification_code_field.dart';

class VerificationCodePage extends StatefulWidget {
  const VerificationCodePage({
    super.key,
    this.email,
    this.phone,
    this.sessionToken,
  });

  final String? email;
  final String? phone;
  final String? sessionToken;

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  static const int _otpLength = 4;
  String _code = '';

  bool get _isComplete => _code.length == _otpLength;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateCubit>().state;
    final resolvedEmail = widget.email ?? appState.registrationEmail;
    final resolvedPhone = widget.phone ?? appState.registrationPhone;
    final resolvedSessionToken =
        widget.sessionToken ?? appState.registrationSessionToken;

    return BlocConsumer<RegisterVerifyCubit, RegisterVerifyState>(
      listener: (context, state) {
        if (state.status == RegisterVerifyStatus.loading) {
          AppLoadingOverlay.show(
            context,
            title: 'Verifying your code',
            subtitle: 'Keeping your account secure',
          );
          return;
        }

        AppLoadingOverlay.hide();
        if (state.status != RegisterVerifyStatus.success) {
          return;
        }

        context.push(
          AppRoutes.createPassword,
          extra: {
            'email': resolvedEmail,
            'phone': resolvedPhone,
            'sessionToken': resolvedSessionToken,
          },
        );
      },
      builder: (context, state) {
        final canSubmit =
            _isComplete &&
            !state.isLoading &&
            resolvedEmail != null &&
            resolvedPhone != null &&
            resolvedSessionToken != null;

        return AuthFlowScaffold(
          buttonLabel: state.isLoading ? 'Verifying...' : 'Continue',
          onButtonPressed: canSubmit
              ? () => context.read<RegisterVerifyCubit>().registerVerify(
                  email: resolvedEmail,
                  phone: resolvedPhone,
                  sessionToken: resolvedSessionToken,
                  otp: _code,
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
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
                      'A 4 digit code has been sent to your email and phone number, enter the code to continue',
                      style: AppTypography.authBody.copyWith(
                        color: AppColors.ink,
                      ),
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        state.errorMessage!,
                        style: AppTypography.authBody.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ],
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
                          context.read<RegisterVerifyCubit>().clearError();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
