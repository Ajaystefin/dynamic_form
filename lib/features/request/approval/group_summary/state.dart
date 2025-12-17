import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';

class GroupSummaryState {
  final LoadingStatus loaderStatus;
  final GroupSummaryTabs activeTab;

  const GroupSummaryState({
    this.loaderStatus = LoadingStatus.loading,
    this.activeTab = GroupSummaryTabs.ownershipCorporateStructure,
  });

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
