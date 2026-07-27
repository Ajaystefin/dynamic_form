import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Application Borrowers feature.
///
/// Manages the loading status for borrower-related operations.
class ApplicationBorrowersState {
  /// Creates an instance of [ApplicationBorrowersState].
  ///
  /// The [loaderStatus] defines the overall loading state.
  ApplicationBorrowersState({
    required this.loaderStatus,
  });

  /// Defines the overall loading status of the feature.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  ApplicationBorrowersState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return ApplicationBorrowersState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
