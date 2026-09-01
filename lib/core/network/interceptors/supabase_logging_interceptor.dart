import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// HTTP Interceptor Client specifically for Supabase requests (Auth, PostgREST, Storage, Functions)
class SupabaseLoggingClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  final bool isDebug;

  SupabaseLoggingClient({this.isDebug = true});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (!isDebug || !kDebugMode) {
      return _inner.send(request);
    }

    final startTime = DateTime.now();
    final requestId = 'SUPA-${request.method}-${DateTime.now().millisecondsSinceEpoch}';

    String? requestBody;
    if (request is http.Request) {
      requestBody = request.body;
    }

    // 1. Log Request
    _logRequest(
      id: requestId,
      method: request.method,
      url: request.url.toString(),
      headers: request.headers,
      body: requestBody,
    );

    try {
      final streamedResponse = await _inner.send(request);
      final responseBytes = await streamedResponse.stream.toBytes();
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      final responseBody = utf8.decode(responseBytes, allowMalformed: true);

      // 2. Log Response or Error based on Status Code
      if (streamedResponse.statusCode >= 400) {
        _logError(
          id: requestId,
          statusCode: streamedResponse.statusCode,
          durationMs: duration,
          url: request.url.toString(),
          responseBody: responseBody,
        );
      } else {
        _logResponse(
          id: requestId,
          statusCode: streamedResponse.statusCode,
          durationMs: duration,
          url: request.url.toString(),
          responseBody: responseBody,
        );
      }

      // Re-create the StreamedResponse so Supabase SDK can consume it
      return http.StreamedResponse(
        http.ByteStream.fromBytes(responseBytes),
        streamedResponse.statusCode,
        contentLength: streamedResponse.contentLength,
        request: streamedResponse.request,
        headers: streamedResponse.headers,
        isRedirect: streamedResponse.isRedirect,
        persistentConnection: streamedResponse.persistentConnection,
        reasonPhrase: streamedResponse.reasonPhrase,
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      _logError(
        id: requestId,
        statusCode: 0,
        durationMs: duration,
        url: request.url.toString(),
        responseBody: 'Exception occurred: $e',
      );
      rethrow;
    }
  }

  void _logRequest({
    required String id,
    required String method,
    required String url,
    required Map<String, String> headers,
    String? body,
  }) {
    final sanitizedHeaders = Map<String, String>.from(headers);
    if (sanitizedHeaders.containsKey('apikey')) {
      sanitizedHeaders['apikey'] = '[SUPABASE_APIKEY_HIDDEN]';
    }
    if (sanitizedHeaders.containsKey('authorization')) {
      sanitizedHeaders['authorization'] = '[AUTH_TOKEN_HIDDEN]';
    }

    dynamic parsedBody = body;
    if (body != null && body.isNotEmpty) {
      try {
        parsedBody = jsonDecode(body);
      } catch (_) {
        parsedBody = body;
      }
    }

    debugPrint('''
╔════════════════════════════════════════════════════════════
║ ⚡ [SUPABASE] 🚀 REQUEST
║ ID      : $id
║ Method  : $method
║ URL     : $url
║ Headers : $sanitizedHeaders
║ Body    : $parsedBody
╚════════════════════════════════════════════════════════════
''');
  }

  void _logResponse({
    required String id,
    required int statusCode,
    required int durationMs,
    required String url,
    required String responseBody,
  }) {
    dynamic parsedBody = responseBody;
    if (responseBody.isNotEmpty) {
      try {
        parsedBody = jsonDecode(responseBody);
      } catch (_) {
        parsedBody = responseBody;
      }
    }

    debugPrint('''
╔════════════════════════════════════════════════════════════
║ ⚡ [SUPABASE] ✅ RESPONSE
║ ID       : $id
║ Status   : $statusCode
║ Duration : ${durationMs}ms
║ URL      : $url
║ Data     : $parsedBody
╚════════════════════════════════════════════════════════════
''');
  }

  void _logError({
    required String id,
    required int statusCode,
    required int durationMs,
    required String url,
    required String responseBody,
  }) {
    dynamic parsedBody = responseBody;
    if (responseBody.isNotEmpty) {
      try {
        parsedBody = jsonDecode(responseBody);
      } catch (_) {
        parsedBody = responseBody;
      }
    }

    debugPrint('''
╔════════════════════════════════════════════════════════════
║ ⚡ [SUPABASE] ❌ ERROR
║ ID       : $id
║ Status   : $statusCode
║ Duration : ${durationMs}ms
║ URL      : $url
║ Response : $parsedBody
╚════════════════════════════════════════════════════════════
''');
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
