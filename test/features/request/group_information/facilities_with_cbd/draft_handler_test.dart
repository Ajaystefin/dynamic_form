import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/features/request/group_information/facilities_with_cbd/draft_handler.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_cbd/model.dart";
import "package:wcas_frontend/models/request/comment.dart";

void main() {
  late FacilitiesWithCbdDraftHandler handler;
  late FacilitiesWithCbdViewModel vm;

  setUp(() {
    handler = FacilitiesWithCbdDraftHandler();
    vm = FacilitiesWithCbdViewModel();
  });

  // ---------------------------------------------------------------------------
  // buildDraftData
  // ---------------------------------------------------------------------------

  test("buildDraftData uses commentController.text when it is not empty", () {
    vm.commentController.text = "controller comment";
    vm.comment = Comment()..comment = "model comment";

    final draft = handler.buildDraftData(vm);

    expect(draft["comment"], "controller comment");
  });

  test(
      "buildDraftData falls back to vm.comment.comment"
      " when controller text is empty", () {
    vm.commentController.text = "";
    vm.comment = Comment()..comment = "model comment";

    final draft = handler.buildDraftData(vm);

    expect(draft["comment"], "model comment");
  });

  test(
      "buildDraftData returns "
      "null when controller "
      "text is empty and comment is null", () {
    vm.commentController.text = "";
    vm.comment = null;

    final draft = handler.buildDraftData(vm);

    expect(draft.containsKey("comment"), true);
    expect(draft["comment"], isNull);
  });

  // ---------------------------------------------------------------------------
  // applyDraft
  // ---------------------------------------------------------------------------

  test("applyDraft creates comment, sets comment text, and updates controller",
      () {
    handler.applyDraft(vm, {
      "comment": "restored comment",
    });

    expect(vm.comment, isNotNull);
    expect(vm.comment!.comment, "restored comment");
    expect(vm.commentController.text, "restored comment");
  });

  test("applyDraft overwrites existing comment and controller text", () {
    vm.comment = Comment()..comment = "before";
    vm.commentController.text = "before";

    handler.applyDraft(vm, {
      "comment": "after",
    });

    expect(vm.comment!.comment, "after");
    expect(vm.commentController.text, "after");
  });

  test("applyDraft converts non-string comment values to string", () {
    handler.applyDraft(vm, {
      "comment": 123,
    });

    expect(vm.comment!.comment, "123");
    expect(vm.commentController.text, "123");
  });

  test("applyDraft does nothing when comment key is missing", () {
    vm.comment = Comment()..comment = "before";
    vm.commentController.text = "before";

    handler.applyDraft(vm, {});

    expect(vm.comment!.comment, "before");
    expect(vm.commentController.text, "before");
  });

  test("applyDraft safely handles null comment value", () {
    vm.comment = Comment()..comment = "before";
    vm.commentController.text = "before";

    handler.applyDraft(vm, {
      "comment": null,
    });

    expect(vm.comment!.comment, "before");
    expect(vm.commentController.text, "before");
  });
}
