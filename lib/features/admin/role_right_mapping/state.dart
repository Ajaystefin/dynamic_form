import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for role and rights mapping.
/// 
/// Holds information related to overall loading status, reference data loading,
/// and saving status during role-right mapping operations.
class RoleRightMappingState {
  /// Creates an instance of [RoleRightMappingState].
  /// 
  /// Requires the current [loaderStatus] and optionally accepts
  /// [referencesLoaderStatus] and [saveReferenceStatus].
  RoleRightMappingState({
    required this.loaderStatus,
    this.referencesLoaderStatus = LoadingStatus.empty,
    this.saveReferenceStatus = LoadingStatus.loaded,
  });

  /// Indicates the overall loading status of role-right mapping operations.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status for reference data associated with roles.
  LoadingStatus referencesLoaderStatus = LoadingStatus.empty;

  /// Represents the status of saving role-right mapping changes.
  LoadingStatus saveReferenceStatus = LoadingStatus.loaded;

  /// Creates a copy of this state with updated values.
  /// 
  /// If provided, [loaderStatus], [referencesLoaderStatus], and
  /// [saveReferenceStatus] will replace the current values.
  /// Otherwise, existing values are retained.
  RoleRightMappingState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? referencesLoaderStatus,
    LoadingStatus? saveReferenceStatus,
  }) {
    return RoleRightMappingState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      referencesLoaderStatus:
          referencesLoaderStatus ?? this.referencesLoaderStatus,
      saveReferenceStatus: saveReferenceStatus ?? this.saveReferenceStatus,
    );
  }
}
