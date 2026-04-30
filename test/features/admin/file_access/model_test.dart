import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/file_access/draft_handler.dart";
import "package:wcas_frontend/features/admin/file_access/model.dart";
import "package:wcas_frontend/features/admin/file_access/state.dart";
import "package:wcas_frontend/models/admin/file_access.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";

import "../../../test_config.dart";

class MockAdminRepository extends Mock implements AdminRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class FakeReference extends Fake implements Reference {}

class FakeFileAccess extends Fake implements FileAccess {}

/// A testable subclass to intercept DraftMixin-related calls
/// so we can verify coverage without depending on actual draft infrastructure.
class TestFileAccessViewModel extends FileAccessViewModel {
  bool registerDraftCallbackCalled = false;
  bool unregisterDraftCallbackCalled = false;
  bool loadDraftIfAvailableCalled = false;
  bool deleteDraftCalled = false;

  @override
  void registerDraftCallback() {
    registerDraftCallbackCalled = true;
  }

  @override
  void unregisterDraftCallback() {
    unregisterDraftCallbackCalled = true;
  }

  @override
  Future<void> loadDraftIfAvailable() async {
    loadDraftIfAvailableCalled = true;
  }

  @override
  Future<void> deleteDraft() async {
    deleteDraftCalled = true;
  }
}

