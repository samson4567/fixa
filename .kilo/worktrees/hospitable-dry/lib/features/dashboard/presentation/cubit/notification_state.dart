part of 'notification_cubit.dart';

enum NotificationStatus { initial, loading, success, failure }

class NotificationState extends Equatable {
  const NotificationState({
    this.status = NotificationStatus.initial,
    this.result,
    this.errorMessage,
  });

  final NotificationStatus status;
  final NotificationResult? result;
  final String? errorMessage;

  NotificationState copyWith({
    NotificationStatus? status,
    NotificationResult? result,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, result, errorMessage];
}
