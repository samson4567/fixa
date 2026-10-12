part of 'subscription_cubit.dart';

enum SubscriptionStatus {
  initial,
  loading,
  ready,
  initiating,
  paymentReady,
  cancelling,
  cancelled,
  failure,
}

class SubscriptionState extends Equatable {
  const SubscriptionState({
    this.status = SubscriptionStatus.initial,
    this.config,
    this.subscription,
    this.payment,
    this.message,
    this.errorMessage,
  });

  final SubscriptionStatus status;
  final SubscriptionConfig? config;
  final SubscriptionInfo? subscription;
  final PaymentInitiation? payment;
  final String? message;
  final String? errorMessage;

  bool get isBusy =>
      status == SubscriptionStatus.loading ||
      status == SubscriptionStatus.initiating ||
      status == SubscriptionStatus.cancelling;

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    SubscriptionConfig? config,
    SubscriptionInfo? subscription,
    PaymentInitiation? payment,
    String? message,
    String? errorMessage,
    bool clearSubscription = false,
    bool clearError = false,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      config: config ?? this.config,
      subscription: clearSubscription
          ? null
          : (subscription ?? this.subscription),
      payment: payment ?? this.payment,
      message: message ?? this.message,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    config,
    subscription,
    payment,
    message,
    errorMessage,
  ];
}
