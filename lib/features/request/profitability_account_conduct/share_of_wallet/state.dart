import "package:wcas_frontend/core/utils/utils.dart";

class ShareOfWalletState {
  ShareOfWalletState({
    required this.loaderStatus,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  ShareOfWalletState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return ShareOfWalletState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
