import "package:wcas_frontend/core/utils/utils.dart";

class AddOtherBankDialogState {
  AddOtherBankDialogState({
    required this.loaderStatus,
    this.customerName = "",
  });
  LoadingStatus loaderStatus = LoadingStatus.loading;
  String? customerName = "";

  AddOtherBankDialogState copyWith({
    LoadingStatus? loaderStatus,
    String? customerName,
  }) {
    return AddOtherBankDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      customerName: customerName ?? this.customerName,
    );
  }
}
