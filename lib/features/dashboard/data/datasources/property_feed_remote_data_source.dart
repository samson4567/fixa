import 'package:fixa/core/constants/endpoint_constant.dart';
import 'package:fixa/core/network/api_client.dart';
import 'package:fixa/core/network/app_error.dart';
import 'package:fixa/features/dashboard/data/models/property_by_id_response_model.dart';
import 'package:fixa/features/dashboard/data/models/property_feed_response_model.dart';
import 'package:fixa/features/dashboard/data/models/property_favorites_response_model.dart';
import 'package:fixa/features/dashboard/data/models/property_map_pins_response_model.dart';
import 'package:fixa/features/dashboard/data/models/property_places_response_model.dart';
import 'package:fixa/features/dashboard/domain/entities/property_feed_result.dart';

abstract class PropertyFeedRemoteDataSource {
  Future<PropertyFeedResponseModel> getPropertyFeed({
    String? type,
    required int page,
    required int limit,
  });

  Future<PropertyByIdResponseModel> getPropertyById(String id);

  Future<PropertyMapPinsResponseModel> getPropertyMapPins({
    required String type,
    required int page,
    required int limit,
  });

  Future<PropertyPlacesResponseModel> getPropertyPlaces(String query);

  Future<List<PropertyFeedProperty>> getFavoriteProperties();

  Future<String> addPropertyToFavorites(String id);

  Future<String> removePropertyFromFavorites(String id);
}

class PropertyFeedRemoteDataSourceImpl implements PropertyFeedRemoteDataSource {
  PropertyFeedRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<PropertyFeedResponseModel> getPropertyFeed({
    String? type,
    required int page,
    required int limit,
  }) async {
    final queryParameters = <String, dynamic>{'page': page, 'limit': limit};

    if (type != null && type.trim().isNotEmpty) {
      queryParameters['type'] = type.trim();
    }

    final response = await _apiClient.get(
      EndpointConstant.propertyFeed,
      queryParameters: queryParameters,
    );

    final model = PropertyFeedResponseModel.fromJson(response);

    if (!model.success) {
      throw AppError(
        model.message.isEmpty
            ? 'Something went wrong. Please try again.'
            : model.message,
      );
    }

    return model;
  }

  @override
  Future<PropertyByIdResponseModel> getPropertyById(String id) async {
    final response = await _apiClient.get(
      '${EndpointConstant.propertyFeed}/$id',
    );

    final model = PropertyByIdResponseModel.fromJson(response);

    if (!model.success) {
      throw AppError(
        model.message.isEmpty
            ? 'Something went wrong. Please try again.'
            : model.message,
      );
    }

    return model;
  }

  @override
  Future<PropertyMapPinsResponseModel> getPropertyMapPins({
    required String type,
    required int page,
    required int limit,
  }) async {
    final response = await _apiClient.get(
      EndpointConstant.propertyFeed,
      queryParameters: <String, dynamic>{
        'type': type,
        'page': page,
        'limit': limit,
      },
    );

    final model = PropertyMapPinsResponseModel.fromJson(response);

    if (!model.success) {
      throw AppError(
        model.message.isEmpty
            ? 'Something went wrong. Please try again.'
            : model.message,
      );
    }

    return model;
  }

  @override
  Future<PropertyPlacesResponseModel> getPropertyPlaces(String query) async {
    final response = await _apiClient.get(
      EndpointConstant.propertyPlaces,
      queryParameters: <String, dynamic>{'q': query.trim()},
    );

    final model = PropertyPlacesResponseModel.fromJson(response);

    if (!model.success) {
      throw AppError(
        model.message.isEmpty
            ? 'Something went wrong. Please try again.'
            : model.message,
      );
    }

    return model;
  }

  @override
  Future<List<PropertyFeedProperty>> getFavoriteProperties() async {
    final response = await _apiClient.get(EndpointConstant.propertyFavorites);

    final model = PropertyFavoritesResponseModel.fromJson(response);

    if (!model.success) {
      throw AppError(
        model.message.isEmpty
            ? 'Unable to load favorites. Please try again.'
            : model.message,
      );
    }

    return model.toEntity();
  }

  @override
  Future<String> addPropertyToFavorites(String id) async {
    final response = await _apiClient.post(
      EndpointConstant.propertyFavorite(id),
    );
    final success = response['success'] == true;
    final message = response['message'] as String?;

    if (!success) {
      throw AppError(
        message == null || message.trim().isEmpty
            ? 'Unable to add favorite. Please try again.'
            : message,
      );
    }

    return (message == null || message.trim().isEmpty)
        ? 'Property added to favorites.'
        : message;
  }

  @override
  Future<String> removePropertyFromFavorites(String id) async {
    final response = await _apiClient.delete(
      EndpointConstant.propertyFavorite(id),
    );
    final success = response['success'] == true;
    final message = response['message'] as String?;

    if (!success) {
      throw AppError(
        message == null || message.trim().isEmpty
            ? 'Unable to remove favorite. Please try again.'
            : message,
      );
    }

    return (message == null || message.trim().isEmpty)
        ? 'Property removed from favorites.'
        : message;
  }
}
