class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ServerException extends AppException {
  ServerException([super.message = 'Server error occurred. Please try again later.', super.statusCode]);
}

class NetworkException extends AppException {
  NetworkException([super.message = 'No internet connection. Please check your network and try again.']);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String message = 'Invalid or expired API Key / Token. Please check your configuration.'])
      : super(message, 401);
}

class NotFoundException extends AppException {
  NotFoundException([String message = 'Requested resource was not found.'])
      : super(message, 404);
}

class CacheException extends AppException {
  CacheException([super.message = 'Failed to load cached data.']);
}
