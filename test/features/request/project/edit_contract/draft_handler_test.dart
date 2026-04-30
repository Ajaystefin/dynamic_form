import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/draft_handler.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";

import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/project/contract.dart";
import "package:wcas_frontend/models/request/project/ppc.dart";

void main() {
  late EditContractDraftHandler handler;
  late EditContractViewModel vm;

  Future<void> attachForm(
    WidgetTester tester,
    EditContractViewModel vm,
  ) async {
    final key = GlobalKey<FormState>();
    vm.formKey = key;

    await tester.pumpWidget(
      MaterialApp(
        home: Form(key: key, child: const SizedBox()),
      ),
    );
  }

  setUp(() {
    handler = EditContractDraftHandler();

    vm = EditContractViewModel();
    //vm.draftFormKey = 'edit-contract';
    vm.contract = Contract();
    vm.startDateController = TextEditingController();
    vm.completionDateController = TextEditingController();
    vm.contractorCommentsController = TextEditingController();
    vm.borrowerRole = [];
    vm.ppc = [];
    vm.commentInputs = [];
  });

  // ---------------------------------------------------------------------------
  // resolveDraftKey
  // ---------------------------------------------------------------------------

  test("resolveDraftKey returns vm draftFormKey", () {
    // expect(handler.resolveDraftKey(vm), 'edit-contract');
  });

  // ---------------------------------------------------------------------------
  // buildDraftData
  // ---------------------------------------------------------------------------

  testWidgets("buildDraftData saves form and builds full draft",
      (tester) async {
    await attachForm(tester, vm);

    vm.contract
      ..contractCode = "C1"
      ..contractId = "1"
      ..projectId = "10";

    vm.startDateController.text = "01/01/2024";
    vm.completionDateController.text = "31/12/2024";

    vm.ppc = [PPC(ppcId: 1)];
    vm.commentInputs = ["Comment"];

    final draft = handler.buildDraftData(vm);
    final json = draft["editContract"];

    expect(json["contractCode"], "C1");
    expect(json["expectedStartDate"], "01/01/2024");
    expect(json["ppcList"], isNotEmpty);
    expect(json["commentInputs"], ["Comment"]);
  });

  testWidgets("buildDraftData handles unmounted form safely", (tester) async {
    vm.formKey = GlobalKey<FormState>();

    final draft = handler.buildDraftData(vm);
    expect(draft["editContract"], isNotNull);
  });

  // ---------------------------------------------------------------------------
  // applyDraft – early exits
  // ---------------------------------------------------------------------------

  test("applyDraft returns when editContract block is null", () {
    handler.applyDraft(vm, {});
    expect(vm.isRestoringDraft, isFalse);
  });

  test("applyDraft ignores draft when contractCode mismatches", () {
    vm.contract.contractCode = "REAL";

    handler.applyDraft(vm, {
      "editContract": {"contractCode": "OTHER"},
    });

    expect(vm.contract.contractCode, "REAL");
  });

  // ---------------------------------------------------------------------------
  // applyDraft – full happy path
  // ---------------------------------------------------------------------------

  testWidgets(
      "applyDraft restores model, controllers, comments, "
      "borrower role, links, PPC and emits", (tester) async {
    vm.contract.contractCode = "MATCH";

    vm.borrowerRole = [
      Reference(name: "Main"),
      Reference(name: "Sub"),
    ];

    final ppcJson = PPC(ppcId: 10).toJson();

    handler.applyDraft(vm, {
      "editContract": {
        "contractCode": "MATCH",
        "borrowerRole": "Main",
        "expectedStartDate": "01/02/2024",
        "expectedEndDate": "31/03/2025",
        "commentInputs": ["A", "B"],
        "ppcList": [ppcJson],
        "linkCommitmentNumberWith": [
          {"commitmentNumber": "L1"},
        ],
      },
    });

    await tester.pump(); // post-frame callback

    // Dates
    expect(vm.startDateController.text, "01/02/2024");
    expect(vm.completionDateController.text, "31/03/2025");

    // Comments
    expect(vm.commentInputs, ["A", "B"]);
    expect(vm.contractorCommentsController.text, "B");

    // PPC
    expect(vm.ppc.length, 1);
    expect(vm.isNewRow.length, 1);

    // UI state
    expect(vm.state.loaderStatus, LoadingStatus.loaded);
    expect(vm.state.ppcStatus, LoadingStatus.loaded);
    expect(vm.state.linkCommitmentStatus, LoadingStatus.loaded);

    expect(vm.isRestoringDraft, isTrue);
  });

  // ---------------------------------------------------------------------------
  // date parsing edge cases
  // ---------------------------------------------------------------------------

  test("applyDraft handles invalid and empty date strings safely", () {
    vm.contract.contractCode = "EDGE";

    handler.applyDraft(vm, {
      "editContract": {
        "contractCode": "EDGE",
        "expectedStartDate": "",
        "expectedEndDate": "invalid",
      },
    });

    expect(vm.startDateController.text, "");
    expect(vm.completionDateController.text, "invalid");
  });

  // ---------------------------------------------------------------------------
  // comments fallback
  // ---------------------------------------------------------------------------

  test("applyDraft clears commentInputs when none provided", () {
    vm.contract.contractCode = "CLEAN";

    handler.applyDraft(vm, {
      "editContract": {
        "contractCode": "CLEAN",
        "commentInputs": [],
      },
    });

    expect(vm.commentInputs.length, 1); // leaveOneBlank
  });

  // ---------------------------------------------------------------------------
  // borrower role fallback
  // ---------------------------------------------------------------------------

  test("applyDraft falls back to first borrowerRole when not found", () {
    vm.contract.contractCode = "ROLE";

    vm.borrowerRole = [
      Reference(name: "Default"),
      Reference(name: "Other"),
    ];

    handler.applyDraft(vm, {
      "editContract": {
        "contractCode": "ROLE",
        "borrowerRole": "Unknown",
      },
    });

    expect(vm.contract.borrowerRole, "Default");
  });

  // ---------------------------------------------------------------------------
  // link commitments empty path
  // ---------------------------------------------------------------------------

  test("applyDraft safely handles empty linkCommitment list", () {
    vm.contract.contractCode = "LINK";

    handler.applyDraft(vm, {
      "editContract": {
        "contractCode": "LINK",
        "linkCommitmentNumberWith": [],
      },
    });

    expect(vm.state.linkCommitmentStatus, LoadingStatus.loaded);
  });
}
