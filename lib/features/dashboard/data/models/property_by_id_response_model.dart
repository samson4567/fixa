import 'package:fixa/features/dashboard/data/models/property_feed_response_model.dart';
import 'package:fixa/features/dashboard/domain/entities/property_feed_result.dart';

class PropertyByIdResponseModel {
  const PropertyByIdResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final PropertyFeedPropertyModel data;

  factory PropertyByIdResponseModel.fromJson(Map<String, dynamic> json) {
    return PropertyByIdResponseModel(
      success: _readBool(json['success']),
      message: _readString(json['message']),
      data: PropertyFeedPropertyModel.fromJson(_readMap(json['data'])),
    );
  }

  PropertyFeedProperty toEntity() => data.toEntity();
}

Map<String, dynamic> _readMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  return <String, dynamic>{};
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
