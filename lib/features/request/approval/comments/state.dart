import "package:wcas_frontend/core/utils/utils.dart";

class CommentsState {
  CommentsState({
    required this.loaderStatus,
    required this.getRole,
    this.isRMselected = false,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  final String getRole;
  final bool isRMselected;

  CommentsState copyWith({
    LoadingStatus? loaderStatus,
    String? getRole,
    bool? isRMselected,
  }) {
    return CommentsState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      getRole: getRole ?? this.getRole,
      isRMselected: isRMselected ?? this.isRMselected,
    );
  }
}
