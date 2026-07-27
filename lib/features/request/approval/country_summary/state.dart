import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for country summary.
/// 
/// Holds information related to loading status and the currently
/// active tab in the country summary view.
class CountrySummaryState {
  /// Creates an instance of [CountrySummaryState].
  /// 
  /// Initializes with default [loaderStatus] as loading and
  /// [activeTab] as request.
  const CountrySummaryState({
    this.loaderStatus = LoadingStatus.loading,
    this.activeTab = CountrySummaryTabs.request,
  });

  /// Indicates the current loading status of the country summary.
  final LoadingStatus loaderStatus;

  /// Represents the currently active tab in the country summary.
  final CountrySummaryTabs activeTab;

  /// Creates a copy of this state with updated values.
  /// 
  /// If provided, [loaderStatus] and [activeTab] will replace
  /// the current values. Otherwise, existing values are retained.
  CountrySummaryState copyWith({
    LoadingStatus? loaderStatus,
    CountrySummaryTabs? activeTab,
  }) {
    return CountrySummaryState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}
