import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/approval/country_summary/model.dart";
import "package:wcas_frontend/models/request/comment.dart";

class CountrySummaryTabsDraftHandler
    extends DraftHandler<CountrySummaryViewModel> {
  @override
  Map<String, dynamic> buildDraftData(CountrySummaryViewModel vm) {
    return {
      "strategyComment": vm.controller.currentText.toString(),
    };
  }

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
  String? _asString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}
