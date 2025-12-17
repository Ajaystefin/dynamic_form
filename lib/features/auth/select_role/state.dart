import 'package:wcas_frontend/core/utils/utils.dart';

class SelectRoleState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? selectRoleStatus = LoadingStatus.loaded;
  SelectRoleState({
    required this.loaderStatus,
    this.selectRoleStatus,
  });

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
