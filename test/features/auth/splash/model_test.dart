import "dart:convert";

import "package:easy_localization/easy_localization.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/services/session/cubit.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/auth/splash/model.dart";

class MockAlertManager extends Mock implements AlertManager {}

class MockGoRouter extends Mock implements GoRouter {}

class MockStorage extends Mock implements StorageInterface {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SplashViewModel viewModel;
  late MockAlertManager mockAlertManager;
  late MockGoRouter mockRouter;
  late MockStorage mockStorage;
  late GoRouter originalRouter;

  setUpAll(() async {
    registerFallbackValue(Uri());
    await EnvConfig.setEnvironment();
  });

  setUp(() {
    mockAlertManager = MockAlertManager();
    mockRouter = MockGoRouter();
    mockStorage = MockStorage();

    when(() => mockRouter.go(any())).thenReturn(null);

    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);

    when(() => mockStorage.clearBox(any())).thenAnswer((_) async {});
    when(() => mockStorage.put(any(), any(), any())).thenAnswer((_) async {});
    when(() => mockStorage.get(any(), any())).thenAnswer((_) async => null);
    when(() => mockStorage.delete(any(), any())).thenAnswer((_) async {});

    LocalStorageService().getStorage = mockStorage;

    originalRouter = router;
    router = mockRouter;

    AlertManager.overrideInstance = mockAlertManager;

    EnvConfig.configForTesting = {};
    Globals.user = null;
    Globals.sessionID = "";

    viewModel = SplashViewModel();
  });

  tearDown(() {
    router = originalRouter;
    Globals.user = null;
    Globals.sessionID = "";
    EnvConfig.configForTesting = {};
    SessionCubit.instance.stopSession();
  });

  String encodeJson(Object value) {
    return base64UrlEncode(utf8.encode(jsonEncode(value))).replaceAll("=", "");
  }

  String encodeRawString(String value) {
    return base64UrlEncode(utf8.encode(value)).replaceAll("=", "");
  }

  Map<String, dynamic> tokenResponse() {
    return {
      "access_token": "mock_access_token",
      "refresh_token": "mock_refresh_token",
      "id_token": "mock_id_token",
      "token_type": "Bearer",
      "expires_in": 3600,
      "accessToken": "mock_access_token",
      "refreshToken": "mock_refresh_token",
      "idToken": "mock_id_token",
      "tokenType": "Bearer",
      "expiresIn": 3600,
      "token": "mock_access_token",
      "refreshTokenExpiresIn": 7200,
      "scope": "openid profile email",
    };
  }

  Map<String, dynamic> role({
    int id = 1,
    String name = "Admin",
  }) {
    return {
      "id": id,
      "roleId": id,
      "roleID": id,
      "code": "ROLE_$id",
      "name": name,
      "roleName": name,
      "description": name,
      "isDefault": true,
    };
  }

  Map<String, dynamic> segment({
    int id = 1,
    String name = "Segment 1",
  }) {
    return {
      "id": id,
      "segmentId": id,
      "segmentID": id,
      "code": "SEGMENT_$id",
      "name": name,
      "segmentName": name,
      "description": name,
    };
  }

  Map<String, dynamic> userResponse({
    List<Map<String, dynamic>>? availableRoles,
    List<Map<String, dynamic>>? segments,
  }) {
    final roles = availableRoles ?? [role()];
    final userSegments = segments ?? [segment()];

    return {
      "id": "user-1",
      "userId": "user-1",
      "userID": "user-1",
      "employeeId": 1,
      "employeeID": 1,
      "username": "test.user",
      "userName": "test.user",
      "name": "Test User",
      "displayName": "Test User",
      "firstName": "Test",
      "lastName": "User",
      "email": "test.user@example.com",
      "mail": "test.user@example.com",
      "mobile": "0500000000",
      "phoneNumber": "0500000000",
      "segments": userSegments,
      "availableRoles": roles,
      "roles": roles,
      "userRoles": roles,
      "role": roles.isNotEmpty ? roles.first : role(),
      "userSegments": userSegments,
      "segment": userSegments.isNotEmpty ? userSegments.first : segment(),
    };
  }

  Map<String, String> validQueryParams({
    List<Map<String, dynamic>>? availableRoles,
    List<Map<String, dynamic>>? segments,
    String? sessionID,
  }) {
    final params = <String, String>{
      "tokenResponse": encodeJson(tokenResponse()),
      "userResponse": encodeJson(
        userResponse(
          availableRoles: availableRoles,
          segments: segments,
        ),
      ),
    };

    if (sessionID != null) {
      params["sessionID"] = sessionID;
    }

    return params;
  }

  void verifyOneNavigationHappened() {
    final capturedRoutes = verify(
      () => mockRouter.go(captureAny()),
    ).captured;

    expect(capturedRoutes.length, 1);
    expect(
      capturedRoutes.single,
      anyOf(
        Routes.login,
        Routes.home,
        Routes.selectRole,
      ),
    );
  }

  group("SplashViewModel Tests", () {
    test("Initial state is loaded", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("Init without SSO enabled redirects to login", () async {
      EnvConfig.configForTesting = {
        "isSSOEnabled": false,
      };

      await viewModel.init({});

      verify(() => mockRouter.go(Routes.login)).called(1);
      verifyNever(() => mockAlertManager.showFailureToast(any()));
      verifyNever(() => mockAlertManager.showSuccessToast(any()));
    });

    test("Init without query params redirects to login fallback when not web",
        () async {
      EnvConfig.configForTesting = {
        "isSSOEnabled": true,
        "ssoUrl": "mockUrl",
      };

      await viewModel.init({});

      verify(() => mockRouter.go(Routes.login)).called(1);
      verifyNever(() => mockAlertManager.showFailureToast(any()));
      verifyNever(() => mockAlertManager.showSuccessToast(any()));
    });

    test("Init with SSO enabled but empty SSO URL redirects to login",
        () async {
      EnvConfig.configForTesting = {
        "isSSOEnabled": true,
        "ssoUrl": "",
      };

      await viewModel.init({});

      verify(() => mockRouter.go(Routes.login)).called(1);
      verifyNever(() => mockAlertManager.showFailureToast(any()));
      verifyNever(() => mockAlertManager.showSuccessToast(any()));
    });

    test("Init with SSO enabled and missing SSO URL redirects to login",
        () async {
      EnvConfig.configForTesting = {
        "isSSOEnabled": true,
      };

      await viewModel.init({});

      verify(() => mockRouter.go(Routes.login)).called(1);
      verifyNever(() => mockAlertManager.showFailureToast(any()));
      verifyNever(() => mockAlertManager.showSuccessToast(any()));
    });

    test("Init with SSO error query param shows toast and redirects to login",
        () async {
      EnvConfig.configForTesting = {
        "isSSOEnabled": true,
      };

      await viewModel.init({
        "error": "access_denied",
      });

      verify(
        () => mockAlertManager.showFailureToast("access denied"),
      ).called(1);
      verify(() => mockRouter.go(Routes.login)).called(1);
      verifyNever(() => mockAlertManager.showSuccessToast(any()));
    });

    test("Init gives priority to error query param over token response",
        () async {
      EnvConfig.configForTesting = {
        "isSSOEnabled": true,
      };

      await viewModel.init({
        "error": "ADFS_UNAVAILABLE",
        "tokenResponse": encodeJson(tokenResponse()),
        "userResponse": encodeJson(userResponse()),
      });

      verify(
        () => mockAlertManager.showFailureToast(
          "auth.login.errorMessageSSO".tr(),
        ),
      ).called(1);
      verify(() => mockRouter.go(Routes.login)).called(1);
      verifyNever(() => mockAlertManager.showSuccessToast(any()));
    });

    test("Init with tokenResponse but missing userResponse goes to login",
        () async {
      EnvConfig.configForTesting = {
        "isSSOEnabled": true,
      };

      await viewModel.init({
        "tokenResponse": encodeJson(tokenResponse()),
      });

      final captured = verify(
        () => mockAlertManager.showFailureToast(captureAny()),
      ).captured.single as String;

      expect(
        captured,
        contains("auth.login.errorMessageInvalidResponse".tr()),
      );

      verify(() => mockRouter.go(Routes.login)).called(1);
      verifyNever(() => mockAlertManager.showSuccessToast(any()));
    });

    test("Init with empty tokenResponse and missing userResponse goes to login",
        () async {
      EnvConfig.configForTesting = {
        "isSSOEnabled": true,
      };

      await viewModel.init({
        "tokenResponse": "",
      });

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      verify(() => mockRouter.go(Routes.login)).called(1);
      verifyNever(() => mockAlertManager.showSuccessToast(any()));
    });

    test("Init with userResponse but no tokenResponse redirects to login",
        () async {
      EnvConfig.configForTesting = {
        "isSSOEnabled": true,
        "ssoUrl": "mockUrl",
      };

      await viewModel.init({
        "userResponse": encodeJson(userResponse()),
      });

      verify(() => mockRouter.go(Routes.login)).called(1);
      verifyNever(() => mockAlertManager.showFailureToast(any()));
      verifyNever(() => mockAlertManager.showSuccessToast(any()));
    });

    test("Init with invalid base64 responses shows failure and goes to login",
        () async {
      EnvConfig.configForTesting = {
        "isSSOEnabled": true,
      };

      await viewModel.init({
        "tokenResponse": "invalid json",
        "userResponse": "invalid json",
      });

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      verify(() => mockRouter.go(Routes.login)).called(1);
      verifyNever(() => mockAlertManager.showSuccessToast(any()));
    });

    test("Init with valid base64 but invalid token JSON goes to login",
        () async {
      EnvConfig.configForTesting = {
        "isSSOEnabled": true,
      };

      await viewModel.init({
        "tokenResponse": encodeRawString("not-json"),
        "userResponse": encodeJson(userResponse()),
      });

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      verify(() => mockRouter.go(Routes.login)).called(1);
      verifyNever(() => mockAlertManager.showSuccessToast(any()));
    });

    test("Init with valid base64 but invalid user JSON goes to login",
        () async {
      EnvConfig.configForTesting = {
        "isSSOEnabled": true,
      };

      await viewModel.init({
        "tokenResponse": encodeJson(tokenResponse()),
        "userResponse": encodeRawString("not-json"),
      });

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      verify(() => mockRouter.go(Routes.login)).called(1);
      verifyNever(() => mockAlertManager.showSuccessToast(any()));
    });

    test("Init with token JSON as array goes to login", () async {
      EnvConfig.configForTesting = {
        "isSSOEnabled": true,
      };

      await viewModel.init({
        "tokenResponse": encodeJson([]),
        "userResponse": encodeJson(userResponse()),
      });

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      verify(() => mockRouter.go(Routes.login)).called(1);
      verifyNever(() => mockAlertManager.showSuccessToast(any()));
    });

    test("Init with user JSON as array goes to login", () async {
      EnvConfig.configForTesting = {
        "isSSOEnabled": true,
      };

      await viewModel.init({
        "tokenResponse": encodeJson(tokenResponse()),
        "userResponse": encodeJson([]),
      });

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      verify(() => mockRouter.go(Routes.login)).called(1);
      verifyNever(() => mockAlertManager.showSuccessToast(any()));
    });

    test("Init with valid-looking SSO response and sessionID navigates once",
        () async {
      EnvConfig.configForTesting = {
        "isSSOEnabled": true,
      };

      await viewModel.init(
        validQueryParams(
          sessionID: "session-123",
          availableRoles: [
            role(),
          ],
          segments: [
            segment(),
          ],
        ),
      );

      expect(Globals.sessionID, "session-123");
      verifyOneNavigationHappened();
    });

    test(
        "Init with valid-looking SSO response and multiple roles navigates once",
        () async {
      EnvConfig.configForTesting = {
        "isSSOEnabled": true,
      };

      await viewModel.init(
        validQueryParams(
          sessionID: "session-456",
          availableRoles: [
            role(),
            role(id: 2, name: "Approver"),
          ],
          segments: [
            segment(),
          ],
        ),
      );

      expect(Globals.sessionID, "session-456");
      verifyOneNavigationHappened();
    });

    test(
        "Init with valid-looking SSO response without sessionID navigates once",
        () async {
      EnvConfig.configForTesting = {
        "isSSOEnabled": true,
      };

      await viewModel.init(
        validQueryParams(
          availableRoles: [
            role(),
          ],
          segments: [
            segment(),
          ],
        ),
      );

      expect(Globals.sessionID, "");
      verifyOneNavigationHappened();
    });

    test(
        "Init with valid-looking SSO response but empty segments navigates once",
        () async {
      EnvConfig.configForTesting = {
        "isSSOEnabled": true,
      };

      await viewModel.init(
        validQueryParams(
          availableRoles: [
            role(),
          ],
          segments: [],
        ),
      );

      verifyOneNavigationHappened();
    });
  });
}
