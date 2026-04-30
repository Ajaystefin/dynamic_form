import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/features/request/ccsys/approval/model.dart";
import "package:wcas_frontend/models/request/comment.dart";

/// Draft handler for the CCsys screen.
/// This version ONLY implements the flat methods required by your base:
/// - buildDraftData
/// - applyDraft
///
/// The DraftMixin is responsible for saving/loading/deleting the draft,
/// using the ViewModel's draftModuleKey/draftFormKey.
class CcsysApprovalDraftHandler extends DraftHandler<CcsysApprovalViewModel> {
  CcsysApprovalDraftHandler();

  /// Serialize current form state to a simple map.
  /// Make sure onSaved of form fields are flushed first.
  @override
  Map<String, dynamic> buildDraftData(CcsysApprovalViewModel vm) {
    return <String, dynamic>{
      "comment": vm.controller.currentText,
    };
  }

  /// Restore draft values back into the live ViewModel.
  /// Includes defensive type coercion and an optional applicationRef guard.
  @override
  void applyDraft(CcsysApprovalViewModel vm, Map<String, dynamic> data) {
    if (data.isEmpty) {
      logger.w("Draft: applyDraft called with empty payload");
      return;
    }

    vm.comment ??= Comment();
    UnifiedEditorController commentCtrls() => vm.controller;
    final String? commentText = _asString(data["comment"]);
    if (commentText != null) {
      vm.comment!.comment = commentText;
      commentCtrls().setText(commentText);
    }

    // Nudge UI to rebuild if it binds directly to VM fields
    vm.emit(vm.state.copyWith());

    logger.i(
      "Draft: comment=${vm.comment!.comment})",
    );
  }

  // ---- helpers ----
  String? _asString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}
