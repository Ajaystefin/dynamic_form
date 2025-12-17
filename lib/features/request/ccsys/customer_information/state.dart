import 'package:wcas_frontend/core/utils/utils.dart';

class CustomerInformationState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? customerSelectedStatus = LoadingStatus.loaded;
  CustomerInformationState({
    required this.loaderStatus,
    this.customerSelectedStatus,
  });

  CustomerInformationState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? customerSelectedStatus,
  }) {
    return CustomerInformationState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      customerSelectedStatus:
          customerSelectedStatus ?? this.customerSelectedStatus,
    );
  }
}
