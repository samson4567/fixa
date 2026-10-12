import 'package:fixa/core/constants/endpoint_constant.dart';
import 'package:fixa/core/network/api_client.dart';
import 'package:fixa/core/network/app_error.dart';
import 'package:fixa/features/subscription/data/models/subscription_models.dart';

class SubscriptionRemoteDataSource {
  const SubscriptionRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;
  static const paymentRedirectUrl = 'fixa://payment/subscription/callback';

  Future<SubscriptionConfigModel> getConfig() async {
    final json = await _apiClient.get(EndpointConstant.subscriptionConfig);
    _validate(json, 'Unable to load subscription configuration.');
    return SubscriptionConfigModel.fromJson(json);
  }

  Future<SubscriptionInfoModel> getMySubscription() async {
    final json = await _apiClient.get(EndpointConstant.mySubscription);
    _validate(json, 'Unable to load subscription.');
    return SubscriptionInfoModel.fromJson(json);
  }

  Future<PaymentInitiationModel> initiate() async {
    final json = await _apiClient.post(
      EndpointConstant.subscriptionInitiate,
      data: const {'redirectUrl': paymentRedirectUrl},
    );
    _validate(json, 'Unable to initiate payment.');
    return PaymentInitiationModel.fromJson(json);
  }

  Future<String> cancel() async {
    final json = await _apiClient.delete(EndpointConstant.mySubscription);
    _validate(json, 'Unable to cancel subscription.');
    return json['message'] as String? ?? 'Subscription cancelled.';
  }

  void _validate(Map<String, dynamic> json, String fallback) {
    if (json['success'] == false) {
      final message = json['message'] as String?;
      throw AppError(
        message != null && message.trim().isNotEmpty ? message : fallback,
      );
    }
  }
}
