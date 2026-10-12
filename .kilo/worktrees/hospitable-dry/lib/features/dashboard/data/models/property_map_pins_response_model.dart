import 'package:fixa/features/dashboard/domain/entities/property_map_pins_result.dart';

class PropertyMapPinsResponseModel {
  const PropertyMapPinsResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final PropertyMapPinsDataModel data;

  factory PropertyMapPinsResponseModel.fromJson(Map<String, dynamic> json) {
    return PropertyMapPinsResponseModel(
      success: _readBool(json['success']),
      message: _readString(json['message']),
      data: PropertyMapPinsDataModel.fromJson(_readMap(json['data'])),
    );
  }

  PropertyMapPinsResult toEntity() {
    return PropertyMapPinsResult(
      pins: data.pins.map((pin) => pin.toEntity()).toList(),
      total: data.total,
    );
  }
}

class PropertyMapPinsDataModel {
  const PropertyMapPinsDataModel({required this.pins, required this.total});

  final List<PropertyMapPinModel> pins;
  final int total;

  factory PropertyMapPinsDataModel.fromJson(Map<String, dynamic> json) {
    final pinsJson = _resolvePins(json);

    return PropertyMapPinsDataModel(
      pins: pinsJson
          .map((item) => PropertyMapPinModel.fromJson(_readMap(item)))
          .where((pin) => pin.lat != 0 || pin.lng != 0)
          .toList(),
      total: _readInt(json['total'], fallback: pinsJson.length),
    );
  }
}

class PropertyMapPinModel {
  const PropertyMapPinModel({
    required this.id,
    required this.lat,
    required this.lng,
    required this.price,
    required this.type,
    required this.category,
    required this.title,
  });

  final String id;
  final double lat;
  final double lng;
  final int price;
  final String type;
  final String category;
  final String title;

  factory PropertyMapPinModel.fromJson(Map<String, dynamic> json) {
    final location = _readMap(json['location']);

    return PropertyMapPinModel(
      id: _readString(json['id']).isNotEmpty
          ? _readString(json['id'])
          : _readString(json['_id']),
      lat: _readDouble(json['lat'], fallback: _readDouble(location['lat'])),
      lng: _readDouble(json['lng'], fallback: _readDouble(location['lng'])),
      price: _readInt(json['price']),
      type: _readString(json['type']),
      category: _readString(json['category']),
      title: _readString(json['title']),
    );
  }

  PropertyMapPin toEntity() {
    return PropertyMapPin(
      id: id,
      lat: lat,
      lng: lng,
      price: price,
      type: type,
      category: category,
      title: title,
    );
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

int _readInt(Object? value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return fallback;
}

double _readDouble(Object? value, {double fallback = 0}) {
  if (value is double) {
    return value;
  }

  if (value is num) {
    return value.toDouble();
  }

  return fallback;
}

bool _readBool(Object? value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }

  return fallback;
}

List<dynamic> _resolvePins(Map<String, dynamic> data) {
  final directPins = _readList(data['pins']);
  if (directPins.isNotEmpty) {
    return directPins;
  }

  final directProperties = _readList(data['properties']);
  if (directProperties.isNotEmpty) {
    return directProperties;
  }

  final sections = _readList(data['sections']);
  if (sections.isEmpty) {
    return const <dynamic>[];
  }

  return sections
      .map((item) => _readMap(item))
      .expand((section) => _readList(section['properties']))
      .toList();
}
