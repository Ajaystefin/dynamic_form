import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/financial_ratio_analysis.dart";

/// Represents the state of the Financial Ratio Analysis feature.
///
/// Manages loading states, guarantor data, active tab selection,
/// and entity-related context for financial ratio analysis.
class FinancialRatioAnalysisState {
  /// Creates an instance of [FinancialRatioAnalysisState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// [guarantors] holds financial ratio data,
  /// [buttonStatus] represents button loading state,
  /// and other parameters manage UI behavior and entity tracking.
  FinancialRatioAnalysisState({
    required this.loaderStatus,
    this.guarantors = const [],
    LoadingStatus? buttonStatus,
    this.currentEntityId,
    this.nextCanDelete = false,
    this.activeTab = RemarksTabs.financialRatiosAndAnalysis,
  }) : buttonStatus = buttonStatus ?? LoadingStatus.loaded;

  /// Defines the overall loading status of the feature.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Holds the list of financial ratio analysis data for guarantors.
  final List<FinancialRatioAnalysis> guarantors;

  /// Represents the currently selected entity identifier.
  final int? currentEntityId;

  /// Indicates whether the next item can be deleted.
  final bool nextCanDelete;

  /// Defines the currently active tab.
  final RemarksTabs activeTab;

  /// Represents the loading status of button-related actions.
  final LoadingStatus buttonStatus;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  FinancialRatioAnalysisState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? buttonStatus,
    List<FinancialRatioAnalysis>? guarantors,
    int? currentEntityId,
    bool? nextCanDelete,
    RemarksTabs? activeTab,
  }) {
    return FinancialRatioAnalysisState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      buttonStatus: buttonStatus ?? this.buttonStatus,
      guarantors: guarantors ?? this.guarantors,
      currentEntityId: currentEntityId ?? this.currentEntityId,
      nextCanDelete: nextCanDelete ?? this.nextCanDelete,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}
