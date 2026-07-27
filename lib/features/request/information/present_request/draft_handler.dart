import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/information/present_request/model.dart";

/// Handles draft save, restore, and lifecycle operations for
/// the Present Request screen.
class PresentRequestDraftHandler extends DraftHandler<PresentRequestViewModel> {
  @override
  Map<String, dynamic> buildDraftData(PresentRequestViewModel vm) {
    vm.formKey.currentState?.save(); // now this works

    final comment = vm.comment;

    return {
      "commentId": comment.id,
      "strategyComment": comment.strategyComment ?? "",
    };
  }

  @override
  void applyDraft(PresentRequestViewModel vm, Map<String, dynamic> data) {
    final draftedValue = (data["strategyComment"] ?? "").toString();
    final draftedId = data["commentId"];

    vm.comment.strategyComment = draftedValue;
    vm.comment.id = draftedId;

    if (vm.comments?.isNotEmpty ?? false) {
      vm.comments!.first.strategyComment = draftedValue;
      vm.comments!.first.id = draftedId;
    }

    vm.emit(vm.state.copyWith());
  }
}
