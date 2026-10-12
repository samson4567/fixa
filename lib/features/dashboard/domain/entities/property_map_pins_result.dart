import 'package:equatable/equatable.dart';

class PropertyMapPinsResult extends Equatable {
  const PropertyMapPinsResult({required this.pins, required this.total});

  final List<PropertyMapPin> pins;
  final int total;

  @override
  List<Object?> get props => [pins, total];
}

class PropertyMapPin extends Equatable {
  const PropertyMapPin({
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

  @override
  List<Object?> get props => [id, lat, lng, price, type, category, title];
}
