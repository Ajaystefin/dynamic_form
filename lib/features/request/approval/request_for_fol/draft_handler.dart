import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/approval/request_for_fol/model.dart";

/// Handles draft data build and restore logic for request for FOL.
class RequestFOLDraftHandler extends DraftHandler<RequestForFolViewModel> {
  /// Builds the draft data from the request for FOL view model.
  @override
  Map<String, dynamic> buildDraftData(RequestForFolViewModel vm) {
    final String text = vm.controller.currentText;
    return {
      "strategyComment": text,
      "canSubmit": vm.canSubmit,
    };
  }

  /// Applies saved draft data back to the request for FOL view model.
  @override
  void applyDraft(RequestForFolViewModel vm, Map<String, dynamic> data) {
    final String? strategyComment = data["strategyComment"] as String?;
    final bool? canSubmit = data["canSubmit"] as bool?;
    if (canSubmit != null) {
      vm.canSubmit = canSubmit;
    }
    if (strategyComment != null) {
      vm.initialText = strategyComment;
    }
  }
}
