import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixa/core/network/app_error.dart';
import 'package:fixa/features/dashboard/domain/entities/notification_result.dart';
import 'package:fixa/features/dashboard/domain/repositories/notification_repository.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({required NotificationRepository notificationRepository})
    : _notificationRepository = notificationRepository,
      super(const NotificationState());

  final NotificationRepository _notificationRepository;
  static NotificationResult? _resultCache;

  static void invalidateCache() {
    _resultCache = null;
  }

  Future<void> fetchNotifications({bool forceRefresh = false}) async {
    final cachedResult = _resultCache;
    if (!forceRefresh && cachedResult != null) {
      emit(
        state.copyWith(
          status: NotificationStatus.success,
          result: cachedResult,
          clearError: true,
        ),
      );
      return;
    }

    emit(state.copyWith(status: NotificationStatus.loading, clearError: true));
    try {
      final result = await _notificationRepository.getNotifications();
      _resultCache = result;
      emit(
        state.copyWith(
          status: NotificationStatus.success,
          result: result,
          clearError: true,
        ),
      );
    } on AppError catch (error) {
      emit(
        state.copyWith(
          status: NotificationStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: NotificationStatus.failure,
          errorMessage: 'Unable to load notifications.',
        ),
      );
    }
  }
}
