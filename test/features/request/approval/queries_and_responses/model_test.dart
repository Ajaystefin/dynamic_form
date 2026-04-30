import "package:connectivity_plus/connectivity_plus.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
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

/// Simple in-memory storage mock for DraftMixin / LocalStorageService usage.
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

  void clearAll() => _storage.clear();
}

/// Test asset loader to prevent localization warnings for required keys.
class TestAssetLoader extends AssetLoader {
  const TestAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "common": {
        "error": "Error",
      },
      "approval": {
        "creditAssessment": {
          "savedSuccessfully": "Saved successfully",
        },
      },
    };
  }
}

/// Testable subclass to intercept DraftMixin-related methods.
/// This helps us verify production flow inside `onSavePress()` and `close()`.
class TestableQueriesAndResponsesViewModel
    extends QueriesAndResponsesViewModel {
  bool initCalled = false;
  bool registerDraftCallbackCalled = false;
  bool unregisterDraftCallbackCalled = false;
  bool loadDraftIfAvailableCalled = false;
  bool deleteDraftCalled = false;

  @override
  Future<void> init(context) async {
    initCalled = true;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

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

Future<BuildContext> pumpWithViewModel(
  WidgetTester tester,
  QueriesAndResponsesViewModel viewModel,
) async {
  late BuildContext capturedContext;

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale("en")],
      fallbackLocale: const Locale("en"),
      path: "unused",
      assetLoader: const TestAssetLoader(),
      child: MaterialApp(
        home: BlocProvider<QueriesAndResponsesViewModel>.value(
          value: viewModel,
          child: Builder(
            builder: (context) {
              capturedContext = context;
              return const Scaffold(body: SizedBox.shrink());
            },
          ),
        ),
        localizationsDelegates: const [],
        supportedLocales: const [Locale("en")],
      ),
    ),
  );

  await tester.pumpAndSettle();
  return capturedContext;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late QueriesAndResponsesViewModel viewModel;
  late TestableQueriesAndResponsesViewModel testableViewModel;
  late MockCommonRepository mockCommonRepository;
  late MockApprovalRepository mockApprovalRepository;
  late MockRequestRepository mockRequestRepository;
  late MockAlertManager mockAlertManager;
  late MockLocalStorageService mockLocalStorageService;
  late MockController mockController;

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    registerFallbackValue(Comment());
    registerFallbackValue(FakeBuildContext());
  });

  setUp(() async {
    mockCommonRepository = MockCommonRepository();
    mockApprovalRepository = MockApprovalRepository();
    mockRequestRepository = MockRequestRepository();
    mockAlertManager = MockAlertManager();
    mockLocalStorageService = MockLocalStorageService();
    mockController = MockController();

    await EnvConfig.setEnvironment();

    AlertManager.instance = mockAlertManager;
    LocalStorageService().setStorage(mockLocalStorageService);

    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);

    viewModel = QueriesAndResponsesViewModel()
      ..repository = mockApprovalRepository
      ..commonRepository = mockCommonRepository
      ..requestRepository = mockRequestRepository
      ..controller = mockController;

    testableViewModel = TestableQueriesAndResponsesViewModel()
      ..repository = mockApprovalRepository
      ..commonRepository = mockCommonRepository
      ..requestRepository = mockRequestRepository
      ..controller = mockController;

    // Connectivity stubs
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
        return "wifi";
      },
    );

    Globals.user = null;
  });

  tearDown(() {
    mockLocalStorageService.clearAll();
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);
  });

  group("constructor / defaults / getters", () {
    test("initial state and default values are correct", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.rowsPerPage, 5);
      expect(viewModel.comments, isEmpty);
      expect(viewModel.comment, isNotNull);
      expect(viewModel.initialText, "");
      expect(viewModel.canSubmit, false);
      expect(viewModel.isCommentVisible, false);
      expect(viewModel.reviewCommentId, "0");
    });

    test("draft keys and handler are correct", () {
      expect(viewModel.draftModuleKey, DraftModuleKeys.approval);
      expect(viewModel.draftFormKey, Routes.queriesAndResponses);
      expect(viewModel.draftHandler, isA<QueriesAndResponsesDraftHandler>());
    });

    test("formKey getter can be accessed safely", () {
      expect(
        () {
          viewModel.formKey;
        },
        returnsNormally,
      );
    });
  });

  group("isEdit initialization", () {
    test("isEdit is false when user has no edit right", () {
      Globals.user = User(
        id: "u1",
        currentRole: Role(
          roleId: 1,
          rights: {},
        ),
      );

      final vm = QueriesAndResponsesViewModel();
      expect(vm.isEdit, false);
    });

    test("isEdit is true when businessVolume access is edit", () {
      Globals.user = User(
        id: "u1",
        currentRole: Role(
          roleId: 1,
          rights: {
            RightConstants.businessVolume: AccessType.edit,
          },
        ),
      );

      final vm = QueriesAndResponsesViewModel();
      expect(vm.isEdit, true);
    });

    test("isEdit is false when currentRole is null", () {
      Globals.user = User(
        id: "u1",
        availableRoles: [Role(roleId: 1)],
      );

      final vm = QueriesAndResponsesViewModel();
      expect(vm.isEdit, false);
    });

    test("isEdit is false when user is null", () {
      Globals.user = null;
      final vm = QueriesAndResponsesViewModel();
      expect(vm.isEdit, false);
    });
  });

  group("getComments()", () {
    test("handles empty list", () async {
      when(
        () => mockCommonRepository.getComments(
          CommentsType.queriesResponses,
          EntityIdentifier.queriesResponses,
        ),
      ).thenAnswer((_) async => []);

      await viewModel.getComments();

      verify(
        () => mockCommonRepository.getComments(
          CommentsType.queriesResponses,
          EntityIdentifier.queriesResponses,
        ),
      ).called(1);

      verifyNever(() => mockController.setText(any()));
      expect(viewModel.comments, isEmpty);
      expect(viewModel.initialText, "");
      expect(viewModel.reviewCommentId, "0");
      expect(viewModel.isCommentVisible, false);
    });

    test("handles exception and shows failure toast", () async {
      when(
        () => mockCommonRepository.getComments(
          CommentsType.queriesResponses,
          EntityIdentifier.queriesResponses,
        ),
      ).thenThrow(Exception("Failed to fetch comments"));

      await viewModel.getComments();

      verify(
        () => mockCommonRepository.getComments(
          CommentsType.queriesResponses,
          EntityIdentifier.queriesResponses,
        ),
      ).called(1);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.comments, isEmpty);
    });

    test(
        "single comment from same user and same role"
        " populates editor and hides comments", () async {
      Globals.user = User(
        id: "user-1",
        currentRole: Role(roleId: 10),
      );

      final ownComment = Comment(
        commentId: "c1",
        userId: "user-1",
        userRole: 10,
        reviewCommentId: "review-123",
        comment: "Own draft text",
        createdDate: DateTime(2026, 1, 10),
      );

      when(
        () => mockCommonRepository.getComments(
          CommentsType.queriesResponses,
          EntityIdentifier.queriesResponses,
        ),
      ).thenAnswer((_) async => [ownComment]);

      await viewModel.getComments();

      verify(() => mockController.setText("Own draft text")).called(1);
      expect(viewModel.reviewCommentId, "review-123");
      expect(viewModel.initialText, "Own draft text");
      expect(viewModel.isCommentVisible, false);
      expect(viewModel.comments, isEmpty);
      expect(viewModel.comment?.commentId, "c1");
    });

    test(
        "single comment from same "
        "user but different role "
        "shows comments and does not populate editor", () async {
      Globals.user = User(
        id: "user-1",
        currentRole: Role(roleId: 99),
      );

      final sameUserDifferentRoleComment = Comment(
        commentId: "c-role",
        userId: "user-1",
        userRole: 10,
        reviewCommentId: "review-role",
        comment: "Role mismatch comment",
        createdDate: DateTime(2026, 1, 12),
      );

      when(
        () => mockCommonRepository.getComments(
          CommentsType.queriesResponses,
          EntityIdentifier.queriesResponses,
        ),
      ).thenAnswer((_) async => [sameUserDifferentRoleComment]);

      await viewModel.getComments();

      expect(viewModel.isCommentVisible, true);
      verifyNever(() => mockController.setText(any()));
      expect(viewModel.initialText, "");
      expect(viewModel.reviewCommentId, "0");
      expect(viewModel.comments.length, 1);
      expect(viewModel.comment?.commentId, "c-role");
    });

    test(
        "single comment from another user makes "
        "comments visible and does not populate editor", () async {
      Globals.user = User(
        id: "current-user",
        currentRole: Role(roleId: 99),
      );

      final foreignComment = Comment(
        commentId: "c2",
        userId: "other-user",
        userRole: 10,
        reviewCommentId: "review-456",
        comment: "Other user comment",
        createdDate: DateTime(2026, 1, 11),
      );

      when(
        () => mockCommonRepository.getComments(
          CommentsType.queriesResponses,
          EntityIdentifier.queriesResponses,
        ),
      ).thenAnswer((_) async => [foreignComment]);

      await viewModel.getComments();

      verifyNever(() => mockController.setText(any()));
      expect(viewModel.isCommentVisible, true);
      expect(viewModel.reviewCommentId, "0");
      expect(viewModel.initialText, "");
      expect(viewModel.comments.length, 1);
      expect(viewModel.comment?.commentId, "c2");
    });

    test(
        "multiple comments selects latest own "
        "comment and removes it from visible comments", () async {
      Globals.user = User(
        id: "user-1",
        currentRole: Role(roleId: 10),
      );

      final oldOwnComment = Comment(
        commentId: "c-old",
        userId: "user-1",
        userRole: 10,
        reviewCommentId: "review-old",
        comment: "Old own comment",
        createdDate: DateTime(2026, 1, 1),
      );

      final latestOwnComment = Comment(
        commentId: "c-new",
        userId: "user-1",
        userRole: 10,
        reviewCommentId: "review-new",
        comment: "Latest own comment",
        createdDate: DateTime(2026, 2, 1),
      );

      final otherComment = Comment(
        commentId: "c-other",
        userId: "user-2",
        userRole: 20,
        reviewCommentId: "review-other",
        comment: "Other comment",
        createdDate: DateTime(2026, 1, 15),
      );

      when(
        () => mockCommonRepository.getComments(
          CommentsType.queriesResponses,
          EntityIdentifier.queriesResponses,
        ),
      ).thenAnswer(
        (_) async => [
          oldOwnComment,
          latestOwnComment,
          otherComment,
        ],
      );

      await viewModel.getComments();

      expect(viewModel.isCommentVisible, true);
      expect(viewModel.comment?.commentId, "c-new");
      expect(viewModel.reviewCommentId, "review-new");
      expect(viewModel.initialText, "Latest own comment");

      verify(() => mockController.setText("Latest own comment")).called(1);

      expect(viewModel.comments.length, 2);
      expect(
        viewModel.comments.any((e) => e.reviewCommentId == "review-new"),
        false,
      );
      expect(
        viewModel.comments.any((e) => e.reviewCommentId == "review-old"),
        true,
      );
      expect(
        viewModel.comments.any((e) => e.reviewCommentId == "review-other"),
        true,
      );
    });

    test(
        "multiple comments selects latest foreign "
        "comment and does not populate editor", () async {
      Globals.user = User(
        id: "user-1",
        currentRole: Role(roleId: 10),
      );

      final ownComment = Comment(
        commentId: "c-own",
        userId: "user-1",
        userRole: 10,
        reviewCommentId: "review-own",
        comment: "Own comment",
        createdDate: DateTime(2026, 1, 1),
      );

      final latestForeignComment = Comment(
        commentId: "c-foreign",
        userId: "user-2",
        userRole: 20,
        reviewCommentId: "review-foreign",
        comment: "Latest foreign comment",
        createdDate: DateTime(2026, 5, 1),
      );

      when(
        () => mockCommonRepository.getComments(
          CommentsType.queriesResponses,
          EntityIdentifier.queriesResponses,
        ),
      ).thenAnswer(
        (_) async => [
          ownComment,
          latestForeignComment,
        ],
      );

      await viewModel.getComments();

      expect(viewModel.isCommentVisible, true);
      expect(viewModel.comment?.commentId, "c-foreign");
      verifyNever(() => mockController.setText(any()));
      expect(viewModel.reviewCommentId, "0");
      expect(viewModel.initialText, "");
      expect(viewModel.comments.length, 2);
    });

    test("multiple comments with same createdDate still completes safely",
        () async {
      Globals.user = User(
        id: "user-1",
        currentRole: Role(roleId: 10),
      );

      final date = DateTime(2026, 3, 1);

      final c1 = Comment(
        commentId: "c1",
        userId: "user-2",
        userRole: 20,
        reviewCommentId: "r1",
        comment: "Comment 1",
        createdDate: date,
      );

      final c2 = Comment(
        commentId: "c2",
        userId: "user-1",
        userRole: 10,
        reviewCommentId: "r2",
        comment: "Comment 2",
        createdDate: date,
      );

      when(
        () => mockCommonRepository.getComments(
          CommentsType.queriesResponses,
          EntityIdentifier.queriesResponses,
        ),
      ).thenAnswer((_) async => [c1, c2]);

      await viewModel.getComments();

      expect(viewModel.isCommentVisible, true);
      expect(viewModel.comments.isNotEmpty, true);
    });
  });

  group("onSavePress()", () {
    testWidgets(
      "success path saves comment, deletes draft, "
      "refreshes comments, and re-initializes cubit",
      (tester) async {
        Globals.user = User(
          id: "user-1",
          currentRole: Role(roleId: 10),
        );

        testableViewModel.reviewCommentId = "review-999";

        when(() => mockController.getText())
            .thenAnswer((_) async => "<p>Hello</p>");

        when(() => mockApprovalRepository.saveReviewComments(any()))
            .thenAnswer((_) async => "ok");

        when(
          () => mockCommonRepository.getComments(
            CommentsType.queriesResponses,
            EntityIdentifier.queriesResponses,
          ),
        ).thenAnswer((_) async => []);

        final context = await pumpWithViewModel(tester, testableViewModel);

        await testableViewModel.onSavePress(context: context);
        await tester.pumpAndSettle();

        verify(() => mockController.getText()).called(1);

        // IMPORTANT:
        // Verify and capture only ONCE to avoid the "VERIFIED" mocktail error.
        final verification = verify(
          () => mockApprovalRepository.saveReviewComments(captureAny()),
        );

        verification.called(1);

        final captured = verification.captured.single as Comment;

        expect(captured.comment, "<p>Hello</p>");
        expect(captured.type, CommentsType.queriesResponses);
        expect(captured.entityType, EntityIdentifier.queriesResponses);
        expect(
          captured.categoryId,
          ServerConstants.commentTypeId[CommentsType.queriesResponses],
        );
        expect(captured.reviewCommentId, "review-999");

        verify(
          () => mockCommonRepository.getComments(
            CommentsType.queriesResponses,
            EntityIdentifier.queriesResponses,
          ),
        ).called(1);

        verify(() => mockAlertManager.showSuccessToast(any())).called(1);

        expect(testableViewModel.deleteDraftCalled, true);
        expect(testableViewModel.initCalled, true);
        expect(testableViewModel.state.loaderStatus, LoadingStatus.loaded);
      },
    );

    testWidgets(
        "failure path shows failure toast and still ends in loaded state",
        (tester) async {
      Globals.user = User(
        id: "user-1",
        currentRole: Role(roleId: 10),
      );

      when(() => mockController.getText()).thenAnswer((_) async => "Bad save");

      when(() => mockApprovalRepository.saveReviewComments(any()))
          .thenThrow(Exception("Save failed"));

      final context = await pumpWithViewModel(tester, testableViewModel);

      await testableViewModel.onSavePress(context: context);
      await tester.pumpAndSettle();

      verify(() => mockController.getText()).called(1);
      verify(() => mockApprovalRepository.saveReviewComments(any())).called(1);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);

      verifyNever(
        () => mockCommonRepository.getComments(
          CommentsType.queriesResponses,
          EntityIdentifier.queriesResponses,
        ),
      );

      expect(testableViewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    // testWidgets(
    //     'does not call init when context is unmounted before save completes',
    //     (tester) async {
    //   Globals.user = User(
    //     id: 'user-1',
    //     currentRole: Role(roleId: 10),
    //   );

    //   testableViewModel.reviewCommentId = 'review-222';

    //   when(() => mockController.getText())
    //       .thenAnswer((_) async => 'Unmount test');

    //   when(() => mockApprovalRepository.saveReviewComments(any()))
    //       .thenAnswer((_) async {
    //     await Future.delayed(const Duration(milliseconds: 50));
    //     return 'ok';
    //   });

    //   when(
    //     () => mockCommonRepository.getComments(
    //       CommentsType.queriesResponses,
    //       EntityIdentifier.queriesResponses,
    //     ),
    //   ).thenAnswer((_) async => []);

    //   late BuildContext context;

    //   await tester.pumpWidget(
    //     EasyLocalization(
    //       supportedLocales: const [Locale('en')],
    //       fallbackLocale: const Locale('en'),
    //       path: 'unused',
    //       assetLoader: const TestAssetLoader(),
    //       child: MaterialApp(
    //         home: BlocProvider<QueriesAndResponsesViewModel>.value(
    //           value: testableViewModel,
    //           child: Builder(
    //             builder: (ctx) {
    //               context = ctx;
    //               return const Scaffold(body: SizedBox());
    //             },
    //           ),
    //         ),
    //         localizationsDelegates: const [],
    //         supportedLocales: const [Locale('en')],
    //       ),
    //     ),
    //   );

    //   await tester.pumpAndSettle();

    //   final future = testableViewModel.onSavePress(context: context);

    //   // Unmount widget tree before save completes.
    //   await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    //   await tester.pump();

    //   await future;
    //   await tester.pumpAndSettle();

    //   expect(testableViewModel.initCalled, false);
    //   expect(testableViewModel.state.loaderStatus, LoadingStatus.loaded);
    //   verify(() =>
    // mockApprovalRepository.saveReviewComments(any())).called(1);
    // });
  });

  group("close()", () {
    test("close unregisters draft callback", () async {
      await testableViewModel.close();
      expect(testableViewModel.unregisterDraftCallbackCalled, true);
    });
  });

  group("QueriesAndResponsesState", () {
    test("constructor sets loaderStatus", () {
      final state =
          QueriesAndResponsesState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing when null", () {
      final original =
          QueriesAndResponsesState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides loaderStatus", () {
      final original =
          QueriesAndResponsesState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);

      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });
}
