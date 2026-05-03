import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/role_right_mapping/model.dart";
import "package:wcas_frontend/features/admin/role_right_mapping/state.dart";
import "package:wcas_frontend/models/admin/access_right.dart";
import "package:wcas_frontend/models/admin/page.dart" as model;
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";

import "../../../test_config.dart";

class MockAdminRepository extends Mock implements AdminRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class FakeAccessRight extends Fake implements AccessRight {}

class FakeReference extends Fake implements Reference {}

void main() {
  late RoleRightMappingViewModel viewModel;
  late MockAdminRepository mockAdminRepository;
  late MockReferenceDataService mockReferenceDataService;
  late MockAlertManager mockAlertManager;

  setUpAll(() async {
    mockReferenceDataService = MockReferenceDataService();
    registerFallbackValue(FakeAccessRight());
    registerFallbackValue(FakeReference());
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();
  });
  setUp(() {
    mockAdminRepository = MockAdminRepository();
    mockAlertManager = MockAlertManager();
    viewModel = RoleRightMappingViewModel()..repository = mockAdminRepository;
    AlertManager.overrideInstance(mockAlertManager);
  });

  group("RoleRightMappingViewModel", () {
    test("Initial state should be loading", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test("onSave failure", () async {
      final role = Reference(name: "Admin");
      final request = Reference(name: "RequestA");
      final accessRight = AccessRight(
        role: role.toString(),
        requestType: request.toString(),
        pages: [],
      );

      viewModel
        ..updatedAccessRight = accessRight
        ..accessRight = accessRight;

      when(
        () => mockAdminRepository.saveAccessRights(any(), any(), any(), any()),
      ).thenThrow(Exception("Test error"));

      await viewModel.onSave();

      await Future.delayed(const Duration(milliseconds: 100));

      expect(viewModel.state.saveReferenceStatus, LoadingStatus.loaded);
      verifyNever(
        () => mockAdminRepository.saveAccessRights(any(), any(), any(), any()),
      ).called(0);
    });

    test("copyWith should create new state with updated values", () {
      final initialState = RoleRightMappingState(
        loaderStatus: LoadingStatus.loading,
        referencesLoaderStatus: LoadingStatus.empty,
      );

      final newState = initialState.copyWith(
        loaderStatus: LoadingStatus.loaded,
        referencesLoaderStatus: LoadingStatus.loading,
      );

      expect(newState.loaderStatus, LoadingStatus.loaded);
      expect(newState.referencesLoaderStatus, LoadingStatus.loading);
    });

    test("copyWith should preserve unchanged values", () {
      final initialState = RoleRightMappingState(
        loaderStatus: LoadingStatus.loading,
        referencesLoaderStatus: LoadingStatus.empty,
      );

      final newState = initialState.copyWith(
        loaderStatus: LoadingStatus.loaded,
      );

      expect(newState.loaderStatus, LoadingStatus.loaded);
      expect(newState.referencesLoaderStatus, LoadingStatus.empty);
    });

    test("should handle state transitions correctly", () {
      final initialState = RoleRightMappingState(
        loaderStatus: LoadingStatus.loading,
        referencesLoaderStatus: LoadingStatus.empty,
      );

      final loadingState = initialState.copyWith(
        referencesLoaderStatus: LoadingStatus.loading,
      );
      expect(loadingState.referencesLoaderStatus, LoadingStatus.loading);

      final loadedState = loadingState.copyWith(
        referencesLoaderStatus: LoadingStatus.loaded,
      );
      expect(loadedState.referencesLoaderStatus, LoadingStatus.loaded);

      final errorState = loadedState.copyWith(
        referencesLoaderStatus: LoadingStatus.error,
      );
      expect(errorState.referencesLoaderStatus, LoadingStatus.error);
    });

    test("should handle null referencesLoaderStatus in copyWith", () {
      final initialState = RoleRightMappingState(
        loaderStatus: LoadingStatus.loading,
        referencesLoaderStatus: LoadingStatus.empty,
      );

      final newState = initialState.copyWith(
        referencesLoaderStatus: null,
      );

      expect(newState.referencesLoaderStatus, LoadingStatus.empty);
    });
  });

  test("getReferenceData success", () async {
    final mockData = {
      ReferenceDataKeys.roleType: [
        Reference(name: "Admin"),
        Reference(name: "User"),
      ],
    };

    when(() => mockReferenceDataService.getReferenceData(any()))
        .thenAnswer((_) async => mockData);

    ReferenceDataService.overrideInstance(mockReferenceDataService);

    await viewModel.getReferenceData();

    expect(viewModel.state.loaderStatus, isNot(LoadingStatus.error));
  });

  test("getReferenceData failure should emit error", () async {
    when(() => mockReferenceDataService.getReferenceData(any()))
        .thenThrow(Exception("Failed"));

    ReferenceDataService.overrideInstance(mockReferenceDataService);

    await viewModel.getReferenceData();

    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  test("onRoleSelected sets selectedRole", () {
    final role = Reference(name: "Admin");

    viewModel.onRoleSelected(role);

    expect(viewModel.selectedRole, role);
  });

  test("onRoleSelected does not set selectedRole when name is null", () {
    final role = Reference(name: null);

    viewModel.onRoleSelected(role);

    expect(viewModel.selectedRole, isNull);
  });

  test("onRequestTypeSelected sets selectedRequestType", () {
    final request = Reference(name: "RequestA");

    viewModel.onRequestTypeSelected(request);

    expect(viewModel.selectedRequestType, request);
  });

  test("onRequestTypeSelected does not set when name is null", () {
    final request = Reference(name: null);

    viewModel.onRequestTypeSelected(request);

    expect(viewModel.selectedRequestType, isNull);
  });

  test("getAccessRights failure should emit error", () async {
    final role = Reference(name: "Admin");
    final request = Reference(name: "RequestA");

    viewModel
      ..selectedRole = role
      ..selectedRequestType = request;

    when(() => mockAdminRepository.getAccessRights(role, request))
        .thenThrow(Exception("Failed"));

    await viewModel.getAccessRights();

    expect(viewModel.state.referencesLoaderStatus, LoadingStatus.error);
  });

  test("removeNullPages clones accessRight to updatedAccessRight", () {
    final role = Reference(name: "Admin");
    final request = Reference(name: "RequestA");
    final pages = [
      model.Page(accessType: AccessType.view),
      model.Page(accessType: AccessType.none),
    ];
    final accessRight = AccessRight(
      role: role.toString(),
      requestType: request.toString(),
      pages: pages,
    );

    viewModel
      ..accessRight = accessRight
      ..removeNullPages();

    expect(viewModel.updatedAccessRight, accessRight);
  });

  test("removeNullPages handles null accessRight", () {
    viewModel
      ..accessRight = null
      ..removeNullPages();
    expect(viewModel.updatedAccessRight, isNull);
  });

  test("isAccessRightUpdated returns false when both are null", () {
    viewModel
      ..accessRight = null
      ..updatedAccessRight = null;
    expect(viewModel.isAccessRightUpdated(), false);
  });

  test("isAccessRightUpdated returns true when pages differ", () {
    final role = Reference(name: "Admin");
    final request = Reference(name: "RequestA");

    viewModel
      ..accessRight = AccessRight(
        role: role.toString(),
        requestType: request.toString(),
        pages: [],
      )
      ..updatedAccessRight = AccessRight(
        role: role.toString(),
        requestType: request.toString(),
        pages: [model.Page(accessType: AccessType.view)],
      );

    expect(viewModel.isAccessRightUpdated(), true);
  });

  test("isAccessRightUpdated returns false when objects are identical", () {
    final role = Reference(name: "Admin");
    final request = Reference(name: "RequestA");
    final pages = [model.Page(accessType: AccessType.view)];

    viewModel
      ..accessRight = AccessRight(
        role: role.toString(),
        requestType: request.toString(),
        pages: pages,
      )
      ..updatedAccessRight = AccessRight(
        role: role.toString(),
        requestType: request.toString(),
        pages: pages,
      );

    expect(viewModel.isAccessRightUpdated(), false);
  });

  test("isAccessRightUpdated returns true when role differs", () {
    final request = Reference(name: "RequestA");

    viewModel
      ..accessRight =
          AccessRight(role: "Admin", requestType: request.toString(), pages: [])
      ..updatedAccessRight =
          AccessRight(role: "User", requestType: request.toString(), pages: []);

    expect(viewModel.isAccessRightUpdated(), true);
  });

  test("isAccessRightUpdated returns true when requestType differs", () {
    final role = Reference(name: "Admin");

    viewModel
      ..accessRight =
          AccessRight(role: role.toString(), requestType: "RequestA", pages: [])
      ..updatedAccessRight = AccessRight(
        role: role.toString(),
        requestType: "RequestB",
        pages: [],
      );

    expect(viewModel.isAccessRightUpdated(), true);
  });

  test("viewModel properties are properly initialized", () {
    expect(viewModel.requestTypes, isEmpty);
    expect(viewModel.selectedRequestType, isNull);
    expect(viewModel.selectedRole, isNull);
    expect(viewModel.accessRight, isNull);
    expect(viewModel.updatedAccessRight, isNull);
  });
}
