import "package:wcas_frontend/core/utils/utils.dart";

class RelationshipUtilizationState {
  RelationshipUtilizationState({
    required this.loaderStatus,
    this.turnOverStatus = LoadingStatus.loaded,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus turnOverStatus = LoadingStatus.loaded;

  RelationshipUtilizationState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? turnOverStatus,
  }) {
    return RelationshipUtilizationState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      turnOverStatus: turnOverStatus ?? this.turnOverStatus,
    );
  }
}
