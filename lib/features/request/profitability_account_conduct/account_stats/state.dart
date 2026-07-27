import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Account Stats feature.
///
/// Manages overall loading status and loading states
/// for save and continue button actions.
class AccountStatsState {
  /// Creates an instance of [AccountStatsState].
  ///
  /// The [loaderStatus] defines the overall loading state.
  /// [saveButtonLoading] and [continueButtonLoading] represent
  /// loading states for their respective actions.
  AccountStatsState({
    required this.loaderStatus,
    this.saveButtonLoading,
    this.continueButtonLoading,
  });

  /// Defines the overall loading status of the feature.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status of the save button.
  LoadingStatus? saveButtonLoading = LoadingStatus.loaded;

  /// Represents the loading status of the continue button.
  LoadingStatus? continueButtonLoading = LoadingStatus.loaded;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  AccountStatsState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? saveButtonLoading,
    LoadingStatus? continueButtonLoading,
  }) {
    return AccountStatsState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      saveButtonLoading: saveButtonLoading ?? this.saveButtonLoading,
      continueButtonLoading:
          continueButtonLoading ?? this.continueButtonLoading,
    );
  }
}
