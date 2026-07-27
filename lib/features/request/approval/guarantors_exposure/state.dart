import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for guarantors exposure.
/// 
/// Holds information related to the loading status during the
/// guarantors exposure processing.
class GuarantorsExposureState {
  /// Creates an instance of [GuarantorsExposureState].
  /// 
  /// Requires the current [loaderStatus].
  const GuarantorsExposureState({
    required this.loaderStatus,
  });

  /// Indicates the current loading status of the guarantors exposure process.
  final LoadingStatus loaderStatus;

  /// Creates a copy of this state with updated values.
  /// 
  /// If [loaderStatus] is provided, it replaces the current value.
  /// Otherwise, the existing value is retained.
  GuarantorsExposureState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return GuarantorsExposureState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
