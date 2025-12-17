import 'package:wcas_frontend/core/utils/utils.dart';

class LinkContractState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  final String? tenor;
  LinkContractState({required this.loaderStatus, this.tenor});

  LinkContractState copyWith({LoadingStatus? loaderStatus, String? tenor}) {
    return LinkContractState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      tenor: tenor ?? this.tenor,
    );
  }
}
