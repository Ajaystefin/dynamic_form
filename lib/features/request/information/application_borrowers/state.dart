import 'package:wcas_frontend/core/utils/utils.dart';

class ApplicationBorrowersState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  ApplicationBorrowersState({
    required this.loaderStatus,
  });

  ApplicationBorrowersState copyWith({
    LoadingStatus? loaderStatus,
    Map<String, bool>? customerRimName,
  }) {
    return ApplicationBorrowersState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
