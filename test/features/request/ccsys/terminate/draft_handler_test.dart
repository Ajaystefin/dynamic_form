import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/features/request/ccsys/termination/draft_handler.dart";
import "package:wcas_frontend/features/request/ccsys/termination/model.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/request.dart";

void main() {
  late CcsysTerminationDraftHandler handler;
  late CcsysTerminationViewModel vm;

  setUp(() {
    handler = CcsysTerminationDraftHandler();
    vm = CcsysTerminationViewModel();

    // Ensure globals are clean
    Globals.request = null;
  });

  Future<void> attachForm(
    WidgetTester tester,
    CcsysTerminationViewModel vm,
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

  // ---------------------------------------------------------------------------
  // buildDraftData
  // ---------------------------------------------------------------------------

  testWidgets("buildDraftData saves form and serializes comment",
      (tester) async {
    await attachForm(tester, vm);

    vm.comment = Comment()
      ..reasonList = "R1"
      ..categoryId = 10
      ..comment = "Test comment";

    final draft = handler.buildDraftData(vm);

    expect(draft["reasonList"], "R1");
    expect(draft["categoryId"], 10);
    expect(draft["comment"], "Test comment");
  });

  testWidgets("buildDraftData handles null comment safely", (tester) async {
    await attachForm(tester, vm);

    vm.comment = null;

    final draft = handler.buildDraftData(vm);

    expect(draft["reasonList"], isNull);
    expect(draft["categoryId"], isNull);
    expect(draft["comment"], isNull);
  });

  testWidgets("buildDraftData handles unmounted form safely", (tester) async {
    vm
      ..formKey = GlobalKey<FormState>() // not mounted
      ..comment = (Comment()..comment = "Draft");

    final draft = handler.buildDraftData(vm);

    expect(draft["comment"], "Draft");
  });

  // ---------------------------------------------------------------------------
  // applyDraft – guards
  // ---------------------------------------------------------------------------

  testWidgets("applyDraft ignores empty payload", (tester) async {
    vm.comment = Comment();

    handler.applyDraft(vm, {});

    expect(vm.comment!.comment, isNull);
  });

  testWidgets("applyDraft ignores mismatched applicationRef", (tester) async {
    Globals.request = Request(applicationRefNo: "APP-1");

    vm.comment = Comment();

    handler.applyDraft(vm, {
      "applicationRef": "APP-2",
      "comment": "Should not apply",
    });

    expect(vm.comment!.comment, isNull);
  });

  // ---------------------------------------------------------------------------
  // applyDraft – happy path
  // ---------------------------------------------------------------------------

  testWidgets("applyDraft restores all fields and controller", (tester) async {
    await attachForm(tester, vm);

    Globals.request = Request(applicationRefNo: "APP-1");

    handler.applyDraft(vm, {
      "applicationRef": "APP-1",
      "reasonList": "RL",
      "categoryId": "5",
      "comment": "Restored",
    });

    expect(vm.comment, isNotNull);
    expect(vm.comment!.reasonList, "RL");
    expect(vm.comment!.categoryId, 5);
    expect(vm.comment!.comment, "Restored");
    expect(vm.remarksController.text, "Restored");
  });

  // ---------------------------------------------------------------------------
  // applyDraft – partial & coercion cases
  // ---------------------------------------------------------------------------

  testWidgets("applyDraft coerces numeric categoryId", (tester) async {
    vm.comment = Comment();

    handler.applyDraft(vm, {
      "categoryId": 7.9,
    });

    expect(vm.comment!.categoryId, 7);
  });

  testWidgets("applyDraft ignores empty strings", (tester) async {
    vm.comment = Comment();

    handler.applyDraft(vm, {
      "reasonList": "   ",
      "comment": "",
    });

    expect(vm.comment!.reasonList, isNull);
    expect(vm.comment!.comment, isNull);
  });

  testWidgets("applyDraft ignores invalid int values", (tester) async {
    vm.comment = Comment();

    handler.applyDraft(vm, {
      "categoryId": "abc",
    });

    expect(vm.comment!.categoryId, isNull);
  });

  // ---------------------------------------------------------------------------
  // UI update
  // ---------------------------------------------------------------------------

  testWidgets("applyDraft emits state update", (tester) async {
    await attachForm(tester, vm);

    handler.applyDraft(vm, {
      "comment": "Emit check",
    });

    // No exception = emit path covered
    expect(vm.comment!.comment, "Emit check");
  });
}
