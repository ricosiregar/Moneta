import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../interceptors/error_interceptor.dart';
import '../interceptors/logging_interceptor.dart';

/// Network configuration constants (Timeouts & Headers)
class NetworkConfig {
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}

/// HTTP API Client wrapper around Dio with interceptors configured
class ApiClient {
  late final Dio dio;

  ApiClient({Dio? customDio}) {
    dio =
        customDio ??
        Dio(
          BaseOptions(
            connectTimeout: NetworkConfig.connectTimeout,
            receiveTimeout: NetworkConfig.receiveTimeout,
            sendTimeout: NetworkConfig.sendTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    dio.interceptors.addAll([
      ErrorInterceptor(),
      if (kDebugMode) LoggingInterceptor(log: (msg) => debugPrint(msg)),
    ]);
  }
}
