part of 'property_detail_cubit.dart';

enum PropertyDetailStatus { initial, loading, success, failure }

class PropertyDetailState extends Equatable {
  const PropertyDetailState({
    this.status = PropertyDetailStatus.initial,
    this.errorMessage,
    this.property,
  });

  final PropertyDetailStatus status;
  final String? errorMessage;
  final PropertyFeedProperty? property;

  bool get isLoading => status == PropertyDetailStatus.loading;

  PropertyDetailState copyWith({
    PropertyDetailStatus? status,
    String? errorMessage,
    PropertyFeedProperty? property,
    bool clearError = false,
  }) {
    return PropertyDetailState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      property: property ?? this.property,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, property];
}
