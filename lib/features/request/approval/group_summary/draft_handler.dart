import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/approval/group_summary/model.dart";
import "package:wcas_frontend/models/request/comment.dart";

/// Handles draft data build and restore logic for group summary tabs.
class GroupSummaryTabsDraftHandler extends DraftHandler<GroupSummaryViewModel> {
  /// Builds the draft data from the group summary view model.
  @override
  Map<String, dynamic> buildDraftData(GroupSummaryViewModel vm) {
    return {
      "strategyComment": vm.controller.currentText,
    };
  }

  @override
  void applyDraft(GroupSummaryViewModel vm, Map<String, dynamic> data) {
    // vm.formKey.currentState?.save();
    final String? commentContent = _asString(data["strategyComment"]);
    if (commentContent != null) {
      vm.comment ??= Comment();
      vm
        ..comment!.comment = commentContent
        ..controller.setText(commentContent)
        ..initialText = commentContent
        ..emit(vm.state.copyWith());
    }
  }

  // ---- helpers ----
  String? _asString(v) {
    if (v == null) {
      return null;
    }
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}
