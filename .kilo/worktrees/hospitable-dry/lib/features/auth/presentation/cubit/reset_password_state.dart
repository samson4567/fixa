part of 'reset_password_cubit.dart';

enum ResetPasswordStatus { initial, loading, success, failure }

class ResetPasswordState extends Equatable {
  const ResetPasswordState({
    this.status = ResetPasswordStatus.initial,
    this.errorMessage,
    this.result,
  });

  final ResetPasswordStatus status;
  final String? errorMessage;
  final ResetPasswordResult? result;

  bool get isLoading => status == ResetPasswordStatus.loading;

  ResetPasswordState copyWith({
    ResetPasswordStatus? status,
    String? errorMessage,
    ResetPasswordResult? result,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return ResetPasswordState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      result: clearResult ? null : (result ?? this.result),
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, result];
}
