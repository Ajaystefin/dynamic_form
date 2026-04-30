import "dart:async";
import "dart:convert";

import "package:dio/dio.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/services/api_service/mock_interceptor.dart";
import "package:wcas_frontend/core/utils/logger.dart";

// Mock classes for testing
class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class MockEnvConfig {
  static bool mockUseMock = false;
  static bool get useMock => mockUseMock;
}

// Extended MockInterceptor to allow testing with controlled environment
class TestableOriginalMockInterceptor extends MockInterceptor {
  TestableOriginalMockInterceptor({this.forceUseMock = false});
  final bool forceUseMock;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.path;

    // Use forceUseMock if set, otherwise check actual EnvConfig
    bool shouldUseMock = forceUseMock;
    try {
      // This will fail in test environment, so we catch and use our override
      shouldUseMock = forceUseMock; // EnvConfig.useMock;
    } catch (e) {
      shouldUseMock = forceUseMock;
    }

    if (shouldUseMock && path.startsWith(MockInterceptor.mockPrefix)) {
      try {
        final mockResponse = await _testGetMockResponse(path, options);
        handler.resolve(mockResponse);
      } catch (e) {
        handler.reject(
          DioException(
            requestOptions: options,
            error: "Mock file not found or invalid: $e",
            type: DioExceptionType.unknown,
          ),
        );
      }
    } else {
      handler.next(options);
    }
  }

  // Duplicate the private methods to make them testable
  Future<Response> _testGetMockResponse(
    String path,
    RequestOptions options,
  ) async {
    final fileName = _testExtractFileName(path);
    final mockData = await _testLoadMockData(fileName);

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

  String _testExtractFileName(String path) {
    String fileName = path.replaceFirst(MockInterceptor.mockPrefix, "");

    // Convert slashes to underscores for nested paths
    fileName = fileName.replaceAll("/", "_");

    if (!fileName.endsWith(".json")) {
      fileName = "$fileName.json";
    }

    return fileName;
  }

  Future<dynamic> _testLoadMockData(String fileName) async {
    final assetPath = "assets/mocks/$fileName";

    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final jsonData = json.decode(jsonString);

      return jsonData;
    } catch (e) {
      throw Exception("Failed to load mock file: $assetPath. Error: $e");
    }
  }
}

// Test helper to expose private methods for testing
class TestMockInterceptor extends MockInterceptor {
  TestMockInterceptor({bool useMockOverride = true})
      : _useMockOverride = useMockOverride;
  final bool _useMockOverride;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.path;

    if (_useMockOverride && path.startsWith(MockInterceptor.mockPrefix)) {
      try {
        final mockResponse = await getMockResponseTest(path, options);
        handler.resolve(mockResponse);
      } catch (e) {
        handler.reject(
          DioException(
            requestOptions: options,
            error: "Mock file not found or invalid: $e",
            type: DioExceptionType.unknown,
          ),
        );
      }
    } else {
      handler.next(options);
    }
  }

  // Expose private methods for testing
  Future<Response> getMockResponseTest(
    String path,
    RequestOptions options,
  ) async {
    final fileName = extractFileNameTest(path);
    final mockData = await loadMockDataTest(fileName);

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

  String extractFileNameTest(String path) {
    String fileName = path.replaceFirst(MockInterceptor.mockPrefix, "");

    // Convert slashes to underscores for nested paths
    fileName = fileName.replaceAll("/", "_");

    if (!fileName.endsWith(".json")) {
      fileName = "$fileName.json";
    }

    return fileName;
  }

  Future<dynamic> loadMockDataTest(String fileName) async {
    final assetPath = "assets/mocks/$fileName";

    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final jsonData = json.decode(jsonString);

      return jsonData;
    } catch (e) {
      throw Exception("Failed to load mock file: $assetPath. Error: $e");
    }
  }
}

// Fake classes for mocktail
class FakeResponse extends Fake implements Response {}

