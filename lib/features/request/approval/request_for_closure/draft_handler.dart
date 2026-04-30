import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/approval/request_for_closure/model.dart";

class RequestClosureDraftHandler
    extends DraftHandler<RequestForClosureViewModel> {
  @override
  Map<String, dynamic> buildDraftData(RequestForClosureViewModel vm) {
    return {
      "strategyComment": vm.strategyComment,
      "canSubmit": vm.canSubmit,
    };
  }

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
