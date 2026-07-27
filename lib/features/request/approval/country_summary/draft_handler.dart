import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/approval/country_summary/model.dart";
import "package:wcas_frontend/models/request/comment.dart";

/// Handles draft data build and restore logic for country summary tabs.
class CountrySummaryTabsDraftHandler
    extends DraftHandler<CountrySummaryViewModel> {
  /// Builds the draft data from the country summary view model.
  @override
  Map<String, dynamic> buildDraftData(CountrySummaryViewModel vm) {
    return {
      "strategyComment": vm.controller.currentText,
    };
  }

  /// Applies saved draft data back to the country summary view model.
  @override
  void applyDraft(CountrySummaryViewModel vm, Map<String, dynamic> data) {
    // Convert any type to string safely
    final String? commentContent = _asString(data["strategyComment"]);

    if (commentContent != null) {
      vm.comment ??= Comment();

      vm
        ..comment!.comment = commentContent
        ..controller.setText(commentContent)
        ..initialText = commentContent
        ..emit(vm.state.copyWith());
    }
  }

  // ---- helpers ----
  String? _asString(v) {
    if (v == null) {
      return null;
    }
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}
