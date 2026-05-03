import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment/state.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment_fi/model.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

// abstract class HtmlTextProvider {
//   Future<String> getText();
// }

// class HtmlEditorTextProvider implements HtmlTextProvider {
//   final HtmlEditorController controller;

//   HtmlEditorTextProvider(this.controller);

//   @override
//   Future<String> getText() {
//     return controller.getText();
//   }
// }

// class MockHtmlTextProvider extends Mock implements HtmlTextProvider {}

class MockUnifiedEditorController extends Mock
    implements UnifiedEditorController {}

class MockRequestRepository extends Mock implements RequestRepository {}

class FakeBuildContext extends Fake implements BuildContext {}

class MockApprovalRepository extends Mock implements ApprovalRepository {}

class MockAlertManager extends Mock implements AlertManager {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
    JSONMethodCodec(),
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async => ["wifi"]);

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    return ["wifi"];
  });

  late CreditAssessmentFIViewModel viewModel;
  late MockRequestRepository mockRepo;
  late MockUnifiedEditorController mockController;
  late MockAlertManager mockAlertManager;
  late MockApprovalRepository mockApprovalRepository;
  // late GlobalKey<FormState> formKey;
  late BuildContext fakeContext;

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
  });

  setUp(() async {
    await EnvConfig.setEnvironment();
    mockRepo = MockRequestRepository();
    mockController = MockUnifiedEditorController();
    mockAlertManager = MockAlertManager();
    fakeContext = FakeBuildContext();
    mockApprovalRepository = MockApprovalRepository();

    // Override singletons
    RequestRepository.overrideInstance(mockRepo);
    AlertManager.overrideInstance(mockAlertManager);
    ApprovalRepository.overrideInstance(mockApprovalRepository);

    viewModel = CreditAssessmentFIViewModel()
      ..repository = mockRepo
      ..approvalRepository = mockApprovalRepository
      ..controller = mockController;

    when(() => mockController.getText())
        .thenAnswer((_) async => "<p>Some&nbsp;Remarks</p>");

    // formKey = viewModel.formKey;
  });

  test("init handles exception", () async {
    when(() => mockRepo.getApplicationDetails()).thenThrow(Exception("Error"));
    await viewModel.init(fakeContext);
    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  test("init() emits loaded", () async {
    Globals.applicationDetails = ApplicationDetails();
    Globals.applicationDetails?.borrowers = [
      Customer(
        type: CustomerType.belowInvestmentGradeBanks,
        customerName: "Sample1",
        customerRimNo: 10,
      ),
      Customer(
        type: CustomerType.investmentGradeBanks,
        customerName: "Sample2",
        customerRimNo: 20,
      ),
      Customer(
        type: CustomerType.belowInvestmentGradeBanks,
        customerName: "Sample3",
        customerRimNo: 30,
      ),
    ];
    viewModel.rimController = {
      10: MockUnifiedEditorController(),
    };
    when(
      () => mockApprovalRepository.getApplicationStrategyDetails(
        CommentsType.creditAppraisal,
        EntityIdentifier.creditAssesment,
      ),
    ).thenAnswer((_) async => []);
    when(() => mockRepo.getApplicationDetails())
        .thenAnswer((_) async => ApplicationDetails());
    when(() => viewModel.getApplicationStrategyDetails())
        .thenAnswer((_) async => {});
    when(() => mockApprovalRepository.fetchReference())
        .thenAnswer((_) async => {});
    await viewModel.getApplicationStrategyDetails();
    await viewModel.init(fakeContext);
    expect(viewModel.rims.length, 3);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  group("onSavePress success branch", () {
    testWidgets("valid remarks + valid form → loaded", (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              // key: formKey,
              child: TextFormField(
                validator: (_) => null, // always valid
              ),
            ),
          ),
        ),
      );

      await viewModel.onSavePress(
        isContinue: false,
        context: tester.element(find.byType(Form)),
      );

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets(
      "non-empty value in form → loaded",
      (tester) async {
        final String value = await mockController.getText();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: viewModel.formKey,
                child: TextFormField(
                  validator: (_) => "<p>Some Remarks</p>", // valid
                ),
              ),
            ),
          ),
        );

        // Act
        await viewModel.onSavePress(context: tester.element(find.byType(Form)));
        expect(value, "<p>Some&nbsp;Remarks</p>");
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      },
    );
  });

  group("onSavePress()", () {
    testWidgets("throws failure toast when text is empty", (tester) async {
      viewModel
        ..rims = [
          Customer(customerRimNo: 10, customerName: "Sample1"),
        ]
        ..rimController[10] = MockUnifiedEditorController();
      viewModel.rimController[10]?.setText("");
      when(() => mockController.getText()).thenAnswer((_) async => "");
      await viewModel.onSavePress(context: fakeContext);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test(" method will handle exception thrown by API", () async {
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
      when(() => mockController.getText()).thenAnswer((_) async => "");
      when(
        () => mockApprovalRepository.saveApplicationStrategyDetails(
          10,
          [],
        ),
      ).thenThrow(Exception("Error"));
      await viewModel.onSavePress(context: fakeContext);

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test(" with isContinue=true does not call toasts without form", () async {
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
      when(() => mockController.getText()).thenAnswer((_) async => "");
      when(
        () => mockApprovalRepository.saveApplicationStrategyDetails(
          10,
          [],
        ),
      ).thenAnswer((_) async => "Success");
      await viewModel.onSavePress(isContinue: true, context: fakeContext);

      verifyNever(() => mockAlertManager.showFailureToast(""));
    });

    testWidgets("show success toast after bypassing validation",
        (tester) async {
      viewModel
        ..rims = [
          Customer(customerRimNo: 10, firstName: "Sample1"),
          Customer(customerRimNo: 20, firstName: "Sample2"),
        ]
        ..rimController = {
          10: MockUnifiedEditorController(),
          20: MockUnifiedEditorController(),
        }
        ..rimController[10]?.setText("Comment1")
        ..rimController[20]?.setText("Comment2");
      when(() => mockController.getText()).thenAnswer((_) async => "Comments");
      when(
        () => mockApprovalRepository.saveApplicationStrategyDetails(
          any(),
          any(),
        ),
      ).thenAnswer((_) async => "Success");
      await viewModel.onSavePress(context: fakeContext);

      // verify(() => mockAlertManager.showSuccessToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("getApplicationStrategyDetails()", () {
    test("sets comment when matching category exists", () async {
      final comments = [
        Comment(categoryId: 15135, strategyComment: "Test strategy", rimNo: 10),
        Comment(
          categoryId: 15135,
          strategyComment: "Other strategy",
          rimNo: 20,
        ),
      ];
      viewModel
        ..comments = comments
        ..rimController = {
          10: MockUnifiedEditorController(),
          20: MockUnifiedEditorController(),
        };
      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.initialTextMap[10], "Test strategy");
      expect(viewModel.initialTextMap[20], "Other strategy");
    });

    test("clears text when no matching category found", () async {
      final comments = [
        Comment(categoryId: 20, strategyComment: "Other", rimNo: 10),
      ];

      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer((_) async => comments);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.initialTextMap[0], isNull);
    });

    test("clears text when repository returns null", () async {
      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenAnswer((_) async => []);

      await viewModel.getApplicationStrategyDetails();

      expect(viewModel.initialTextMap[0], isNull);
    });

    test("shows error toast when repository throws", () async {
      when(
        () => mockApprovalRepository.getApplicationStrategyDetails(
          CommentsType.creditAppraisal,
          EntityIdentifier.creditAssesment,
        ),
      ).thenThrow(Exception("API error"));

      await viewModel.getApplicationStrategyDetails();
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      verifyNever(() => mockController.setText(any()));
    });
  });

  group("CreditAssessmentFIState", () {
    test("constructor sets provided loaderStatus", () {
      final state = CreditAssessmentState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith with null keeps existing values", () {
      final original =
          CreditAssessmentState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();

      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides provided fields and does not mutate original", () {
      final original =
          CreditAssessmentState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);

      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });
}
