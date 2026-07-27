import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the CCSYS approval process.
///
/// Holds information related to UI state such as loading status.
class CcsysApprovalState {
  /// Creates an instance of [CcsysApprovalState].
  ///
  /// Requires the current [loaderStatus].
  const CcsysApprovalState({
    required this.loaderStatus,
  });

  /// Indicates the current loading status of the approval process.
  final LoadingStatus loaderStatus;

  /// Creates a copy of this state with updated values.
  ///
  /// If [loaderStatus] is provided, it replaces the current value.
  /// Otherwise, the existing value is retained.
  CcsysApprovalState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return CcsysApprovalState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
