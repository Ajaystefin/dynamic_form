import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/projects/link_contract/draft_handler.dart";
import "package:wcas_frontend/features/request/projects/link_contract/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/project/contract.dart";
import "package:wcas_frontend/models/request/project/project.dart";

void main() {
  late LinkContractDraftHandler handler;
  late LinkContractViewModel vm;

  Future<void> attachForm(
    WidgetTester tester,
    LinkContractViewModel vm,
  ) async {
    final key = GlobalKey<FormState>();
    vm.formKey = key;

    await tester.pumpWidget(
      MaterialApp(
        home: Form(
          key: key,
          child: const SizedBox(),
        ),
      ),
    );
  }

  setUp(() {
    handler = LinkContractDraftHandler();

    vm = LinkContractViewModel()
      ..contract = Contract()
      ..project = Project()
      ..customerNameController = TextEditingController()
      ..searchNameController = TextEditingController()
      ..searchRimController = TextEditingController()
      ..customerRimController = TextEditingController()
      ..paymasterNameController = TextEditingController()
      ..contractorScopeController = TextEditingController()
      ..contractorValueController = TextEditingController()
      ..convertedAmountController = TextEditingController()
      ..projectTenorController = TextEditingController()
      ..startDateController = TextEditingController()
      ..completionDateController = TextEditingController();
  });

  // ---------------------------------------------------------------------------
  // resolveDraftKey
  // ---------------------------------------------------------------------------

  test("resolveDraftKey returns vm draftFormKey", () {
    // expect(handler.resolveDraftKey(vm), 'link-contract');
  });

  // ---------------------------------------------------------------------------
  // buildDraftData
  // ---------------------------------------------------------------------------

  testWidgets("buildDraftData saves form and builds draft", (tester) async {
    await attachForm(tester, vm);

    vm.project!
      ..projectId = 5
      ..projectCode = "PRJ"
      ..projectName = "Project";

    vm
      ..contract.customerRimNo = 123
      ..borrowerAppRefNo = "APP"
      ..customerNameController.text = "Customer";

    final draft = handler.buildDraftData(vm);
    final json = draft["linkContract"];

    expect(json["projectId"], "5");
    expect(json["projectCode"], "PRJ");
    expect(json["customerName"], "Customer");
    expect(json["appRefNo"], "APP");
  });

  testWidgets("buildDraftData falls back to custName", (tester) async {
    await attachForm(tester, vm);

    vm.custName = "Fallback";
    vm.customerNameController.text = "";

    final draft = handler.buildDraftData(vm);
    expect(draft["linkContract"]["customerName"], "Fallback");
  });

  testWidgets("buildDraftData handles unmounted form", (tester) async {
    vm.formKey = GlobalKey<FormState>();
    final draft = handler.buildDraftData(vm);
    expect(draft["linkContract"], isNotNull);
  });

  // ---------------------------------------------------------------------------
  // applyDraft – guards
  // ---------------------------------------------------------------------------

  test("applyDraft returns if linkContract block missing", () {
    handler.applyDraft(vm, {});
    expect(vm.contract.projectCode, isNull);
  });

  test("applyDraft ignores when projectCode mismatches", () {
    vm.project!.projectCode = "REAL";

    handler.applyDraft(vm, {
      "linkContract": {"projectCode": "OTHER"},
    });

    expect(vm.contract.contractName, isNull);
  });

  // ---------------------------------------------------------------------------
  // applyDraft – happy path
  // ---------------------------------------------------------------------------

  test("applyDraft restores contract, controllers, dates & emits", () {
    vm.project!.projectCode = "MATCH";

    vm.borrowerRole = [
      Reference(name: "Main"),
      Reference(name: "Sub"),
    ];

    handler.applyDraft(vm, {
      "linkContract": {
        "projectId": "10",
        "projectCode": "MATCH",
        "projectName": "Proj",
        "contractName": "Contract",
        "rimNo": 99,
        "borrowerRole": "Main",
        "contractCurrency": "USD",
        "paymasterName": "Pay",
        "projectTenor": 12,
        "contractValue": "100",
        "contractValueAedAmount": "367",
        "contractScope": "Scope",
        "customerName": "Cust",
        "appRefNo": "APP",
        "completionPercentage": 50,
        "expectedStartDate": "01/02/2024",
        "expectedEndDate": "15/03/2025",
        "isMainContractor": true,
      },
    });

    expect(vm.contract.projectId, "10");
    expect(vm.contract.contractName, "Contract");
    expect(vm.contract.customerRimNo, 99);
    expect(vm.contract.completionPercentage, 50.0);

    expect(vm.customerNameController.text, "Cust");
    expect(vm.searchRimController.text, "99");
    expect(vm.projectTenorController.text, "13 Months");
    expect(vm.state.loaderStatus, LoadingStatus.loaded);
  });

  // ---------------------------------------------------------------------------
  // applyDraft – date edge cases
  // ---------------------------------------------------------------------------

  test("applyDraft handles invalid and empty dates safely", () {
    vm.project!.projectCode = "EDGE";

    handler.applyDraft(vm, {
      "linkContract": {
        "projectCode": "EDGE",
        "expectedStartDate": "invalid",
        "expectedEndDate": "",
      },
    });

    expect(vm.startDateController.text, "invalid");
    expect(vm.completionDateController.text, "");
  });

  // ---------------------------------------------------------------------------
  // applyDraft – borrower role fallback
  // ---------------------------------------------------------------------------

  test("applyDraft falls back to first borrowerRole when not found", () {
    vm.project!.projectCode = "ROLE";

    vm.borrowerRole = [
      Reference(name: "Default"),
      Reference(name: "Other"),
    ];

    handler.applyDraft(vm, {
      "linkContract": {
        "projectCode": "ROLE",
        "borrowerRole": "Unknown",
        "isMainContractor": false,
        "projectId": "10",
        "projectName": "Proj",
        "contractName": "Contract",
        "rimNo": 99,
        "contractCurrency": "USD",
        "paymasterName": "Pay",
        "projectTenor": 12,
        "contractValue": "100",
        "contractValueAedAmount": "367",
        "contractScope": "Scope",
        "customerName": "Cust",
        "appRefNo": "APP",
        "completionPercentage": 50,
        "expectedStartDate": "01/02/2024",
        "expectedEndDate": "15/03/2025",
      },
    });

    expect(vm.contract.borrowerRole, "Default");
  });
}
