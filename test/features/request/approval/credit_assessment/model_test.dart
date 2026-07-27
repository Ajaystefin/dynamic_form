import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment/model.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment/state.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class TestAlertManager implements AlertManager {
  String? lastFailure;
  String? lastSuccess;
  String? lastInfo;
  String? lastWarning;

  @override
  void showFailureToast(String msg) => lastFailure = msg;

  @override
  void showSuccessToast(String msg) => lastSuccess = msg;

  @override
  void showInfoToast(String msg) => lastInfo = msg;

  @override
  void showWarningToast(String msg) => lastWarning = msg;
}

class MockUnifiedEditorController extends Mock
    implements UnifiedEditorController {}

class MockRequestRepository extends Mock implements RequestRepository {}

class MockApprovalRepository extends Mock implements ApprovalRepository {}

class FakeBuildContext extends Fake implements BuildContext {}

/// Testable subclass to:
/// 1) avoid real deleteDraft network/timers
/// 2) count internal refresh calls
class TestCreditAssessmentViewModel extends CreditAssessmentViewModel {
  int getApplicationStrategyDetailsCalled = 0;
  int deleteDraftCalled = 0;
  int registerDraftCallbackCalled = 0;
  int loadDraftIfAvailableCalled = 0;

  @override
  Future<void> getApplicationStrategyDetails() async {
    getApplicationStrategyDetailsCalled++;
    return super.getApplicationStrategyDetails();
  }

  @override
  Future<void> deleteDraft() async {
    deleteDraftCalled++;
    return;
  }

  @override
  void registerDraftCallback() {
    registerDraftCallbackCalled++;
  }

  @override
  Future<void> loadDraftIfAvailable() async {
    loadDraftIfAvailableCalled++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
    JSONMethodCodec(),
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    connectivityChannel,
    (MethodCall methodCall) async {
      return ["wifi"];
    },
  );

