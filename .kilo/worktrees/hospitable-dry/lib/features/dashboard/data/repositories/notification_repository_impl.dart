import 'package:fixa/features/dashboard/data/datasources/notification_remote_data_source.dart';
import 'package:fixa/features/dashboard/domain/entities/notification_result.dart';
import 'package:fixa/features/dashboard/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({
    required NotificationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final NotificationRemoteDataSource _remoteDataSource;

  @override
  Future<NotificationResult> getNotifications() async {
    final notificationsFuture = _remoteDataSource.getNotifications();
    final unreadFuture = _remoteDataSource.getUnreadCount();
    final notifications = await notificationsFuture;
    final unread = await unreadFuture;
    return NotificationResult(
      notifications: notifications.notifications,
      unreadCount: unread.count,
    );
  }
}
