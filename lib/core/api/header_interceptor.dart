import 'package:dio/dio.dart';
import 'package:fixa/core/api/device_storage_keys.dart';
import 'package:fixa/core/storage/app_preference_service.dart';

const String _authTokenStorageKey = 'auth_token';

class HeaderInterceptor extends Interceptor {
  HeaderInterceptor({required this.appPreferenceService});

  final AppPreferenceService appPreferenceService;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final isAuthHeaderRequired = options.extra['isAuthHeaderRequired'] == true;
    final isLoginEndpoint = options.extra['isLoginEndpoint'] ?? false;

    if (isAuthHeaderRequired) {
      final accessToken = appPreferenceService
          .getValue<String>(_authTokenStorageKey)
          ?.trim();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = accessToken.startsWith('Bearer ')
            ? accessToken
            : 'Bearer $accessToken';
      }

      final deviceId = appPreferenceService.getValue<String>(
        DeviceStorageKeys.deviceId,
      );
      if (deviceId != null) {
        options.headers['X-Device-Id'] = deviceId;
      }
    }

    if (isLoginEndpoint) {
      options.headers['x-client-type'] = 'mobile';
    }

    super.onRequest(options, handler);
  }
}
