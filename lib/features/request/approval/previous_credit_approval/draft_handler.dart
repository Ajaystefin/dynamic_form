import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/previous_credit_approval/model.dart";

/// Draft handler for "Recommend for Current Approval" screen.
class PreviousCreditApprovalDraftHandler
    extends DraftHandler<PreviousCreditApprovalViewModel> {
  /// Build a stable, collision-free draft key.
  /// Key parts:
  ///   - form key (route)
  ///   - applicationRefNo (or "NA" if not available)
  ///   - current role id (so drafts are role-specific)
  String resolveDraftKey(PreviousCreditApprovalViewModel vm) {
    final formKey = vm.draftFormKey;
    final roleId = Globals.user?.currentRole?.roleId?.toString() ?? "0";
    return "${formKey}_r$roleId";
  }

  /// Compose the draft payload from the current VM state.
  @override
  Map<String, dynamic> buildDraftData(PreviousCreditApprovalViewModel vm) {
    // Save any pending form changes
    vm.formKey.currentState?.save();

    final payload = <String, dynamic>{
      "initialText": vm.initialText,
      "reviewCommentId": vm.reviewCommentId,
    };

    return payload;
  }

  /// Apply the draft into the VM, avoiding overwriting computed permissions.
  @override
  void applyDraft(
    PreviousCreditApprovalViewModel vm,
    Map<String, dynamic> data,
  ) {
    try {
      final String? text = (data["initialText"] as String?)?.trim();
      if (text != null && text.isNotEmpty) {
        vm.initialText = text;
      }

      final rcId = data["reviewCommentId"];
      if (rcId is String && rcId.trim().isNotEmpty) {
        vm.reviewCommentId = rcId.trim();
      }

      // NOTE: Do NOT override canEdit / isReadOnly here.
      // Those are computed from role, status, and app sub-status during init().

      // Refresh UI
      vm.emit(vm.state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      // Still try to keep the UI responsive
      vm.emit(vm.state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }
}
