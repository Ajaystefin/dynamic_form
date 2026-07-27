import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Home screen.
///
/// Holds information about loading states for different UI sections
/// such as table, graph, refresh, and requests.
class HomeState {
  /// Creates an instance of [HomeState].
  ///
  /// Requires [loaderStatus] and optionally accepts other loaders
  /// and reference index.
  HomeState({
    required this.loaderStatus,
    this.tableLoader,
    this.graphLoader,
    this.refreshLoader,
    this.requestLoader,
    this.appRefIndex,
  });

  /// Overall loading status of the screen.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Loading status of the table section.
  LoadingStatus? tableLoader = LoadingStatus.loaded;

  /// Loading status of the graph section.
  LoadingStatus? graphLoader = LoadingStatus.loaded;

  /// Indicates whether refresh operation is in progress.
  bool? refreshLoader = false;

  /// Loading status of request-related operations.
  LoadingStatus? requestLoader = LoadingStatus.loaded;

  /// Selected application reference index.
  int? appRefIndex = -1;

  /// Creates a copy of this state with updated values.
  ///
  /// Only provided values will be replaced,
  /// others will retain existing values.
  HomeState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? tableLoader,
    LoadingStatus? graphLoader,
    bool? refreshLoader,
    LoadingStatus? requestLoader,
    int? appRefIndex,
  }) {
    return HomeState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      tableLoader: tableLoader ?? this.tableLoader,
      graphLoader: graphLoader ?? this.graphLoader,
      refreshLoader: refreshLoader ?? this.refreshLoader,
      requestLoader: requestLoader ?? this.requestLoader,
      appRefIndex: appRefIndex ?? this.appRefIndex,
    );
  }
}
