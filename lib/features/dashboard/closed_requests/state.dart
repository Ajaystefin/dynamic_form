import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Closed Requests screen.
///
/// Holds information about overall loading, table loading,
/// and selected application reference index.
class ClosedRequestsState {
  /// Creates an instance of [ClosedRequestsState].
  ///
  /// Requires [loaderStatus] and optionally accepts
  /// table loading status and reference index.
  ClosedRequestsState({
    required this.loaderStatus,
    this.tableLoader = LoadingStatus.empty,
    this.appRefIndex,
  });

  /// Overall loading status of the screen.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Loading status of the table data.
  LoadingStatus tableLoader = LoadingStatus.empty;

  /// Selected application reference index.
  int? appRefIndex = -1;

  /// Creates a copy of this state with updated values.
  ///
  /// Only provided values will be replaced,
  /// others will retain existing values.
  ClosedRequestsState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? tableLoader,
    int? appRefIndex,
  }) {
    return ClosedRequestsState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      tableLoader: tableLoader ?? this.tableLoader,
      appRefIndex: appRefIndex ?? this.appRefIndex,
    );
  }
}
