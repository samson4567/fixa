import 'package:fixa/features/dashboard/domain/entities/property_place.dart';

class PropertyPlacesResponseModel {
  const PropertyPlacesResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final List<PropertyPlaceModel> data;

  factory PropertyPlacesResponseModel.fromJson(Map<String, dynamic> json) {
    return PropertyPlacesResponseModel(
      success: _readBool(json['success']),
      message: _readString(json['message']),
      data: _readList(
        json['data'],
      ).map((item) => PropertyPlaceModel.fromJson(_readMap(item))).toList(),
    );
  }

  List<PropertyPlace> toEntity() {
    return data.map((item) => item.toEntity()).toList();
  }
}

class PropertyPlaceModel {
  const PropertyPlaceModel({
    required this.city,
    required this.area,
    required this.state,
  });

  final String city;
  final String area;
  final String state;

  factory PropertyPlaceModel.fromJson(Map<String, dynamic> json) {
    return PropertyPlaceModel(
      city: _readString(json['city']),
      area: _readString(json['area']),
      state: _readString(json['state']),
    );
  }

  PropertyPlace toEntity() {
    return PropertyPlace(city: city, area: area, state: state);
  }
}

Map<String, dynamic> _readMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  return <String, dynamic>{};
}

List<dynamic> _readList(Object? value) {
  if (value is List<dynamic>) {
    return value;
  }

  return const <dynamic>[];
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
