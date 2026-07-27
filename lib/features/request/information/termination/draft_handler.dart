import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/information/termination/model.dart";
import "package:wcas_frontend/models/request/comment.dart";

/// Draft handler for the Termination screen.
///
/// Keeps TerminationViewModel focused on business logic by owning
/// autosave serialization/deserialization of the minimal, user-entered state.
class TerminationDraftHandler extends DraftHandler<TerminationViewModel> {
  /// Build a JSON-safe map from the current form state.
  ///
  /// We make sure to flush any `FormField.onSaved` callbacks first so that
  /// widgets using `onSaved` (rather than controllers) write their values
  /// back into the ViewModel's `comment` object.
  @override
  Map<String, dynamic> buildDraftData(TerminationViewModel vm) {
    // Flush onSaved callbacks — required for screens using onSaved in
    // FormFields.
    vm.formKey.currentState?.save();

    final Comment? c = vm.comment;
    return <String, dynamic>{
      // Selected reason id (as string) – your code uses `reasonList` to hold
      // it.
      "reasonList": c?.reasonList,
      // Category id if you’re tagging the comment with a category.
      "categoryId": c?.categoryId,
      // Free-text details entered by the user.
      "comment": c?.comment,
    };
  }

  /// Restore draft values into the live ViewModel.
  ///
  /// - Rehydrates the minimal `comment` fields (reasonList, categoryId,
  /// comment)
  /// - Mirrors the reason back to the first `getReviewComments` item if present
  ///   (to keep the screen’s state consistent with your current pattern)
  /// - Emits a no-op state update so UI can refresh if bound to these fields
  @override
  void applyDraft(TerminationViewModel vm, Map<String, dynamic> data) {
    // Ensure there’s a Comment instance to write into.
    vm.comment ??= Comment();

    // Restore fields defensively.
    final dynamic reasonList = data["reasonList"];
    final dynamic categoryId = data["categoryId"];
    final dynamic commentText = data["comment"];

    if (reasonList != null) {
      vm.comment!.reasonList = reasonList.toString();
      // Keep the "review comments" mirror in sync if it’s used by the UI.
      if ((vm.getReviewComments ?? []).isNotEmpty) {
        vm.getReviewComments!.first.reasonList = reasonList.toString();
      }
    }

    if (categoryId != null) {
      // Accept both int and string-like ids.
      vm.comment!.categoryId = _asInt(categoryId);
    }

    if (commentText != null) {
      vm.comment!.comment = commentText.toString();
    }

    // Notify UI (no loader change) in case widgets are listening.
    vm.emit(vm.state.copyWith());
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  int? _asInt(Object? v) {
    if (v == null) {
      return null;
    }
    if (v is int) {
      return v;
    }
    return int.tryParse(v.toString());
  }
}
