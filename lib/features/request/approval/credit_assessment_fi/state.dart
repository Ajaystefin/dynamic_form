import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for Credit Assessment (FI).
/// 
/// Holds information related to the loading status during the
/// financial institution credit assessment process.
class CreditAssessmentFIState {
  /// Creates an instance of [CreditAssessmentFIState].
  /// 
  /// Requires the current [loaderStatus].
  const CreditAssessmentFIState({
    required this.loaderStatus,
  });

  /// Indicates the current loading status of the Credit Assessment (FI) process.
  final LoadingStatus loaderStatus;

  /// Creates a copy of this state with updated values.
  /// 
  /// If [loaderStatus] is provided, it replaces the current value.
  /// Otherwise, the existing value is retained.
  CreditAssessmentFIState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return CreditAssessmentFIState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
