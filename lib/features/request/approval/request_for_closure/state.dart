import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for request for closure.
/// 
/// Holds information related to the loading status during the
/// request for closure process.
class RequestForClosureState {
  /// Creates an instance of [RequestForClosureState].
  /// 
  /// Requires the current [loaderStatus].
  RequestForClosureState({
    required this.loaderStatus,
  });

  /// Indicates the current loading status of the request for closure process.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Creates a copy of this state with updated values.
  /// 
  /// If [loaderStatus] is provided, it replaces the current value.
  /// Otherwise, the existing value is retained.
  RequestForClosureState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return RequestForClosureState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
