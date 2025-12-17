import 'package:wcas_frontend/core/utils/utils.dart';

class AccountConductState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  AccountConductState({
    required this.loaderStatus,
  });

  AccountConductState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return AccountConductState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
