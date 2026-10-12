import 'package:fixa/features/subscription/domain/entities/subscription_entities.dart';

abstract class SubscriptionRepository {
  Future<SubscriptionConfig> getConfig();
  Future<SubscriptionInfo> getMySubscription();
  Future<PaymentInitiation> initiate();
  Future<String> cancel();
}
