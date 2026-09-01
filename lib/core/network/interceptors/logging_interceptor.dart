import 'dart:convert';
import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  final void Function(String) log;
  final bool isDebug;
  final int maxListDisplay;

  LoggingInterceptor({
    required this.log,
    this.isDebug = true,
    this.maxListDisplay = 3,
  });

  String _generateRequestId(RequestOptions options) {
    return '${options.method}-${options.path.replaceAll('/', '_')}-${DateTime.now().millisecondsSinceEpoch}';
  }

  dynamic _cleanData(dynamic data) {
    if (data is List) {
      final total = data.length;
      final preview = data
          .take(maxListDisplay)
          .map((e) => _cleanData(e))
          .toList();
      if (total > maxListDisplay) {
        preview.add('... +${total - maxListDisplay} item lainnya');
      }
      return preview;
    }

    if (data is Map) {
      return data.map((key, value) {
        final keyStr = key.toString().toLowerCase();

        final isSuspectKey =
            keyStr.contains('base64') ||
            keyStr.contains('image') ||
            keyStr.contains('logo') ||
            keyStr.contains('photo') ||
            keyStr.contains('avatar') ||
            keyStr.contains('picture') ||
            keyStr.contains('thumbnail');

        if (isSuspectKey && value is String && value.length > 100) {
          return MapEntry(key, '[BASE64 HIDDEN - ${value.length} chars]');
        }

        return MapEntry(key, _cleanData(value));
      });
    }

    if (data is String && data.length > 500) {
      final suspiciousChars = data.replaceAll(
        RegExp(r'[A-Za-z0-9+/=\r\n\s]'),
        '',
      );
      if (suspiciousChars.isEmpty) {
        return '[BASE64 HIDDEN - ${data.length} chars]';
      }
    }

    return data;
  }

  dynamic _parseData(dynamic rawData) {
    if (rawData is String) {
      try {
        return jsonDecode(rawData);
      } catch (_) {
        return rawData;
      }
    }
    return rawData;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (isDebug) {
      final requestId = _generateRequestId(options);
      options.extra['request_id'] = requestId;
      options.extra['request_start'] = DateTime.now().millisecondsSinceEpoch;

      log('''
╔════════════════════════════════════════════════════════════
║ 🚀 REQUEST
║ ID          : $requestId
║ Method      : ${options.method}
║ URL         : ${options.uri}
║ Headers     : ${options.headers}
║ Query Params: ${options.queryParameters.isEmpty ? 'none' : options.queryParameters}
║ Body        : ${_cleanData(_parseData(options.data))}
╚════════════════════════════════════════════════════════════
      ''');
    }
    return handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (isDebug) {
      final start = response.requestOptions.extra['request_start'] as int?;
      final duration = start != null
          ? '${DateTime.now().millisecondsSinceEpoch - start}ms'
          : 'N/A';
      final requestId = response.requestOptions.extra['request_id'] ?? 'N/A';

      log('''
╔════════════════════════════════════════════════════════════
║ ✅ RESPONSE
║ ID       : $requestId
║ Status   : ${response.statusCode}
║ Duration : $duration
║ URL      : ${response.requestOptions.uri}
║ Data     : ${_cleanData(_parseData(response.data))}
╚════════════════════════════════════════════════════════════
      ''');
    }
    return handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    if (isDebug) {
      final start = err.requestOptions.extra['request_start'] as int?;
      final duration = start != null
          ? '${DateTime.now().millisecondsSinceEpoch - start}ms'
          : 'N/A';
      final requestId = err.requestOptions.extra['request_id'] ?? 'N/A';

      log('''
╔════════════════════════════════════════════════════════════
║ ❌ ERROR
║ ID       : $requestId
║ Duration : $duration
║ Type     : ${err.type}
║ URL      : ${err.requestOptions.uri}
║ Message  : ${err.message}
║ Response : ${_cleanData(_parseData(err.response?.data))}
╚════════════════════════════════════════════════════════════
      ''');
    }
    return handler.next(err);
  }

  /// Helper method to log custom service requests (e.g. Supabase, Firebase, etc.)
  static void logAction({
    required String title,
    required String action,
    Map<String, dynamic>? data,
  }) {
    print('''
╔════════════════════════════════════════════════════════════
║ 🚀 $title
║ Action : $action
║ Time   : ${DateTime.now().toIso8601String()}
${data != null && data.isNotEmpty ? '║ Data   : $data\n' : ''}╚════════════════════════════════════════════════════════════
    ''');
  }

  /// Helper method to log custom service successes
  static void logSuccess({
    required String title,
    required String action,
    dynamic data,
  }) {
    print('''
╔════════════════════════════════════════════════════════════
║ ✅ $title SUCCESS
║ Action : $action
${data != null ? '║ Result : $data\n' : ''}╚════════════════════════════════════════════════════════════
    ''');
  }

  /// Helper method to log custom service errors
  static void logFailure({
    required String title,
    required String action,
    required dynamic error,
  }) {
    print('''
╔════════════════════════════════════════════════════════════
║ ❌ $title ERROR
║ Action  : $action
║ Message : $error
╚════════════════════════════════════════════════════════════
    ''');
  }
}

