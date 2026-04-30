import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/approval/request_for_fol/model.dart";

class RequestFOLDraftHandler extends DraftHandler<RequestForFolViewModel> {
  @override
  Map<String, dynamic> buildDraftData(RequestForFolViewModel vm) {
    final String text = vm.controller.currentText;
    return {
      "strategyComment": text,
      "canSubmit": vm.canSubmit,
    };
  }

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
