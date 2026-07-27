import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for proposed facilities.
/// 
/// Holds information related to the loading status during the
/// proposed facilities processing.
class ProposedFacilitiesState {
  /// Creates an instance of [ProposedFacilitiesState].
  /// 
  /// Requires the current [loaderStatus].
  ProposedFacilitiesState({
    required this.loaderStatus,
  });

  /// Indicates the current loading status of proposed facilities.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Creates a copy of this state with updated values.
  /// 
  /// If [loaderStatus] is provided, it replaces the current value.
  /// Otherwise, the existing value is retained.
  ProposedFacilitiesState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return ProposedFacilitiesState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
