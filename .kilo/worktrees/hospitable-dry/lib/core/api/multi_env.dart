import 'package:flutter/foundation.dart';
import 'package:envied/envied.dart';

part 'multi_env.g.dart';

@Envied(path: '.env', name: 'ProductionEnv')
@Envied(path: '.env_debug', name: 'DebugEnv')
final class MultiEnv {
  // static const bool kDebugMode;

  factory MultiEnv() => _instance;

  static final MultiEnv _instance = switch (kDebugMode) {
    true => _DebugEnv(),
    false => _ProductionEnv(),
  }; //

  @EnviedField(varName: 'API_URL')
  final String apiUrl = _instance.apiUrl;

  @EnviedField(varName: 'WEBSOCKET_API_URL')
  final String webSocketApiUrl = _instance.webSocketApiUrl;

  @EnviedField(varName: 'WEBSOCKET_AUTH_URL')
  final String webSocketAuthUrl = _instance.webSocketAuthUrl;

  @EnviedField(varName: 'SOCKET_IO_URL')
  final String socketIoUrl = _instance.socketIoUrl;

  @EnviedField(varName: 'SOCKET_PATH')
  final String socketPath = _instance.socketPath;

  @EnviedField(varName: 'TWITTER_HANDLE')
  final String xHandle = _instance.xHandle;

  @EnviedField(varName: 'INSTANGRAM_HANDLE')
  final String instangramHandle = _instance.instangramHandle;

  @EnviedField(varName: 'TIKTOK_HANDLE')
  final String tiktokHandle = _instance.tiktokHandle;

  @EnviedField(varName: 'DISCORD_SERVER')
  final String discordServer = _instance.discordServer;
}
