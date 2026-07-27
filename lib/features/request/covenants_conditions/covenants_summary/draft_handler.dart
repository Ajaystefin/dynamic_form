import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenants_summary/model.dart";
import "package:wcas_frontend/models/request/comment.dart";

/// Draft handler for the Covenants Summary screen.
/// Stores/restores only the last comment text to keep the draft small & robust.
class CovenantsSummaryDraftHandler
    extends DraftHandler<CovenantsSummaryViewModel> {
  @override
  Map<String, dynamic> buildDraftData(CovenantsSummaryViewModel vm) {
    try {
      // Flush onSaved callbacks, if any are used in Forms.
      vm.formKey.currentState?.save();
    } on Object catch (_) {
      // ignore (form may not be mounted yet)
    }

    String? last;
    try {
      // Preferred: VM's single source of truth
      final c1 = vm.comment?.comment;
      if (c1 != null && c1.trim().isNotEmpty) {
        last = c1;
      } else if (vm.comments.isNotEmpty) {
        // Fallback: last server-backed comment
        final c2 = vm.comments.last.comment;
        if (c2 != null && c2.trim().isNotEmpty) {
          last = c2;
        }
      }

      // Final fallback: whatever is in the plain controller
      if (last == null || last.trim().isEmpty) {
        final c3 = vm.controller.text;
        if (c3.trim().isNotEmpty) {
          last = c3;
        }
      }
    } on Object catch (_) {
      // Avoid throwing — return minimal payload
    }

    return <String, dynamic>{
      "lastComment": last,
    };
  }

  @override
  void applyDraft(CovenantsSummaryViewModel vm, Map<String, dynamic> data) {
    try {
      final restored = data["lastComment"] as String?;
      if (restored == null) {
        return;
      }

      // Update VM single source of truth
      if (vm.comment == null) {
        vm.comment = Comment(comment: restored);
      } else {
        vm.comment!.comment = restored;
      }

      // // Sync comments list....
      // if (vm.comments.isEmpty) {
      //   vm.comments = [Comment(comment: restored)];
      // } else {
      //   vm.comments.last.comment = restored;
      // }

      // Update plain controller
      try {
        vm.controller.text = restored;
      } on Object catch (_) {}

      // Update rich editor (if mounted)
      try {
        vm.unifiedEditorController.setText(restored);
      } on Object catch (_) {}

      // Optional: nudge a rebuild if your UI depends on state
      try {
        vm.emit(vm.state.copyWith());
      } on Object catch (_) {}
    } on Object catch (_) {
      // swallow malformed data; never throw from draft handler
    }
  }
}
