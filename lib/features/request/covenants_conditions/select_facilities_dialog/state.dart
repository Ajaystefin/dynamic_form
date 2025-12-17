import 'package:wcas_frontend/core/utils/utils.dart';

class SelectFacilitiesDialogState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  SelectFacilitiesDialogState({
    required this.loaderStatus,
  });

  SelectFacilitiesDialogState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return SelectFacilitiesDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
