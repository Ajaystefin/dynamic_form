import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for file access operations.
/// 
/// Holds information related to overall loading status, file access status,
/// and saving status during file-related processing.
class FileAccessState {
  /// Creates an instance of [FileAccessState].
  /// 
  /// Requires the current [loaderStatus] and optionally accepts
  /// [fileAccessStatus] and [savingStatus].
  FileAccessState({
    required this.loaderStatus,
    this.fileAccessStatus,
    this.savingStatus,
  });

  /// Indicates the overall loading status of file operations.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the status of file access operations.
  LoadingStatus? fileAccessStatus = LoadingStatus.empty;

  /// Represents the status of file saving operations.
  LoadingStatus? savingStatus = LoadingStatus.loaded;

  /// Creates a copy of this state with updated values.
  /// 
  /// If provided, [loaderStatus], [fileAccessStatus], and [savingStatus]
  /// will replace the current values. Otherwise, existing values are retained.
  FileAccessState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? fileAccessStatus,
    LoadingStatus? savingStatus,
  }) {
    return FileAccessState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      fileAccessStatus: fileAccessStatus ?? this.fileAccessStatus,
      savingStatus: savingStatus ?? this.savingStatus,
    );
  }
}
