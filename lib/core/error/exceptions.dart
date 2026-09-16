/// Thrown by data sources (remote or local). Repositories catch these and
/// translate them into [Failure]s for the domain/presentation layers.
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException(this.message, {this.statusCode});
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'No internet connection']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'No cached data available']);
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Session expired, please log in again']);
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
}
