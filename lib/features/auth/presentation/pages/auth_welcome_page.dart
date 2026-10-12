import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../cubit/login_cubit.dart';
import '../../../../shared/widgets/app_asset_icon.dart';
import '../../../../shared/widgets/auth_legal_notice.dart';
import '../../../../shared/widgets/auth_provider_button.dart';
import '../../../../shared/widgets/auth_welcome_hero.dart';

class AuthWelcomePage extends StatefulWidget {
  const AuthWelcomePage({super.key});

  @override
  State<AuthWelcomePage> createState() => _AuthWelcomePageState();
}

class _AuthWelcomePageState extends State<AuthWelcomePage> {
  static const String _googleServerClientId =
      '933118997615-in54iif7h30e01h4d99ef5bt3sbko7ht.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: _googleServerClientId,
  );
  BuildContext? _loaderDialogContext;

  Future<void> _onGooglePressed() async {
    if (context.read<LoginCubit>().state.isLoading) {
      return;
    }

    try {
      await _googleSignIn.signOut();
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken?.trim() ?? '';
      final accessToken = auth.accessToken?.trim() ?? '';
      final credential = idToken.isNotEmpty ? idToken : accessToken;

      if (credential.isEmpty) {
        if (!mounted) {
          return;
        }

        await _showLoginModal(
          title: 'Google sign in failed',
          message: 'Unable to get Google credential. Please try again.',
          isSuccess: false,
        );
        return;
      }

      if (!mounted) {
        return;
      }

      await context.read<LoginCubit>().loginWithGoogle(credential: credential);
    } catch (error) {
      if (!mounted) {
        return;
      }

      final details = error.toString();
      final message = details.isEmpty
          ? 'Unable to continue with Google. Please try again.'
          : 'Unable to continue with Google. $details';

      await _showLoginModal(
        title: 'Google sign in failed',
        message: message,
        isSuccess: false,
      );
    }
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
            title: 'Google sign in failed',
            isSuccess: false,
            message: message != null && message.isNotEmpty
                ? message
                : 'Unable to continue with Google. Please try again.',
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
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth = (constraints.maxWidth - 40).clamp(
                  0.0,
                  AppSpacing.authActionsWidth,
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.authHeroHorizontalPadding,
                    vertical: 12,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const AuthWelcomeHero(),
                          const SizedBox(height: AppSpacing.authHeroGap),
                          SizedBox(
                            width: contentWidth,
                            height: AppSpacing.authActionsHeight,
                            child: Column(
                              children: [
                                AuthProviderButton(
                                  label: 'Continue with Email',
                                  leading: const AppAssetIcon(
                                    assetPath: 'assets/icons/mail.svg',
                                  ),
                                  onPressed: () =>
                                      context.push(AppRoutes.emailSignUp),
                                ),
                                const SizedBox(
                                  height: AppSpacing.authActionsGap,
                                ),
                                AuthProviderButton(
                                  label: state.isLoading
                                      ? 'Signing in...'
                                      : 'Continue with Google',
                                  leading: const AppAssetIcon(
                                    assetPath: 'assets/icons/google.svg',
                                  ),
                                  onPressed: state.isLoading
                                      ? null
                                      : _onGooglePressed,
                                ),
                                const SizedBox(
                                  height: AppSpacing.authActionsGap,
                                ),
                                AuthProviderButton(
                                  label: 'Continue with Apple ID',
                                  leading: const AppAssetIcon(
                                    assetPath: 'assets/icons/apple.svg',
                                    width: 12,
                                    height: 14,
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            width: contentWidth,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      context.push(AppRoutes.signIn),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.ink,
                                    textStyle: AppTypography.forgotPassword
                                        .copyWith(color: AppColors.ink),
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text('Sign In'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      context.push(AppRoutes.forgotPassword),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.ink,
                                    textStyle: AppTypography.forgotPassword
                                        .copyWith(color: AppColors.ink),
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text('Forgot Password?'),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(height: AppSpacing.xxl),
                          SizedBox(
                            width: contentWidth,
                            child: const Padding(
                              padding: EdgeInsets.only(bottom: AppSpacing.md),
                              child: AuthLegalNotice(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
