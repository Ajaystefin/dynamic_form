import 'package:wcas_frontend/core/utils/utils.dart';

class FacilitiesWithCbdState {
  LoadingStatus loaderStatus = LoadingStatus.loading;

  FacilitiesWithCbdState({
    required this.loaderStatus,
  });

  FacilitiesWithCbdState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return FacilitiesWithCbdState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
