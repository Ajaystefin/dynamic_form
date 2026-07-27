import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for limit caps.
/// 
/// Holds information related to the loading status during the
/// limit caps processing.
class LimitCapsState {
  /// Creates an instance of [LimitCapsState].
  /// 
  /// Requires the current [loaderStatus].
  const LimitCapsState({
    required this.loaderStatus,
  });

  /// Indicates the current loading status of limit caps processing.
  final LoadingStatus loaderStatus;

  /// Creates a copy of this state with updated values.
  /// 
  /// If [loaderStatus] is provided, it replaces the current value.
  /// Otherwise, the existing value is retained.
  LimitCapsState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return LimitCapsState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
