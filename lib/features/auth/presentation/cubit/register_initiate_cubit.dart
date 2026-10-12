import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixa/core/app_state/app_state_cubit.dart';
import 'package:fixa/core/network/app_error.dart';
import 'package:fixa/features/auth/domain/entities/register_initiate_result.dart';
import 'package:fixa/features/auth/domain/repositories/auth_repository.dart';

part 'register_initiate_state.dart';

class RegisterInitiateCubit extends Cubit<RegisterInitiateState> {
  RegisterInitiateCubit({
    required AuthRepository authRepository,
    required AppStateCubit appStateCubit,
  }) : _authRepository = authRepository,
       _appStateCubit = appStateCubit,
       super(const RegisterInitiateState());

  final AuthRepository _authRepository;
  final AppStateCubit _appStateCubit;

  Future<void> registerInitiate({
    required String email,
    required String phone,
  }) async {
    emit(
      state.copyWith(
        status: RegisterInitiateStatus.loading,
        clearError: true,
        clearResult: true,
      ),
    );

    try {
      final result = await _authRepository.registerInitiate(
        email: email,
        phone: phone,
      );

      _appStateCubit.setRegistrationSession(
        email: email,
        phone: phone,
        sessionToken: result.sessionToken,
        step: result.step,
      );

      emit(
        state.copyWith(
          status: RegisterInitiateStatus.success,
          result: result,
          clearError: true,
        ),
      );
    } on AppError catch (error) {
      emit(
        state.copyWith(
          status: RegisterInitiateStatus.failure,
          errorMessage: error.message,
          clearResult: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: RegisterInitiateStatus.failure,
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
      state.copyWith(status: RegisterInitiateStatus.initial, clearError: true),
    );
  }
}
