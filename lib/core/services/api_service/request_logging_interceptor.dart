import "dart:convert";
import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/utils/logger.dart";

/// Request Logging Interceptor
///
/// Logs each request/response body as indented JSON (paste-able into a
/// formatter) into the same buffer `downloadLogs()` exports, instead of
/// dio's field-by-field pretty-printing.
class RequestLoggingInterceptor extends Interceptor {
  @visibleForTesting
  static const String requestStartTimeKey = "requestStartTime";

  static const JsonEncoder _prettyJson =
      JsonEncoder.withIndent("  ", _toEncodableFallback);

  static Object? _toEncodableFallback(Object? object) => object.toString();

  /// File upload/download calls carry raw bytes/FormData — never logged.
  @visibleForTesting
  static bool shouldLogBody(RequestOptions options) =>
      options.responseType != ResponseType.bytes && options.data is! FormData;

  /// Re-encodes Map/List bodies (Dio already JSON-decodes most responses) as
  /// indented JSON. Re-parses String bodies that are themselves JSON text
  /// (e.g. a plainResponse call) so they print indented too; falls back to
  /// the raw string if it isn't valid JSON (e.g. a plain error message).
  /// Never throws: any value that can't be JSON-encoded falls back to its
  /// own `.toString()` via [_toEncodableFallback].
  @visibleForTesting
  static String? formatLoggedBody(Object? data) {
    if (data == null) {
      return null;
    }
    if (data is String) {
      try {
        return _prettyJson.convert(jsonDecode(data));
      } on FormatException {
        return data;
      }
    }
    return _prettyJson.convert(data);
  }

  @visibleForTesting
  static int elapsedMs(RequestOptions options) {
    final int? startTime = options.extra[requestStartTimeKey] as int?;
    return startTime == null
        ? -1
        : DateTime.now().millisecondsSinceEpoch - startTime;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (EnvConfig.enableLogging) {
      options.extra[requestStartTimeKey] =
          DateTime.now().millisecondsSinceEpoch;
      if (shouldLogBody(options)) {
        try {
          final body = formatLoggedBody(options.data);
          logger.i(
            "--> ${options.method} ${options.uri}"
            "${body != null ? '\n$body' : ''}",
          );
        } on Object catch (e) {
          logger.w("Failed to log request body: $e");
        }
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (EnvConfig.enableLogging && shouldLogBody(response.requestOptions)) {
      try {
        final body = formatLoggedBody(response.data);
        logger.i(
          "<-- ${response.statusCode} ${response.requestOptions.method} "
          "${response.requestOptions.uri} "
          "(${elapsedMs(response.requestOptions)}ms)"
          "${body != null ? '\n$body' : ''}",
        );
      } on Object catch (e) {
        logger.w("Failed to log response body: $e");
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (EnvConfig.enableLogging && shouldLogBody(err.requestOptions)) {
      try {
        final body = formatLoggedBody(err.response?.data ?? err.message);
        logger.e(
          "<-- ERROR ${err.response?.statusCode} ${err.requestOptions.method} "
          "${err.requestOptions.uri} (${elapsedMs(err.requestOptions)}ms)"
          "${body != null ? '\n$body' : ''}",
        );
      } on Object catch (e) {
        logger.w("Failed to log error body: $e");
      }
    }
    handler.next(err);
  }
}
