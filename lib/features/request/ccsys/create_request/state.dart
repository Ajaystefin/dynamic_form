import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for creating a CCSYS request.
/// 
/// Holds information related to loading status and visibility
/// of the selection dialog during the request creation process.
class CcsysCreateRequestState {
  /// Creates an instance of [CcsysCreateRequestState].
  /// 
  /// Requires the current [loaderStatus] and optionally controls
  /// visibility of the selection dialog.
  CcsysCreateRequestState({
    required this.loaderStatus,
    this.showSelectDialog = false,
  });

  /// Indicates the current loading status of the CCSYS request creation process.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Controls whether the selection dialog should be displayed.
  bool showSelectDialog;

  /// Creates a copy of this state with updated values.
  /// 
  /// If provided, [loaderStatus] and [showSelectDialog] will replace
  /// the current values. Otherwise, existing values are retained.
  CcsysCreateRequestState copyWith({
    LoadingStatus? loaderStatus,
    bool? showSelectDialog,
  }) {
    return CcsysCreateRequestState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      showSelectDialog: showSelectDialog ?? false,
    );
  }
}
