import 'package:dio/dio.dart';
import 'package:fixa/core/api/base_api_client.dart';

class AppApiClient extends BaseApiClient<dynamic> {
  AppApiClient({required super.dio, required super.appPreferenceService});

  Future<dynamic> getAuth({
    required String endpoint,
    Options? options,
    Map<String, dynamic>? params,
  }) async {
    return super.get(endpoint: endpoint, options: options, params: params);
  }

  Future<dynamic> postAuth({
    required String endpoint,
    dynamic data,
    Options? options,
  }) async {
    return super.post(endpoint: endpoint, data: data, options: options);
  }
}
