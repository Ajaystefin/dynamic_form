import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/request/remarks/financial_ratio_analysis/financial_ratio_analysis.dart';

class FinancialRatioAnalysisState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? buttonStatus = LoadingStatus.loaded;
  final List<FinancialRatioAnalysis> guarantors;
  final int? currentEntityId;
  final bool nextCanDelete;
  final RemarksTabs activeTab;

  FinancialRatioAnalysisState(
      {required this.loaderStatus,
      this.buttonStatus,
      this.guarantors = const [],
      this.currentEntityId,
      this.nextCanDelete = false,
      this.activeTab = RemarksTabs.financialRatiosAndAnalysis});

  FinancialRatioAnalysisState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? buttonStatus,
    List<FinancialRatioAnalysis>? guarantors,
    int? currentEntityId,
    bool? nextCanDelete,
    RemarksTabs? activeTab,
  }) {
    return FinancialRatioAnalysisState(
        loaderStatus: loaderStatus ?? this.loaderStatus,
        buttonStatus: buttonStatus ?? this.buttonStatus,
        guarantors: guarantors ?? this.guarantors,
        currentEntityId: currentEntityId ?? this.currentEntityId,
        nextCanDelete: nextCanDelete ?? this.nextCanDelete,
        activeTab: activeTab ?? this.activeTab);
  }
}
