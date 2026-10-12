abstract class AppException implements Exception {
  const AppException({
    required this.message,
    this.description,
    this.moreInformation,
  });

  final String message;
  final String? description;
  final Object? moreInformation;
}

class NetworkException extends AppException {
  const NetworkException({
    super.message =
        'No internet connection. Please check your connection and try again.',
    super.description = 'We could not reach Clapmi right now.',
  });
}

class UnAuthorizedException extends AppException {
  const UnAuthorizedException({
    required super.message,
    super.description,
    super.moreInformation,
  });
}

class ClientException extends AppException {
  const ClientException({
    required super.message,
    super.description,
    super.moreInformation,
  });
}

class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.description,
    super.moreInformation,
  });
}

class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'Request timed out',
    super.description = 'Try again later',
  });
}

class BadRequestException extends AppException {
  const BadRequestException({
    required super.message,
    super.description,
    super.moreInformation,
  });
}

class UnknownException extends AppException {
  const UnknownException({
    required super.message,
    super.description,
  });
}
