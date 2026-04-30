import "package:wcas_frontend/core/utils/utils.dart";

class SecurityPerfectionState {
  SecurityPerfectionState({
    required this.loaderStatus,
    this.isButtonLoading = false,
    this.refreshKey = 0,
  });
  final LoadingStatus loaderStatus;
  final bool isButtonLoading;
  final int refreshKey;

  SecurityPerfectionState copyWith({
    LoadingStatus? loaderStatus,
    bool? isButtonLoading,
    int? refreshKey,
  }) {
    return SecurityPerfectionState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      isButtonLoading: isButtonLoading ?? this.isButtonLoading,
      refreshKey: refreshKey ?? this.refreshKey,
    );
  }
}
