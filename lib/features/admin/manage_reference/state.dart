import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for managing reference data.
/// 
/// Holds information related to overall loading status and
/// reference-specific loading status during reference management operations.
class ManageReferenceState {
  /// Creates an instance of [ManageReferenceState].
  /// 
  /// Requires the current [loaderStatus] and optionally accepts
  /// [referencesLoaderStatus].
  ManageReferenceState({
    required this.loaderStatus,
    this.referencesLoaderStatus = LoadingStatus.empty,
  });

  /// Indicates the overall loading status of reference operations.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status specific to reference data handling.
  LoadingStatus referencesLoaderStatus = LoadingStatus.empty;

  /// Creates a copy of this state with updated values.
  /// 
  /// If provided, [loaderStatus] and [referencesLoaderStatus]
  /// will replace the current values. Otherwise, existing values are retained.
  ManageReferenceState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? referencesLoaderStatus,
  }) {
    return ManageReferenceState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      referencesLoaderStatus:
          referencesLoaderStatus ?? this.referencesLoaderStatus,
    );
  }
}
