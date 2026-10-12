part of 'property_favorite_cubit.dart';

enum PropertyFavoriteStatus { initial, loading, success, failure }

class PropertyFavoriteState extends Equatable {
  const PropertyFavoriteState({
    this.status = PropertyFavoriteStatus.initial,
    this.errorMessage,
    this.message,
    this.propertyId,
    this.isFavorite,
  });

  final PropertyFavoriteStatus status;
  final String? errorMessage;
  final String? message;
  final String? propertyId;
  final bool? isFavorite;

  PropertyFavoriteState copyWith({
    PropertyFavoriteStatus? status,
    String? errorMessage,
    String? message,
    String? propertyId,
    bool? isFavorite,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return PropertyFavoriteState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      message: clearMessage ? null : (message ?? this.message),
      propertyId: propertyId ?? this.propertyId,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    message,
    propertyId,
    isFavorite,
  ];
}
