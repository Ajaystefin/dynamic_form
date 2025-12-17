import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/request/remarks/guarantor_financials/guarantor.dart';

class GuarantorFinancialState {
  final LoadingStatus loaderStatus;
  LoadingStatus? buttonStatus = LoadingStatus.loaded;

  final int? currentEntityId;
  final bool nextCanDelete;
  final List<Guarantor> guarantors;
  final bool showExtraTab;
  final bool canDeleteSection;
  final bool searchButtonLoading;
  final RemarksTabs activeTab;

  GuarantorFinancialState(
      {this.loaderStatus = LoadingStatus.loaded,
      this.buttonStatus,
      this.currentEntityId,
      this.nextCanDelete = false,
      this.guarantors = const [],
      this.showExtraTab = false,
      this.canDeleteSection = false,
      this.searchButtonLoading = false,
      this.activeTab = RemarksTabs.guarantorFinancials});

  GuarantorFinancialState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? buttonStatus,
    int? currentEntityId,
    bool? nextCanDelete,
    List<Guarantor>? guarantors,
    bool? showExtraTab,
    bool? canDeleteSection,
    bool? searchButtonLoading,
    RemarksTabs? activeTab,
  }) {
    return GuarantorFinancialState(
      activeTab: activeTab ?? this.activeTab,
      loaderStatus: loaderStatus ?? this.loaderStatus,
      buttonStatus: buttonStatus ?? this.buttonStatus,
      currentEntityId: currentEntityId ?? this.currentEntityId,
      nextCanDelete: nextCanDelete ?? this.nextCanDelete,
      guarantors: guarantors ?? this.guarantors,
      showExtraTab: showExtraTab ?? this.showExtraTab,
      canDeleteSection: canDeleteSection ?? this.canDeleteSection,
      searchButtonLoading: searchButtonLoading ?? this.searchButtonLoading,
    );
  }
}
