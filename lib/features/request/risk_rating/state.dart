import 'package:wcas_frontend/core/utils/utils.dart';

class RiskRatingState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? externalTableStatus = LoadingStatus.loaded;
  LoadingStatus? refreshLoader = LoadingStatus.loaded;

  RiskRatingState({
    required this.loaderStatus,
    this.externalTableStatus,
    this.refreshLoader,
  });

  RiskRatingState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? externalTableStatus,
    LoadingStatus? refreshLoader,
  }) {
    return RiskRatingState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      externalTableStatus: externalTableStatus ?? this.externalTableStatus,
      refreshLoader: refreshLoader ?? this.refreshLoader,
    );
  }
}
