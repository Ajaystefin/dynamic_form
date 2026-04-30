import "package:wcas_frontend/core/utils/utils.dart";

class LinkContractState {
  LinkContractState({required this.loaderStatus, this.tenor});
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  final String? tenor;

  LinkContractState copyWith({LoadingStatus? loaderStatus, String? tenor}) {
    return LinkContractState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      tenor: tenor ?? this.tenor,
    );
  }
}
