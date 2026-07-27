import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_other_banks/model.dart";

/// Draft handler for the Facilities with Other Banks section.
class FacilitiesWithOtherBanksDraftHandler
    extends DraftHandler<FacilitiesWithOtherBanksViewModel> {
  @override
  Map<String, dynamic> buildDraftData(FacilitiesWithOtherBanksViewModel vm) {
    String? nz(String? s) => (s != null && s.trim().isNotEmpty) ? s : null;

    return <String, dynamic>{
      "strategyComment": nz(vm.strategyCommentController.text),
      "strategyCommentCBRB": nz(vm.strategyCommentCBRBController.text),
    };
  }

  @override
  void applyDraft(
    FacilitiesWithOtherBanksViewModel vm,
    Map<String, dynamic> data,
  ) {
    if (data.isEmpty) {
      return;
    }

    final Object? rawStrategy = data["strategyComment"];
    final Object? rawStrategyCBRB = data["strategyCommentCBRB"];

    final String? draftedStrategy =
        (rawStrategy is String && rawStrategy.trim().isNotEmpty)
            ? rawStrategy
            : null;

    final String? draftedStrategyCBRB =
        (rawStrategyCBRB is String && rawStrategyCBRB.trim().isNotEmpty)
            ? rawStrategyCBRB
            : null;

    if (draftedStrategy != null) {
      vm.strategyComment = draftedStrategy;
      vm.strategyCommentController.text = draftedStrategy;
    }

    if (draftedStrategyCBRB != null) {
      vm.strategyCommentCBRB = draftedStrategyCBRB;
      vm.strategyCommentCBRBController.text = draftedStrategyCBRB;
    }

    try {
      vm.emit(vm.state.copyWith());
    } on Object catch (_) {}
  }
}
