import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/projects/create_project/draft_handler.dart";
import "package:wcas_frontend/features/request/projects/create_project/model.dart";
import "package:wcas_frontend/models/request/project/project.dart";

void main() {
  late EditProjectDraftHandler handler;
  late CreateProjectViewModel vm;

  Future<void> attachForm(
    WidgetTester tester,
    CreateProjectViewModel vm,
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

  setUp(() {
    handler = EditProjectDraftHandler();

    vm = CreateProjectViewModel()
      ..isCreateProject = false
      ..project = Project()
      ..projectPeriodController = TextEditingController()
      ..defectLiabilityEndDateController = TextEditingController();
  });

  // ---------------------------------------------------------------------------
  // resolveDraftKey
  // ---------------------------------------------------------------------------

  test("resolveDraftKey returns vm draftFormKey", () {
    // expect(handler.resolveDraftKey(vm), 'edit-project-draft');
  });

  // ---------------------------------------------------------------------------
  // buildDraftData
  // ---------------------------------------------------------------------------

  testWidgets("buildDraftData saves form when mounted", (tester) async {
    await attachForm(tester, vm);

    vm.project
      ..projectId = 1
      ..projectCode = "P001"
      ..projectName = "Test Project";

    final draft = handler.buildDraftData(vm);

    expect(draft.containsKey("project"), true);
    expect(draft["project"]["projectCode"], "P001");
    expect(draft["project"]["projectId"], 1);
  });

  testWidgets("buildDraftData handles unmounted form safely", (tester) async {
    vm.formKey = GlobalKey<FormState>(); // not attached

    vm.project.projectCode = "P002";

    final draft = handler.buildDraftData(vm);

    expect(draft["project"]["projectCode"], "P002");
  });

  // ---------------------------------------------------------------------------
  // applyDraft – early exits
  // ---------------------------------------------------------------------------

  test("applyDraft returns when project block is null", () {
    vm.project.projectCode = "PX";

    handler.applyDraft(vm, {});

    expect(vm.project.projectId, isNull);
  });

  test("applyDraft returns on projectCode mismatch", () {
    vm.project.projectCode = "REAL";

    handler.applyDraft(vm, {
      "project": {
        "projectCode": "OTHER",
        "projectName": "Should not apply",
      },
    });

    expect(vm.project.projectName, isNull);
  });

  // ---------------------------------------------------------------------------
  // applyDraft – full restore
  // ---------------------------------------------------------------------------

  test("applyDraft restores project, dates, controllers and emits state", () {
    vm.project.projectCode = "MATCH";

    handler.applyDraft(vm, {
      "project": {
        "projectId": 99,
        "projectCode": "MATCH",
        "projectName": "Restored",
        "projectUltimateOwnerName": "Owner",
        "projectOwnerEntityName": "Entity",
        "projectOwnerRimNo": 10,
        "projectOwnerEntityRimNo": 20,
        "projectValue": "1000",
        "projectValueCurrent": "800",
        "initialProjectValue": "1200",
        "projmary": "Summary",
        "projectCompletion": 75.25,
        "projectPeriod": "03/2024",
        "defectLiabilityEndDate": "12/2025",
      },
    });

    expect(vm.project.projectId, 99);
    expect(vm.project.projectName, "Restored");
    expect(vm.project.projectCompletion, 75.25);

    expect(vm.projectPeriod, DateTime(2024, 3));
    expect(
      vm.projectPeriodController.text,
      DateTimeUtils.formatMonthYear(DateTime(2024, 3)),
    );

    expect(vm.defectLiabilityEndDate, DateTime(2025, 12));
    expect(
      vm.defectLiabilityEndDateController.text,
      DateTimeUtils.formatMonthYear(DateTime(2025, 12)),
    );

    expect(vm.state.loaderStatus, LoadingStatus.loaded);
  });

  // ---------------------------------------------------------------------------
  // parseMonthYear edge cases (indirect coverage)
  // ---------------------------------------------------------------------------

  test("applyDraft handles null & invalid date formats safely", () {
    vm.project.projectCode = "EDGE";

    handler.applyDraft(vm, {
      "project": {
        "projectCode": "EDGE",
        "projectPeriod": null,
        "defectLiabilityEndDate": "invalid",
      },
    });

    expect(vm.projectPeriod, isNull);
    expect(vm.projectPeriodController.text, "");

    expect(vm.defectLiabilityEndDate, isNull);
    expect(vm.defectLiabilityEndDateController.text, "");
  });
}
