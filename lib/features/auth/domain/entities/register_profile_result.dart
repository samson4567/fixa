import 'package:equatable/equatable.dart';

class RegisterProfileResult extends Equatable {
  const RegisterProfileResult({required this.message, required this.step});

  final String message;
  final String step;

  @override
  List<Object?> get props => [message, step];
}
