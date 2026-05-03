import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/covenants_conditions/conditions_summary/model.dart";
import "package:wcas_frontend/models/request/comment.dart"; // ensure this import exists for Comment class

/// Draft handler for the Condition Summary screen.
/// Stores/restores the last comment text reliably.
class ConditionsSummaryDraftHandler
    extends DraftHandler<ConditionsSummaryViewModel> {
  /// Serializes the current condition summary form state to JSON.
  ///
  /// - Calls `formKey.currentState?.save()` to flush any onSaved fields.
  /// - Prefers `vm.comment.comment` as the single source of truth.
  /// - Falls back to `vm.comments.last.comment` or the plain controller's text
  /// if needed.
  @override
  Map<String, dynamic> buildDraftData(ConditionsSummaryViewModel vm) {
    try {
      // Flush onSaved callbacks — required for screens using onSaved in
      // FormFields.
      vm.formKey.currentState?.save();
    } catch (_) {
      // ignore: form may not be built yet; do not crash autosave
    }

    String? last;
    try {
      // Preferred: the single source of truth in the VM if editor updates it.
      final c1 = vm.comment.comment;
      if (c1 != null && c1.trim().isNotEmpty) {
        last = c1;
      } else if (vm.comments.isNotEmpty) {
        // Fallback: if you already loaded server comments, take the latest
        final c2 = vm.comments.last.comment;
        if (c2 != null && c2.trim().isNotEmpty) {
          last = c2;
        }
      }

      // Final fallback: whatever is currently visible in the plain controller
      if (last == null || last.trim().isEmpty) {
        final c3 = vm.controller.text;
        if (c3.trim().isNotEmpty) {
          last = c3;
        }
      }
    } catch (_) {
      // Avoid throwing—return minimal safe payload
    }

    return <String, dynamic>{
      "lastComment": last, // keep draft small and strongly typed
    };
  }

  /// Restores draft values into the live view model and UI.
  ///
  /// - Writes the restored text to:
  ///   * vm.comment.comment (single source of truth)
  ///   * vm.comments (ensures a last item exists)
  ///   * vm.controller.text (plain input)
  ///   * vm.unifiedEditorController.setText(...) (rich editor)
  /// - Optionally triggers a light UI rebuild.
  ///
  @override
  void applyDraft(ConditionsSummaryViewModel vm, Map<String, dynamic> data) {
    try {
      final restored = data["lastComment"] as String?;
      if (restored == null) return;

      // Update single source of truth
      vm.comment.comment = restored;

      // Ensure comments list reflects the same value (create last item if
      // needed)
      if (vm.comments.isEmpty) {
        vm.comments = [Comment(comment: restored)];
      } else {
        vm.comments.last.comment = restored;
      }

      // Update the plain controller
      try {
        vm.controller.text = restored;
      } catch (_) {
        // ignore if not mounted
      }

      // Update the rich text editor (if already mounted)
      try {
        vm.unifiedEditorController.setText(restored);
      } catch (_) {
        // ignore if editor not ready; VM still has the correct value
      }

      // Optional: nudge a lightweight rebuild if your UI needs it
      try {
        vm.emit(vm.state.copyWith());
      } catch (_) {
        // ignore if not allowed from here
      }
    } catch (e, _) {
      // Never throw from draft apply; ignore malformed data silently
      // logger.e('[Draft] applyDraft error: $e'); // uncomment if you want logging
    }
  }
}
