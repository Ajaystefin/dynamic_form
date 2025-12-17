import 'package:wcas_frontend/core/utils/utils.dart';

class RelationshipProfitabilitySummaryState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  RelationshipProfitabilitySummaryState({
    required this.loaderStatus,
  });

  RelationshipProfitabilitySummaryState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return RelationshipProfitabilitySummaryState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
