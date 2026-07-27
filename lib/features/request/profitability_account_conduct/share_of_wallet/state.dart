import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the Share of Wallet feature.
///
/// Manages the loading status during share of wallet operations.
class ShareOfWalletState {
  /// Creates an instance of [ShareOfWalletState].
  ///
  /// The [loaderStatus] defines the current loading state.
  const ShareOfWalletState({
    required this.loaderStatus,
  });

  /// Defines the current loading status of the feature.
  final LoadingStatus loaderStatus;

  /// Creates a copy of this state with updated values.
  ///
  /// Any parameter that is not provided will retain its existing value.
  ShareOfWalletState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return ShareOfWalletState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
