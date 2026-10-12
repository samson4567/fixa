import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:fixa/core/app_state/app_state_cubit.dart';
import 'package:fixa/core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../presentation/cubit/register_password_cubit.dart';
import '../../../../shared/widgets/app_form_error_text.dart';
import '../../../../shared/widgets/app_loading_overlay.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/auth_flow_scaffold.dart';
import '../../../../shared/widgets/auth_legal_notice.dart';

class CreatePasswordPage extends StatefulWidget {
  const CreatePasswordPage({
    super.key,
    this.email,
    this.phone,
    this.sessionToken,
  });

  final String? email;
  final String? phone;
  final String? sessionToken;

  @override
  State<CreatePasswordPage> createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends State<CreatePasswordPage> {
  late final TextEditingController _passwordController;
  bool _obscureText = true;

  bool get _hasPassword => _passwordController.text.trim().length >= 8;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController()..addListener(_handleChanged);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _handleChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateCubit>().state;
    final resolvedEmail = widget.email ?? appState.registrationEmail;
    final resolvedPhone = widget.phone ?? appState.registrationPhone;
    final resolvedSessionToken =
        widget.sessionToken ?? appState.registrationSessionToken;

    final displayEmail = (resolvedEmail?.trim().isNotEmpty ?? false)
        ? resolvedEmail!.trim()
        : 'johndoe@gmail.com';

    return BlocConsumer<RegisterPasswordCubit, RegisterPasswordState>(
      listener: (context, state) {
        if (state.status == RegisterPasswordStatus.loading) {
          AppLoadingOverlay.show(
            context,
            title: 'Securing your account',
            subtitle: 'Saving your password safely',
          );
          return;
        }

        AppLoadingOverlay.hide();
        if (state.status != RegisterPasswordStatus.success) {
          return;
        }

        context.go(
          AppRoutes.registerProfile,
          extra: {'sessionToken': resolvedSessionToken},
        );
      },
      builder: (context, state) {
        final password = _passwordController.text.trim();
        final normalizedEmail = resolvedEmail?.trim().toLowerCase();
        final localValidationError =
            normalizedEmail != null &&
                normalizedEmail.isNotEmpty &&
                password.isNotEmpty &&
                password.toLowerCase() == normalizedEmail
            ? 'Password cannot be the same as your email.'
            : null;
        final effectiveError = localValidationError ?? state.errorMessage;

        final canSubmit =
            _hasPassword &&
            !state.isLoading &&
            localValidationError == null &&
            resolvedEmail != null &&
            resolvedPhone != null &&
            resolvedSessionToken != null;

        return AuthFlowScaffold(
          buttonLabel: state.isLoading ? 'Saving...' : 'Sign up',
          onButtonPressed: canSubmit
              ? () => context.read<RegisterPasswordCubit>().registerPassword(
                  email: resolvedEmail,
                  phone: resolvedPhone,
                  sessionToken: resolvedSessionToken,
                  password: _passwordController.text.trim(),
                )
              : null,
          footerContent: const AuthLegalNotice(),
          child: SizedBox(
            width: AppSpacing.authHeroWidth,
            height: 164,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.authHeroHorizontalPadding,
                  ),
                  child: Text(
                    'Create password',
                    style: AppTypography.authFieldTitle,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.authHeroHorizontalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayEmail,
                        style: AppTypography.legalNotice.copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColors.authText,
                        ),
                      ),
                      if (effectiveError != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        AppFormErrorText(
                          message: effectiveError,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        obscureText: _obscureText,
                        width: AppSpacing.inputWidth,
                        onChanged: (_) =>
                            context.read<RegisterPasswordCubit>().clearError(),
                        textStyle: AppTypography.authFieldInput.copyWith(
                          color: AppColors.ink,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.mutedInk,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
