import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Income Summary feature.
///
/// Manages the loading status during income summary operations.
class IncomeSummaryState {
  /// Creates an instance of [IncomeSummaryState].
  ///
  /// The [loaderStatus] defines the current loading state.
  const IncomeSummaryState({
    required this.loaderStatus,
  });

  /// Defines the current loading status of the feature.
  final LoadingStatus loaderStatus;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  IncomeSummaryState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return IncomeSummaryState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
