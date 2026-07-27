import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";

// ignore: avoid_relative_lib_imports — intentional same-feature import
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_detailed/model.dart";

/// Draft handler for the Relationship Profitability Detailed screen.
///
/// Owns autosave serialization/deserialization for minimal user-entered state
/// so [RelationshipProfitabilityDetailedViewModel] stays focused on business
/// logic.
class RelationshipProfitabilityDetailedDraftHandler
    extends DraftHandler<RelationshipProfitabilityDetailedViewModel> {
  @override
  Map<String, dynamic> buildDraftData(
    RelationshipProfitabilityDetailedViewModel vm,
  ) {
    return <String, dynamic>{
      "strategyComment": vm.strategyCommentController.text,
    };
  }

  @override
  void applyDraft(
    RelationshipProfitabilityDetailedViewModel vm,
    Map<String, dynamic> data,
  ) {
    final dynamic value = data["strategyComment"];
    if (value != null) {
      final text = value.toString();
      vm.strategyComment = text;
      vm.strategyCommentController.text = text;
    }

    // Notify listeners in case widgets depend on state changes
    vm.emit(vm.state.copyWith());
  }
}
