import 'package:fixa/features/subscription/data/datasources/subscription_remote_data_source.dart';
import 'package:fixa/features/subscription/domain/entities/subscription_entities.dart';
import 'package:fixa/features/subscription/domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  const SubscriptionRepositoryImpl({
    required SubscriptionRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final SubscriptionRemoteDataSource _remoteDataSource;

  @override
  Future<String> cancel() => _remoteDataSource.cancel();

  @override
  Future<SubscriptionConfig> getConfig() async =>
      (await _remoteDataSource.getConfig()).data;

  @override
  Future<SubscriptionInfo> getMySubscription() async =>
      (await _remoteDataSource.getMySubscription()).data;

  @override
  Future<PaymentInitiation> initiate() async =>
      (await _remoteDataSource.initiate()).data;
}
