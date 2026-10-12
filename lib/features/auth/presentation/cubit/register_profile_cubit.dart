import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixa/core/app_state/app_state_cubit.dart';
import 'package:fixa/core/network/app_error.dart';
import 'package:fixa/features/auth/domain/entities/register_profile_result.dart';
import 'package:fixa/features/auth/domain/repositories/auth_repository.dart';
import 'package:image_picker/image_picker.dart';

part 'register_profile_state.dart';

class RegisterProfileCubit extends Cubit<RegisterProfileState> {
  RegisterProfileCubit({
    required AuthRepository authRepository,
    required AppStateCubit appStateCubit,
  }) : _authRepository = authRepository,
       _appStateCubit = appStateCubit,
       super(const RegisterProfileState());

  final AuthRepository _authRepository;
  final AppStateCubit _appStateCubit;

  Future<void> registerProfile({
    required String sessionToken,
    required String firstName,
    required String lastName,
    required String birthday,
    required String address,
    XFile? profilePicture,
  }) async {
    emit(
      state.copyWith(
        status: RegisterProfileStatus.loading,
        clearError: true,
        clearResult: true,
      ),
    );

    try {
      final result = await _authRepository.registerProfile(
        sessionToken: sessionToken,
        firstName: firstName,
        lastName: lastName,
        birthday: birthday,
        address: address,
        profilePicture: profilePicture,
      );

      _appStateCubit.clearRegistrationSession();

      emit(
        state.copyWith(
          status: RegisterProfileStatus.success,
          result: result,
          clearError: true,
        ),
      );
    } on AppError catch (error) {
      emit(
        state.copyWith(
          status: RegisterProfileStatus.failure,
          errorMessage: error.message,
          clearResult: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: RegisterProfileStatus.failure,
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
      state.copyWith(status: RegisterProfileStatus.initial, clearError: true),
    );
  }
}
