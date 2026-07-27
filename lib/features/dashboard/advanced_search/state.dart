import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Advanced Search screen.
///
/// Holds information about loading status, field loading,
/// table loading, and selected reference index.
class AdvancedSearchState {
  /// Creates an instance of [AdvancedSearchState].
  ///
  /// Requires [loaderStatus] and optionally accepts
  /// field loader, table loader and reference index.
  AdvancedSearchState({
    required this.loaderStatus,
    this.fieldLoader = false,
    this.tableLoader = LoadingStatus.empty,
    this.appRefIndex,
  });

  /// Overall loading status of the screen.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Indicates whether field-level loading is active.
  bool fieldLoader = false;

  /// Loading status of the table data.
  LoadingStatus tableLoader = LoadingStatus.empty;

  /// Selected application reference index.
  int? appRefIndex = -1;

  /// Creates a copy of this state with updated values.
  ///
  /// Only provided values will be replaced,
  /// others will keep existing values.
  AdvancedSearchState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? tableLoader,
    bool? fieldLoader,
    int? appRefIndex,
  }) {
    return AdvancedSearchState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      tableLoader: tableLoader ?? this.tableLoader,
      fieldLoader: fieldLoader ?? this.fieldLoader,
      appRefIndex: appRefIndex ?? this.appRefIndex,
    );
  }
}
