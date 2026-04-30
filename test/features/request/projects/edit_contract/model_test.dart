import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/draft_handler.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/utils/project_contract_numeric_helper.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/project/contract.dart";
import "package:wcas_frontend/models/request/project/link_commitment_number.dart";
import "package:wcas_frontend/models/request/project/ppc.dart";
import "package:wcas_frontend/models/request/project/project.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/project_repository.dart";

/// --------------------
/// Mocks
/// --------------------
class MockProjectRepository extends Mock implements ProjectRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockAlertManager extends Mock implements AlertManager {}

void main() {
  late EditContractViewModel vm;
  late MockProjectRepository projectRepo;

  setUp(() {
    projectRepo = MockProjectRepository();

    vm = EditContractViewModel();

    // Inject repositories directly
    vm.repository = projectRepo;
  });

  tearDown(() async {
    await vm.close();
  });

  // ------------------------------------------------------------
  // BASIC STATE
  // ------------------------------------------------------------
  group("initial state", () {
    test("starts in loading state", () {
      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });

    test("draft keys are correct", () {
      expect(vm.draftModuleKey, DraftModuleKeys.projects);
    });
  });

  // ------------------------------------------------------------
  // MODEL <-> CONTROLLER SYNC
  // ------------------------------------------------------------
  group("model/controller sync", () {
    test("syncModelFromControllers updates contract", () {
      vm.contractorValueController.text = "1000";
      vm.contractorScopeController.text = "Scope";
      vm.customerNameController.text = "Customer";

      vm.syncModelFromControllers();

      expect(vm.contract.contractValue, "1000");
      expect(vm.contract.contractScope, "Scope");
      expect(vm.contract.contractName, "Customer");
    });

    test("syncControllersFromModel populates controllers", () {
      vm.contract
        ..contractName = "ABC"
        ..contractValue = "500"
        ..contractScope = "Test scope"
        ..completionPercentage = 50;

      vm.syncControllersFromModel();

      expect(vm.customerNameController.text, "ABC");
      expect(vm.contractorValueController.text, "500");
      expect(vm.contractorScopeController.text, "Test scope");
    });
  });

  // ------------------------------------------------------------
  // CURRENCY LOGIC
  // ------------------------------------------------------------
  group("currency logic", () {
    test("onCurrencyChanged updates currency and AED flag", () {
      final ref = Reference(name: "AED");

      vm.onCurrencyChanged(ref);

      expect(vm.selectedCurrencyLabel, "AED");
      expect(vm.isAedRates, true);
    });

    test("updateConvertedAmount calculates value", () {
      vm.selectedCurrencyLabel = "USD";
      vm.contractorValueController.text = "100";

      vm.updateConvertedAmount();

      expect(vm.convertedAmountController.text, isNotEmpty);
    });
  });

  // ------------------------------------------------------------
  // COMMENT INPUT LOGIC
  // ------------------------------------------------------------
  group("comments", () {
    test("addCommentInput adds new blank input", () {
      final initial = vm.commentInputs.length;

      vm.addCommentInput();

      expect(vm.commentInputs.length, initial + 1);
    });

    test("updateCommentInput updates input text", () {
      vm.updateCommentInput(0, "Test comment");

      expect(vm.commentInputs[0], "Test comment");
    });

    test("clearCommentInputs resets to single blank", () {
      vm.commentInputs = ["a", "b"];

      vm.clearCommentInputs();

      expect(vm.commentInputs.length, 1);
      expect(vm.commentInputs.first, "");
    });
  });

  // ------------------------------------------------------------
  // PPC ROW LOGIC (NO UI)
  // ------------------------------------------------------------
  group("PPC logic", () {
    test("addPpcRow increases PPC count", () {
      final before = vm.ppc.length;

      vm.addPpcRow();

      expect(vm.ppc.length, before + 1);
    });

    test("removePpcRow removes PPC safely", () {
      vm.addPpcRow();
      vm.addPpcRow();

      final before = vm.ppc.length;

      vm.removePpcRow(0);

      expect(vm.ppc.length, before - 1);
    });
  });

  // ------------------------------------------------------------
  // SAFE CLEANUP
  // ------------------------------------------------------------
  group("dispose", () {
    test("close disposes controllers safely", () async {
      vm.addPpcRow();

      await vm.close();

      expect(vm.ppcControllers, isEmpty);
    });
  });

  group("getcountryCode()", () {
    test("loads country codes and prioritizes AED", () async {
      final vm = EditContractViewModel();
      final repo = MockProjectRepository();

      vm.repository = repo;
      vm.contract = Contract(contractCurrency: "USD");

      when(repo.getcountryCode).thenAnswer(
        (_) async => [
          Reference(name: "USD"),
          Reference(name: "AED"),
          Reference(name: "KWD"),
        ],
      );

      await vm.getcountryCode();

      expect(vm.countryCodes.first.name, ServerConstants.aedCurrency);
      expect(vm.selectedContractValueCurrency?.name, "USD");
      expect(vm.isAedRates, false);
    });

    test("sets AED rate flag when contract currency is AED", () async {
      final vm = EditContractViewModel();
      final repo = MockProjectRepository();

      vm.repository = repo;
      vm.contract = Contract(contractCurrency: "AED");

      when(repo.getcountryCode).thenAnswer(
        (_) async => [Reference(name: "AED")],
      );

      await vm.getcountryCode();

      expect(vm.isAedRates, true);
    });
  });

  group("getContract()", () {
    test("loads contract and populates controllers", () async {
      final vm = EditContractViewModel();
      final repo = MockProjectRepository();

      vm.repository = repo;
      vm.contract = Contract(contractCode: "C1");
      vm.project = Project(projectId: 10);

      final contractFromApi = Contract(
        contractCode: "C1",
        contractName: "Test Contract",
        contractCurrency: "AED",
        contractValue: "1000",
      );

      when(
        () => repo.getContractByContractCodeDetails(
          contractCode: "C1",
        ),
      ).thenAnswer((_) async => contractFromApi);

      when(repo.getcountryCode)
          .thenAnswer((_) async => [Reference(name: "AED")]);

      await vm.getContract();

      expect(vm.contract.contractName, "Test Contract");
      expect(vm.customerNameController.text, "Test Contract");
      expect(vm.contractorValueController.text, "1000");
      expect(vm.selectedCurrencyLabel, "AED");
      expect(vm.isAedRates, true);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("throws when repository fails", () async {
      final vm = EditContractViewModel();
      final repo = MockProjectRepository();

      vm.repository = repo;
      vm.contract = Contract(contractCode: "C1");

      when(
        () => repo.getContractByContractCodeDetails(
          contractCode: "C1",
        ),
      ).thenThrow(Exception("API error"));

      expect(
        () async => vm.getContract(),
        throwsException,
      );
    });
  });

  group("clean()", () {
    test("returns empty string for null", () {
      expect(vm.clean(null), "");
    });

    test('returns empty string for "null" string', () {
      expect(vm.clean("null"), "");
      expect(vm.clean("NULL"), "");
    });

    test("returns string value otherwise", () {
      expect(vm.clean(123), "123");
      expect(vm.clean("abc"), "abc");
    });
  });

  group("onBacktoRequestStatusPressed()", () {
    test("calls autosave when canEdit is true", () async {
      bool autoSaveCalled = false;
      Globals.onAutoSave = () async {
        autoSaveCalled = true;
      };

      vm.pageMode = PageMode.edit; // canEdit = true

      await vm.onBacktoRequestStatusPressed(FakeBuildContext());

      expect(autoSaveCalled, true);
    });

    test("does not throw when context is not mounted", () async {
      vm.pageMode = PageMode.view;

      await vm.onBacktoRequestStatusPressed(
        FakeBuildContext(mountedValue: false),
      );

      expect(true, true); // success = no crash
    });
  });

  group("prefillPpcControllersFromModel()", () {
    test("prefills empty controllers from PPC model", () {
      // Arrange
      final vm = EditContractViewModel();

      // Create one empty PPC controller row
      vm.ppcControllers = [PpcControllers.empty()];

      final ppc = PPC(
        ppcNo: "PPC-1",
        ppcDate: "01/01/2026",
        grossPPCValue: 1000,
        advancePaymentDeduction: 100,
        retentionDeduction: 50,
        vatAmount: 25,
        otherPayment: 10,
        actualPaymentReceived: 815,
        datePaymentReceived: "02/01/2026",
      );

      // Act
      vm.prefillPpcControllersFromModel(0, ppc);

      final c = vm.ppcControllers.first;

      // Assert
      expect(c.ppcCtrl.text, "PPC-1");
      expect(c.ppcDateCtrl.text, isNotEmpty);
      expect(c.grossPPCValueCtrl.text, isNotEmpty);
      expect(c.advancePaymentDeductionCtrl.text, isNotEmpty);
      expect(c.retentionDeductionCtrl.text, isNotEmpty);
      expect(c.vatAmountCtrl.text, isNotEmpty);
      expect(c.otherPaymentCtrl.text, isNotEmpty);
      expect(c.actualPaymentReceivedCtrl.text, isNotEmpty);
      expect(c.datePaymentReceivedCtrl.text, isNotEmpty);
    });

    test("does NOT override existing controller values", () {
      final vm = EditContractViewModel();

      final ctrls = PpcControllers.empty();
      ctrls.ppcCtrl.text = "EXISTING";

      vm.ppcControllers = [ctrls];

      final ppc = PPC(ppcNo: "PPC-NEW");

      vm.prefillPpcControllersFromModel(0, ppc);

      // Existing value must remain
      expect(ctrls.ppcCtrl.text, "EXISTING");
    });

    test("does nothing when index is out of range", () {
      final vm = EditContractViewModel();
      vm.ppcControllers = [];

      vm.prefillPpcControllersFromModel(0, PPC());

      expect(vm.ppcControllers, isEmpty);
    });

    test("does nothing when restoring draft", () {
      final vm = EditContractViewModel();
      vm.isRestoringDraft = true;

      vm.ppcControllers = [PpcControllers.empty()];

      vm.prefillPpcControllersFromModel(0, PPC(ppcNo: "PPC-1"));

      expect(vm.ppcControllers.first.ppcCtrl.text, "");
    });
  });

  group("buildNames()", () {
    test("returns names from refs list", () {
      final options = [
        Reference(id: 1, name: "A"),
        Reference(id: 2, name: "B"),
      ];
      final refs = [
        Reference(id: 1),
        Reference(id: 2),
      ];

      final result = vm.buildNames(refs: refs, options: options);

      expect(result, "A, B");
    });

    test('returns "--" when refs is empty', () {
      final result = vm.buildNames(refs: [], options: []);
      expect(result, "--");
    });

    test("returns name by id", () {
      final options = [Reference(id: 10, name: "X")];

      final result = vm.buildNames(options: options, id: 10);

      expect(result, "X");
    });

    test('returns "--" when id not found', () {
      final result = vm.buildNames(options: [], id: 99);
      expect(result, "--");
    });
  });

  group("mandatoryNumericIfOther()", () {
    late PpcControllers ctrls;

    setUp(() {
      ctrls = PpcControllers.empty();
    });

    test("returns null when row is blank and value is empty", () {
      final result = vm.mandatoryNumericIfOther(
        c: ctrls,
        value: "",
        fieldLabel: "Amount",
      );

      expect(result, null);
    });

    test("returns error when row has data and value is empty", () {
      ctrls.ppcCtrl.text = "1"; // row has other input

      final result = vm.mandatoryNumericIfOther(
        c: ctrls,
        value: "",
        fieldLabel: "Amount",
      );

      expect(
        result,
        "Amount is required because other PPC details are provided.",
      );
    });

    test("returns null for valid numeric value", () {
      ctrls.ppcCtrl.text = "1";

      final result = vm.mandatoryNumericIfOther(
        c: ctrls,
        value: "1234.56",
        fieldLabel: "Amount",
      );

      expect(result, null);
    });

    test("returns format error for invalid numeric value", () {
      ctrls.ppcCtrl.text = "1";

      final result = vm.mandatoryNumericIfOther(
        c: ctrls,
        value: "abc",
        fieldLabel: "Amount",
      );

      expect(result, contains("must be numeric"));
    });
  });

  group("rowHasAnyInput()", () {
    late PpcControllers c;

    setUp(() {
      c = PpcControllers.empty();
    });

    test("returns false when all fields are empty", () {
      expect(vm.rowHasAnyInput(c), false);
    });

    test("returns true when any field has value", () {
      c.ppcCtrl.text = "1";
      expect(vm.rowHasAnyInput(c), true);
    });
  });

  group("recomputeDerivedForSingleRow()", () {
    setUp(() {
      vm.contractValue = 1000;
      vm.contractorValueController.text = "1000";

      vm.ppc = [
        PPC(
          grossPPCValue: 200,
          advancePaymentDeduction: 20,
          retentionDeduction: 10,
          vatAmount: 5,
          otherPayment: 0,
        ),
      ];
    });

    test("does nothing when index is out of range", () {
      vm.recomputeDerivedForSingleRow(5);
      expect(vm.ppc.first.cumulativePPCValue, isNull);
    });

    test("computes cumulative, net and percentages correctly", () {
      vm.recomputeDerivedForSingleRow(0);

      final row = vm.ppc.first;

      expect(row.cumulativePPCValue, 200);
      expect(row.netPPCValue, 170); // 200 - 20 - 10
      expect(row.netCertifiedAmountVat, 175); // net + vat
      expect(row.workDonePercent, isNotNull);
      expect(row.cumulativeWorkDonePercent, isNotNull);
    });

    test("caps applied gross when exceeding contract value", () {
      vm.ppc[0].grossPPCValue = 2000;

      vm.recomputeDerivedForSingleRow(0);

      expect(vm.ppc.first.cumulativePPCValue, 1000);
    });

    test("sets percentages to zero when contract value is zero", () {
      vm.contractValue = 0;
      vm.contractorValueController.text = "0";

      vm.recomputeDerivedForSingleRow(0);

      final row = vm.ppc.first;
      expect(row.workDonePercent, 0);
      expect(row.cumulativeWorkDonePercent, 0);
    });
  });
  group("syncRowFromControllersSoft()", () {
    test("updates PPC row from controllers without recompute", () {
      vm.ppcControllers = [PpcControllers.empty()];
      vm.ppc = [
        PPC(
          ppcId: 1,
          cumulativePpcValue: 100,
          netPpcValue: 50,
        ),
      ];

      final c = vm.ppcControllers.first;
      c.ppcCtrl.text = "10";
      c.grossPPCValueCtrl.text = "200";
      c.commentsCtrl.text = "note";

      vm.syncRowFromControllersSoft(0);

      final row = vm.ppc.first;
      expect(row.ppc, 10);
      expect(row.grossPPCValue, 200);
      expect(row.comments, "note");

      // preserved fields
      expect(row.cumulativePpcValue, 100);
      expect(row.netPpcValue, 50);
    });
  });

  group("rowHasAnyInput()", () {
    late PpcControllers c;

    setUp(() {
      c = PpcControllers.empty();
    });

    test("returns false when all fields are empty", () {
      expect(vm.rowHasAnyInput(c), false);
    });

    test("returns true when any field has value", () {
      c.ppcCtrl.text = "1";
      expect(vm.rowHasAnyInput(c), true);
    });

    test("ignores whitespace-only values", () {
      c.commentsCtrl.text = "   ";
      expect(vm.rowHasAnyInput(c), false);
    });
  });
  group("syncRowFromControllers()", () {
    test("syncs PPC model from controllers and preserves non-controller fields",
        () {
      // Arrange
      vm.ppcControllers = [PpcControllers.empty()];
      vm.ppc = [
        PPC(
          contractorId: "CID",
          ppcNo: "PPC-1",
        ),
      ];

      final c = vm.ppcControllers.first;
      c.ppcCtrl.text = "10";
      c.ppcDateCtrl.text = "01/01/2026";
      c.grossPPCValueCtrl.text = "200";
      c.advancePaymentDeductionCtrl.text = "20";
      c.retentionDeductionCtrl.text = "10";
      c.vatAmountCtrl.text = "5";
      c.otherPaymentCtrl.text = "2";
      c.actualPaymentReceivedCtrl.text = "173";
      c.commentsCtrl.text = "note";

      // Act
      vm.syncRowFromControllers(0);

      final row = vm.ppc.first;

      // Assert – synced values
      expect(row.ppc, 10);
      expect(row.grossPPCValue, 200);
      expect(row.advancePaymentDeduction, 20);
      expect(row.retentionDeduction, 10);
      expect(row.vatAmount, 5);
      expect(row.otherPayment, 2);
      expect(row.actualPaymentReceived, 173);
      expect(row.comments, "note");

      // Assert – preserved fields
      expect(row.contractorId, "CID");
      expect(row.ppcNo, "PPC-1");
    });

    test("does nothing when restoring draft", () {
      vm.isRestoringDraft = true;

      vm.ppcControllers = [PpcControllers.empty()];
      vm.ppc = [PPC(ppcNo: "KEEP")];

      vm.syncRowFromControllers(0);

      expect(vm.ppc.first.ppcNo, "KEEP");
    });
  });

  group("initializeControllers()", () {
    test("creates controllers from PPC rows and updates state", () {
      // Arrange
      final rows = [
        PPC(
          ppcNo: "PPC-1",
          ppcDate: "01/01/2026",
          grossPpcValue: 100,
          advancePaymentDeduction: 10,
          retentionDeduction: 5,
          vatAmount: 2,
          otherPayment: 1,
          actualPaymentReceived: 86,
          comments: "note",
        ),
      ];

      // Act
      vm.initializeControllers(rows);

      // Assert: model list replaced
      expect(vm.ppc.length, 1);
      expect(vm.ppc.first.ppcNo, "PPC-1");

      // Assert: controllers created & prefilled
      final c = vm.ppcControllers.first;
      expect(c.ppcCtrl.text, "PPC-1");
      expect(c.ppcDateCtrl.text, "01/01/2026");
      expect(c.grossPPCValueCtrl.text, isNotEmpty);
      expect(c.advancePaymentDeductionCtrl.text, isNotEmpty);
      expect(c.retentionDeductionCtrl.text, isNotEmpty);
      expect(c.vatAmountCtrl.text, isNotEmpty);
      expect(c.otherPaymentCtrl.text, isNotEmpty);
      expect(c.actualPaymentReceivedCtrl.text, isNotEmpty);
      expect(c.commentsCtrl.text, "note");

      // Assert: generation incremented & state loaded
      expect(vm.ppcControllerGeneration, 1);
      expect(vm.state.ppcStatus, LoadingStatus.loaded);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("handles empty rows safely", () {
      vm.initializeControllers([]);

      expect(vm.ppc, isEmpty);
      expect(vm.ppcControllers, isEmpty);
      expect(vm.ppcControllerGeneration, 1);
    });
  });

  group("submitComments()", () {
    test("returns early when comment text is empty", () async {
      vm.contractorCommentsController.text = "";

      await vm.submitComments();

      expect(vm.contractorCommentsController.text, "");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("onCompletionDateSubmitted2()", () {
    test("sets end date and calls tenor when valid", () {
      vm.contract.expectedStartDate = DateTime(2026, 1, 1);

      vm.onCompletionDateSubmitted2(DateTime(2026, 2, 1));

      expect(vm.contract.expectedEndDate, isNotNull);
      expect(vm.contract.expectedCompletionDate, isNotNull);
      expect(vm.completionDateController.text, isNotEmpty);
      expect(vm.completionDateValidate, false);
    });
  });

  group("callEndDateTenor()", () {
    test("updates end date and completion text", () {
      final date = DateTime(2026, 3, 1);

      vm.callEndDateTenor(date, const YearRules(), isFirst: false);

      expect(vm.contract.expectedCompletionDate, date);
      expect(vm.completionDateController.text, "01/03/2026");
    });
  });

  group("onOriginalCompletionDateSubmitted2()", () {
    test("sets original completion date and variation", () {
      final date = DateTime(2026, 1, 1);

      vm.onOriginalCompletionDateSubmitted2(date);

      expect(vm.contract.originalCompletionDate, date);
      expect(vm.variationCompletionDateController.text, isNotEmpty);
    });

    test("sets NA when date is null", () {
      vm.onOriginalCompletionDateSubmitted2(null);

      expect(vm.variationCompletionDateController.text, "NA");
    });
  });

  group("onSavedTenor()", () {
    test("parses tenor string and sets months", () {
      vm.onSavedTenor("3 Months");

      expect(vm.contract.projectTenor, 3);
    });
  });
  group("enrichLinkCommitmentNumberWith()", () {
    test("does nothing when lists are empty", () {
      vm.contract.linkCommitmentNumberWith = [];
      vm.linkContract = [];

      vm.enrichLinkCommitmentNumberWith();

      expect(vm.contract.linkCommitmentNumberWith, isEmpty);
    });
  });

  group("updateLinkCommitmentNumberWith()", () {
    test("updates list and emits loaded state", () {
      final list = [
        LinkCommitmentNumber(projectAllocationAccount: "X"),
      ];

      vm.updateLinkCommitmentNumberWith(list);

      expect(vm.contract.linkCommitmentNumberWith, list);
      expect(vm.state.linkCommitmentStatus, LoadingStatus.loaded);
    });
  });

  group("linkCommitmentNumberDeleted()", () {
    test("removes item at index", () {
      vm.contract.linkCommitmentNumberWith = [
        LinkCommitmentNumber(projectAllocationAccount: "A"),
        LinkCommitmentNumber(projectAllocationAccount: "B"),
      ];

      vm.linkCommitmentNumberDeleted(0);

      expect(vm.contract.linkCommitmentNumberWith!.length, 1);
      expect(
        vm.contract.linkCommitmentNumberWith!.first.projectAllocationAccount,
        "B",
      );
    });
  });

  group("draftFormKey", () {
    test("returns correct draft form key", () {
      vm.contract = Contract(contractCode: "C123");

      expect(
        vm.draftFormKey,
        "${Routes.editContract}_C123",
      );
    });
  });

  group("draftHandler", () {
    test("returns EditContractDraftHandler instance", () {
      expect(vm.draftHandler, isA<EditContractDraftHandler>());
    });
  });

  group("getContract() – deep unit test", () {
    late TestEditContractViewModel vm;
    late MockProjectRepository repo;

    setUp(() {
      vm = TestEditContractViewModel();
      repo = MockProjectRepository();

      vm.repository = repo;
      vm.contract = Contract(contractCode: "C1");
      vm.project = Project(projectId: 10);
    });

    test("loads contract and updates state correctly", () async {
      final contractFromApi = Contract(
        contractCode: "C1",
        contractName: "Test Contract",
        contractCurrency: "AED",
        contractValue: "1000",
        appRefNo: "APP1",
        ppcList: [
          PPC(ppcNo: "P1"),
        ],
      );

      when(
        () => repo.getContractByContractCodeDetails(
          contractCode: "C1",
        ),
      ).thenAnswer((_) async => contractFromApi);

      await vm.getContract();

      // ✅ repository call
      verify(() => repo.getContractByContractCodeDetails(contractCode: "C1"))
          .called(1);

      // ✅ model assignment
      expect(vm.contract.contractName, "Test Contract");
      expect(vm.contractValue, 1000);

      // ✅ controller updates
      expect(vm.customerNameController.text, "Test Contract");
      expect(vm.contractorValueController.text, "1000");

      // ✅ side effects
      expect(vm.getCountryCalled, true);
      expect(vm.fetchCommentsCalled, true);
      expect(vm.recomputeCalled, true);
      expect(vm.initControllersCalled, true);

      // ✅ PPC logic
      expect(vm.ppc.length, 1);
      expect(vm.isNewRow.first, false);

      // ✅ state
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      expect(vm.state.ppcStatus, LoadingStatus.loaded);
    });
  });

  group("getContractDetailsData()", () {
    test("sets customer name from project contract list", () async {
      final repo = MockProjectRepository();
      final vm = EditContractViewModel()..repository = repo;

      final project = Project(projectId: 1);
      final contract = Contract(contractCode: "C1");

      when(() => repo.getProjectContractDetails(project)).thenAnswer(
        (_) async => [
          Contract(contractCode: "C1", contractName: "Customer X"),
        ],
      );

      await vm.getContractDetailsData(project, contract);

      expect(vm.customerNameController.text, "Customer X");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("getLinkCommitment()", () {
    test("loads linked commitment and updates state", () async {
      final repo = MockProjectRepository();
      final vm = EditContractViewModel()..repository = repo;

      vm.contract = Contract(rimNo: "123");

      when(() => repo.getLinkedCMNForRimDetails(contractRimNo: "123"))
          .thenAnswer(
        (_) async => [
          LinkCommitmentNumber(projectAllocationAccount: "ACC1"),
        ],
      );

      await vm.getLinkCommitment();

      expect(vm.linkContract!.length, 1);
      expect(vm.state.linkCommitmentStatus, LoadingStatus.loaded);
    });
  });

  group("updateVariationField()", () {
    test("calculates variation when AED rates are used", () {
      // Arrange
      vm.isAedRates = true;
      vm.contract
        ..initialContractValue = "100"
        ..contractValue = "120";

      // Act
      vm.updateVariationField();

      // Assert
      expect(vm.variationController.text, isNotEmpty);
      expect(vm.contract.variationAmount, isNotNull);
      expect(vm.contract.variationAmount, greaterThan(0));
      expect(vm.contract.variationContractValue, isNotNull);
    });

    test("calculates variation using AED converted amount when not AED rate",
        () {
      // Arrange
      vm.isAedRates = false;
      vm.contract
        ..initialContractValue = "100"
        ..contractValueAedAmount = "150";

      // Act
      vm.updateVariationField();

      // Assert
      expect(vm.variationController.text, isNotEmpty);
      expect(vm.contract.variationAmount, 50);
    });

    test("sets variationAmount to zero when diff is within epsilon", () {
      // Arrange
      vm.isAedRates = true;
      vm.contract
        ..initialContractValue = "100"
        ..contractValue = "100.0000001";

      // Act
      vm.updateVariationField(epsilon: 1e-3);

      // Assert
      expect(vm.contract.variationAmount, 0);
    });

    test("handles null and non-numeric values safely", () {
      // Arrange
      vm.isAedRates = false;
      vm.contract
        ..initialContractValue = null
        ..contractValueAedAmount = null;

      // Act
      vm.updateVariationField();

      // Assert
      expect(vm.variationController.text, isNotEmpty);
      expect(vm.contract.variationAmount, isNotNull);
    });
  });

  group("role access checks", () {
    setUp(() {
      Globals.user = User(
        id: "1",
        currentRole: Role(
          userRole: UserRole.relationshipManager,
        ),
      );
    });

    test("editAccessRolesCheck returns true for business roles", () {
      Globals.user!.currentRole!.userRole = UserRole.relationshipManager;

      expect(vm.editAccessRolesCheck(), true);
    });

    test("editAccessRolesCheck returns false for credit roles", () {
      Globals.user!.currentRole!.userRole = UserRole.creditAnalyst;

      expect(vm.editAccessRolesCheck(), false);
    });

    test("viewAccessRolesCheck returns true for credit roles", () {
      Globals.user!.currentRole!.userRole = UserRole.creditAnalyst;

      expect(vm.viewAccessRolesCheck(), true);
    });

    test("viewAccessRolesCheck returns false for business roles", () {
      Globals.user!.currentRole!.userRole = UserRole.relationshipManager;

      expect(vm.viewAccessRolesCheck(), false);
    });
  });

  group("mandatoryDateIfOther()", () {
    late PpcControllers c;

    setUp(() {
      c = PpcControllers.empty();
    });

    test("returns null when row is blank and date is empty", () {
      final result = vm.mandatoryDateIfOther(
        c: c,
        value: "",
        fieldLabel: "Date",
      );

      expect(result, null);
    });

    test("returns format error when row is blank and date is invalid", () {
      final result = vm.mandatoryDateIfOther(
        c: c,
        value: "2026-01-01",
        fieldLabel: "Date",
      );

      expect(result, "Date must be in DD/MM/YYYY format.");
    });

    test("returns required error when row has other input and date is empty",
        () {
      c.ppcCtrl.text = "1"; // row has other details

      final result = vm.mandatoryDateIfOther(
        c: c,
        value: "",
        fieldLabel: "Date",
      );

      expect(
        result,
        "Date is required because other PPC details are provided.",
      );
    });

    test("returns null for valid date when row has other input", () {
      c.ppcCtrl.text = "1";

      final result = vm.mandatoryDateIfOther(
        c: c,
        value: "01/01/2026",
        fieldLabel: "Date",
      );

      expect(result, null);
    });
  });

  group("getCommentInputs()", () {
    test("returns the same commentInputs list", () {
      vm.commentInputs = ["a", "b"];

      final result = vm.getCommentInputs();

      expect(result, ["a", "b"]);
    });
  });
  group("onReset()", () {
    test("does nothing when context is not mounted", () async {
      await vm.onReset(FakeBuildContext(mountedValue: false));

      expect(true, true); // success = no crash
    });
  });

  group("isCompletionBeforeStart()", () {
    test("returns true when end date is before start date", () {
      final start = DateTime(2026, 1, 10);
      final end = DateTime(2026, 1, 9);

      expect(vm.isCompletionBeforeStart(start, end), true);
    });

    test("returns false when end date is same or after start date", () {
      final start = DateTime(2026, 1, 10);

      expect(vm.isCompletionBeforeStart(start, DateTime(2026, 1, 10)), false);
      expect(vm.isCompletionBeforeStart(start, DateTime(2026, 1, 11)), false);
    });
  });

  group("draft comment helpers", () {
    test("setDraftComment sets controller text and emits loaded", () {
      vm.setDraftComment("hello");

      expect(vm.contractorCommentsController.text, "hello");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("setDraftComment sets empty string when value is null", () {
      vm.setDraftComment(null);

      expect(vm.contractorCommentsController.text, "");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("clearDraftComment clears controller text and emits loaded", () {
      vm.contractorCommentsController.text = "temp";

      vm.clearDraftComment();

      expect(vm.contractorCommentsController.text, "");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("onBorrowerRoleSelected()", () {
    test("sets borrower role and marks main contractor when id matches", () {
      final ref = Reference(
        id: ServerConstants.mainContractorId,
        name: "Main Contractor",
      );

      vm.onBorrowerRoleSelected(ref);

      expect(vm.selectedBorrowerRole, ref);
      expect(vm.contract.borrowerRole, "Main Contractor");
      expect(vm.contract.isMainContractor, true);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("sets borrower role and marks non-main contractor", () {
      final ref = Reference(
        id: 999,
        name: "Sub Contractor",
      );

      vm.onBorrowerRoleSelected(ref);

      expect(vm.selectedBorrowerRole, ref);
      expect(vm.contract.borrowerRole, "Sub Contractor");
      expect(vm.contract.isMainContractor, false);
    });
  });

  group("disposeControllers()", () {
    test("disposes all PPC controllers and clears the list", () {
      // Arrange
      vm.ppcControllers = [
        PpcControllers.empty(),
        PpcControllers.empty(),
      ];

      expect(vm.ppcControllers.length, 2);

      // Act
      vm.disposeControllers();

      // Assert
      expect(vm.ppcControllers, isEmpty);
    });
  });
}

class FakeBuildContext extends Fake implements BuildContext {
  FakeBuildContext({this.mountedValue = true});

  final bool mountedValue;

  @override
  bool get mounted => mountedValue;
}

class TestEditContractViewModel extends EditContractViewModel {
  // --- side‑effect flags ---
  bool getCountryCalled = false;
  bool fetchCommentsCalled = false;
  bool recomputeCalled = false;
  bool initControllersCalled = false;

  // --- delegation flag ---
  bool updateCalled = false;

  @override
  Future<void> getcountryCode() async {
    getCountryCalled = true;
  }

  @override
  Future<void> fetchAndSetStrategyComments({String? appRefNo}) async {
    fetchCommentsCalled = true;
  }

  @override
  void recomputeDerived() {
    recomputeCalled = true;
  }

  @override
  void initializeControllers(List<PPC> rows) {
    initControllersCalled = true;
    ppc = List<PPC>.from(rows);
    ppcControllers = rows.map((_) => PpcControllers.empty()).toList();
  }

  @override
  void updateConvertedAmount() {
    updateCalled = true;
  }
}