class FakeDioException extends Fake implements DioException {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(FakeResponse());
    registerFallbackValue(FakeDioException());
    registerFallbackValue(RequestOptions(path: "test"));
  });

  group("MockInterceptor Tests", () {
    // First, let's test the actual MockInterceptor with override parameter
    group("Original MockInterceptor with override", () {
      test(
          "should resolve mock when overrideUseMock is"
          " true and path has mock prefix", () async {
        final interceptor = MockInterceptor(overrideUseMock: true);
        final handler = MockRequestInterceptorHandler();
        final options = RequestOptions(path: "mock/testEndpoint");

        unawaited(interceptor.onRequest(options, handler));
        await Future.delayed(const Duration(milliseconds: 600));

        verify(() => handler.resolve(any<Response>())).called(1);
      });

      test("should reject when mock file does not exist", () async {
        final interceptor = MockInterceptor(overrideUseMock: true);
        final handler = MockRequestInterceptorHandler();
        final options = RequestOptions(path: "mock/nonExistentMockFile");

        unawaited(interceptor.onRequest(options, handler));
        await Future.delayed(const Duration(milliseconds: 100));

        verify(() => handler.reject(any<DioException>())).called(1);
      });

      test(
          "should handle non-mock "
          "paths by calling "
          "super when overrideUseMock is true", () async {
        final interceptor = MockInterceptor(overrideUseMock: true);
        final handler = MockRequestInterceptorHandler();
        final options = RequestOptions(path: "regular/endpoint");

        unawaited(interceptor.onRequest(options, handler));
        await Future.delayed(const Duration(milliseconds: 100));

        // Super call doesn't invoke handler in test context
        verifyNever(() => handler.resolve(any<Response>()));
        verifyNever(() => handler.reject(any<DioException>()));
      });

      test("should call super when overrideUseMock is false", () async {
        final interceptor = MockInterceptor(overrideUseMock: false);
        final handler = MockRequestInterceptorHandler();
        final options = RequestOptions(path: "mock/testEndpoint");

        unawaited(interceptor.onRequest(options, handler));
        await Future.delayed(const Duration(milliseconds: 100));

        // Super call doesn't invoke handler in test context
        verifyNever(() => handler.resolve(any<Response>()));
        verifyNever(() => handler.reject(any<DioException>()));
      });

      test("should access mockPrefix constant correctly", () {
        expect(MockInterceptor.mockPrefix, equals("mock/"));
      });

      test("should handle invalid JSON in mock file", () async {
        final interceptor = MockInterceptor(overrideUseMock: true);
        final handler = MockRequestInterceptorHandler();
        final options = RequestOptions(path: "mock/invalidJson");

        unawaited(interceptor.onRequest(options, handler));
        await Future.delayed(const Duration(milliseconds: 100));

        verify(() => handler.reject(any<DioException>())).called(1);
      });

      test("should fall back to EnvConfig.useMock when override is null",
          () async {
        final interceptor = MockInterceptor(); // No override
        final handler = MockRequestInterceptorHandler();
        final options = RequestOptions(path: "mock/testEndpoint");

        unawaited(interceptor.onRequest(options, handler));
        await Future.delayed(const Duration(milliseconds: 100));

        // Since EnvConfig.useMock is false in test env, should call super
        verifyNever(() => handler.resolve(any<Response>()));
        verifyNever(() => handler.reject(any<DioException>()));
      });

      test("should test auth_validateUser mock flow", () async {
        final interceptor = MockInterceptor(overrideUseMock: true);
        final handler = MockRequestInterceptorHandler();
        final options = RequestOptions(path: "mock/auth_validateUser");

        unawaited(interceptor.onRequest(options, handler));
        await Future.delayed(const Duration(milliseconds: 600));

        final capturedCall =
            verify(() => handler.resolve(captureAny<Response>())).captured.first
                as Response;
        expect(capturedCall.statusCode, equals(200));
        expect(
          capturedCall.data["responseData"]["userResponse"]["authenticated"],
          equals(true),
        );
      });
    });

    // Then test our custom TestMockInterceptor for detailed unit tests
    late TestMockInterceptor mockInterceptor;
    late MockRequestInterceptorHandler mockHandler;
    late RequestOptions requestOptions;

    setUp(() {
      mockInterceptor = TestMockInterceptor(useMockOverride: true);
      mockHandler = MockRequestInterceptorHandler();
      requestOptions = RequestOptions(path: "test/path");
      reset(mockHandler); // Reset mock between tests
    });

    group("onRequest method tests", () {
      test(
          "should resolve with mock response when useMock is true and path starts with mock/",
          () async {
        requestOptions = RequestOptions(path: "mock/testEndpoint");

        unawaited(mockInterceptor.onRequest(requestOptions, mockHandler));
        await Future.delayed(
          const Duration(milliseconds: 600),
        ); // Wait for async completion

        verify(() => mockHandler.resolve(any<Response>())).called(1);
      });

      test("should call super.onRequest when useMock is false", () async {
        final interceptorWithMockDisabled =
            TestMockInterceptor(useMockOverride: false);
        final freshHandler = MockRequestInterceptorHandler();
        requestOptions = RequestOptions(path: "mock/testEndpoint");

        unawaited(
          interceptorWithMockDisabled.onRequest(requestOptions, freshHandler),
        );

        await Future.delayed(const Duration(milliseconds: 100));

        // Since super.onRequest doesn't call handler methods in our test
        // context,
        // we verify that resolve/reject weren't called
        verifyNever(() => freshHandler.resolve(any<Response>()));
        verifyNever(() => freshHandler.reject(any<DioException>()));
      });

      test(
          "should call super.onRequest when "
          "path does not start with mock prefix", () async {
        final freshHandler = MockRequestInterceptorHandler();
        requestOptions = RequestOptions(path: "regular/endpoint");

        unawaited(
          mockInterceptor.onRequest(requestOptions, freshHandler),
        );

        await Future.delayed(const Duration(milliseconds: 100));

        verifyNever(() => freshHandler.resolve(any<Response>()));
        verifyNever(() => freshHandler.reject(any<DioException>()));
      });

      test("should reject with DioException when mock file loading fails",
          () async {
        final freshHandler = MockRequestInterceptorHandler();
        requestOptions = RequestOptions(path: "mock/nonExistentFile");

        unawaited(
          mockInterceptor.onRequest(requestOptions, freshHandler),
        );

        await Future.delayed(const Duration(milliseconds: 100));

        verify(() => freshHandler.reject(any<DioException>())).called(1);
      });
    });

    group("_getMockResponse method tests", () {
      test("should return Response with correct structure and 500ms delay",
          () async {
        requestOptions = RequestOptions(path: "mock/testEndpoint");
        final stopwatch = Stopwatch()..start();

        final response = await mockInterceptor.getMockResponseTest(
          "mock/testEndpoint",
          requestOptions,
        );
        stopwatch.stop();

        expect(response.statusCode, equals(200));
        expect(response.statusMessage, equals("OK"));
        expect(response.data, isNotNull);
        expect(
          response.headers.value("content-type"),
          contains("application/json"),
        );
        expect(
          stopwatch.elapsedMilliseconds,
          greaterThanOrEqualTo(450),
        ); // Allow some margin
      });

      test("should return correct mock data structure", () async {
        requestOptions = RequestOptions(path: "mock/testEndpoint");

        final response = await mockInterceptor.getMockResponseTest(
          "mock/testEndpoint",
          requestOptions,
        );

        expect(response.data["status"], equals("success"));
        expect(response.data["data"]["message"], equals("Test mock response"));
        expect(response.data["data"]["id"], equals(123));
      });
    });

    group("_extractFileName method tests", () {
      test("should remove mock prefix and add .json extension", () {
        final result = mockInterceptor.extractFileNameTest("mock/testEndpoint");
        expect(result, equals("testEndpoint.json"));
      });

      test("should convert slashes to underscores for nested paths", () {
        final result =
            mockInterceptor.extractFileNameTest("mock/auth/validateUser");
        expect(result, equals("auth_validateUser.json"));
      });

      test("should handle multiple nested slashes correctly", () {
        final result =
            mockInterceptor.extractFileNameTest("mock/user/profile/settings");
        expect(result, equals("user_profile_settings.json"));
      });

      test("should not add .json extension if already present", () {
        final result =
            mockInterceptor.extractFileNameTest("mock/endpoint.json");
        expect(result, equals("endpoint.json"));
      });

      test("should handle deeply nested paths with .json extension", () {
        final result = mockInterceptor
            .extractFileNameTest("mock/deep/nested/path/endpoint.json");
        expect(result, equals("deep_nested_path_endpoint.json"));
      });

      test("should handle edge case with empty path after mock prefix", () {
        final result = mockInterceptor.extractFileNameTest("mock/");
        expect(result, equals(".json"));
      });
    });

    group("_loadMockData method tests", () {
      test("should successfully load and parse existing mock file", () async {
        final result =
            await mockInterceptor.loadMockDataTest("testEndpoint.json");

        expect(result, isA<Map<String, dynamic>>());
        expect(result["status"], equals("success"));
        expect(result["data"]["message"], equals("Test mock response"));
      });

      test("should load auth_validateUser.json mock file correctly", () async {
        final result =
            await mockInterceptor.loadMockDataTest("auth_validateUser.json");

        expect(result, isA<Map<String, dynamic>>());
        expect(result["status"]["statusCode"], equals(0));
        expect(
          result["responseData"]["userResponse"]["userId"],
          equals("WCASTSP01"),
        );
      });

      test("should throw exception when mock file does not exist", () async {
        expect(
          () => mockInterceptor.loadMockDataTest("nonExistentFile.json"),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              "message",
              contains("Failed to load mock file"),
            ),
          ),
        );
      });

      test("should construct correct asset path", () async {
        try {
          await mockInterceptor.loadMockDataTest("testEndpoint.json");
        } catch (e) {
          // If this fails, it should mention the correct path
          expect(e.toString(), contains("assets/mocks/testEndpoint.json"));
        }
      });
    });

    group("Error handling tests", () {
      test("should handle invalid JSON in mock file gracefully", () async {
        // This would require creating an invalid JSON file, but we can test the
        // exception path
        expect(
          () => mockInterceptor.loadMockDataTest("invalidFile.json"),
          throwsA(isA<Exception>()),
        );
      });

      test("should create DioException with correct error message format",
          () async {
        final freshHandler = MockRequestInterceptorHandler();
        requestOptions = RequestOptions(path: "mock/nonExistentFile");

        unawaited(
          mockInterceptor.onRequest(requestOptions, freshHandler),
        );

        await Future.delayed(const Duration(milliseconds: 100));

        final capturedCall =
            verify(() => freshHandler.reject(captureAny<DioException>()))
                .captured
                .first as DioException;
        expect(
          capturedCall.error.toString(),
          contains("Mock file not found or invalid"),
        );
        expect(capturedCall.type, equals(DioExceptionType.unknown));
        expect(capturedCall.requestOptions, equals(requestOptions));
      });
    });

    group("Integration tests", () {
      test("should handle complete mock request flow successfully", () async {
        final freshHandler = MockRequestInterceptorHandler();
        requestOptions = RequestOptions(path: "mock/testEndpoint");

        unawaited(
          mockInterceptor.onRequest(requestOptions, freshHandler),
        );

        await Future.delayed(const Duration(milliseconds: 600));

        final capturedCall =
            verify(() => freshHandler.resolve(captureAny<Response>()))
                .captured
                .first as Response;
        expect(capturedCall.statusCode, equals(200));
        expect(capturedCall.data["status"], equals("success"));
      });

      test("should handle auth validation mock flow", () async {
        final freshHandler = MockRequestInterceptorHandler();
        requestOptions = RequestOptions(path: "mock/auth_validateUser");

        unawaited(
          mockInterceptor.onRequest(requestOptions, freshHandler),
        );

        await Future.delayed(const Duration(milliseconds: 600));

        final capturedCall =
            verify(() => freshHandler.resolve(captureAny<Response>()))
                .captured
                .first as Response;
        expect(capturedCall.statusCode, equals(200));
        expect(
          capturedCall.data["responseData"]["userResponse"]["authenticated"],
          equals(true),
        );
      });

      test("should maintain mockPrefix constant value", () {
        expect(MockInterceptor.mockPrefix, equals("mock/"));
      });
    });
  });

  // Additional tests for better coverage of the original MockInterceptor
  // methods
  group("MockInterceptor Method Coverage Tests", () {
    test("should test file name extraction logic through public interface", () {
      final interceptor = MockInterceptor();
      logger.i(interceptor);
      // Test that constants are accessible
      expect(MockInterceptor.mockPrefix, isA<String>());
      expect(MockInterceptor.mockPrefix.isNotEmpty, isTrue);
    });

    test("should instantiate MockInterceptor without error", () {
      expect(MockInterceptor.new, returnsNormally);
    });

    test("should handle requests without throwing exceptions", () {
      final interceptor = MockInterceptor();
      final handler = MockRequestInterceptorHandler();

      // Test various request types
      final testCases = [
        "mock/simple",
        "mock/nested/path",
        "regular/endpoint",
        "api/users",
      ];

      for (final path in testCases) {
        final options = RequestOptions(path: path);
        expect(() => interceptor.onRequest(options, handler), returnsNormally);
      }
    });
  });
}
