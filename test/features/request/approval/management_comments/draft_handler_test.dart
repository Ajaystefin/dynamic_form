import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/features/request/approval/management_comments/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/management_comments/model.dart";

void main() {
  late ManagementCommentsDraftHandler handler;
  late ManagementCommentsViewModel vm;

  setUp(() {
    handler = ManagementCommentsDraftHandler();
    vm = ManagementCommentsViewModel();
  });

  // ---------------------------------------------------------------------------
  // buildDraftData
  // ---------------------------------------------------------------------------

  testWidgets(
      "buildDraftData saves form and returns all comment fields and canSubmit",
      (tester) async {
    // Attach a Form to ensure formKey.currentState?.save() is executed
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: vm.formKey,
            child: TextFormField(
              onSaved: (_) {
                vm.creditCommitteeRecommendations = "CCR";
                vm.ccoComments = "CCO";
                vm.ceoComments = "CEO";
                vm.bcicComments = "BCIC";
              },
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    vm.canSubmit = true;

    final draft = handler.buildDraftData(vm);

    expect(draft, isA<Map<String, dynamic>>());
    expect(draft["creditCommitteeRecommendations"], "CCR");
    expect(draft["ccoComments"], "CCO");
    expect(draft["ceoComments"], "CEO");
    expect(draft["bcicComments"], "BCIC");
    expect(draft["canSubmit"], true);
  });

  test("buildDraftData works when form is not mounted", () {
    vm.creditCommitteeRecommendations = "CCR";
    vm.ccoComments = "CCO";
    vm.ceoComments = "CEO";
    vm.bcicComments = "BCIC";
    vm.canSubmit = false;

    final draft = handler.buildDraftData(vm);

    expect(draft["creditCommitteeRecommendations"], "CCR");
    expect(draft["ccoComments"], "CCO");
    expect(draft["ceoComments"], "CEO");
    expect(draft["bcicComments"], "BCIC");
    expect(draft["canSubmit"], false);
  });

  // ---------------------------------------------------------------------------
  // applyDraft
  // ---------------------------------------------------------------------------

  test("applyDraft restores all comment fields and canSubmit when present", () {
    handler.applyDraft(vm, {
      "creditCommitteeRecommendations": "CCR",
      "ccoComments": "CCO",
      "ceoComments": "CEO",
      "bcicComments": "BCIC",
      "canSubmit": true,
    });

    expect(vm.creditCommitteeRecommendations, "CCR");
    expect(vm.ccoComments, "CCO");
    expect(vm.ceoComments, "CEO");
    expect(vm.bcicComments, "BCIC");
    expect(vm.canSubmit, true);
  });

  test("applyDraft updates only provided fields and leaves others unchanged",
      () {
    vm.creditCommitteeRecommendations = "old CCR";
    vm.ccoComments = "old CCO";
    vm.ceoComments = "old CEO";
    vm.bcicComments = "old BCIC";
    vm.canSubmit = false;

    handler.applyDraft(vm, {
      "ccoComments": "new CCO",
      "canSubmit": true,
    });

    expect(vm.creditCommitteeRecommendations, "old CCR");
    expect(vm.ccoComments, "new CCO");
    expect(vm.ceoComments, "old CEO");
    expect(vm.bcicComments, "old BCIC");
    expect(vm.canSubmit, true);
  });

  test("applyDraft ignores null values safely", () {
    vm.creditCommitteeRecommendations = "CCR";
    vm.ccoComments = "CCO";
    vm.ceoComments = "CEO";
    vm.bcicComments = "BCIC";
    vm.canSubmit = true;

    handler.applyDraft(vm, {
      "creditCommitteeRecommendations": null,
      "ccoComments": null,
      "ceoComments": null,
      "bcicComments": null,
      "canSubmit": null,
    });

    expect(vm.creditCommitteeRecommendations, "CCR");
    expect(vm.ccoComments, "CCO");
    expect(vm.ceoComments, "CEO");
    expect(vm.bcicComments, "BCIC");
    expect(vm.canSubmit, true);
  });

  test("applyDraft ignores unrelated keys", () {
    vm.creditCommitteeRecommendations = "CCR";
    vm.canSubmit = false;

    handler.applyDraft(vm, {
      "foo": "bar",
      "count": 123,
    });

    expect(vm.creditCommitteeRecommendations, "CCR");
    expect(vm.canSubmit, false);
  });

  test("applyDraft does nothing when draft map is empty", () {
    vm.creditCommitteeRecommendations = "CCR";
    vm.ccoComments = "CCO";
    vm.ceoComments = "CEO";
    vm.bcicComments = "BCIC";
    vm.canSubmit = true;

    handler.applyDraft(vm, {});

    expect(vm.creditCommitteeRecommendations, "CCR");
    expect(vm.ccoComments, "CCO");
    expect(vm.ceoComments, "CEO");
    expect(vm.bcicComments, "BCIC");
    expect(vm.canSubmit, true);
  });
}
