import 'package:wcas_frontend/core/utils/utils.dart';

class ManageReferenceState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus referencesLoaderStatus = LoadingStatus.empty;

  ManageReferenceState({
    required this.loaderStatus,
    this.referencesLoaderStatus = LoadingStatus.empty,
  });

  ManageReferenceState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? referencesLoaderStatus,
  }) {
    return ManageReferenceState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      referencesLoaderStatus:
          referencesLoaderStatus ?? this.referencesLoaderStatus,
    );
  }
}
