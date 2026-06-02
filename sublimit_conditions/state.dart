import "package:wcas_frontend/core/utils/utils.dart";

class SubLimitConditionsState {
  SubLimitConditionsState({required this.loaderStatus});
  final LoadingStatus loaderStatus;

  SubLimitConditionsState copyWith({LoadingStatus? loaderStatus}) =>
      SubLimitConditionsState(
        loaderStatus: loaderStatus ?? this.loaderStatus,
      );
}
