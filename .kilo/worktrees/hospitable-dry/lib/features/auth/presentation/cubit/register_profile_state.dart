part of 'register_profile_cubit.dart';

enum RegisterProfileStatus { initial, loading, success, failure }

class RegisterProfileState extends Equatable {
  const RegisterProfileState({
    this.status = RegisterProfileStatus.initial,
    this.errorMessage,
    this.result,
  });

  final RegisterProfileStatus status;
  final String? errorMessage;
  final RegisterProfileResult? result;

  bool get isLoading => status == RegisterProfileStatus.loading;

  RegisterProfileState copyWith({
    RegisterProfileStatus? status,
    String? errorMessage,
    RegisterProfileResult? result,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return RegisterProfileState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      result: clearResult ? null : (result ?? this.result),
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, result];
}
