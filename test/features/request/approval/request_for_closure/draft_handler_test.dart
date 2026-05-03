import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/features/request/approval/request_for_closure/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/request_for_closure/model.dart";

void main() {
  late RequestClosureDraftHandler handler;
  late RequestForClosureViewModel vm;

  setUp(() {
    handler = RequestClosureDraftHandler();
    vm = RequestForClosureViewModel();
  });

  // ---------------------------------------------------------------------------
  // buildDraftData
  // ---------------------------------------------------------------------------

  test("buildDraftData returns strategyComment and canSubmit", () {
    vm
      ..strategyComment = "closure comment"
      ..canSubmit = true;

    final draft = handler.buildDraftData(vm);

    expect(draft, isA<Map<String, dynamic>>());
    expect(draft["strategyComment"], "closure comment");
    expect(draft["canSubmit"], true);
  });

  test("buildDraftData works with empty strategyComment", () {
    vm
      ..strategyComment = ""
      ..canSubmit = false;

    final draft = handler.buildDraftData(vm);

    expect(draft["strategyComment"], "");
    expect(draft["canSubmit"], false);
  });

  // ---------------------------------------------------------------------------
  // applyDraft
  // ---------------------------------------------------------------------------

  test("applyDraft restores strategyComment and canSubmit", () {
    handler.applyDraft(vm, {
      "strategyComment": "restored comment",
      "canSubmit": true,
    });

    expect(vm.strategyComment, "restored comment");
    expect(vm.canSubmit, true);
  });

  test("applyDraft updates only canSubmit when strategyComment missing", () {
    vm.strategyComment = "original";

    handler.applyDraft(vm, {
      "canSubmit": false,
    });

    expect(vm.strategyComment, "original");
    expect(vm.canSubmit, false);
  });

  test("applyDraft updates only strategyComment when canSubmit missing", () {
    vm.canSubmit = true;

    handler.applyDraft(vm, {
      "strategyComment": "updated comment",
    });

    expect(vm.strategyComment, "updated comment");
    expect(vm.canSubmit, true);
  });

  test("applyDraft ignores null values safely", () {
    vm
      ..strategyComment = "before"
      ..canSubmit = true;

    handler.applyDraft(vm, {
      "strategyComment": null,
      "canSubmit": null,
    });

    expect(vm.strategyComment, "before");
    expect(vm.canSubmit, true);
  });

  test("applyDraft ignores unrelated keys", () {
    vm
      ..strategyComment = "before"
      ..canSubmit = false;

    handler.applyDraft(vm, {
      "foo": "bar",
      "count": 123,
    });

    expect(vm.strategyComment, "before");
    expect(vm.canSubmit, false);
  });

  test("applyDraft does nothing when draft map is empty", () {
    vm
      ..strategyComment = "before"
      ..canSubmit = true;

    handler.applyDraft(vm, {});

    expect(vm.strategyComment, "before");
    expect(vm.canSubmit, true);
  });
}
