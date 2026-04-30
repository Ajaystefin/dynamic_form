import "package:wcas_frontend/core/utils/utils.dart";

class FileAccessState {
  FileAccessState({
    required this.loaderStatus,
    this.fileAccessStatus,
    this.savingStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? fileAccessStatus = LoadingStatus.empty;
  LoadingStatus? savingStatus = LoadingStatus.loaded;

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
