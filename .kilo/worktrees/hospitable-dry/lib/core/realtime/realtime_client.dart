import 'package:clapmi/core/realtime/realtime_connection_state.dart';
import 'package:clapmi/core/realtime/realtime_event.dart';

abstract class RealtimeClient {
  Stream<RealtimeConnectionState> get connectionStates;
  Stream<RealtimeEvent> get events;
  String? get socketId;
  bool get isConnected;

  Future<void> connect();
  Future<void> disconnect();
  Future<void> subscribePublic(String channelName);
  Future<void> subscribePrivate(String channelName);
  Future<void> unsubscribe(String channelName);
  Future<void> send({
    required String event,
    String? channel,
    dynamic data,
  });
}
