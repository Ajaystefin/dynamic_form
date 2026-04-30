import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class CovenantEditDialogState {
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
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? searchLoaderStatus;
  final bool addLinkFinancialView;
  final bool showAddWidgets;
  final bool addFinancialCovenat;
  final int financialViewCount;
  String? entityName;
  final Reference? selectedBasisOfPreperation;
  final Reference? selectedAuditStatus;

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
