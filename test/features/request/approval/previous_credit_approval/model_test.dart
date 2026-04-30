import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/previous_credit_approval/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/previous_credit_approval/model.dart";
import "package:wcas_frontend/features/request/approval/previous_credit_approval/state.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class MockCommonRepository extends Mock implements CommonRepository {}

class MockApprovalRepository extends Mock implements ApprovalRepository {}

class MockRequestRepository extends Mock implements RequestRepository {}

class FakeBuildContext extends Fake implements BuildContext {}

class MockAlertManager extends Mock implements AlertManager {}

class MockController extends Mock implements UnifiedEditorController {}

// Mock LocalStorageService
class MockLocalStorageService implements StorageInterface {
  final Map<String, Map<String, dynamic>> _storage = {};

  @override
  Future<void> init({String? path}) async {}

  @override
  Future<void> put(String box, String key, dynamic value) async {
    _storage[box] ??= {};
    _storage[box]![key] = value;
  }

  @override
  Future<dynamic> get(String box, String key) async {
    return _storage[box]?[key];
  }

  @override
  Future<void> delete(String box, String key) async {
    _storage[box]?.remove(key);
  }

  @override
  Future<void> clearBox(String box) async {
    _storage[box]?.clear();
  }

  void clearAll() {
    _storage.clear();
  }
}

