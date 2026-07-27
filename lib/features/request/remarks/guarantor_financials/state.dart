import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/request/remarks/guarantor_financials/guarantor.dart";

/// Represents the state of the Guarantor Financial feature.
///
/// Manages loading states, guarantor data, tab behavior,
/// and UI visibility controls for financial sections.
class GuarantorFinancialState {
  /// Creates an instance of [GuarantorFinancialState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// [buttonStatus] represents button loading state,
  /// and other parameters manage UI behavior, entity selection,
  /// and section visibility.
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
    this.firstSectionTablesVisible = false,
    this.firstSectionLoader = LoadingStatus.loaded,
  });

  /// Defines the overall loading status of the feature.
  final LoadingStatus loaderStatus;

  /// Represents the loading status of button-related actions.
  LoadingStatus? buttonStatus;

  /// Represents the currently selected entity identifier.
  int? currentEntityId;

  /// Indicates whether the next item can be deleted.
  final bool nextCanDelete;

  /// Holds the list of guarantor financial data.
  final List<Guarantor> guarantors;

  /// Indicates whether an extra tab should be displayed.
  final bool showExtraTab;

  /// Indicates whether the section can be deleted.
  final bool canDeleteSection;

  /// Indicates whether the search button is in loading state.
  final bool searchButtonLoading;

  /// Defines the currently active tab.
  final RemarksTabs activeTab;

  /// Controls visibility of the first section tables.
  final bool firstSectionTablesVisible;

  /// Represents the loading status of the first section.
  final LoadingStatus firstSectionLoader;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  GuarantorFinancialState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? buttonStatus,
    int? currentEntityId,
    bool clearCurrentEntityId = false,
    bool? nextCanDelete,
    List<Guarantor>? guarantors,
    bool? showExtraTab,
    bool? canDeleteSection,
    bool? searchButtonLoading,
    RemarksTabs? activeTab,
    bool? firstSectionTablesVisible,
    LoadingStatus? firstSectionLoader,
  }) {
    return GuarantorFinancialState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      buttonStatus: buttonStatus ?? this.buttonStatus,
      currentEntityId:
          clearCurrentEntityId ? null : currentEntityId ?? this.currentEntityId,
      nextCanDelete: nextCanDelete ?? this.nextCanDelete,
      guarantors: guarantors ?? this.guarantors,
      showExtraTab: showExtraTab ?? this.showExtraTab,
      canDeleteSection: canDeleteSection ?? this.canDeleteSection,
      searchButtonLoading: searchButtonLoading ?? this.searchButtonLoading,
      activeTab: activeTab ?? this.activeTab,
      firstSectionTablesVisible:
          firstSectionTablesVisible ?? this.firstSectionTablesVisible,
      firstSectionLoader: firstSectionLoader ?? this.firstSectionLoader,
    );
  }
}
