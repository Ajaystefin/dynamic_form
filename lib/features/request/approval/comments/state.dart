import 'package:wcas_frontend/core/utils/utils.dart';

class CommentsState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  final String getRole;

  CommentsState({required this.loaderStatus, required this.getRole});

  CommentsState copyWith({LoadingStatus? loaderStatus, String? getRole}) {
    return CommentsState(
        loaderStatus: loaderStatus ?? this.loaderStatus,
        getRole: getRole ?? this.getRole);
  }
}
