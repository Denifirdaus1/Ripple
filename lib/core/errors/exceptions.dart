// Custom exceptions for the application

/// Thrown when there is a server-side error
class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error occurred']);

  @override
  String toString() => 'ServerException: $message';
}

/// Thrown when there is an authentication error
/// Named AppAuthException to avoid conflict with Supabase AuthException
class AppAuthException implements Exception {
  final String message;
  const AppAuthException([this.message = 'Authentication error occurred']);

  @override
  String toString() => 'AppAuthException: $message';
}

/// Thrown when there is a cache/local storage error
class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error occurred']);

  @override
  String toString() => 'CacheException: $message';
}

/// Thrown when there is a network connectivity issue
class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Network error occurred']);

  @override
  String toString() => 'NetworkException: $message';
}
