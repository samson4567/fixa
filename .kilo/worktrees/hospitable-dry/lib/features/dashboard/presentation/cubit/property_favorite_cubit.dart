import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixa/core/network/app_error.dart';
import 'package:fixa/features/dashboard/domain/repositories/property_feed_repository.dart';
import 'package:fixa/features/dashboard/presentation/cubit/property_favorites_cubit.dart';

part 'property_favorite_state.dart';

class PropertyFavoriteCubit extends Cubit<PropertyFavoriteState> {
  PropertyFavoriteCubit({
    required PropertyFeedRepository propertyFeedRepository,
  }) : _propertyFeedRepository = propertyFeedRepository,
       super(const PropertyFavoriteState());

  final PropertyFeedRepository _propertyFeedRepository;

  Future<void> setFavorite({
    required String propertyId,
    required bool isFavorite,
  }) async {
    emit(
      state.copyWith(
        status: PropertyFavoriteStatus.loading,
        propertyId: propertyId,
        isFavorite: isFavorite,
        clearError: true,
        clearMessage: true,
      ),
    );

    try {
      final message = isFavorite
          ? await _propertyFeedRepository.addPropertyToFavorites(propertyId)
          : await _propertyFeedRepository.removePropertyFromFavorites(
              propertyId,
            );
      PropertyFavoritesCubit.invalidateCache();

      emit(
        state.copyWith(
          status: PropertyFavoriteStatus.success,
          propertyId: propertyId,
          isFavorite: isFavorite,
          message: message,
          clearError: true,
        ),
      );
    } on AppError catch (error) {
      emit(
        state.copyWith(
          status: PropertyFavoriteStatus.failure,
          propertyId: propertyId,
          isFavorite: isFavorite,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: PropertyFavoriteStatus.failure,
          propertyId: propertyId,
          isFavorite: isFavorite,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }
}
