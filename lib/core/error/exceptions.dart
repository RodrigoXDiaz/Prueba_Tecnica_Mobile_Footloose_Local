class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException([String message = 'Error de conexión']) : super(message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String message = 'No autorizado'])
    : super(message, 401);
}

class ServerException extends AppException {
  ServerException([String message = 'Error del servidor'])
    : super(message, 500);
}

class ValidationException extends AppException {
  ValidationException([String message = 'Error de validación'])
    : super(message, 400);
}
