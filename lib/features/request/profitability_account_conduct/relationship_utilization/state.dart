import 'package:wcas_frontend/core/utils/utils.dart';

class RelationshipUtilizationState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  RelationshipUtilizationState({
    required this.loaderStatus,
  });

  RelationshipUtilizationState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return RelationshipUtilizationState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
