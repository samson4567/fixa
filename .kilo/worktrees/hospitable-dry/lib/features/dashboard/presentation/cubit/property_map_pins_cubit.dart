import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixa/core/network/app_error.dart';
import 'package:fixa/features/dashboard/domain/entities/property_map_pins_result.dart';
import 'package:fixa/features/dashboard/domain/repositories/property_feed_repository.dart';

part 'property_map_pins_state.dart';

class PropertyMapPinsCubit extends Cubit<PropertyMapPinsState> {
  PropertyMapPinsCubit({required PropertyFeedRepository propertyFeedRepository})
    : _propertyFeedRepository = propertyFeedRepository,
      super(const PropertyMapPinsState());

  final PropertyFeedRepository _propertyFeedRepository;

  Future<void> fetchMapPins({
    required String type,
    required int page,
    required int limit,
  }) async {
    emit(
      state.copyWith(status: PropertyMapPinsStatus.loading, clearError: true),
    );

    try {
      final result = await _propertyFeedRepository.getPropertyMapPins(
        type: type,
        page: page,
        limit: limit,
      );

      emit(
        state.copyWith(
          status: PropertyMapPinsStatus.success,
          result: result,
          clearError: true,
        ),
      );
    } on AppError catch (error) {
      emit(
        state.copyWith(
          status: PropertyMapPinsStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: PropertyMapPinsStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }
}
