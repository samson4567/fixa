import 'package:fixa/core/constants/endpoint_constant.dart';
import 'package:fixa/core/network/api_client.dart';
import 'package:fixa/core/network/app_error.dart';
import 'package:fixa/features/dashboard/data/models/notification_response_model.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationResponseModel> getNotifications();
  Future<NotificationUnreadCountModel> getUnreadCount();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<NotificationResponseModel> getNotifications() async {
    final response = await _apiClient.get(EndpointConstant.notifications);
    final model = NotificationResponseModel.fromJson(response);
    if (!model.success) {
      throw AppError(
        model.message.isEmpty ? 'Unable to load notifications.' : model.message,
      );
    }
    return model;
  }

  @override
  Future<NotificationUnreadCountModel> getUnreadCount() async {
    final response = await _apiClient.get(
      EndpointConstant.notificationUnreadCount,
    );
    final model = NotificationUnreadCountModel.fromJson(response);
    if (!model.success) {
      throw AppError(
        model.message.isEmpty
            ? 'Unable to load notification count.'
            : model.message,
      );
    }
    return model;
  }
}
