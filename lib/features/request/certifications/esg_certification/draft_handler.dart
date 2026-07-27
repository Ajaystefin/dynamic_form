import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/model.dart";
import "package:wcas_frontend/models/request/esg_certification.dart";

/// Draft handler for ESG Certification.
class EsgCertificationDraftHandler
    extends DraftHandler<EsgCertificationViewModel> {
  /// Creates an ESG certification draft handler.
  EsgCertificationDraftHandler();

  @override
  Map<String, dynamic> buildDraftData(EsgCertificationViewModel vm) {
    // Force UI forms to flush into the viewmodel
    vm.formKey.currentState?.save();

    return {
      // 'sffRequired': vm.sffRequired,
      // 'sllRequired': vm.sllRequired,
      "isAdverseMedia": vm.isAdverseMedia,
      "adverseMediaSummary": vm.adverseMediaSummary,
      "isExcluded": vm.isExcluded,
      "excludedStatus": vm.excludedStatus.apiValue,
      "excludedActivities": vm.excludedActivities,
      "additionalChecklist": vm.additionalChecklist,
      "esgSffCategoriess": vm.esgSffCategoriess.map((e) => e.toJson()).toList(),
      // 'facilitiesRiskRatings':
      // vm.facilitiesRiskRatings.map((e) => e.toJson()).toList(),
      // Convert map with int keys to map with String keys for JSON
      "inputsByRefId":
          vm.inputsByRefId.map((key, value) => MapEntry(key.toString(), value)),
    };
  }

  @override
  void applyDraft(EsgCertificationViewModel vm, Map<String, dynamic> data) {
    // vm.sffRequired = data['sffRequired'] as bool? ?? vm.sffRequired;
    // vm.sllRequired = data['sllRequired'] as bool? ?? vm.sllRequired;
    vm
      ..isAdverseMedia = data["isAdverseMedia"] as bool? ?? vm.isAdverseMedia
      ..adverseMediaSummary =
          data["adverseMediaSummary"] as String? ?? vm.adverseMediaSummary
      ..isExcluded = data["isExcluded"] as String? ?? vm.isExcluded;

    if (data["excludedStatus"] != null) {
      vm.excludedStatus =
          ExclusionStatusX.fromApi(data["excludedStatus"] as String);
    }

    if (data["excludedActivities"] != null) {
      vm.excludedActivities =
          (data["excludedActivities"] as List).cast<String>();
    }

    vm.additionalChecklist =
        data["additionalChecklist"] as String? ?? vm.additionalChecklist;

    if (data["esgSffCategoriess"] != null) {
      vm.esgSffCategoriess = (data["esgSffCategoriess"] as List)
          .map((json) => SffCategory.fromJson(json))
          .toList();
    }

    // if (data['facilitiesRiskRatings'] != null) {
    //   vm.facilitiesRiskRatings = (data['facilitiesRiskRatings'] as List)
    //       .map((json) => FacilityRiskRating.fromJson(json))
    //       .toList();
    // }

    if (data["inputsByRefId"] != null) {
      final inputs = data["inputsByRefId"] as Map<String, dynamic>;
      vm.inputsByRefId.clear();
      inputs.forEach((key, value) {
        final intKey = int.tryParse(key);
        if (intKey != null) {
          vm.inputsByRefId[intKey] = value?.toString() ?? "";
        }
      });
    }

    // Update ephemeral UI states (such as checklist updates causing rebuilds)
    vm.fieldVersion++;
  }
}
