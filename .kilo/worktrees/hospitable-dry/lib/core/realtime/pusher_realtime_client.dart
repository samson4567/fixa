import 'dart:async';
import 'dart:convert';

import 'package:web_socket_client/web_socket_client.dart' as ws;

class PusherRealtimeClient implements RealtimeClient {
  PusherRealtimeClient({required RealtimeChannelAuthService channelAuthService})
    : _channelAuthService = channelAuthService;

  final RealtimeChannelAuthService _channelAuthService;

  final StreamController<RealtimeConnectionState> _connectionController =
      StreamController<RealtimeConnectionState>.broadcast();
  final StreamController<RealtimeEvent> _eventController =
      StreamController<RealtimeEvent>.broadcast();

  final Set<String> _publicChannels = <String>{};
  final Set<String> _privateChannels = <String>{};

  ws.WebSocket? _socket;
  StreamSubscription<dynamic>? _messagesSub;
  StreamSubscription<ws.ConnectionState>? _connectionSub;
  Completer<void>? _socketReadyCompleter;
  String? _socketId;

  @override
  Stream<RealtimeConnectionState> get connectionStates =>
      _connectionController.stream;

  @override
  Stream<RealtimeEvent> get events => _eventController.stream;

  @override
  String? get socketId => _socketId;

  @override
  bool get isConnected => _socketId?.isNotEmpty == true;

