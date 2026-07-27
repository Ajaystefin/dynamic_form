import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for request for limit release.
/// 
/// Holds information related to the loading status during the
/// limit release request process.
class RequestForLimitReleaseState {
  /// Creates an instance of [RequestForLimitReleaseState].
  /// 
  /// Requires the current [loaderStatus].
  const RequestForLimitReleaseState({
    required this.loaderStatus,
  });

  /// Indicates the current loading status of the limit release request process.
  final LoadingStatus loaderStatus;

  /// Creates a copy of this state with updated values.
  /// 
  /// If [loaderStatus] is provided, it replaces the current value.
  /// Otherwise, the existing value is retained.
  RequestForLimitReleaseState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return RequestForLimitReleaseState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
