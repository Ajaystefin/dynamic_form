import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/auth/login/model.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  late LoginViewModel viewModel;
  late MockAuthRepository mockAuthRepository;
  late MockAlertManager mockAlertManager;
  late MockGoRouter mockGoRouter;

  setUpAll(() async {
    registerFallbackValue(Uri());
    await EnvConfig.setEnvironment();
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockAlertManager = MockAlertManager();
    mockGoRouter = MockGoRouter();

    viewModel = LoginViewModel()..repository = mockAuthRepository;

    AlertManager.overrideInstance = mockAlertManager;
    router = mockGoRouter;
    Globals.user = null;
  });

  group("LoginViewModel Tests", () {
    test("Initial state should be loaded", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("Init method sets loaderStatus to loaded", () async {
      await viewModel.init();
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("Toggle password visibility twice", () {
      viewModel
        ..isPasswordVisible = false
        ..togglePasswordVisibility();
      expect(viewModel.isPasswordVisible, true);
      viewModel.togglePasswordVisibility();
      expect(viewModel.isPasswordVisible, false);
    });

    test("Password input updates state", () {
      viewModel.onPasswordChanged("passw");
      expect(viewModel.hasPasswordInput, true);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("Login using credentials successfully with 1 role", () async {
      const username = "username";
      const password = "password";
      const mockResult = "Success";

      when(
        () => mockAuthRepository.login(username: username, password: password),
      ).thenAnswer((_) async => mockResult);
      when(() => mockAuthRepository.goToLandingScreen())
          .thenAnswer((_) async {});

      Globals.user = User(
        segments: ["Retail"],
        availableRoles: [Role(roleId: 1)],
      );

      viewModel
        ..username = username
        ..password = password;

      await viewModel.onSubmitPressed();

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      verify(() => mockAlertManager.showSuccessToast(mockResult)).called(1);
      verify(() => mockAuthRepository.goToLandingScreen()).called(1);
    });

    test("Login using credentials successfully with multiple roles", () async {
      const username = "username";
      const password = "password";
      const mockResult = "Success";

      when(
        () => mockAuthRepository.login(username: username, password: password),
      ).thenAnswer((_) async => mockResult);

      Globals.user = User(
        segments: ["Retail"],
        availableRoles: [Role(roleId: 1), Role(roleId: 2)],
      );

      viewModel
        ..username = username
        ..password = password;

      await viewModel.onSubmitPressed();

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      verify(() => mockAlertManager.showSuccessToast(mockResult)).called(1);
      verify(() => mockGoRouter.go(any())).called(1);
    });

    test("Login using credentials but no roles", () async {
      const username = "username";
      const password = "password";
      const mockResult = "Success";

      when(
        () => mockAuthRepository.login(username: username, password: password),
      ).thenAnswer((_) async => mockResult);

      Globals.user = User(
        segments: [], // Empty segments means no roles
        availableRoles: [],
      );

      viewModel
        ..username = username
        ..password = password;

      await viewModel.onSubmitPressed();

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("refresh method resets user and router", () {
      Globals.user = User(name: "Test User");
      viewModel
        ..hasNoRoles = true
        ..refresh();

      expect(Globals.user, isNull);
      expect(viewModel.hasNoRoles, false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      verify(() => mockGoRouter.refresh()).called(1);
    });

    test("Login failure shows toast", () async {
      const username = "wrongusername";
      const password = "nopass";

      when(
        () => mockAuthRepository.login(username: username, password: password),
      ).thenThrow(Exception("Failed to load"));

      viewModel
        ..username = username
        ..password = password;

      await viewModel.onSubmitPressed();

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("Submit with empty username and password", () async {
      viewModel
        ..username = ""
        ..password = "";

      await viewModel.onSubmitPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("Whitespace-only username and password", () async {
      viewModel
        ..username = "   "
        ..password = "   ";

      await viewModel.onSubmitPressed();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("Empty username validation", () {
      final String? result = CustomValidator.email("");
      expect(result, "common.validation.emptyEmail".tr());
    });

    test("Invalid email format", () {
      final String? result = CustomValidator.email("invalid-email");
      expect(result, "common.validation.invalidEmail".tr());
    });

    test("Valid username validation", () {
      final String? result = CustomValidator.email("email@email.com");
      expect(result, null);
    });

    test("Empty password validation", () {
      final String? result = CustomValidator.password("");
      expect(result, "common.validation.emptyPassword".tr());
    });

    test("Valid password validation", () {
      final String? result = CustomValidator.requiredField("passwordm");
      expect(result, null);
    });
  });
}
