import 'package:equatable/equatable.dart';

class PropertyPlace extends Equatable {
  const PropertyPlace({
    required this.city,
    required this.area,
    required this.state,
  });

  final String city;
  final String area;
  final String state;

  @override
  List<Object?> get props => [city, area, state];
}
