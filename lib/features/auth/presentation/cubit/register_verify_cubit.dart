import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixa/core/app_state/app_state_cubit.dart';
import 'package:fixa/core/network/app_error.dart';
import 'package:fixa/features/auth/domain/entities/register_verify_result.dart';
import 'package:fixa/features/auth/domain/repositories/auth_repository.dart';

part 'register_verify_state.dart';

class RegisterVerifyCubit extends Cubit<RegisterVerifyState> {
  RegisterVerifyCubit({
    required AuthRepository authRepository,
    required AppStateCubit appStateCubit,
  }) : _authRepository = authRepository,
       _appStateCubit = appStateCubit,
       super(const RegisterVerifyState());

  final AuthRepository _authRepository;
  final AppStateCubit _appStateCubit;

  Future<void> registerVerify({
    required String email,
    required String phone,
    required String sessionToken,
    required String otp,
  }) async {
    emit(
      state.copyWith(
        status: RegisterVerifyStatus.loading,
        clearError: true,
        clearResult: true,
      ),
    );

    try {
      final result = await _authRepository.registerVerify(
        sessionToken: sessionToken,
        otp: otp,
      );

      _appStateCubit.setRegistrationSession(
        email: email,
        phone: phone,
        sessionToken: sessionToken,
        step: result.step,
      );

      emit(
        state.copyWith(
          status: RegisterVerifyStatus.success,
          result: result,
          clearError: true,
        ),
      );
    } on AppError catch (error) {
      emit(
        state.copyWith(
          status: RegisterVerifyStatus.failure,
          errorMessage: error.message,
          clearResult: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: RegisterVerifyStatus.failure,
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
      state.copyWith(status: RegisterVerifyStatus.initial, clearError: true),
    );
  }
}
