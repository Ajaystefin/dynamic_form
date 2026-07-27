import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/role_right_mapping/model.dart";
import "package:wcas_frontend/models/admin/access_right.dart";

/// Handles draft save and restore operations for role-right mappings.
class RoleRightMappingsDraftHandler
    extends DraftHandler<RoleRightMappingViewModel> {
  // ---------------------------------------------------------------------------
  // Draft key (one per role + request type combination)
  // ---------------------------------------------------------------------------

  /// Resolves the draft key for the selected role and request type.
  String resolveDraftKey(RoleRightMappingViewModel vm) {
    final roleId = vm.selectedRole?.id;
    final requestTypeId = vm.selectedRequestType?.id;
    if (roleId != null && requestTypeId != null) {
      return "role_right_mapping_${roleId}_$requestTypeId";
    } else if (roleId != null) {
      return "role_right_mapping_$roleId";
    }
    return "role_right_mapping_no_role";
  }

  // ---------------------------------------------------------------------------
  // SAVE (store API-shaped JSON)
  // ---------------------------------------------------------------------------

  /// Builds draft data for storage.
  @override
  Map<String, dynamic> buildDraftData(RoleRightMappingViewModel vm) {
    if (vm.selectedRole == null || vm.selectedRequestType == null) {
      return const {"__skip__": true};
    }

    final accessRight = vm.updatedAccessRight;
    if (accessRight == null) {
      return const {"__skip__": true};
    }

    return {
      "roleId": vm.selectedRole!.id,
      "requestTypeId": vm.selectedRequestType!.id,
      "accessRight": _toFullJson(accessRight),
    };
  }

  // ---------------------------------------------------------------------------
  // RESTORE (use existing fromJson)
  // ---------------------------------------------------------------------------

  /// Restores draft data into the view model.
  @override
  void applyDraft(
    RoleRightMappingViewModel vm,
    Map<String, dynamic> data,
  ) {
    try {
      final int? draftRoleId = data["roleId"] as int?;
      final int? draftRequestTypeId = data["requestTypeId"] as int?;
      final int? currentRoleId = vm.selectedRole?.id;
      final int? currentRequestTypeId = vm.selectedRequestType?.id;

      if (draftRoleId == null || draftRoleId != currentRoleId) {
        logger.i("RoleRightMapping draft ignored – role mismatch");
        return;
      }

      if (draftRequestTypeId == null ||
          draftRequestTypeId != currentRequestTypeId) {
        logger.i("RoleRightMapping draft ignored – request type mismatch");
        return;
      }

      final Map<String, dynamic>? accessRightJson =
          data["accessRight"] as Map<String, dynamic>?;

      if (accessRightJson == null) {
        return;
      }

      // restore using existing fromJson constructor
      final restored = AccessRight.fromJson(accessRightJson);

      vm
        ..accessRight = restored
        ..updatedAccessRight = restored;

      logger.i(
        "RoleRightMapping draft restored "
        "(${restored.pages?.length ?? 0} pages)",
      );
    } on Object {
      logger.e("Failed to restore RoleRightMapping draft");
    }

    vm.emit(
      vm.state.copyWith(referencesLoaderStatus: LoadingStatus.loaded),
    );
  }

  // ---------------------------------------------------------------------------
  // Convert AccessRight → full JSON for draft storage
  // (uses 'pageList' key so fromJson can restore ALL pages, not just updated
  // ones)
  // ---------------------------------------------------------------------------

  /// Converts an [AccessRight] instance to JSON for draft storage.
  Map<String, dynamic> _toFullJson(AccessRight a) {
    return {
      "role": a.role,
      "requestType": a.requestType,
      "subType": a.subType,
      "pageList": a.pages?.map((page) => page.toJson()).toList(),
    };
  }
}
