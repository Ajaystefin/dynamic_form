import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment/model.dart";

/// Handles draft data build and restore logic for credit assessment.
class CreditAssessmentDraftHandler
    extends DraftHandler<CreditAssessmentViewModel> {
  @override
  Map<String, dynamic> buildDraftData(CreditAssessmentViewModel vm) {
    return {
      "creditBrief": vm.briefController.currentText,
      "creditAppraisal": vm.appraisalController.currentText,
    };
  }

  @override
  void applyDraft(CreditAssessmentViewModel vm, Map<String, dynamic> data) {
    final String? creditBrief = data["creditBrief"] as String?;
    final String? creditAppraisal = data["creditAppraisal"] as String?;
    if (creditAppraisal != null) {
      vm.creditAppraisal = creditAppraisal;
    }
    if (creditBrief != null) {
      vm.creditBrief = creditBrief;
    }
  }
}
