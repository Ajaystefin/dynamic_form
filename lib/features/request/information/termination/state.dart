import 'package:wcas_frontend/core/utils/utils.dart';

class TerminationState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  final bool isButtonLoading;

  TerminationState({required this.loaderStatus, this.isButtonLoading = false});

  TerminationState copyWith(
      {LoadingStatus? loaderStatus, bool? isButtonLoading}) {
    return TerminationState(
        loaderStatus: loaderStatus ?? this.loaderStatus,
        isButtonLoading: isButtonLoading ?? this.isButtonLoading);
  }
}
