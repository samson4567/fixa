import 'package:clapmi/core/config/app_env.dart';
import 'package:clapmi/modules/auth/data/datasources/authentication_local_datasource.dart';
import 'package:dio/dio.dart';

abstract class RealtimeChannelAuthService {
  Future<String> getAuthorizationHeader();
  Future<String> authorizePrivateChannel({
    required String socketId,
    required String channelName,
  });
}

class RealtimeChannelAuthServiceImpl implements RealtimeChannelAuthService {
  RealtimeChannelAuthServiceImpl({
    required Dio dio,
    required AuthenticationLocalDatasource authenticationLocalDatasource,
  })  : _dio = dio,
        _authenticationLocalDatasource = authenticationLocalDatasource;

  final Dio _dio;
  final AuthenticationLocalDatasource _authenticationLocalDatasource;

  @override
  Future<String> getAuthorizationHeader() async {
    final token = await _authenticationLocalDatasource.getCachedAuthToken();
    final accessToken = token?.accessToken.trim() ?? '';
    if (accessToken.isEmpty) {
      throw StateError('Missing access token for realtime connection.');
    }
    return 'Bearer $accessToken';
  }

  @override
  Future<String> authorizePrivateChannel({
    required String socketId,
    required String channelName,
  }) async {
    final authorizationHeader = await getAuthorizationHeader();
    final response = await _dio.post(
      AppEnv().webSocketAuthUrl,
      options: Options(
        headers: <String, dynamic>{
          'Content-Type': 'application/json',
          'Authorization': authorizationHeader,
        },
      ),
      data: <String, dynamic>{
        'socket_id': socketId,
        'channel_name': channelName,
      },
    );

    final authToken = response.data['auth']?.toString().trim() ?? '';
    if (authToken.isEmpty) {
      throw StateError(
          'Realtime channel authorization failed for $channelName.');
    }
    return authToken;
  }
}
