class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'No internet connection. Please check your network.'});

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'Failed to read/write local storage.'});

  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;

  const AuthException({required this.message});

  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;

  const ValidationException({required this.message});

  @override
  String toString() => message;
}

class AIException implements Exception {
  final String message;

  const AIException({required this.message});

  @override
  String toString() => message;
}

class OCRException implements Exception {
  final String message;

  const OCRException({required this.message});

  @override
  String toString() => message;
}

