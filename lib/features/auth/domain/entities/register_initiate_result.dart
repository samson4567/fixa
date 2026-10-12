import 'package:equatable/equatable.dart';

class RegisterInitiateResult extends Equatable {
  const RegisterInitiateResult({
    required this.message,
    required this.sessionToken,
    required this.step,
  });

  final String message;
  final String sessionToken;
  final String step;

  @override
  List<Object?> get props => [message, sessionToken, step];
}
