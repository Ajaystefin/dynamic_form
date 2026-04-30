import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";

class GroupSummaryState {
  const GroupSummaryState({
    this.loaderStatus = LoadingStatus.loading,
    this.activeTab = GroupSummaryTabs.ownershipCorporateStructure,
  });
  final LoadingStatus loaderStatus;
  final GroupSummaryTabs activeTab;

  GroupSummaryState copyWith({
    LoadingStatus? loaderStatus,
    GroupSummaryTabs? activeTab,
  }) {
    return GroupSummaryState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}
