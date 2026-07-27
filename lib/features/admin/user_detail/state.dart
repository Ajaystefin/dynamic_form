import "package:wcas_frontend/core/utils/utils.dart";

/// Represents the state for user detail management.
/// 
/// Holds information related to loading status, save operation status,
/// and various user access permissions.
class UserDetailState {
  /// Creates an instance of [UserDetailState].
  /// 
  /// Requires [loaderStatus] and [saveUserDetailStatus], and optionally accepts
  /// user permission flags such as approval access and VIP customer access.
  UserDetailState({
    required this.loaderStatus,
    required this.saveUserDetailStatus,
    this.approveOnBehalfOf,
    this.approvalAccess,
    this.tranApprovalAccess,
    this.accessToVipCust,
  });

  /// Indicates the overall loading status of user detail operations.
  LoadingStatus loaderStatus = LoadingStatus.loaded;

  /// Represents the loading status of the save user detail operation.
  LoadingStatus saveUserDetailStatus = LoadingStatus.loaded;

  /// Indicates whether the user can approve on behalf of others.
  bool? approveOnBehalfOf;

  /// Indicates whether the user has approval access.
  bool? approvalAccess;

  /// Indicates whether the user has transaction approval access.
  bool? tranApprovalAccess;

  /// Indicates whether the user has access to VIP customers.
  bool? accessToVipCust;

  /// The fields that are not provided will be copied from this
  /// [UserDetailState].
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
