import "dart:convert";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
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
import "package:wcas_frontend/features/auth/splash/model.dart";

class MockAlertManager extends Mock implements AlertManager {}

class MockGoRouter extends Mock implements GoRouter {}

class MockStorage extends Mock implements StorageInterface {}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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

    // Mock local storage fully to avoid platform channel exceptions and let
    // loginWithSSO succeed
    when(() => mockStorage.clearBox(any())).thenAnswer((_) async {});
    when(() => mockStorage.put(any(), any(), any())).thenAnswer((_) async {});
    when(() => mockStorage.get(any(), any())).thenAnswer((_) async => null);
    when(() => mockStorage.delete(any(), any())).thenAnswer((_) async {});
    LocalStorageService().setStorage(mockStorage);

    originalRouter = router;
    router = mockRouter;

    viewModel = SplashViewModel();
    AlertManager.overrideInstance(mockAlertManager);
    Globals.user = null;
    Globals.sessionID = "";
  });

  tearDown(() {
    router = originalRouter;
    SessionCubit.instance.stopSession();
  });

  group("SplashViewModel Tests", () {
    test("Init without SSO enabled redirects to login", () async {
      EnvConfig.setConfigForTesting({"isSSOEnabled": false});
      when(() => mockRouter.go(Routes.login)).thenReturn(null);

      await viewModel.init({});

      verify(() => mockRouter.go(Routes.login)).called(1);
    });

    test("Init with sso_error redirects to login and shows failure toast",
        () async {
      EnvConfig.setConfigForTesting({"isSSOEnabled": true});
      when(() => mockRouter.go(Routes.login)).thenReturn(null);
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      await viewModel.init({"sso_error": "true"});

      verify(
        () => mockAlertManager
            .showFailureToast("auth.login.errorMessageSSO".tr()),
      ).called(1);
      verify(() => mockRouter.go(Routes.login)).called(1);
    });

    test("Init without query params calls redirect fallback when web is false",
        () async {
      EnvConfig.setConfigForTesting(
        {"isSSOEnabled": true, "ssoUrl": "mockUrl"},
      );
      when(() => mockRouter.go(Routes.login)).thenReturn(null);

      // Since kIsWeb is false in tests by default, it hits the fallback
      await viewModel.init({});

      verify(() => mockRouter.go(Routes.login)).called(1);
    });

    test(
        "Init with invalid tokenResponse (missing"
        " userResponse) throws and goes to login", () async {
      EnvConfig.setConfigForTesting({"isSSOEnabled": true});
      when(() => mockRouter.go(Routes.login)).thenReturn(null);
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      await viewModel.init({"tokenResponse": "{}"});

      verify(
        () => mockAlertManager.showFailureToast(
          "auth.login.errorMessageInvalidResponse".tr(),
        ),
      ).called(1);
      verify(() => mockRouter.go(Routes.login)).called(1);
    });

    test("handleTokenFound successful login with single role redirects to home",
        () async {
      EnvConfig.setConfigForTesting({"isSSOEnabled": true});
      when(() => mockRouter.go(Routes.home)).thenReturn(null);
      when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);

      final tokenResponse = {
        "jwtToken": "123",
        "refreshToken": "123",
        "expiresIn": 3600,
      };
      final userResponse = {
        "userID": "testUser",
        "userName": "Test User",
        "emailID": "test@test.com",
        "segmentList": ["Segment1"],
        "roleList": [
          {"roleID": 1, "role": "role1", "bpmRole": "bpm1"},
        ],
      };

      await viewModel.init({
        "tokenResponse": jsonEncode(tokenResponse),
        "userResponse": jsonEncode(userResponse),
        "sessionID": "mock_session_id",
      });

      expect(Globals.sessionID, "mock_session_id");
      verify(() => mockAlertManager.showSuccessToast("auth.login.success".tr()))
          .called(1);
      verify(() => mockRouter.go(Routes.home)).called(1);
    });

    test(
        "handleTokenFound "
        "successful login with "
        "NO roles throws and goes to login", () async {
      EnvConfig.setConfigForTesting({"isSSOEnabled": true});
      when(() => mockRouter.go(Routes.login)).thenReturn(null);
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      final tokenResponse = {
        "jwtToken": "123",
        "refreshToken": "123",
        "expiresIn": 3600,
      };
      final userResponse = {
        "userID": "testUser",
        "userName": "Test User",
        "emailID": "test@test.com",
        "segmentList": [],
        "roleList": [],
      };

      await viewModel.init({
        "tokenResponse": jsonEncode(tokenResponse),
        "userResponse": jsonEncode(userResponse),
        "sessionID": "mock_session_id",
      });

      verify(
        () => mockAlertManager
            .showFailureToast("auth.login.errorMessageNoRoles".tr()),
      ).called(1);
      verify(() => mockRouter.go(Routes.login)).called(1);
    });

    test("handleTokenFound with multiple roles redirects to selectRole",
        () async {
      EnvConfig.setConfigForTesting({"isSSOEnabled": true});
      when(() => mockRouter.go(Routes.selectRole)).thenReturn(null);
      when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);

      final tokenResponse = {
        "jwtToken": "123",
        "refreshToken": "123",
        "expiresIn": 3600,
      };
      final userResponse = {
        "userID": "testUser",
        "userName": "Test User",
        "emailID": "test@test.com",
        "segmentList": ["Segment1"],
        "roleList": [
          {"roleID": 1, "role": "role1", "bpmRole": "bpm1"},
          {"roleID": 2, "role": "role2", "bpmRole": "bpm2"},
        ],
      };

      await viewModel.init({
        "tokenResponse": jsonEncode(tokenResponse),
        "userResponse": jsonEncode(userResponse),
        "sessionID": "mock_session_id",
      });

      verify(() => mockAlertManager.showSuccessToast("auth.login.success".tr()))
          .called(1);
      verify(() => mockRouter.go(Routes.selectRole)).called(1);
    });

    test("handleTokenFound API/JSON exception goes to login", () async {
      EnvConfig.setConfigForTesting({"isSSOEnabled": true});
      when(() => mockRouter.go(Routes.login)).thenReturn(null);
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      // Invalid json format throws exception internally during decode
      await viewModel.init(
        {"tokenResponse": "invalid json", "userResponse": "invalid json"},
      );

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      verify(() => mockRouter.go(Routes.login)).called(1);
    });
  });
}
