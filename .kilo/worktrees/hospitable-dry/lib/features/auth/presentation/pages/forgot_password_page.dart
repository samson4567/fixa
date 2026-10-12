import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:fixa/core/routing/app_routes.dart';
import 'package:fixa/core/theme/app_colors.dart';
import 'package:fixa/core/theme/app_spacing.dart';
import 'package:fixa/core/theme/app_typography.dart';
import 'package:fixa/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:fixa/shared/widgets/app_form_error_text.dart';
import 'package:fixa/shared/widgets/app_form_label.dart';
import 'package:fixa/shared/widgets/app_text_field.dart';
import 'package:fixa/shared/widgets/auth_flow_scaffold.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final TextEditingController _emailController;

  bool get _hasEmail => _emailController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController()..addListener(_handleChanged);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state.status != ForgotPasswordStatus.success) {
          return;
        }

        context.push(
          AppRoutes.resetPasswordVerification,
          extra: {
            'email': _emailController.text.trim(),
          },
        );
      },
      builder: (context, state) {
        final canSubmit = _hasEmail && !state.isLoading;

        return AuthFlowScaffold(
          buttonLabel: state.isLoading ? 'Sending...' : 'Continue',
          onButtonPressed: canSubmit
              ? () => context.read<ForgotPasswordCubit>().forgotPassword(
                  email: _emailController.text.trim(),
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
                  'Forgot your password?',
                  style: AppTypography.authFieldTitle.copyWith(
                    color: AppColors.authText,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Enter your email address to reset your password',
                  style: AppTypography.authBody.copyWith(
                    color: AppColors.authText,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const AppFormLabel(text: 'Email address', color: AppColors.ink),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _emailController,
                  hintText: 'Enter email address',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  width: AppSpacing.inputWidth,
                  onChanged: (_) =>
                      context.read<ForgotPasswordCubit>().clearError(),
                  textStyle: AppTypography.authFieldInput.copyWith(
                    color: AppColors.ink,
                  ),
                ),
                if (state.errorMessage != null &&
                    state.errorMessage!.trim().isNotEmpty)
                  AppFormErrorText(
                    message: state.errorMessage!,
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
