import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/auth/select_role/model.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";

import "../../../test_config.dart";

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAlertManager extends Mock implements AlertManager {}

void main() {
  late SelectRoleViewModel viewModel;
  late MockAuthRepository mockRepository;
  late MockAlertManager mockAlertManager;

  setUp(() async {
    mockRepository = MockAuthRepository();
    mockAlertManager = MockAlertManager();
    AlertManager.overrideInstance(mockAlertManager);
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();
    viewModel = SelectRoleViewModel();
    viewModel.repository = mockRepository;
  });

  group("SelectRoleViewModel Tests", () {
    test("Initial state should be loading", () {
      viewModel.init();
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test("selectRole should emit error if no role is selected", () async {
      when(() => mockRepository.changeRole(Role())).thenAnswer((_) async {});
      await viewModel.selectRole();

      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.state.selectRoleStatus, LoadingStatus.loaded);
    });

    test("viewModel properties are properly initialized", () {
      expect(viewModel.repository, mockRepository);
      expect(viewModel.userRole, isNull);
      expect(viewModel.errorMessage, isNull);
    });

    test("check routeAfterRoleChange with different role", () {
      viewModel.routeAfterRoleChange(UserRole.admin);
      viewModel.routeAfterRoleChange(UserRole.boardDirectorProxy);
      viewModel.routeAfterRoleChange(UserRole.icsAdmin);
    });
  });
}
