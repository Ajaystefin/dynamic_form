import 'package:wcas_frontend/core/utils/utils.dart';

class SecuritiesSummaryState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? deleteButtonStatus = LoadingStatus.loaded;
  SecuritiesSummaryState({
    required this.loaderStatus,
    this.deleteButtonStatus,
  });

  SecuritiesSummaryState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? deleteButtonStatus,
  }) {
    return SecuritiesSummaryState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      deleteButtonStatus: deleteButtonStatus ?? this.deleteButtonStatus,
    );
  }
}
