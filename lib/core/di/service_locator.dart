import 'package:get_it/get_it.dart';

import 'package:fixa/core/app_state/app_state_cubit.dart';
import 'package:fixa/core/network/api_client.dart';
import 'package:fixa/core/storage/app_preference_service.dart';
import 'package:fixa/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:fixa/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fixa/features/auth/domain/repositories/auth_repository.dart';
import 'package:fixa/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:fixa/features/auth/presentation/cubit/login_cubit.dart';
import 'package:fixa/features/auth/presentation/cubit/register_initiate_cubit.dart';
import 'package:fixa/features/auth/presentation/cubit/register_password_cubit.dart';
import 'package:fixa/features/auth/presentation/cubit/register_profile_cubit.dart';
import 'package:fixa/features/auth/presentation/cubit/register_verify_cubit.dart';
import 'package:fixa/features/auth/presentation/cubit/reset_password_cubit.dart';
import 'package:fixa/features/auth/presentation/cubit/user_profile_cubit.dart';
import 'package:fixa/features/dashboard/data/datasources/property_feed_remote_data_source.dart';
import 'package:fixa/features/dashboard/data/datasources/notification_remote_data_source.dart';
import 'package:fixa/features/dashboard/data/repositories/notification_repository_impl.dart';
import 'package:fixa/features/dashboard/data/repositories/property_feed_repository_impl.dart';
import 'package:fixa/features/dashboard/domain/repositories/property_feed_repository.dart';
import 'package:fixa/features/dashboard/domain/repositories/notification_repository.dart';
import 'package:fixa/features/dashboard/presentation/cubit/notification_cubit.dart';
import 'package:fixa/features/dashboard/presentation/cubit/property_detail_cubit.dart';
import 'package:fixa/features/dashboard/presentation/cubit/property_favorite_cubit.dart';
import 'package:fixa/features/dashboard/presentation/cubit/property_favorites_cubit.dart';
import 'package:fixa/features/dashboard/presentation/cubit/property_feed_cubit.dart';
import 'package:fixa/features/dashboard/presentation/cubit/property_map_pins_cubit.dart';
import 'package:fixa/features/dashboard/presentation/cubit/property_places_cubit.dart';
import 'package:fixa/features/subscription/data/datasources/subscription_remote_data_source.dart';
import 'package:fixa/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:fixa/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:fixa/features/subscription/presentation/cubit/subscription_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  if (!getIt.isRegistered<AppPreferenceService>()) {
    final appPreferenceService = AppPreferenceService();
    await appPreferenceService.init();
    getIt.registerLazySingleton<AppPreferenceService>(
      () => appPreferenceService,
    );
  }

  if (!getIt.isRegistered<ApiClient>()) {
    getIt.registerLazySingleton<ApiClient>(
      () => ApiClient(appPreferenceService: getIt<AppPreferenceService>()),
    );
  }

  if (!getIt.isRegistered<AuthRemoteDataSource>()) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
    );
  }

  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: getIt<AuthRemoteDataSource>()),
    );
  }

  if (!getIt.isRegistered<PropertyFeedRemoteDataSource>()) {
    getIt.registerLazySingleton<PropertyFeedRemoteDataSource>(
      () => PropertyFeedRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
    );
  }

  if (!getIt.isRegistered<SubscriptionRemoteDataSource>()) {
    getIt.registerLazySingleton<SubscriptionRemoteDataSource>(
      () => SubscriptionRemoteDataSource(apiClient: getIt<ApiClient>()),
    );
  }

  if (!getIt.isRegistered<SubscriptionRepository>()) {
    getIt.registerLazySingleton<SubscriptionRepository>(
      () => SubscriptionRepositoryImpl(
        remoteDataSource: getIt<SubscriptionRemoteDataSource>(),
      ),
    );
  }

  if (!getIt.isRegistered<NotificationRemoteDataSource>()) {
    getIt.registerLazySingleton<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
    );
  }

  if (!getIt.isRegistered<NotificationRepository>()) {
    getIt.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(
        remoteDataSource: getIt<NotificationRemoteDataSource>(),
      ),
    );
  }

  if (!getIt.isRegistered<PropertyFeedRepository>()) {
    getIt.registerLazySingleton<PropertyFeedRepository>(
      () => PropertyFeedRepositoryImpl(
        remoteDataSource: getIt<PropertyFeedRemoteDataSource>(),
      ),
    );
  }

  if (!getIt.isRegistered<AppStateCubit>()) {
    getIt.registerLazySingleton<AppStateCubit>(AppStateCubit.new);
  }

  if (!getIt.isRegistered<LoginCubit>()) {
    getIt.registerFactory<LoginCubit>(
      () => LoginCubit(
        authRepository: getIt<AuthRepository>(),
        appPreferenceService: getIt<AppPreferenceService>(),
      ),
    );
  }

  if (!getIt.isRegistered<ForgotPasswordCubit>()) {
    getIt.registerFactory<ForgotPasswordCubit>(
      () => ForgotPasswordCubit(authRepository: getIt<AuthRepository>()),
    );
  }

  if (!getIt.isRegistered<RegisterInitiateCubit>()) {
    getIt.registerFactory<RegisterInitiateCubit>(
      () => RegisterInitiateCubit(
        authRepository: getIt<AuthRepository>(),
        appStateCubit: getIt<AppStateCubit>(),
      ),
    );
  }

  if (!getIt.isRegistered<ResetPasswordCubit>()) {
    getIt.registerFactory<ResetPasswordCubit>(
      () => ResetPasswordCubit(authRepository: getIt<AuthRepository>()),
    );
  }

  if (!getIt.isRegistered<RegisterVerifyCubit>()) {
    getIt.registerFactory<RegisterVerifyCubit>(
      () => RegisterVerifyCubit(
        authRepository: getIt<AuthRepository>(),
        appStateCubit: getIt<AppStateCubit>(),
      ),
    );
  }

  if (!getIt.isRegistered<RegisterPasswordCubit>()) {
    getIt.registerFactory<RegisterPasswordCubit>(
      () => RegisterPasswordCubit(
        authRepository: getIt<AuthRepository>(),
        appStateCubit: getIt<AppStateCubit>(),
      ),
    );
  }

  if (!getIt.isRegistered<RegisterProfileCubit>()) {
    getIt.registerFactory<RegisterProfileCubit>(
      () => RegisterProfileCubit(
        authRepository: getIt<AuthRepository>(),
        appStateCubit: getIt<AppStateCubit>(),
      ),
    );
  }

  if (!getIt.isRegistered<UserProfileCubit>()) {
    getIt.registerFactory<UserProfileCubit>(
      () => UserProfileCubit(authRepository: getIt<AuthRepository>()),
    );
  }

  if (!getIt.isRegistered<PropertyFeedCubit>()) {
    getIt.registerFactory<PropertyFeedCubit>(
      () => PropertyFeedCubit(
        propertyFeedRepository: getIt<PropertyFeedRepository>(),
      ),
    );
  }

  if (!getIt.isRegistered<NotificationCubit>()) {
    getIt.registerFactory<NotificationCubit>(
      () => NotificationCubit(
        notificationRepository: getIt<NotificationRepository>(),
      ),
    );
  }

  if (!getIt.isRegistered<PropertyDetailCubit>()) {
    getIt.registerFactory<PropertyDetailCubit>(
      () => PropertyDetailCubit(
        propertyFeedRepository: getIt<PropertyFeedRepository>(),
      ),
    );
  }

  if (!getIt.isRegistered<PropertyMapPinsCubit>()) {
    getIt.registerFactory<PropertyMapPinsCubit>(
      () => PropertyMapPinsCubit(
        propertyFeedRepository: getIt<PropertyFeedRepository>(),
      ),
    );
  }

  if (!getIt.isRegistered<PropertyPlacesCubit>()) {
    getIt.registerFactory<PropertyPlacesCubit>(
      () => PropertyPlacesCubit(
        propertyFeedRepository: getIt<PropertyFeedRepository>(),
      ),
    );
  }

  if (!getIt.isRegistered<PropertyFavoriteCubit>()) {
    getIt.registerFactory<PropertyFavoriteCubit>(
      () => PropertyFavoriteCubit(
        propertyFeedRepository: getIt<PropertyFeedRepository>(),
      ),
    );
  }

  if (!getIt.isRegistered<PropertyFavoritesCubit>()) {
    getIt.registerFactory<PropertyFavoritesCubit>(
      () => PropertyFavoritesCubit(
        propertyFeedRepository: getIt<PropertyFeedRepository>(),
      ),
    );
  }

  if (!getIt.isRegistered<SubscriptionCubit>()) {
    getIt.registerFactory<SubscriptionCubit>(
      () => SubscriptionCubit(repository: getIt<SubscriptionRepository>()),
    );
  }
}
