import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for recommending current approval.
/// 
/// Holds information related to the loading status during the
/// recommendation and approval process.
class RecommendCurrentApprovalState {
  /// Creates an instance of [RecommendCurrentApprovalState].
  /// 
  /// Requires the current [loaderStatus].
  RecommendCurrentApprovalState({
    required this.loaderStatus,
  });

  /// Indicates the current loading status of the recommendation and approval process.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Creates a copy of this state with updated values.
  /// 
  /// If [loaderStatus] is provided, it replaces the current value.
  /// Otherwise, the existing value is retained.
  RecommendCurrentApprovalState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return RecommendCurrentApprovalState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
