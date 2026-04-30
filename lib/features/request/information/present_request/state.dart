import "package:wcas_frontend/core/utils/utils.dart";

class PresentRequestState {
  PresentRequestState({
    required this.loaderStatus,
    this.isButtonLoading = false,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  final bool isButtonLoading;

  PresentRequestState copyWith({
    LoadingStatus? loaderStatus,
    bool? isButtonLoading,
  }) {
    return PresentRequestState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      isButtonLoading: isButtonLoading ?? this.isButtonLoading,
    );
  }
}
