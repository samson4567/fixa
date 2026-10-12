import 'package:equatable/equatable.dart';

class RealtimeEvent extends Equatable {
  const RealtimeEvent({
    required this.name,
    this.channel,
    this.data,
    this.raw = const <String, dynamic>{},
  });

  final String name;
  final String? channel;
  final dynamic data;
  final Map<String, dynamic> raw;

  @override
  List<Object?> get props => [name, channel, data, raw];
}
