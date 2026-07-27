import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Facilities Summary screen.
///
/// Manages overall loading status and the loading state
/// of the facilities table data.
class FacilitiesSummaryState {
  /// Creates an instance of [FacilitiesSummaryState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// and [tableLoaderStatus] represents the loading status
  /// for the facilities table.
  FacilitiesSummaryState({
    required this.loaderStatus,
    this.tableLoaderStatus,
  });

  /// Defines the overall loading status of the screen.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status of the facilities table.
  LoadingStatus? tableLoaderStatus = LoadingStatus.loaded;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  FacilitiesSummaryState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? tableLoaderStatus,
  }) {
    return FacilitiesSummaryState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      tableLoaderStatus: tableLoaderStatus ?? this.tableLoaderStatus,
    );
  }
}
