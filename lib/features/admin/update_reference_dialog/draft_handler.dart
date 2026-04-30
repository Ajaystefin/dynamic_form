import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class UpdateReferenceDialogDraftHandler
    extends DraftHandler<UpdateReferenceDialogViewModel> {
  static const _skipKey = "__skip_draft__";

  // ---------------------------------------------------------------------------
  // Draft key (per reference + type)
  // ---------------------------------------------------------------------------
  String resolveDraftKey(UpdateReferenceDialogViewModel vm) {
    final refId = vm.reference.id ?? "new";
    final typeId = vm.selectedReferenceType?.id ?? "na";
    return "update_reference_${typeId}_$refId";
  }

  // ---------------------------------------------------------------------------
  // Build draft data (SAVE)
  // ---------------------------------------------------------------------------
  @override
  Map<String, dynamic> buildDraftData(UpdateReferenceDialogViewModel vm) {
    //  Do NOT allow empty drafts to be saved
    if (!vm.isDraftReady) {
      logger.i("Draft skipped — dialog not ready");
      return const {_skipKey: true};
    }

    if (vm.formKey.currentState?.mounted == true) {
      vm.formKey.currentState!.save();
    }

    return {
      "referenceTypeId": vm.selectedReferenceType?.id,
      "reference": vm.reference.toJson(),
      "statusListValue": vm.statusListValue,
    };
  }

  // ---------------------------------------------------------------------------
  // Apply draft (RESTORE)
  // ---------------------------------------------------------------------------
  @override
  void applyDraft(
    UpdateReferenceDialogViewModel vm,
    Map<String, dynamic> data,
  ) {
    try {
      if (data.containsKey(_skipKey)) {
        logger.i("Skipping empty draft");
        return;
      }

      final refJson = data["reference"] as Map<String, dynamic>?;
      if (refJson == null) {
        logger.i("Draft has no reference data — keeping API values");
        return;
      }

      final int? draftTypeId = data["referenceTypeId"];
      final int? currentTypeId = vm.selectedReferenceType?.id;

      if (draftTypeId != null &&
          currentTypeId != null &&
          draftTypeId != currentTypeId) {
        logger.w("Draft ignored — referenceType mismatch");
        return;
      }

      // Build draft ref but DO NOT assign directly
      final draftRef = Reference.fromJson(refJson);

      // Merge: apply only non-empty strings, otherwise keep API values already
      // in vm.reference
      String? pick(String? draftValue, String? apiValue) {
        final v = draftValue?.trim();
        if (v == null || v.isEmpty) return apiValue;
        return draftValue;
      }

      vm.reference = vm.reference
        ..id = draftRef.id ?? vm.reference.id
        ..name = pick(draftRef.name, vm.reference.name)
        ..description = pick(draftRef.description, vm.reference.description)
        ..reference1 = pick(draftRef.reference1, vm.reference.reference1)
        ..reference2 = pick(draftRef.reference2, vm.reference.reference2)
        ..reference3 = pick(draftRef.reference3, vm.reference.reference3)
        ..reference4 = pick(draftRef.reference4, vm.reference.reference4)
        ..reference5 = pick(draftRef.reference5, vm.reference.reference5)
        ..status = pick(draftRef.status, vm.reference.status);

      // Restore UI-only fields
      final status = data["statusListValue"] as List?;
      if (status != null) {
        vm.statusListValue = status.map((e) => e.toString()).toList();
      }

      logger.i("Draft applied successfully");
    } catch (e) {
      logger.e("Failed to apply draft");
    }
  }
}
