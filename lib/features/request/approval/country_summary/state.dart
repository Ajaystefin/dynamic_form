import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";

class CountrySummaryState {
  const CountrySummaryState({
    this.loaderStatus = LoadingStatus.loading,
    this.activeTab = CountrySummaryTabs.request,
  });
  final LoadingStatus loaderStatus;
  final CountrySummaryTabs activeTab;

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
