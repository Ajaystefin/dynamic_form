import 'package:wcas_frontend/core/utils/utils.dart';

class CreateFacilityState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? navigateToCreateFacility = LoadingStatus.loaded;
  final bool isButtonLoading;
  CreateFacilityState({
    required this.loaderStatus,
    this.navigateToCreateFacility,
    this.isButtonLoading = false,
  });

  CreateFacilityState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? navigateToCreateFacility,
    bool? isButtonLoading,
  }) {
    return CreateFacilityState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      navigateToCreateFacility:
          navigateToCreateFacility ?? this.navigateToCreateFacility,
      isButtonLoading: isButtonLoading ?? this.isButtonLoading,
    );
  }
}
