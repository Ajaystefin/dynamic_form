import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/approval/comments/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/comments/state.dart";
import "package:wcas_frontend/features/request/approval/utils/approval_utils.dart";
import "package:wcas_frontend/features/request/ccsys/approval/model.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class CommentsViewModel extends SafeCubit<CommentsState>
    with DraftMixin<CommentsViewModel> {
  CommentsViewModel()
      : super(
          CommentsState(
            loaderStatus: LoadingStatus.loading,
            getRole: Globals.user?.currentRole?.code ?? "",
          ),
        );
  late RequestRepository repository;
  late ApprovalRepository approvalRepository;
  int? rowsPerPage = 5;
  late UnifiedEditorController controller = UnifiedEditorController();
  final ScrollController scrollController = ScrollController();
  List<Comment> comments = [];
  Comment? comment;
  List<User> users = [];
  List<User> recommendUserList = <User>[];
  List<User> approveUserList = <User>[];
  List<User> returnUserList = <User>[];
  Map<String, List<User>> recommendUserMap = {};
  Map<String, List<User>> approveUserMap = {};
  Map<String, List<User>> returnUserMap = {};
  UserRole? userRole = Globals.user?.currentRole!.userRole;
  String? returnOptSelected = "";
  bool isReadOnly = Utils.checkIfAppReadOnly();
  List<Reference> references = [];
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<Role> assigned = [];
  String selectedUserId = ""; // for recommend
  User selectedUser = User(); // for recommend
  String initialText = ""; // inital value in editor
  bool canSubmit = false; // empty field validation
  bool visibilityStatus = false; // check app status
  String reviewCommentId = "0";
  bool isRiskRatingInit = false; // to check if role is initaitor and subtype RR
  bool isApproveButtonVisible = Globals.user?.approvalAccess ?? false;
  bool isApproveOnBehalfButtonVisible =
      Globals.user?.approveOnBehalfOf ?? false;
  bool isApproveDelegationButtonVisible = true;
  List<Map<String, int>> reviewCommentCategory = [
    {"Rework for Clarification": ServerConstants.returnForClarification},
    {"Rework for Query": ServerConstants.returnForQuery},
  ];
  int optsActionId = 0;
  bool isOneOffLimit = false;
  Map<String, List<Reference>> referenceData = {};
  List<int?> segmentHeadList = [
    ServerConstants.userRoleId[UserRole.segmentHeadLevelB],
    ServerConstants.userRoleId[UserRole.segmentHeadCreditLevelD],
    ServerConstants.userRoleId[UserRole.segmentHeadLevelC],
    ServerConstants.userRoleId[UserRole.segmentHeadLevelB1],
    ServerConstants.userRoleId[UserRole.teamLeaderCreditLevelD1],
  ];
  List<int?> proxyList = [
    ServerConstants.userRoleId[UserRole.creditCommitteeProxy],
    ServerConstants.userRoleId[UserRole.boardDirectorProxy],
  ];
  List<int?> proxyApprovalList = [
    ServerConstants.userRoleId[UserRole.creditCommitteeProxyApprover],
    ServerConstants.userRoleId[UserRole.boardDirectorProxyApproval],
  ];
  List<int?> businessUnitHead = [
    ServerConstants.userRoleId[UserRole.businessUnitHead],
    ServerConstants.userRoleId[UserRole.teamLeaderBusiness],
    ServerConstants.userRoleId[UserRole.segmentHeadBusiness],
    ServerConstants.userRoleId[UserRole.commercialAreaManager],
    ServerConstants.userRoleId[UserRole.relationshipManagerBussiness],
  ];
  // raroc amend must not be visible for specific application type
  List<String?> rarocAmendAppType = [
    ServerConstants.applicationSubTypeCode[ApplicationType.markForward],
    ServerConstants.applicationSubTypeCode[ApplicationType.cancellation],
    ServerConstants
        .applicationSubTypeCode[ApplicationType.documentationDeferral],
    ServerConstants.applicationSubTypeCode[ApplicationType.oneOffLimit],
    ServerConstants.applicationSubTypeCode[ApplicationType.isolatedExcessType],
  ];
  // risk rating amend must not be visible for specific application type
  List<String?> riskRatingAmendAppType = [
    ServerConstants.applicationSubTypeCode[ApplicationType.markForward],
    ServerConstants.applicationSubTypeCode[ApplicationType.cancellation],
    ServerConstants
        .applicationSubTypeCode[ApplicationType.documentationDeferral],
    ServerConstants.applicationSubTypeCode[ApplicationType.oneOffLimit],
    ServerConstants.applicationSubTypeCode[ApplicationType.isolatedExcessType],
    ServerConstants.applicationSubTypeCode[ApplicationType.isolatedOther],
  ];
  String selectedDelegation = "";
  bool isCommentVisible = false;
  bool isInitByCA = false;
  bool isInitByCCOOD = false;
  String selectedReason = "";
  bool isInitByUser = false;
  bool isRMselected = false;
  Map<String, String> roleMap = {};
  int initRoleId = 0;
  String rsaDigit = "";
  CustomDropdownItem? returnPrefill;
  CustomDropdownItem? recommendPrefill;
  bool isReturnSelected = false;
  bool isRecommendSelected = false;
  String assignedBy = "";
  int assignedByRole = 0;
  int userAction = 0;
  bool isEdit =
      Globals.user?.currentRole?.rights?[RightConstants.businessVolume] ==
          AccessType.edit;
  bool isRSAEnabled = false;

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
          UserRole.relationshipManagerBussiness,
          UserRole.commercialAreaManager,
          UserRole.teamLeaderBusiness,
          UserRole.segmentHeadBusiness,
          UserRole.businessUnitHead,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB1,
          UserRole.segmentHeadLevelB,
          UserRole.segmentHeadLevelB,
          UserRole.creditCommitteeProxyApprover,
          UserRole.boardDirectorProxyApproval,
        ]),
    ApprovalFields.approvalDelegation: () => Utils.checkRoles([
          UserRole.admin,
          UserRole.businessUnitHead,
          UserRole.relationshipManagerBussiness,
          UserRole.commercialAreaManager,
          UserRole.teamLeaderBusiness,
          UserRole.segmentHeadBusiness,
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
          UserRole.relationshipManagerBussiness,
          UserRole.commercialAreaManager,
          UserRole.teamLeaderBusiness,
          UserRole.segmentHeadBusiness,
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
          UserRole.relationshipManagerBussiness,
          UserRole.commercialAreaManager,
          UserRole.teamLeaderBusiness,
          UserRole.segmentHeadBusiness,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB1,
          UserRole.segmentHeadLevelB,
          UserRole.creditCommitteeProxyApprover,
          UserRole.boardDirectorProxyApproval,
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
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
        ]),
    ApprovalFields.noReturn: () => Utils.checkRoles([
          UserRole.admin,
        ]),
    ApprovalFields.recommend: () => Utils.checkRoles([
          UserRole.admin,
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
          // UserRole.relationshipManagerBussiness,
          // UserRole.commercialAreaManager,
          // UserRole.teamLeaderBusiness,
          // UserRole.segmentHeadBusiness,
          // UserRole.businessUnitHead,
          // UserRole.creditCordinator,
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
          UserRole.relationshipManager,
          UserRole.businessUnitHead,
          UserRole.relationshipManagerBussiness,
          UserRole.commercialAreaManager,
          UserRole.teamLeaderBusiness,
          UserRole.segmentHeadBusiness,
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
          UserRole.relationshipManager,
          UserRole.relationshipManagerBussiness,
          UserRole.commercialAreaManager,
          UserRole.teamLeaderBusiness,
          UserRole.segmentHeadBusiness,
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
          UserRole.relationshipManager,
          UserRole.relationshipManagerBussiness,
          UserRole.businessUnitHead,
          UserRole.commercialAreaManager,
          UserRole.teamLeaderBusiness,
          UserRole.segmentHeadBusiness,
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
          UserRole.relationshipManagerBussiness,
          UserRole.commercialAreaManager,
          UserRole.teamLeaderBusiness,
          UserRole.segmentHeadBusiness,
          UserRole.businessUnitHead,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelC,
          UserRole.segmentHeadLevelB1,
          UserRole.segmentHeadLevelB,
        ]),
  };

  List<String> approvalDelegationList = [];

  final List<String> returnOpts = [
    "Rework for Clarification",
    "Rework for Query",
  ];

  List<RequestStatus> requestStatus = [
    RequestStatus.declined,
    RequestStatus.approved,
    RequestStatus.pendingFolIssuance,
    RequestStatus.completed,
    RequestStatus.folNotRequired,
    RequestStatus.pendingLimitRelease,
    RequestStatus.folIssuedPendingSignOff,
    RequestStatus.folSignOffCompletedPendingFitToLend,
    RequestStatus.fitToLendCompletedPendingLimitRelease,
  ];

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.approval;

  @override
  String get draftFormKey => Routes.comments;

  @override
  DraftHandler<CommentsViewModel> get draftHandler => CommentsDraftHandler();

  // ---------------------------------------------------------------------------

  /// Initializes the BusinessVolumeViewModel.
  ///
  /// This function sets up the repository, logs the initialization
  /// process, retrieves business volume data, and updates the loader status.
  ///
  /// [context] - The BuildContext, if needed for additional initialization
  /// steps.
  ///

  Future<void> init(context) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    logger.i("initialising CommentsViewModel");
    repository = RequestRepository.instance;
    approvalRepository = ApprovalRepository.instance;
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      await repository.getApplicationDetails();
      await approvalRepository.fetchReference();
      final bool status = Globals.checkCurrentStatus(requestStatus);
      isReadOnly = Utils.checkIfAppReadOnly() || status;
      debugPrint("isReadOnly : $isReadOnly $status");
      // isReadOnly = false; // for test
      await getComments(CommentsType.approval, EntityIdentifier.approval);
      final String role = await approvalRepository.getInitiatedRole();
      initRoleId = 0;
      for (final Map<String, int> bpmRoles in Globals.superRolesId) {
        if (bpmRoles.containsKey(role)) {
          initRoleId = bpmRoles[role] ?? 0;
          break;
        }
      }
      final ApplicationLifeCycle? appLifeCycle =
          Globals.applicationDetails?.applicationLifeCycle;
      if (appLifeCycle != null) {
        assignedBy = appLifeCycle.assignedBy ?? "";
        assignedByRole = appLifeCycle.assignedByRole ?? 0;
        userAction = appLifeCycle.userAction ?? 0;
      }
      debugPrint("initRoleId : $initRoleId");
      isInitByUser = (role == Globals.user?.currentRole?.code) &&
          Globals.checkIsInitiated();
      debugPrint("roleRM : $isInitByUser");
      isInitByCA =
          (role == ServerConstants.userRoleCode[UserRole.creditAnalyst]);
      debugPrint("isInitByCA : $isInitByCA");
      isInitByCCOOD =
          (role == ServerConstants.userRoleCode[UserRole.creditCordinator]);
      debugPrint("isInitByCCOOD : $isInitByCCOOD");
      isRiskRatingInit = Globals.checkAppSubStatus(
        ServerConstants.applicationSubType[ApplicationSubType.riskRating] ?? "",
      );
      // isRiskRatingInit = true; // for test
      // Extract for line-length compliance
      final bool notOolBuh = !(isOneOffLimit &&
          businessUnitHead.contains(
            Globals.user?.currentRole?.roleId,
          ));
      debugPrint(
        "isInitByCCOOD "
        "${buttonVisibilityStatus[ApprovalFields.recommend]!.call()} "
        "$notOolBuh "
        "${isRiskRatingInit && isInitByCCOOD}",
      );
      isOneOffLimit = Globals.checkAppSubStatus(
            ServerConstants.applicationSubType[ApplicationSubType.cashMargin] ??
                "",
          ) &&
          Globals.applicationDetails?.requestType == "MEMO";
      // isOneOffLimit = true; // for test
      recommendUserMap =
          await getUserListByGroup(ReferenceDataKeys.recommendationList);
      returnUserMap =
          await getUserListByGroup(ReferenceDataKeys.returnedRolesList);
      if (Globals.checkCurrentStatus([RequestStatus.pendingForApproval]) ||
          isOneOffLimit ||
          segmentHeadList.contains(Globals.user?.currentRole?.roleId)) {
        approveUserMap = await getApprovalUserListByGroup();
      }
      approvalDelegationList = await getApprovalDelegationList(
        ReferenceDataKeys.approvalDelegationList,
      );
      isRSAEnabled =
          (ApprovalUtils.passwordModeReference.firstOrNull?.name == "2");
      isApproveButtonVisible = Globals.user?.approvalAccess ?? false;
      isApproveOnBehalfButtonVisible = Globals.user?.approveOnBehalfOf ?? false;
      isApproveDelegationButtonVisible =
          isApproveButtonVisible || isApproveOnBehalfButtonVisible;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      logger.e("Error Fetching : $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
    if (!isReadOnly) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<Map<String, List<User>>> getUserListByGroup(String type) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    Reference selectedReference = Reference();
    if (type == ReferenceDataKeys.returnedRolesList) {
      selectedReference = Globals.returnReferences.firstWhereOrNull(
            (ref) =>
                ref.name ==
                ServerConstants
                    .userRoleCode[Globals.user?.currentRole?.userRole],
          ) ??
          Reference();
    } else {
      selectedReference = Globals.recommendReferences.firstWhereOrNull(
            (ref) =>
                ref.name ==
                ServerConstants
                    .userRoleCode[Globals.user?.currentRole?.userRole],
          ) ??
          Reference();
    }
    List<String> referenceList = [];
    if (selectedReference.reference1?.isNotEmpty ?? false) {
      referenceList.addAll(
        selectedReference.reference1?.split(RegExp(r"\s*,\s*")) ?? [],
      );
    }
    referenceList = referenceList.toSet().toList();
    roleMap = {
      for (final role in Globals.superUserRoles) ...role,
    };
    final List<String> bpmRoleList =
        referenceList.map((ref) => roleMap[ref]).whereType<String>().toList();
    final String roles = bpmRoleList.join(",");
    if (roles.isNotEmpty) {
      if (type == ReferenceDataKeys.returnedRolesList) {
        returnUserList = await approvalRepository.getUsersByRoles([roles]);
        if (initRoleId != 0) {
          returnUserList = returnUserList
              .where((user) => user.currentRole!.roleId! >= initRoleId)
              .toList();
        }
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return getUsersByRole(returnUserList);
      } else {
        recommendUserList = await approvalRepository.getUsersByRoles([roles]);
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return getUsersByRole(recommendUserList);
      }
    }
    return {};
  }

  Future<Map<String, List<User>>> getApprovalUserListByGroup() async {
    try {
      const String cfo = "CFO";
      const String cfoBpm = "Chief Financial Officer-WCAS";
      references = Globals.approvalReferences;
      final Reference selectedReference = references.firstWhereOrNull(
            (ref) => ref.name ==
                ServerConstants
                    .userRoleCode[Globals.user?.currentRole?.userRole],
          ) ??
          Reference();
      List<String> referenceList = [];
      // if (selectedReference.reference1?.isNotEmpty ?? false) {
      //   referenceList.addAll(
      //       selectedReference.reference1?.split(RegExp(r'\s*,\s*')) ?? []);
      // }
      if (selectedReference.reference2?.isNotEmpty ?? false) {
        referenceList.addAll(
          selectedReference.reference2?.split(RegExp(r"\s*,\s*")) ?? [],
        );
      }
      if (selectedReference.reference3?.isNotEmpty ?? false) {
        referenceList.addAll(
          selectedReference.reference3?.split(RegExp(r"\s*,\s*")) ?? [],
        );
      }
      // debugPrint("referenceList : ${referenceList.length}");
      referenceList = referenceList.toSet().toList();
      if (referenceList.contains(cfo) && !isRiskRatingInit) {
        referenceList.remove(cfo); // show CFO heading only if app is RR
      }
      roleMap = {
        for (final role in Globals.superUserRoles) ...role,
      };
      final List<String> bpmRoleList =
          referenceList.map((ref) => roleMap[ref]).whereType<String>().toList();
      final String roles = bpmRoleList.join(",");
      if (roles.isNotEmpty) {
        approveUserList = await approvalRepository.getUsersByRoles([roles]);
        if (isRiskRatingInit) {
          approveUserList
            ..removeWhere((user) {
              if (user.currentRole != null &&
                  user.currentRole?.bpmRole != null) {
                return user.currentRole?.bpmRole == cfoBpm;
              }
              return false;
            }) // show CFO heading only if app is RR
            ..add(
              User(
                currentRole: Role(bpmRole: cfoBpm, name: cfo),
              ),
            ); // show role only
        }
        return getUsersByRole(approveUserList);
      }
    } catch (e) {
      logger.e("Error Fetching : $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
    return {};
  }

  Future<List<String>> getApprovalDelegationList(String type) async {
    // List<String> delegationList = ["Unit Head", "Segment Head", "GM"];
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    final List<String> selectedDelegation = Globals.delegationReferences
        .map((ref) {
          final roles = ref.reference1?.split(RegExp(r"\s*,\s*")) ?? [];
          if (roles.contains(Globals.user?.currentRole?.roleId.toString())) {
            return ref.name;
          }
        })
        .whereType<String>()
        .toList();
    // if (isOneOffLimit) {
    //   selectedDelegation.addAll(delegationList);
    // }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    return selectedDelegation;
  }

  Future<void> getComments(
    CommentsType type,
    EntityIdentifier entityIdentifier,
  ) async {
    try {
      comments =
          await CommonRepository.instance.getComments(type, entityIdentifier);

      if (comments.isNotEmpty) {
        if (comments.length == 1) {
          isCommentVisible = comments.first.userId != Globals.user?.id ||
              comments.first.userRole != Globals.user?.currentRole?.roleId;
          debugPrint("isCommentVisible : $isCommentVisible");
        } else {
          isCommentVisible = true;
        }

        if (comments.length > 1) {
          comment = comments
              .reduce((a, b) => a.createdDate!.isAfter(b.createdDate!) ? a : b);
        }
        if (comments.length == 1 && comments.firstOrNull != null) {
          comment = comments.first;
        }

        if (comment != null) {
          if (comment?.userId == Globals.user?.id &&
              comment?.userRole == Globals.user?.currentRole?.roleId) {
            reviewCommentId = comment?.reviewCommentId ?? "0";
            initialText = comment?.comment ?? "";
            controller.setText(initialText);
            comments.removeWhere(
              (userComment) =>
                  comment?.reviewCommentId == userComment.reviewCommentId,
            );
          }
        }
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Filters description subtypes based on the selected type.
  void onReturnOptChanged(String? value) {
    returnOptSelected = value;
    optsActionId = reviewCommentCategory.firstWhereOrNull(
          (cat) => cat.containsKey(returnOptSelected),
        )?[returnOptSelected] ??
        0;
    debugPrint("categoryId : $optsActionId");
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> onSavePress({
    required BuildContext context,
    bool isContinue = false,
  }) async {
    try {
      final String rawText = await controller.getText();
      final String text = rawText
          .replaceAll(RegExp("<[^>]*>"), "") // remove HTML tags
          .replaceAll("&nbsp;", " ") // handle non-breaking spaces
          .trim();
      if (text.isEmpty) {
        AlertManager().showFailureToast(
          "approval.creditAssessment.pleaseEnterRemarks".tr(),
        );
        return;
      }
      reviewCommentId = await saveReviewComments();
      unawaited(deleteDraft());
      if (int.tryParse(reviewCommentId) is int) {
        AlertManager().showSuccessToast(
          "approval.creditAssessment.savedSuccessfully".tr(),
        );
      }

      if (isContinue) {
        LayoutViewModel().goToNextRoute();
      }

      await getComments(CommentsType.approval, EntityIdentifier.approval);
      await repository.getApplicationDetails();
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  Future<String> saveReviewComments() async {
    try {
      final String rawHtml = await controller.getText();

      if (rawHtml.isEmpty) {
        AlertManager().showFailureToast(
          "approval.creditAssessment.pleaseEnterRemarks".tr(),
        );
        return "";
      }
      comment = Comment.fromInputData(
        type: CommentsType.approval,
        entityType: EntityIdentifier.approval,
        categoryId:
            ServerConstants.commentCategoryId[CommentsCategory.approval],
        reviewCommentId: reviewCommentId,
        comment: rawHtml,
      );
      if (optsActionId != 0) {
        comment?.reasonList = optsActionId.toString();
      }

      reviewCommentId = await approvalRepository.saveReviewComments(comment!);
      debugPrint("reviewCommentId : $reviewCommentId");
      return reviewCommentId;
    } catch (e) {
      logger.e("Error Saving : $e");
      AlertManager().showFailureToast(e.toString());
    }
    return reviewCommentId;
  }

  List<CustomDropdownItem> getUserListDropDownItems(
    Map<String, List<User>> users,
  ) {
    final List<CustomDropdownItem> usersList = [];
    debugPrint("user prefill $assignedBy $assignedByRole $userAction");
    users.forEach((role, users) {
      usersList
          .add(CustomDropdownItem(value: role, label: role, isHeader: true));
      for (final user in users) {
        if (user.name != null || user.id != null) {
          usersList.add(
            CustomDropdownItem(
              isHeader: false,
              value: "${user.id}:${user.currentRole?.bpmRole}",
              label: "${user.name} - ${user.id}",
              onPressed: () {
                selectedUser = user;
              },
            ),
          );

          if (assignedBy == user.id &&
              assignedByRole == user.currentRole?.roleId) {
            if (ServerConstants.userActionReturn == userAction &&
                recommendPrefill == null) {
              debugPrint(
                "user prefill recommend ${user.toJson()} "
                "${user.id} ${user.currentRole?.roleId} "
                "$assignedByRole "
                "${assignedByRole == user.currentRole?.roleId}",
              );
              recommendPrefill = CustomDropdownItem(
                isHeader: false,
                value: "${user.id}:${user.currentRole?.bpmRole}",
                label: "${user.name} - ${user.id}",
                onPressed: () {
                  selectedUser = user;
                },
              );
            } else if (ServerConstants.userActionRecommend == userAction &&
                returnPrefill == null) {
              debugPrint(
                "user prefill return ${user.toJson()} "
                "${user.id} ${user.currentRole?.roleId}",
              );
              returnPrefill = CustomDropdownItem(
                isHeader: false,
                value: "${user.id}:${user.currentRole?.bpmRole}",
                label: "${user.name} - ${user.id}",
                onPressed: () {
                  selectedUser = user;
                },
              );
            }
          }
        }
      }
    });
    return usersList;
  }

  Map<String, List<User>> getUsersByRole(List<User> users) {
    final Map<String, List<User>> grouped = {};
    if (users.isEmpty) {
      return grouped;
    }
    for (final user in users) {
      // grouped.putIfAbsent(user.currentRole!.bpmRole!, () => []);
      // grouped[user.currentRole!.bpmRole]?.add(user);
      grouped.putIfAbsent(user.currentRole!.name!, () => []);
      grouped[user.currentRole!.name]?.add(user);
    }
    // debugPrint("GROUP user :
    // ${grouped['RO-WCAS']?.first.toJson().toString()}");
    return grouped;
  }

  void setSelectedUser(String userRole) {
    isRMselected = (userRole ==
        roleMap[ServerConstants.userRoleCode[UserRole.relationshipManager]]);
    emit(state.copyWith(isRMselected: isRMselected));
  }

  Future<bool> validateRsaToken() async {
    if (rsaDigit.length == 10) {
      final bool value = await approvalRepository.validateRSAToken(rsaDigit);
      debugPrint("value : $value");
      return value;
    }
    return false;
  }

  Future<String?> validateApproval(UserAction userAction) async {
    String? errorDescription;
    final int? actionId = Globals.userAction.firstWhereOrNull(
      (map) => map.containsKey(ServerConstants.userActionList[userAction]),
    )?[ServerConstants.userActionList[userAction]];
    final AppResponse response =
        await approvalRepository.validateApproval(actionId ?? 0);
    if (response.status == ResponseStatus.success) {
      return errorDescription;
    } else if (response.body["baseResponse"] != null &&
        response.body["baseResponse"]["status"]["errorCode"] == "422") {
      return response.body["baseResponse"]["status"]["errorDescription"];
    }
    return errorDescription;
  }

  Future<List<String>> submitApplication(UserAction userAction) async {
    final List<String> description = [];
    final List<UserAction> actions = [
      // for validation of user selection
      UserAction.recommended,
      UserAction.returned,
      UserAction.approveOnBehalfOf,
    ];
    String action = "";
    int commentId = 0;
    final bool isReturn = (userAction == UserAction.returned);
    final String rawText = await controller.getText();
    final String text = rawText
        .replaceAll(RegExp("<[^>]*>"), "") // remove HTML tags
        .replaceAll("&nbsp;", " ") // handle non-breaking spaces
        .trim();
    if (initialText.isEmpty || text.isEmpty) {
      AlertManager().showFailureToast(
        "approval.creditAssessment.pleaseEnterRemarks".tr(),
      );
      return [];
    }
    try {
      final List<String> selectedValue = selectedUserId.split(":");
      final String userId = selectedValue.first;
      final String role = selectedValue.last;
      debugPrint("selectedValue : ${selectedValue.toString()}");

      if (userId.isEmpty && actions.contains(userAction)) {
        AlertManager().showFailureToast(
          "approval.comments.selectUserbeforeSubmit".tr(),
        );
        return [];
      }

      if (Utils.checkRole(UserRole.creditAnalyst) && isRMselected) {
        if (optsActionId == 0) {
          AlertManager().showFailureToast(
            "approval.comments.selectOptionbeforeSubmit".tr(),
          );
          return [];
        } else {
          await saveReviewComments();
        }
      }

      if (userAction == UserAction.returned) {
        selectedUser = returnUserList.firstWhere((user) => user.id == userId);
        selectedUser.currentRole?.bpmRole = role;
      } else if (userAction == UserAction.approveOnBehalfOf) {
        selectedUser = approveUserList.firstWhere((user) => user.id == userId);
        selectedUser.currentRole?.bpmRole = role;
      } else if (userAction == UserAction.recommended) {
        selectedUser =
            recommendUserList.firstWhere((user) => user.id == userId);
        selectedUser.currentRole?.bpmRole = role;
      }
      // debugPrint("selectedUser : ${selectedUser.toJson()}");

      final int? actionId = Globals.userAction.firstWhereOrNull(
        (map) => map.containsKey(ServerConstants.userActionList[userAction]),
      )?[ServerConstants.userActionList[userAction]];
      AppResponse response;
      if (isRiskRatingInit && userAction == UserAction.acceptCloseApplication) {
        await saveReviewComments();
        if (comment == null) {
          return [];
        }
      }
      if ([UserAction.approved, UserAction.approveOnBehalfOf]
          .contains(userAction)) {
        action = "approval.comments.approved";
        if (selectedDelegation.isEmpty) {
          AlertManager().showFailureToast(
            "approval.comments.selectDelegationbeforeSubmit".tr(),
          );
          return [];
        }
      }
      if (UserAction.declined == userAction) {
        action = "approval.comments.declined";
        if (selectedReason.isEmpty) {
          AlertManager().showFailureToast(
            "approval.comments.selectReasonbeforeSubmit".tr(),
          );
          return [];
        }
      }

      commentId = int.tryParse(reviewCommentId) ?? 0;
      response = await approvalRepository.submitApplication(
        selectedUser, commentId, actionId,
        returnToUser: isReturn,
        avoidWarning:
            false, // for further process made it as true change it to false
        approvalDelegation: (userAction == UserAction.approved ||
                userAction == UserAction.approveOnBehalfOf)
            ? selectedDelegation
            : "",
        reasonForDecline:
            (userAction == UserAction.declined) ? selectedReason : "",
        userAction: userAction,
      );
      if (response.status == ResponseStatus.success) {
        AlertManager().showSuccessToast(
          "approval.comments.applicationSuccessfulSubmitted".tr(),
        );
        if ([
          UserAction.approved,
          UserAction.declined,
          UserAction.approveOnBehalfOf,
        ].contains(userAction)) {
          description.addAll([
            "layout.topmenu.comfirmation".tr(),
            "approval.comments.applicationStatus".tr(
              namedArgs: {
                "refno": Globals.request?.applicationRefNo ?? "",
                "status": action.tr(),
              },
            ),
          ]);
        } else {
          description.addAll([
            "layout.topmenu.comfirmation".tr(),
            "approval.comments.applicationMoved".tr(
              namedArgs: {
                "refno": Globals.request?.applicationRefNo ?? "",
                "id": selectedUser.id ?? "",
              },
            ),
          ]);
        }
        return description;
      } else if (response.body["baseResponse"] != null &&
          response.body["baseResponse"]["status"]["errorCode"] == "422") {
        final String errorDescription =
            response.body["baseResponse"]["status"]["errorDescription"];
        final List<String> description =
            errorDescription.split(RegExp(r"\s*;\s*"));
        return description;
      } else {
        AlertManager()
            .showFailureToast("approval.comments.applicationFailed".tr());
        return description;
      }
    } catch (e) {
      logger.e("Error details: $e");
      AlertManager()
          .showFailureToast("approval.comments.applicationFailed".tr());
      return description;
    }
  }

  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }
}
