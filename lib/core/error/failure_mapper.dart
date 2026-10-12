import 'package:fixa/core/error/exception.dart';
import 'package:fixa/core/error/failure.dart';

Failure mapExceptionToFailure(Object error) {
  if (error is ServerException) {
    return ServerFailure(
      message: error.message,
      description: error.description,
    );
  }
  if (error is UnAuthorizedException) {
    return UnAuthorizedFailure(
      message: error.message,
      description: error.description,
    );
  }
  if (error is ClientException) {
    return ClientFailure(
      message: error.message,
      description: error.description,
      moreInformation: error.moreInformation,
    );
  }
  if (error is NetworkException) {
    return NetworkFailure(
      message: error.message,
      description: error.description,
    );
  }
  if (error is TimeoutException) {
    return TimeoutFailure(
      message: error.message,
      description: error.description,
    );
  }
  if (error is BadRequestException) {
    return BadRequestFailure(
      message: error.message,
      description: error.description,
    );
  }
  if (error is UnknownException) {
    return UnKnownFailure(
      message: error.message,
      description: error.description,
    );
  }

  return const UnKnownFailure(
    message: 'Something went wrong',
    description: 'Try again later',
  );
}
