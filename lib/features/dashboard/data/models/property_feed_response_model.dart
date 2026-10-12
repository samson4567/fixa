import 'package:fixa/features/dashboard/domain/entities/property_feed_result.dart';

class PropertyFeedResponseModel {
  const PropertyFeedResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final PropertyFeedDataModel data;

  factory PropertyFeedResponseModel.fromJson(Map<String, dynamic> json) {
    return PropertyFeedResponseModel(
      success: _readBool(json['success']),
      message: _readString(json['message']),
      data: PropertyFeedDataModel.fromJson(_readMap(json['data'])),
    );
  }

  PropertyFeedResult toEntity() {
    return PropertyFeedResult(
      sections: data.sections.map((section) => section.toEntity()).toList(),
      total: data.total,
      page: data.page,
      limit: data.limit,
      totalPages: data.totalPages,
    );
  }
}

class PropertyFeedDataModel {
  const PropertyFeedDataModel({
    required this.sections,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  final List<PropertyFeedSectionModel> sections;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  factory PropertyFeedDataModel.fromJson(Map<String, dynamic> json) {
    final sectionsJson = _readList(json['sections']);

    return PropertyFeedDataModel(
      sections: sectionsJson
          .map((item) => PropertyFeedSectionModel.fromJson(_readMap(item)))
          .toList(),
      total: _readInt(json['total']),
      page: _readInt(json['page'], fallback: 1),
      limit: _readInt(json['limit'], fallback: 20),
      totalPages: _readInt(json['totalPages'], fallback: 1),
    );
  }
}

class PropertyFeedSectionModel {
  const PropertyFeedSectionModel({
    required this.title,
    required this.type,
    required this.properties,
  });

  final String title;
  final String type;
  final List<PropertyFeedPropertyModel> properties;

  factory PropertyFeedSectionModel.fromJson(Map<String, dynamic> json) {
    final propertiesJson = _readList(json['properties']);

    return PropertyFeedSectionModel(
      title: _readString(json['title']),
      type: _readString(json['type']),
      properties: propertiesJson
          .map((item) => PropertyFeedPropertyModel.fromJson(_readMap(item)))
          .toList(),
    );
  }

  PropertyFeedSection toEntity() {
    return PropertyFeedSection(
      title: title,
      type: type,
      properties: properties.map((property) => property.toEntity()).toList(),
    );
  }
}

class PropertyFeedPropertyModel {
  const PropertyFeedPropertyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.type,
    required this.category,
    required this.images,
    required this.bedrooms,
    required this.bathrooms,
    required this.address,
    required this.city,
    required this.state,
    required this.lat,
    required this.lng,
    required this.isVerified,
    required this.agent,
  });

  final String id;
  final String title;
  final String description;
  final int price;
  final String type;
  final String category;
  final List<String> images;
  final int bedrooms;
  final int bathrooms;
  final String address;
  final String city;
  final String state;
  final double lat;
  final double lng;
  final bool isVerified;
  final PropertyAgent? agent;

  factory PropertyFeedPropertyModel.fromJson(Map<String, dynamic> json) {
    final location = _readMap(json['location']);

    return PropertyFeedPropertyModel(
      id: _readString(json['_id']),
      title: _readString(json['title']),
      description: _readString(json['description']),
      price: _readInt(json['price']),
      type: _readString(json['type']),
      category: _readString(json['category']),
      images: _readList(json['images'])
          .map((item) => _readString(item))
          .where((item) => item.isNotEmpty)
          .toList(),
      bedrooms: _readInt(json['bedrooms']),
      bathrooms: _readInt(json['bathrooms']),
      address: _firstNonEmpty([
        _firstString(location, const [
          'address',
          'formattedAddress',
          'fullAddress',
          'streetAddress',
        ]),
        _firstString(json, const [
          'address',
          'formattedAddress',
          'fullAddress',
        ]),
      ]),
      city: _firstNonEmpty([
        _readString(location['city']),
        _readString(json['city']),
      ]),
      state: _firstNonEmpty([
        _readString(location['state']),
        _readString(json['state']),
      ]),
      lat: _readDouble(location['lat']),
      lng: _readDouble(location['lng']),
      isVerified: _readBool(json['isVerified']),
      agent: _readAgent(json),
    );
  }

