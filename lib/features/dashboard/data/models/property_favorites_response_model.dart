import 'package:fixa/features/dashboard/data/models/property_feed_response_model.dart';
import 'package:fixa/features/dashboard/domain/entities/property_feed_result.dart';

class PropertyFavoritesResponseModel {
  const PropertyFavoritesResponseModel({
    required this.success,
    required this.message,
    required this.properties,
  });

  final bool success;
  final String message;
  final List<PropertyFeedPropertyModel> properties;

  factory PropertyFavoritesResponseModel.fromJson(Map<String, dynamic> json) {
    return PropertyFavoritesResponseModel(
      success: _readBool(json['success']),
      message: _readString(json['message']),
      properties: _extractPropertyMaps(
        json,
      ).map(PropertyFeedPropertyModel.fromJson).toList(),
    );
  }

  List<PropertyFeedProperty> toEntity() {
    return properties.map((property) => property.toEntity()).toList();
  }

  static List<Map<String, dynamic>> _extractPropertyMaps(
    Map<String, dynamic> json,
  ) {
    final data = json['data'];

    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }

    if (data is Map<String, dynamic>) {
      final candidates = <Object?>[
        data['favorites'],
        data['properties'],
        data['items'],
        data['data'],
      ];

      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate.whereType<Map<String, dynamic>>().toList();
        }
      }
    }

    return const <Map<String, dynamic>>[];
  }
}

String _readString(Object? value) {
  if (value is String) {
    return value;
  }

  return '';
}

bool _readBool(Object? value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }

  return fallback;
}
