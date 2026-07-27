import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for credit assessment.
/// 
/// Holds information related to the loading status during the credit assessment process.
class CreditAssessmentState {
  /// Creates an instance of [CreditAssessmentState].
  /// 
  /// Requires the current [loaderStatus].
  const CreditAssessmentState({
    required this.loaderStatus,
  });

  /// Indicates the current loading status of the credit assessment process.
  final LoadingStatus loaderStatus;

  /// Creates a copy of this state with updated values.
  /// 
  /// If [loaderStatus] is provided, it replaces the current value.
  /// Otherwise, the existing value is retained.
  CreditAssessmentState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return CreditAssessmentState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
