import 'package:wcas_frontend/core/utils/utils.dart';

class AddOtherBankDialogState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  AddOtherBankDialogState({
    required this.loaderStatus,
  });

  AddOtherBankDialogState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return AddOtherBankDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
