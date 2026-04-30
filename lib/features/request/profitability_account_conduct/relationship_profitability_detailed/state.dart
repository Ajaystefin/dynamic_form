import "package:wcas_frontend/core/utils/utils.dart";

class RelationshipProfitabilityDetailedState {
  RelationshipProfitabilityDetailedState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  RelationshipProfitabilityDetailedState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return RelationshipProfitabilityDetailedState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