  @override
  Future<void> connect() async {
    if (_socket != null) {
      if (isConnected) {
        return;
      }
      final readyCompleter = _socketReadyCompleter;
      if (readyCompleter != null) {
        try {
          await readyCompleter.future.timeout(const Duration(seconds: 10));
        } catch (error) {
          await _resetSocketState();
          rethrow;
        }
      }
      return;
    }

    try {
      final authorizationHeader = await _channelAuthService
          .getAuthorizationHeader();
      _socketReadyCompleter = Completer<void>();
      final socket = ws.WebSocket(
        Uri.parse(AppEnv().webSocketApiUrl),
        headers: <String, dynamic>{'Authorization': authorizationHeader},
      );

      _socket = socket;
      _connectionController.add(RealtimeConnectionState.connecting);

      _connectionSub = socket.connection.listen(
        (state) {
          _onConnectionStateChanged(state);
        },
        onError: (_) {
          _connectionController.add(RealtimeConnectionState.disconnected);
        },
      );

      _messagesSub = socket.messages.listen(
        (message) => unawaited(_handleMessage(message)),
        onError: (_) {
          _completeSocketReadyWithError(
            StateError('Realtime socket message stream failed.'),
          );
          _connectionController.add(RealtimeConnectionState.disconnected);
        },
        onDone: () {
          _socketId = null;
          _completeSocketReadyWithError(
            StateError('Realtime socket closed before becoming ready.'),
          );
          _connectionController.add(RealtimeConnectionState.disconnected);
        },
      );

      await _socketReadyCompleter?.future.timeout(const Duration(seconds: 10));
    } catch (error) {
      await _resetSocketState();
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    _completeSocketReadyWithError(StateError('Realtime socket disconnected.'));
    await _resetSocketState();
  }

  @override
  Future<void> subscribePublic(String channelName) async {
    _publicChannels.add(channelName);
    await connect();
    if (!isConnected) {
      return;
    }
    _sendRaw(<String, dynamic>{
      'event': 'pusher:subscribe',
      'data': <String, dynamic>{'channel': channelName},
    });
  }

  @override
  Future<void> subscribePrivate(String channelName) async {
    _privateChannels.add(channelName);
    await connect();
    await _subscribePrivateChannel(channelName);
  }

  Future<void> _subscribePrivateChannel(String channelName) async {
    final currentSocketId = _socketId;
    if (currentSocketId == null || currentSocketId.isEmpty) {
      return;
    }

    final authToken = await _channelAuthService.authorizePrivateChannel(
      socketId: currentSocketId,
      channelName: channelName,
    );
    _sendRaw(<String, dynamic>{
      'event': 'pusher:subscribe',
      'data': <String, dynamic>{'channel': channelName, 'auth': authToken},
    });
  }

  @override
  Future<void> unsubscribe(String channelName) async {
    _publicChannels.remove(channelName);
    _privateChannels.remove(channelName);
    _sendRaw(<String, dynamic>{
      'event': 'pusher:unsubscribe',
      'data': <String, dynamic>{'channel': channelName},
    });
  }

  @override
  Future<void> send({
    required String event,
    String? channel,
    dynamic data,
  }) async {
    await connect();
    _sendRaw(<String, dynamic>{
      'event': event,
      if (channel != null && channel.isNotEmpty) 'channel': channel,
      'data': data,
    });
  }

  void _onConnectionStateChanged(ws.ConnectionState state) {
    switch (state) {
      case ws.Connecting():
        _connectionController.add(RealtimeConnectionState.connecting);
      case ws.Connected():
        _connectionController.add(RealtimeConnectionState.connected);
      case ws.Reconnecting():
        _socketId = null;
        _connectionController.add(RealtimeConnectionState.reconnecting);
      case ws.Reconnected():
        _connectionController.add(RealtimeConnectionState.connected);
      case ws.Disconnecting():
        _connectionController.add(RealtimeConnectionState.disconnected);
      case ws.Disconnected():
        _socketId = null;
        _connectionController.add(RealtimeConnectionState.disconnected);
    }
  }

  Future<void> _handleMessage(dynamic rawMessage) async {
    final payload = _normalizeMap(rawMessage);
    if (payload.isEmpty) {
      return;
    }

    final eventName = payload['event']?.toString().trim() ?? '';
    if (eventName.isEmpty) {
      return;
    }

    if (eventName == 'pusher:connection_established') {
      final data = _normalizeMap(payload['data']);
      _socketId = data['socket_id']?.toString();
      _socketReadyCompleter?.complete();
      await _restoreSubscriptions();
      return;
    }

    _eventController.add(
      RealtimeEvent(
        name: _normalizeEventName(eventName),
        channel: payload['channel']?.toString(),
        data: _decodeData(payload['data']),
        raw: payload,
      ),
    );
  }

  Future<void> _restoreSubscriptions() async {
    for (final channelName in _publicChannels) {
      _sendRaw(<String, dynamic>{
        'event': 'pusher:subscribe',
        'data': <String, dynamic>{'channel': channelName},
      });
    }

    for (final channelName in _privateChannels) {
      await _subscribePrivateChannel(channelName);
    }
  }

  String _normalizeEventName(String eventName) {
    return eventName.split('\\').last.split('.').last.trim();
  }

  dynamic _decodeData(dynamic rawData) {
    if (rawData is! String) {
      return rawData;
    }
    final trimmed = rawData.trim();
    if (trimmed.isEmpty) {
      return rawData;
    }
    try {
      return jsonDecode(trimmed);
    } catch (_) {
      return rawData;
    }
  }

  Map<String, dynamic> _normalizeMap(dynamic rawData) {
    final decoded = _decodeData(rawData);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    return const <String, dynamic>{};
  }

  void _sendRaw(Map<String, dynamic> payload) {
    final socket = _socket;
    if (socket == null) {
      return;
    }
    socket.send(jsonEncode(payload));
  }

  Future<void> _resetSocketState() async {
    _socketId = null;
    _socket?.close();
    _socket = null;
    await _messagesSub?.cancel();
    await _connectionSub?.cancel();
    _messagesSub = null;
    _connectionSub = null;
    _socketReadyCompleter = null;
  }

  void _completeSocketReadyWithError(Object error) {
    final completer = _socketReadyCompleter;
    if (completer == null || completer.isCompleted) {
      return;
    }
    completer.completeError(error);
  }
}
