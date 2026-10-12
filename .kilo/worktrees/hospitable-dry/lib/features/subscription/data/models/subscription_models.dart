import 'package:fixa/features/subscription/domain/entities/subscription_entities.dart';

class SubscriptionConfigModel {
  const SubscriptionConfigModel({required this.message, required this.data});
  final String message;
  final SubscriptionConfig data;

  factory SubscriptionConfigModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    return SubscriptionConfigModel(
      message: json['message'] as String? ?? '',
      data: SubscriptionConfig(
        plan: data['plan'] as String? ?? '',
        name: data['name'] as String? ?? '',
        amount: (data['amount'] as num?)?.toInt() ?? 0,
        billingCycle: data['billingCycle'] as String? ?? '',
        currency: data['currency'] as String? ?? '',
        features: (data['features'] as List<dynamic>? ?? const [])
            .whereType<String>()
            .toList(growable: false),
      ),
    );
  }
}

class SubscriptionInfoModel {
  const SubscriptionInfoModel({required this.message, required this.data});
  final String message;
  final SubscriptionInfo data;

  factory SubscriptionInfoModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    return SubscriptionInfoModel(
      message: json['message'] as String? ?? '',
      data: SubscriptionInfo(
        id: data['id'] as String? ?? '',
        plan: data['plan'] as String? ?? '',
        status: data['status'] as String? ?? '',
        amount: (data['amount'] as num?)?.toInt() ?? 0,
        billingCycle: data['billingCycle'] as String? ?? '',
      ),
    );
  }
}

class PaymentInitiationModel {
  const PaymentInitiationModel({required this.message, required this.data});
  final String message;
  final PaymentInitiation data;

  factory PaymentInitiationModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    return PaymentInitiationModel(
      message: json['message'] as String? ?? '',
      data: PaymentInitiation(
        authorizationUrl: data['authorizationUrl'] as String? ?? '',
        accessCode: data['accessCode'] as String? ?? '',
        reference: data['reference'] as String? ?? '',
      ),
    );
  }
}