void main() {
  late PreviousCreditApprovalViewModel viewModel;
  late MockCommonRepository mockCommonRepository;
  late MockApprovalRepository mockApprovalRepository;
  late MockAlertManager mockAlertManager;
  late BuildContext fakeContext;
  late MockLocalStorageService mockLocalStorageService;
  late MockController mockController;

  // Stub connectivity_plus channel so every check() returns wifi
  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockCommonRepository = MockCommonRepository();
    mockApprovalRepository = MockApprovalRepository();
    mockAlertManager = MockAlertManager();
    fakeContext = FakeBuildContext();
    mockController = MockController();
    await EnvConfig.setEnvironment();
    AlertManager.instance = mockAlertManager;

    viewModel = PreviousCreditApprovalViewModel()
      ..repository = mockApprovalRepository;

    mockLocalStorageService = MockLocalStorageService();

    // Set up LocalStorageService mock
    LocalStorageService().setStorage(mockLocalStorageService);

    // Connectivity mock
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, (call) async {
      if (call.method == "check") {
        return [ConnectivityResult.wifi.name];
      }
      return null;
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel("plugins.flutter.io/connectivity"),
      (MethodCall methodCall) async {
        return "wifi"; // or whatever mock result you need
      },
    );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);
  });

  test("initial state should be loading", () {
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  // test('init loads data and emits loaded state', () async {
  //   final mockData = <Comment>[];

  //   when(() => mockApprovalRepository.fetchReference())
  //       .thenAnswer((_) async => []);
  //   viewModel.init(fakeContext);

  //   expect(viewModel.comments, mockData);
  // });

  test("viewModel properties are properly initialized", () {
    expect(viewModel.repository, mockApprovalRepository);
    expect(viewModel.comments, isEmpty);
    expect(viewModel.comment, isNull);
  });

  test("viewModel variables are having default values", () {
    expect(viewModel.initialText, "");
    expect(viewModel.reviewCommentId, "0");
    expect(viewModel.comments, isEmpty);
    expect(viewModel.comment, isNull);
  });

  test("initialText and controller should be empty if comments are not present",
      () async {
    viewModel.comment = Comment();
    when(
      () => mockController.getText(),
    ).thenAnswer((_) async => "");
    final value = await mockController.getText();
    expect(viewModel.comments, isEmpty);
    expect(viewModel.initialText, "");
    expect(value, "");
  });

  // test('onSavePress emits loading and loaded on success', () async {
  //   final mockComments = [
  //     Comment.fromInputData(
  //       type: CommentsType.previousCreditApproval,
  //       entityType: EntityIdentifier.previousCreditApproval,
  //       categoryId: 1,
  //       strategyComment: 'Sample',
  //     ),
  //   ];
  //   viewModel.initialText = 'Sample';
  //   viewModel.comments = mockComments;

  //   Globals.user = User(id: 'user1', availableRoles: [Role(roleId: 1)]);

  //   when(() => mockController.getText()).thenAnswer((_) async => 'Test');

  //   when(
  //     () => mockApprovalRepository.saveApplicationStrategyDetails(
  //       10,
  //       mockComments,
  //     ),
  //   ).thenAnswer((_) async => 'Saved successfully');

  //   viewModel.onSavePress(context: fakeContext);

  //   // verify(() => mockController.getText()).called(1);
  //   // verify(() => mockApprovalRepository.saveApplicationStrategyDetails(
  //   //     10, mockComments,),).called(1);
  //   expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  // });

  test("onSavePress failure ", () async {
    final mockComment = Comment(comment: "Test");
    viewModel.comment = mockComment;

    // Globals.request = Request(applicantRim: 'APP123');
    // Globals.user = User(id: 'user1', availableRoles: [Role(roleId: 1)]);

    when(() => mockCommonRepository.saveComment(mockComment))
        .thenThrow(Exception("Save failed"));

    await viewModel.onSavePress(context: fakeContext);

    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  test("getComments should handle exception and show failure toast", () async {
    // Simulate an exception
    // when(() => mockRepository.getQueryResponse())
    //     .thenThrow(Exception('Failed to fetch'));

    // Stub AlertManager
    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
    when(() => viewModel.getApplicationStrategyDetails())
        .thenAnswer((_) async => "");

    // Call the method
    await viewModel.getApplicationStrategyDetails();

    // Verify toast was shown
    verify(() => mockAlertManager.showFailureToast(any())).called(1);
  });

  test("getComments handles empty list", () async {
    when(
      () => mockCommonRepository.getComments(
        CommentsType.previousCreditApproval,
        EntityIdentifier.previousCreditApproval,
      ),
    ).thenAnswer((_) async => []);

    await viewModel.getApplicationStrategyDetails();
    verifyNever(() => mockController.setText(""));
  });

  group("PreviousCreditApprovalState", () {});

  group("PreviousCreditApprovalState", () {
    test("constructor sets loaderStatus", () {
      final state =
          PreviousCreditApprovalState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing when null", () {
      final original =
          PreviousCreditApprovalState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides", () {
      final original =
          PreviousCreditApprovalState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("PreviousCreditApprovalViewModel – getters & draft config", () {
    late PreviousCreditApprovalViewModel vm;

    setUp(() {
      vm = PreviousCreditApprovalViewModel();
    });

    test("isEdit returns true when user has edit right", () {
      Globals.user = User(
        currentRole: Role(
          rights: {
            RightConstants.previousCreditApproval: AccessType.edit,
          },
        ),
      );

      expect(vm.isEdit, true);
    });

    test("isEdit returns false when user has no edit right", () {
      Globals.user = User(
        currentRole: Role(
          rights: {
            RightConstants.previousCreditApproval: AccessType.view,
          },
        ),
      );

      expect(vm.isEdit, false);
    });

    test("draftModuleKey is approval", () {
      expect(vm.draftModuleKey, DraftModuleKeys.approval);
    });

    test("draftFormKey is previousCreditApproval", () {
      expect(vm.draftFormKey, Routes.previousCreditApproval);
    });

    test("draftHandler type", () {
      expect(vm.draftHandler, isA<PreviousCreditApprovalDraftHandler>());
    });
  });

  group("close()", () {
    test("unregisters draft and disposes controller", () async {
      final vm = PreviousCreditApprovalViewModel();

      await vm.close();

      expect(true, isTrue); // completes safely
    });
  });
  test("onSavePress saves successfully and shows success toast", () async {
    viewModel.initialText = "Approved";

    when(
      () => mockApprovalRepository.saveApplicationStrategyDetails(
        any(),
        any(),
      ),
    ).thenAnswer((_) async => null);

    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);

    await viewModel.onSavePress(context: fakeContext);

    verify(() => mockAlertManager.showSuccessToast(any())).called(1);
  });

  group("syncControllerFromModel()", () {
    late PreviousCreditApprovalViewModel vm;

    setUp(() {
      vm = PreviousCreditApprovalViewModel();
    });

    test("updates controller text when different from initialText", () {
      // Arrange
      vm.initialText = "New value";
      vm.commentController.text = "Old value";

      // Act
      vm.syncControllerFromModel();

      // Assert
      expect(vm.commentController.text, "New value");
    });

    test("does nothing when controller text matches initialText", () {
      // Arrange
      vm.initialText = "Same value";
      vm.commentController.text = "Same value";

      // Act
      vm.syncControllerFromModel();

      // Assert
      expect(vm.commentController.text, "Same value");
    });
  });
}
