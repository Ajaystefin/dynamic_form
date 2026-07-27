import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Appendix feature.
///
/// Manages the loading status for appendix-related operations.
class AppendixState {
  /// Creates an instance of [AppendixState].
  ///
  /// The [loaderStatus] defines the current loading state.
  /// Defaults to [LoadingStatus.loaded].
  const AppendixState({
    this.loaderStatus = LoadingStatus.loaded,
  });

  /// Defines the current loading status.
  final LoadingStatus loaderStatus;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  AppendixState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return AppendixState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
