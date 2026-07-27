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
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment_fi/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment_fi/model.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment_fi/state.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

// ----------------------------------------------------------------------------
// Mocks / Fakes
// ----------------------------------------------------------------------------

class MockUnifiedEditorController extends Mock
    implements UnifiedEditorController {}

class MockRequestRepository extends Mock implements RequestRepository {}

class MockApprovalRepository extends Mock implements ApprovalRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class FakeBuildContext extends Fake implements BuildContext {}

class FakeCommentList extends Fake implements List<Comment> {}

// ----------------------------------------------------------------------------
// Testable ViewModel
// ----------------------------------------------------------------------------

class TestCreditAssessmentFIViewModel extends CreditAssessmentFIViewModel {
  bool registerDraftCallbackCalled = false;
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
}

// ----------------------------------------------------------------------------
// Helpers
// ----------------------------------------------------------------------------

Future<BuildContext> pumpViewModelHost(
  WidgetTester tester,
  CreditAssessmentFIViewModel viewModel,
) async {
  late BuildContext capturedContext;

  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<CreditAssessmentFIViewModel>.value(
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

MockUnifiedEditorController mockEditor(String html) {
  final MockUnifiedEditorController controller = MockUnifiedEditorController();

  when(controller.getText).thenAnswer((_) async => html);
  when(() => controller.setText(any())).thenReturn(null);

  return controller;
}

List<Customer> mixedCustomers() {
  return <Customer>[
    Customer(
      type: CustomerType.belowInvestmentGradeBanks,
      customerName: "Bank One",
      firstName: "Bank",
      customerRimNo: 10,
    ),
    Customer(
      type: CustomerType.investmentGradeBanks,
      customerName: "Bank Two",
      firstName: "Bank",
      customerRimNo: 20,
    ),
    Customer(
      customerName: "Ignored Customer",
      firstName: "Ignored",
      customerRimNo: 30,
    ),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
    JSONMethodCodec(),
  );

  late TestCreditAssessmentFIViewModel viewModel;
  late MockRequestRepository mockRequestRepository;
  late MockApprovalRepository mockApprovalRepository;
  late MockAlertManager mockAlertManager;

  setUpAll(() async {
    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(FakeCommentList());

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall methodCall) async => <String>["wifi"],
    );

    try {
      await EasyLocalization.ensureInitialized();
    } on Object {
      // Safe for unit/widget tests where EasyLocalization may already be initialized.
    }
  });

  setUp(() async {
    await EnvConfig.setEnvironment();

    mockRequestRepository = MockRequestRepository();
    mockApprovalRepository = MockApprovalRepository();
    mockAlertManager = MockAlertManager();

    RequestRepository.overrideInstance = mockRequestRepository;
    ApprovalRepository.overrideInstance = mockApprovalRepository;
    AlertManager.overrideInstance = mockAlertManager;

    Globals.sessionID = "session-123";
    Globals.applicationDetails = ApplicationDetails()
      ..borrowers = mixedCustomers();

    viewModel = TestCreditAssessmentFIViewModel()
      ..repository = mockRequestRepository
      ..approvalRepository = mockApprovalRepository;

    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);

    when(() => mockRequestRepository.getApplicationDetails()).thenAnswer(
      (_) async => ApplicationDetails(),
    );

    when(() => mockApprovalRepository.fetchReference()).thenAnswer(
      (_) async {},
    );

    when(
      () => mockApprovalRepository.getApplicationStrategyDetails(
        CommentsType.creditAppraisal,
        EntityIdentifier.creditAssesment,
      ),
    ).thenAnswer((_) async => <Comment>[]);

    when(
      () => mockApprovalRepository.saveApplicationStrategyDetails(
        any(),
        any(),
      ),
    ).thenAnswer((_) async => "Success");
  });

  tearDown(() async {
    await viewModel.close();
  });

  group("draft identity", () {
    test("returns expected draft module key", () {
      expect(viewModel.draftModuleKey, DraftModuleKeys.approval);
    });

    test("returns expected draft form key", () {
      expect(viewModel.draftFormKey, Routes.creditAssessmentFI);
    });

    test("returns CreditAssessmentFIDraftHandler", () {
      final DraftHandler<CreditAssessmentFIViewModel> handler =
          viewModel.draftHandler;

      expect(handler, isA<CreditAssessmentFIDraftHandler>());
    });
  });

  group("constructor", () {
    test("starts with loading state", () {
      final CreditAssessmentFIViewModel vm = CreditAssessmentFIViewModel();

      expect(vm.state.loaderStatus, LoadingStatus.loading);

      unawaited(vm.close());
    });

    test("default fields are initialized", () {
      expect(viewModel.comments, isEmpty);
      expect(viewModel.rims, isEmpty);
      expect(viewModel.canSubmit, isFalse);
      expect(viewModel.rimNo, 0);
      expect(viewModel.initialTextMap, isEmpty);
      expect(viewModel.rimController, isEmpty);
      expect(viewModel.formKey, isA<GlobalKey<FormState>>());
      expect(viewModel.scrollController, isA<ScrollController>());
      expect(viewModel.controller, isA<UnifiedEditorController>());
    });
  });

  group("init()", () {
    testWidgets("loads FI customers, repositories, references and emits loaded",
        (WidgetTester tester) async {
      await pumpViewModelHost(tester, viewModel);

      await viewModel.init(await pumpViewModelHost(tester, viewModel));

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.rims.length, 2);
      expect(viewModel.rims.map((Customer e) => e.customerRimNo), <int?>[
        10,
        20,
      ]);
      expect(viewModel.rimController.containsKey(10), isTrue);
      expect(viewModel.rimController.containsKey(20), isTrue);

      verify(() => mockRequestRepository.getApplicationDetails()).called(1);
      verify(() => mockApprovalRepository.fetchReference()).called(1);
      verify(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).called(1);
    });

    testWidgets("handles null applicationDetails borrowers and emits loaded",
        (WidgetTester tester) async {
      Globals.applicationDetails = ApplicationDetails();

      final BuildContext context = await pumpViewModelHost(tester, viewModel);

      await viewModel.init(context);

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.rims, isEmpty);
      expect(viewModel.rimController, isEmpty);

      verify(() => mockRequestRepository.getApplicationDetails()).called(1);
      verify(() => mockApprovalRepository.fetchReference()).called(1);
    });

    testWidgets("emits error when getApplicationDetails throws",
        (WidgetTester tester) async {
      when(() => mockRequestRepository.getApplicationDetails()).thenThrow(
        Exception("request error"),
      );

      final BuildContext context = await pumpViewModelHost(tester, viewModel);

      await viewModel.init(context);

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    testWidgets("emits error when fetchReference throws",
        (WidgetTester tester) async {
      when(() => mockApprovalRepository.fetchReference()).thenThrow(
        Exception("reference error"),
      );

      final BuildContext context = await pumpViewModelHost(tester, viewModel);

      await viewModel.init(context);

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    testWidgets(
        "handles strategy details exception inside init and still loads",
        (WidgetTester tester) async {
      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenThrow(Exception("strategy error"));

      final BuildContext context = await pumpViewModelHost(tester, viewModel);

      await viewModel.init(context);

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });
  });

  group("onSavePress()", () {
    testWidgets("saves valid remarks, deletes draft, shows success and reloads",
        (WidgetTester tester) async {
      final BuildContext context = await pumpViewModelHost(tester, viewModel);

      viewModel
        ..rims = <Customer>[
          Customer(customerRimNo: 10, customerName: "Bank One"),
          Customer(customerRimNo: 20, customerName: "Bank Two"),
        ]
        ..rimController = <int, UnifiedEditorController>{
          10: mockEditor("<p>First&nbsp;remark</p>"),
          20: mockEditor("<p>Second remark</p>"),
        };

      await viewModel.onSavePress(context: context);

      verify(
        () => mockApprovalRepository.saveApplicationStrategyDetails(
          ServerConstants.commentTypeId[CommentsType.creditAppraisal],
          any(),
        ),
      ).called(1);

      verify(() => mockAlertManager.showSuccessToast(any())).called(1);
      expect(viewModel.deleteDraftCalled, isTrue);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("saves valid remarks with isContinue false and mounted context",
        (WidgetTester tester) async {
      final BuildContext context = await pumpViewModelHost(tester, viewModel);

      viewModel
        ..rims = <Customer>[
          Customer(customerRimNo: 10, customerName: "Bank One"),
        ]
        ..rimController = <int, UnifiedEditorController>{
          10: mockEditor("<div>Valid comment</div>"),
        };

      await viewModel.onSavePress(
        context: context,
      );

      verify(
        () => mockApprovalRepository.saveApplicationStrategyDetails(
          any(),
          any(),
        ),
      ).called(1);
      verify(() => mockAlertManager.showSuccessToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("handles save API exception and emits loaded at end",
        (WidgetTester tester) async {
      final BuildContext context = await pumpViewModelHost(tester, viewModel);

      viewModel
        ..rims = <Customer>[
          Customer(customerRimNo: 10, customerName: "Bank One"),
        ]
        ..rimController = <int, UnifiedEditorController>{
          10: mockEditor("<p>Valid remark</p>"),
        };

      when(
        () => mockApprovalRepository.saveApplicationStrategyDetails(
          any(),
          any(),
        ),
      ).thenThrow(Exception("save failed"));

      await viewModel.onSavePress(context: context);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("handles editor getText exception and emits loaded at end",
        (WidgetTester tester) async {
      final BuildContext context = await pumpViewModelHost(tester, viewModel);

      final MockUnifiedEditorController editor = MockUnifiedEditorController();

      when(editor.getText).thenThrow(Exception("editor failed"));

      viewModel
        ..rims = <Customer>[
          Customer(customerRimNo: 10, customerName: "Bank One"),
        ]
        ..rimController = <int, UnifiedEditorController>{
          10: editor,
        };

      await viewModel.onSavePress(context: context);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("handles empty rims by saving empty comments list",
        (WidgetTester tester) async {
      final BuildContext context = await pumpViewModelHost(tester, viewModel);

      viewModel
        ..rims = <Customer>[]
        ..rimController = <int, UnifiedEditorController>{};

      await viewModel.onSavePress(context: context);

      verify(
        () => mockApprovalRepository.saveApplicationStrategyDetails(
          ServerConstants.commentTypeId[CommentsType.creditAppraisal],
          any(),
        ),
      ).called(1);
      verify(() => mockAlertManager.showSuccessToast(any())).called(1);
      expect(viewModel.deleteDraftCalled, isTrue);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("getApplicationStrategyDetails()", () {
    test("loads comments and sets editor text for matching rim controllers",
        () async {
      final int categoryId =
          ServerConstants.approvalCategoryId[ApprovalCategory.creditAppraisal]!;

      final List<Comment> comments = <Comment>[
        Comment(
          categoryId: categoryId,
          strategyComment: "Strategy one",
          rimNo: 10,
        ),
        Comment(
          categoryId: categoryId,
          strategyComment: "Strategy two",
          rimNo: 20,
        ),
      ];

      final MockUnifiedEditorController editor10 = mockEditor("");
      final MockUnifiedEditorController editor20 = mockEditor("");

      viewModel.rimController = <int, UnifiedEditorController>{
        10: editor10,
        20: editor20,
      };

      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.comments, comments);
      expect(viewModel.initialTextMap[10], "Strategy one");
      expect(viewModel.initialTextMap[20], "Strategy two");

      verify(() => editor10.setText("Strategy one")).called(greaterThan(0));
      verify(() => editor20.setText("Strategy two")).called(greaterThan(0));
    });

    test("sets first comment to matched credit appraisal comment", () async {
      final int creditAppraisalId =
          ServerConstants.approvalCategoryId[ApprovalCategory.creditAppraisal]!;

      final List<Comment> comments = <Comment>[
        Comment(
          categoryId: 999999,
          strategyComment: "Original first",
          rimNo: 10,
        ),
        Comment(
          categoryId: creditAppraisalId,
          strategyComment: "Matched appraisal",
          rimNo: 20,
        ),
      ];

      viewModel.rimController = <int, UnifiedEditorController>{
        10: mockEditor(""),
        20: mockEditor(""),
      };

      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.comments?.first.strategyComment, "Matched appraisal");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("sets first comment to fallback text when no matching category exists",
        () async {
      final List<Comment> comments = <Comment>[
        Comment(
          categoryId: 123456,
          strategyComment: "Unmatched",
          rimNo: 10,
        ),
      ];

      viewModel.rimController = <int, UnifiedEditorController>{
        10: mockEditor(""),
      };

      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.getApplicationStrategyDetails();

      expect(
        viewModel.comments?.first.strategyComment,
        "commentitem not matched",
      );
      expect(viewModel.initialTextMap[10], "commentitem not matched");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("handles comment with null rimNo using rim 0 controller", () async {
      final int categoryId =
          ServerConstants.approvalCategoryId[ApprovalCategory.creditAppraisal]!;

      final MockUnifiedEditorController editor0 = mockEditor("");

      viewModel.rimController = <int, UnifiedEditorController>{
        0: editor0,
      };

      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer(
        (_) async => <Comment>[
          Comment(
            categoryId: categoryId,
            strategyComment: "No rim comment",
          ),
        ],
      );

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.initialTextMap[0], "No rim comment");
      verify(() => editor0.setText("No rim comment")).called(greaterThan(0));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("does not set editor text when controller is missing", () async {
      final int categoryId =
          ServerConstants.approvalCategoryId[ApprovalCategory.creditAppraisal]!;

      viewModel.rimController = <int, UnifiedEditorController>{};

      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer(
        (_) async => <Comment>[
          Comment(
            categoryId: categoryId,
            strategyComment: "Missing controller comment",
            rimNo: 999,
          ),
        ],
      );

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.initialTextMap.containsKey(999), isFalse);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("handles empty comments list and emits loaded", () async {
      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer((_) async => <Comment>[]);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.comments, isEmpty);
      expect(viewModel.initialTextMap, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("handles null comments and emits loaded", () async {
      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer((_) async => []);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.comments, isEmpty);
      expect(viewModel.initialTextMap, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("shows failure toast when repository throws", () async {
      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenThrow(Exception("API error"));

      await viewModel.getApplicationStrategyDetails();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("CreditAssessmentFIState", () {
    test("constructor sets provided loaderStatus", () {
      const CreditAssessmentFIState state =
          CreditAssessmentFIState(loaderStatus: LoadingStatus.loading);

      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith with null keeps existing values", () {
      const CreditAssessmentFIState original =
          CreditAssessmentFIState(loaderStatus: LoadingStatus.loaded);

      final CreditAssessmentFIState copied = original.copyWith();

      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides provided fields and does not mutate original", () {
      const CreditAssessmentFIState original =
          CreditAssessmentFIState(loaderStatus: LoadingStatus.loaded);

      final CreditAssessmentFIState updated = original.copyWith(
        loaderStatus: LoadingStatus.error,
      );

      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });
}
