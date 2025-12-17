import 'package:wcas_frontend/core/utils/utils.dart';

class GroupBorrowersState {
  final LoadingStatus loaderStatus;
  final bool isSearchingNonBorrowers;

  GroupBorrowersState({
    required this.loaderStatus,
    this.isSearchingNonBorrowers = false,
  });

  GroupBorrowersState copyWith({
    LoadingStatus? loaderStatus,
    bool? isSearchingNonBorrowers,
  }) {
    return GroupBorrowersState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      isSearchingNonBorrowers:
          isSearchingNonBorrowers ?? this.isSearchingNonBorrowers,
    );
  }
}
