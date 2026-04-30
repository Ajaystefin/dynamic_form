import "package:flutter/material.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
// ignore: avoid_relative_lib_imports — intentional same-feature import
import "package:wcas_frontend/features/request/approval/comments/model.dart";

/// Draft handler for the **Comments** screen.
///
/// Owns autosave serialization and deserialization logic so that
/// [CommentsViewModel] stays focused on business logic only.
///
/// Design notes:
/// - We persist only user-editable inputs and intent (editor text &
/// selections).
/// - We avoid persisting transient/server-derived fields (e.g., reviewCommentId),
///   dynamic user maps, or sensitive values (e.g., RSA token).
class CommentsDraftHandler extends DraftHandler<CommentsViewModel> {
  /// Serializes the current comments form state to JSON.
  ///
  /// Calls [formKey.currentState?.save()] first because the page may rely on
  /// `onSaved` callbacks rather than controllers to update the ViewModel.
  @override
  Map<String, dynamic> buildDraftData(CommentsViewModel vm) {
    // Flush onSaved callbacks — required for screens using onSaved in
    // FormFields.
    // vm.formKey.currentState?.save();

    // NOTE: UnifiedEditorController.getText() is async; we therefore persist
    // vm.initialText, which the ViewModel keeps in sync on text change.
    debugPrint("buildDraftData comments");
    return {
      "initialText": vm.controller.currentText,
      "returnOptSelected": vm.returnOptSelected,
      "optsActionId": vm.optsActionId,
      "selectedUserId": vm.selectedUserId,
      "selectedDelegation": vm.selectedDelegation,
      "selectedReason": vm.selectedReason,
      "isReturnSelected": vm.isReturnSelected,
      "isRecommendSelected": vm.isRecommendSelected,
    };
  }

  /// Restores draft values back into the live [CommentsViewModel].
  ///
  /// In addition to restoring the fields, we also push the persisted text
  /// to the rich editor via [UnifiedEditorController.setText].
  @override
  void applyDraft(CommentsViewModel vm, Map<String, dynamic> data) {
    // Restore editor text and push to controller so the UI reflects the value.
    debugPrint("applyDraft comments");

    final String? draftedText = data["initialText"] as String?;
    if (draftedText != null) {
      vm.initialText = draftedText;
      vm.controller.setText(draftedText);
    }

    // Restore simple selections & flags
    vm.returnOptSelected =
        (data["returnOptSelected"] as String?) ?? vm.returnOptSelected;

    final dynamic optsIdRaw = data["optsActionId"];
    if (optsIdRaw is int) {
      vm.optsActionId = optsIdRaw;
    } else if (optsIdRaw is String) {
      vm.optsActionId = int.tryParse(optsIdRaw) ?? vm.optsActionId;
    }

    vm.selectedUserId =
        (data["selectedUserId"] as String?) ?? vm.selectedUserId;

    vm.selectedDelegation =
        (data["selectedDelegation"] as String?) ?? vm.selectedDelegation;

    vm.selectedReason =
        (data["selectedReason"] as String?) ?? vm.selectedReason;

    final dynamic isReturn = data["isReturnSelected"];
    if (isReturn is bool) {
      vm.isReturnSelected = isReturn;
    }

    final dynamic isRecommend = data["isRecommendSelected"];
    if (isRecommend is bool) {
      vm.isRecommendSelected = isRecommend;
    }
  }
}
