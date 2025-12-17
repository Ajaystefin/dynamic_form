import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';

import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

class CommentsViewModel extends Cubit<CommentsState> {
  CommentsViewModel()
      : super(CommentsState(loaderStatus: LoadingStatus.loading, getRole: ''));
  late RequestRepository repository;
  int? rowsPerPage = 5;
  final HtmlEditorController controller = HtmlEditorController();

  List<Comment> comments = [];
  Comment? comment;
  UserRole? userRole = Globals.user?.currentRole!.userRole;
  String? returnOptSelected = '';
// Define role-based permissions
  final Map<ApprovalFields, bool Function()> buttonVisibilityStatus = {
    ApprovalFields.amendRAROC: () => Utils.checkRoles([
          UserRole.admin,
          UserRole.creditAnalyst,
          UserRole.creditCommitteeProxy,
          UserRole.boardDirectorProxy,
        ]),
    ApprovalFields.amendFacilities: () => Utils.checkRoles([
          UserRole.admin,
          UserRole.creditAnalyst,
          UserRole.creditCommitteeProxy,
          UserRole.boardDirectorProxy,
        ]),
    ApprovalFields.amendSecurities: () => Utils.checkRoles([
          UserRole.admin,
          UserRole.creditAnalyst,
          UserRole.creditCommitteeProxy,
          UserRole.boardDirectorProxy,
        ]),
    ApprovalFields.amendConditions: () => Utils.checkRoles([
          UserRole.admin,
          UserRole.creditAnalyst,
          UserRole.creditCommitteeProxy,
          UserRole.boardDirectorProxy,
        ]),
    ApprovalFields.amendRiskRating: () => Utils.checkRoles([
          UserRole.admin,
          UserRole.creditAnalyst,
          UserRole.creditCommitteeProxy,
          UserRole.boardDirectorProxy,
        ]),
    ApprovalFields.approve: () => Utils.checkRoles([
          UserRole.admin,
          UserRole.businessUnitHead,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB1,
          UserRole.segmentHeadLevelB,
          UserRole.creditCommitteeProxyApprover,
          UserRole.boardDirectorProxyApproval,
        ]),
    ApprovalFields.approvalDelegation: () => Utils.checkRoles([
          UserRole.admin,
          UserRole.businessUnitHead,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB1,
          UserRole.segmentHeadLevelB,
          UserRole.creditCommitteeProxyApprover,
          UserRole.boardDirectorProxyApproval,
        ]),
    ApprovalFields.decline: () => Utils.checkRoles([
          UserRole.admin,
          UserRole.businessUnitHead,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB1,
          UserRole.segmentHeadLevelB,
          UserRole.creditCommitteeProxyApprover,
          UserRole.boardDirectorProxyApproval,
        ]),
    ApprovalFields.reasonForDecline: () => Utils.checkRoles([
          UserRole.admin,
          UserRole.businessUnitHead,
        ]),
    ApprovalFields.generatePack: () => Utils.checkRoles([
          UserRole.admin,
          UserRole.creditCordinator,
          UserRole.creditAnalyst,
          UserRole.creditCommitteeProxy,
          UserRole.boardDirectorProxy,
        ]),
    ApprovalFields.closeApplication: () => Utils.checkRoles([
          UserRole.admin,
          UserRole.creditCordinator,
          UserRole.creditAnalyst,
        ]),
    ApprovalFields.noReturn: () => Utils.checkRoles([
          UserRole.admin,
        ]),
    ApprovalFields.recommend: () => Utils.checkRoles([
          UserRole.admin,
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
          UserRole.businessUnitHead,
          UserRole.creditCordinator,
          UserRole.creditAnalyst,
          UserRole.teamLeaderCreditLevelD1,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB1,
          UserRole.segmentHeadLevelB,
          UserRole.creditCommitteeProxy,
          UserRole.creditCommitteeProxyApprover,
          UserRole.boardDirectorProxy,
        ]),
    ApprovalFields.returns: () => Utils.checkRoles([
          UserRole.admin,
          UserRole.relationshipManagerBussiness,
          UserRole.businessUnitHead,
          UserRole.creditCordinator,
          UserRole.creditAnalyst,
          UserRole.teamLeaderCreditLevelD1,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB1,
          UserRole.segmentHeadLevelB,
          UserRole.creditCommitteeProxy,
          UserRole.creditCommitteeProxyApprover,
          UserRole.boardDirectorProxy,
          UserRole.boardDirectorProxyApproval,
        ]),
    ApprovalFields.previewApplication: () => Utils.checkRoles([
          UserRole.admin,
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
          UserRole.businessUnitHead,
          UserRole.creditCordinator,
          UserRole.creditAnalyst,
          UserRole.teamLeaderCreditLevelD1,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB1,
          UserRole.segmentHeadLevelB,
          UserRole.creditCommitteeProxy,
          UserRole.creditCommitteeProxyApprover,
          UserRole.boardDirectorProxy,
          UserRole.boardDirectorProxyApproval,
        ]),
    ApprovalFields.save: () => Utils.checkRoles([
          UserRole.admin,
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
          UserRole.businessUnitHead,
          UserRole.creditCordinator,
          UserRole.creditAnalyst,
          UserRole.teamLeaderCreditLevelD1,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB1,
          UserRole.segmentHeadLevelB,
          UserRole.creditCommitteeProxy,
          UserRole.creditCommitteeProxyApprover,
          UserRole.boardDirectorProxy,
          UserRole.boardDirectorProxyApproval,
        ]),
    ApprovalFields.saveAndContinue: () => Utils.checkRoles([
          UserRole.admin,
        ]),
    ApprovalFields.amendCovenants: () => Utils.checkRoles([
          UserRole.creditAnalyst,
          UserRole.creditCommitteeProxy,
          UserRole.boardDirectorProxy,
        ]),
    ApprovalFields.amendFacilitySecurityLinkage: () => Utils.checkRoles([
          UserRole.creditAnalyst,
          UserRole.creditCommitteeProxy,
          UserRole.boardDirectorProxy,
        ]),
    ApprovalFields.approveonbehalf: () => Utils.checkRoles([
          UserRole.businessUnitHead,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB1,
          UserRole.segmentHeadLevelB,
        ]),
  };

