import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Fee Structure feature.
///
/// Manages overall loading status and the loading state
/// of the fee structure table.
class FeeStructureState {
  /// Creates an instance of [FeeStructureState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// and [tableLoader] represents the loading status of the table data.
  FeeStructureState({
    required this.loaderStatus,
    this.tableLoader = LoadingStatus.loading,
  });

  /// Defines the overall loading status of the feature.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status of the fee structure table.
  LoadingStatus tableLoader = LoadingStatus.loaded;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  FeeStructureState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? tableLoader,
  }) {
    return FeeStructureState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      tableLoader: tableLoader ?? this.tableLoader,
    );
  }
}
