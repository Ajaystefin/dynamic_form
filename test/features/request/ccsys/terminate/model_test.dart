import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/ccsys/termination/model.dart";
import "package:wcas_frontend/features/request/ccsys/termination/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/ccsys_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/draft_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

import "../../../../test_config.dart";

/// ---- Mocks / Fakes ----

class FakeCcsysRepository extends Mock implements CcsysRepository {}

/// Spy to capture emitted states for submit tests
class SpySubmitVm extends CcsysTerminationViewModel {
  final List<TerminationState> emitted = [];
  final List<TerminationState> emittedStates = [];
}

/// Spy to capture emitted states in general tests
class MockCcsysCreateRequestViewModel extends CcsysTerminationViewModel {
  @override
  void emit(TerminationState state) {
    super.emit(state);
    emittedStates.add(state);
  }

  final List<TerminationState> emittedStates = [];
  bool searchCalled = false;
}

class MockAlertManager extends Mock implements AlertManager {}

class MockRouter extends Mock {
  // Match production signature
  void go(String route, {Object? extra});
}

class MockDialogHelper extends Mock implements DialogHelper {
  void showCustomDialog({
    required BuildContext context,
    required String title,
    required Widget content,
    required List<Widget> actions,
  }) {}
}

class RequestController {
  RequestController(this.router);
  final MockRouter router;

  void onResetButtonPress() {
    router.go(Routes.loadingPage);
    Future.delayed(const Duration(milliseconds: 100), () {
      router.go(Routes.requestCreate);
    });
  }
}

class MockLayoutViewModel extends Mock implements LayoutViewModel {}

class MockRequestRepository extends Mock implements RequestRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockContext extends Mock implements BuildContext {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockDraftRepository extends Mock implements DraftRepository {}

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
  TestWidgetsFlutterBinding.ensureInitialized(); // binding required

  late MockCcsysCreateRequestViewModel viewModel;
  late MockRequestRepository mockRequestRepository;
  late MockCommonRepository mockCommonRepository;
  late MockContext mockContext;

  late MockAlertManager mockAlertManager;
  late MockDraftRepository mockDraftRepository;
  late MockLocalStorageService mockLocalStorageService;

  const connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();

    // Mock the connectivity plugin to return a list with wifi connectivity
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (call) async {
        if (call.method == "check") {
          return ["wifi"];
        }
        return null;
      },
    );

    registerFallbackValue(Request());
    registerFallbackValue(Customer());
  });

  setUp(() {
    mockAlertManager = MockAlertManager();
    AlertManager.overrideInstance(mockAlertManager);

    mockLocalStorageService = MockLocalStorageService();
    // Set up LocalStorageService mock
    LocalStorageService().setStorage(mockLocalStorageService);
    mockDraftRepository = MockDraftRepository();
    mockRequestRepository = MockRequestRepository();
    mockCommonRepository = MockCommonRepository();
    RequestRepository.overrideInstance(mockRequestRepository);
    CommonRepository.overrideInstance(mockCommonRepository);
    mockContext = MockContext();
    viewModel = MockCcsysCreateRequestViewModel();
    viewModel.repository = mockRequestRepository;

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
  });

  test("init method set values", () {
    when(
      () => MockReferenceDataService()
          .getReferenceData([ReferenceDataKeys.ccsysTerminationReason]),
    ).thenAnswer(
      (_) async => {
        ReferenceDataKeys.ccsysTerminationReason: [
          Reference(id: 1, name: "Reason"),
        ],
      },
    );
    when(
      () => mockCommonRepository.getComments(
        CommentsType.terminateWithdraw,
        EntityIdentifier.terminateWithdraw,
      ),
    ).thenAnswer(
      (_) async => [],
    );

    viewModel.init(mockContext);
    expect(viewModel.comments, isEmpty);
  });

  test("initRightsAndMode method set values", () {
    viewModel.initRightsAndMode(Request());
    expect(viewModel.canEdit, false);
  });

  test("reasonForTerminationSelected method set values", () {
    viewModel.reasonForTerminationSelected(Reference(id: 10));
    expect(viewModel.comment?.categoryId, 10);
    expect(viewModel.comment?.reasonList, "10");
  });

  test("onTerminateButtonPressed method validation", () {
    viewModel.onTerminateButtonPressed(mockContext);
    verifyNever(
      () => mockAlertManager.showFailureToast(
        "requestInformation.terminateWithdrawal.requiredFeild".tr(),
      ),
    );
    viewModel.canEdit = true;
    viewModel.onTerminateButtonPressed(mockContext);
    verify(
      () => mockAlertManager.showFailureToast(
        "requestInformation.terminateWithdrawal.requiredFeild".tr(),
      ),
    ).called(1);
  });

  group("submitTerminateRequest", () {
    test("method handles the exception", () {
      viewModel.canEdit = false;
      when(
        () => mockRequestRepository.updateTerminateStatus(any(), any()),
      ).thenThrow(Exception("Error"));
      viewModel.submitTerminateRequest(mockContext);
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    test("method on success set value", () {
      viewModel.canEdit = false;
      when(
        () => mockRequestRepository.updateTerminateStatus(any(), any()),
      ).thenAnswer((_) async => "Success");
      viewModel.submitTerminateRequest(mockContext);
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });
  });

  group("getReviewCommentsReference", () {
    test("method handles the exception", () {
      when(
        () => mockCommonRepository.getComments(
          CommentsType.terminateWithdraw,
          EntityIdentifier.terminateWithdraw,
        ),
      ).thenThrow(Exception("Error"));
      viewModel.getReviewCommentsReference(
        CommentsType.terminateWithdraw,
        EntityIdentifier.terminateWithdraw,
      );
      // verify(() =>

      //     .called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    test("method on success set value", () {
      Globals.request?.applicationRefNo = "App123";
      final comments = [
        Comment(
          userId: "u1",
          userRole: 1,
          comment: "Test",
          reviewCommentId: "1",
          applicationRefNo: "App123",
        ),
      ];
      viewModel.comments = comments;
      when(
        () => mockCommonRepository.getComments(
          CommentsType.terminateWithdraw,
          EntityIdentifier.terminateWithdraw,
        ),
      ).thenAnswer((_) async => comments);
      viewModel.getReviewCommentsReference(
        CommentsType.terminateWithdraw,
        EntityIdentifier.terminateWithdraw,
      );
      expect(viewModel.comments, isNotEmpty);
      expect(viewModel.comment, isNotNull);
    });
  });

  group("TerminationState", () {
    test("constructor sets loaderStatus", () {
      final state = TerminationState(
        loaderStatus: LoadingStatus.loading,
      );
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing when null", () {
      final original = TerminationState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides", () {
      final original = TerminationState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });
}