  final List<String> approvalDelegationList = [
    "Unit Head",
    "Segment Head",
    "GM",
  ];

  final List<String> returnOpts = [
    'Rework for clarification',
    'Rework for Query'
  ];

  final List<String> reasonForDecline = [
    "Pricing / Deal Economics",
    "Credit Concerns on Borrower",
    "Credit Concerns on Structure",
    "Other appetite restrictions ",
    "Policy / RAC Breach"
  ];

  Future<void> init(context) async {
    logger.i('initialising CommentsViewModel');
    repository = RequestRepository.instance;
    await getComments(CommentsType.approval, EntityIdentifier.approval);
    getUserRole(userRole!);
  }

  Future<void> getComments(
      CommentsType type, EntityIdentifier entityIdentifier) async {
    try {
      comments =
          await CommonRepository.instance.getComments(type, entityIdentifier);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Filters description subtypes based on the selected type.
  void onReturnOptChanged(String? value) {
    returnOptSelected = value;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onSavePress({bool isContinue = false}) async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      // String response =
      //     await repository.saveBussinessVoumes(customerWiseBusinessVolume);
      // AlertManager().showSuccessToast(response);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      if (isContinue) {
        LayoutViewModel().goToNextRoute();
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  void getUserRole(UserRole commentUserRole) {
    String roleCode;
    switch (commentUserRole) {
      case UserRole.relationshipOfficer:
        roleCode = ServerConstants.userRoleCode[UserRole.relationshipOfficer]!;

      case UserRole.relationshipManagerBussiness:
        roleCode = ServerConstants
            .userRoleCode[UserRole.relationshipManagerBussiness]!;

      case UserRole.businessUnitHead:
        roleCode = ServerConstants.userRoleCode[UserRole.businessUnitHead]!;
      case UserRole.creditCordinator:
        roleCode = ServerConstants.userRoleCode[UserRole.creditCordinator]!;

      default:
        roleCode = "";
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded, getRole: roleCode));
  }
}
