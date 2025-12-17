import 'package:wcas_frontend/core/utils/utils.dart';

class SecurityPerfectionState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  final bool isButtonLoading;

  SecurityPerfectionState(
      {required this.loaderStatus, this.isButtonLoading = false});

  SecurityPerfectionState copyWith(
      {LoadingStatus? loaderStatus, bool? isButtonLoading}) {
    return SecurityPerfectionState(
        loaderStatus: loaderStatus ?? this.loaderStatus,
        isButtonLoading: isButtonLoading ?? this.isButtonLoading);
  }
}
