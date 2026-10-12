import 'package:equatable/equatable.dart';

class LoginResult extends Equatable {
  const LoginResult({
    required this.message,
    required this.accessToken,
    required this.refreshToken,
  });

  final String message;
  final String accessToken;
  final String refreshToken;

  @override
  List<Object?> get props => [message, accessToken, refreshToken];
}
