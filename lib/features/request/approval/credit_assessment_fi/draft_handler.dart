import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment_fi/model.dart";

/// Handles draft data build and restore logic for FI credit assessment.
class CreditAssessmentFIDraftHandler
    extends DraftHandler<CreditAssessmentFIViewModel> {
  /// Builds the draft data from the FI credit assessment view model.
  @override
  Map<String, dynamic> buildDraftData(CreditAssessmentFIViewModel vm) {
    return {
      "rimData": {
        for (final entry in vm.rimController.entries)
          entry.key.toString(): entry.value.currentText,
      },
    };
  }

  @override
  void applyDraft(CreditAssessmentFIViewModel vm, Map<String, dynamic> data) {
    logger.i("rimData ${data["rimData"]}");
    vm.emit(vm.state.copyWith(loaderStatus: LoadingStatus.loading));
    final Map<String, dynamic>? rimData =
        data["rimData"] as Map<String, dynamic>?;
    // if (rimData != null) {
    //   for (var entry in rimData.entries) {
    //     int rim = int.tryParse(entry.key) ?? 0;
    //     vm.initialTextMap[rim] = entry.value;
    //     logger.i("rimData : ${vm.initialTextMap[rim]}");
    //   }
    // }
    if (rimData != null) {
      for (final entry in rimData.entries) {
        final int rim = int.tryParse(entry.key) ?? 0;
        vm.rimController[rim]?.setText(entry.value);
        logger.i("rimData : ${vm.rimController[rim]?.currentText}");
      }
    }
    vm.emit(vm.state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}
