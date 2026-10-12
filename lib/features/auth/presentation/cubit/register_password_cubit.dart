import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixa/core/app_state/app_state_cubit.dart';
import 'package:fixa/core/network/app_error.dart';
import 'package:fixa/features/auth/domain/entities/register_password_result.dart';
import 'package:fixa/features/auth/domain/repositories/auth_repository.dart';

part 'register_password_state.dart';

class RegisterPasswordCubit extends Cubit<RegisterPasswordState> {
  RegisterPasswordCubit({
    required AuthRepository authRepository,
    required AppStateCubit appStateCubit,
  }) : _authRepository = authRepository,
       _appStateCubit = appStateCubit,
       super(const RegisterPasswordState());

  final AuthRepository _authRepository;
  final AppStateCubit _appStateCubit;

  Future<void> registerPassword({
    required String email,
    required String phone,
    required String sessionToken,
    required String password,
  }) async {
    emit(
      state.copyWith(
        status: RegisterPasswordStatus.loading,
        clearError: true,
        clearResult: true,
      ),
    );

    try {
      final result = await _authRepository.registerPassword(
        sessionToken: sessionToken,
        password: password,
      );

      _appStateCubit.setRegistrationSession(
        email: email,
        phone: phone,
        sessionToken: sessionToken,
        step: result.step,
      );

      emit(
        state.copyWith(
          status: RegisterPasswordStatus.success,
          result: result,
          clearError: true,
        ),
      );
    } on AppError catch (error) {
      emit(
        state.copyWith(
          status: RegisterPasswordStatus.failure,
          errorMessage: error.message,
          clearResult: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: RegisterPasswordStatus.failure,
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

    emit(
      state.copyWith(status: RegisterPasswordStatus.initial, clearError: true),
    );
  }
}
