import "dart:convert";
import "package:dio/dio.dart";
import "package:flutter/services.dart";

/// Mock Interceptor
///
/// Intercepts HTTP requests and returns predefined mock responses
/// from local JSON files when mock mode is enabled.
class MockInterceptor extends Interceptor {
  /// Creates a mock interceptor.
  MockInterceptor({bool? overrideUseMock}) : _overrideUseMock = overrideUseMock;

  /// Prefix used to identify mock API requests.
  static const String mockPrefix = "mock/";

  // Allow override for testing
  final bool? _overrideUseMock;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.path;

    final shouldUseMock = _overrideUseMock ?? true;

    if (shouldUseMock && path.startsWith(mockPrefix)) {
      try {
        final mockResponse = await _getMockResponse(path, options);
        handler.resolve(mockResponse);
      } on Object catch (e) {
        handler.reject(
          DioException(
            requestOptions: options,
            error: "Mock file not found or invalid: $e",
          ),
        );
      }
    } else {
      super.onRequest(options, handler);
    }
  }

  Future<Response> _getMockResponse(String path, RequestOptions options) async {
    final fileName = _extractFileName(path);
    final mockData = await _loadMockData(fileName);

    await Future.delayed(const Duration(milliseconds: 500));

    return Response(
      requestOptions: options,
      data: mockData,
      statusCode: 200,
      statusMessage: "OK",
      headers: Headers.fromMap({
        "content-type": ["application/json"],
      }),
    );
  }

  String _extractFileName(String path) {
    String fileName = path.replaceFirst(mockPrefix, "");

    // Convert slashes to underscores for nested paths
    fileName = fileName.replaceAll("/", "_");

    if (!fileName.endsWith(".json")) {
      fileName = "$fileName.json";
    }

    return fileName;
  }

  Future<dynamic> _loadMockData(String fileName) async {
    final assetPath = "assets/mocks/$fileName";

    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final jsonData = json.decode(jsonString);

      return jsonData;
    } on Object catch (e) {
      throw Exception("Failed to load mock file: $assetPath. Error: $e");
    }
  }
}
