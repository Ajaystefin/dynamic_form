import 'package:wcas_frontend/core/utils/utils.dart';

class ShareOfWalletState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  ShareOfWalletState({
    required this.loaderStatus,
  });

  ShareOfWalletState copyWith({
    LoadingStatus? loaderStatus,
  }) {
    return ShareOfWalletState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
    );
  }
}
