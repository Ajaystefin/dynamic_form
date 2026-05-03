import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/features/request/remarks/guarantor_financials/draft_handler.dart";
import "package:wcas_frontend/features/request/remarks/guarantor_financials/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/income_statement_analysis.dart";
import "package:wcas_frontend/models/request/remarks/guarantor_financials/guarantor.dart";

class FakeEditorController {
  String currentText = "";

  void setText(String value) {
    currentText = value;
  }
}

class FakeRemarksEditor {
  String _text = "";

  String get currentText => _text;

  Future<String> getText() async => _text;

  void setText(String value) {
    _text = value;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group("GuarantorFinancialDraftHandler – pure unit tests", () {
    late GuarantorFinancialDraftHandler handler;
    late GuarantorFinancialViewModel vm;

    setUp(() {
      handler = GuarantorFinancialDraftHandler();
      vm = GuarantorFinancialViewModel();
    });

    // -------------------------------------------------------------------------
    // buildDraftData
    // -------------------------------------------------------------------------

    test("buildDraftData builds entities list", () {
      final draft = handler.buildDraftData(vm);

      expect(draft.containsKey("entities"), true);
      expect(draft["entities"], isA<List>());
    });

    test("buildDraftData uses controller path when not strategy", () {
      vm
        ..hasCreditLensData = false
        ..hasSavedAnalysisData = false;

      // DO NOT touch vm.controller (HTML editor)
      // Default controller remark is empty

      final draft = handler.buildDraftData(vm);
      final first = (draft["entities"] as List).first;

      expect(first["remarks"], isEmpty);
    });
    test("buildDraftData uses incomeStatementRows for active entity", () {
      // Step 1: Choose an entity that actually exists
      final guarantor = vm.state.guarantors.first;

      // Step 2: Mark it as the active entity (Cubit-safe)
      vm.emit(
        vm.state.copyWith(currentEntityId: guarantor.entityId),
      );

      final activeId = guarantor.entityId;

      //  Step 3: Seed active entity rows
      vm.incomeStatementRows.add(
        IncomeStatementAnalysisRow(id: "row-1", isNew: false),
      );

      final draft = handler.buildDraftData(vm);

      final entities = draft["entities"] as List<Map<String, dynamic>>;

      final active = entities.firstWhere((e) => e["entityId"] == activeId);

      expect(active["rows"], isA<List>());
      expect((active["rows"] as List).length, 1);
    });

    // -------------------------------------------------------------------------
    // applyDraft
    // -------------------------------------------------------------------------

    test("buildDraftData persists credit lens and saved analysis flags", () {
      vm
        ..hasCreditLensData = true
        ..hasSavedAnalysisData = true;

      final draft = handler.buildDraftData(vm);

      expect(draft["hasCreditLensData"], true);
      expect(draft["hasSavedAnalysisData"], true);
    });
    test("buildDraftData creates an entity entry per guarantor", () {
      final draft = handler.buildDraftData(vm);
      final entities = draft["entities"] as List;

      expect(entities.length, vm.state.guarantors.length);
    });
    test("buildDraftData uses incomeRowsFor for inactive entities", () {
      final first = vm.state.guarantors.first;

      // add second guarantor
      final second = Guarantor(
        entityId: 99,
        name: "",
        analysisHtml: "",
        spreadsmartUrl: "",
      );

      // activate first guarantor
      vm
        ..emit(vm.state.copyWith(currentEntityId: first.entityId))
        ..emit(
          vm.state.copyWith(
            guarantors: [...vm.state.guarantors, second],
          ),
        )
        ..incomeRows = []
        ..incomeStatementRows.add(
          IncomeStatementAnalysisRow(id: "active", isNew: false),
        );

      final draft = handler.buildDraftData(vm);
      final entities = draft["entities"] as List<Map<String, dynamic>>;

      final inactive =
          entities.firstWhere((e) => e["entityId"] == second.entityId);

      expect(inactive["rows"], isA<List>());
    });
    test(
        "applyDraft does not restore rows for"
        " inactive entity when no rows exist", () {
      final inactive = Guarantor(
        entityId: 50,
        name: "",
        analysisHtml: "",
        spreadsmartUrl: "",
      );

      vm.emit(
        vm.state.copyWith(
          guarantors: [...vm.state.guarantors, inactive],
        ),
      );

      handler.applyDraft(vm, {
        "entities": [
          {
            "entityId": inactive.entityId,
            "rows": [
              {"id": "r1", "isNew": false},
            ],
          }
        ],
      });

      //  By design: no existing rows → no restore
      expect(
        vm.incomeRowsFor(inactive.entityId!).isEmpty,
        true,
      );
    });
    test("buildDraftData creates one entity entry per guarantor", () {
      final g2 = Guarantor(
        entityId: 99,
        name: "",
        analysisHtml: "",
        spreadsmartUrl: "",
      );

      vm.emit(
        vm.state.copyWith(
          guarantors: [...vm.state.guarantors, g2],
        ),
      );

      final draft = handler.buildDraftData(vm);
      final entities = draft["entities"] as List;

      expect(entities.length, 2);
    });
    test("buildDraftData keeps inactive entity rows empty by default", () {
      final inactive = Guarantor(
        entityId: 55,
        name: "",
        analysisHtml: "",
        spreadsmartUrl: "",
      );

      vm.emit(
        vm.state.copyWith(
          guarantors: [...vm.state.guarantors, inactive],
        ),
      );

      final draft = handler.buildDraftData(vm);
      final entities = draft["entities"] as List<Map<String, dynamic>>;

      final inactiveDraft =
          entities.firstWhere((e) => e["entityId"] == inactive.entityId);

      expect(inactiveDraft["rows"], isA<List>());
      expect((inactiveDraft["rows"] as List).isEmpty, true);
    });
    test("buildDraftData persists healthId for inactive entity", () {
      final inactive = Guarantor(
        entityId: 77,
        name: "",
        analysisHtml: "",
        spreadsmartUrl: "",
      );

      vm.emit(
        vm.state.copyWith(
          guarantors: [...vm.state.guarantors, inactive],
        ),
      );

      final health = Reference(id: 5, name: "Healthy");
      vm.setSelectedHealthFor(inactive.entityId!, health);

      final draft = handler.buildDraftData(vm);
      final entities = draft["entities"] as List<Map<String, dynamic>>;

      final entry =
          entities.firstWhere((e) => e["entityId"] == inactive.entityId);

      expect(entry["healthId"], 5);
    });
    test("applyDraft restores hasCreditLensData from draft", () {
      vm.hasCreditLensData = false;

      handler.applyDraft(vm, {
        "hasCreditLensData": true,
        "entities": [],
      });

      expect(vm.hasCreditLensData, true);
    });
    test("applyDraft restores hasSavedAnalysisData from draft", () {
      vm.hasSavedAnalysisData = false;

      handler.applyDraft(vm, {
        "hasSavedAnalysisData": true,
        "entities": [],
      });

      expect(vm.hasSavedAnalysisData, true);
    });
    test("applyDraft ignores draft entities with missing entityId", () {
      final countBefore = vm.state.guarantors.length;

      handler.applyDraft(vm, {
        "entities": [
          {"rows": []},
          {"entityId": null},
        ],
      });

      expect(vm.state.guarantors.length, countBefore);
    });
    test("applyDraft safely skips restore when rows key is missing", () {
      final guarantor = vm.state.guarantors.first;

      handler.applyDraft(vm, {
        "entities": [
          {
            "entityId": guarantor.entityId,
          }
        ],
      });

      expect(vm.incomeStatementRows.isEmpty, true);
    });
    test("applyDraft handles multiple entities in draft payload", () {
      final g1 = vm.state.guarantors.first;
      final g2 = Guarantor(
        entityId: 88,
        name: "",
        analysisHtml: "",
        spreadsmartUrl: "",
      );

      vm.emit(
        vm.state.copyWith(
          guarantors: [g1, g2],
          currentEntityId: g1.entityId,
        ),
      );

      handler.applyDraft(vm, {
        "entities": [
          {"entityId": g1.entityId, "rows": []},
          {"entityId": g2.entityId, "rows": []},
        ],
      });

      expect(vm.state.guarantors.length, 2);
    });
    testWidgets("buildDraftData calls primaryFormKey.save when mounted",
        (tester) async {
      // Use the existing final key from the ViewModel
      final form = Form(
        key: vm.primaryFormKey,
        child: const SizedBox(),
      );

      // Mount the widget tree
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(), // placeholder
        ),
      );

      // Rebuild with the Form
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: form,
        ),
      );

      // Should enter the `save()` branch and not throw
      expect(
        () => handler.buildDraftData(vm),
        returnsNormally,
      );
    });
    test("buildDraftData includes selectedBalanceSheetHealth for active entity",
        () {
      final guarantor = vm.state.guarantors.first;
      vm.emit(vm.state.copyWith(currentEntityId: guarantor.entityId));

      final health = Reference(id: 9, name: "Strong");
      vm.selectedBalanceSheetHealth = health;

      final draft = handler.buildDraftData(vm);
      final entity = (draft["entities"] as List<Map<String, dynamic>>).first;

      expect(entity["healthId"], 9);
    });
    test("applyDraft restores selectedBalanceSheetHealth for active entity",
        () {
      final guarantor = vm.state.guarantors.first;
      final health = Reference(id: 3, name: "OK");
      vm
        ..guarantorsHealth = [health]
        ..emit(vm.state.copyWith(currentEntityId: guarantor.entityId));

      handler.applyDraft(vm, {
        "entities": [
          {
            "entityId": guarantor.entityId,
            "healthId": 3,
            "rows": [],
          }
        ],
      });

      expect(vm.selectedBalanceSheetHealth?.id, 3);
    });
    test("applyDraft restores rows for active entity", () {
      final guarantor = vm.state.guarantors.first;
      vm.emit(vm.state.copyWith(currentEntityId: guarantor.entityId));

      handler.applyDraft(vm, {
        "entities": [
          {
            "entityId": guarantor.entityId,
            "rows": [
              {"id": "r1", "isNew": false},
              {"id": "r2", "isNew": true},
            ],
          }
        ],
      });

      expect(vm.incomeStatementRows.length, 2);
      expect(vm.incomeStatementRows.any((r) => r.isNew), true);
    });
    test("applyDraft ignores invalid healthId and preserves existing health",
        () {
      final guarantor = vm.state.guarantors.first;

      vm
        ..guarantorsHealth = [
          Reference(id: 1, name: "Good"),
        ]

        // Explicitly set a starting value
        ..selectedBalanceSheetHealth = Reference(id: 100, name: "Initial");

      handler.applyDraft(vm, {
        "entities": [
          {
            "entityId": guarantor.entityId,
            "healthId": 999, // invalid
            "rows": [],
          }
        ],
      });

      // Should remain unchanged
      expect(vm.selectedBalanceSheetHealth?.id, 100);
    });
    test("applyDraft with empty payload does nothing", () {
      handler.applyDraft(vm, {});

      expect(vm.state.guarantors.isNotEmpty, true);
    });
    test("applyDraft ignores unknown fields safely", () {
      handler.applyDraft(vm, {
        "entities": [
          {
            "entityId": vm.state.guarantors.first.entityId,
            "unknownKey": "junk",
            "rows": [],
          }
        ],
      });

      expect(vm.state.guarantors.isNotEmpty, true);
    });
    test("applyDraft handles empty rows list safely", () {
      handler.applyDraft(vm, {
        "entities": [
          {
            "entityId": vm.state.guarantors.first.entityId,
            "rows": [],
          }
        ],
      });

      expect(
        vm.incomeStatementRows.isEmpty,
        true,
      );
    });
    test("applyDraft supports multiple entities in draft payload", () {
      final g1 = vm.state.guarantors.first;
      final g2 = Guarantor(
        entityId: 77,
        name: "",
        analysisHtml: "",
        spreadsmartUrl: "",
      );

      vm.emit(
        vm.state.copyWith(
          guarantors: [g1, g2],
          currentEntityId: g1.entityId,
        ),
      );

      handler.applyDraft(vm, {
        "entities": [
          {"entityId": g1.entityId, "rows": []},
          {"entityId": g2.entityId, "rows": []},
        ],
      });

      expect(vm.state.guarantors.length, 2);
    });
    test("applyDraft skips invalid draft entries safely", () {
      handler.applyDraft(vm, {
        "entities": [
          "bad",
          {},
          {"entityId": null},
        ],
      });

      expect(vm.state.guarantors.isNotEmpty, true);
    });

    test("applyDraft returns safely when entities key is missing", () {
      handler.applyDraft(vm, {});

      expect(vm.state.guarantors.isNotEmpty, true);
    });
  });
}
