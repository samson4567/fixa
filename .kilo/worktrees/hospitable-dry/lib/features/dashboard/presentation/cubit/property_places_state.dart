part of 'property_places_cubit.dart';

enum PropertyPlacesStatus { initial, loading, success, failure }

class PropertyPlacesState extends Equatable {
  const PropertyPlacesState({
    this.status = PropertyPlacesStatus.initial,
    this.errorMessage,
    this.places = const <PropertyPlace>[],
  });

  final PropertyPlacesStatus status;
  final String? errorMessage;
  final List<PropertyPlace> places;

  PropertyPlacesState copyWith({
    PropertyPlacesStatus? status,
    String? errorMessage,
    List<PropertyPlace>? places,
    bool clearError = false,
  }) {
    return PropertyPlacesState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      places: places ?? this.places,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, places];
}
