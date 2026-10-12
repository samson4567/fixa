import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({
    required this.message,
    this.description,
    this.moreInformation,
  });

  final String message;
  final String? description;
  final Object? moreInformation;

  @override
  List<Object?> get props => [message, description, moreInformation];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.description});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.description});
}

class UnAuthorizedFailure extends Failure {
  const UnAuthorizedFailure({required super.message, super.description});
}

class ClientFailure extends Failure {
  const ClientFailure({
    required super.message,
    super.description,
    super.moreInformation,
  });
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({required super.message, super.description});
}

class BadRequestFailure extends Failure {
  const BadRequestFailure({required super.message, super.description});
}

class UnKnownFailure extends Failure {
  const UnKnownFailure({required super.message, super.description});
}
