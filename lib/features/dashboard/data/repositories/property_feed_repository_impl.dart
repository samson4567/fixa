import 'package:fixa/features/dashboard/data/datasources/property_feed_remote_data_source.dart';
import 'package:fixa/features/dashboard/domain/entities/property_feed_result.dart';
import 'package:fixa/features/dashboard/domain/entities/property_map_pins_result.dart';
import 'package:fixa/features/dashboard/domain/entities/property_place.dart';
import 'package:fixa/features/dashboard/domain/repositories/property_feed_repository.dart';

class PropertyFeedRepositoryImpl implements PropertyFeedRepository {
  PropertyFeedRepositoryImpl({
    required PropertyFeedRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final PropertyFeedRemoteDataSource _remoteDataSource;

  @override
  Future<PropertyFeedResult> getPropertyFeed({
    String? type,
    required int page,
    required int limit,
  }) async {
    final response = await _remoteDataSource.getPropertyFeed(
      type: type,
      page: page,
      limit: limit,
    );

    return response.toEntity();
  }

  @override
  Future<PropertyFeedProperty> getPropertyById(String id) async {
    final response = await _remoteDataSource.getPropertyById(id);
    return response.toEntity();
  }

  @override
  Future<PropertyMapPinsResult> getPropertyMapPins({
    required String type,
    required int page,
    required int limit,
  }) async {
    final response = await _remoteDataSource.getPropertyMapPins(
      type: type,
      page: page,
      limit: limit,
    );

    return response.toEntity();
  }

  @override
  Future<List<PropertyPlace>> getPropertyPlaces(String query) async {
    final response = await _remoteDataSource.getPropertyPlaces(query);
    return response.toEntity();
  }

  @override
  Future<List<PropertyFeedProperty>> getFavoriteProperties() {
    return _remoteDataSource.getFavoriteProperties();
  }

  @override
  Future<String> addPropertyToFavorites(String id) {
    return _remoteDataSource.addPropertyToFavorites(id);
  }

  @override
  Future<String> removePropertyFromFavorites(String id) {
    return _remoteDataSource.removePropertyFromFavorites(id);
  }
}
