part of 'register_password_cubit.dart';

enum RegisterPasswordStatus { initial, loading, success, failure }

class RegisterPasswordState extends Equatable {
  const RegisterPasswordState({
    this.status = RegisterPasswordStatus.initial,
    this.errorMessage,
    this.result,
  });

  final RegisterPasswordStatus status;
  final String? errorMessage;
  final RegisterPasswordResult? result;

  bool get isLoading => status == RegisterPasswordStatus.loading;

  RegisterPasswordState copyWith({
    RegisterPasswordStatus? status,
    String? errorMessage,
    RegisterPasswordResult? result,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return RegisterPasswordState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      result: clearResult ? null : (result ?? this.result),
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, result];
}
