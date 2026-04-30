import "package:flutter/material.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/features/request/ccsys/termination/model.dart";
import "package:wcas_frontend/models/request/comment.dart";

/// Draft handler for the CCsys Termination / Withdrawal screen.
/// This version ONLY implements the flat methods required by your base:
/// - buildDraftData
/// - applyDraft
///
/// The DraftMixin is responsible for saving/loading/deleting the draft,
/// using the ViewModel's draftModuleKey/draftFormKey.
class CcsysTerminationDraftHandler
    extends DraftHandler<CcsysTerminationViewModel> {
  CcsysTerminationDraftHandler();

  /// Serialize current form state to a simple map.
  /// Make sure onSaved of form fields are flushed first.
  @override
  Map<String, dynamic> buildDraftData(CcsysTerminationViewModel vm) {
    vm.formKey.currentState?.save();

    return <String, dynamic>{
      "reasonList": vm.comment?.reasonList,
      "categoryId": vm.comment?.categoryId,
      "comment": vm.comment?.comment,
    };
  }

  /// Restore draft values back into the live ViewModel.
  /// Includes defensive type coercion and an optional applicationRef guard.
  @override
  void applyDraft(CcsysTerminationViewModel vm, Map<String, dynamic> data) {
    if (data.isEmpty) {
      logger.w("Draft: applyDraft called with empty payload");
      return;
    }

    // Optional: ignore drafts that belong to another request
    final currentRef = Globals.request?.applicationRefNo;
    final draftRef = _asString(data["applicationRef"]);
    if (currentRef != null && draftRef != null && currentRef != draftRef) {
      logger.w(
        "Draft: ignored (applicationRef mismatch: $draftRef != $currentRef)",
      );
      return;
    }

    vm.comment ??= Comment();
    TextEditingController commentCtrls() => vm.remarksController;
    final String? reasonList = _asString(data["reasonList"]);
    final int? categoryId = _asInt(data["categoryId"]);
    final String? commentText = _asString(data["comment"]);

    if (reasonList != null) vm.comment!.reasonList = reasonList;
    if (categoryId != null) vm.comment!.categoryId = categoryId;
    if (commentText != null) {
      vm.comment!.comment = commentText;
      commentCtrls().text = commentText;
    }

    // Nudge UI to rebuild if it binds directly to VM fields
    vm.emit(vm.state.copyWith());

    logger.i(
      "Draft: applied (reasonList=${vm.comment!.reasonList}, "
      "categoryId=${vm.comment!.categoryId}, comment=${vm.comment!.comment})",
    );
  }

  // ---- helpers ----
  String? _asString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
}
