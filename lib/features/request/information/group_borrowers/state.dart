import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Group Borrowers feature.
///
/// Manages loading status and tracks whether
/// non-borrower searching is in progress.
class GroupBorrowersState {
  /// Creates an instance of [GroupBorrowersState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// and [isSearchingNonBorrowers] indicates whether
  /// non-borrower search is active.
  const GroupBorrowersState({
    required this.loaderStatus,
    this.isSearchingNonBorrowers = false,
  });

  /// Defines the overall loading status of the feature.
  final LoadingStatus loaderStatus;

  /// Indicates whether non-borrower search is in progress.
  final bool isSearchingNonBorrowers;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  GroupBorrowersState copyWith({
    LoadingStatus? loaderStatus,
    bool? isSearchingNonBorrowers,
  }) {
    return GroupBorrowersState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      isSearchingNonBorrowers:
          isSearchingNonBorrowers ?? this.isSearchingNonBorrowers,
    );
  }
}
