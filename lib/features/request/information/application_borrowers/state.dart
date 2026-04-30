import "package:wcas_frontend/core/utils/utils.dart";

class ApplicationBorrowersState {
  ApplicationBorrowersState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  ApplicationBorrowersState copyWith({
    LoadingStatus? loaderStatus,
    Map<String, bool>? customerRimName,
  }) {
    return ApplicationBorrowersState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
