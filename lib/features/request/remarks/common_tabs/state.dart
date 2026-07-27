import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Common Tabs feature.
///
/// Manages loading states, active tab selection,
/// and navigation trigger handling.
class CommonTabsState {
  /// Creates an instance of [CommonTabsState].
  ///
  /// The [loaderStatus] defines the overall loading state,
  /// [buttonLoaderStatus] represents button-level loading,
  /// [activeTab] defines the currently selected tab,
  /// and [shouldNavigate] controls navigation trigger.
  CommonTabsState({
    required this.loaderStatus,
    this.buttonLoaderStatus,
    this.shouldNavigate = false,
    this.activeTab = RemarksTabs.requestSummary,
  });

  /// Defines the overall loading status of the feature.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status of button-related actions.
  LoadingStatus? buttonLoaderStatus;

  /// Defines the currently active tab.
  final RemarksTabs activeTab;

  /// Indicates whether navigation should be triggered.
  bool shouldNavigate;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  CommonTabsState copyWith({
    LoadingStatus? loaderStatus,
    RemarksTabs? activeTab,
    bool? shouldNavigate,
    LoadingStatus? buttonLoaderStatus,
  }) {
    return CommonTabsState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      buttonLoaderStatus: buttonLoaderStatus ?? this.buttonLoaderStatus,
      shouldNavigate: shouldNavigate ?? this.shouldNavigate,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}
