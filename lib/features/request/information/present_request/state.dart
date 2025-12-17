import 'package:wcas_frontend/core/utils/utils.dart';

class PresentRequestState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  final bool isButtonLoading;

  PresentRequestState(
      {required this.loaderStatus, this.isButtonLoading = false});

  PresentRequestState copyWith(
      {LoadingStatus? loaderStatus, bool? isButtonLoading}) {
    return PresentRequestState(
        loaderStatus: loaderStatus ?? this.loaderStatus,
        isButtonLoading: isButtonLoading ?? this.isButtonLoading);
  }
}
