import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Handles draft save and restore operations for workflow configuration.
class UpdateWorkflowConfigDraftHandler
    extends DraftHandler<UpdateWorkflowConfigViewModel> {
  static const String _skipKey = "__skip_draft__";

  // ---------------------------------------------------------------------------
  // Draft key
  // ---------------------------------------------------------------------------

  /// Resolves the draft key for the current workflow configuration.
  ///
  /// NOTE:
  /// Do NOT use @override here unless your DraftHandler base class declares it.
  String resolveDraftKey(UpdateWorkflowConfigViewModel vm) {
    final String configId =
        vm.editingConfig?.id?.toString() ??
        vm.draftReference.id?.toString() ??
        "new";

    final String typeId =
        vm.customAppTypeId?.toString() ??
        vm.draftReference.typeId?.toString() ??
        "na";

    return "update_workflow_config_${typeId}_$configId";
  }

  // ---------------------------------------------------------------------------
  // Build draft data (SAVE)
  // ---------------------------------------------------------------------------

  /// Builds draft data for persistence.
  @override
  Map<String, dynamic> buildDraftData(UpdateWorkflowConfigViewModel vm) {
    if (!vm.isDraftReady) {
      logger.i("Draft skipped — workflow config dialog not ready");
      return const <String, dynamic>{_skipKey: true};
    }

    // Process/save draft only when config was provided (edit mode)
    if (vm.editingConfig == null) {
      logger.i("Draft skipped — no config provided (add mode)");
      return const <String, dynamic>{_skipKey: true};
    }

    if (vm.formKey.currentState?.mounted ?? false) {
      vm.formKey.currentState!.save();
    }

    return <String, dynamic>{
      "customAppTypeId": vm.customAppTypeId,
      "draft": vm.draftReference.toJson(),
      "isEditMode": vm.isEditMode,
      "editingConfigId": vm.editingConfig?.id,
      "selectedWorkflowType": vm.selectedWorkflowType,
      "selectedCustomerSegment": vm.selectedCustomerSegment,
      "selectedCategory": vm.selectedCategory,
      "selectedApplicationType": vm.selectedApplicationType,
      "newApplicationTypeName": vm.newApplicationTypeName,
      "selectedStatus": vm.selectedStatus,
    };
  }

  // ---------------------------------------------------------------------------
  // Apply draft (RESTORE)
  // ---------------------------------------------------------------------------

  /// Restores draft data into the workflow configuration view model.
  @override
  void applyDraft(
    UpdateWorkflowConfigViewModel vm,
    Map<String, dynamic> data,
  ) {
    try {
      if (data.containsKey(_skipKey)) {
        logger.i("Skipping empty workflow config draft");
        return;
      }

      // Process draft only when config was provided (edit mode)
      if (vm.editingConfig == null) {
        logger.i("Draft ignored — no config provided (add mode)");
        return;
      }

      final Map<String, dynamic>? draftJson =
          data["draft"] as Map<String, dynamic>?;
      if (draftJson == null) {
        logger.i("Workflow config draft has no draft payload");
        return;
      }

      final int? draftTypeId = data["customAppTypeId"] as int?;
      final int? currentTypeId = vm.customAppTypeId;

      if (draftTypeId != null &&
          currentTypeId != null &&
          draftTypeId != currentTypeId) {
        logger.w("Workflow config draft ignored — referenceType mismatch");
        return;
      }

      // Optional safety: ensure draft belongs to same edited config
      final dynamic draftConfigId = data["editingConfigId"];
      final dynamic currentConfigId = vm.editingConfig?.id;

      if (draftConfigId != null &&
          currentConfigId != null &&
          draftConfigId.toString() != currentConfigId.toString()) {
        logger.w("Workflow config draft ignored — config id mismatch");
        return;
      }

      final Reference savedDraft = Reference.fromJson(draftJson);

      final String? workflowType = data["selectedWorkflowType"]?.toString();
      final String? customerSegment =
          data["selectedCustomerSegment"]?.toString();
      final String? category = data["selectedCategory"]?.toString();
      final String? applicationType =
          data["selectedApplicationType"]?.toString();

      final String draftName =
          data["newApplicationTypeName"]?.toString() ?? savedDraft.name ?? "";
      final String? status = data["selectedStatus"]?.toString();

      // Restore dropdown cascade in proper order
      if (workflowType != null && workflowType.trim().isNotEmpty) {
        vm.onWorkflowTypeSelected(workflowType);
      }

      if (customerSegment != null && customerSegment.trim().isNotEmpty) {
        vm.onCustomerSegmentSelected(customerSegment);
      }

      if (category != null && category.trim().isNotEmpty) {
        vm.onCategorySelected(category);
      }

      if (applicationType != null && applicationType.trim().isNotEmpty) {
        vm.onApplicationTypeSelected(applicationType);
      }

      // IMPORTANT: do not apply blank/whitespace names
      if (draftName.trim().isNotEmpty) {
        vm.onNewApplicationTypeNameChanged(draftName);
      }

      // IMPORTANT: do not apply blank/whitespace status
      if (status != null && status.trim().isNotEmpty) {
        vm.onStatusChanged(status);
      }

      final Reference merged = vm.draftReference
        ..id = savedDraft.id ?? vm.draftReference.id
        ..name = _pick(savedDraft.name, vm.draftReference.name)
        ..reference1 =
            _pick(savedDraft.reference1, vm.draftReference.reference1)
        ..reference2 =
            _pick(savedDraft.reference2, vm.draftReference.reference2)
        ..reference3 =
            _pick(savedDraft.reference3, vm.draftReference.reference3)
        ..reference4 =
            _pick(savedDraft.reference4, vm.draftReference.reference4)
        ..reference5 =
            _pick(savedDraft.reference5, vm.draftReference.reference5) ?? "N"
        ..status = _pick(savedDraft.status, vm.draftReference.status)
        ..isActive = savedDraft.isActive ?? vm.draftReference.isActive
        ..typeId =
            savedDraft.typeId ??
            vm.customAppTypeId ??
            vm.draftReference.typeId;

      vm.draftReference = merged;

      logger.i("Workflow config draft applied successfully");
    } on Object catch (e) {
      logger.e("Failed to apply workflow config draft: $e");
    }
  }

  String? _pick(String? draftValue, String? fallbackValue) {
    final String? trimmed = draftValue?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return fallbackValue;
    }
    return draftValue;
  }
}