void main() {
  late TestFileAccessViewModel viewModel;
  late MockAdminRepository mockRepository;
  late MockReferenceDataService mockReferenceDataService;
  late MockAlertManager mockAlertManager;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    registerFallbackValue(FakeReference());
    registerFallbackValue(<FileAccess>[]);
    registerFallbackValue(FakeFileAccess());

    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();
  });

  setUp(() {
    mockRepository = MockAdminRepository();
    mockReferenceDataService = MockReferenceDataService();
    mockAlertManager = MockAlertManager();

    viewModel = TestFileAccessViewModel();
    viewModel.repository = mockRepository;

    ReferenceDataService.overrideInstance(mockReferenceDataService);
    AlertManager.overrideInstance(mockAlertManager);

    // Stub toast methods so verification works cleanly
    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);
  });

  group("FileAccessViewModel - initial and getters", () {
    test("initial state should be loading", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.state.fileAccessStatus, isNull);
      expect(viewModel.state.savingStatus, isNull);
    });

    test("draft-related getters should return expected values", () {
      expect(viewModel.draftModuleKey, DraftModuleKeys.admin);
      expect(viewModel.draftFormKey, Routes.fileAccess);
      expect(viewModel.draftHandler, isA<FileAccessDraftHandler>());
    });

    test("copyWith should update provided values only", () {
      final initialState = FileAccessState(
        loaderStatus: LoadingStatus.loading,
        fileAccessStatus: LoadingStatus.empty,
        savingStatus: LoadingStatus.empty,
      );

      final updatedState = initialState.copyWith(
        loaderStatus: LoadingStatus.loaded,
        fileAccessStatus: LoadingStatus.loading,
      );

      expect(updatedState.loaderStatus, LoadingStatus.loaded);
      expect(updatedState.fileAccessStatus, LoadingStatus.loading);
      expect(updatedState.savingStatus, LoadingStatus.empty);
    });

    test("copyWith should preserve unchanged values", () {
      final initialState = FileAccessState(
        loaderStatus: LoadingStatus.loading,
        fileAccessStatus: LoadingStatus.empty,
      );

      final updatedState = initialState.copyWith(
        loaderStatus: LoadingStatus.loaded,
      );

      expect(updatedState.loaderStatus, LoadingStatus.loaded);
      expect(updatedState.fileAccessStatus, LoadingStatus.empty);
    });

    test("copyWith should handle null fileAccessStatus and preserve old value",
        () {
      final initialState = FileAccessState(
        loaderStatus: LoadingStatus.loading,
        fileAccessStatus: LoadingStatus.empty,
      );

      final updatedState = initialState.copyWith(
        fileAccessStatus: null,
      );

      expect(updatedState.fileAccessStatus, LoadingStatus.empty);
    });
  });

  group("loadReferenceData", () {
    test("should load reference data successfully and filter roles correctly",
        () async {
      final mockData = {
        ReferenceDataKeys.roleType: [
          // should remain (normal role)
          Reference(id: 1, name: "Admin", status: "active"),

          // should remain (id null branch)
          Reference(name: "NoIdRole", status: "active"),

          // should be removed (financial pool maker + active)
          Reference(
            id: ServerConstants.financialPoolMaker,
            name: "Financial Pool Maker",
            status: "active",
          ),

          // should remain (financial pool checker + inactive)
          Reference(
            id: ServerConstants.financialPoolChecker,
            name: "Financial Pool Checker",
            status: "inactive",
          ),

          // should be removed (financial pool coordinator + active)
          Reference(
            id: ServerConstants.financialPoolCoordinator,
            name: "Financial Pool Coordinator",
            status: "active",
          ),
        ],
      };

      when(
        () => mockReferenceDataService
            .getReferenceData([ReferenceDataKeys.roleType]),
      ).thenAnswer((_) async => mockData);

      await viewModel.loadReferenceData();

      expect(viewModel.referenceData, mockData);
      expect(viewModel.state.loaderStatus, isNot(LoadingStatus.error));

      expect(viewModel.roles, isNotNull);
      expect(viewModel.roles!.length, 3);

      expect(
        viewModel.roles!.any((r) => r.name == "Admin"),
        isTrue,
      );
      expect(
        viewModel.roles!.any((r) => r.name == "NoIdRole"),
        isTrue,
      );
      expect(
        viewModel.roles!.any((r) => r.name == "Financial Pool Checker"),
        isTrue,
      );

      expect(
        viewModel.roles!.any((r) => r.name == "Financial Pool Maker"),
        isFalse,
      );
      expect(
        viewModel.roles!.any((r) => r.name == "Financial Pool Coordinator"),
        isFalse,
      );

      verify(
        () => mockReferenceDataService
            .getReferenceData([ReferenceDataKeys.roleType]),
      ).called(1);
    });

    test("should emit error when loadReferenceData fails", () async {
      when(
        () => mockReferenceDataService.getReferenceData(any()),
      ).thenThrow(Exception("Failed to load references"));

      await viewModel.loadReferenceData();

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("init", () {
    test(
        "should call loadReferenceData, register draft"
        " callback and set loaded state", () async {
      final mockData = {
        ReferenceDataKeys.roleType: [
          Reference(id: 1, name: "Admin", status: "active"),
        ],
      };

      when(
        () => mockReferenceDataService
            .getReferenceData([ReferenceDataKeys.roleType]),
      ).thenAnswer((_) async => mockData);

      await viewModel.init(null);

      expect(viewModel.registerDraftCallbackCalled, isTrue);
      expect(viewModel.referenceData, mockData);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("getFileAccess", () {
    testWidgets(
        "should fetch file access "
        "successfully, load "
        "draft, populate children, and emit loaded", (tester) async {
      final selectedRole = Reference(id: 1, name: "Admin", status: "active");
      viewModel.selectedRoleType = selectedRole;

      final child1 = FileAccess(name: "Child 1");
      final parent1 = FileAccess(
        name: "Parent 1",
        children: [child1],
      );
      final parent2 = FileAccess(
        name: "Parent 2",
        children: [],
      );
      final parent3 = FileAccess(name: "Parent 3");

      when(
        () => mockRepository.getFileAttachments(selectedRole),
      ).thenAnswer((_) async => [parent1, parent2, parent3]);

      await viewModel.getFileAccess();

      // Pump one frame so the post-frame callback executes
      await tester.pump();

      expect(viewModel.fileAccesses.length, 3);
      expect(viewModel.fileAccesses.first.name, "Parent 1");
      expect(viewModel.loadDraftIfAvailableCalled, isTrue);

      // firstLevelParentsWithChildren should only include parent1
      expect(viewModel.firstLevelParentsWithChildren.length, 1);
      expect(viewModel.firstLevelParentsWithChildren.first.name, "Parent 1");

      expect(viewModel.state.fileAccessStatus, LoadingStatus.loaded);

      verify(() => mockRepository.getFileAttachments(selectedRole)).called(1);
    });

    test("should emit error when getFileAccess fails", () async {
      final selectedRole = Reference(id: 1, name: "Admin", status: "active");
      viewModel.selectedRoleType = selectedRole;

      when(
        () => mockRepository.getFileAttachments(selectedRole),
      ).thenThrow(Exception("File access fetch failed"));

      await viewModel.getFileAccess();

      expect(viewModel.state.fileAccessStatus, LoadingStatus.error);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("onRoleTypeSelected", () {
    testWidgets(
        "should set selectedRoleType, fetch file access, and set loaded state",
        (tester) async {
      final selectedRole = Reference(id: 1, name: "Admin", status: "active");

      when(
        () => mockRepository.getFileAttachments(selectedRole),
      ).thenAnswer((_) async => []);

      await viewModel.onRoleTypeSelected(selectedRole);
      await tester.pump();

      expect(viewModel.selectedRoleType, selectedRole);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.state.fileAccessStatus, LoadingStatus.loaded);

      verify(() => mockRepository.getFileAttachments(selectedRole)).called(1);
    });
  });

  group("onSave", () {
    test(
        "should save successfully, flatten "
        "children, delete draft, and emit loaded", () async {
      final selectedRole = Reference(id: 1, name: "Admin", status: "active");
      viewModel.selectedRoleType = selectedRole;

      final child1 = FileAccess(name: "Child 1");
      final child2 = FileAccess(name: "Child 2");

      final parent1 = FileAccess(
        name: "Parent 1",
        children: [child1, child2],
      );
      final parent2 = FileAccess(name: "Parent 2");

      viewModel.fileAccesses = [parent1, parent2];

      when(
        () => mockRepository.saveFileAttachments(any(), selectedRole),
      ).thenAnswer((invocation) async {
        final attachments =
            invocation.positionalArguments[0] as List<FileAccess>;

        // parent1 + child1 + child2 + parent2 = 4 flattened items
        expect(attachments.length, 4);
        expect(attachments.map((e) => e.name).toList(), [
          "Parent 1",
          "Child 1",
          "Child 2",
          "Parent 2",
        ]);

        return "Saved successfully";
      });

      await viewModel.onSave();

      expect(viewModel.deleteDraftCalled, isTrue);
      expect(viewModel.state.savingStatus, LoadingStatus.loaded);

      verify(() => mockRepository.saveFileAttachments(any(), selectedRole))
          .called(1);
      verify(() => mockAlertManager.showSuccessToast("Saved successfully"))
          .called(1);
    });

    test(
        "should save successfully with empty "
        "response and not show success toast", () async {
      final selectedRole = Reference(id: 2, name: "User", status: "active");
      viewModel.selectedRoleType = selectedRole;
      viewModel.fileAccesses = [FileAccess(name: "Only File")];

      when(
        () => mockRepository.saveFileAttachments(any(), selectedRole),
      ).thenAnswer((_) async => "");

      await viewModel.onSave();

      expect(viewModel.deleteDraftCalled, isTrue);
      expect(viewModel.state.savingStatus, LoadingStatus.loaded);

      verify(() => mockRepository.saveFileAttachments(any(), selectedRole))
          .called(1);
      verifyNever(() => mockAlertManager.showSuccessToast(any()));
    });

    test("should emit error and show failure toast when save fails", () async {
      final selectedRole = Reference(id: 1, name: "Admin", status: "active");
      viewModel.selectedRoleType = selectedRole;
      viewModel.fileAccesses = [FileAccess(name: "File1")];

      when(
        () => mockRepository.saveFileAttachments(any(), selectedRole),
      ).thenThrow(Exception("Test error"));

      await viewModel.onSave();

      expect(viewModel.state.savingStatus, LoadingStatus.error);
      verify(() => mockRepository.saveFileAttachments(any(), selectedRole))
          .called(1);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("close", () {
    test("should unregister draft callback on close", () async {
      await viewModel.close();
      expect(viewModel.unregisterDraftCallbackCalled, isTrue);
    });
  });
}
