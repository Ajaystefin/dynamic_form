import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/features/request/approval/credit_assessment/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment/model.dart";

void main() {
  late CreditAssessmentDraftHandler handler;
  late CreditAssessmentViewModel vm;

  setUp(() {
    handler = CreditAssessmentDraftHandler();
    vm = CreditAssessmentViewModel();
  });

  // ---------------------------------------------------------------------------
  // buildDraftData
  // ---------------------------------------------------------------------------

  test("buildDraftData returns creditBrief and creditAppraisal", () {
    final draft = handler.buildDraftData(vm);

    expect(draft, isA<Map<String, dynamic>>());
    expect(draft["creditBrief"], vm.briefController.currentText);
    expect(draft["creditAppraisal"], vm.appraisalController.currentText);
  });

  test("buildDraftData works when both texts are empty", () {
    final draft = handler.buildDraftData(vm);

    expect(draft["creditBrief"], "");
    expect(draft["creditAppraisal"], "");
  });

  // ---------------------------------------------------------------------------
  // applyDraft
  // ---------------------------------------------------------------------------

  test("applyDraft restores creditBrief and creditAppraisal", () {
    handler.applyDraft(vm, {
      "creditBrief": "brief text",
      "creditAppraisal": "appraisal text",
    });

    expect(vm.creditBrief, "brief text");
    expect(vm.creditAppraisal, "appraisal text");
  });

  test("applyDraft restores only creditBrief when appraisal missing", () {
    vm.creditAppraisal = "original appraisal";

    handler.applyDraft(vm, {
      "creditBrief": "new brief",
    });

    expect(vm.creditBrief, "new brief");
    expect(vm.creditAppraisal, "original appraisal");
  });

  test("applyDraft restores only creditAppraisal when brief missing", () {
    vm.creditBrief = "original brief";

    handler.applyDraft(vm, {
      "creditAppraisal": "new appraisal",
    });

    expect(vm.creditBrief, "original brief");
    expect(vm.creditAppraisal, "new appraisal");
  });

  test("applyDraft ignores null values safely", () {
    vm.creditBrief = "before brief";
    vm.creditAppraisal = "before appraisal";

    handler.applyDraft(vm, {
      "creditBrief": null,
      "creditAppraisal": null,
    });

    expect(vm.creditBrief, "before brief");
    expect(vm.creditAppraisal, "before appraisal");
  });

  test("applyDraft ignores unrelated keys", () {
    vm.creditBrief = "before brief";
    vm.creditAppraisal = "before appraisal";

    handler.applyDraft(vm, {
      "foo": "bar",
      "count": 123,
    });

    expect(vm.creditBrief, "before brief");
    expect(vm.creditAppraisal, "before appraisal");
  });

  test("applyDraft does nothing when draft map is empty", () {
    vm.creditBrief = "before brief";
    vm.creditAppraisal = "before appraisal";

    handler.applyDraft(vm, {});

    expect(vm.creditBrief, "before brief");
    expect(vm.creditAppraisal, "before appraisal");
  });
}
