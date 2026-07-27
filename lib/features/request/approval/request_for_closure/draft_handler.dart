import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/approval/request_for_closure/model.dart";

/// Handles draft data build and restore logic for request closure.
class RequestClosureDraftHandler
    extends DraftHandler<RequestForClosureViewModel> {
  /// Builds the draft data from the request for closure view model.
  @override
  Map<String, dynamic> buildDraftData(RequestForClosureViewModel vm) {
    return {
      "strategyComment": vm.strategyComment,
      "canSubmit": vm.canSubmit,
    };
  }

  /// Applies saved draft data back to the request for closure view model.
  @override
  void applyDraft(RequestForClosureViewModel vm, Map<String, dynamic> data) {
    final String? strategyComment = data["strategyComment"] as String?;
    final bool? canSubmit = data["canSubmit"] as bool?;
    if (canSubmit != null) {
      vm.canSubmit = canSubmit;
    }
    if (strategyComment != null) {
      vm.strategyComment = strategyComment;
    }
  }
}
