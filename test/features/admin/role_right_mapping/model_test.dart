import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/role_right_mapping/model.dart";
import "package:wcas_frontend/features/admin/role_right_mapping/state.dart";
import "package:wcas_frontend/models/admin/access_right.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";
import "package:wcas_frontend/repositories/draft_repository.dart";

import "../../../test_config.dart";

class MockAdminRepository extends Mock implements AdminRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockDraftRepository extends Mock implements DraftRepository {}

class FakeAccessRight extends Fake implements AccessRight {}

class FakeReference extends Fake implements Reference {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  const MethodChannel oldConnectivityChannel = MethodChannel(
    "plugins.flutter.io/connectivity",
  );

  late RoleRightMappingViewModel viewModel;
  late MockAdminRepository mockRepo;
  late MockReferenceDataService mockRefService;
  late MockAlertManager mockAlert;
  late MockDraftRepository mockDraftRepository;

  void stubConnectivity() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall methodCall) async {
        if (methodCall.method == "check") {
          return <String>["wifi"];
        }
        return null;
      },
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      oldConnectivityChannel,
      (MethodCall methodCall) async {
        if (methodCall.method == "check") {
          return "wifi";
        }
        return null;
      },
    );
  }

  void stubDraftRepository() {
    when(
      () => mockDraftRepository.deleteDraft(
        module: any(named: "module"),
        screen: any(named: "screen"),
      ),
    ).thenAnswer((_) async {});

    when(
      () => mockDraftRepository.saveDraft(
        module: any(named: "module"),
        screen: any(named: "screen"),
        draftJson: any(named: "draftJson"),
      ),
    ).thenAnswer((_) async {});

    when(
      () => mockDraftRepository.getDraft(
        module: any(named: "module"),
        screen: any(named: "screen"),
      ),
    ).thenAnswer((_) async => null);
  }

  setUpAll(() async {
    registerFallbackValue(FakeAccessRight());
    registerFallbackValue(FakeReference());

    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();
  });

  setUp(() {
    mockRepo = MockAdminRepository();
    mockRefService = MockReferenceDataService();
    mockAlert = MockAlertManager();
    mockDraftRepository = MockDraftRepository();

    stubConnectivity();

    ReferenceDataService.overrideInstance = mockRefService;
    AlertManager.overrideInstance = mockAlert;
    DraftRepository.overrideInstance = mockDraftRepository;

    stubDraftRepository();

    when(() => mockRefService.getReferenceData(any()))
        .thenAnswer((_) async => {});

    when(() => mockAlert.showSuccessToast(any())).thenReturn(null);
    when(() => mockAlert.showFailureToast(any())).thenReturn(null);

    viewModel = RoleRightMappingViewModel()..repository = mockRepo;
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(oldConnectivityChannel, null);

    if (!viewModel.isClosed) {
      await viewModel.close();
    }
  });

  group("init", () {
    test("init should call getReferenceData", () async {
      when(() => mockRefService.getReferenceData(any()))
          .thenAnswer((_) async => {});

      await viewModel.init(null);

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("getReferenceData", () {
    test("getReferenceData success full", () async {
      when(() => mockRefService.getReferenceData(any()))
          .thenAnswer((_) async => {});

      await viewModel.getReferenceData();

      expect(viewModel.roles, isNull);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("getReferenceData failure", () async {
      when(() => mockRefService.getReferenceData(any()))
          .thenThrow(Exception("reference failed"));

      await viewModel.getReferenceData();

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });
  });

  group("role and request selection", () {
    test("onRoleSelected triggers getAccessRights", () async {
      final role = Reference(name: "Admin");
      final request = Reference(name: "Req");

      viewModel.selectedRequestType = request;

      when(() => mockRepo.getAccessRights(role, request))
          .thenAnswer((_) async => AccessRight(pages: []));

      await viewModel.onRoleSelected(role);

      expect(viewModel.selectedRole, role);
      expect(viewModel.state.referencesLoaderStatus, LoadingStatus.loaded);
    });

    test("onRequestTypeSelected triggers getAccessRights", () async {
      final role = Reference(name: "Admin");
      final request = Reference(name: "Req");

      viewModel.selectedRole = role;

      when(() => mockRepo.getAccessRights(role, request))
          .thenAnswer((_) async => AccessRight(pages: []));

      await viewModel.onRequestTypeSelected(request);

      expect(viewModel.selectedRequestType, request);
      expect(viewModel.state.referencesLoaderStatus, LoadingStatus.loaded);
    });
  });

  group("getAccessRights", () {
    test("getAccessRights success", () async {
      final role = Reference(name: "Admin");
      final request = Reference(name: "Req");
      final access = AccessRight(pages: []);

      viewModel
        ..selectedRole = role
        ..selectedRequestType = request;

      when(() => mockRepo.getAccessRights(role, request))
          .thenAnswer((_) async => access);

      await viewModel.getAccessRights();

      expect(viewModel.accessRight, access);
      expect(viewModel.updatedAccessRight, access);
      expect(viewModel.state.referencesLoaderStatus, LoadingStatus.loaded);
    });

    test("getAccessRights failure", () async {
      final role = Reference(name: "Admin");
      final request = Reference(name: "Req");

      viewModel
        ..selectedRole = role
        ..selectedRequestType = request;

      when(() => mockRepo.getAccessRights(role, request))
          .thenThrow(Exception("access failed"));

      await viewModel.getAccessRights();

      expect(viewModel.state.referencesLoaderStatus, LoadingStatus.error);
    });
  });

  group("removeNullPages", () {
    test("removeNullPages with pages null", () {
      final access = AccessRight();

      viewModel
        ..accessRight = access
        ..removeNullPages();

      expect(viewModel.updatedAccessRight, access);
    });
  });

  group("isAccessRightUpdated", () {
    test("isAccessRightUpdated returns true for subType difference", () {
      viewModel
        ..accessRight = AccessRight(subType: "A", pages: [])
        ..updatedAccessRight = AccessRight(subType: "B", pages: []);

      expect(viewModel.isAccessRightUpdated(), true);
    });

    test("isAccessRightUpdated returns false for same access right", () {
      final access = AccessRight(subType: "A", pages: []);

      viewModel
        ..accessRight = access
        ..updatedAccessRight = access;

      expect(viewModel.isAccessRightUpdated(), false);
    });
  });

  group("onSave", () {
    test("onSave success", () async {
      final role = Reference(name: "Admin");
      final request = Reference(name: "Req");
      final access = AccessRight(pages: []);

      viewModel
        ..selectedRole = role
        ..selectedRequestType = request
        ..accessRight = access
        ..updatedAccessRight = access;

      when(
        () => mockRepo.saveAccessRights(
          request,
          role,
          access,
          isUpdate: any(named: "isUpdate"),
        ),
      ).thenAnswer((_) async => "success");

      await viewModel.onSave();
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.saveReferenceStatus, LoadingStatus.loaded);

      verify(
        () => mockRepo.saveAccessRights(
          request,
          role,
          access,
          isUpdate: any(named: "isUpdate"),
        ),
      ).called(1);

      verify(() => mockAlert.showSuccessToast(any())).called(1);

      verify(
        () => mockDraftRepository.deleteDraft(
          module: any(named: "module"),
          screen: any(named: "screen"),
        ),
      ).called(1);
    });

    test("onSave failure", () async {
      final role = Reference(name: "Admin");
      final request = Reference(name: "Req");
      final access = AccessRight(pages: []);

      viewModel
        ..selectedRole = role
        ..selectedRequestType = request
        ..accessRight = access
        ..updatedAccessRight = access;

      when(
        () => mockRepo.saveAccessRights(
          request,
          role,
          access,
          isUpdate: any(named: "isUpdate"),
        ),
      ).thenThrow(Exception("save failed"));

      await viewModel.onSave();
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.saveReferenceStatus, LoadingStatus.loaded);

      verifyNever(
        () => mockDraftRepository.deleteDraft(
          module: any(named: "module"),
          screen: any(named: "screen"),
        ),
      );
    });
  });

  group("close", () {
    test("close should not throw", () async {
      await viewModel.close();

      expect(viewModel.isClosed, isTrue);
    });
  });

  group("RoleRightMappingState", () {
    test("copyWith updates loaderStatus", () {
      final state = RoleRightMappingState(
        loaderStatus: LoadingStatus.loading,
      );

      final copied = state.copyWith(
        loaderStatus: LoadingStatus.loaded,
      );

      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith keeps existing values when nothing provided", () {
      final state = RoleRightMappingState(
        loaderStatus: LoadingStatus.loading,
        referencesLoaderStatus: LoadingStatus.loaded,
        saveReferenceStatus: LoadingStatus.error,
      );

      final copied = state.copyWith();

      expect(copied.loaderStatus, LoadingStatus.loading);
      expect(copied.referencesLoaderStatus, LoadingStatus.loaded);
      expect(copied.saveReferenceStatus, LoadingStatus.error);
    });

    test("copyWith updates all statuses", () {
      final state = RoleRightMappingState(
        loaderStatus: LoadingStatus.loading,
        referencesLoaderStatus: LoadingStatus.loading,
        saveReferenceStatus: LoadingStatus.loading,
      );

      final copied = state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        referencesLoaderStatus: LoadingStatus.error,
        saveReferenceStatus: LoadingStatus.loaded,
      );

      expect(copied.loaderStatus, LoadingStatus.loaded);
      expect(copied.referencesLoaderStatus, LoadingStatus.error);
      expect(copied.saveReferenceStatus, LoadingStatus.loaded);
    });
  });

  group("initial properties", () {
    test("initial properties", () {
      expect(viewModel.roles, isEmpty);
      expect(viewModel.requestTypes, isEmpty);
      expect(viewModel.selectedRole, isNull);
      expect(viewModel.selectedRequestType, isNull);
    });
  });
}
