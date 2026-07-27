import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for SIC code review.
/// 
/// Holds information related to the loading status during SIC code review processing.
class SicCodeReviewState {
  /// Creates an instance of [SicCodeReviewState].
  /// 
  /// Requires the current [loaderStatus].
  const SicCodeReviewState({
    required this.loaderStatus,
  });

  /// Indicates the current loading status of the SIC code review process.
  final LoadingStatus loaderStatus;

  /// Creates a copy of this state with updated values.
  /// 
  /// If [loaderStatus] is provided, it replaces the current value.
  /// Otherwise, the existing value is retained.
  SicCodeReviewState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return SicCodeReviewState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
