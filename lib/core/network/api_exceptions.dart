class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;
}

class BadRequestException extends ApiException {
  BadRequestException({required String message})
      : super(message: message, statusCode: 400);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({required String message})
      : super(message: message, statusCode: 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException({required String message})
      : super(message: message, statusCode: 403);
}

class NotFoundException extends ApiException {
  NotFoundException({required String message})
      : super(message: message, statusCode: 404);
}

class ValidationException extends ApiException {
  ValidationException({required String message})
      : super(message: message, statusCode: 422);
}

class ServerException extends ApiException {
  ServerException({required String message})
      : super(message: message, statusCode: 500);
}

class NoInternetException extends ApiException {
  NoInternetException()
      : super(
          message: 'No internet connection. Please check your network.',
          statusCode: 0,
        );
}

class CacheException implements Exception {
  final String message;

  CacheException({required this.message});

  @override
  String toString() => message;
}