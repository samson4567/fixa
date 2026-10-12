part of 'register_initiate_cubit.dart';

enum RegisterInitiateStatus { initial, loading, success, failure }

class RegisterInitiateState extends Equatable {
  const RegisterInitiateState({
    this.status = RegisterInitiateStatus.initial,
    this.errorMessage,
    this.result,
  });

  final RegisterInitiateStatus status;
  final String? errorMessage;
  final RegisterInitiateResult? result;

  bool get isLoading => status == RegisterInitiateStatus.loading;

  RegisterInitiateState copyWith({
    RegisterInitiateStatus? status,
    String? errorMessage,
    RegisterInitiateResult? result,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return RegisterInitiateState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      result: clearResult ? null : (result ?? this.result),
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, result];
}
