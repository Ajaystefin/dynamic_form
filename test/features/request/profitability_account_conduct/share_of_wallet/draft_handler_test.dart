import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/share_of_wallet/draft_handler.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/share_of_wallet/model.dart";

void main() {
  group("ShareOfWalletDraftHandler", () {
    late ShareOfWalletDraftHandler handler;

    ShareOfWalletViewModel makeVm({
      String? rmComments,
    }) {
      final vm = ShareOfWalletViewModel();
      if (rmComments != null) {
        vm.rmComments = rmComments;
      }
      return vm;
    }

    setUp(() {
      handler = ShareOfWalletDraftHandler();
    });

    testWidgets("buildDraftData calls FormState.save() to flush onSaved",
        (tester) async {
      final vm = makeVm(rmComments: "initial value");
      var onSavedInvoked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: vm.formKey,
              child: TextFormField(
                initialValue: "saved comment",
                onSaved: (value) {
                  onSavedInvoked = true;
                  vm.rmComments = value;
                },
              ),
            ),
          ),
        ),
      );

      final data = handler.buildDraftData(vm);

      expect(
        onSavedInvoked,
        isTrue,
        reason: "buildDraftData must flush FormState.save() so"
            " onSaved values are captured.",
      );
      expect(data, isA<Map<String, dynamic>>());
      expect(data.containsKey("comments"), isTrue);
      expect(data["comments"], "saved comment");
      expect(vm.rmComments, "saved comment");
    });

    test("buildDraftData serializes current vm.rmComments into map", () {
      final vm = makeVm(rmComments: "current comment");

      final data = handler.buildDraftData(vm);

      expect(data["comments"], isNotNull);
      expect(data["comments"], isA<String>());
      expect(data["comments"], "current comment");
    });

    test("applyDraft replaces rmComments when draft contains a string", () {
      final vm = makeVm(rmComments: "old comment");

      final draft = <String, dynamic>{
        "comments": "new comment",
      };

      handler.applyDraft(vm, draft);

      expect(vm.rmComments, "new comment");
    });

    test("applyDraft keeps existing rmComments when draft comments is null",
        () {
      final vm = makeVm(rmComments: "keep-me");

      final draft = <String, dynamic>{
        "comments": null, // explicit null should not overwrite
      };

      handler.applyDraft(vm, draft);

      expect(vm.rmComments, "keep-me");
    });

    test("applyDraft keeps existing rmComments when draft key is missing", () {
      final vm = makeVm(rmComments: "existing");

      final draft = <String, dynamic>{
        // no 'comments' key
      };

      handler.applyDraft(vm, draft);

      expect(vm.rmComments, "existing");
    });

    test(
        "applyDraft can "
        "set rmComments to "
        "empty string when provided explicitly", () {
      final vm = makeVm(rmComments: "will be cleared");

      final draft = <String, dynamic>{
        "comments": "",
      };

      handler.applyDraft(vm, draft);

      expect(vm.rmComments, "");
    });
  });
}
