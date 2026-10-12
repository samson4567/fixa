part of 'user_profile_cubit.dart';

enum UserProfileStatus {
  initial,
  loading,
  success,
  updating,
  updateSuccess,
  failure,
}

class UserProfileState extends Equatable {
  const UserProfileState({
    this.status = UserProfileStatus.initial,
    this.profile,
    this.errorMessage,
    this.message,
  });

  final UserProfileStatus status;
  final UserProfileResult? profile;
  final String? errorMessage;
  final String? message;

  bool get isLoading =>
      status == UserProfileStatus.loading ||
      status == UserProfileStatus.updating;

  UserProfileState copyWith({
    UserProfileStatus? status,
    UserProfileResult? profile,
    String? errorMessage,
    String? message,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return UserProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage, message];
}
