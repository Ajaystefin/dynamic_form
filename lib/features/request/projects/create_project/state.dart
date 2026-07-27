import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Create Project feature.
///
/// Manages overall loading status and contract-related loading state.
class CreateProjectState {
  /// Creates an instance of [CreateProjectState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// and [contractStatus] represents the loading status
  /// for contract-related operations.
  CreateProjectState({
    required this.loaderStatus,
    this.contractStatus,
  });

  /// Defines the overall loading status of the feature.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status of contract-related operations.
  LoadingStatus? contractStatus = LoadingStatus.loaded;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  CreateProjectState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? contractStatus,
  }) {
    return CreateProjectState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      contractStatus: contractStatus ?? this.contractStatus,
    );
  }
}
