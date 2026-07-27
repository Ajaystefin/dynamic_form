import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for comments handling.
/// 
/// Holds information related to loading status, user role, and
/// selection state for relationship manager (RM).
class CommentsState {
  /// Creates an instance of [CommentsState].
  /// 
  /// Requires the current [loaderStatus] and [getRole],
  /// with an optional [isRMselected] flag.
  CommentsState({
    required this.loaderStatus,
    required this.getRole,
    this.isRMselected = false,
  });

  /// Indicates the current loading status of comments processing.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the role associated with the comments.
  final String getRole;

  /// Indicates whether the relationship manager (RM) is selected.
  final bool isRMselected;

  /// Creates a copy of this state with updated values.
  /// 
  /// If provided, [loaderStatus], [getRole], and [isRMselected]
  /// will replace the current values. Otherwise, existing values are retained.
  CommentsState copyWith({
    LoadingStatus? loaderStatus,
    String? getRole,
    bool? isRMselected,
  }) {
    return CommentsState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      getRole: getRole ?? this.getRole,
      isRMselected: isRMselected ?? this.isRMselected,
    );
  }
}
