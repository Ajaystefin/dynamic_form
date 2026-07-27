import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/file_access/model.dart";
import "package:wcas_frontend/models/admin/file_access.dart";
import "package:wcas_frontend/models/admin/page.dart";

/// Handles draft save and restore operations for file access management.
class FileAccessDraftHandler extends DraftHandler<FileAccessViewModel> {
  // ---------------------------------------------------------------------------
  // Draft key (one per role)
  // ---------------------------------------------------------------------------

  /// Resolves the draft storage key based on the selected role.
  String resolveDraftKey(FileAccessViewModel vm) {
    final roleId = vm.selectedRoleType?.id;
    return roleId != null ? "file_access_$roleId" : "file_access_no_role";
  }

  // ---------------------------------------------------------------------------
  // SAVE (store API-shaped JSON)
  // ---------------------------------------------------------------------------

  /// Builds the draft data to be stored.
  @override
  Map<String, dynamic> buildDraftData(FileAccessViewModel vm) {
    if (vm.selectedRoleType == null) {
      return const {"__skip__": true};
    }

    return {
      "roleId": vm.selectedRoleType!.id,
      "fileAccesses": vm.fileAccesses.map(_toApiJson).toList(),
    };
  }

  // ---------------------------------------------------------------------------
  // RESTORE (use existing fromJson)
  // ---------------------------------------------------------------------------

  /// Applies the stored draft data to the view model.
  @override
  void applyDraft(
    FileAccessViewModel vm,
    Map<String, dynamic> data,
  ) {
    try {
      final int? draftRoleId = data["roleId"] as int?;
      final int? currentRoleId = vm.selectedRoleType?.id;

      if (draftRoleId == null || draftRoleId != currentRoleId) {
        logger.i("FileAccess draft ignored – role mismatch");
        return;
      }

      final List<dynamic>? list = data["fileAccesses"] as List<dynamic>?;

      if (list == null || list.isEmpty) {
        return;
      }

      // ✅ restore using existing API constructor
      final restored = list
          .map(
            (e) => FileAccess.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();

      vm
        ..fileAccesses = restored
        ..firstLevelParentsWithChildren =
            restored.where((e) => e.children?.isNotEmpty ?? false).toList();

      logger.i(
        "FileAccess draft restored (${restored.length} root nodes)",
      );
    } on Object {
      logger.e("Failed to restore FileAccess draft");
    }
    vm.emit(
      vm.state.copyWith(fileAccessStatus: LoadingStatus.loaded),
    );
  }

  // ---------------------------------------------------------------------------
  // Convert FileAccess → API JSON
  // ---------------------------------------------------------------------------

  /// Converts a [FileAccess] object to API-compatible JSON.
  Map<String, dynamic> _toApiJson(FileAccess f) {
    return {
      "id": f.id,
      "name": f.name,
      "parentId": f.parentId,
      "access": accessTypeToString(f.access),
      "children": f.children?.map(_toApiJson).toList(),
    };
  }
}
