import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fixa/core/network/app_error.dart';
import 'package:fixa/features/auth/domain/entities/user_profile_result.dart';
import 'package:fixa/features/auth/domain/repositories/auth_repository.dart';

part 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  UserProfileCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const UserProfileState());

  final AuthRepository _authRepository;
  static UserProfileResult? _profileCache;

  static void invalidateCache() {
    _profileCache = null;
  }

  Future<void> fetchUserProfile({bool forceRefresh = false}) async {
    final cachedProfile = _profileCache;
    if (!forceRefresh && cachedProfile != null) {
      emit(
        state.copyWith(
          status: UserProfileStatus.success,
          profile: cachedProfile,
          clearError: true,
          clearMessage: true,
        ),
      );
      return;
    }

    emit(state.copyWith(status: UserProfileStatus.loading, clearError: true));

    try {
      final profile = await _authRepository.getUserProfile();
      _profileCache = profile;
      emit(
        state.copyWith(
          status: UserProfileStatus.success,
          profile: profile,
          clearError: true,
          clearMessage: true,
        ),
      );
    } on AppError catch (error) {
      emit(
        state.copyWith(
          status: UserProfileStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: UserProfileStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String birthday,
    required String address,
    XFile? profilePicture,
  }) async {
    emit(
      state.copyWith(
        status: UserProfileStatus.updating,
        clearError: true,
        clearMessage: true,
      ),
    );

    try {
      final profile = await _authRepository.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        birthday: birthday,
        address: address,
        profilePicture: profilePicture,
      );
      _profileCache = profile;
      emit(
        state.copyWith(
          status: UserProfileStatus.updateSuccess,
          profile: profile,
          message: 'Profile updated successfully.',
          clearError: true,
        ),
      );
    } on AppError catch (error) {
      emit(
        state.copyWith(
          status: UserProfileStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: UserProfileStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }
}
