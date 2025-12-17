import 'package:wcas_frontend/core/utils/utils.dart';

class IncomeSummaryState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  IncomeSummaryState({
    required this.loaderStatus,
  });

  IncomeSummaryState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return IncomeSummaryState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
