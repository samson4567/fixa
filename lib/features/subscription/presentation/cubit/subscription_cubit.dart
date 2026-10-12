import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixa/core/network/app_error.dart';
import 'package:fixa/features/subscription/domain/entities/subscription_entities.dart';
import 'package:fixa/features/subscription/domain/repositories/subscription_repository.dart';

part 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit({required SubscriptionRepository repository})
    : _repository = repository,
      super(const SubscriptionState());

  final SubscriptionRepository _repository;
  static SubscriptionConfig? _configCache;
  static SubscriptionInfo? _subscriptionCache;

  static void invalidateCache() {
    _configCache = null;
    _subscriptionCache = null;
  }

  Future<void> load({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _configCache != null &&
        _subscriptionCache?.isActive == true) {
      emit(
        state.copyWith(
          status: SubscriptionStatus.ready,
          config: _configCache,
          subscription: _subscriptionCache,
          clearError: true,
        ),
      );
      return;
    }

    emit(state.copyWith(status: SubscriptionStatus.loading, clearError: true));
    try {
      final config = await _repository.getConfig();
      SubscriptionInfo? subscription;
      try {
        subscription = await _repository.getMySubscription();
      } on AppError {
        subscription = null;
      }
      _configCache = config;
      _subscriptionCache = subscription;
      emit(
        state.copyWith(
          status: SubscriptionStatus.ready,
          config: config,
          subscription: subscription,
          clearSubscription: subscription == null,
          clearError: true,
        ),
      );
    } on AppError catch (error) {
      emit(
        state.copyWith(
          status: SubscriptionStatus.failure,
          errorMessage: error.message,
        ),
      );
    }
  }

  Future<void> initiate() async {
    final plan = state.config?.plan.trim();
    if (plan == null || plan.isEmpty) return;
    emit(
      state.copyWith(status: SubscriptionStatus.initiating, clearError: true),
    );
    try {
      final payment = await _repository.initiate();
      emit(
        state.copyWith(
          status: SubscriptionStatus.paymentReady,
          payment: payment,
          clearError: true,
        ),
      );
    } on AppError catch (error) {
      emit(
        state.copyWith(
          status: SubscriptionStatus.failure,
          errorMessage: error.message,
        ),
      );
    }
  }

  Future<void> refreshSubscription() => load(forceRefresh: true);

  Future<void> confirmSubscription() async {
    emit(state.copyWith(status: SubscriptionStatus.loading, clearError: true));
    try {
      SubscriptionInfo? latest;
      for (var attempt = 0; attempt < 6; attempt++) {
        latest = await _repository.getMySubscription();
        _subscriptionCache = latest;
        if (latest.isActive) break;
        if (attempt < 5) {
          await Future<void>.delayed(const Duration(seconds: 2));
        }
      }
      emit(
        state.copyWith(
          status: SubscriptionStatus.ready,
          subscription: latest,
          clearError: true,
        ),
      );
    } on AppError catch (error) {
      emit(
        state.copyWith(
          status: SubscriptionStatus.failure,
          errorMessage: error.message,
        ),
      );
    }
  }

  Future<void> cancel() async {
    emit(
      state.copyWith(status: SubscriptionStatus.cancelling, clearError: true),
    );
    try {
      final message = await _repository.cancel();
      _subscriptionCache = null;
      emit(
        state.copyWith(
          status: SubscriptionStatus.cancelled,
          message: message,
          clearSubscription: true,
          clearError: true,
        ),
      );
    } on AppError catch (error) {
      emit(
        state.copyWith(
          status: SubscriptionStatus.failure,
          errorMessage: error.message,
        ),
      );
    }
  }
}
