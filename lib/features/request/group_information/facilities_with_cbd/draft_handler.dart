import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_cbd/model.dart";
import "package:wcas_frontend/models/request/comment.dart";

class FacilitiesWithCbdDraftHandler
    extends DraftHandler<FacilitiesWithCbdViewModel> {
  @override
  Map<String, dynamic> buildDraftData(FacilitiesWithCbdViewModel vm) {
    final Comment? c = vm.comment;

    return <String, dynamic>{
      "comment": vm.commentController.text.isNotEmpty
          ? vm.commentController.text
          : c?.comment,
    };
  }

  @override
  void applyDraft(
    FacilitiesWithCbdViewModel vm,
    Map<String, dynamic> data,
  ) {
    vm.comment ??= Comment();

    final dynamic commentText = data["comment"];
    if (commentText != null) {
      final value = commentText.toString();
      vm.comment!.comment = value;
      vm.commentController.text = value;
    }

    vm.emit(vm.state.copyWith());
  }
}
