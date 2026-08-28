import 'package:equatable/equatable.dart';

/// Base abstract class for all Failure types in the Domain Layer
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Failure returned when remote server (e.g. Supabase, REST API) throws an error
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
  });
}

/// Failure returned when there is no internet connection
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.statusCode,
  });
}

/// Failure returned when local database/cache (e.g. SQLite/Drift/SharedPreferences) fails
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to load data from local storage.',
    super.statusCode,
  });
}

/// Failure returned when authentication/session is invalid or unauthorized
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.statusCode,
  });
}

/// Failure returned when input validation fails (e.g. amount is negative, empty title)
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.statusCode,
  });
}

/// Failure returned when AI Insight / Gemini API encounters an issue
class AIFailure extends Failure {
  const AIFailure({
    required super.message,
    super.statusCode,
  });
}

/// Failure returned when OCR / Receipt scanner fails to read an image
class OCRFailure extends Failure {
  const OCRFailure({
    required super.message,
    super.statusCode,
  });
}
