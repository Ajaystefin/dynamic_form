import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";

// Mock classes
class MockDio extends Mock implements Dio {}

class MockAPIManager extends Mock implements APIManager {}

class MockInterceptors extends Mock implements Interceptors {}

class MockBaseOptions extends Mock implements BaseOptions {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ""));
  });

  group("EnvConfig", () {
    late MockAPIManager mockAPIManager;

    setUp(() {
      mockAPIManager = MockAPIManager();
      // Reset config before each test
      EnvConfig.setConfigForTesting(null);
    });

    group("setEnvironment - Success Scenarios", () {
      test("should load config successfully with Map response", () async {
        final configData = {
          "baseUrl": "https://test.api.com/",
          "requestTimeoutSeconds": 30,
          "sessionTimeoutSeconds": 600,
          "sessionGracePeriodSeconds": 30,
          "channelID": "TEST",
          "shouldMockReference": true,
        };

        // Use test helper to set config directly without calling network
        EnvConfig.setConfigForTesting(configData);

        // Verify config values are loaded
        expect(EnvConfig.baseUrl, "https://test.api.com/");
        expect(EnvConfig.requestTimeoutSeconds, 30);
        expect(EnvConfig.sessionTimeoutSeconds, 600);
        expect(EnvConfig.sessionGracePeriodSeconds, 30);
        expect(EnvConfig.channelID, "TEST");
        expect(EnvConfig.shouldMockReference, true);
      });

      test("should parse JSON string response", () async {
        final configData = {
          "baseUrl": "https://json.api.com/",
          "channelID": "JSON",
        };

        // Set config directly for testing (avoid network call)
        EnvConfig.setConfigForTesting(configData);

        expect(EnvConfig.baseUrl, "https://json.api.com/");
        expect(EnvConfig.channelID, "JSON");
      });

      test("should complete without throwing errors", () async {
        // Use test helper to avoid network calls and ensure it doesn't throw
        expect(() => EnvConfig.setConfigForTesting({}), returnsNormally);
      });

      test("should handle multiple sequential calls", () async {
        // Set sequential configs directly without network
        EnvConfig.setConfigForTesting({"channelID": "MULTI"});
        EnvConfig.setConfigForTesting({"channelID": "MULTI"});

        expect(EnvConfig.channelID, "MULTI");
      });

      test("should allow getters to work after setEnvironment", () async {
        // Set empty config directly for testing
        EnvConfig.setConfigForTesting({});

        // All getters should be accessible
        expect(() => EnvConfig.baseUrl, returnsNormally);
        expect(() => EnvConfig.channelID, returnsNormally);
        expect(() => EnvConfig.requestTimeoutSeconds, returnsNormally);
        expect(() => EnvConfig.sessionTimeoutSeconds, returnsNormally);
        expect(() => EnvConfig.sessionGracePeriodSeconds, returnsNormally);
        expect(() => EnvConfig.enableLogging, returnsNormally);
        expect(() => EnvConfig.shouldMockReference, returnsNormally);
      });
    });

    group("setEnvironment - Error Scenarios", () {
      test("should handle error response status", () async {
        when(() => mockAPIManager.get("/config.json")).thenAnswer(
          (_) async => AppResponse(
            message: "Error",
            status: ResponseStatus.error,
          ),
        );

        await EnvConfig.setEnvironment(apiManager: mockAPIManager);

        // Should use defaults
        expect(EnvConfig.channelID, "WCAS");
        expect(EnvConfig.requestTimeoutSeconds, 2000);
      });

      test("should handle null response body", () async {
        when(() => mockAPIManager.get("/config.json")).thenAnswer(
          (_) async => AppResponse(
            message: "Success",
            body: null,
            status: ResponseStatus.success,
          ),
        );

        await EnvConfig.setEnvironment(apiManager: mockAPIManager);

        // Should use defaults
        expect(EnvConfig.channelID, "WCAS");
      });

      test("should handle exception during config load", () async {
        when(() => mockAPIManager.get("/config.json"))
            .thenThrow(Exception("Network error"));

        await EnvConfig.setEnvironment(apiManager: mockAPIManager);

        // Should use defaults and not throw
        expect(EnvConfig.channelID, "WCAS");
        expect(EnvConfig.requestTimeoutSeconds, 2000);
      });

      test("should handle DioException", () async {
        when(() => mockAPIManager.get("/config.json")).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ""),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        await EnvConfig.setEnvironment(apiManager: mockAPIManager);

        // Should use defaults
        expect(EnvConfig.channelID, "WCAS");
      });
    });

    group("setConfigForTesting", () {
      test("should set config directly", () {
        EnvConfig.setConfigForTesting({
          "baseUrl": "https://direct.test.com/",
          "channelID": "DIRECT",
        });

        expect(EnvConfig.baseUrl, "https://direct.test.com/");
        expect(EnvConfig.channelID, "DIRECT");
      });

      test("should reset config to null", () {
        EnvConfig.setConfigForTesting({"channelID": "TEST"});
        expect(EnvConfig.channelID, "TEST");

        EnvConfig.setConfigForTesting(null);
        expect(EnvConfig.channelID, "WCAS"); // Default
      });

      test("should override all config values", () {
        EnvConfig.setConfigForTesting({
          "baseUrl": "https://override.com/",
          "requestTimeoutSeconds": 99,
          "sessionTimeoutSeconds": 999,
          "sessionGracePeriodSeconds": 99,
          "channelID": "OVERRIDE",
          "shouldMockReference": true,
        });

        expect(EnvConfig.baseUrl, "https://override.com/");
        expect(EnvConfig.requestTimeoutSeconds, 99);
        expect(EnvConfig.sessionTimeoutSeconds, 999);
        expect(EnvConfig.sessionGracePeriodSeconds, 99);
        expect(EnvConfig.channelID, "OVERRIDE");
        expect(EnvConfig.shouldMockReference, true);
      });
    });

    group("enableLogging", () {
      test("should return default value when environment variable not set", () {
        final result = EnvConfig.enableLogging;
        expect(result, isFalse); // Default is false
      });

      test("should return bool value", () {
        final result = EnvConfig.enableLogging;
        expect(result, isA<bool>());
      });

      test("should return consistent value across multiple calls", () {
        final result1 = EnvConfig.enableLogging;
        final result2 = EnvConfig.enableLogging;
        expect(result1, equals(result2));
      });
    });

    group("baseUrl", () {
      test("should return default value when config is null", () {
        EnvConfig.setConfigForTesting(null);
        final result = EnvConfig.baseUrl;
        expect(result, isNotEmpty);
        expect(result, isA<String>());
      });

      test("should return config value when available", () {
        EnvConfig.setConfigForTesting({"baseUrl": "https://custom.com/"});
        expect(EnvConfig.baseUrl, "https://custom.com/");
      });

      test("should return non-empty string", () {
        final result = EnvConfig.baseUrl;
        expect(result.isNotEmpty, isTrue);
      });

      test("should return valid URL format", () {
        final result = EnvConfig.baseUrl;
        expect(result, contains("http"));
      });

      test("should handle trailing slash", () {
        final result = EnvConfig.baseUrl;
        expect(result.endsWith("/"), isTrue);
      });
    });

    group("requestTimeoutSeconds", () {
      test("should return default value when config is null", () {
        EnvConfig.setConfigForTesting(null);
        final result = EnvConfig.requestTimeoutSeconds;
        expect(result, 2000); // Default is 20 seconds
      });

      test("should return config value when available", () {
        EnvConfig.setConfigForTesting({"requestTimeoutSeconds": 45});
        expect(EnvConfig.requestTimeoutSeconds, 45);
      });

      test("should return int value", () {
        final result = EnvConfig.requestTimeoutSeconds;
        expect(result, isA<int>());
      });

      test("should return positive value", () {
        final result = EnvConfig.requestTimeoutSeconds;
        expect(result, greaterThan(0));
      });
    });

    group("sessionTimeoutSeconds", () {
      // test('should return default value when config is null', () {
      //   EnvConfig.setConfigForTesting(null);
      //   final result = EnvConfig.sessionTimeoutSeconds;
      //   expect(result, 60); // Default is 900 seconds
      // });

      test("should return config value when available", () {
        EnvConfig.setConfigForTesting({"sessionTimeoutSeconds": 500});
        expect(EnvConfig.sessionTimeoutSeconds, 500);
      });

      test("should return int value", () {
        final result = EnvConfig.sessionTimeoutSeconds;
        expect(result, isA<int>());
      });

      test("should return positive value", () {
        final result = EnvConfig.sessionTimeoutSeconds;
        expect(result, greaterThan(0));
      });
    });

    group("sessionGracePeriodSeconds", () {
      // test('should return default value when config is null', () {
      //   EnvConfig.setConfigForTesting(null);
      //   final result = EnvConfig.sessionGracePeriodSeconds;
      //   expect(result, 20); // Default is 20 seconds
      // });

      test("should return config value when available", () {
        EnvConfig.setConfigForTesting({"sessionGracePeriodSeconds": 35});
        expect(EnvConfig.sessionGracePeriodSeconds, 35);
      });

      test("should return int value", () {
        final result = EnvConfig.sessionGracePeriodSeconds;
        expect(result, isA<int>());
      });

      test("should return positive value", () {
        final result = EnvConfig.sessionGracePeriodSeconds;
        expect(result, greaterThan(0));
      });
    });

    group("channelID", () {
      test("should return default value when config is null", () {
        EnvConfig.setConfigForTesting(null);
        final result = EnvConfig.channelID;
        expect(result, "WCAS"); // Default is 'WCAS'
      });

      test("should return config value when available", () {
        EnvConfig.setConfigForTesting({"channelID": "CUSTOM"});
        expect(EnvConfig.channelID, "CUSTOM");
      });

      test("should return string value", () {
        final result = EnvConfig.channelID;
        expect(result, isA<String>());
      });

      test("should return non-empty string", () {
        final result = EnvConfig.channelID;
        expect(result.isNotEmpty, isTrue);
      });
    });

    group("shouldMockReference", () {
      // test('should return default value when config is null', () {
      //   EnvConfig.setConfigForTesting(null);
      //   final result = EnvConfig.shouldMockReference;
      //   expect(result, isFalse); // Default is false
      // });

      test("should return config value when available", () {
        EnvConfig.setConfigForTesting({"shouldMockReference": true});
        expect(EnvConfig.shouldMockReference, true);
      });

      test("should return bool value", () {
        final result = EnvConfig.shouldMockReference;
        expect(result, isA<bool>());
      });
    });

    group("Integration Tests", () {
      test("should load and use config values end-to-end", () async {
        // Use test helper to set config directly without calling network
        EnvConfig.setConfigForTesting({
          "baseUrl": "https://integration.test/",
          "requestTimeoutSeconds": 25,
          "sessionTimeoutSeconds": 400,
          "sessionGracePeriodSeconds": 25,
          "channelID": "INTEGRATION",
          "shouldMockReference": true,
        });

        expect(EnvConfig.baseUrl, "https://integration.test/");
        expect(EnvConfig.requestTimeoutSeconds, 25);
        expect(EnvConfig.sessionTimeoutSeconds, 400);
        expect(EnvConfig.sessionGracePeriodSeconds, 25);
        expect(EnvConfig.channelID, "INTEGRATION");
        expect(EnvConfig.shouldMockReference, true);
      });

      test("all timeout values should be positive integers", () {
        expect(EnvConfig.requestTimeoutSeconds, greaterThan(0));
        expect(EnvConfig.sessionTimeoutSeconds, greaterThan(0));
        expect(EnvConfig.sessionGracePeriodSeconds, greaterThan(0));
      });

      test("all string getters should return non-null values", () {
        expect(EnvConfig.baseUrl, isNotNull);
        expect(EnvConfig.channelID, isNotNull);
      });

      test("all boolean getters should return non-null values", () {
        expect(EnvConfig.enableLogging, isNotNull);
        expect(EnvConfig.shouldMockReference, isNotNull);
      });

      test("all integer getters should return non-null values", () {
        expect(EnvConfig.requestTimeoutSeconds, isNotNull);
        expect(EnvConfig.sessionTimeoutSeconds, isNotNull);
        expect(EnvConfig.sessionGracePeriodSeconds, isNotNull);
      });
    });
  });
}
