import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/core/utils/utils.dart";

import "package:wcas_frontend/features/request/projects/create_project/model.dart";

/// Draft handler for edit project.
class EditProjectDraftHandler extends DraftHandler<CreateProjectViewModel> {
  /// Resolves the draft key for edit project.
  String resolveDraftKey(CreateProjectViewModel vm) {
    return vm.draftFormKey;
  }

  // --------------------------------------------------
  // BUILD DRAFT
  // --------------------------------------------------

  /// Builds draft data for edit project.
  @override
  Map<String, dynamic> buildDraftData(
    CreateProjectViewModel vm,
  ) {
    if (vm.formKey.currentState?.mounted ?? false) {
      vm.formKey.currentState?.save();
    }

    // Ensure model is up to date
    vm.syncModelFromControllers();

    return {
      "project": {
        ...vm.project.toSaveEditProjectJson(
          isCreateProject: vm.isCreateProject,
        ),
        "projectCode": vm.project.projectCode,
        "projectId": vm.project.projectId,
      },
    };
  }

  // --------------------------------------------------
  // APPLY DRAFT
  // --------------------------------------------------

  /// Applies draft data to edit project.
  @override
  void applyDraft(
    CreateProjectViewModel vm,
    Map<String, dynamic> data,
  ) {
    final Map<String, dynamic>? json = data["project"] as Map<String, dynamic>?;
    if (json == null) {
      return;
    }

    final draftCode = json["projectCode"];
    if (draftCode != vm.project.projectCode) {
      return;
    }

    // --------------------------------------------------
    // Restore MODEL
    // --------------------------------------------------
    vm.project
      ..projectId = json["projectId"]
      ..projectCode = json["projectCode"]
      ..projectName = json["projectName"]
      ..projectUltimateOwnerName = json["projectUltimateOwnerName"]
      ..projectOwnerEntityName = json["projectOwnerEntityName"]
      ..projectOwnerRimNo = json["projectOwnerRimNo"]
      ..projectOwnerEntityRimNo = json["projectOwnerEntityRimNo"]
      ..projectValue = json["projectValue"]
      ..projectValueCurrent = json["projectValueCurrent"]
      ..initialProjectValue = json["initialProjectValue"]
      ..projectSummary = json["projectSummary"]
      ..projectCompletion = (json["projectCompletion"] as num?)?.toDouble();

    // --------------------------------------------------
    // Parse MM/YYYY
    // --------------------------------------------------
    DateTime? parseMonthYear(String? value) {
      if (value == null || value.isEmpty) {
        return null;
      }
      final parts = value.split("/");
      if (parts.length != 2) {
        return null;
      }
      return DateTime(
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    }

    // during draft apply
    vm.projectPeriod = parseMonthYear(json["projectPeriod"]);
    vm.projectPeriodController.text =
        DateTimeUtils.formatMonthYear(vm.projectPeriod);

    vm.defectLiabilityEndDate = parseMonthYear(json["defectLiabilityEndDate"]);
    vm.defectLiabilityEndDateController.text =
        DateTimeUtils.formatMonthYear(vm.defectLiabilityEndDate);
    // --------------------------------------------------
    // Restore CONTROLLERS
    // --------------------------------------------------
    vm
      ..syncControllersFromModel()
      ..emit(
        vm.state.copyWith(loaderStatus: LoadingStatus.loaded),
      );
  }
}
