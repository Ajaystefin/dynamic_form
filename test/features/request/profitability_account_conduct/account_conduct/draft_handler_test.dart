import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/features/request/profitability_account_conduct/account_conduct/draft_handler.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/account_conduct/model.dart";
import "package:wcas_frontend/models/request/profitability/account_conduct.dart";

// ============================================================================
// TEST‑ONLY FakeCustomer
// MUST extend AccountConductDto correctly
// ============================================================================
class FakeCustomer extends AccountConductDto {
  FakeCustomer({
    required int super.rimNo,
    super.passDueOrExcesses,
    super.chequeReturns,
    super.turnoverInAcc,
    super.odHardcore,
    super.unusualTransactions,
    super.transparencyDisclosureLevels,
  }) : super(
          accountConductDetailsList: const [],
        );
}

// ============================================================================
// TEST‑ONLY VIEWMODEL
// ============================================================================
class FakeAccountConductViewModel extends AccountConductViewModel {
  FakeAccountConductViewModel() {
    customers.addAll([
      FakeCustomer(
        rimNo: 101,
        passDueOrExcesses: "1",
        chequeReturns: "2",
        turnoverInAcc: "3",
      ),
      FakeCustomer(
        rimNo: 102,
        passDueOrExcesses: "4",
        chequeReturns: "5",
        turnoverInAcc: "6",
      ),
    ]);
  }

  final Map<String, TextEditingController> _controllers = {};

  @override
  TextEditingController controllerFor(String field, int index) {
    final key = "$field-$index";
    return _controllers.putIfAbsent(
      key,
      TextEditingController.new,
    );
  }
}

// ============================================================================
// TESTS
// ============================================================================
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AccountConductDraftHandler handler;

  setUp(() {
    handler = AccountConductDraftHandler();
  });

  // ---------------------------------------------------------------------------
  // buildDraftData
  // ---------------------------------------------------------------------------
  test("buildDraftData serializes DTO values into draft map", () {
    final vm = FakeAccountConductViewModel();

    final data = handler.buildDraftData(vm);
    final customers = data["customers"] as List;

    expect(customers.length, 2);
    expect(customers[0]["passDueOrExcesses"], "1");
    expect(customers[1]["chequeReturns"], "5");
  });

  test("buildDraftData reflects DTO field changes", () {
    final vm = FakeAccountConductViewModel();

    vm.customers[0] = vm.customers[0].copyWith(
      passDueOrExcesses: "99",
    );

    final data = handler.buildDraftData(vm);
    final customers = data["customers"] as List;

    expect(customers[0]["passDueOrExcesses"], "99");
  });

  // ---------------------------------------------------------------------------
  // applyDraft — merge by RIM
  // ---------------------------------------------------------------------------
  test("applyDraft merges updated fields by rimNo", () {
    final vm = FakeAccountConductViewModel();

    handler.applyDraft(vm, {
      "customers": [
        {
          "rimNo": 102,
          "passDueOrExcesses": "999",
          "chequeReturns": "888",
        }
      ],
    });

    expect(vm.customers[1].passDueOrExcesses, "999");
    expect(vm.customers[1].chequeReturns, "888");

    // other row unchanged
    expect(vm.customers[0].passDueOrExcesses, "1");
  });

  // ---------------------------------------------------------------------------
  // applyDraft — index fallback
  // ---------------------------------------------------------------------------
  test("applyDraft falls back to index merge when rimNo missing", () {
    final vm = FakeAccountConductViewModel();

    handler.applyDraft(vm, {
      "customers": [
        {"passDueOrExcesses": "10"},
        {"passDueOrExcesses": "20"},
      ],
    });

    expect(vm.customers[0].passDueOrExcesses, "10");
    expect(vm.customers[1].passDueOrExcesses, "20");
  });

  // ---------------------------------------------------------------------------
  // controller reseeding & cleaning
  // ---------------------------------------------------------------------------
  test('applyDraft cleans "null" values when reseeding controllers', () {
    final vm = FakeAccountConductViewModel();

    handler.applyDraft(vm, {
      "customers": [
        {"rimNo": 101, "passDueOrExcesses": "null"},
      ],
    });

    expect(
      vm.controllerFor("passDueOrExcesses", 0).text,
      "",
    );
  });

  test("applyDraft updates only provided fields and preserves others", () {
    final vm = FakeAccountConductViewModel();

    handler.applyDraft(vm, {
      "customers": [
        {"rimNo": 101, "passDueOrExcesses": "500"},
      ],
    });

    expect(vm.customers[0].passDueOrExcesses, "500");
    expect(vm.customers[0].chequeReturns, "2");
  });

  // ---------------------------------------------------------------------------
  // defensive paths
  // ---------------------------------------------------------------------------
  test("applyDraft skips invalid but well‑typed rows safely", () {
    final vm = FakeAccountConductViewModel();

    handler.applyDraft(vm, {
      "customers": <Map<String, dynamic>>[
        {},
        {},
      ],
    });

    expect(vm.customers.length, 2);
  });

  test("applyDraft safely ignores excess draft rows", () {
    final vm = FakeAccountConductViewModel();

    handler.applyDraft(vm, {
      "customers": List.generate(
        10,
        (_) => {"passDueOrExcesses": "999"},
      ),
    });

    expect(vm.customers.length, 2);
  });

  test("applyDraft exits cleanly when draft missing", () {
    final vm = FakeAccountConductViewModel();

    handler.applyDraft(vm, {});

    expect(vm.customers.length, 2);
  });
}
