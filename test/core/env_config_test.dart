import "dart:convert";

import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";

class MockAPIManager extends Mock implements APIManager {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAPIManager mockAPIManager;

  setUpAll(() {
    registerFallbackValue(RequestOptions());
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockAPIManager = MockAPIManager();
    EnvConfig.configForTesting = null;
  });

  tearDown(() {
    EnvConfig.configForTesting = null;
  });

  group("EnvConfig.setEnvironment", () {
    test("should load config successfully when response body is Map", () async {
      final configData = <String, dynamic>{
        "baseUrl": "https://map.api.com/",
        "requestTimeoutSeconds": 30,
        "sessionTimeoutSeconds": 700,
        "sessionGracePeriodSeconds": 70,
        "channelID": "MAP",
        "shouldMockReference": false,
        "useTinyMceEditor": true,
        "isSSOEnabled": true,
        "ssoUrl": "https://sso.map.com",
        "spreadSmartUrl": "https://spread.map.com",
        "disableRestriction": true,
      };

      when(
        () => mockAPIManager.get(
          "/config.json",
          additionalHeaders: any(named: "additionalHeaders"),
        ),
      ).thenAnswer(
        (_) async => AppResponse(
          message: "success",
          status: ResponseStatus.success,
          body: configData,
          code: 200,
        ),
      );

      await EnvConfig.setEnvironment(apiManager: mockAPIManager);

      expect(EnvConfig.configForTesting, configData);
      expect(EnvConfig.baseUrl, "https://map.api.com/");
      expect(EnvConfig.requestTimeoutSeconds, 30);
      expect(EnvConfig.sessionTimeoutSeconds, 700);
      expect(EnvConfig.sessionGracePeriodSeconds, 70);
      expect(EnvConfig.channelID, "MAP");
      expect(EnvConfig.shouldMockReference, false);
      expect(EnvConfig.useTinyMceEditor, true);
      expect(EnvConfig.isSSOEnabled, true);
      expect(EnvConfig.ssoUrl, "https://sso.map.com");
      expect(EnvConfig.spreadSmartUrl, "https://spread.map.com");
      expect(EnvConfig.disableRestriction, true);

      final capturedHeaders = verify(
        () => mockAPIManager.get(
          "/config.json",
          additionalHeaders: captureAny(named: "additionalHeaders"),
        ),
      ).captured.single as Map<String, dynamic>;

      expect(
        capturedHeaders["Cache-Control"],
        "no-cache, no-store, must-revalidate",
      );
      expect(capturedHeaders["Pragma"], "no-cache");
      expect(capturedHeaders["Expires"], "0");
    });

    test("should load config successfully when response body is JSON string",
        () async {
      final configData = <String, dynamic>{
        "baseUrl": "https://json.api.com/",
        "requestTimeoutSeconds": 45,
        "sessionTimeoutSeconds": 800,
        "sessionGracePeriodSeconds": 80,
        "channelID": "JSON",
        "shouldMockReference": true,
        "useTinyMceEditor": false,
        "isSSOEnabled": false,
        "ssoUrl": "https://sso.json.com",
        "spreadSmartUrl": "https://spread.json.com",
        "disableRestriction": false,
      };

      when(
        () => mockAPIManager.get(
          "/config.json",
          additionalHeaders: any(named: "additionalHeaders"),
        ),
      ).thenAnswer(
        (_) async => AppResponse(
          message: "success",
          status: ResponseStatus.success,
          body: jsonEncode(configData),
          code: 200,
        ),
      );

      await EnvConfig.setEnvironment(apiManager: mockAPIManager);

      expect(EnvConfig.configForTesting, configData);
      expect(EnvConfig.baseUrl, "https://json.api.com/");
      expect(EnvConfig.requestTimeoutSeconds, 45);
      expect(EnvConfig.sessionTimeoutSeconds, 800);
      expect(EnvConfig.sessionGracePeriodSeconds, 80);
      expect(EnvConfig.channelID, "JSON");
      expect(EnvConfig.shouldMockReference, true);
      expect(EnvConfig.useTinyMceEditor, false);
      expect(EnvConfig.isSSOEnabled, false);
      expect(EnvConfig.ssoUrl, "https://sso.json.com");
      expect(EnvConfig.spreadSmartUrl, "https://spread.json.com");
      expect(EnvConfig.disableRestriction, false);
    });

    test("should keep config null when response status is error", () async {
      when(
        () => mockAPIManager.get(
          "/config.json",
          additionalHeaders: any(named: "additionalHeaders"),
        ),
      ).thenAnswer(
        (_) async => AppResponse(
          message: "error",
          status: ResponseStatus.error,
          body: <String, dynamic>{"channelID": "ERROR"},
          code: 500,
        ),
      );

      await EnvConfig.setEnvironment(apiManager: mockAPIManager);

      expect(EnvConfig.configForTesting, null);
      expect(EnvConfig.channelID, "WCAS");
      expect(EnvConfig.requestTimeoutSeconds, 2000);
    });

    test("should keep config null when success response body is null",
        () async {
      when(
        () => mockAPIManager.get(
          "/config.json",
          additionalHeaders: any(named: "additionalHeaders"),
        ),
      ).thenAnswer(
        (_) async => AppResponse(
          message: "success",
          status: ResponseStatus.success,
          code: 200,
        ),
      );

      await EnvConfig.setEnvironment(apiManager: mockAPIManager);

      expect(EnvConfig.configForTesting, null);
      expect(EnvConfig.channelID, "WCAS");
    });

    test("should catch invalid JSON body and keep defaults", () async {
      when(
        () => mockAPIManager.get(
          "/config.json",
          additionalHeaders: any(named: "additionalHeaders"),
        ),
      ).thenAnswer(
        (_) async => AppResponse(
          message: "success",
          status: ResponseStatus.success,
          body: "{invalid-json",
          code: 200,
        ),
      );

      await EnvConfig.setEnvironment(apiManager: mockAPIManager);

      expect(EnvConfig.configForTesting, null);
      expect(EnvConfig.channelID, "WCAS");
      expect(EnvConfig.requestTimeoutSeconds, 2000);
    });

    test("should catch exception thrown by APIManager", () async {
      when(
        () => mockAPIManager.get(
          "/config.json",
          additionalHeaders: any(named: "additionalHeaders"),
        ),
      ).thenThrow(Exception("Network error"));

      await EnvConfig.setEnvironment(apiManager: mockAPIManager);

      expect(EnvConfig.configForTesting, null);
      expect(EnvConfig.channelID, "WCAS");
    });

    test("should catch DioException thrown by APIManager", () async {
      when(
        () => mockAPIManager.get(
          "/config.json",
          additionalHeaders: any(named: "additionalHeaders"),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: "/config.json"),
          type: DioExceptionType.connectionTimeout,
          message: "timeout",
        ),
      );

      await EnvConfig.setEnvironment(apiManager: mockAPIManager);

      expect(EnvConfig.configForTesting, null);
      expect(EnvConfig.channelID, "WCAS");
    });
  });

  group("EnvConfig.configForTesting", () {
    test("should set and get config directly", () {
      final config = <String, dynamic>{
        "baseUrl": "https://direct.test.com/",
        "channelID": "DIRECT",
      };

      EnvConfig.configForTesting = config;

      expect(EnvConfig.configForTesting, config);
      expect(EnvConfig.baseUrl, "https://direct.test.com/");
      expect(EnvConfig.channelID, "DIRECT");
    });

    test("should reset config to null", () {
      EnvConfig.configForTesting = <String, dynamic>{"channelID": "TEMP"};

      expect(EnvConfig.channelID, "TEMP");

      EnvConfig.configForTesting = null;

      expect(EnvConfig.configForTesting, null);
      expect(EnvConfig.channelID, "WCAS");
    });

    test("should allow empty config map and use fallback getter values", () {
      EnvConfig.configForTesting = <String, dynamic>{};

      expect(EnvConfig.configForTesting, <String, dynamic>{});
      expect(EnvConfig.baseUrl, "https://api.wcas-sit.cbd.dev/wcas/");
      expect(EnvConfig.requestTimeoutSeconds, 2000);
      expect(EnvConfig.sessionTimeoutSeconds, 600);
      expect(EnvConfig.sessionGracePeriodSeconds, 300);
      expect(EnvConfig.channelID, "WCAS");
      expect(EnvConfig.shouldMockReference, true);
      expect(EnvConfig.useTinyMceEditor, false);
      expect(EnvConfig.isSSOEnabled, false);
      expect(EnvConfig.ssoUrl, "");
      expect(EnvConfig.spreadSmartUrl, "");
      expect(EnvConfig.disableRestriction, false);
    });
  });

  group("EnvConfig getters with configured values", () {
    test("should return all configured values", () {
      EnvConfig.configForTesting = <String, dynamic>{
        "baseUrl": "https://configured.com/",
        "requestTimeoutSeconds": 11,
        "sessionTimeoutSeconds": 22,
        "sessionGracePeriodSeconds": 33,
        "channelID": "CONFIGURED",
        "shouldMockReference": false,
        "useTinyMceEditor": true,
        "isSSOEnabled": true,
        "ssoUrl": "https://configured-sso.com",
        "spreadSmartUrl": "https://configured-spread.com",
        "disableRestriction": true,
      };

      expect(EnvConfig.baseUrl, "https://configured.com/");
      expect(EnvConfig.requestTimeoutSeconds, 11);
      expect(EnvConfig.sessionTimeoutSeconds, 22);
      expect(EnvConfig.sessionGracePeriodSeconds, 33);
      expect(EnvConfig.channelID, "CONFIGURED");
      expect(EnvConfig.shouldMockReference, false);
      expect(EnvConfig.useTinyMceEditor, true);
      expect(EnvConfig.isSSOEnabled, true);
      expect(EnvConfig.ssoUrl, "https://configured-sso.com");
      expect(EnvConfig.spreadSmartUrl, "https://configured-spread.com");
      expect(EnvConfig.disableRestriction, true);
    });

    test("should return configured false boolean values", () {
      EnvConfig.configForTesting = <String, dynamic>{
        "shouldMockReference": false,
        "useTinyMceEditor": false,
        "isSSOEnabled": false,
        "disableRestriction": false,
      };

      expect(EnvConfig.shouldMockReference, false);
      expect(EnvConfig.useTinyMceEditor, false);
      expect(EnvConfig.isSSOEnabled, false);
      expect(EnvConfig.disableRestriction, false);
    });

    test("should return configured zero integer values", () {
      EnvConfig.configForTesting = <String, dynamic>{
        "requestTimeoutSeconds": 0,
        "sessionTimeoutSeconds": 0,
        "sessionGracePeriodSeconds": 0,
      };

      expect(EnvConfig.requestTimeoutSeconds, 0);
      expect(EnvConfig.sessionTimeoutSeconds, 0);
      expect(EnvConfig.sessionGracePeriodSeconds, 0);
    });

    test("should return configured empty string values", () {
      EnvConfig.configForTesting = <String, dynamic>{
        "baseUrl": "",
        "channelID": "",
        "ssoUrl": "",
        "spreadSmartUrl": "",
      };

      expect(EnvConfig.baseUrl, "");
      expect(EnvConfig.channelID, "");
      expect(EnvConfig.ssoUrl, "");
      expect(EnvConfig.spreadSmartUrl, "");
    });
  });

  group("EnvConfig getters with null config defaults", () {
    test("baseUrl should return default value when config is null", () {
      EnvConfig.configForTesting = null;

      expect(EnvConfig.baseUrl, "https://api.wcas-sit.cbd.dev/wcas/");
    });

    test(
        "requestTimeoutSeconds should return default value when config is null",
        () {
      EnvConfig.configForTesting = null;

      expect(EnvConfig.requestTimeoutSeconds, 2000);
    });

    test(
        "sessionTimeoutSeconds should return default value when config is null",
        () {
      EnvConfig.configForTesting = null;

      expect(EnvConfig.sessionTimeoutSeconds, 600);
    });

    test(
        "sessionGracePeriodSeconds should return default value when config is null",
        () {
      EnvConfig.configForTesting = null;

      expect(EnvConfig.sessionGracePeriodSeconds, 300);
    });

    test("channelID should return default value when config is null", () {
      EnvConfig.configForTesting = null;

      expect(EnvConfig.channelID, "WCAS");
    });

    test("shouldMockReference should return default value when config is null",
        () {
      EnvConfig.configForTesting = null;

      expect(EnvConfig.shouldMockReference, true);
    });

    test("useTinyMceEditor should return default value when config is null",
        () {
      EnvConfig.configForTesting = null;

      expect(EnvConfig.useTinyMceEditor, false);
    });

    test("isSSOEnabled should return default value when config is null", () {
      EnvConfig.configForTesting = null;

      expect(EnvConfig.isSSOEnabled, false);
    });

    test("ssoUrl should return default value when config is null", () {
      EnvConfig.configForTesting = null;

      expect(EnvConfig.ssoUrl, "");
    });

    test("spreadSmartUrl should return default value when config is null", () {
      EnvConfig.configForTesting = null;

      expect(EnvConfig.spreadSmartUrl, "");
    });

    test("disableRestriction should return default value when config is null",
        () {
      EnvConfig.configForTesting = null;

      expect(EnvConfig.disableRestriction, false);
    });

    test("enableLogging should return bool environment value", () {
      expect(EnvConfig.enableLogging, isA<bool>());
      expect(EnvConfig.enableLogging, false);
    });
  });

  group("EnvConfig partial config fallback behavior", () {
    test("should use configured baseUrl and fallback for missing values", () {
      EnvConfig.configForTesting = <String, dynamic>{
        "baseUrl": "https://partial.com/",
      };

      expect(EnvConfig.baseUrl, "https://partial.com/");
      expect(EnvConfig.requestTimeoutSeconds, 2000);
      expect(EnvConfig.sessionTimeoutSeconds, 600);
      expect(EnvConfig.sessionGracePeriodSeconds, 300);
      expect(EnvConfig.channelID, "WCAS");
    });

    test("should use configured timeouts and fallback for missing strings", () {
      EnvConfig.configForTesting = <String, dynamic>{
        "requestTimeoutSeconds": 101,
        "sessionTimeoutSeconds": 202,
        "sessionGracePeriodSeconds": 303,
      };

      expect(EnvConfig.requestTimeoutSeconds, 101);
      expect(EnvConfig.sessionTimeoutSeconds, 202);
      expect(EnvConfig.sessionGracePeriodSeconds, 303);
      expect(EnvConfig.baseUrl, "https://api.wcas-sit.cbd.dev/wcas/");
      expect(EnvConfig.channelID, "WCAS");
    });

    test("should use configured urls and fallback for missing booleans", () {
      EnvConfig.configForTesting = <String, dynamic>{
        "ssoUrl": "https://partial-sso.com",
        "spreadSmartUrl": "https://partial-spread.com",
      };

      expect(EnvConfig.ssoUrl, "https://partial-sso.com");
      expect(EnvConfig.spreadSmartUrl, "https://partial-spread.com");
      expect(EnvConfig.shouldMockReference, true);
      expect(EnvConfig.useTinyMceEditor, false);
      expect(EnvConfig.isSSOEnabled, false);
      expect(EnvConfig.disableRestriction, false);
    });
  });

  group("EnvConfig getter stability", () {
    test("all getters should be callable without throwing when config is null",
        () {
      EnvConfig.configForTesting = null;

      expect(() => EnvConfig.baseUrl, returnsNormally);
      expect(() => EnvConfig.requestTimeoutSeconds, returnsNormally);
      expect(() => EnvConfig.sessionTimeoutSeconds, returnsNormally);
      expect(() => EnvConfig.sessionGracePeriodSeconds, returnsNormally);
      expect(() => EnvConfig.channelID, returnsNormally);
      expect(() => EnvConfig.shouldMockReference, returnsNormally);
      expect(() => EnvConfig.useTinyMceEditor, returnsNormally);
      expect(() => EnvConfig.isSSOEnabled, returnsNormally);
      expect(() => EnvConfig.ssoUrl, returnsNormally);
      expect(() => EnvConfig.spreadSmartUrl, returnsNormally);
      expect(() => EnvConfig.disableRestriction, returnsNormally);
      expect(() => EnvConfig.enableLogging, returnsNormally);
    });

    test("all getters should return consistent values across multiple calls",
        () {
      EnvConfig.configForTesting = <String, dynamic>{
        "baseUrl": "https://stable.com/",
        "requestTimeoutSeconds": 1,
        "sessionTimeoutSeconds": 2,
        "sessionGracePeriodSeconds": 3,
        "channelID": "STABLE",
        "shouldMockReference": false,
        "useTinyMceEditor": true,
        "isSSOEnabled": true,
        "ssoUrl": "https://stable-sso.com",
        "spreadSmartUrl": "https://stable-spread.com",
        "disableRestriction": true,
      };

      expect(EnvConfig.baseUrl, EnvConfig.baseUrl);
      expect(EnvConfig.requestTimeoutSeconds, EnvConfig.requestTimeoutSeconds);
      expect(EnvConfig.sessionTimeoutSeconds, EnvConfig.sessionTimeoutSeconds);
      expect(
        EnvConfig.sessionGracePeriodSeconds,
        EnvConfig.sessionGracePeriodSeconds,
      );
      expect(EnvConfig.channelID, EnvConfig.channelID);
      expect(EnvConfig.shouldMockReference, EnvConfig.shouldMockReference);
      expect(EnvConfig.useTinyMceEditor, EnvConfig.useTinyMceEditor);
      expect(EnvConfig.isSSOEnabled, EnvConfig.isSSOEnabled);
      expect(EnvConfig.ssoUrl, EnvConfig.ssoUrl);
      expect(EnvConfig.spreadSmartUrl, EnvConfig.spreadSmartUrl);
      expect(EnvConfig.disableRestriction, EnvConfig.disableRestriction);
      expect(EnvConfig.enableLogging, EnvConfig.enableLogging);
    });
  });
}
