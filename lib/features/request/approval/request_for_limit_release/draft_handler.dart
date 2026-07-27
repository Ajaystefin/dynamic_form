import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/approval/request_for_limit_release/model.dart";

/// Handles draft data build and restore logic for request for limit release.
class RequestForLimitReleaseDraftHandler
    extends DraftHandler<RequestForLimitReleaseViewModel> {
  /// Builds the draft data from the request for limit release view model.
  @override
  Map<String, dynamic> buildDraftData(RequestForLimitReleaseViewModel vm) {
    return {
      // FIX: Use controller.currentText (live state) instead of vm.initialText
      // vm.initialText is only updated via onTextChange (user interaction),
      // so it can be stale when autosave fires on navigation/logout.
      "htmlComment": vm.controller.currentText,
      "selectedUserId": vm.selectedUserId,
      "selectedStage": vm.selectedStage,
    };
  }

  /// Applies saved draft data back to the request for limit release view model.
  @override
  void applyDraft(
    RequestForLimitReleaseViewModel vm,
    Map<String, dynamic> data,
  ) {
    final html = _asString(data["htmlComment"]);
    final user = _asString(data["selectedUserId"]);
    final stage = _asString(data["selectedStage"]);

    if (html != null) {
      // FIX: Keep both in sync — initialText is used as the editor's
      // seed value in the view, controller holds the live state.
      vm.initialText = html;
      vm.controller.setText(html);
    }

    if (user != null) {
      vm.selectedUserId = user;
    }
    if (stage != null) {
      vm.selectedStage = stage;
    }

    try {
      vm.emit(vm.state.copyWith());
    } on Object catch (_) {}
  }

  String? _asString(v) {
    if (v == null) {
      return null;
    }
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}
