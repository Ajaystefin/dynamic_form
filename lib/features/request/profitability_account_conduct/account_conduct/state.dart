import "package:wcas_frontend/core/utils/utils.dart";

class AccountConductState {
  AccountConductState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  AccountConductState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return AccountConductState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
