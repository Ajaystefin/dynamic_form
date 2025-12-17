import 'package:wcas_frontend/core/utils/utils.dart';

class AddCbrbDialogState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  String? customerName = '';

  AddCbrbDialogState({
    required this.loaderStatus,
    this.customerName = '',
  });

  AddCbrbDialogState copyWith({
    LoadingStatus? loaderStatus,
    String? customerName,
  }) {
    return AddCbrbDialogState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      customerName: customerName ?? this.customerName,
    );
  }
}
