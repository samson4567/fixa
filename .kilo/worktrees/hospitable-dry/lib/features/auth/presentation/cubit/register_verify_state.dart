part of 'register_verify_cubit.dart';

enum RegisterVerifyStatus { initial, loading, success, failure }

class RegisterVerifyState extends Equatable {
  const RegisterVerifyState({
    this.status = RegisterVerifyStatus.initial,
    this.errorMessage,
    this.result,
  });

  final RegisterVerifyStatus status;
  final String? errorMessage;
  final RegisterVerifyResult? result;

  bool get isLoading => status == RegisterVerifyStatus.loading;

  RegisterVerifyState copyWith({
    RegisterVerifyStatus? status,
    String? errorMessage,
    RegisterVerifyResult? result,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return RegisterVerifyState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      result: clearResult ? null : (result ?? this.result),
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, result];
}
