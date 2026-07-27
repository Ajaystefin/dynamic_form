import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Represents the state of the Covenant Edit Dialog.
///
/// Manages loading states, UI toggles, financial view handling,
/// and selected reference values within the dialog.
class CovenantEditDialogState {
  /// Creates an instance of [CovenantEditDialogState].
  ///
  /// The [loaderStatus] defines the overall loading state.
  /// Other parameters control UI behavior, loading indicators,
  /// and selected reference values.
  CovenantEditDialogState({
    required this.loaderStatus,
    this.searchLoaderStatus = LoadingStatus.loaded,
    this.addLinkFinancialView = false,
    this.addFinancialCovenat = false,
    this.showAddWidgets = false,
    this.financialViewCount = 0,
    this.entityName = "",
    this.selectedBasisOfPreperation,
    this.selectedAuditStatus,
  });

  /// Defines the overall loading status of the dialog.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Loading status for search operations within the dialog.
  LoadingStatus? searchLoaderStatus;

  /// Indicates whether linking financial view option is enabled.
  final bool addLinkFinancialView;

  /// Indicates whether additional widgets should be shown.
  final bool showAddWidgets;

  /// Indicates whether financial covenant addition is enabled.
  final bool addFinancialCovenat;

  /// Tracks the number of financial views added.
  final int financialViewCount;

  /// Stores the selected entity name.
  String? entityName;

  /// Represents the selected basis of preparation.
  final Reference? selectedBasisOfPreperation;

  /// Represents the selected audit status.
  final Reference? selectedAuditStatus;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  CovenantEditDialogState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? searchLoaderStatus,
    bool? addLinkFinancialView,
    bool? addFinancialCovenat,
    bool? showAddWidgets,
    int? financialViewCount,
    String? entityName,
    Reference? selectedBasisOfPreperation,
    Reference? selectedAuditStatus,
  }) {
    return CovenantEditDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      searchLoaderStatus: searchLoaderStatus ?? this.searchLoaderStatus,
      addLinkFinancialView: addLinkFinancialView ?? this.addLinkFinancialView,
      addFinancialCovenat: addFinancialCovenat ?? this.addFinancialCovenat,
      showAddWidgets: showAddWidgets ?? this.showAddWidgets,
      financialViewCount: financialViewCount ?? this.financialViewCount,
      entityName: entityName ?? this.entityName,
      selectedBasisOfPreperation:
          selectedBasisOfPreperation ?? this.selectedBasisOfPreperation,
      selectedAuditStatus: selectedAuditStatus ?? this.selectedAuditStatus,
    );
  }
}
