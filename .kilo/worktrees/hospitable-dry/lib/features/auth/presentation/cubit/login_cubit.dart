import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixa/core/network/app_error.dart';
import 'package:fixa/core/storage/app_preference_service.dart';
import 'package:fixa/features/auth/domain/entities/login_result.dart';
import 'package:fixa/features/auth/domain/repositories/auth_repository.dart';
import 'package:fixa/features/auth/presentation/cubit/user_profile_cubit.dart';
import 'package:fixa/features/dashboard/presentation/cubit/property_feed_cubit.dart';
import 'package:fixa/features/dashboard/presentation/cubit/property_favorites_cubit.dart';
import 'package:fixa/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:fixa/features/dashboard/presentation/cubit/notification_cubit.dart';

part 'login_state.dart';

const String _authTokenStorageKey = 'auth_token';
const String _refreshTokenStorageKey = 'refresh_token';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required AuthRepository authRepository,
    required AppPreferenceService appPreferenceService,
  }) : _authRepository = authRepository,
       _appPreferenceService = appPreferenceService,
       super(const LoginState());

  final AuthRepository _authRepository;
  final AppPreferenceService _appPreferenceService;

  Future<void> loginWithGoogle({required String credential}) async {
    final normalizedCredential = credential.trim();
    if (normalizedCredential.isEmpty) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Unable to continue with Google. Please try again.',
          clearResult: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: LoginStatus.loading,
        clearError: true,
        clearResult: true,
      ),
    );

    try {
      final result = await _authRepository.loginWithGoogle(
        credential: normalizedCredential,
      );
      await _handleLoginSuccess(result);
    } on AppError catch (error) {
      _emitFailure(error.message);
    } catch (_) {
      _emitFailure('Something went wrong. Please try again.');
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(
      state.copyWith(
        status: LoginStatus.loading,
        clearError: true,
        clearResult: true,
      ),
    );

    try {
      final result = await _authRepository.login(
        email: email,
        password: password,
      );
      await _handleLoginSuccess(result);
    } on AppError catch (error) {
      _emitFailure(error.message);
    } catch (_) {
      _emitFailure('Something went wrong. Please try again.');
    }
  }

  Future<void> _handleLoginSuccess(LoginResult result) async {
    if (result.accessToken.trim().isNotEmpty) {
      await _appPreferenceService.saveValue<String>(
        _authTokenStorageKey,
        result.accessToken.trim(),
      );
    }
    if (result.refreshToken.trim().isNotEmpty) {
      await _appPreferenceService.saveValue<String>(
        _refreshTokenStorageKey,
        result.refreshToken.trim(),
      );
    }

    UserProfileCubit.invalidateCache();
    PropertyFeedCubit.invalidateCache();
    PropertyFavoritesCubit.invalidateCache();
    NotificationCubit.invalidateCache();
    SubscriptionCubit.invalidateCache();

    emit(
      state.copyWith(
        status: LoginStatus.success,
        result: result,
        clearError: true,
      ),
    );
  }

  void _emitFailure(String message) {
    emit(
      state.copyWith(
        status: LoginStatus.failure,
        errorMessage: message,
        clearResult: true,
      ),
    );
  }

  void clearError() {
    if (state.errorMessage == null) {
      return;
    }

    emit(state.copyWith(status: LoginStatus.initial, clearError: true));
  }
}
