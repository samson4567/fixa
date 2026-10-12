import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:fixa/core/routing/app_routes.dart';
import 'package:fixa/core/theme/app_colors.dart';
import 'package:fixa/core/theme/app_spacing.dart';
import 'package:fixa/core/theme/app_typography.dart';
import 'package:fixa/features/auth/presentation/cubit/login_cubit.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/auth_flow_scaffold.dart';
import '../../../../shared/widgets/auth_legal_notice.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  static const _prefilledEmail = 'samadeyemi1888@gmail.com';
  static const _prefilledPassword = 'samlucy111@@';

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  BuildContext? _loaderDialogContext;
  bool _obscurePassword = true;

  bool get _hasEmail => _emailController.text.trim().isNotEmpty;
  bool get _hasPassword => _passwordController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: _prefilledEmail)
      ..addListener(_handleChanged);
    _passwordController = TextEditingController(text: _prefilledPassword)
      ..addListener(_handleChanged);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleChanged() {
    setState(() {});
  }

  void _showLoginLoader() {
    if (_loaderDialogContext != null) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.white.withValues(alpha: 0.92),
      builder: (dialogContext) {
        _loaderDialogContext = dialogContext;
        return PopScope(
          canPop: false,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 68,
                    height: 68,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const SizedBox(
                          width: 68,
                          height: 68,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            backgroundColor: Color(0xFFFFE4E4),
                            strokeWidth: 3,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.home_rounded,
                            color: AppColors.white,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Getting things ready',
                    style: AppTypography.authBody.copyWith(
                      color: AppColors.authText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Signing you in securely',
                    style: AppTypography.authBody.copyWith(
                      color: AppColors.mutedInk,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(() => _loaderDialogContext = null);
  }

  void _hideLoginLoader() {
    final dialogContext = _loaderDialogContext;
    if (dialogContext == null) return;

    _loaderDialogContext = null;
    Navigator.of(dialogContext).pop();
  }

  Future<void> _showLoginModal({
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final statusColor = isSuccess
            ? const Color(0xFF23875B)
            : AppColors.error;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 44),
          backgroundColor: Colors.transparent,
          child: Container(
            width: 292,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x24000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSuccess
                            ? Icons.check_rounded
                            : Icons.error_outline_rounded,
                        color: statusColor,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.authBody.copyWith(
                              color: AppColors.authText,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            message,
                            style: AppTypography.authBody.copyWith(
                              color: AppColors.mutedInk,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      textStyle: AppTypography.authButtonLabel.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) async {
        if (state.status == LoginStatus.loading) {
          _showLoginLoader();
          return;
        }

        if (state.status == LoginStatus.failure) {
          _hideLoginLoader();
          final message = state.errorMessage?.trim();
          await _showLoginModal(
            title: 'Sign in failed',
            isSuccess: false,
            message: message != null && message.isNotEmpty
                ? message
                : 'Something went wrong. Please try again.',
          );
          return;
        }

        if (state.status == LoginStatus.success) {
          _hideLoginLoader();
          final message = state.result?.message.trim();
          await _showLoginModal(
            title: 'Sign in successful',
            isSuccess: true,
            message: message != null && message.isNotEmpty
                ? message
                : 'Sign in successful.',
          );
          if (mounted) {
            this.context.go(AppRoutes.dashboard);
          }
        }
      },
      builder: (context, state) {
        final canSubmit = _hasEmail && _hasPassword && !state.isLoading;

        return AuthFlowScaffold(
          buttonLabel: state.isLoading ? 'Signing in...' : 'Sign in',
          onButtonPressed: canSubmit
              ? () => context.read<LoginCubit>().login(
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
                )
              : null,
          footerContent: const AuthLegalNotice(),
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
                      'Login with Email',
                      style: AppTypography.authFieldTitle.copyWith(
                        color: AppColors.authText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _emailController,
                      hintText: 'Enter Email',
                      keyboardType: TextInputType.emailAddress,
                      width: AppSpacing.inputWidth,
                      onChanged: (_) => context.read<LoginCubit>().clearError(),
                      textStyle: AppTypography.authFieldInput.copyWith(
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: _obscurePassword,
                      width: AppSpacing.inputWidth,
                      onChanged: (_) => context.read<LoginCubit>().clearError(),
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
                          color: AppColors.mutedInk,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: AppSpacing.inputWidth,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              context.push(AppRoutes.forgotPassword),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.authText,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: AppTypography.forgotPassword,
                          ),
                          child: const Text('Forgot Password?'),
                        ),
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
