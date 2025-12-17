import 'package:wcas_frontend/core/utils/utils.dart';

class UserDetailState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  LoadingStatus saveUserDetailStatus = LoadingStatus.loaded;

  bool? approveOnBehalfOf;
  bool? approvalAccess;
  bool? tranApprovalAccess;
  bool? accessToVipCust;

  UserDetailState({
    required this.loaderStatus,
    required this.saveUserDetailStatus,
    this.approveOnBehalfOf,
    this.approvalAccess,
    this.tranApprovalAccess,
    this.accessToVipCust,
  });

  /// The fields that are not provided will be copied from this [UserDetailState].
  ///
  /// This is a convenient way to create a new state that is a variation of this
  /// state, without having to manually copy all the fields.
  UserDetailState copyWith({
    LoadingStatus? loaderStatus,
    LoadingStatus? saveUserDetailStatus,
    bool? tranApprovalAccess,
    bool? approveOnBehalfOf,
    bool? approvalAccess,
    bool? accessToVipCust,
  }) {
    return UserDetailState(
      loaderStatus: loaderStatus ?? this.loaderStatus,
      saveUserDetailStatus: saveUserDetailStatus ?? this.saveUserDetailStatus,
      approveOnBehalfOf: approveOnBehalfOf ?? this.approveOnBehalfOf,
      approvalAccess: approvalAccess ?? this.approvalAccess,
      tranApprovalAccess: tranApprovalAccess ?? this.tranApprovalAccess,
      accessToVipCust: accessToVipCust ?? this.accessToVipCust,
    );
  }
}
