part of 'property_feed_cubit.dart';

enum PropertyFeedStatus { initial, loading, success, failure }

class PropertyFeedState extends Equatable {
  const PropertyFeedState({
    this.status = PropertyFeedStatus.initial,
    this.errorMessage,
    this.result,
  });

  final PropertyFeedStatus status;
  final String? errorMessage;
  final PropertyFeedResult? result;

  bool get isLoading => status == PropertyFeedStatus.loading;

  PropertyFeedState copyWith({
    PropertyFeedStatus? status,
    String? errorMessage,
    PropertyFeedResult? result,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return PropertyFeedState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      result: clearResult ? null : (result ?? this.result),
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, result];
}
