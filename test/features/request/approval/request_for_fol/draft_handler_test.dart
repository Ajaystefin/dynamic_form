import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/features/request/approval/request_for_fol/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/request_for_fol/model.dart";

void main() {
  late RequestFOLDraftHandler handler;
  late RequestForFolViewModel vm;

  setUp(() {
    handler = RequestFOLDraftHandler();
    vm = RequestForFolViewModel();
  });

  // ---------------------------------------------------------------------------
  // buildDraftData
  // ---------------------------------------------------------------------------

  test("buildDraftData returns strategyComment and canSubmit", () {
    // controller.currentText is read-only in unit tests
    vm.canSubmit = true;

    final draft = handler.buildDraftData(vm);

    expect(draft["strategyComment"], vm.controller.currentText);
    expect(draft["canSubmit"], true);
  });

  test("buildDraftData works when canSubmit is false", () {
    vm.canSubmit = false;

    final draft = handler.buildDraftData(vm);

    expect(draft["strategyComment"], vm.controller.currentText);
    expect(draft["canSubmit"], false);
  });

  // ---------------------------------------------------------------------------
  // applyDraft
  // ---------------------------------------------------------------------------

  test("applyDraft restores strategyComment into initialText and canSubmit",
      () {
    handler.applyDraft(vm, {
      "strategyComment": "restored",
      "canSubmit": true,
    });

    expect(vm.initialText, "restored");
    expect(vm.canSubmit, true);
  });

  test("applyDraft updates only canSubmit when comment missing", () {
    vm.initialText = "before";

    handler.applyDraft(vm, {
      "canSubmit": false,
    });

    expect(vm.initialText, "before");
    expect(vm.canSubmit, false);
  });

  test("applyDraft updates only initialText when canSubmit missing", () {
    vm.canSubmit = true;

    handler.applyDraft(vm, {
      "strategyComment": "updated",
    });

    expect(vm.initialText, "updated");
    expect(vm.canSubmit, true);
  });

  test("applyDraft ignores null values safely", () {
    vm.initialText = "before";
    vm.canSubmit = true;

    handler.applyDraft(vm, {
      "strategyComment": null,
      "canSubmit": null,
    });

    expect(vm.initialText, "before");
    expect(vm.canSubmit, true);
  });

  test("applyDraft ignores unrelated keys", () {
    vm.initialText = "before";
    vm.canSubmit = false;

    handler.applyDraft(vm, {
      "foo": "bar",
      "count": 123,
    });

    expect(vm.initialText, "before");
    expect(vm.canSubmit, false);
  });
}
