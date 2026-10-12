import 'package:fixa/features/dashboard/domain/entities/property_feed_result.dart';
import 'package:fixa/features/dashboard/domain/entities/property_map_pins_result.dart';
import 'package:fixa/features/dashboard/domain/entities/property_place.dart';

abstract class PropertyFeedRepository {
  Future<PropertyFeedResult> getPropertyFeed({
    String? type,
    required int page,
    required int limit,
  });

  Future<PropertyFeedProperty> getPropertyById(String id);

  Future<PropertyMapPinsResult> getPropertyMapPins({
    required String type,
    required int page,
    required int limit,
  });

  Future<List<PropertyPlace>> getPropertyPlaces(String query);

  Future<List<PropertyFeedProperty>> getFavoriteProperties();

  Future<String> addPropertyToFavorites(String id);

  Future<String> removePropertyFromFavorites(String id);
}
