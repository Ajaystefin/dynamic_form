import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/recommend_for_current_approval/model.dart"; // RecommendCurrentApprovalViewModel

/// Draft handler for "Recommend for Current Approval" screen.
class RecommendCurrentApprovalDraftHandler
    extends DraftHandler<RecommendCurrentApprovalViewModel> {
  /// Build a stable, collision-free draft key.
  /// Key parts:
  ///   - form key (route)
  ///   - applicationRefNo (or "NA" if not available)
  ///   - current role id (so drafts are role-specific)
  String resolveDraftKey(RecommendCurrentApprovalViewModel vm) {
    final formKey = vm.draftFormKey;
    final roleId = Globals.user?.currentRole?.roleId?.toString() ?? "0";
    return "${formKey}_r$roleId";
  }

  /// Compose the draft payload from the current VM state.
  @override
  Map<String, dynamic> buildDraftData(RecommendCurrentApprovalViewModel vm) {
    // Save any pending form changes
    vm.formKey.currentState?.save();

    final payload = <String, dynamic>{
      "initialText": vm.initialText,
      "reviewCommentId": vm.reviewCommentId,
      "isCommentVisible": vm.isCommentVisible,
      "meta": {
        "appRefNo": Globals.request?.applicationRefNo,
        "roleId": Globals.user?.currentRole?.roleId,
        "timestamp": DateTime.now().toIso8601String(),
        "formKey": vm.draftFormKey,
        "moduleKey": vm.draftModuleKey,
      },
      // place for transient UI flags if you want to persist them
      "ui": <String, dynamic>{
        // intentionally NOT persisting canEdit/isReadOnly as they are derived
      },
    };

    logger.d("[RecommendCurrentApprovalDraftHandler] buildDraftData: $payload");
    return payload;
  }

  /// Apply the draft into the VM, avoiding overwriting computed permissions.
  @override
  void applyDraft(
    RecommendCurrentApprovalViewModel vm,
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

      final isVisible = data["isCommentVisible"];
      if (isVisible is bool) {
        vm.isCommentVisible = isVisible;
      }

      // NOTE: Do NOT override canEdit / isReadOnly here.
      // Those are computed from role, status, and app sub-status during init().

      // Refresh UI
      vm.emit(vm.state.copyWith(loaderStatus: LoadingStatus.loaded));
      logger.d("[RecommendCurrentApprovalDraftHandler] applyDraft: success");
    } catch (e) {
      logger.e("[RecommendCurrentApprovalDraftHandler] applyDraft error: $e");
      // Still try to keep the UI responsive
      vm.emit(vm.state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }
}
