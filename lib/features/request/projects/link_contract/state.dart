import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state of the link contract process.
///
/// Holds information related to loading status and contract tenor.
class LinkContractState {
  LinkContractState({
    required this.loaderStatus,
    this.tenor,
    this.subContractor = false,
    this.hasRim = false,
  });
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  final String? tenor;
  final bool subContractor;
  final bool hasRim;

  LinkContractState copyWith({
    LoadingStatus? loaderStatus,
    String? tenor,
    bool? subContractor,
    bool? hasRim,
  }) {
    return LinkContractState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      tenor: tenor ?? this.tenor,
      subContractor: subContractor ?? this.subContractor,
      hasRim: hasRim ?? this.hasRim,
    );
  }
}
