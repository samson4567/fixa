import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixa/core/network/app_error.dart';
import 'package:fixa/features/dashboard/domain/entities/property_feed_result.dart';
import 'package:fixa/features/dashboard/domain/repositories/property_feed_repository.dart';

part 'property_feed_state.dart';

class PropertyFeedCubit extends Cubit<PropertyFeedState> {
  PropertyFeedCubit({required PropertyFeedRepository propertyFeedRepository})
    : _propertyFeedRepository = propertyFeedRepository,
      super(const PropertyFeedState());

  final PropertyFeedRepository _propertyFeedRepository;
  static final Map<String, PropertyFeedResult> _resultCache =
      <String, PropertyFeedResult>{};

  static void invalidateCache() {
    _resultCache.clear();
  }

  Future<void> fetchPropertyFeed({
    String? type,
    required int page,
    required int limit,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${type ?? 'all'}:$page:$limit';
    final cachedResult = _resultCache[cacheKey];
    if (!forceRefresh && cachedResult != null) {
      emit(
        state.copyWith(
          status: PropertyFeedStatus.success,
          result: cachedResult,
          clearError: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: PropertyFeedStatus.loading,
        clearError: true,
        clearResult: true,
      ),
    );

    try {
      final result = await _propertyFeedRepository.getPropertyFeed(
        type: type,
        page: page,
        limit: limit,
      );
      _resultCache[cacheKey] = result;

      emit(
        state.copyWith(
          status: PropertyFeedStatus.success,
          result: result,
          clearError: true,
        ),
      );
    } on AppError catch (error) {
      emit(
        state.copyWith(
          status: PropertyFeedStatus.failure,
          errorMessage: error.message,
          clearResult: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: PropertyFeedStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
          clearResult: true,
        ),
      );
    }
  }
}
