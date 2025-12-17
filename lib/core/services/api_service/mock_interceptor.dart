import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class MockInterceptor extends Interceptor {
  static const String mockPrefix = 'mock/';

  // Allow override for testing
  final bool? _overrideUseMock;

  MockInterceptor({bool? overrideUseMock}) : _overrideUseMock = overrideUseMock;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final path = options.path;

    final shouldUseMock = _overrideUseMock ?? true;

    if (shouldUseMock) {
      try {
        final mockResponse = await _getMockResponse(path, options);
        handler.resolve(mockResponse);
      } catch (e) {
        handler.reject(
          DioException(
            requestOptions: options,
            error: 'Mock file not found or invalid: $e',
            type: DioExceptionType.unknown,
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
      statusMessage: 'OK',
      headers: Headers.fromMap({
        'content-type': ['application/json'],
      }),
    );
  }

  String _extractFileName(String path) {
    String fileName = path.replaceFirst(mockPrefix, '');

    // Convert slashes to underscores for nested paths
    fileName = fileName.replaceAll('/', '_');

    if (!fileName.endsWith('.json')) {
      fileName = '$fileName.json';
    }

    return fileName;
  }

  Future<dynamic> _loadMockData(String fileName) async {
    final assetPath = 'assets/mocks/$fileName';

    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final jsonData = json.decode(jsonString);

      return jsonData;
    } catch (e) {
      throw Exception('Failed to load mock file: $assetPath. Error: $e');
    }
  }
}
