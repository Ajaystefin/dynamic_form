import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for request for FOL (Facility Offer Letter).
/// 
/// Holds information related to the loading status during the
/// request for FOL process.
class RequestForFolState {
  /// Creates an instance of [RequestForFolState].
  /// 
  /// Requires the current [loaderStatus].
  RequestForFolState({
    required this.loaderStatus,
  });

  /// Indicates the current loading status of the request for FOL process.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Creates a copy of this state with updated values.
  /// 
  /// If [loaderStatus] is provided, it replaces the current value.
  /// Otherwise, the existing value is retained.
  RequestForFolState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return RequestForFolState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
