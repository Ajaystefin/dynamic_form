import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/remarks/common_tabs/model.dart";
import "package:wcas_frontend/models/request/comment.dart";

/// Handles draft persistence and restoration for the Common Tabs screen.
class CommonTabsDraftHandler extends DraftHandler<CommonTabsViewModel> {
  @override
  Map<String, dynamic> buildDraftData(CommonTabsViewModel vm) {
    return {
      "strategyComment": vm.rteController.currentText,
    };
  }

  @override
  void applyDraft(CommonTabsViewModel vm, Map<String, dynamic> data) {
    final String? commentContent = data["strategyComment"] as String?;
    if (commentContent != null) {
      if (vm.commentData != null) {
        vm.commentData!.strategyComment = commentContent;
      } else {
        vm.commentData = Comment(strategyComment: commentContent);
      }
    }
  }
}
