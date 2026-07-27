import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the user list screen.
/// 
/// Holds information about the overall loading status and
/// the table-specific loading state.
class UserListState {
  /// Creates an instance of [UserListState].
  /// 
  /// Requires [loaderStatus] and initializes [tableLoader]
  /// with a default value if not provided.
  const UserListState({
    required this.loaderStatus,
    this.tableLoader = LoadingStatus.empty,
  });

  /// Indicates the overall loading status of the screen.
  final LoadingStatus loaderStatus;

  /// Represents the loading status of the user table.
  final LoadingStatus? tableLoader;

  /// Creates a copy of this state with updated values.
  /// 
  /// If provided, [loaderStatus] and [tableLoader] will replace
  /// the current values. Otherwise, existing values are retained.
  UserListState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? tableLoader,
  }) {
    return UserListState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      tableLoader: tableLoader ?? LoadingStatus.empty,
    );
  }
}
