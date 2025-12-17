import 'package:wcas_frontend/core/utils/utils.dart';

class RoleRightMappingState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus referencesLoaderStatus = LoadingStatus.empty;
  LoadingStatus saveReferenceStatus = LoadingStatus.loaded;

  RoleRightMappingState(
      {required this.loaderStatus,
      this.referencesLoaderStatus = LoadingStatus.empty,
      this.saveReferenceStatus = LoadingStatus.loaded});

  RoleRightMappingState copyWith(
      {LoadingStatus? loaderStatus,
      LoadingStatus? referencesLoaderStatus,
      LoadingStatus? saveReferenceStatus}) {
    return RoleRightMappingState(
        loaderStatus: loaderStatus ?? this.loaderStatus,
        referencesLoaderStatus:
            referencesLoaderStatus ?? this.referencesLoaderStatus,
        saveReferenceStatus: saveReferenceStatus ?? this.saveReferenceStatus);
  }
}
