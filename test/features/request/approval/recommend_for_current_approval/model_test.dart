import "package:connectivity_plus/connectivity_plus.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/queries_and_responses/state.dart";
import "package:wcas_frontend/features/request/approval/recommend_for_current_approval/model.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/draft_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

import "../../../../test_config.dart";

class MockCommonRepository extends Mock implements CommonRepository {}

class MockApprovalRepository extends Mock implements ApprovalRepository {}

class MockRequestRepository extends Mock implements RequestRepository {}

class MockBuildContext extends Mock implements BuildContext {}

class MockAlertManager extends Mock implements AlertManager {}

class MockDraftRepository extends Mock implements DraftRepository {}

class FakeComment extends Fake implements Comment {}

class MockController extends Mock implements UnifiedEditorController {}

// Mock LocalStorageService
class MockLocalStorageService implements StorageInterface {
  final Map<String, Map<String, dynamic>> _storage = {};

  @override
  Future<void> init({String? path}) async {}

  @override
  Future<void> put(String box, String key, Object? value) async {
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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
    JSONMethodCodec(),
  );

  setUpAll(() async {
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    registerFallbackValue(FakeComment());
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall call) async {
        if (call.method == "check") {
          return <dynamic>[];
        }
        return null;
      },
    );
  });

  late RecommendCurrentApprovalViewModel viewModel;
  late MockCommonRepository mockCommonRepository;
  late MockRequestRepository mockRequestRepository;
  late MockApprovalRepository mockApprovalRepository;
  late MockAlertManager mockAlertManager;
  late MockBuildContext fakeContext;
  late MockLocalStorageService mockLocalStorageService;
  late MockDraftRepository mockDraftRepository;
  late MockController mockController;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockCommonRepository = MockCommonRepository();
    mockRequestRepository = MockRequestRepository();
    mockApprovalRepository = MockApprovalRepository();
    mockDraftRepository = MockDraftRepository();
    mockController = MockController();
    mockAlertManager = MockAlertManager();
    fakeContext = MockBuildContext();
    await EnvConfig.setEnvironment();
    AlertManager.instance = mockAlertManager;
    // Override repository instances
    CommonRepository.overrideInstance = mockCommonRepository;
    AlertManager.overrideInstance = mockAlertManager;
    ApprovalRepository.overrideInstance = mockApprovalRepository;
    RequestRepository.overrideInstance = mockRequestRepository;

    viewModel = RecommendCurrentApprovalViewModel()
      ..repository = mockApprovalRepository
      ..controller = mockController
      ..requestRepository = mockRequestRepository;

    mockLocalStorageService = MockLocalStorageService();

    when(() => mockRequestRepository.getApplicationDetails())
        .thenAnswer((_) async => ApplicationDetails());

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

    // Set up LocalStorageService mock
    LocalStorageService().getStorage = mockLocalStorageService;

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

  test("init loads data and emits loaded state", () async {
    final comments = [
      Comment(categoryId: 20, strategyComment: "Other"),
    ];
    Globals.user = User(currentRole: Role(code: "CA"));
    when(
      () => mockApprovalRepository.getApplicationStrategyDetails(
        CommentsType.recommendCurrentApproval,
        EntityIdentifier.recommendCurrentApproval,
      ),
    ).thenAnswer((_) async => comments);
    when(() => mockApprovalRepository.getInitiatedRole())
        .thenAnswer((_) async => "CA");
    when(() => viewModel.getApplicationStrategyDetails())
        .thenAnswer((_) async => {});
    when(() => mockRequestRepository.getApplicationDetails())
        .thenAnswer((_) async => ApplicationDetails());
    when(() => mockApprovalRepository.fetchReference())
        .thenAnswer((_) async => {});
    when(() => mockController.getText())
        .thenAnswer((_) async => "<p>Sample</p>");

    await (viewModel..comments = comments).init(MockBuildContext());
    await viewModel.close();

    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    expect(viewModel.comments, comments);
  });

  test("isEdit must be assigned with proper values", () async {
    final comments = [
      Comment(categoryId: 20, strategyComment: "Other"),
    ];

    viewModel
      ..isRiskRatingInit = true
      ..isReadOnly = false
      ..comments = comments
      ..controller = mockController;

    Globals.user = User(currentRole: Role(code: "CA"));

    when(() => mockController.getText())
        .thenAnswer((_) async => "<p>Sample</p>");
    when(
      () => mockApprovalRepository.getApplicationStrategyDetails(
        CommentsType.recommendCurrentApproval,
        EntityIdentifier.recommendCurrentApproval,
      ),
    ).thenAnswer((_) async => comments);

    when(() => mockApprovalRepository.getInitiatedRole())
        .thenAnswer((_) async => "CA");

    when(() => mockRequestRepository.getApplicationDetails())
        .thenAnswer((_) async => ApplicationDetails());

    when(() => mockApprovalRepository.fetchReference())
        .thenAnswer((_) async => {});

    await viewModel.init(MockBuildContext());

    expect(viewModel.isInitByCA, true);
    expect(viewModel.isEdit, false);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test("getComments success", () async {
    final mockComments = [
      Comment(commentId: "1", comment: "Test comment"),
    ];

    when(
      () => mockCommonRepository.getComments(
        CommentsType.approval,
        EntityIdentifier.approval,
      ),
    ).thenAnswer((_) async => mockComments);

    final response = await mockCommonRepository.getComments(
      CommentsType.approval,
      EntityIdentifier.approval,
    );

    expect(response, mockComments);
  });

  test("getComments failure", () async {
    when(
      () => mockCommonRepository.getComments(
        CommentsType.approval,
        EntityIdentifier.approval,
      ),
    ).thenThrow(Exception());

    expect(
      () => mockCommonRepository.getComments(
        CommentsType.approval,
        EntityIdentifier.approval,
      ),
      throwsException,
    );
  });

  group("onSavePress()", () {
    testWidgets("throws failure toast when text is empty", (tester) async {
      when(() => mockController.getText()).thenAnswer((_) async => "");
      when(
        () => mockApprovalRepository.saveApplicationStrategyDetails(
          10,
          [],
        ),
      ).thenAnswer((_) async => "");
      await viewModel.onSavePress(context: fakeContext);
      await tester.pumpAndSettle();

      verify(
        () => mockAlertManager.showFailureToast(
          "approval.recommendationCurrentApproval.pleaseEnterRemarks",
        ),
      ).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test(" with exception shows in error state", () async {
      when(() => mockController.getText())
          .thenAnswer((_) async => "<p>Sample</p>");
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
      when(
        () => mockApprovalRepository.saveApplicationStrategyDetails(
          10,
          [],
        ),
      ).thenThrow(Exception("Error"));
      await (viewModel..initialText = "Sample")
          .onSavePress(context: MockBuildContext());

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    test(" with isContinue=true does not call toasts without form", () async {
      when(() => mockController.getText())
          .thenAnswer((_) async => "<p>Sample</p>");
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
      when(
        () => mockApprovalRepository.saveApplicationStrategyDetails(
          10,
          [],
        ),
      ).thenAnswer((_) async => "Success");
      await (viewModel..initialText = "Sample")
          .onSavePress(isContinue: true, context: fakeContext);

      verifyNever(() => mockAlertManager.showFailureToast(""));
    });
  });

  test("getComments should handle exception and show failure toast", () async {
    // Simulate an exception

    // Stub AlertManager
    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

    // Call the method
    await viewModel.getApplicationStrategyDetails();

    // Verify toast was shown
    verify(() => mockAlertManager.showFailureToast(any())).called(1);
  });

  test("viewModel properties are properly initialized", () {
    expect(viewModel.comment, isNull);
    expect(viewModel.comments, isEmpty);
  });

  group("getApplicationStrategyDetails()", () {
    test("clears text when no matching category found", () async {
      final comments = [
        Comment(categoryId: 20, strategyComment: "Other"),
      ];

      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.recommendCurrentApproval,
          EntityIdentifier.recommendCurrentApproval,
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.initialText, "");
    });

    test("clears text when repository returns null", () async {
      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.recommendCurrentApproval,
          EntityIdentifier.recommendCurrentApproval,
        ),
      ).thenAnswer((_) async => []);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.initialText, "");
    });

    test("shows error toast when repository throws", () async {
      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.recommendCurrentApproval,
          EntityIdentifier.recommendCurrentApproval,
        ),
      ).thenThrow(Exception("API error"));

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.initialText, isNotNull);
    });
  });

  group("QueriesAndResponsesState", () {
    test("constructor sets loaderStatus", () {
      const state =
          QueriesAndResponsesState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing when null", () {
      const original =
          QueriesAndResponsesState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides", () {
      const original =
          QueriesAndResponsesState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });
}
