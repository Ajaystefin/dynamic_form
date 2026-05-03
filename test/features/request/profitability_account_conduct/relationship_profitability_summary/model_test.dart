import "package:decimal/decimal.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/draft_handler.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/state.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/profitability/profitability_summary/profitability_data.dart";
import "package:wcas_frontend/models/request/profitability/profitability_summary/raroc_info.dart";
import "package:wcas_frontend/models/request/profitability/profitability_summary/realtionship_profitability.dart";
import "package:wcas_frontend/models/request/profitability/relationship_profitability_summary.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/profitability_repository.dart";

class TestAlertManager implements AlertManager {
  String? lastFailure;
  String? lastSuccess;
  String? lastInfo;
  String? lastWarning;

  @override
  void showFailureToast(String message) => lastFailure = message;

  @override
  void showSuccessToast(String message) => lastSuccess = message;

  @override
  void showInfoToast(String message) => lastInfo = message;

  @override
  void showWarningToast(String message) => lastWarning = message;
}

class MockProfitabilityRepository extends Mock
    implements ProfitabilityRepository {}

class FakeBuildContext extends Fake implements BuildContext {}

/// Safe subclass to cover onSaveAndContinue without hitting:
/// - CommonRepository.instance network
/// - DraftMixin network/timers
/// - Layout navigation side-effects
class HarnessRelationshipProfitabilitySummaryViewModel
    extends RelationshipProfitabilitySummaryViewModel {
  int saveCommentsCalled = 0;
  int saveRelationCalled = 0;
  int deleteDraftCalled = 0;

  bool throwOnSaveComments = false;
  bool throwOnSaveRelation = false;

  @override
  Future<void> saveComments() async {
    saveCommentsCalled++;
    if (throwOnSaveComments) {
      throw Exception("saveComments failed");
    }
  }

  @override
  Future<void> saveRelationProfitDetailSumData() async {
    saveRelationCalled++;
    if (throwOnSaveRelation) {
      throw Exception("saveRelationProfitDetailSumData failed");
    }
  }

  @override
  Future<void> deleteDraft() async {
    deleteDraftCalled++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(RelationshipProfitabilitySummary());
    registerFallbackValue(Comment());
  });

  late RelationshipProfitabilitySummaryViewModel vm;
  late HarnessRelationshipProfitabilitySummaryViewModel harnessVm;
  late MockProfitabilityRepository mockProfitRepo;
  late TestAlertManager alertSpy;

  setUp(() {
    alertSpy = TestAlertManager();
    AlertManager.overrideInstance(alertSpy);

    mockProfitRepo = MockProfitabilityRepository();

    // IMPORTANT: method returns Future<String>, so return a String
    when(() => mockProfitRepo.postRelationshipProfitabilitySummaryData(any()))
        .thenAnswer((_) async => "Success");

    vm = RelationshipProfitabilitySummaryViewModel()
      ..repository = mockProfitRepo;
    harnessVm = HarnessRelationshipProfitabilitySummaryViewModel()
      ..repository = mockProfitRepo;

    Globals.request = null;
  });

  Future<GlobalKey<FormState>> pumpForm(
    WidgetTester tester, {
    String? Function(String?)? validator,
  }) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: TextFormField(
              validator: validator ?? (_) => null,
            ),
          ),
        ),
      ),
    );

    return formKey;
  }

  RelationshipProfitabilitySummary sampleSummaryData() {
    return RelationshipProfitabilitySummary(
      relationshipProfitability: [
        RelationshipProfitability(
          comments: " Comment A ",
          projectedNext12Months: ProfitabilityData(
            nii: "100",
            nfi: "200",
            expectedNetIncome: "300",
            avgCasa: "400",
            rwa: "500",
          ),
          realizedLastYear: ProfitabilityData(
            nii: "150",
            nfi: "250",
            expectedNetIncome: "400",
            avgCasa: "450",
            rwa: "550",
          ),
        ),
        RelationshipProfitability(
          comments: "Comment B",
          projectedNext12Months: ProfitabilityData(
            nii: "10",
            nfi: "20",
            expectedNetIncome: "30",
            avgCasa: "40",
            rwa: "50",
          ),
          realizedLastYear: ProfitabilityData(
            nii: "15",
            nfi: "25",
            expectedNetIncome: "40",
            avgCasa: "45",
            rwa: "55",
          ),
        ),
      ],
      rarocInformation: [
        RarocInformation(
          existingRealizedRarocPercent: "1.1",
          proposedRarocPercentProposedByCoverage: "2.2",
          proposedFinalRarocPercentExAnteRaroc: "3.3",
          comments: "RAROC Comment 1",
        ),
        RarocInformation(
          existingRealizedRarocPercent: "4.4",
          proposedRarocPercentProposedByCoverage: "5.5",
          proposedFinalRarocPercentExAnteRaroc: "6.6",
          comments: "RAROC Comment 2",
        ),
      ],
    );
  }

  group("Constructor / defaults / simple getters", () {
    test("constructor initializes expected defaults", () async {
      final localVm = RelationshipProfitabilitySummaryViewModel();

      expect(localVm.state.loaderStatus, LoadingStatus.loading);
      expect(
        localVm.relationshipProfitabilitySummaryData,
        isA<RelationshipProfitabilitySummary>(),
      );
      expect(localVm.summaryComments, isNull);
      expect(localVm.commentData, isNull);
      expect(localVm.comments, isEmpty);
      expect(localVm.comment, isNull);
      expect(localVm.isFIApplication, false);
      expect(localVm.rowsPerPage, 5);
      expect(localVm.sumProfitabilityData, isNull);
      expect(localVm.groupComments, isNull);
      expect(localVm.realizedRarocControllers, isNull);
      expect(localVm.proposedRarocControllers, isNull);
      expect(localVm.finalRarocControllers, isNull);
      expect(localVm.commentsControllers, isNull);
      expect(localVm.summaryCommentsController.text, "");
      expect(localVm.formKey, isA<GlobalKey<FormState>>());

      await localVm.close();
    });

    test("draft getters return expected values", () {
      expect(vm.draftModuleKey, DraftModuleKeys.profitabilityAndAccountConduct);
      expect(vm.draftFormKey, Routes.relationshipProfitabilitySummary);
      expect(
        vm.draftHandler,
        isA<DraftHandler<RelationshipProfitabilitySummaryViewModel>>(),
      );
      expect(
        vm.draftHandler,
        isA<RelationshipProfitabilitySummaryDraftHandler>(),
      );
    });

    test("canEdit responds to pageMode", () {
      vm.pageMode = PageMode.na;
      expect(vm.canEdit, false);

      vm.pageMode = PageMode.edit;
      expect(vm.canEdit, true);
    });

    test("currentGroupName returns empty when request is null", () {
      Globals.request = null;
      expect(vm.currentGroupName(), "");
    });

    test("currentGroupName returns empty when request groupName is null/empty",
        () {
      Globals.request = Request(groupName: null);
      expect(vm.currentGroupName(), "");

      Globals.request = Request(groupName: "");
      expect(vm.currentGroupName(), "");
    });

    test("currentGroupName returns actual value when present", () {
      Globals.request = Request(groupName: "ACME");
      expect(vm.currentGroupName(), "ACME");
    });

    test("canEditFinalRAROC is a bool", () {
      expect(vm.canEditFinalRAROC, isA<bool>());
    });
  });

  group("Controller cache helpers", () {
    test("getTextController creates and caches controller", () {
      final c1 = vm.getTextController("proj_nii_0", "10");
      final c2 = vm.getTextController("proj_nii_0", "999");

      expect(identical(c1, c2), isTrue);
      expect(c1.text, "10");
      expect(c2.text, "10");
    });

    test("getTextController creates different controller for different keys",
        () {
      final c1 = vm.getTextController("a", "1");
      final c2 = vm.getTextController("b", "2");

      expect(identical(c1, c2), isFalse);
      expect(c1.text, "1");
      expect(c2.text, "2");
    });

    test("getFocusedNode creates and caches node", () {
      final n1 = vm.getFocusedNode("proj_nii_0");
      final n2 = vm.getFocusedNode("proj_nii_0");
      final n3 = vm.getFocusedNode("proj_nfi_0");

      expect(identical(n1, n2), isTrue);
      expect(identical(n1, n3), isFalse);
    });
  });

  group("initializeProfitabilityControllers()", () {
    test(
        "empty relationshipProfitability list still emits"
        " loaded and creates no controllers", () async {
      vm.relationshipProfitabilitySummaryData =
          RelationshipProfitabilitySummary(
        relationshipProfitability: [],
      );

      await vm.initializeProfitabilityControllers();

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      expect(vm.getTextController("some_key").text, "");
    });

    test("null relationshipProfitability list still emits loaded", () async {
      vm.relationshipProfitabilitySummaryData =
          RelationshipProfitabilitySummary(
        relationshipProfitability: null,
      );

      await vm.initializeProfitabilityControllers();

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "creates projected and realized controllers + focus nodes for each row",
        () async {
      vm.relationshipProfitabilitySummaryData = sampleSummaryData();

      await vm.initializeProfitabilityControllers();

      expect(vm.getTextController("proj_nii_0").text, "100");
      expect(vm.getTextController("proj_nfi_0").text, "200");
      expect(vm.getTextController("proj_exp_0").text, "300");
      expect(vm.getTextController("proj_casa_0").text, "400");
      expect(vm.getTextController("proj_rwa_0").text, "500");

      expect(vm.getTextController("real_nii_0").text, "150");
      expect(vm.getTextController("real_nfi_0").text, "250");
      expect(vm.getTextController("real_exp_0").text, "400");
      expect(vm.getTextController("real_casa_0").text, "450");
      expect(vm.getTextController("real_rwa_0").text, "550");

      expect(vm.getTextController("proj_nii_1").text, "10");
      expect(vm.getTextController("real_rwa_1").text, "55");

      expect(vm.getFocusedNode("proj_nii_0"), isA<FocusNode>());
      expect(vm.getFocusedNode("proj_nfi_0"), isA<FocusNode>());
      expect(vm.getFocusedNode("proj_casa_0"), isA<FocusNode>());
      expect(vm.getFocusedNode("proj_rwa_0"), isA<FocusNode>());
      expect(vm.getFocusedNode("real_nii_0"), isA<FocusNode>());
      expect(vm.getFocusedNode("real_nfi_0"), isA<FocusNode>());
      expect(vm.getFocusedNode("real_casa_0"), isA<FocusNode>());
      expect(vm.getFocusedNode("real_rwa_0"), isA<FocusNode>());

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "handles null projected/realized values by creating empty text controllers",
        () async {
      vm.relationshipProfitabilitySummaryData =
          RelationshipProfitabilitySummary(
        relationshipProfitability: [
          RelationshipProfitability(
            projectedNext12Months: ProfitabilityData(),
            realizedLastYear: ProfitabilityData(),
          ),
        ],
      );

      await vm.initializeProfitabilityControllers();

      expect(vm.getTextController("proj_nii_0").text, "");
      expect(vm.getTextController("proj_nfi_0").text, "");
      expect(vm.getTextController("proj_exp_0").text, "");
      expect(vm.getTextController("real_nii_0").text, "");
      expect(vm.getTextController("real_exp_0").text, "");
    });
  });

  group("saveRelationProfitDetailSumData()", () {
    testWidgets("successful save posts summary data", (tester) async {
      vm.formKey = await pumpForm(tester);

      await vm.saveRelationProfitDetailSumData();

      verify(
        () => mockProfitRepo.postRelationshipProfitabilitySummaryData(any()),
      ).called(1);
    });

    testWidgets("repository exception shows toast and emits error",
        (tester) async {
      vm.formKey = await pumpForm(tester);

      when(() => mockProfitRepo.postRelationshipProfitabilitySummaryData(any()))
          .thenThrow(Exception("Save failed"));

      await vm.saveRelationProfitDetailSumData();

      expect(alertSpy.lastFailure, "Exception: Save failed");
      expect(vm.state.loaderStatus, LoadingStatus.error);
    });
  });

  group("onSaveAndContinue() via safe harness subclass", () {
    testWidgets("no mounted form -> catches null currentState and emits error",
        (tester) async {
      harnessVm.formKey = GlobalKey<FormState>();

      await harnessVm.onSaveAndContinue(false, context: FakeBuildContext());

      expect(harnessVm.state.loaderStatus, LoadingStatus.error);
      expect(alertSpy.lastFailure, isNotNull);
      expect(harnessVm.saveCommentsCalled, 0);
      expect(harnessVm.saveRelationCalled, 0);
      expect(harnessVm.deleteDraftCalled, 0);
    });

    testWidgets(
        "invalid form -> does not save and does not show success/failure",
        (tester) async {
      harnessVm.formKey = await pumpForm(
        tester,
        validator: (_) => "invalid",
      );

      await harnessVm.onSaveAndContinue(
        false,
        context: tester.element(find.byType(Form)),
      );

      expect(harnessVm.saveCommentsCalled, 0);
      expect(harnessVm.saveRelationCalled, 0);
      expect(harnessVm.deleteDraftCalled, 0);
      expect(alertSpy.lastSuccess, isNull);
      expect(alertSpy.lastFailure, isNull);
    });

    testWidgets(
        "valid form -> saves "
        "comments, saves "
        "detail, deletes draft, emits loaded", (tester) async {
      harnessVm.formKey = await pumpForm(tester);

      await harnessVm.onSaveAndContinue(
        false,
        context: tester.element(find.byType(Form)),
      );

      expect(harnessVm.saveCommentsCalled, 1);
      expect(harnessVm.saveRelationCalled, 1);
      expect(harnessVm.deleteDraftCalled, 1);
      expect(harnessVm.state.loaderStatus, LoadingStatus.loaded);
      expect(
        alertSpy.lastSuccess,
        "profitabilityAccountConduct."
        "relationshipProfitabilitySummary.savedSuccessfully",
      );
    });

    testWidgets(
        "saveComments throws -> catch branch emits error and failure toast",
        (tester) async {
      harnessVm
        ..formKey = await pumpForm(tester)
        ..throwOnSaveComments = true;

      await harnessVm.onSaveAndContinue(
        false,
        context: tester.element(find.byType(Form)),
      );

      expect(harnessVm.saveCommentsCalled, 1);
      expect(harnessVm.saveRelationCalled, 0);
      expect(harnessVm.deleteDraftCalled, 0);
      expect(harnessVm.state.loaderStatus, LoadingStatus.error);
      expect(alertSpy.lastFailure, contains("saveComments failed"));
    });

    testWidgets(
        "saveRelationProfitDetailSumData throws -> "
        "catch branch emits error and failure toast", (tester) async {
      harnessVm
        ..formKey = await pumpForm(tester)
        ..throwOnSaveRelation = true;

      await harnessVm.onSaveAndContinue(
        false,
        context: tester.element(find.byType(Form)),
      );

      expect(harnessVm.saveCommentsCalled, 1);
      expect(harnessVm.saveRelationCalled, 1);
      expect(harnessVm.deleteDraftCalled, 0);
      expect(harnessVm.state.loaderStatus, LoadingStatus.error);
      expect(
        alertSpy.lastFailure,
        contains("saveRelationProfitDetailSumData failed"),
      );
    });
  });

  group("computeTotalProfitability()", () {
    test("null/empty relationship list -> all summary fields become null",
        () async {
      vm.relationshipProfitabilitySummaryData =
          RelationshipProfitabilitySummary(
        relationshipProfitability: [],
      );

      await vm.computeTotalProfitability();

      expect(vm.sumProfitabilityData, isNotNull);
      expect(vm.sumProfitabilityData!.nii, isNull);
      expect(vm.sumProfitabilityData!.nfi, isNull);
      expect(vm.sumProfitabilityData!.expectedNetIncome, isNull);
      expect(vm.sumProfitabilityData!.avgCasa, isNull);
      expect(vm.sumProfitabilityData!.rwa, isNull);
      expect(vm.sumProfitabilityData!.realizedNii, isNull);
      expect(vm.sumProfitabilityData!.realizedNfi, isNull);
      expect(vm.sumProfitabilityData!.realizedExpectedNetIncome, isNull);
      expect(vm.sumProfitabilityData!.realizedAvgCasa, isNull);
      expect(vm.sumProfitabilityData!.realizedRwa, isNull);
    });

    test(
        "null relationshipProfitability list -> all summary fields become null",
        () async {
      vm.relationshipProfitabilitySummaryData =
          RelationshipProfitabilitySummary(
        relationshipProfitability: null,
      );

      await vm.computeTotalProfitability();

      expect(vm.sumProfitabilityData, isNotNull);
      expect(vm.sumProfitabilityData!.nii, isNull);
      expect(vm.sumProfitabilityData!.realizedNii, isNull);
    });

    test("sums projected and realized values correctly", () async {
      vm.relationshipProfitabilitySummaryData = sampleSummaryData();

      await vm.computeTotalProfitability();

      expect(vm.sumProfitabilityData!.nii, "110");
      expect(vm.sumProfitabilityData!.nfi, "220");
      expect(vm.sumProfitabilityData!.expectedNetIncome, "330");
      expect(vm.sumProfitabilityData!.avgCasa, "440");
      expect(vm.sumProfitabilityData!.rwa, "550");

      expect(vm.sumProfitabilityData!.realizedNii, "165");
      expect(vm.sumProfitabilityData!.realizedNfi, "275");
      expect(vm.sumProfitabilityData!.realizedExpectedNetIncome, "440");
      expect(vm.sumProfitabilityData!.realizedAvgCasa, "495");
      expect(vm.sumProfitabilityData!.realizedRwa, "605");

      expect(vm.groupComments, "Comment A, Comment B");
    });

    test("handles null nested profitability data as zeros", () async {
      vm.relationshipProfitabilitySummaryData =
          RelationshipProfitabilitySummary(
        relationshipProfitability: [
          RelationshipProfitability(
            projectedNext12Months: null,
            realizedLastYear: null,
          ),
        ],
      );

      await vm.computeTotalProfitability();

      expect(vm.sumProfitabilityData!.nii, "0");
      expect(vm.sumProfitabilityData!.nfi, "0");
      expect(vm.sumProfitabilityData!.expectedNetIncome, "0");
      expect(vm.sumProfitabilityData!.avgCasa, "0");
      expect(vm.sumProfitabilityData!.rwa, "0");
      expect(vm.sumProfitabilityData!.realizedNii, "0");
      expect(vm.sumProfitabilityData!.realizedNfi, "0");
      expect(vm.sumProfitabilityData!.realizedExpectedNetIncome, "0");
      expect(vm.sumProfitabilityData!.realizedAvgCasa, "0");
      expect(vm.sumProfitabilityData!.realizedRwa, "0");
    });

    test("handles invalid, empty and comma-formatted numbers gracefully",
        () async {
      vm.relationshipProfitabilitySummaryData =
          RelationshipProfitabilitySummary(
        relationshipProfitability: [
          RelationshipProfitability(
            comments: "  A  ",
            projectedNext12Months: ProfitabilityData(
              nii: "1,000",
              nfi: "abc",
              expectedNetIncome: "",
              avgCasa: null,
              rwa: "-50.5",
            ),
            realizedLastYear: ProfitabilityData(
              nii: " 200 ",
              nfi: "",
              expectedNetIncome: "300.25",
              avgCasa: "x",
              rwa: "1,000.75",
            ),
          ),
        ],
      );

      await vm.computeTotalProfitability();

      expect(vm.sumProfitabilityData!.nii, "1000");
      expect(vm.sumProfitabilityData!.nfi, "0");
      expect(vm.sumProfitabilityData!.expectedNetIncome, "0");
      expect(vm.sumProfitabilityData!.avgCasa, "0");
      expect(vm.sumProfitabilityData!.rwa, "-50.5");

      expect(vm.sumProfitabilityData!.realizedNii, "200");
      expect(vm.sumProfitabilityData!.realizedNfi, "0");
      expect(vm.sumProfitabilityData!.realizedExpectedNetIncome, "300.25");
      expect(vm.sumProfitabilityData!.realizedAvgCasa, "0");
      expect(vm.sumProfitabilityData!.realizedRwa, "1000.75");

      expect(vm.groupComments, "A");
    });

    test("ignores blank comments while joining group comments", () async {
      vm.relationshipProfitabilitySummaryData =
          RelationshipProfitabilitySummary(
        relationshipProfitability: [
          RelationshipProfitability(
            comments: "   ",
            projectedNext12Months: ProfitabilityData(),
            realizedLastYear: ProfitabilityData(),
          ),
          RelationshipProfitability(
            comments: "",
            projectedNext12Months: ProfitabilityData(),
            realizedLastYear: ProfitabilityData(),
          ),
          RelationshipProfitability(
            comments: "Hello",
            projectedNext12Months: ProfitabilityData(),
            realizedLastYear: ProfitabilityData(),
          ),
        ],
      );

      await vm.computeTotalProfitability();

      expect(vm.groupComments, "Hello");
    });
  });

  group("debouncedTotals() and table refresh", () {
    test("debouncedTotals computes totals and sets table loader back to loaded",
        () async {
      vm
        ..relationshipProfitabilitySummaryData =
            RelationshipProfitabilitySummary(
          relationshipProfitability: [
            RelationshipProfitability(
              projectedNext12Months: ProfitabilityData(nii: "10", nfi: "5"),
              realizedLastYear: ProfitabilityData(nii: "20", nfi: "5"),
            ),
          ],
        )
        ..debouncedTotals()
        ..debouncedTotals()
        ..debouncedTotals();

      await Future<void>.delayed(const Duration(milliseconds: 260));
      await Future<void>.delayed(Duration.zero);

      expect(vm.sumProfitabilityData, isNotNull);
      expect(vm.sumProfitabilityData!.nii, "10");
      expect(vm.sumProfitabilityData!.realizedNii, "20");
      expect(vm.state.tableLoaderStatus, LoadingStatus.loaded);
    });

    test("forceTableRefresh pulses tableLoaderStatus back to loaded", () async {
      vm.forceTableRefresh();

      await Future<void>.delayed(Duration.zero);

      expect(vm.state.tableLoaderStatus, LoadingStatus.loaded);
    });

    test("forceTableRefresh can be called repeatedly", () async {
      vm
        ..forceTableRefresh()
        ..forceTableRefresh()
        ..forceTableRefresh();

      await Future<void>.delayed(Duration.zero);

      expect(vm.state.tableLoaderStatus, LoadingStatus.loaded);
    });
  });

  group("calculateExpNetIncome()", () {
    test("projected row calculates expectedNetIncome = nii + nfi", () async {
      vm.relationshipProfitabilitySummaryData =
          RelationshipProfitabilitySummary(
        relationshipProfitability: [
          RelationshipProfitability(
            projectedNext12Months: ProfitabilityData(nii: "12.5", nfi: "7.5"),
            realizedLastYear: ProfitabilityData(nii: "1", nfi: "2"),
          ),
        ],
      );

      await vm.initializeProfitabilityControllers();
      vm.calculateExpNetIncome(0, 0);

      expect(
        vm.relationshipProfitabilitySummaryData!.relationshipProfitability![0]
            .projectedNext12Months!.expectedNetIncome,
        anyOf("20", "20.0"),
      );
      expect(vm.getTextController("proj_exp_0").text, anyOf("20", "20.0"));
    });

    test("realized row calculates expectedNetIncome = nii + nfi", () async {
      vm.relationshipProfitabilitySummaryData =
          RelationshipProfitabilitySummary(
        relationshipProfitability: [
          RelationshipProfitability(
            projectedNext12Months: ProfitabilityData(nii: "1", nfi: "2"),
            realizedLastYear: ProfitabilityData(nii: "10", nfi: "5"),
          ),
        ],
      );

      await vm.initializeProfitabilityControllers();
      vm.calculateExpNetIncome(0, 1);

      expect(
        vm.relationshipProfitabilitySummaryData!.relationshipProfitability![0]
            .realizedLastYear!.expectedNetIncome,
        "15",
      );
      expect(vm.getTextController("real_exp_0").text, "15");
    });

    test("null/invalid values are treated as zero", () async {
      vm.relationshipProfitabilitySummaryData =
          RelationshipProfitabilitySummary(
        relationshipProfitability: [
          RelationshipProfitability(
            projectedNext12Months: ProfitabilityData(nii: null, nfi: "abc"),
            realizedLastYear: ProfitabilityData(nii: "", nfi: null),
          ),
        ],
      );

      await vm.initializeProfitabilityControllers();

      vm.calculateExpNetIncome(0, 0);
      expect(vm.getTextController("proj_exp_0").text, "0");

      vm.calculateExpNetIncome(0, 1);
      expect(vm.getTextController("real_exp_0").text, "0");
    });

    test("null relationshipProfitability list returns normally", () {
      vm.relationshipProfitabilitySummaryData =
          RelationshipProfitabilitySummary(
        relationshipProfitability: null,
      );

      expect(() => vm.calculateExpNetIncome(0, 0), returnsNormally);
    });

    test("empty relationshipProfitability list throws RangeError", () {
      vm.relationshipProfitabilitySummaryData =
          RelationshipProfitabilitySummary(
        relationshipProfitability: [],
      );

      expect(() => vm.calculateExpNetIncome(0, 0), throwsA(isA<RangeError>()));
    });

    test("null summary object returns normally", () {
      vm.relationshipProfitabilitySummaryData = null;

      expect(() => vm.calculateExpNetIncome(0, 0), returnsNormally);
    });
  });

  group("initializeControllers()", () {
    test("empty rarocInformation initializes empty controller lists", () async {
      vm.relationshipProfitabilitySummaryData =
          RelationshipProfitabilitySummary(
        rarocInformation: [],
      );

      await vm.initializeControllers();

      expect(vm.realizedRarocControllers, isEmpty);
      expect(vm.proposedRarocControllers, isEmpty);
      expect(vm.finalRarocControllers, isEmpty);
      expect(vm.commentsControllers, isEmpty);
    });

    test("null rarocInformation initializes empty controller lists", () async {
      vm.relationshipProfitabilitySummaryData =
          RelationshipProfitabilitySummary(
        rarocInformation: null,
      );

      await vm.initializeControllers();

      expect(vm.realizedRarocControllers, isEmpty);
      expect(vm.proposedRarocControllers, isEmpty);
      expect(vm.finalRarocControllers, isEmpty);
      expect(vm.commentsControllers, isEmpty);
    });

    test("populates all RAROC controllers and joins comments with pipe",
        () async {
      vm.relationshipProfitabilitySummaryData = sampleSummaryData();

      await vm.initializeControllers();

      expect(vm.realizedRarocControllers, isNotNull);
      expect(vm.proposedRarocControllers, isNotNull);
      expect(vm.finalRarocControllers, isNotNull);
      expect(vm.commentsControllers, isNotNull);

      expect(vm.realizedRarocControllers!.length, 2);
      expect(vm.proposedRarocControllers!.length, 2);
      expect(vm.finalRarocControllers!.length, 2);
      expect(vm.commentsControllers!.length, 2);

      expect(vm.realizedRarocControllers![0].text, "1.1");
      expect(vm.proposedRarocControllers![0].text, "2.2");
      expect(vm.finalRarocControllers![0].text, "3.3");
      expect(vm.commentsControllers![0].text, "RAROC Comment 1");

      expect(vm.realizedRarocControllers![1].text, "4.4");
      expect(vm.proposedRarocControllers![1].text, "5.5");
      expect(vm.finalRarocControllers![1].text, "6.6");
      expect(vm.commentsControllers![1].text, "RAROC Comment 2");

      expect(vm.groupComments, "RAROC Comment 1 | RAROC Comment 2");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("handles null comment values while joining group comments", () async {
      vm.relationshipProfitabilitySummaryData =
          RelationshipProfitabilitySummary(
        rarocInformation: [
          RarocInformation(
            existingRealizedRarocPercent: "1",
            proposedRarocPercentProposedByCoverage: "2",
            proposedFinalRarocPercentExAnteRaroc: "3",
            comments: null,
          ),
          RarocInformation(
            existingRealizedRarocPercent: "4",
            proposedRarocPercentProposedByCoverage: "5",
            proposedFinalRarocPercentExAnteRaroc: "6",
            comments: "  Keep Me ",
          ),
        ],
      );

      await vm.initializeControllers();

      expect(vm.groupComments, "Keep Me");
      expect(vm.commentsControllers![0].text, "");
      expect(vm.commentsControllers![1].text, "  Keep Me ");
    });

    test("blank comments result in empty joined groupComments", () async {
      vm.relationshipProfitabilitySummaryData =
          RelationshipProfitabilitySummary(
        rarocInformation: [
          RarocInformation(
            existingRealizedRarocPercent: "1",
            proposedRarocPercentProposedByCoverage: "2",
            proposedFinalRarocPercentExAnteRaroc: "3",
            comments: "   ",
          ),
          RarocInformation(
            existingRealizedRarocPercent: "4",
            proposedRarocPercentProposedByCoverage: "5",
            proposedFinalRarocPercentExAnteRaroc: "6",
            comments: "",
          ),
        ],
      );

      await vm.initializeControllers();

      expect(vm.groupComments, "");
      expect(vm.commentsControllers![0].text, "   ");
      expect(vm.commentsControllers![1].text, "");
    });
  });

  group("updateRoracField()", () {
    setUp(() {
      vm.relationshipProfitabilitySummaryData =
          RelationshipProfitabilitySummary(
        rarocInformation: [
          RarocInformation(),
        ],
      );
    });

    test("null rarocInformation list -> returns without crash", () async {
      vm.relationshipProfitabilitySummaryData!.rarocInformation = null;

      await vm.updateRoracField(0, "8.5", RoracFieldType.realizedRaroc);

      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });

    test("invalid index -> returns without crash", () async {
      await vm.updateRoracField(5, "9", RoracFieldType.realizedRaroc);

      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });

    test("updates realizedRaroc field", () async {
      await vm.updateRoracField(0, "7.5", RoracFieldType.realizedRaroc);

      expect(
        vm.relationshipProfitabilitySummaryData!.rarocInformation![0]
            .existingRealizedRarocPercent,
        "7.5",
      );
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updates proposedRaroc field", () async {
      await vm.updateRoracField(0, "8.5", RoracFieldType.proposedRaroc);

      expect(
        vm.relationshipProfitabilitySummaryData!.rarocInformation![0]
            .proposedRarocPercentProposedByCoverage,
        "8.5",
      );
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updates finalRaroc field", () async {
      await vm.updateRoracField(0, "9.5", RoracFieldType.finalRaroc);

      expect(
        vm.relationshipProfitabilitySummaryData!.rarocInformation![0]
            .proposedFinalRarocPercentExAnteRaroc,
        "9.5",
      );
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updates comments field", () async {
      await vm.updateRoracField(0, "hello", RoracFieldType.comments);

      expect(
        vm.relationshipProfitabilitySummaryData!.rarocInformation![0].comments,
        "hello",
      );
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("handles empty and negative values", () async {
      await vm.updateRoracField(0, "", RoracFieldType.realizedRaroc);
      expect(
        vm.relationshipProfitabilitySummaryData!.rarocInformation![0]
            .existingRealizedRarocPercent,
        "",
      );

      await vm.updateRoracField(0, "-5.5", RoracFieldType.proposedRaroc);
      expect(
        vm.relationshipProfitabilitySummaryData!.rarocInformation![0]
            .proposedRarocPercentProposedByCoverage,
        "-5.5",
      );
    });
  });

  group("close()", () {
    test("close disposes created controllers/focus nodes without crashing",
        () async {
      final localVm = RelationshipProfitabilitySummaryViewModel()
        ..relationshipProfitabilitySummaryData = sampleSummaryData();

      await localVm.initializeProfitabilityControllers();
      await localVm.initializeControllers();

      localVm.debouncedTotals();
      await localVm.close();
      expect(true, isTrue);
    });

    test("close works even when nothing was initialized", () async {
      final localVm = RelationshipProfitabilitySummaryViewModel();
      await localVm.close();
      expect(true, isTrue);
    });
  });

  group("Additional property / enum / utility coverage", () {
    test("summaryCommentsController text can be updated", () {
      vm
        ..summaryComments = "Hello"
        ..summaryCommentsController.text = "Hello";

      expect(vm.summaryCommentsController.text, "Hello");
    });

    test("sumProfitabilityData and request properties can be assigned", () {
      vm
        ..isFIApplication = true
        ..sumProfitabilityData = ProfitabilityData(rwa: "1000")
        ..request = Request(applicationRefNo: "REQ-1");

      expect(vm.sumProfitabilityData!.nii, null);
      expect(vm.request!.applicationRefNo, "REQ-1");
    });

    test("RoracFieldType contains all expected enum values", () {
      expect(RoracFieldType.values.length, 4);
      expect(RoracFieldType.values, contains(RoracFieldType.realizedRaroc));
      expect(RoracFieldType.values, contains(RoracFieldType.proposedRaroc));
      expect(RoracFieldType.values, contains(RoracFieldType.finalRaroc));
      expect(RoracFieldType.values, contains(RoracFieldType.comments));
    });

    test("Decimal sanity for totals helper expectations", () {
      expect(Decimal.parse("1.5") + Decimal.parse("2.5"), Decimal.parse("4.0"));
    });

    test("manual property coverage", () {
      vm
        ..context = FakeBuildContext()
        ..comment = Comment(comment: "x")
        ..comments = [Comment(comment: "a"), Comment(comment: "b")]
        ..groupComments = "g"
        ..realizedRarocControllers = [TextEditingController(text: "1")]
        ..proposedRarocControllers = [TextEditingController(text: "2")]
        ..finalRarocControllers = [TextEditingController(text: "3")]
        ..commentsControllers = [TextEditingController(text: "4")];

      expect(vm.context, isNotNull);
      expect(vm.comment!.comment, "x");
      expect(vm.comments.length, 2);
      expect(vm.groupComments, "g");
      expect(vm.realizedRarocControllers!.first.text, "1");
      expect(vm.proposedRarocControllers!.first.text, "2");
      expect(vm.finalRarocControllers!.first.text, "3");
      expect(vm.commentsControllers!.first.text, "4");
    });
  });

  group("RelationshipProfitabilitySummaryState", () {
    test("constructor sets loaderStatus", () {
      final state = RelationshipProfitabilitySummaryState(
        loaderStatus: LoadingStatus.loading,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing when null", () {
      final original = RelationshipProfitabilitySummaryState(
        loaderStatus: LoadingStatus.loaded,
        tableLoaderStatus: LoadingStatus.error,
      );

      final copied = original.copyWith();

      expect(copied.loaderStatus, LoadingStatus.loaded);
      expect(copied.tableLoaderStatus, LoadingStatus.error);
    });

    test("copyWith overrides loaderStatus", () {
      final original = RelationshipProfitabilitySummaryState(
        loaderStatus: LoadingStatus.loaded,
      );

      final updated = original.copyWith(loaderStatus: LoadingStatus.error);

      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides tableLoaderStatus", () {
      final original = RelationshipProfitabilitySummaryState(
        loaderStatus: LoadingStatus.loaded,
        tableLoaderStatus: LoadingStatus.loaded,
      );

      final updated =
          original.copyWith(tableLoaderStatus: LoadingStatus.loading);

      expect(updated.tableLoaderStatus, LoadingStatus.loading);
      expect(original.tableLoaderStatus, LoadingStatus.loaded);
    });
  });
}