  PropertyFeedProperty toEntity() {
    return PropertyFeedProperty(
      id: id,
      title: title,
      description: description,
      price: price,
      type: type,
      category: category,
      images: images,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      address: address,
      city: city,
      state: state,
      lat: lat,
      lng: lng,
      isVerified: isVerified,
      agent: agent,
    );
  }
}

PropertyAgent? _readAgent(Map<String, dynamic> propertyJson) {
  const nestedKeys = <String>[
    'agent',
    'listedBy',
    'owner',
    'createdBy',
    'realtor',
    'user',
  ];

  Map<String, dynamic> data = const <String, dynamic>{};
  for (final key in nestedKeys) {
    final candidate = propertyJson[key];
    if (candidate is Map<String, dynamic> && candidate.isNotEmpty) {
      data = candidate;
      break;
    }
  }

  final firstName = _firstString(data, const ['firstName', 'firstname']);
  final lastName = _firstString(data, const ['lastName', 'lastname']);
  final composedName = [
    firstName,
    lastName,
  ].where((part) => part.isNotEmpty).join(' ');
  final name = _firstNonEmpty([
    _firstString(data, const ['fullName', 'name', 'displayName']),
    composedName,
    _firstString(propertyJson, const ['agentName', 'ownerName']),
  ]);
  final phone = _firstNonEmpty([
    _firstString(data, const ['phone', 'phoneNumber', 'mobile']),
    _firstString(propertyJson, const ['agentPhone', 'contactPhone']),
  ]);
  final imageUrl = _firstNonEmpty([
    _readImageUrl(data['profileImage']),
    _readImageUrl(data['avatar']),
    _readImageUrl(data['image']),
    _readImageUrl(data['photo']),
    _readImageUrl(propertyJson['agentImage']),
  ]);
  final location = _firstNonEmpty([
    _readLocation(data['location']),
    _firstString(data, const ['address']),
    _firstString(propertyJson, const ['agentLocation']),
  ]);
  final note = _firstNonEmpty([
    _firstString(data, const ['note', 'additionalNote', 'bio']),
    _firstString(propertyJson, const ['additionalNote', 'agentNote']),
  ]);
  final isVerified =
      _firstBool(data, const ['isVerified', 'verified']) ||
      _firstBool(propertyJson, const ['agentVerified']);

  final agent = PropertyAgent(
    name: name,
    phone: phone,
    location: location,
    imageUrl: imageUrl,
    isVerified: isVerified,
    note: note,
  );
  return agent.hasDetails || note.isNotEmpty ? agent : null;
}

String _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = _readString(json[key]).trim();
    if (value.isNotEmpty) return value;
  }
  return '';
}

String _firstNonEmpty(List<String> values) {
  for (final value in values) {
    if (value.trim().isNotEmpty) return value.trim();
  }
  return '';
}

bool _firstBool(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (_readBool(json[key])) return true;
  }
  return false;
}

String _readImageUrl(Object? value) {
  if (value is String) return value.trim();
  if (value is Map<String, dynamic>) {
    return _firstString(value, const ['url', 'secureUrl', 'path']);
  }
  return '';
}

String _readLocation(Object? value) {
  if (value is String) return value.trim();
  if (value is! Map<String, dynamic>) return '';
  return [
    _firstString(value, const ['address']),
    _firstString(value, const ['city']),
    _firstString(value, const ['state']),
    _firstString(value, const ['country']),
  ].where((part) => part.isNotEmpty).toSet().join(', ');
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
