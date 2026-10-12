import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:fixa/core/routing/app_routes.dart';
import 'package:fixa/core/theme/app_colors.dart';
import 'package:fixa/core/theme/app_spacing.dart';
import 'package:fixa/core/theme/app_typography.dart';
import 'package:fixa/features/auth/presentation/cubit/reset_password_cubit.dart';
import 'package:fixa/shared/widgets/app_form_error_text.dart';
import 'package:fixa/shared/widgets/app_form_label.dart';
import 'package:fixa/shared/widgets/app_text_field.dart';
import 'package:fixa/shared/widgets/auth_flow_scaffold.dart';
import 'package:fixa/shared/widgets/app_response_modal.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, this.email, this.otp});

  final String? email;
  final String? otp;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool get _hasPassword => _passwordController.text.trim().length >= 8;

  bool get _hasConfirmPassword =>
      _confirmPasswordController.text.trim().isNotEmpty;

  bool get _passwordsMatch =>
      _passwordController.text.trim() == _confirmPasswordController.text.trim();

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController()..addListener(_handleChanged);
    _confirmPasswordController = TextEditingController()
      ..addListener(_handleChanged);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.email?.trim() ?? '';
    final otp = widget.otp?.trim() ?? '';
    String? localValidationError;
    if (_hasConfirmPassword && !_passwordsMatch) {
      localValidationError = 'Passwords do not match.';
    } else if (email.isEmpty) {
      localValidationError =
          'Email is missing. Please request another password reset.';
    } else if (otp.isEmpty) {
      localValidationError =
          'Reset code is missing. Please request another password reset.';
    }

    return BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
      listener: (context, state) async {
        if (state.status != ResetPasswordStatus.success) {
          return;
        }

        final message = state.result?.message.trim();
        await showAppResponseModal(
          context,
          message: message != null && message.isNotEmpty
              ? message
              : 'Password reset successfully.',
        );
        if (context.mounted) context.go(AppRoutes.signIn);
      },
      builder: (context, state) {
        final effectiveError = localValidationError ?? state.errorMessage;
        final canSubmit =
            _hasPassword &&
            _hasConfirmPassword &&
            _passwordsMatch &&
            email.isNotEmpty &&
            otp.isNotEmpty &&
            !state.isLoading;

        return AuthFlowScaffold(
          buttonLabel: state.isLoading ? 'Saving...' : 'Continue',
          onButtonPressed: canSubmit
              ? () => context.read<ResetPasswordCubit>().resetPassword(
                  email: email,
                  otp: otp,
                  password: _passwordController.text.trim(),
                  confirmPassword: _confirmPasswordController.text.trim(),
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
                  'Enter Password?',
                  style: AppTypography.authFieldTitle.copyWith(
                    color: AppColors.authText,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Your new password should be different from your password',
                  style: AppTypography.authBody.copyWith(
                    color: AppColors.authText,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const AppFormLabel(text: 'New Password', color: AppColors.ink),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _passwordController,
                  hintText: 'New password',
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  width: AppSpacing.inputWidth,
                  onChanged: (_) =>
                      context.read<ResetPasswordCubit>().clearError(),
                  textStyle: AppTypography.authFieldInput.copyWith(
                    color: AppColors.ink,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.ink,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const AppFormLabel(
                  text: 'Confirm New Password',
                  color: AppColors.ink,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm new password',
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  width: AppSpacing.inputWidth,
                  onChanged: (_) =>
                      context.read<ResetPasswordCubit>().clearError(),
                  textStyle: AppTypography.authFieldInput.copyWith(
                    color: AppColors.ink,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.ink,
                      size: 20,
                    ),
                  ),
                ),
                if (effectiveError != null && effectiveError.trim().isNotEmpty)
                  AppFormErrorText(
                    message: effectiveError,
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
