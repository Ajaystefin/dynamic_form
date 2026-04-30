import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/features/request/remarks/fee_structure/draft_handler.dart";
import "package:wcas_frontend/features/request/remarks/fee_structure/model.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/remarks/fee_structure.dart";

/// A lightweight test double that avoids localization-driven assertions
/// and lets us spy on onAmountFieldChanged.
class _TestFeeStructureViewModel extends FeeStructureViewModel {
  _TestFeeStructureViewModel() : super();

  // Deterministic fee types for assertions.
  @override
  List<String> get defaultFeeTypes => <String>[
        "Arrangement Fee",
        "Processing Fee",
        "Commitment Fee",
        "Prepayment Fee",
        "Breach of Covenant",
      ];

  int? lastAmountChangedIndex;
  String? lastAmountChangedValue;
  int amountChangeCallCount = 0;

  @override
  void onAmountFieldChanged(int index, String input) {
    amountChangeCallCount++;
    lastAmountChangedIndex = index;
    lastAmountChangedValue = input;
    super.onAmountFieldChanged(index, input);
  }
}

void main() {
  group("FeeStructureDraftHandler", () {
    late FeeStructureDraftHandler handler;

    _TestFeeStructureViewModel makeVm({
      bool includeExtraRow = false,
      int customerRim = 555,
    }) {
      final vm = _TestFeeStructureViewModel();

      vm.selectedCustomer = Customer(customerRimNo: customerRim);

      vm.feeRows = <FeeStructure>[];

      if (includeExtraRow) {
        vm.feeRows.add(
          FeeStructure(
            id: "extra_1",
            isNew: true,
            feeType: "Custom Fee",
            amount: 10,
            comments: "old extra",
          ),
        );
      }

      final rows = vm.combinedRows;
      vm.amountControllers.clear();
      vm.commentsControllers.clear();

      for (int i = 0; i < rows.length; i++) {
        vm.amountControllers.add(TextEditingController(text: "0.00"));
        vm.commentsControllers.add(
          TextEditingController(text: rows[i].comments),
        );
      }

      return vm;
    }

    setUp(() {
      handler = FeeStructureDraftHandler();
    });

    testWidgets("buildDraftData calls FormState.save() to flush onSaved",
        (tester) async {
      final vm = makeVm();

      bool onSavedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: vm.formKey,
              child: TextFormField(
                initialValue: "x",
                onSaved: (_) => onSavedCalled = true,
              ),
            ),
          ),
        ),
      );

      final data = handler.buildDraftData(vm);

      expect(
        onSavedCalled,
        isTrue,
        reason: "FormState.save() should have been called by buildDraftData",
      );
      expect(data["feeStructuresByCustomer"], isA<Map<String, dynamic>>());
    });

    test("buildDraftData serializes rows under current customer key", () {
      final vm = makeVm(customerRim: 999);

      final rows = vm.combinedRows;
      expect(rows, isNotEmpty);

      vm.amountControllers[0].text = "12.34";
      vm.commentsControllers[0].text = "first row comment";

      final data = handler.buildDraftData(vm);

      final Map<String, dynamic>? byCustomer =
          data["feeStructuresByCustomer"] as Map<String, dynamic>?;
      expect(byCustomer, isNotNull);

      final List<dynamic>? draftList = byCustomer!["999"] as List<dynamic>?;
      expect(draftList, isNotNull);
      expect(draftList!.length, rows.length);

      final Map<String, dynamic> first =
          draftList.first as Map<String, dynamic>;
      expect(first["feeType"], rows.first.feeType);
      expect(first["amount"], "12.34");
      expect(first["comments"], "first row comment");
      expect(first.containsKey("id"), isTrue);
      expect(first.containsKey("isDefault"), isTrue);
    });

    test(
        "applyDraft restores amount/comments via controllers and mirrors to model",
        () {
      final vm = makeVm(includeExtraRow: true, customerRim: 123);

      final rows = vm.combinedRows;
      final int n = rows.length;
      expect(n, greaterThanOrEqualTo(6), reason: "Expect 5 defaults + 1 extra");

      final List<Map<String, dynamic>> draft = List.generate(n, (i) {
        final r = rows[i];
        final isDefault = vm.defaultFeeTypes.contains(r.feeType);

        return <String, dynamic>{
          "id": r.id,
          "feeType": isDefault ? r.feeType : "Changed Custom Name",
          "amount": "77.${i}0",
          "comments": "drafted comment $i",
          "isDefault": isDefault,
        };
      });

      final data = <String, dynamic>{
        "feeStructuresByCustomer": {
          "123": draft,
        },
        "selectedCustomerRimNo": "123",
      };

      handler.applyDraft(vm, data);

      for (int i = 0; i < n; i++) {
        expect(vm.amountControllers[i].text, "77.${i}0");
        expect(vm.commentsControllers[i].text, "drafted comment $i");
        expect(vm.combinedRows[i].comments, "drafted comment $i");
      }

      final lastIdx = n - 1;
      expect(vm.defaultFeeTypes.contains(rows[0].feeType), isTrue);
      expect(rows[0].feeType, isNot("SHOULD_NOT_APPLY"));
      expect(vm.defaultFeeTypes.contains(rows[lastIdx].feeType), isFalse);
      expect(rows[lastIdx].feeType, "Changed Custom Name");

      expect(vm.amountChangeCallCount, n);
      expect(vm.lastAmountChangedIndex, lastIdx);
      expect(vm.lastAmountChangedValue, "77.${lastIdx}0");
    });

    test("applyDraft is a no-op when customer does not match", () {
      final vm = makeVm(includeExtraRow: true, customerRim: 0);

      final rowsBefore = vm.combinedRows.map((r) => r.feeType).toList();
      final amountsBefore = vm.amountControllers.map((c) => c.text).toList();
      final commentsBefore = vm.commentsControllers.map((c) => c.text).toList();

      final data = <String, dynamic>{
        "feeStructuresByCustomer": {
          "B": [
            {
              "feeType": "Different",
              "amount": "99.99",
              "comments": "no-op",
            }
          ],
        },
        "selectedCustomerRimNo": "B",
      };

      handler.applyDraft(vm, data);

      expect(vm.combinedRows.map((r) => r.feeType).toList(), rowsBefore);
      expect(vm.amountControllers.map((c) => c.text).toList(), amountsBefore);
      expect(
        vm.commentsControllers.map((c) => c.text).toList(),
        commentsBefore,
      );
    });

    test(
        "applyDraft restores only matching rows and"
        " leaves unmatched rows untouched", () {
      final vm = makeVm(includeExtraRow: true, customerRim: 321);
      final rows = vm.combinedRows;

      // Only the first two default rows are included in the draft.
      // Use matching IDs + feeTypes so the handler can restore them.
      final List<Map<String, dynamic>> shortDraft = <Map<String, dynamic>>[
        {
          "id": rows[0].id,
          "feeType": rows[0].feeType,
          "amount": "10.10",
          "comments": "c0",
          "isDefault": true,
        },
        {
          "id": rows[1].id,
          "feeType": rows[1].feeType,
          "amount": "20.20",
          "comments": "c1",
          "isDefault": true,
        },
      ];

      final data = <String, dynamic>{
        "feeStructuresByCustomer": {
          "321": shortDraft,
        },
      };

      handler.applyDraft(vm, data);

      expect(vm.amountControllers[0].text, "10.10");
      expect(vm.commentsControllers[0].text, "c0");

      expect(vm.amountControllers[1].text, "20.20");
      expect(vm.commentsControllers[1].text, "c1");

      for (int i = 2; i < rows.length; i++) {
        expect(vm.amountControllers[i].text, "0.00");
        expect(vm.commentsControllers[i].text, rows[i].comments);
      }
    });

    test("applyDraft recreates a missing custom Add Fee row from draft", () {
      final vm = makeVm(includeExtraRow: false, customerRim: 777);

      final initialRowCount = vm.combinedRows.length;
      final initialAmountCtrlCount = vm.amountControllers.length;
      final initialCommentCtrlCount = vm.commentsControllers.length;

      expect(initialRowCount, 5, reason: "Only default rows should exist");

      final draft = <String, dynamic>{
        "feeStructuresByCustomer": {
          "777": [
            for (final row in vm.combinedRows)
              {
                "id": row.id,
                "feeType": row.feeType,
                "amount": "0.00",
                "comments": row.comments,
                "isDefault": true,
              },
            {
              "id": "extra_draft_1",
              "feeType": "Drafted Custom Fee",
              "amount": "88.88",
              "comments": "restored extra row",
              "isDefault": false,
            },
          ],
        },
      };

      handler.applyDraft(vm, draft);

      expect(vm.combinedRows.length, initialRowCount + 1);
      expect(vm.amountControllers.length, initialAmountCtrlCount + 1);
      expect(vm.commentsControllers.length, initialCommentCtrlCount + 1);

      final restoredRow = vm.combinedRows.last;
      expect(restoredRow.id, "extra_draft_1");
      expect(restoredRow.feeType, "Drafted Custom Fee");
      expect(restoredRow.comments, "restored extra row");

      expect(vm.amountControllers.last.text, "88.88");
      expect(vm.commentsControllers.last.text, "restored extra row");
    });
  });
}
