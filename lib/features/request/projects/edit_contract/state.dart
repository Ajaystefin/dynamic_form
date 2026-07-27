import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Edit Contract feature.
///
/// Manages loading states for contract editing, including
/// commitment linking, PPC processing, and UI refresh control.
class EditContractState {
  /// Creates an instance of [EditContractState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// [linkCommitmentStatus] and [ppcStatus] represent
  /// their respective operation states, and [refreshKey]
  /// is used to trigger UI refresh.
  EditContractState({
    required this.loaderStatus,
    required this.linkCommitmentStatus,
    required this.ppcStatus,
    this.refreshKey = 0,
  });

  /// Defines the overall loading status of the feature.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status of link commitment operations.
  LoadingStatus linkCommitmentStatus = LoadingStatus.loaded;

  /// Represents the loading status of PPC operations.
  LoadingStatus ppcStatus = LoadingStatus.loaded;

  /// Used as a key to trigger UI refresh or rebuild.
  final int refreshKey;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  EditContractState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? linkCommitmentStatus,
    LoadingStatus? ppcStatus,
    int? refreshKey,
  }) {
    return EditContractState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      linkCommitmentStatus: linkCommitmentStatus ?? this.linkCommitmentStatus,
      ppcStatus: ppcStatus ?? this.ppcStatus,
      refreshKey: refreshKey ?? this.refreshKey,
    );
  }
}
