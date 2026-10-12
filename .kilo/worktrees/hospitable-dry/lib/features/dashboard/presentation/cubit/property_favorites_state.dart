part of 'property_favorites_cubit.dart';

enum PropertyFavoritesStatus { initial, loading, success, failure }

class PropertyFavoritesState extends Equatable {
  const PropertyFavoritesState({
    this.status = PropertyFavoritesStatus.initial,
    this.errorMessage,
    this.properties = const <PropertyFeedProperty>[],
  });

  final PropertyFavoritesStatus status;
  final String? errorMessage;
  final List<PropertyFeedProperty> properties;

  bool get isLoading => status == PropertyFavoritesStatus.loading;

  PropertyFavoritesState copyWith({
    PropertyFavoritesStatus? status,
    String? errorMessage,
    List<PropertyFeedProperty>? properties,
    bool clearError = false,
  }) {
    return PropertyFavoritesState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      properties: properties ?? this.properties,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, properties];
}
