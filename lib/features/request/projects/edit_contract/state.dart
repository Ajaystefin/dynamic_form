import 'package:wcas_frontend/core/utils/utils.dart';

class EditContractState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus linkCommitmentStatus = LoadingStatus.loaded;
  LoadingStatus ppcStatus = LoadingStatus.loaded;
  
  EditContractState({
    required this.loaderStatus,
    required this.linkCommitmentStatus,
    required this.ppcStatus,
  });

  EditContractState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? linkCommitmentStatus,
    LoadingStatus? ppcStatus,
  }) {
    return EditContractState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      linkCommitmentStatus: linkCommitmentStatus ?? this.linkCommitmentStatus,
      ppcStatus: ppcStatus ?? this.ppcStatus,
    );
  }
}
