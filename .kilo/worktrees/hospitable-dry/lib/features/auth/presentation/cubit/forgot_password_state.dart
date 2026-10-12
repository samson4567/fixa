part of 'forgot_password_cubit.dart';

enum ForgotPasswordStatus { initial, loading, success, failure }

class ForgotPasswordState extends Equatable {
  const ForgotPasswordState({
    this.status = ForgotPasswordStatus.initial,
    this.errorMessage,
    this.result,
  });

  final ForgotPasswordStatus status;
  final String? errorMessage;
  final ForgotPasswordResult? result;

  bool get isLoading => status == ForgotPasswordStatus.loading;

  ForgotPasswordState copyWith({
    ForgotPasswordStatus? status,
    String? errorMessage,
    ForgotPasswordResult? result,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      result: clearResult ? null : (result ?? this.result),
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, result];
}
