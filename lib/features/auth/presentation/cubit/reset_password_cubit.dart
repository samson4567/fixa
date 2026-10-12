import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixa/core/network/app_error.dart';
import 'package:fixa/features/auth/domain/entities/reset_password_result.dart';
import 'package:fixa/features/auth/domain/repositories/auth_repository.dart';

part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const ResetPasswordState());

  final AuthRepository _authRepository;

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
  }) async {
    emit(
      state.copyWith(
        status: ResetPasswordStatus.loading,
        clearError: true,
        clearResult: true,
      ),
    );

    try {
      final result = await _authRepository.resetPassword(
        email: email,
        otp: otp,
        password: password,
        confirmPassword: confirmPassword,
      );

      emit(
        state.copyWith(
          status: ResetPasswordStatus.success,
          result: result,
          clearError: true,
        ),
      );
    } on AppError catch (error) {
      emit(
        state.copyWith(
          status: ResetPasswordStatus.failure,
          errorMessage: error.message,
          clearResult: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ResetPasswordStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
          clearResult: true,
        ),
      );
    }
  }

  void clearError() {
    if (state.errorMessage == null) {
      return;
    }

    emit(state.copyWith(status: ResetPasswordStatus.initial, clearError: true));
  }
}
