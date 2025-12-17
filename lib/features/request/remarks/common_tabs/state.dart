import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';

class CommonTabsState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus? buttonLoaderStatus;
  final RemarksTabs activeTab;
  bool shouldNavigate;

  CommonTabsState(
      {required this.loaderStatus,
      this.buttonLoaderStatus,
      this.shouldNavigate = false,
      this.activeTab = RemarksTabs.requestSummary});

  CommonTabsState copyWith(
      {LoadingStatus? loaderStatus,
      RemarksTabs? activeTab,
      bool? shouldNavigate,
      LoadingStatus? buttonLoaderStatus}) {
    return CommonTabsState(
        loaderStatus: loaderStatus ?? this.loaderStatus,
        buttonLoaderStatus: buttonLoaderStatus ?? this.buttonLoaderStatus,
        shouldNavigate:shouldNavigate?? this.shouldNavigate,
        activeTab: activeTab ?? this.activeTab);
  }
}
