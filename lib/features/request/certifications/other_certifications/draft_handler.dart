import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/certifications/other_certifications/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class OtherCertificationsDraftHandler
    extends DraftHandler<OtherCertificationsViewModel> {
  @override
  Map<String, dynamic> buildDraftData(OtherCertificationsViewModel vm) {
    // Save the user-modifiable fields for each certification item inside the
    // map.
    // We keyed by referenceId.
    final Map<String, dynamic> draftData = {};
    for (final entry in vm.certificationDataMap.entries) {
      // Only serialize the selectedOption ID and remarks
      draftData[entry.key.toString()] = {
        "selectedOptionId": entry.value.selectedOption?.id,
        "remarks": entry.value.remarks,
      };
    }
    return draftData;
  }

  @override
  void applyDraft(OtherCertificationsViewModel vm, Map<String, dynamic> data) {
    for (final entry in data.entries) {
      final int? referenceId = int.tryParse(entry.key);
      if (referenceId != null &&
          vm.certificationDataMap.containsKey(referenceId)) {
        final draftItem = entry.value as Map<String, dynamic>?;
        if (draftItem != null) {
          final int? optionId = draftItem["selectedOptionId"] as int?;
          final String? remarks = draftItem["remarks"] as String?;

          final certData = vm.certificationDataMap[referenceId]!;

          // Re-attach the concrete Reference object for the selected option
          if (optionId != null) {
            Reference? option;
            try {
              option = vm.yesNoNaOptions.firstWhere((o) => o.id == optionId);
            } catch (_) {}

            if (option != null && certData.selectedOption?.id != option.id) {
              certData
                ..selectedOption = option
                ..isUpdated = true; // Mark as updated so saving persists it
            }
          }

          // Restore remarks
          if (remarks != null && remarks != certData.remarks) {
            certData
              ..remarks = remarks
              ..isUpdated = true;
          }
        }
      }
    }

    // We don't need to manually emit here; the framework or the caller should
    // trigger rebuild
    // but we can call an emit in the view model if necessary - though typical
    // drafts are loaded before state is fully emitted.
  }
}
