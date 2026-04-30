import "package:wcas_frontend/core/utils/utils.dart";

class SelectRoleState {
  SelectRoleState({
    required this.loaderStatus,
    this.selectRoleStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? selectRoleStatus = LoadingStatus.loaded;

  SelectRoleState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? selectRoleStatus,
  }) {
    return SelectRoleState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      selectRoleStatus: selectRoleStatus ?? this.selectRoleStatus,
    );
  }
}
