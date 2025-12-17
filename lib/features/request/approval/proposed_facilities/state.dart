import 'package:wcas_frontend/core/utils/utils.dart';

class ProposedFacilitiesState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  ProposedFacilitiesState({
    required this.loaderStatus,
  });

  ProposedFacilitiesState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return ProposedFacilitiesState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
