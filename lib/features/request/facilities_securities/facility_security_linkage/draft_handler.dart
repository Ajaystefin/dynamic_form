import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/facility_security_linkage/model.dart";

/// Draft handler for the Facility–Security Linkage screen.
///
/// Keeps [FacilitySecurityLinkageViewModel] focused on business logic by
/// owning auto-save serialization/deserialization of *user-entered state*
/// only (filters). Heavy server-driven lists are not persisted.
class FacilitySecurityLinkageDraftHandler
    extends DraftHandler<FacilitySecurityLinkageViewModel> {
  /// Build a JSON-safe draft payload.
  ///
  /// We call `formKey.currentState?.save()` first in case the screen uses
  /// any `FormField.onSaved` to store values back into the ViewModel.
  @override
  Map<String, dynamic> buildDraftData(FacilitySecurityLinkageViewModel vm) {
    // Flush onSaved callbacks — required for screens using onSaved in
    // FormFields.
    vm.formKey.currentState?.save();

    return <String, dynamic>{
      "securityNumberFilter": vm.securityNumberFilter,
      "securityTypeFilter": vm.securityTypeFilter,
    };
  }

  /// Restore previously saved filters into the ViewModel.
  ///
  /// This sets the filter fields and emits a state update so bound widgets
  /// can refresh. It also schedules filter application via [onFilter] to keep
  /// `applyDraft` synchronous (avoids `await` here).
  @override
  void applyDraft(
    FacilitySecurityLinkageViewModel vm,
    Map<String, dynamic> data,
  ) {
    final dynamic number = data["securityNumberFilter"];
    final dynamic type = data["securityTypeFilter"];

    if (number != null) {
      vm.securityNumberFilter = number.toString();
    }
    if (type != null) {
      vm.securityTypeFilter = type.toString();
    }

    // Notify UI (no loader change) so widgets can re-render with updated
    // filters.
    vm.emit(vm.state.copyWith());

    // Optionally, re-apply filters against the already-fetched `securities`.
    // We schedule as microtasks to avoid making applyDraft async.
    if ((vm.securityNumberFilter ?? "").trim().isNotEmpty) {
      Future.microtask(
        () => vm.onFilter(
          value: vm.securityNumberFilter!.trim(),
          filterType: FilterType.securityNumber,
          caseInsensitive: true,
          useContains: true,
        ),
      );
    }
    if ((vm.securityTypeFilter ?? "").trim().isNotEmpty) {
      Future.microtask(
        () => vm.onFilter(
          value: vm.securityTypeFilter!.trim(),
          filterType: FilterType.securityType,
          caseInsensitive: true,
          useContains: true,
        ),
      );
    }
  }
}
