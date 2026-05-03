// ignore_for_file: deprecated_member_use

import "package:connectivity_plus/connectivity_plus.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/request_for_closure/model.dart";
import "package:wcas_frontend/features/request/approval/request_for_closure/state.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/draft_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

import "../../../../test_config.dart";

class MockRequestRepository extends Mock implements RequestRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockBuildContext extends Mock implements BuildContext {}

class FakeComment extends Fake implements Comment {}

class MockApprovalRepository extends Mock implements ApprovalRepository {}

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
    connectivityChannel.setMockMethodCallHandler((call) async {
      if (call.method == "check") {
        return <dynamic>[];
      }
      return null;
    });
  });

  late RequestForClosureViewModel viewModel;
  late MockRequestRepository mockRequestRepository;
  late MockCommonRepository mockCommonRepository;
  late MockApprovalRepository mockApprovalRepository;
  late MockAlertManager mockAlert;
  late MockDraftRepository mockDraftRepository;
  late MockLocalStorageService mockLocalStorageService;

  setUp(() async {
    Globals.user = User(
      id: "u1",
      name: "Test User",
      currentRole: Role(id: 1, code: "R1", bpmRole: "Role 1"),
    );
    mockAlert = MockAlertManager();
    mockRequestRepository = MockRequestRepository();
    mockCommonRepository = MockCommonRepository();
    mockApprovalRepository = MockApprovalRepository();
    mockDraftRepository = MockDraftRepository();
    mockLocalStorageService = MockLocalStorageService();

    // Override repository instances
    CommonRepository.overrideInstance(mockCommonRepository);
    AlertManager.overrideInstance(mockAlert);
    ApprovalRepository.overrideInstance(mockApprovalRepository);
    RequestRepository.overrideInstance(mockRequestRepository);

    viewModel = RequestForClosureViewModel()
      ..requestRepository = mockRequestRepository
      ..commonRepository = mockCommonRepository
      ..repository = mockApprovalRepository;

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
    await EnvConfig.setEnvironment();
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);
  });

  test("initial state should be loading", () {
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  test("init loads data and emits loaded state", () async {
    when(
      () => mockCommonRepository.getComments(
        CommentsType.requestForClosure,
        EntityIdentifier.requestForClosure,
      ),
    ).thenAnswer((_) async => [Comment()]);

    when(() => mockRequestRepository.getApplicationDetails())
        .thenAnswer((_) async => ApplicationDetails());

    when(() => mockApprovalRepository.getInitiatedRole())
        .thenAnswer((_) async => "");

    when(
      () => viewModel.getComments(
        CommentsType.requestForClosure,
        EntityIdentifier.requestForClosure,
      ),
    ).thenAnswer((_) async {});

    await viewModel.init(MockBuildContext());

    expect(viewModel.isReadOnly, true);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    expect(viewModel.comments, []);
  });

  test("getComments should handle exception and leave comments empty",
      () async {
    when(
      () => mockCommonRepository.getComments(
        CommentsType.requestForClosure,
        EntityIdentifier.requestForClosure,
      ),
    ).thenThrow(Exception("Failed"));
    await viewModel.getComments(
      CommentsType.requestForClosure,
      EntityIdentifier.requestForClosure,
    );
    expect(viewModel.comments, isEmpty);
  });

  test("saveComment should emit loaded after success", () async {
    viewModel.comment = Comment();
    const resultMessage = "Saved OK";
    when(() => mockCommonRepository.saveComment(any()))
        .thenAnswer((_) async => resultMessage);
    when(
      () => mockApprovalRepository.submitApplication(
        any(),
        any(),
        any(),
      ),
    ).thenAnswer(
      (_) async =>
          AppResponse(status: ResponseStatus.success, message: "Success"),
    );
    await viewModel.saveCommentAndClose();
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test("saveComment handles exception and emits loaded", () async {
    when(() => mockCommonRepository.saveComment(any()))
        .thenThrow(Exception("oops"));
    await (viewModel..comment = Comment()).saveCommentAndClose();
    verify(() => mockAlert.showFailureToast(any())).called(1);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test("saveComment should assign the details to the fields", () async {
    viewModel
      ..comment = Comment()
      ..comment = Comment.fromInputData(
        type: CommentsType.requestForClosure,
        entityType: EntityIdentifier.requestForClosure,
        categoryId: 10,
        reviewCommentId: "2",
        comment: "strategyComment",
      );
    const resultMessage = "Saved OK";
    Globals.userAction = [
      {"Accept & Close Application": 10},
    ];
    when(() => mockCommonRepository.saveComment(any()))
        .thenAnswer((_) async => resultMessage);
    when(
      () => mockApprovalRepository.submitApplication(
        any(),
        any(),
        any(),
      ),
    ).thenAnswer(
      (_) async =>
          AppResponse(status: ResponseStatus.success, message: "Success"),
    );
    when(
      () => viewModel.submitApplication(
        UserAction.acceptCloseApplication,
      ),
    ).thenAnswer((_) async => ["Success"]);
    await viewModel.saveCommentAndClose();
    await viewModel.submitApplication(
      UserAction.acceptCloseApplication,
    );
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test("saveCommentAndClose emits loaded state", () async {
    final statuses = <LoadingStatus>[];

    final sub =
        viewModel.stream.map((s) => s.loaderStatus).listen(statuses.add);

    await viewModel.saveCommentAndClose();

    await sub.cancel();

    expect(statuses, contains(LoadingStatus.loaded));
  });

  test("viewModel properties are properly initialized", () {
    expect(viewModel.repository, mockApprovalRepository);
    expect(viewModel.comments, isEmpty);
    expect(viewModel.comment, isNull);
  });

  group("RequestForClosureState", () {
    test("constructor sets loaderStatus", () {
      final state = RequestForClosureState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing when null", () {
      final original =
          RequestForClosureState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides", () {
      final original =
          RequestForClosureState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("onTextChange", () {
    test("should validate the field", () async {
      viewModel.onTextChange("");
      expect(viewModel.canSubmit, false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      viewModel.onTextChange("New Comment");
      expect(viewModel.canSubmit, true);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("submitApplication()", () {
    test("returns empty when exception is thrown", () async {
      when(
        () => mockApprovalRepository.submitApplication(
          any(),
          any(),
          any(),
        ),
      ).thenThrow(Exception("API error"));
      final result = await viewModel.submitApplication(
        UserAction.acceptCloseApplication,
      );

      expect(result, isEmpty);
    });

    test(
        "show success alter popup for the success"
        " response with assigning the variables", () async {
      Globals.userAction = [
        {"Accept & Close Application": 10},
      ];
      when(
        () => mockApprovalRepository.submitApplication(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer(
        (_) async =>
            AppResponse(status: ResponseStatus.success, message: "Success"),
      );
      final result = await viewModel.submitApplication(
        UserAction.acceptCloseApplication,
      );
      verify(() => mockAlert.showSuccessToast(any())).called(1);
      expect(result, isA<List<String>>());
      expect(result.first, contains("layout.topmenu.comfirmation"));
      expect(
        result.last,
        contains(
          "approval.comments.applicationStatus",
        ),
      );
      expect(result, isNotEmpty);
    });

    test("show failure alter popup for the error response", () async {
      when(
        () => mockApprovalRepository.submitApplication(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer(
        (_) async =>
            AppResponse(status: ResponseStatus.error, message: "Failed"),
      );
      final result = await viewModel.submitApplication(
        UserAction.acceptCloseApplication,
      );
      verify(() => mockAlert.showFailureToast(any())).called(1);
      expect(result, isEmpty);
    });
  });
}
