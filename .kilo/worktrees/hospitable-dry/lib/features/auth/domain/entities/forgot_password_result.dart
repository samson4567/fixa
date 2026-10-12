import 'package:equatable/equatable.dart';

class ForgotPasswordResult extends Equatable {
  const ForgotPasswordResult({required this.message, this.token});

  final String message;
  final String? token;

  @override
  List<Object?> get props => [message, token];
}
