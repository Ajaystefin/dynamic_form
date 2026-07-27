import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for group summary.
/// 
/// Holds information related to loading status and the currently
/// active tab in the group summary view.
class GroupSummaryState {
  /// Creates an instance of [GroupSummaryState].
  /// 
  /// Initializes with default [loaderStatus] as loading and
  /// [activeTab] as ownershipCorporateStructure.
  const GroupSummaryState({
    this.loaderStatus = LoadingStatus.loading,
    this.activeTab = GroupSummaryTabs.ownershipCorporateStructure,
  });

  /// Indicates the current loading status of the group summary.
  final LoadingStatus loaderStatus;

  /// Represents the currently active tab in the group summary.
  final GroupSummaryTabs activeTab;

  /// Creates a copy of this state with updated values.
  /// 
  /// If provided, [loaderStatus] and [activeTab] will replace
  /// the current values. Otherwise, existing values are retained.
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
