import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/features/request/approval/previous_credit_approval/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/previous_credit_approval/model.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";

void main() {
  late PreviousCreditApprovalDraftHandler handler;
  late PreviousCreditApprovalViewModel vm;

  User? prevUser;

  setUp(() {
    handler = PreviousCreditApprovalDraftHandler();
    vm = PreviousCreditApprovalViewModel();

    // Preserve globals
    prevUser = Globals.user;
  });

  tearDown(() {
    Globals.user = prevUser;
  });

  // ---------------------------------------------------------------------------
  // resolveDraftKey
  // ---------------------------------------------------------------------------

  test("resolveDraftKey includes formKey and roleId", () {
    Globals.user = User(
      id: "u1",
      currentRole: Role(roleId: 99),
    );

    final key = handler.resolveDraftKey(vm);

    expect(key, contains(vm.draftFormKey));
    expect(key, contains("_r99"));
  });

  test("resolveDraftKey falls back to roleId 0 when user missing", () {
    Globals.user = null;

    final key = handler.resolveDraftKey(vm);

    expect(key, contains(vm.draftFormKey));
    expect(key, contains("_r0"));
  });

  // ---------------------------------------------------------------------------
  // buildDraftData
  // ---------------------------------------------------------------------------

  testWidgets("buildDraftData saves form and returns payload", (tester) async {
    // Attach a form to trigger formKey.currentState?.save()
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: vm.formKey,
            child: TextFormField(
              onSaved: (_) {
                vm.initialText = "saved from form";
              },
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    vm.reviewCommentId = "RC123";

    final draft = handler.buildDraftData(vm);

    expect(draft["initialText"], "saved from form");
    expect(draft["reviewCommentId"], "RC123");
  });

  test("buildDraftData works when form is not mounted", () {
    vm.initialText = "text";
    vm.reviewCommentId = "RID";

    final draft = handler.buildDraftData(vm);

    expect(draft["initialText"], "text");
    expect(draft["reviewCommentId"], "RID");
  });

  // ---------------------------------------------------------------------------
  // applyDraft
  // ---------------------------------------------------------------------------

  test("applyDraft restores trimmed initialText and reviewCommentId", () {
    handler.applyDraft(vm, {
      "initialText": "  restored text  ",
      "reviewCommentId": "  RC001 ",
    });

    expect(vm.initialText, "restored text");
    expect(vm.reviewCommentId, "RC001");
  });

  test("applyDraft does not overwrite initialText with empty string", () {
    vm.initialText = "before";

    handler.applyDraft(vm, {
      "initialText": "   ",
    });

    expect(vm.initialText, "before");
  });

  test("applyDraft ignores non-string reviewCommentId", () {
    vm.reviewCommentId = "before";

    handler.applyDraft(vm, {
      "reviewCommentId": 123,
    });

    expect(vm.reviewCommentId, "before");
  });

  test("applyDraft ignores missing keys safely", () {
    vm.initialText = "before";
    vm.reviewCommentId = "RID";

    handler.applyDraft(vm, {});

    expect(vm.initialText, "before");
    expect(vm.reviewCommentId, "RID");
  });

  test("applyDraft handles null values safely", () {
    vm.initialText = "before";
    vm.reviewCommentId = "RID";

    handler.applyDraft(vm, {
      "initialText": null,
      "reviewCommentId": null,
    });

    expect(vm.initialText, "before");
    expect(vm.reviewCommentId, "RID");
  });

  test("applyDraft does not throw on invalid payload", () {
    vm.initialText = "before";
    vm.reviewCommentId = "RID";

    expect(
      () => handler.applyDraft(vm, {
        "initialText": {"bad": "type"},
        "reviewCommentId": ["bad"],
      }),
      returnsNormally,
    );

    // Values unchanged
    expect(vm.initialText, "before");
    expect(vm.reviewCommentId, "RID");
  });
}
