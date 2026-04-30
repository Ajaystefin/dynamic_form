import "package:wcas_frontend/core/utils/utils.dart";

class TerminationState {
  TerminationState({required this.loaderStatus, this.isButtonLoading = false});
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  final bool isButtonLoading;

  TerminationState copyWith({
    LoadingStatus? loaderStatus,
    bool? isButtonLoading,
  }) {
    return TerminationState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      isButtonLoading: isButtonLoading ?? this.isButtonLoading,
    );
  }
}
