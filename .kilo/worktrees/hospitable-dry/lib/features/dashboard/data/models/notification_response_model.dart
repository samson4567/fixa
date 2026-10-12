import 'package:fixa/features/dashboard/domain/entities/notification_result.dart';

class NotificationResponseModel {
  const NotificationResponseModel({
    required this.success,
    required this.message,
    required this.notifications,
  });

  final bool success;
  final String message;
  final List<AppNotification> notifications;

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationResponseModel(
      success: _readSuccess(json),
      message: _readString(json['message']),
      notifications: _extractNotifications(
        json,
      ).map(_notificationFromJson).toList(),
    );
  }
}

class NotificationUnreadCountModel {
  const NotificationUnreadCountModel({
    required this.success,
    required this.message,
    required this.count,
  });

  final bool success;
  final String message;
  final int count;

  factory NotificationUnreadCountModel.fromJson(Map<String, dynamic> json) {
    final data = _readMap(json['data']);
    return NotificationUnreadCountModel(
      success: _readSuccess(json),
      message: _readString(json['message']),
      count: _firstInt([
        data['unreadCount'],
        data['count'],
        json['unreadCount'],
        json['count'],
      ]),
    );
  }
}

List<Map<String, dynamic>> _extractNotifications(Map<String, dynamic> json) {
  final data = json['data'];
  final candidates = <Object?>[
    data,
    if (data is Map<String, dynamic>) ...[
      data['notifications'],
      data['items'],
      data['results'],
      data['docs'],
    ],
    json['notifications'],
    json['items'],
  ];

  for (final candidate in candidates) {
    if (candidate is List) {
      return candidate.whereType<Map<String, dynamic>>().toList();
    }
  }
  return const <Map<String, dynamic>>[];
}

AppNotification _notificationFromJson(Map<String, dynamic> json) {
  final payload = _readMap(json['data']);
  final createdAtText = _firstString([
    json['createdAt'],
    json['created_at'],
    json['date'],
    json['timestamp'],
  ]);

  return AppNotification(
    id: _firstString([json['_id'], json['id']]),
    title: _firstString([
      json['title'],
      json['subject'],
      payload['title'],
      'Notification',
    ]),
    message: _firstString([
      json['message'],
      json['body'],
      json['description'],
      payload['message'],
      payload['body'],
    ]),
    type: _firstString([json['type'], json['category'], payload['type']]),
    isRead: _firstBool([json['isRead'], json['read'], json['seen']]),
    createdAt: DateTime.tryParse(createdAtText)?.toLocal(),
  );
}

Map<String, dynamic> _readMap(Object? value) {
  return value is Map<String, dynamic> ? value : const <String, dynamic>{};
}

String _readString(Object? value) => value is String ? value.trim() : '';

String _firstString(List<Object?> values) {
  for (final value in values) {
    final text = _readString(value);
    if (text.isNotEmpty) return text;
  }
  return '';
}

int _firstInt(List<Object?> values) {
  for (final value in values) {
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return 0;
}

bool _firstBool(List<Object?> values) {
  for (final value in values) {
    if (value is bool) return value;
    if (value is num) return value != 0;
  }
  return false;
}

bool _readSuccess(Map<String, dynamic> json) {
  final success = json['success'];
  return success is bool ? success : true;
}
