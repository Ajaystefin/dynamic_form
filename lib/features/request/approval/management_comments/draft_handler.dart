import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";

// ignore: avoid_relative_lib_imports — intentional same-feature import
import "package:wcas_frontend/features/request/approval/management_comments/model.dart";

/// Draft handler for the Account Stats screen.

class ManagementCommentsDraftHandler
    extends DraftHandler<ManagementCommentsViewModel> {
  @override
  Map<String, dynamic> buildDraftData(ManagementCommentsViewModel vm) {
    // Flush onSaved callbacks — required for screens using onSaved in
    // FormFields.
    vm.formKey.currentState?.save();

    return <String, dynamic>{
      "creditCommitteeRecommendations": vm.creditCommitteeRecommendations,
      "ccoComments": vm.ccoComments,
      "ceoComments": vm.ceoComments,
      "bcicComments": vm.bcicComments,
      "canSubmit": vm.canSubmit,
    };
  }

  /// Restores draft values into the live [`groupWiseFacilitiesWithCbd`] map.
  @override
  void applyDraft(ManagementCommentsViewModel vm, Map<String, dynamic> data) {
    final String? creditCommitteeRecommendations =
        data["creditCommitteeRecommendations"] as String?;
    final String? ccoComments = data["ccoComments"] as String?;
    final String? ceoComments = data["ceoComments"] as String?;
    final String? bcicComments = data["bcicComments"] as String?;
    final bool? canSubmit = data["canSubmit"] as bool?;
    if (creditCommitteeRecommendations != null) {
      vm.creditCommitteeRecommendations = creditCommitteeRecommendations;
    }
    if (ccoComments != null) {
      vm.ccoComments = ccoComments;
    }
    if (ceoComments != null) {
      vm.ceoComments = ceoComments;
    }
    if (bcicComments != null) {
      vm.bcicComments = bcicComments;
    }
    if (canSubmit != null) {
      vm.canSubmit = canSubmit;
    }
  }
}
