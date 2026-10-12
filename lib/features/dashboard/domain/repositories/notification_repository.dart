import 'package:fixa/features/dashboard/domain/entities/notification_result.dart';

abstract class NotificationRepository {
  Future<NotificationResult> getNotifications();
}
