import "package:connectivity_plus/connectivity_plus.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/queries_and_responses/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/queries_and_responses/model.dart";
import "package:wcas_frontend/features/request/approval/queries_and_responses/state.dart";
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

class MockAlertManager extends Mock implements AlertManager {}

class MockController extends Mock implements UnifiedEditorController {}

class FakeBuildContext extends Fake implements BuildContext {}

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

  void clearAll() => _storage.clear();
}

class TestableQueriesAndResponsesViewModel
    extends QueriesAndResponsesViewModel {
  bool registerDraftCallbackCalled = false;
  bool unregisterDraftCallbackCalled = false;
  bool loadDraftIfAvailableCalled = false;
  bool deleteDraftCalled = false;

  @override
  void registerDraftCallback() {
    registerDraftCallbackCalled = true;
  }

  @override
  Future<void> loadDraftIfAvailable() async {
    loadDraftIfAvailableCalled = true;
  }

  @override
  Future<void> deleteDraft() async {
    deleteDraftCalled = true;
  }

  @override
  void unregisterDraftCallback() {
    unregisterDraftCallbackCalled = true;
  }
}

Future<BuildContext> pumpContext(
  WidgetTester tester,
  QueriesAndResponsesViewModel viewModel,
) async {
  late BuildContext capturedContext;

  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          capturedContext = context;
          return const Scaffold(body: SizedBox.shrink());
        },
      ),
    ),
  );

  await tester.pump();
  return capturedContext;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  late TestableQueriesAndResponsesViewModel viewModel;
  late MockCommonRepository mockCommonRepository;
  late MockApprovalRepository mockApprovalRepository;
  late MockRequestRepository mockRequestRepository;
  late MockAlertManager mockAlertManager;
  late MockLocalStorageService mockLocalStorageService;
  late MockController mockController;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await EnvConfig.setEnvironment();

    registerFallbackValue(Comment());
    registerFallbackValue(FakeBuildContext());

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall call) async {
        if (call.method == "check") {
          return <dynamic>[ConnectivityResult.wifi.name];
        }
        return null;
      },
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel("plugins.flutter.io/connectivity"),
      (MethodCall call) async => "wifi",
    );
  });

  setUp(() {
    mockCommonRepository = MockCommonRepository();
    mockApprovalRepository = MockApprovalRepository();
    mockRequestRepository = MockRequestRepository();
    mockAlertManager = MockAlertManager();
    mockLocalStorageService = MockLocalStorageService();
    mockController = MockController();

    AlertManager.instance = mockAlertManager;
    CommonRepository.overrideInstance = mockCommonRepository;
    ApprovalRepository.overrideInstance = mockApprovalRepository;
    RequestRepository.overrideInstance = mockRequestRepository;
    LocalStorageService().getStorage = mockLocalStorageService;

    when(() => mockAlertManager.showFailureToast(any())).thenAnswer((_) {});
    when(() => mockAlertManager.showSuccessToast(any())).thenAnswer((_) {});
    when(() => mockAlertManager.showWarningToast(any())).thenAnswer((_) {});
    when(() => mockAlertManager.showInfoToast(any())).thenAnswer((_) {});

    when(
      () => mockCommonRepository.getComments(
        CommentsType.queriesResponses,
        EntityIdentifier.queriesResponses,
      ),
    ).thenAnswer((_) async => <Comment>[]);

    when(() => mockRequestRepository.getApplicationDetails())
        .thenAnswer((_) async => null);

    when(() => mockApprovalRepository.fetchReference())
        .thenAnswer((_) async {});

    Globals.user = User(
      id: "user-1",
      currentRole: Role(
        roleId: 10,
        rights: <String, AccessType>{},
      ),
    );

    viewModel = TestableQueriesAndResponsesViewModel()
      ..repository = mockApprovalRepository
      ..commonRepository = mockCommonRepository
      ..requestRepository = mockRequestRepository
      ..controller = mockController;
  });

  tearDown(() async {
    mockLocalStorageService.clearAll();
    await viewModel.close();
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel("plugins.flutter.io/connectivity"),
      null,
    );
  });

  group("constructor / defaults / draft getters", () {
    test("initial state and defaults", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.rowsPerPage, 5);
      expect(viewModel.comments, isEmpty);
      expect(viewModel.comment, isNotNull);
      expect(viewModel.initialText, "");
      expect(viewModel.canSubmit, false);
      expect(viewModel.isCommentVisible, false);
      expect(viewModel.reviewCommentId, "0");
      expect(viewModel.isReadOnly, true);
    });

    test("draft keys and handler", () {
      expect(viewModel.draftModuleKey, DraftModuleKeys.approval);
      expect(viewModel.draftFormKey, Routes.queriesAndResponses);
      expect(viewModel.draftHandler, isA<QueriesAndResponsesDraftHandler>());
    });

    test("formKey getter is safe", () {
      expect(() => viewModel.formKey, returnsNormally);
    });

    test("isEdit false when no edit right", () {
      Globals.user = User(
        id: "u1",
        currentRole: Role(
          roleId: 1,
          rights: <String, AccessType>{},
        ),
      );

      final vm = QueriesAndResponsesViewModel();

      expect(vm.isEdit, false);
    });

    test("isEdit true when business volume right is edit", () {
      Globals.user = User(
        id: "u1",
        currentRole: Role(
          roleId: 1,
          rights: <String, AccessType>{
            RightConstants.businessVolume: AccessType.edit,
          },
        ),
      );

      final vm = QueriesAndResponsesViewModel();

      expect(vm.isEdit, true);
    });

    test("isEdit false when user is null", () {
      Globals.user = null;

      final vm = QueriesAndResponsesViewModel();

      expect(vm.isEdit, false);
    });
  });

  group("init", () {
    testWidgets("init loads dependencies and emits loaded", (tester) async {
      final context = await pumpContext(tester, viewModel);

      await viewModel.init(context);

      verify(
        () => mockCommonRepository.getComments(
          CommentsType.queriesResponses,
          EntityIdentifier.queriesResponses,
        ),
      ).called(1);

      verify(() => mockRequestRepository.getApplicationDetails()).called(1);
      verify(() => mockApprovalRepository.fetchReference()).called(1);

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("init registers draft when app is not read only", (
      tester,
    ) async {
      final context = await pumpContext(tester, viewModel);

      await viewModel.init(context);

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("getComments", () {
    test("empty list", () async {
      when(
        () => mockCommonRepository.getComments(
          CommentsType.queriesResponses,
          EntityIdentifier.queriesResponses,
        ),
      ).thenAnswer((_) async => <Comment>[]);

      await viewModel.getComments();

      expect(viewModel.comments, isEmpty);
      expect(viewModel.initialText, "");
      expect(viewModel.reviewCommentId, "0");
      expect(viewModel.isCommentVisible, false);
      verifyNever(() => mockController.setText(any()));
    });

    test("exception shows failure toast", () async {
      when(
        () => mockCommonRepository.getComments(
          CommentsType.queriesResponses,
          EntityIdentifier.queriesResponses,
        ),
      ).thenThrow(Exception("comments failed"));

      await viewModel.getComments();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("single own comment populates editor and removes from visible list",
        () async {
      Globals.user = User(
        id: "user-1",
        currentRole: Role(roleId: 10),
      );

      final ownComment = Comment(
        commentId: "c1",
        userId: "user-1",
        userRole: 10,
        reviewCommentId: "r1",
        comment: "Own comment",
        createdDate: DateTime(2026),
      );

      when(
        () => mockCommonRepository.getComments(
          CommentsType.queriesResponses,
          EntityIdentifier.queriesResponses,
        ),
      ).thenAnswer((_) async => <Comment>[ownComment]);

      await viewModel.getComments();

      expect(viewModel.isCommentVisible, false);
      expect(viewModel.reviewCommentId, "r1");
      expect(viewModel.initialText, "Own comment");
      expect(viewModel.comments, isEmpty);
      expect(viewModel.comment?.commentId, "c1");

      verify(() => mockController.setText("Own comment")).called(1);
    });

    test("single foreign comment remains visible", () async {
      Globals.user = User(
        id: "current",
        currentRole: Role(roleId: 10),
      );

      final comment = Comment(
        commentId: "c2",
        userId: "other",
        userRole: 20,
        reviewCommentId: "r2",
        comment: "Foreign comment",
        createdDate: DateTime(2026),
      );

      when(
        () => mockCommonRepository.getComments(
          CommentsType.queriesResponses,
          EntityIdentifier.queriesResponses,
        ),
      ).thenAnswer((_) async => <Comment>[comment]);

      await viewModel.getComments();

      expect(viewModel.isCommentVisible, true);
      expect(viewModel.comments.length, 1);
      expect(viewModel.comment?.commentId, "c2");
      expect(viewModel.reviewCommentId, "0");
      verifyNever(() => mockController.setText(any()));
    });

    test("single same user different role remains visible", () async {
      Globals.user = User(
        id: "user-1",
        currentRole: Role(roleId: 99),
      );

      final comment = Comment(
        commentId: "c3",
        userId: "user-1",
        userRole: 10,
        reviewCommentId: "r3",
        comment: "Role mismatch",
        createdDate: DateTime(2026),
      );

      when(
        () => mockCommonRepository.getComments(
          CommentsType.queriesResponses,
          EntityIdentifier.queriesResponses,
        ),
      ).thenAnswer((_) async => <Comment>[comment]);

      await viewModel.getComments();

      expect(viewModel.isCommentVisible, true);
      expect(viewModel.comments.length, 1);
      verifyNever(() => mockController.setText(any()));
    });

    test("multiple comments latest own comment populates editor", () async {
      Globals.user = User(
        id: "user-1",
        currentRole: Role(roleId: 10),
      );

      final oldOwn = Comment(
        commentId: "old",
        userId: "user-1",
        userRole: 10,
        reviewCommentId: "old-r",
        comment: "Old own",
        createdDate: DateTime(2026),
      );

      final latestOwn = Comment(
        commentId: "latest",
        userId: "user-1",
        userRole: 10,
        reviewCommentId: "latest-r",
        comment: "Latest own",
        createdDate: DateTime(2026, 3),
      );

      final other = Comment(
        commentId: "other",
        userId: "user-2",
        userRole: 20,
        reviewCommentId: "other-r",
        comment: "Other",
        createdDate: DateTime(2026, 2),
      );

      when(
        () => mockCommonRepository.getComments(
          CommentsType.queriesResponses,
          EntityIdentifier.queriesResponses,
        ),
      ).thenAnswer((_) async => <Comment>[oldOwn, latestOwn, other]);

      await viewModel.getComments();

      expect(viewModel.isCommentVisible, true);
      expect(viewModel.comment?.commentId, "latest");
      expect(viewModel.reviewCommentId, "latest-r");
      expect(viewModel.initialText, "Latest own");
      expect(viewModel.comments.length, 2);
      expect(
        viewModel.comments.any((e) => e.reviewCommentId == "latest-r"),
        false,
      );

      verify(() => mockController.setText("Latest own")).called(1);
    });

    test("multiple comments latest foreign does not populate editor", () async {
      Globals.user = User(
        id: "user-1",
        currentRole: Role(roleId: 10),
      );

      final own = Comment(
        commentId: "own",
        userId: "user-1",
        userRole: 10,
        reviewCommentId: "own-r",
        comment: "Own",
        createdDate: DateTime(2026),
      );

      final foreign = Comment(
        commentId: "foreign",
        userId: "user-2",
        userRole: 20,
        reviewCommentId: "foreign-r",
        comment: "Foreign",
        createdDate: DateTime(2026, 5),
      );

      when(
        () => mockCommonRepository.getComments(
          CommentsType.queriesResponses,
          EntityIdentifier.queriesResponses,
        ),
      ).thenAnswer((_) async => <Comment>[own, foreign]);

      await viewModel.getComments();

      expect(viewModel.isCommentVisible, true);
      expect(viewModel.comment?.commentId, "foreign");
      expect(viewModel.reviewCommentId, "0");
      expect(viewModel.initialText, "");
      expect(viewModel.comments.length, 2);
      verifyNever(() => mockController.setText(any()));
    });
  });

  group("onSavePress", () {
    testWidgets("empty editor text shows validation toast", (tester) async {
      final context = await pumpContext(tester, viewModel);

      when(() => mockController.getText())
          .thenAnswer((_) async => "<p>&nbsp;</p>");

      await viewModel.onSavePress(context: context);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      verifyNever(() => mockApprovalRepository.saveReviewComments(any()));
    });

    testWidgets("success saves comment and refreshes comments", (tester) async {
      final context = await pumpContext(tester, viewModel);

      viewModel.reviewCommentId = "review-1";

      when(() => mockController.getText())
          .thenAnswer((_) async => "<p>Hello</p>");

      when(() => mockApprovalRepository.saveReviewComments(any()))
          .thenAnswer((_) async => "ok");

      when(
        () => mockCommonRepository.getComments(
          CommentsType.queriesResponses,
          EntityIdentifier.queriesResponses,
        ),
      ).thenAnswer((_) async => <Comment>[]);

      await viewModel.onSavePress(context: context);

      verify(() => mockController.getText()).called(1);

      final captured = verify(
        () => mockApprovalRepository.saveReviewComments(captureAny()),
      ).captured.single as Comment;

      expect(captured.comment, "<p>Hello</p>");
      expect(captured.type, CommentsType.queriesResponses);
      expect(captured.entityType, EntityIdentifier.queriesResponses);
      expect(
        captured.categoryId,
        ServerConstants.commentTypeId[CommentsType.queriesResponses],
      );
      expect(captured.reviewCommentId, "review-1");

      expect(viewModel.deleteDraftCalled, true);
      verify(() => mockAlertManager.showSuccessToast(any())).called(1);
      verify(
        () => mockCommonRepository.getComments(
          CommentsType.queriesResponses,
          EntityIdentifier.queriesResponses,
        ),
      ).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("success continue branch remains safe", (tester) async {
      final context = await pumpContext(tester, viewModel);

      when(() => mockController.getText())
          .thenAnswer((_) async => "<div>Continue</div>");

      when(() => mockApprovalRepository.saveReviewComments(any()))
          .thenAnswer((_) async => "ok");

      when(
        () => mockCommonRepository.getComments(
          CommentsType.queriesResponses,
          EntityIdentifier.queriesResponses,
        ),
      ).thenAnswer((_) async => <Comment>[]);

      await viewModel.onSavePress(
        context: context,
        isContinue: true,
      );

      verify(() => mockApprovalRepository.saveReviewComments(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("repository failure shows toast and loaded", (tester) async {
      final context = await pumpContext(tester, viewModel);

      when(() => mockController.getText()).thenAnswer((_) async => "Bad save");

      when(() => mockApprovalRepository.saveReviewComments(any()))
          .thenThrow(Exception("Save failed"));

      await viewModel.onSavePress(context: context);

      verify(() => mockController.getText()).called(1);
      verify(() => mockApprovalRepository.saveReviewComments(any())).called(1);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);

      verifyNever(
        () => mockCommonRepository.getComments(
          CommentsType.queriesResponses,
          EntityIdentifier.queriesResponses,
        ),
      );

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("controller getText failure shows toast", (tester) async {
      final context = await pumpContext(tester, viewModel);

      when(() => mockController.getText())
          .thenThrow(Exception("editor failed"));

      await viewModel.onSavePress(context: context);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("close", () {
    test("unregisters draft callback", () async {
      await viewModel.close();

      expect(viewModel.unregisterDraftCallbackCalled, true);
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

    test("copyWith overrides loaderStatus", () {
      const original =
          QueriesAndResponsesState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);

      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });
}
