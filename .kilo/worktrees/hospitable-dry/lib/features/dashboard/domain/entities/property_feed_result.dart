import 'package:equatable/equatable.dart';

class PropertyFeedResult extends Equatable {
  const PropertyFeedResult({
    required this.sections,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  final List<PropertyFeedSection> sections;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  @override
  List<Object?> get props => [sections, total, page, limit, totalPages];
}

class PropertyFeedSection extends Equatable {
  const PropertyFeedSection({
    required this.title,
    required this.type,
    required this.properties,
  });

  final String title;
  final String type;
  final List<PropertyFeedProperty> properties;

  @override
  List<Object?> get props => [title, type, properties];
}

class PropertyFeedProperty extends Equatable {
  const PropertyFeedProperty({
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
    this.agent,
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

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    price,
    type,
    category,
    images,
    bedrooms,
    bathrooms,
    address,
    city,
    state,
    lat,
    lng,
    isVerified,
    agent,
  ];
}

class PropertyAgent extends Equatable {
  const PropertyAgent({
    required this.name,
    required this.phone,
    required this.location,
    required this.imageUrl,
    required this.isVerified,
    required this.note,
  });

  final String name;
  final String phone;
  final String location;
  final String imageUrl;
  final bool isVerified;
  final String note;

  bool get hasDetails =>
      name.isNotEmpty ||
      phone.isNotEmpty ||
      location.isNotEmpty ||
      imageUrl.isNotEmpty;

  @override
  List<Object?> get props => [
    name,
    phone,
    location,
    imageUrl,
    isVerified,
    note,
  ];
}
