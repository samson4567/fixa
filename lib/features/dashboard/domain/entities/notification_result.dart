import 'package:equatable/equatable.dart';

class NotificationResult extends Equatable {
  const NotificationResult({
    required this.notifications,
    required this.unreadCount,
  });

  final List<AppNotification> notifications;
  final int unreadCount;

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, title, message, type, isRead, createdAt];
}
