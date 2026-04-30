import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/request/remarks/guarantor_financials/guarantor.dart";

class GuarantorFinancialState {
  GuarantorFinancialState({
    this.loaderStatus = LoadingStatus.loaded,
    this.buttonStatus = LoadingStatus.loaded,
    this.currentEntityId,
    this.nextCanDelete = false,
    this.guarantors = const [],
    this.showExtraTab = false,
    this.canDeleteSection = false,
    this.searchButtonLoading = false,
    this.activeTab = RemarksTabs.guarantorFinancials,
    this.firstSectionTablesVisible = false, // NEW: default hidden
    this.firstSectionLoader = LoadingStatus.loaded, // NEW
  });
  final LoadingStatus loaderStatus;
  LoadingStatus? buttonStatus;
  int? currentEntityId;
  final bool nextCanDelete;
  final List<Guarantor> guarantors;
  final bool showExtraTab;
  final bool canDeleteSection;
  final bool searchButtonLoading;
  final RemarksTabs activeTab;

  final bool firstSectionTablesVisible; // NEW

  final LoadingStatus firstSectionLoader;

  GuarantorFinancialState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? buttonStatus,
    int? currentEntityId,
    bool? nextCanDelete,
    List<Guarantor>? guarantors,
    bool? showExtraTab,
    bool? canDeleteSection,
    bool? searchButtonLoading,
    RemarksTabs? activeTab,
    bool? firstSectionTablesVisible, // NEW

    LoadingStatus? firstSectionLoader, // NEW
  }) {
    return GuarantorFinancialState(
      activeTab: activeTab ?? this.activeTab,
      loaderStatus: loaderStatus ?? this.loaderStatus,
      buttonStatus: buttonStatus ?? this.buttonStatus,
      currentEntityId: currentEntityId ?? this.currentEntityId,
      nextCanDelete: nextCanDelete ?? this.nextCanDelete,
      guarantors: guarantors ?? this.guarantors,
      showExtraTab: showExtraTab ?? this.showExtraTab,
      canDeleteSection: canDeleteSection ?? this.canDeleteSection,
      searchButtonLoading: searchButtonLoading ?? this.searchButtonLoading,

      firstSectionTablesVisible:
          firstSectionTablesVisible ?? this.firstSectionTablesVisible,

      firstSectionLoader: firstSectionLoader ?? this.firstSectionLoader, // NEW
    );
  }
}
