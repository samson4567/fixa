import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixa/core/network/app_error.dart';
import 'package:fixa/features/dashboard/domain/entities/property_feed_result.dart';
import 'package:fixa/features/dashboard/domain/repositories/property_feed_repository.dart';

part 'property_favorites_state.dart';

class PropertyFavoritesCubit extends Cubit<PropertyFavoritesState> {
  PropertyFavoritesCubit({
    required PropertyFeedRepository propertyFeedRepository,
  }) : _propertyFeedRepository = propertyFeedRepository,
       super(const PropertyFavoritesState());

  final PropertyFeedRepository _propertyFeedRepository;
  static List<PropertyFeedProperty>? _propertiesCache;

  static void invalidateCache() {
    _propertiesCache = null;
  }

  Future<void> fetchFavorites({bool forceRefresh = false}) async {
    final cachedProperties = _propertiesCache;
    if (!forceRefresh && cachedProperties != null) {
      emit(
        state.copyWith(
          status: PropertyFavoritesStatus.success,
          properties: cachedProperties,
          clearError: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(status: PropertyFavoritesStatus.loading, clearError: true),
    );

    try {
      final properties = await _propertyFeedRepository.getFavoriteProperties();
      _propertiesCache = List<PropertyFeedProperty>.unmodifiable(properties);
      emit(
        state.copyWith(
          status: PropertyFavoritesStatus.success,
          properties: _propertiesCache,
          clearError: true,
        ),
      );
    } on AppError catch (error) {
      emit(
        state.copyWith(
          status: PropertyFavoritesStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: PropertyFavoritesStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }
}
