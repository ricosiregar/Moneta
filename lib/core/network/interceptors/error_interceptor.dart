import '../error/exceptions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('❌ [API ERROR]: ${err.message}');

    Exception exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = NetworkException(
          message: 'Koneksi ke server terputus (Timeout).',
        );
        break;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final message = _getErrorMessage(err.response?.data);

        if (statusCode == 401) {
          exception = ServerException(
            message: 'Sesi Anda telah berakhir, silakan login kembali.',
            statusCode: statusCode,
          );
        } else if (statusCode != null && statusCode >= 500) {
          exception = ServerException(
            message: 'Terjadi kesalahan pada server (500).',
            statusCode: statusCode,
          );
        } else {
          exception = ServerException(
            message: message ?? 'Terjadi kesalahan sistem.',
            statusCode: statusCode,
          );
        }
        break;

      case DioExceptionType.cancel:
        exception = NetworkException(message: 'Request dibatalkan.');
        break;

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        if (err.error is FormatException) {
          exception = ServerException(
            message: 'Format response dari server tidak valid.',
            statusCode: err.response?.statusCode,
          );
        } else if (err.error is ServerException ||
            err.error is NetworkException) {
          exception = err.error as Exception;
        } else {
          exception = NetworkException(
            message:
                'Koneksi internet bermasalah atau server tidak dapat dihubungi.',
          );
        }
        break;

      default:
        exception = NetworkException(
          message: 'Terjadi kesalahan yang tidak diketahui.',
        );
    }

    final dioException = DioException(
      requestOptions: err.requestOptions,
      error: exception,
      type: err.type,
      response: err.response,
    );

    super.onError(dioException, handler);
  }

  String? _getErrorMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      return data['message'] ??
          data['error'] ??
          data['error_message'] ??
          data['msg'];
    }

    if (data is String) {
      return data.isNotEmpty ? data : null;
    }

    return null;
  }
}
