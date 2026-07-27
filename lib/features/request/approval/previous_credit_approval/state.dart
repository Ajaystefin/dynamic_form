import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for previous credit approval.
/// 
/// Holds information related to the loading status during the
/// previous credit approval processing.
class PreviousCreditApprovalState {
  /// Creates an instance of [PreviousCreditApprovalState].
  /// 
  /// Requires the current [loaderStatus].
  PreviousCreditApprovalState({
    required this.loaderStatus,
  });

  /// Indicates the current loading status of previous credit approval.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Creates a copy of this state with updated values.
  /// 
  /// If [loaderStatus] is provided, it replaces the current value.
  /// Otherwise, the existing value is retained.
  PreviousCreditApprovalState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return PreviousCreditApprovalState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
