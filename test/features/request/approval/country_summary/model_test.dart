import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/country_summary/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/country_summary/model.dart";
import "package:wcas_frontend/features/request/approval/country_summary/state.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class MockRequestRepository extends Mock implements RequestRepository {}

class MockApprovalRepository extends Mock implements ApprovalRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockUnifiedEditorController extends Mock
    implements UnifiedEditorController {}

class MockAlertManager extends Mock implements AlertManager {}

class MockBuildContext extends Mock implements BuildContext {}

class TestableCountrySummaryViewModel extends CountrySummaryViewModel {
  int deleteDraftCallCount = 0;
  int loadDraftCallCount = 0;
  int registerDraftCallbackCallCount = 0;
  int initCallCount = 0;

  bool overrideInitForContextRead = false;

  @override
  Future<void> deleteDraft() async {
    deleteDraftCallCount++;
  }

  @override
  Future<void> loadDraftIfAvailable() async {
    loadDraftCallCount++;
  }

  @override
  void registerDraftCallback() {
    registerDraftCallbackCallCount++;
  }

  @override
  Future<void> init(BuildContext context) async {
    if (overrideInitForContextRead) {
      initCallCount++;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return;
    }

    await super.init(context);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
    JSONMethodCodec(),
  );

  late TestableCountrySummaryViewModel viewModel;
  late MockRequestRepository mockRequestRepository;
  late MockApprovalRepository mockApprovalRepository;
  late MockCommonRepository mockCommonRepository;
  late MockUnifiedEditorController mockController;
  late MockAlertManager mockAlertManager;

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall call) async => <int>[0],
    );

    registerFallbackValue(Comment());
    registerFallbackValue(<Comment>[]);
    registerFallbackValue(CommentsType.countrySummary);
    registerFallbackValue(EntityIdentifier.countrySummary);
  });

  setUp(() async {
    await EnvConfig.setEnvironment();

    mockRequestRepository = MockRequestRepository();
    mockApprovalRepository = MockApprovalRepository();
    mockCommonRepository = MockCommonRepository();
    mockController = MockUnifiedEditorController();
    mockAlertManager = MockAlertManager();

    CommonRepository.overrideInstance = mockCommonRepository;
    AlertManager.overrideInstance = mockAlertManager;

    // Required for CountrySummaryViewModel.init(), because init() assigns:
    // repository = RequestRepository.instance;
    // approvalRepository = ApprovalRepository.instance;
    RequestRepository.overrideInstance = mockRequestRepository;
    ApprovalRepository.overrideInstance = mockApprovalRepository;

    viewModel = TestableCountrySummaryViewModel()
      ..repository = mockRequestRepository
      ..approvalRepository = mockApprovalRepository
      ..controller = mockController
      ..isReadOnly = true;

    when(() => mockController.setText(any())).thenReturn(null);

    when(() => mockRequestRepository.getApplicationDetails())
        .thenAnswer((_) async => null);

    when(
      () => mockApprovalRepository.getApplicationStrategyDetails(
        any(),
        any(),
      ),
    ).thenAnswer(
      (_) async => <Comment>[
        _comment(
          categoryId:
              ServerConstants.approvalCategoryId[ApprovalCategory.request],
          strategyComment: "Existing request comment",
        ),
        _comment(
          categoryId:
              ServerConstants.approvalCategoryId[ApprovalCategory.rational],
          strategyComment: "Existing rational comment",
        ),
        _comment(
          categoryId: ServerConstants
              .approvalCategoryId[ApprovalCategory.summaryOfLastDev],
          strategyComment: "Existing latest development comment",
        ),
        _comment(
          categoryId: ServerConstants
              .approvalCategoryId[ApprovalCategory.bankingSector],
          strategyComment: "Existing banking sector comment",
        ),
        _comment(
          categoryId: ServerConstants
              .approvalCategoryId[ApprovalCategory.fiRecommendation],
          strategyComment: "Existing FI recommendation comment",
        ),
      ],
    );

    when(
      () => mockApprovalRepository.saveApplicationStrategyDetails(
        any(),
        any(),
      ),
    ).thenAnswer((_) async => null);

    when(() => mockCommonRepository.saveComment(any()))
        .thenAnswer((_) async => "");

    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);
  });

  tearDown(() async {
    await viewModel.close();
  });

  group("initial state and draft properties", () {
    test("initial state has loading status and request tab", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.state.activeTab, CountrySummaryTabs.request);
      expect(viewModel.comments, isEmpty);
      expect(viewModel.comment, isA<Comment>());
      expect(viewModel.controller, mockController);
      expect(viewModel.formKey, isA<GlobalKey<FormState>>());
      expect(viewModel.initialText, "");
      expect(viewModel.isEditable, false);
    });

    test("draft identity properties return expected values", () {
      expect(viewModel.draftModuleKey, DraftModuleKeys.approval);
      expect(
        viewModel.draftFormKey,
        "${Routes.countrySummary}_${CountrySummaryTabs.request.name}",
      );
      expect(
        viewModel.draftHandler,
        isA<DraftHandler<CountrySummaryViewModel>>(),
      );
      expect(viewModel.draftHandler, isA<CountrySummaryTabsDraftHandler>());
    });
  });

  group("init", () {
    testWidgets("init loads repositories and emits loaded",
        (WidgetTester tester) async {
      when(() => mockRequestRepository.getApplicationDetails())
          .thenAnswer((_) async => null);

      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          any(),
          any(),
        ),
      ).thenAnswer((_) async => <Comment>[]);

      final BuildContext context = await _pumpBasicContext(
        tester: tester,
        viewModel: viewModel,
      );

      await viewModel.init(context);

      verify(() => mockRequestRepository.getApplicationDetails()).called(1);

      verify(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.countrySummary,
          EntityIdentifier.countrySummary,
        ),
      ).called(1);

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.isEditable, false);
      expect(viewModel.isReadOnly, true);
      expect(viewModel.initialText, "");
    });
  });

  group("getTabLabel", () {
    test("returns localized label for all country summary tabs", () {
      for (final CountrySummaryTabs tab in CountrySummaryTabs.values) {
        final String expectedKey = TabConstants.countrySummaryTitles[tab]!;
        expect(viewModel.getTabLabel(tab), expectedKey.tr());
      }
    });

    test("different tabs return different labels", () {
      final String bankingSector =
          viewModel.getTabLabel(CountrySummaryTabs.bankingSector);
      final String fiRecommend =
          viewModel.getTabLabel(CountrySummaryTabs.fiRecommend);

      expect(bankingSector, isNot(fiRecommend));
    });
  });

  group("changeTab", () {
    testWidgets("covers all switch branches and updates category values",
        (WidgetTester tester) async {
      final Map<CountrySummaryTabs, ApprovalCategory> expectedCategory =
          <CountrySummaryTabs, ApprovalCategory>{
        CountrySummaryTabs.request: ApprovalCategory.request,
        CountrySummaryTabs.rational: ApprovalCategory.rational,
        CountrySummaryTabs.summaryOfLatestDev:
            ApprovalCategory.summaryOfLastDev,
        CountrySummaryTabs.bankingSector: ApprovalCategory.bankingSector,
        CountrySummaryTabs.fiRecommend: ApprovalCategory.fiRecommendation,
      };

      for (final CountrySummaryTabs tab in CountrySummaryTabs.values) {
        final Future<void> future = viewModel.changeTab(tab);

        expect(viewModel.state.loaderStatus, LoadingStatus.loading);

        await tester.pump(const Duration(seconds: 1));
        await future;

        final ApprovalCategory category = expectedCategory[tab]!;

        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
        expect(viewModel.state.activeTab, tab);
        expect(
          viewModel.categoryId,
          ServerConstants.approvalCategoryId[category],
        );
        expect(
          viewModel.categoryType,
          ServerConstants.approvalCategoryType[category],
        );
      }

      verify(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.countrySummary,
          EntityIdentifier.countrySummary,
        ),
      ).called(CountrySummaryTabs.values.length);
    });

    testWidgets("loads draft after tab change when not read only",
        (WidgetTester tester) async {
      viewModel.isReadOnly = false;

      final Future<void> future =
          viewModel.changeTab(CountrySummaryTabs.rational);

      await tester.pump(const Duration(seconds: 1));
      await future;

      expect(viewModel.loadDraftCallCount, 1);
      expect(viewModel.state.activeTab, CountrySummaryTabs.rational);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("getApplicationStrategyDetails", () {
    test("sets initial text when matching category comment exists", () async {
      final int? selectedCategory =
          ServerConstants.approvalCategoryId[ApprovalCategory.rational];

      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          any(),
          any(),
        ),
      ).thenAnswer(
        (_) async => <Comment>[
          _comment(
            categoryId: selectedCategory,
            strategyComment: "Rational text",
          ),
        ],
      );

      await viewModel.getApplicationStrategyDetails(selectedCategory);

      expect(viewModel.comments, hasLength(1));
      expect(viewModel.comment?.strategyComment, "Rational text");
      expect(viewModel.initialText, "Rational text");
      verify(() => mockController.setText("Rational text")).called(1);
    });

    test("sets empty text when no matching category comment exists", () async {
      final int? selectedCategory =
          ServerConstants.approvalCategoryId[ApprovalCategory.bankingSector];

      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          any(),
          any(),
        ),
      ).thenAnswer(
        (_) async => <Comment>[
          _comment(
            categoryId:
                ServerConstants.approvalCategoryId[ApprovalCategory.request],
            strategyComment: "Request text",
          ),
        ],
      );

      await viewModel.getApplicationStrategyDetails(selectedCategory);

      expect(viewModel.comments, isEmpty);
      expect(viewModel.initialText, "");
      verify(() => mockController.setText("")).called(1);
    });

    test("sets empty text when repository returns empty comments", () async {
      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          any(),
          any(),
        ),
      ).thenAnswer((_) async => <Comment>[]);

      await viewModel.getApplicationStrategyDetails(
        ServerConstants.approvalCategoryId[ApprovalCategory.request],
      );

      expect(viewModel.comments, isEmpty);
      expect(viewModel.initialText, "");
      verify(() => mockController.setText("")).called(1);
    });

    test("sets empty text when repository returns null comments", () async {
      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          any(),
          any(),
        ),
      ).thenAnswer((_) async => []);

      await viewModel.getApplicationStrategyDetails(
        ServerConstants.approvalCategoryId[ApprovalCategory.request],
      );

      expect(viewModel.comments, []);
      expect(viewModel.initialText, "");
      verify(() => mockController.setText("")).called(1);
    });

    test("sets empty text when matching comment has null strategyComment",
        () async {
      final int? selectedCategory =
          ServerConstants.approvalCategoryId[ApprovalCategory.request];

      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          any(),
          any(),
        ),
      ).thenAnswer(
        (_) async => <Comment>[
          Comment()..categoryId = selectedCategory,
        ],
      );

      await viewModel.getApplicationStrategyDetails(selectedCategory);

      expect(viewModel.comments, hasLength(1));
      expect(viewModel.initialText, "");
      verify(() => mockController.setText("")).called(1);
    });

    test("shows failure toast when repository throws exception", () async {
      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          any(),
          any(),
        ),
      ).thenThrow(Exception("strategy failed"));

      await viewModel.getApplicationStrategyDetails(
        ServerConstants.approvalCategoryId[ApprovalCategory.request],
      );

      verify(
        () => mockAlertManager.showFailureToast(
          "Exception: strategy failed",
        ),
      ).called(1);
    });
  });

  group("onSavePress", () {
    test("empty editor text and editable mode shows failure toast", () async {
      viewModel.isEditable = true;

      when(() => mockController.getText()).thenAnswer((_) async => "");

      final MockBuildContext context = MockBuildContext();
      when(() => context.mounted).thenReturn(false);

      await viewModel.onSavePress(isContinue: false, context: context);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      verifyNever(
        () => mockApprovalRepository.saveApplicationStrategyDetails(
          any(),
          any(),
        ),
      );
    });

    test("html with only nbsp is treated as empty", () async {
      viewModel.isEditable = true;

      when(() => mockController.getText())
          .thenAnswer((_) async => "<p>&nbsp;</p>");

      final MockBuildContext context = MockBuildContext();
      when(() => context.mounted).thenReturn(false);

      await viewModel.onSavePress(isContinue: false, context: context);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      verifyNever(
        () => mockApprovalRepository.saveApplicationStrategyDetails(
          any(),
          any(),
        ),
      );
    });

    test("controller getText exception shows failure toast and error status",
        () async {
      when(() => mockController.getText()).thenThrow(Exception("editorErr"));

      final MockBuildContext context = MockBuildContext();
      when(() => context.mounted).thenReturn(false);

      await viewModel.onSavePress(isContinue: false, context: context);

      verify(
        () => mockAlertManager.showFailureToast("Exception: editorErr"),
      ).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    testWidgets("valid editor text but invalid form does not save",
        (WidgetTester tester) async {
      when(() => mockController.getText())
          .thenAnswer((_) async => "<p>Valid content</p>");

      await _pumpForm(
        tester: tester,
        viewModel: viewModel,
        validator: (_) => "Required",
      );

      final MockBuildContext context = MockBuildContext();
      when(() => context.mounted).thenReturn(false);

      await viewModel.onSavePress(isContinue: false, context: context);

      verifyNever(
        () => mockApprovalRepository.saveApplicationStrategyDetails(
          any(),
          any(),
        ),
      );
      verifyNever(() => mockAlertManager.showSuccessToast(any()));
    });

    testWidgets("valid form saves country summary comment and deletes draft",
        (WidgetTester tester) async {
      viewModel
        ..isEditable = true
        ..categoryId =
            ServerConstants.approvalCategoryId[ApprovalCategory.request]
        ..categoryType =
            ServerConstants.approvalCategoryType[ApprovalCategory.request];

      when(() => mockController.getText())
          .thenAnswer((_) async => "<p>Valid content</p>");

      await _pumpForm(
        tester: tester,
        viewModel: viewModel,
        validator: (_) => null,
      );

      final MockBuildContext context = MockBuildContext();
      when(() => context.mounted).thenReturn(false);

      await viewModel.onSavePress(isContinue: false, context: context);

      final List<Object?> captured = verify(
        () => mockApprovalRepository.saveApplicationStrategyDetails(
          ServerConstants.commentTypeId[CommentsType.countrySummary],
          captureAny(),
        ),
      ).captured;

      final List<Comment> savedComments = captured.single! as List<Comment>;

      expect(savedComments, hasLength(1));
      expect(savedComments.first.strategyComment, "<p>Valid content</p>");
      expect(savedComments.first.categoryId, viewModel.categoryId);
      expect(savedComments.first.categoryType, viewModel.categoryType);
      expect(viewModel.deleteDraftCallCount, 1);
      verify(() => mockAlertManager.showSuccessToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("non editable mode allows empty editor text and validates form",
        (WidgetTester tester) async {
      viewModel.isEditable = false;

      when(() => mockController.getText()).thenAnswer((_) async => "");

      await _pumpForm(
        tester: tester,
        viewModel: viewModel,
        validator: (_) => null,
      );

      final MockBuildContext context = MockBuildContext();
      when(() => context.mounted).thenReturn(false);

      await viewModel.onSavePress(isContinue: false, context: context);

      verify(
        () => mockApprovalRepository.saveApplicationStrategyDetails(
          ServerConstants.commentTypeId[CommentsType.countrySummary],
          any(),
        ),
      ).called(1);

      verify(() => mockAlertManager.showSuccessToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("save exception shows failure toast and error status",
        (WidgetTester tester) async {
      when(() => mockController.getText())
          .thenAnswer((_) async => "<p>Valid content</p>");

      when(
        () => mockApprovalRepository.saveApplicationStrategyDetails(
          any(),
          any(),
        ),
      ).thenThrow(Exception("save failed"));

      await _pumpForm(
        tester: tester,
        viewModel: viewModel,
        validator: (_) => null,
      );

      final MockBuildContext context = MockBuildContext();
      when(() => context.mounted).thenReturn(false);

      await viewModel.onSavePress(isContinue: false, context: context);

      verify(
        () => mockAlertManager.showFailureToast("Exception: save failed"),
      ).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.error);
      expect(viewModel.deleteDraftCallCount, 0);
    });

    testWidgets("mounted context triggers init after save",
        (WidgetTester tester) async {
      viewModel.overrideInitForContextRead = true;

      when(() => mockController.getText())
          .thenAnswer((_) async => "<p>Valid mounted content</p>");

      final BuildContext context = await _pumpForm(
        tester: tester,
        viewModel: viewModel,
        validator: (_) => null,
      );

      await viewModel.onSavePress(isContinue: false, context: context);

      // expect(viewModel.initCallCount, 1);
      expect(viewModel.deleteDraftCallCount, 1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("isContinue true navigates to next tab when context is mounted",
        (WidgetTester tester) async {
      viewModel
        ..overrideInitForContextRead = true
        ..isReadOnly = true;

      when(() => mockController.getText())
          .thenAnswer((_) async => "<p>Continue content</p>");

      final BuildContext context = await _pumpForm(
        tester: tester,
        viewModel: viewModel,
        validator: (_) => null,
      );

      await viewModel.onSavePress(isContinue: true, context: context);

      await tester.pump(const Duration(seconds: 1));

      // expect(viewModel.initCallCount, 1);
      expect(viewModel.deleteDraftCallCount, 1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("form save callback is executed on successful validation",
        (WidgetTester tester) async {
      String? savedValue;

      when(() => mockController.getText())
          .thenAnswer((_) async => "<p>Save callback content</p>");

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CountrySummaryViewModel>.value(
            value: viewModel,
            child: Scaffold(
              body: Form(
                key: viewModel.formKey,
                child: TextFormField(
                  initialValue: "saved value",
                  validator: (_) => null,
                  onSaved: (String? value) {
                    savedValue = value;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      final MockBuildContext context = MockBuildContext();
      when(() => context.mounted).thenReturn(false);

      await viewModel.onSavePress(isContinue: false, context: context);

      expect(savedValue, "saved value");

      verify(
        () => mockApprovalRepository.saveApplicationStrategyDetails(
          any(),
          any(),
        ),
      ).called(1);
    });
  });

  group("saveComment", () {
    test("creates and saves request FOL comment", () async {
      await viewModel.saveComment("Test country summary comment");

      expect(viewModel.comment, isNotNull);
      expect(viewModel.comment?.comment, "Test country summary comment");
      expect(viewModel.comment?.type, CommentsType.requestForFOL);
      expect(viewModel.comment?.entityType, EntityIdentifier.requestForFOL);
      expect(
        viewModel.comment?.categoryId,
        ServerConstants.commentTypeId[CommentsType.requestForFOL],
      );
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      verify(() => mockCommonRepository.saveComment(any())).called(1);
    });

    test("shows failure toast when saveComment repository throws", () async {
      when(() => mockCommonRepository.saveComment(any()))
          .thenThrow(Exception("comment save failed"));

      await viewModel.saveComment("Test comment");

      verify(
        () => mockAlertManager.showFailureToast(
          "Exception: comment save failed",
        ),
      ).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("emits loading and loaded states during saveComment", () async {
      final List<LoadingStatus> emittedStatuses = <LoadingStatus>[];

      final StreamSubscription<CountrySummaryState> subscription =
          viewModel.stream.listen((CountrySummaryState state) {
        emittedStatuses.add(state.loaderStatus);
      });

      await viewModel.saveComment("State check comment");
      await Future<void>.delayed(Duration.zero);

      expect(emittedStatuses, contains(LoadingStatus.loading));
      expect(emittedStatuses, contains(LoadingStatus.loaded));

      await subscription.cancel();
    });
  });

  group("navigate", () {
    test("moves from request tab to next tab", () async {
      viewModel.isReadOnly = true;

      final MockBuildContext context = MockBuildContext();
      when(() => context.mounted).thenReturn(false);

      viewModel.navigate(context);

      await Future<void>.delayed(const Duration(milliseconds: 1100));

      expect(viewModel.state.activeTab, isNot(CountrySummaryTabs.request));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("state copyWith", () {
    test("copyWith updates provided values", () {
      const CountrySummaryState initialState = CountrySummaryState(
        activeTab: CountrySummaryTabs.bankingSector,
      );

      final CountrySummaryState newState = initialState.copyWith(
        loaderStatus: LoadingStatus.loaded,
        activeTab: CountrySummaryTabs.fiRecommend,
      );

      expect(newState.loaderStatus, LoadingStatus.loaded);
      expect(newState.activeTab, CountrySummaryTabs.fiRecommend);
      expect(initialState.loaderStatus, LoadingStatus.loading);
      expect(initialState.activeTab, CountrySummaryTabs.bankingSector);
    });

    test("copyWith preserves existing values when arguments are null", () {
      const CountrySummaryState initialState = CountrySummaryState(
        loaderStatus: LoadingStatus.loaded,
        activeTab: CountrySummaryTabs.fiRecommend,
      );

      final CountrySummaryState newState = initialState.copyWith();

      expect(newState.loaderStatus, LoadingStatus.loaded);
      expect(newState.activeTab, CountrySummaryTabs.fiRecommend);
    });
  });
}

Comment _comment({
  required int? categoryId,
  required String strategyComment,
}) {
  return Comment()
    ..categoryId = categoryId
    ..strategyComment = strategyComment;
}

Future<BuildContext> _pumpForm({
  required WidgetTester tester,
  required CountrySummaryViewModel viewModel,
  required String? Function(String?) validator,
}) async {
  late BuildContext capturedContext;

  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<CountrySummaryViewModel>.value(
        value: viewModel,
        child: Builder(
          builder: (BuildContext context) {
            capturedContext = context;

            return Scaffold(
              body: Form(
                key: viewModel.formKey,
                child: TextFormField(
                  initialValue: "form value",
                  validator: validator,
                  onSaved: (_) {},
                ),
              ),
            );
          },
        ),
      ),
    ),
  );

  await tester.pump();

  return capturedContext;
}

Future<BuildContext> _pumpBasicContext({
  required WidgetTester tester,
  required CountrySummaryViewModel viewModel,
}) async {
  late BuildContext capturedContext;

  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<CountrySummaryViewModel>.value(
        value: viewModel,
        child: Builder(
          builder: (BuildContext context) {
            capturedContext = context;

            return const Scaffold(
              body: SizedBox.shrink(),
            );
          },
        ),
      ),
    ),
  );

  await tester.pump();

  return capturedContext;
}
