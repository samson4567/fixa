import 'package:flutter_dotenv/flutter_dotenv.dart';

final class AppEnv {
  factory AppEnv() => _instance;

  AppEnv._();

  static final AppEnv _instance = AppEnv._();

  static String _required(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError('Missing required env var: $key');
    }
    return value;
  }

  final String apiUrl = _required('API_URL');

  final String webSocketApiUrl = _required('WEBSOCKET_API_URL');

  final String webSocketAuthUrl = _required('WEBSOCKET_AUTH_URL');

  final String socketIoUrl = _required('SOCKET_IO_URL');

  final String socketPath = _required('SOCKET_PATH');

  final String xHandle = _required('TWITTER_HANDLE');

  final String instangramHandle = _required('INSTAGRAM_HANDLE');

  final String tiktokHandle = _required('TIKTOK_HANDLE');

  final String discordServer = _required('DISCORD_SERVER');
}
