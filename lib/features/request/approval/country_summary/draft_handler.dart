import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/approval/country_summary/model.dart";
import "package:wcas_frontend/models/request/comment.dart";

class CountrySummaryTabsDraftHandler
    extends DraftHandler<CountrySummaryViewModel> {
  @override
  Map<String, dynamic> buildDraftData(CountrySummaryViewModel vm) {
    return {
      "strategyComment": vm.controller.currentText.toString(),
    };
  }

  @override
  void applyDraft(CountrySummaryViewModel vm, Map<String, dynamic> data) {
    // Convert any type to string safely
    final String? commentContent = _asString(data["strategyComment"]);

    if (commentContent != null) {
      vm.comment ??= Comment();
      UnifiedEditorController commentCtrls() => vm.controller;

      vm.comment!.comment = commentContent;
      commentCtrls().setText(commentContent);
      vm.initialText = commentContent;
      // Nudge UI to rebuild if it binds directly to VM fields
      vm.emit(vm.state.copyWith());
    }
  }

  // ---- helpers ----
  String? _asString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}
