import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Securities Summary screen.
///
/// Manages overall loading status and the loading state
/// of the delete button.
class SecuritiesSummaryState {
  /// Creates an instance of [SecuritiesSummaryState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// and [deleteButtonStatus] represents the loading state
  /// of the delete button action.
  SecuritiesSummaryState({
    required this.loaderStatus,
    this.deleteButtonStatus,
  });

  /// Defines the overall loading status of the screen.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status of the delete button.
  LoadingStatus? deleteButtonStatus = LoadingStatus.loaded;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  SecuritiesSummaryState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? deleteButtonStatus,
  }) {
    return SecuritiesSummaryState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      deleteButtonStatus: deleteButtonStatus ?? this.deleteButtonStatus,
    );
  }
}