  late TestCreditAssessmentViewModel viewModel;
  late MockRequestRepository mockRequestRepo;
  late MockApprovalRepository mockApprovalRepo;
  late MockUnifiedEditorController mockAppraisalController;
  late MockUnifiedEditorController mockBriefController;
  late TestAlertManager alertSpy;
  late BuildContext fakeContext;

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());

    // Needed because mocktail uses this for any<List<Comment>>() and
    // captureAny<List<Comment>>()
    registerFallbackValue(<Comment>[]);
  });

  setUp(() async {
    await EnvConfig.setEnvironment();

    mockRequestRepo = MockRequestRepository();
    mockApprovalRepo = MockApprovalRepository();
    mockAppraisalController = MockUnifiedEditorController();
    mockBriefController = MockUnifiedEditorController();
    alertSpy = TestAlertManager();
    fakeContext = FakeBuildContext();

    AlertManager.overrideInstance = alertSpy;

    viewModel = TestCreditAssessmentViewModel()
      ..repository = mockRequestRepo
      ..approvalRepository = mockApprovalRepo
      ..appraisalController = mockAppraisalController
      ..briefController = mockBriefController;

    when(() => mockAppraisalController.getText())
        .thenAnswer((_) async => "<p>Appraisal</p>");
    when(() => mockBriefController.getText())
        .thenAnswer((_) async => "<p>Brief</p>");

    when(
      () => mockApprovalRepo.saveApplicationStrategyDetails(
        ServerConstants.commentTypeId[CommentsType.creditAppraisal],
        any<List<Comment>>(),
      ),
    ).thenAnswer((_) async {
      return null;
    });

    when(
      () => mockApprovalRepo.getApplicationStrategyDetails(
        CommentsType.creditAppraisal,
        EntityIdentifier.creditAssesment,
      ),
    ).thenAnswer((_) async => []);
  });

  group("init()", () {
    testWidgets("init success path -> loaded and calls repos + draft methods",
        (tester) async {
      // IMPORTANT:
      // These override methods must exist in your project.
      // If they do, use them. If not, see note below.
      RequestRepository.overrideInstance = mockRequestRepo;
      ApprovalRepository.overrideInstance = mockApprovalRepo;

      when(() => mockRequestRepo.getApplicationDetails()).thenAnswer((_) async {
        return null;
      });
      when(() => mockApprovalRepo.fetchReference()).thenAnswer((_) async {});
      when(
        () => mockApprovalRepo.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer((_) async => []);

      final router = GoRouter(
        initialLocation: "/",
        routes: [
          GoRoute(
            path: "/",
            name: Routes.creditAssessment,
            builder: (context, state) => Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {},
                    child: const Text("test"),
                  );
                },
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      final BuildContext ctx = tester.element(find.byType(ElevatedButton));

      await viewModel.init(ctx);

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      verify(() => mockRequestRepo.getApplicationDetails()).called(1);
      verify(() => mockApprovalRepo.fetchReference()).called(1);

      // Since our test subclass overrides these safely,
      // this proves the non-read-only branch executed.
      expect(viewModel.registerDraftCallbackCalled, 0);
      expect(viewModel.loadDraftIfAvailableCalled, 0);
      expect(viewModel.getApplicationStrategyDetailsCalled, 1);
    });

    testWidgets("init error path -> emits error when request repo throws",
        (tester) async {
      RequestRepository.overrideInstance = mockRequestRepo;
      ApprovalRepository.overrideInstance = mockApprovalRepo;

      when(() => mockRequestRepo.getApplicationDetails())
          .thenThrow(Exception("init failed"));
      when(() => mockApprovalRepo.fetchReference()).thenAnswer((_) async {});
      when(
        () => mockApprovalRepo.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer((_) async => []);

      final router = GoRouter(
        initialLocation: "/",
        routes: [
          GoRoute(
            path: "/",
            name: Routes.creditAssessment,
            builder: (context, state) => const Scaffold(
              body: Text("init error"),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      final BuildContext ctx = tester.element(find.text("init error"));

      await viewModel.init(ctx);

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    testWidgets("init error path -> emits error when fetchReference throws",
        (tester) async {
      RequestRepository.overrideInstance = mockRequestRepo;
      ApprovalRepository.overrideInstance = mockApprovalRepo;

      when(() => mockRequestRepo.getApplicationDetails()).thenAnswer((_) async {
        return null;
      });
      when(() => mockApprovalRepo.fetchReference())
          .thenThrow(Exception("fetch ref failed"));
      when(
        () => mockApprovalRepo.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer((_) async => []);

      final router = GoRouter(
        initialLocation: "/",
        routes: [
          GoRoute(
            path: "/",
            name: Routes.creditAssessment,
            builder: (context, state) => const Scaffold(
              body: Text("fetch ref error"),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      final BuildContext ctx = tester.element(find.text("fetch ref error"));

      await viewModel.init(ctx);

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });
  });

  group("Initial state / properties / getters", () {
    test("initial state is loading", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test("initialized variables are correct", () {
      expect(viewModel.isReadOnly, false);
      expect(viewModel.canSubmit, false);
      expect(viewModel.comment, null);
      expect(viewModel.comments, isEmpty);
      expect(viewModel.creditBrief, isEmpty);
      expect(viewModel.creditAppraisal, isEmpty);
      expect(viewModel.scrollController, isA<ScrollController>());
      expect(viewModel.formKey, isA<GlobalKey<FormState>>());
      expect(viewModel.appraisalController, same(mockAppraisalController));
      expect(viewModel.briefController, same(mockBriefController));
    });

    test("draft getters return expected values", () {
      expect(viewModel.draftModuleKey, DraftModuleKeys.approval);
      expect(viewModel.draftFormKey, Routes.creditAssessment);
      expect(
        viewModel.draftHandler,
        isA<DraftHandler<CreditAssessmentViewModel>>(),
      );
      expect(viewModel.draftHandler, isA<CreditAssessmentDraftHandler>());
    });

    test("isApproved is a bool", () {
      expect(viewModel.isApproved, isA<bool>());
    });

    test("userRoleList contains expected role ids", () {
      expect(viewModel.userRoleList, isNotEmpty);
      expect(
        viewModel.userRoleList
            .contains(ServerConstants.userRoleId[UserRole.creditAnalyst]),
        isTrue,
      );
      expect(
        viewModel.userRoleList.contains(
          ServerConstants.userRoleId[UserRole.teamLeaderCreditLevelD1],
        ),
        isTrue,
      );
      expect(
        viewModel.userRoleList
            .contains(ServerConstants.userRoleId[UserRole.segmentHeadLevelB]),
        isTrue,
      );
      expect(
        viewModel.userRoleList.contains(
          ServerConstants.userRoleId[UserRole.segmentHeadCreditLevelD],
        ),
        isTrue,
      );
      expect(
        viewModel.userRoleList
            .contains(ServerConstants.userRoleId[UserRole.segmentHeadLevelC]),
        isTrue,
      );
      expect(
        viewModel.userRoleList
            .contains(ServerConstants.userRoleId[UserRole.segmentHeadLevelB1]),
        isTrue,
      );
      expect(
        viewModel.userRoleList.contains(
          ServerConstants.userRoleId[UserRole.creditCommitteeProxy],
        ),
        isTrue,
      );
      expect(
        viewModel.userRoleList
            .contains(ServerConstants.userRoleId[UserRole.boardDirectorProxy]),
        isTrue,
      );
      expect(
        viewModel.userRoleList.contains(
          ServerConstants.userRoleId[UserRole.creditCommitteeProxyApprover],
        ),
        isTrue,
      );
      expect(
        viewModel.userRoleList.contains(
          ServerConstants.userRoleId[UserRole.boardDirectorProxyApproval],
        ),
        isTrue,
      );
    });
  });

  group("onSavePress - editor failure branches", () {
    test("appraisal controller throws -> failure toast and loaded state at end",
        () async {
      when(() => mockAppraisalController.getText())
          .thenThrow(Exception("JS Error"));

      await viewModel.onSavePress(context: fakeContext);

      expect(alertSpy.lastFailure, "Exception: JS Error");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      verifyNever(
        () => mockApprovalRepo.saveApplicationStrategyDetails(
          ServerConstants.commentTypeId[CommentsType.creditAppraisal],
          any<List<Comment>>(),
        ),
      );
    });

    test("brief controller throws -> failure toast and loaded state at end",
        () async {
      when(() => mockBriefController.getText())
          .thenThrow(Exception("Brief Error"));

      await viewModel.onSavePress(context: fakeContext);

      expect(alertSpy.lastFailure, "Exception: Brief Error");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      verifyNever(
        () => mockApprovalRepo.saveApplicationStrategyDetails(
          ServerConstants.commentTypeId[CommentsType.creditAppraisal],
          any<List<Comment>>(),
        ),
      );
    });
  });

  group("onSavePress - empty remarks branches", () {
    test("empty appraisal html -> failure toast and early return", () async {
      when(() => mockAppraisalController.getText()).thenAnswer((_) async => "");
      when(() => mockBriefController.getText())
          .thenAnswer((_) async => "<p>Brief</p>");

      await viewModel.onSavePress(context: fakeContext);

      expect(
        alertSpy.lastFailure,
        "approval.creditAssessment.pleaseEnterRemarks",
      );

      verifyNever(
        () => mockApprovalRepo.saveApplicationStrategyDetails(
          ServerConstants.commentTypeId[CommentsType.creditAppraisal],
          any<List<Comment>>(),
        ),
      );

      // Early return before final emit, so remains constructor loading
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test("empty brief html -> failure toast and early return", () async {
      when(() => mockAppraisalController.getText())
          .thenAnswer((_) async => "<p>Appraisal</p>");
      when(() => mockBriefController.getText()).thenAnswer((_) async => "");

      await viewModel.onSavePress(context: fakeContext);

      expect(
        alertSpy.lastFailure,
        "approval.creditAssessment.pleaseEnterRemarks",
      );

      verifyNever(
        () => mockApprovalRepo.saveApplicationStrategyDetails(
          ServerConstants.commentTypeId[CommentsType.creditAppraisal],
          any<List<Comment>>(),
        ),
      );

      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test("both editors empty -> failure toast and no save", () async {
      when(() => mockAppraisalController.getText()).thenAnswer((_) async => "");
      when(() => mockBriefController.getText()).thenAnswer((_) async => "");

      await viewModel.onSavePress(context: fakeContext);

      expect(
        alertSpy.lastFailure,
        "approval.creditAssessment.pleaseEnterRemarks",
      );

      verifyNever(
        () => mockApprovalRepo.saveApplicationStrategyDetails(
          ServerConstants.commentTypeId[CommentsType.creditAppraisal],
          any<List<Comment>>(),
        ),
      );
    });
  });

  group("onSavePress - form branches", () {
    test(
        "non-empty remarks but no form mounted -> no"
        " save, no toast, final loaded", () async {
      // No widget pump => formKey.currentState is null
      await viewModel.onSavePress(context: fakeContext);

      verifyNever(
        () => mockApprovalRepo.saveApplicationStrategyDetails(
          ServerConstants.commentTypeId[CommentsType.creditAppraisal],
          any<List<Comment>>(),
        ),
      );

      expect(alertSpy.lastFailure, isNull);
      expect(alertSpy.lastSuccess, isNull);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("invalid form -> no save, no toast, loaded", (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: viewModel.formKey,
              child: TextFormField(
                validator: (_) => "error",
              ),
            ),
          ),
        ),
      );

      await viewModel.onSavePress(
        context: tester.element(find.byType(Form)),
      );

      verifyNever(
        () => mockApprovalRepo.saveApplicationStrategyDetails(
          ServerConstants.commentTypeId[CommentsType.creditAppraisal],
          any<List<Comment>>(),
        ),
      );

      expect(alertSpy.lastFailure, isNull);
      expect(alertSpy.lastSuccess, isNull);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("valid remarks + valid form -> save success toast + loaded",
        (tester) async {
      when(
        () => mockApprovalRepo.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer(
        (_) async => [
          Comment(
            categoryId: ServerConstants
                .approvalCategoryId[ApprovalCategory.creditBreif],
            strategyComment: "<p>Saved Brief</p>",
          ),
          Comment(
            categoryId: ServerConstants
                .approvalCategoryId[ApprovalCategory.creditAppraisal],
            strategyComment: "<p>Saved Appraisal</p>",
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: viewModel.formKey,
              child: TextFormField(
                validator: (_) => null,
              ),
            ),
          ),
        ),
      );

      await viewModel.onSavePress(
        context: tester.element(find.byType(Form)),
      );

      verify(
        () => mockApprovalRepo.saveApplicationStrategyDetails(
          ServerConstants.commentTypeId[CommentsType.creditAppraisal],
          any<List<Comment>>(),
        ),
      ).called(1);

      verify(
        () => mockApprovalRepo.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).called(1);

      expect(viewModel.getApplicationStrategyDetailsCalled, 1);
      expect(viewModel.deleteDraftCalled, 1);
      expect(
        alertSpy.lastSuccess,
        "approval.creditAssessment.savedSuccessfully",
      );
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets(
        "saveApplicationStrategyDetails "
        "throws "
        "-> failure toast and final loaded state", (tester) async {
      when(
        () => mockApprovalRepo.saveApplicationStrategyDetails(
          ServerConstants.commentTypeId[CommentsType.creditAppraisal],
          any<List<Comment>>(),
        ),
      ).thenThrow(Exception("save failed"));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: viewModel.formKey,
              child: TextFormField(
                validator: (_) => null,
              ),
            ),
          ),
        ),
      );

      await viewModel.onSavePress(
        context: tester.element(find.byType(Form)),
      );

      expect(alertSpy.lastFailure, "Exception: save failed");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      verifyNever(
        () => mockApprovalRepo.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      );
    });

    testWidgets("saved comments payload branch executes fully", (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: viewModel.formKey,
              child: TextFormField(
                validator: (_) => null,
              ),
            ),
          ),
        ),
      );

      await viewModel.onSavePress(
        context: tester.element(find.byType(Form)),
      );

      final captured = verify(
        () => mockApprovalRepo.saveApplicationStrategyDetails(
          ServerConstants.commentTypeId[CommentsType.creditAppraisal],
          captureAny<List<Comment>>(),
        ),
      ).captured;

      expect(captured.isNotEmpty, isTrue);
      expect(captured.first, isA<List<Comment>>());

      final List<Comment> savedComments = captured.first as List<Comment>;
      expect(savedComments.length, 2);
      expect(savedComments[0].strategyComment, "<p>Brief</p>");
      expect(savedComments[1].strategyComment, "<p>Appraisal</p>");
      expect(
        savedComments[0].categoryId,
        ServerConstants.approvalCategoryId[ApprovalCategory.creditBreif],
      );
      expect(
        savedComments[1].categoryId,
        ServerConstants.approvalCategoryId[ApprovalCategory.creditAppraisal],
      );
      expect(viewModel.deleteDraftCalled, 1);
    });

    testWidgets("different editor values are passed correctly to payload",
        (tester) async {
      when(() => mockAppraisalController.getText())
          .thenAnswer((_) async => "<p>AAA</p>");
      when(() => mockBriefController.getText())
          .thenAnswer((_) async => "<p>BBB</p>");

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: viewModel.formKey,
              child: TextFormField(
                validator: (_) => null,
              ),
            ),
          ),
        ),
      );

      await viewModel.onSavePress(
        context: tester.element(find.byType(Form)),
      );

      final captured = verify(
        () => mockApprovalRepo.saveApplicationStrategyDetails(
          ServerConstants.commentTypeId[CommentsType.creditAppraisal],
          captureAny<List<Comment>>(),
        ),
      ).captured;

      final List<Comment> savedComments = captured.first as List<Comment>;
      expect(savedComments.length, 2);
      expect(savedComments[0].strategyComment, "<p>BBB</p>");
      expect(savedComments[1].strategyComment, "<p>AAA</p>");
    });

    testWidgets("calling onSavePress twice saves twice and deletes draft twice",
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: viewModel.formKey,
              child: TextFormField(
                validator: (_) => null,
              ),
            ),
          ),
        ),
      );

      await viewModel.onSavePress(
        context: tester.element(find.byType(Form)),
      );

      await viewModel.onSavePress(
        context: tester.element(find.byType(Form)),
      );

      verify(
        () => mockApprovalRepo.saveApplicationStrategyDetails(
          ServerConstants.commentTypeId[CommentsType.creditAppraisal],
          any<List<Comment>>(),
        ),
      ).called(2);

      expect(viewModel.deleteDraftCalled, 2);
    });
  });

  group("getApplicationStrategyDetails", () {
    test("empty comments -> values remain empty and no controller setText",
        () async {
      when(
        () => mockApprovalRepo.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer((_) async => []);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.comments, isEmpty);
      expect(viewModel.creditBrief, "");
      expect(viewModel.creditAppraisal, "");
      verifyNever(() => mockAppraisalController.setText(any()));
      verifyNever(() => mockBriefController.setText(any()));
    });

    test("matching appraisal and brief comments set fields and controller text",
        () async {
      final comments = [
        Comment(
          categoryId: 99999,
          strategyComment: "ignore me first",
        ),
        Comment(
          categoryId: ServerConstants
              .approvalCategoryId[ApprovalCategory.creditAppraisal],
          strategyComment: "<p>Appraisal Value</p>",
        ),
        Comment(
          categoryId:
              ServerConstants.approvalCategoryId[ApprovalCategory.creditBreif],
          strategyComment: "<p>Brief Value</p>",
        ),
      ];

      when(
        () => mockApprovalRepo.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.comments, isNotNull);
      expect(viewModel.comments!.length, 3);
      expect(viewModel.creditAppraisal, "<p>Appraisal Value</p>");
      expect(viewModel.creditBrief, "<p>Brief Value</p>");

      // first.strategyComment becomes the first matching item
      expect(
        viewModel.comments!.first.strategyComment,
        "<p>Appraisal Value</p>",
      );

      verify(() => mockAppraisalController.setText("<p>Appraisal Value</p>"))
          .called(1);
      verify(() => mockBriefController.setText("<p>Brief Value</p>")).called(1);
    });

    test(
        "brief before appraisal still sets both "
        "and first matching comment becomes brief", () async {
      final comments = [
        Comment(
          categoryId:
              ServerConstants.approvalCategoryId[ApprovalCategory.creditBreif],
          strategyComment: "<p>Brief First</p>",
        ),
        Comment(
          categoryId: ServerConstants
              .approvalCategoryId[ApprovalCategory.creditAppraisal],
          strategyComment: "<p>Appraisal Second</p>",
        ),
      ];

      when(
        () => mockApprovalRepo.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.creditBrief, "<p>Brief First</p>");
      expect(viewModel.creditAppraisal, "<p>Appraisal Second</p>");
      expect(viewModel.comments!.first.strategyComment, "<p>Brief First</p>");

      verify(() => mockBriefController.setText("<p>Brief First</p>")).called(1);
      verify(() => mockAppraisalController.setText("<p>Appraisal Second</p>"))
          .called(1);
    });

    test(
        "non-matching categories -> first "
        "strategyComment becomes commentitem not matched", () async {
      final comments = [
        Comment(
          categoryId: 11111,
          strategyComment: "original value",
        ),
        Comment(
          categoryId: 22222,
          strategyComment: "another value",
        ),
      ];

      when(
        () => mockApprovalRepo.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.comments, isNotNull);
      expect(
        viewModel.comments!.first.strategyComment,
        "commentitem not matched",
      );
      expect(viewModel.creditAppraisal, "");
      expect(viewModel.creditBrief, "");
      verifyNever(() => mockAppraisalController.setText(any()));
      verifyNever(() => mockBriefController.setText(any()));
    });

    test("single non-matching comment becomes commentitem not matched",
        () async {
      final comments = [
        Comment(
          categoryId: 123456,
          strategyComment: "<p>Unknown</p>",
        ),
      ];

      when(
        () => mockApprovalRepo.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.comments, isNotNull);
      expect(viewModel.comments!.length, 1);
      expect(
        viewModel.comments!.first.strategyComment,
        "commentitem not matched",
      );
      expect(viewModel.creditAppraisal, "");
      expect(viewModel.creditBrief, "");
    });

    test("only appraisal comment -> sets only appraisal controller", () async {
      when(
        () => mockApprovalRepo.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer(
        (_) async => [
          Comment(
            categoryId: ServerConstants
                .approvalCategoryId[ApprovalCategory.creditAppraisal],
            strategyComment: "<p>Only Appraisal</p>",
          ),
        ],
      );

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.creditAppraisal, "<p>Only Appraisal</p>");
      expect(viewModel.creditBrief, "");
      verify(() => mockAppraisalController.setText("<p>Only Appraisal</p>"))
          .called(1);
      verifyNever(() => mockBriefController.setText(any()));
    });

    test("only brief comment -> sets only brief controller", () async {
      when(
        () => mockApprovalRepo.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer(
        (_) async => [
          Comment(
            categoryId: ServerConstants
                .approvalCategoryId[ApprovalCategory.creditBreif],
            strategyComment: "<p>Only Brief</p>",
          ),
        ],
      );

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.creditAppraisal, "");
      expect(viewModel.creditBrief, "<p>Only Brief</p>");
      verify(() => mockBriefController.setText("<p>Only Brief</p>")).called(1);
      verifyNever(() => mockAppraisalController.setText(any()));
    });

    test("null strategyComment falls back to empty string for both categories",
        () async {
      when(
        () => mockApprovalRepo.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer(
        (_) async => [
          Comment(
            categoryId: ServerConstants
                .approvalCategoryId[ApprovalCategory.creditAppraisal],
          ),
          Comment(
            categoryId: ServerConstants
                .approvalCategoryId[ApprovalCategory.creditBreif],
          ),
        ],
      );

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.creditAppraisal, "");
      expect(viewModel.creditBrief, "");
      verify(() => mockAppraisalController.setText("")).called(1);
      verify(() => mockBriefController.setText("")).called(1);
    });

    test("empty string strategyComment is passed through as empty string",
        () async {
      when(
        () => mockApprovalRepo.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer(
        (_) async => [
          Comment(
            categoryId: ServerConstants
                .approvalCategoryId[ApprovalCategory.creditAppraisal],
            strategyComment: "",
          ),
          Comment(
            categoryId: ServerConstants
                .approvalCategoryId[ApprovalCategory.creditBreif],
            strategyComment: "",
          ),
        ],
      );

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.creditAppraisal, "");
      expect(viewModel.creditBrief, "");
      verify(() => mockAppraisalController.setText("")).called(1);
      verify(() => mockBriefController.setText("")).called(1);
    });

    test("repository throws -> failure toast", () async {
      when(
        () => mockApprovalRepo.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenThrow(Exception("fetch failed"));

      await viewModel.getApplicationStrategyDetails();

      expect(alertSpy.lastFailure, "Exception: fetch failed");
    });

    test("calling getApplicationStrategyDetails twice refreshes values twice",
        () async {
      when(
        () => mockApprovalRepo.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer(
        (_) async => [
          Comment(
            categoryId: ServerConstants
                .approvalCategoryId[ApprovalCategory.creditAppraisal],
            strategyComment: "<p>Repeat Appraisal</p>",
          ),
        ],
      );

      await viewModel.getApplicationStrategyDetails();
      await viewModel.getApplicationStrategyDetails();

      verify(() => mockAppraisalController.setText("<p>Repeat Appraisal</p>"))
          .called(2);
    });
  });

  group("CreditAssessmentState", () {
    test("constructor sets provided loaderStatus", () {
      const state = CreditAssessmentState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith with null keeps existing values", () {
      const original =
          CreditAssessmentState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();

      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides provided fields and does not mutate original", () {
      const original =
          CreditAssessmentState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);

      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith preserves error when called without values", () {
      const state = CreditAssessmentState(loaderStatus: LoadingStatus.error);
      final copied = state.copyWith();

      expect(copied.loaderStatus, LoadingStatus.error);
    });

    test("copyWith can switch loading to loaded", () {
      const state = CreditAssessmentState(loaderStatus: LoadingStatus.loading);
      final copied = state.copyWith(loaderStatus: LoadingStatus.loaded);

      expect(copied.loaderStatus, LoadingStatus.loaded);
    });
  });
}
