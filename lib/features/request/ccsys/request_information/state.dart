import "package:wcas_frontend/core/utils/utils.dart";

class RequestInformationState {
  RequestInformationState({
    required this.loaderStatus,
    this.isButtonLoading = false,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  final bool isButtonLoading;

  RequestInformationState copyWith({
    LoadingStatus? loaderStatus,
    bool? isButtonLoading,
  }) {
    return RequestInformationState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      isButtonLoading: isButtonLoading ?? this.isButtonLoading,
    );
  }
}
