import 'package:wcas_frontend/core/utils/utils.dart';

class RelationshipProfitabilityDetailedState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  RelationshipProfitabilityDetailedState({
    required this.loaderStatus,
  });

  RelationshipProfitabilityDetailedState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return RelationshipProfitabilityDetailedState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
