import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixa/core/network/app_error.dart';
import 'package:fixa/features/dashboard/domain/entities/property_feed_result.dart';
import 'package:fixa/features/dashboard/domain/repositories/property_feed_repository.dart';

part 'property_detail_state.dart';

class PropertyDetailCubit extends Cubit<PropertyDetailState> {
  PropertyDetailCubit({required PropertyFeedRepository propertyFeedRepository})
    : _propertyFeedRepository = propertyFeedRepository,
      super(const PropertyDetailState());

  final PropertyFeedRepository _propertyFeedRepository;

  Future<void> fetchPropertyById(String id) async {
    emit(
      state.copyWith(status: PropertyDetailStatus.loading, clearError: true),
    );

    try {
      final property = await _propertyFeedRepository.getPropertyById(id);
      emit(
        state.copyWith(
          status: PropertyDetailStatus.success,
          property: property,
          clearError: true,
        ),
      );
    } on AppError catch (error) {
      emit(
        state.copyWith(
          status: PropertyDetailStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: PropertyDetailStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }
}
