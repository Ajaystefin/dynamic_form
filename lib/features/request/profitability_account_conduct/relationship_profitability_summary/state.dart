import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Relationship Profitability Summary feature.
///
/// Manages overall loading status and the loading state
/// of the profitability summary table.
class RelationshipProfitabilitySummaryState {
  /// Creates an instance of [RelationshipProfitabilitySummaryState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// and [tableLoaderStatus] represents the loading status of the table data.
  RelationshipProfitabilitySummaryState({
    required this.loaderStatus,
    this.tableLoaderStatus = LoadingStatus.loaded,
  });

  /// Defines the overall loading status of the feature.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status of the profitability table.
  LoadingStatus tableLoaderStatus = LoadingStatus.loaded;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  RelationshipProfitabilitySummaryState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? tableLoaderStatus,
  }) {
    return RelationshipProfitabilitySummaryState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      tableLoaderStatus: tableLoaderStatus ?? this.tableLoaderStatus,
    );
  }
}
