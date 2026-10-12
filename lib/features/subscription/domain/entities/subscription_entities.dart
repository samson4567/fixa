import 'package:equatable/equatable.dart';

class SubscriptionConfig extends Equatable {
  const SubscriptionConfig({
    required this.plan,
    required this.name,
    required this.amount,
    required this.billingCycle,
    required this.currency,
    required this.features,
  });

  final String plan;
  final String name;
  final int amount;
  final String billingCycle;
  final String currency;
  final List<String> features;

  @override
  List<Object?> get props => [
    plan,
    name,
    amount,
    billingCycle,
    currency,
    features,
  ];
}

class SubscriptionInfo extends Equatable {
  const SubscriptionInfo({
    required this.id,
    required this.plan,
    required this.status,
    required this.amount,
    required this.billingCycle,
  });

  final String id;
  final String plan;
  final String status;
  final int amount;
  final String billingCycle;

  bool get isActive => status.toLowerCase() == 'active';

  @override
  List<Object?> get props => [id, plan, status, amount, billingCycle];
}

class PaymentInitiation extends Equatable {
  const PaymentInitiation({
    required this.authorizationUrl,
    required this.accessCode,
    required this.reference,
  });

  final String authorizationUrl;
  final String accessCode;
  final String reference;

  @override
  List<Object?> get props => [authorizationUrl, accessCode, reference];
}
