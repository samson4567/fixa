part of 'property_map_pins_cubit.dart';

enum PropertyMapPinsStatus { initial, loading, success, failure }

class PropertyMapPinsState extends Equatable {
  const PropertyMapPinsState({
    this.status = PropertyMapPinsStatus.initial,
    this.errorMessage,
    this.result,
  });

  final PropertyMapPinsStatus status;
  final String? errorMessage;
  final PropertyMapPinsResult? result;

  bool get isLoading => status == PropertyMapPinsStatus.loading;

  PropertyMapPinsState copyWith({
    PropertyMapPinsStatus? status,
    String? errorMessage,
    PropertyMapPinsResult? result,
    bool clearError = false,
  }) {
    return PropertyMapPinsState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, result];
}
