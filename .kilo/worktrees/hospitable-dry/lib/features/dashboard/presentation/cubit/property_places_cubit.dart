import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixa/core/network/app_error.dart';
import 'package:fixa/features/dashboard/domain/entities/property_place.dart';
import 'package:fixa/features/dashboard/domain/repositories/property_feed_repository.dart';

part 'property_places_state.dart';

class PropertyPlacesCubit extends Cubit<PropertyPlacesState> {
  PropertyPlacesCubit({required PropertyFeedRepository propertyFeedRepository})
    : _propertyFeedRepository = propertyFeedRepository,
      super(const PropertyPlacesState());

  final PropertyFeedRepository _propertyFeedRepository;

  Future<void> searchPlaces(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      emit(const PropertyPlacesState());
      return;
    }

    emit(
      state.copyWith(status: PropertyPlacesStatus.loading, clearError: true),
    );

    try {
      final places = await _propertyFeedRepository.getPropertyPlaces(
        normalizedQuery,
      );
      emit(
        state.copyWith(
          status: PropertyPlacesStatus.success,
          places: places,
          clearError: true,
        ),
      );
    } on AppError catch (error) {
      emit(
        state.copyWith(
          status: PropertyPlacesStatus.failure,
          errorMessage: error.message,
          places: const <PropertyPlace>[],
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: PropertyPlacesStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
          places: const <PropertyPlace>[],
        ),
      );
    }
  }
}
