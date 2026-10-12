import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:fixa/core/di/service_locator.dart';
import 'package:fixa/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:fixa/features/auth/presentation/cubit/login_cubit.dart';
import 'package:fixa/features/auth/presentation/cubit/register_initiate_cubit.dart';
import 'package:fixa/features/auth/presentation/cubit/register_password_cubit.dart';
import 'package:fixa/features/auth/presentation/cubit/register_profile_cubit.dart';
import 'package:fixa/features/auth/presentation/cubit/register_verify_cubit.dart';
import 'package:fixa/features/auth/presentation/cubit/reset_password_cubit.dart';
import 'package:fixa/features/auth/presentation/pages/auth_welcome_page.dart';
import 'package:fixa/features/auth/presentation/pages/amass_splash_page.dart';
import 'package:fixa/features/auth/presentation/pages/create_password_page.dart';
import 'package:fixa/features/auth/presentation/pages/email_sign_up_page.dart';
import 'package:fixa/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:fixa/features/auth/presentation/pages/phone_sign_in_page.dart';
import 'package:fixa/features/auth/presentation/pages/register_profile_page.dart';
import 'package:fixa/features/auth/presentation/pages/reset_password_verification_page.dart';
import 'package:fixa/features/auth/presentation/pages/reset_password_page.dart';
import 'package:fixa/features/auth/presentation/pages/sign_in_page.dart';
import 'package:fixa/features/auth/presentation/pages/verification_code_page.dart';
import 'package:fixa/features/dashboard/presentation/pages/dashboard_map_page.dart';
import 'package:fixa/features/subscription/presentation/pages/subscription_callback_page.dart';

class AppRoutes {
  const AppRoutes._();

  static const splash = '/';
  static const authWelcome = '/welcome';
  static const emailSignUp = '/email-sign-up';
  static const signIn = '/sign-in';
  static const forgotPassword = '/forgot-password';
  static const resetPasswordVerification = '/reset-password-verification';
  static const resetPassword = '/reset-password';
  static const phoneSignIn = '/phone-sign-in';
  static const verificationCode = '/verification-code';
  static const createPassword = '/create-password';
  static const registerProfile = '/register-profile';
  static const dashboard = '/dashboard';
  static const subscriptionCallback = '/subscription/callback';

  static GoRouter router() {
    return GoRouter(
      initialLocation: splash,
      routes: [
        GoRoute(
          path: splash,
          builder: (context, state) => const AmassSplashPage(),
        ),
        GoRoute(
          path: authWelcome,
          builder: (context, state) => BlocProvider<LoginCubit>(
            create: (_) => getIt<LoginCubit>(),
            child: const AuthWelcomePage(),
          ),
        ),
        GoRoute(
          path: dashboard,
          builder: (context, state) => const DashboardMapPage(),
        ),
        GoRoute(
          path: subscriptionCallback,
          builder: (context, state) => const SubscriptionCallbackPage(),
        ),
        GoRoute(
          path: emailSignUp,
          builder: (context, state) => const EmailSignUpPage(),
        ),
        GoRoute(
          path: signIn,
          builder: (context, state) => BlocProvider<LoginCubit>(
            create: (_) => getIt<LoginCubit>(),
            child: const SignInPage(),
          ),
        ),
        GoRoute(
          path: forgotPassword,
          builder: (context, state) => BlocProvider<ForgotPasswordCubit>(
            create: (_) => getIt<ForgotPasswordCubit>(),
            child: const ForgotPasswordPage(),
          ),
        ),
        GoRoute(
          path: resetPassword,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return BlocProvider<ResetPasswordCubit>(
              create: (_) => getIt<ResetPasswordCubit>(),
              child: ResetPasswordPage(
                email:
                    extra?['email'] as String? ??
                    state.uri.queryParameters['email'],
                otp:
                    extra?['otp'] as String? ??
                    state.uri.queryParameters['otp'],
              ),
            );
          },
        ),
        GoRoute(
          path: resetPasswordVerification,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return ResetPasswordVerificationPage(
              email:
                  extra?['email'] as String? ??
                  state.uri.queryParameters['email'],
            );
          },
        ),
        GoRoute(
          path: phoneSignIn,
          builder: (context, state) => BlocProvider<RegisterInitiateCubit>(
            create: (_) => getIt<RegisterInitiateCubit>(),
            child: PhoneSignInPage(email: state.uri.queryParameters['email']),
          ),
        ),
        GoRoute(
          path: verificationCode,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return BlocProvider<RegisterVerifyCubit>(
              create: (_) => getIt<RegisterVerifyCubit>(),
              child: VerificationCodePage(
                email: extra?['email'] as String?,
                phone: extra?['phone'] as String?,
                sessionToken: extra?['sessionToken'] as String?,
              ),
            );
          },
        ),
        GoRoute(
          path: createPassword,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return BlocProvider<RegisterPasswordCubit>(
              create: (_) => getIt<RegisterPasswordCubit>(),
              child: CreatePasswordPage(
                email: extra?['email'] as String?,
                phone: extra?['phone'] as String?,
                sessionToken: extra?['sessionToken'] as String?,
              ),
            );
          },
        ),
        GoRoute(
          path: registerProfile,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return BlocProvider<RegisterProfileCubit>(
              create: (_) => getIt<RegisterProfileCubit>(),
              child: RegisterProfilePage(
                sessionToken: extra?['sessionToken'] as String?,
              ),
            );
          },
        ),
      ],
    );
  }
}
