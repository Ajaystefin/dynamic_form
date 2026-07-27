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
import "package:wcas_frontend/features/request/approval/utils/process_comments.dart";
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

/// View model for approval comments and action handling.
class CommentsViewModel extends SafeCubit<CommentsState>
    with DraftMixin<CommentsViewModel> {
  /// Creates a [CommentsViewModel].
  CommentsViewModel()
      : super(
          CommentsState(
            loaderStatus: LoadingStatus.loading,
            getRole: Globals.user?.currentRole?.code ?? "",
          ),
        );

  /// Repository used for request related API calls.
  late RequestRepository repository;

  /// Repository used for approval related API calls.
  late ApprovalRepository approvalRepository;

  /// Number of rows displayed per page.
  int? rowsPerPage = 5;

  /// Rich text editor controller for comments.
  UnifiedEditorController controller = UnifiedEditorController();

  /// Scroll controller used in the comments screen.
  final ScrollController scrollController = ScrollController();

  /// List of comments loaded for the approval entity.
  List<Comment> comments = [];

  /// Current comment object used for saving.
  Comment? comment;

  /// Recommendation users grouped by role.
  Map<String, List<User>> recommendUserMap = {};

  /// Approval users grouped by role.
  Map<String, List<User>> approveUserMap = {};

  /// Return users grouped by role.
  Map<String, List<User>> returnUserMap = {};

  /// Current logged-in user's role.
  UserRole? userRole = Globals.user?.currentRole?.userRole;

  /// Selected return option.
  String? returnOptSelected = "";

  /// Indicates whether the comments screen is read-only.
  bool isReadOnly = Utils.checkIfAppReadOnly();

  /// Reference data used by the comments screen.
  List<Reference> references = [];

  /// Form key used for comments validation.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Assigned role list.
  List<Role> assigned = [];

  /// Selected user id used for recommendation.
  String selectedUserId = "";

  /// Selected user used for recommendation or return.
  User selectedUser = User();

  /// Initial editor text.
  String initialText = "";

  /// Whether submit action is allowed.
  bool canSubmit = false;

  /// Visibility status of application actions.
  bool visibilityStatus = false;

  /// Review comment id used for update and save.
  String reviewCommentId = "0";

  /// Whether the role is initiator and subtype is risk rating.
  bool isRiskRatingInit = false;

  /// Whether approve button is visible.
  bool isApproveButtonVisible = Globals.user?.approvalAccess ?? false;

  /// Whether approve-on-behalf button is visible.
  bool isApproveOnBehalfButtonVisible =
      Globals.user?.approveOnBehalfOf ?? false;

  /// Whether approval delegation button is visible.
  bool isApproveDelegationButtonVisible = true;

  /// Whether decline button is visible.
  bool isDeclineButtonVisible = true;

  /// Review comment category list.
  List<Map<String, int>> reviewCommentCategory = [
    {"Rework for Clarification": ServerConstants.returnForClarification},
    {"Rework": ServerConstants.returnForQuery},
  ];

  /// Selected option action id.
  int optsActionId = 0;

  /// Whether the application is one-off limit.
  bool isOneOffLimit = false;

  /// Reference data grouped by reference data key.
  Map<String, List<Reference>> referenceData = {};

  /// Segment head role ids.
  List<int?> segmentHeadList = [
    ServerConstants.userRoleId[UserRole.segmentHeadLevelB],
    ServerConstants.userRoleId[UserRole.segmentHeadCreditLevelD],
    ServerConstants.userRoleId[UserRole.segmentHeadLevelC],
    ServerConstants.userRoleId[UserRole.segmentHeadLevelB1],
    ServerConstants.userRoleId[UserRole.teamLeaderCreditLevelD1],
  ];

  /// Proxy role ids.
  List<int?> proxyList = [
    ServerConstants.userRoleId[UserRole.creditCommitteeProxy],
    ServerConstants.userRoleId[UserRole.boardDirectorProxy],
  ];

  /// Proxy approval role ids.
  List<int?> proxyApprovalList = [
    ServerConstants.userRoleId[UserRole.creditCommitteeProxyApprover],
    ServerConstants.userRoleId[UserRole.boardDirectorProxyApproval],
  ];

  /// Business unit head related role ids.
  List<int?> businessUnitHead = [
    ServerConstants.userRoleId[UserRole.businessUnitHead],
    ServerConstants.userRoleId[UserRole.teamLeaderBusiness],
    ServerConstants.userRoleId[UserRole.segmentHeadBusiness],
    ServerConstants.userRoleId[UserRole.commercialAreaManager],
    ServerConstants.userRoleId[UserRole.relationshipManagerBussiness],
  ];

  // raroc amend must not be visible for specific application type

  /// Application types for which RAROC amend is not visible.
  List<String?> rarocAmendAppType = [
    ServerConstants.applicationSubTypeCode[ApplicationType.markForward],
    ServerConstants.applicationSubTypeCode[ApplicationType.cancellation],
    ServerConstants
        .applicationSubTypeCode[ApplicationType.documentationDeferral],
    ServerConstants.applicationSubTypeCode[ApplicationType.oneOffLimit],
    ServerConstants.applicationSubTypeCode[ApplicationType.isolatedExcessType],
  ];

  // risk rating amend must not be visible for specific application type

  /// Application types for which risk rating amend is not visible.
  List<String?> riskRatingAmendAppType = [
    ServerConstants.applicationSubTypeCode[ApplicationType.markForward],
    ServerConstants.applicationSubTypeCode[ApplicationType.cancellation],
    ServerConstants
        .applicationSubTypeCode[ApplicationType.documentationDeferral],
    ServerConstants.applicationSubTypeCode[ApplicationType.oneOffLimit],
    ServerConstants.applicationSubTypeCode[ApplicationType.isolatedExcessType],
    ServerConstants.applicationSubTypeCode[ApplicationType.isolatedOther],
  ];

  /// Selected approval delegation value.
  String selectedDelegation = "";

  /// Whether comments are visible.
  bool isCommentVisible = false;

  /// Whether the application was initiated by CA.
  bool isInitByCA = false;

  /// Whether the application was initiated by CCOOD.
  bool isInitByCCOOD = false;

  /// Selected decline reason.
  String selectedReason = "";

  /// Whether the current user is the initiator.
  bool isInitByUser = false;

  /// Whether RM is selected.
  bool isRMselected = false;

  /// Role mapping from reference role to BPM role.
  Map<String, String> roleMap = {};

  /// Initiated role id.
  int initRoleId = 0;

  /// RSA token digit value.
  String rsaDigit = "";

  /// Prefilled return dropdown item.
  CustomDropdownItem? returnPrefill;

  /// Prefilled recommend dropdown item.
  CustomDropdownItem? recommendPrefill;

  /// Whether return option is selected.
  bool isReturnSelected = false;

  /// Whether recommend option is selected.
  bool isRecommendSelected = false;

  /// User id who assigned the application.
  String assignedBy = "";

  /// Role id of assigning user.
  int assignedByRole = 0;

  /// Current user action id.
  int userAction = 0;

  /// Whether the current role has edit access.
  bool isEdit =
      Globals.user?.currentRole?.rights?[RightConstants.businessVolume] ==
          AccessType.edit;

  /// Whether RSA validation is enabled.
  bool isRSAEnabled = false;

  /// CFO role label.
  final String cfo = "CFO";

  /// Initiated role code.
  String initiatedRole = "";

  /// Cached list of all users used for approval, return, and recommend.
  List<User> allUsers = [];

  /// Role map data grouped by action type.
  Map<String, Set<String>> roleMapData = {};

// Define role-based permissions

  /// Button visibility configuration by approval field.
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

  /// Available approval delegation labels for current user.
  List<String> approvalDelegationList = [];

  /// Return option labels.
  final List<String> returnOpts = [
    "Rework for Clarification",
    "Rework",
  ];

  /// Request statuses that make the comments page read-only.
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
  Future<void> init(BuildContext context) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    logger.i("initialising CommentsViewModel");
    repository = RequestRepository.instance;
    approvalRepository = ApprovalRepository.instance;
    try {
      await repository.getApplicationDetails();
      await approvalRepository.fetchReference();
      final bool status = Globals.checkCurrentStatus(requestStatus);
      isReadOnly = Utils.checkIfAppReadOnly() || status;
      logger.i("isReadOnly : $isReadOnly $status");
      // isReadOnly = false; // for test
      await getComments(CommentsType.approval, EntityIdentifier.approval);
      initiatedRole = await approvalRepository.getInitiatedRole();
      for (final Map<String, int> bpmRoles in Globals.superRolesId) {
        if (bpmRoles.containsKey(initiatedRole)) {
          initRoleId = bpmRoles[initiatedRole] ?? 0;
          break;
        }
      }
      assignValues();
      approvalDelegationList = await getApprovalDelegationList(
        ReferenceDataKeys.approvalDelegationList,
      );
      allUsers = await fetchAllUsersOnce();
      roleMapData = collectAllRoles();
      recommendUserMap =
          await getUserListByGroup(ReferenceDataKeys.recommendationList);
      returnUserMap =
          await getUserListByGroup(ReferenceDataKeys.returnedRolesList);
      if (Globals.checkCurrentStatus([RequestStatus.pendingForApproval]) ||
          isOneOffLimit ||
          segmentHeadList.contains(Globals.user?.currentRole?.roleId)) {
        approveUserMap = await getApprovalUserListByGroup();
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      logger.e("Error Fetching : $e");
      // emit(state.copyWith(loaderStatus: LoadingStatus.error));
      return;
    }
    if (!isReadOnly) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }
    // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Assigns initial lifecycle and visibility values for approval comments.
  void assignValues() {
    final ApplicationLifeCycle? appLifeCycle =
        Globals.applicationDetails?.applicationLifeCycle;
    if (appLifeCycle != null) {
      assignedBy = appLifeCycle.assignedBy ?? "";
      assignedByRole = appLifeCycle.assignedByRole ?? 0;
      userAction = appLifeCycle.userAction ?? 0;
    }
    isInitByUser = (initiatedRole == Globals.user?.currentRole?.code) &&
        Globals.checkIsInitiated();
    isInitByCA =
        (initiatedRole == ServerConstants.userRoleCode[UserRole.creditAnalyst]);
    isInitByCCOOD = (initiatedRole ==
        ServerConstants.userRoleCode[UserRole.creditCordinator]);
    isRiskRatingInit = Globals.checkAppSubStatus(
      ServerConstants.applicationSubType[ApplicationSubType.riskRating] ?? "",
    );
    isOneOffLimit = Globals.checkAppSubStatus(
          ServerConstants.applicationSubType[ApplicationSubType.cashMargin] ??
              "",
        ) &&
        Globals.applicationDetails?.requestType == "MEMO";
    isRSAEnabled =
        (ApprovalUtils.passwordModeReference.firstOrNull?.name == "2");
    isApproveButtonVisible = Globals.user?.approvalAccess ?? false;
    isApproveOnBehalfButtonVisible = Globals.user?.approveOnBehalfOf ?? false;
    isApproveDelegationButtonVisible =
        isApproveButtonVisible || isApproveOnBehalfButtonVisible;
    isDeclineButtonVisible =
        !Utils.checkApplicationType(ApplicationType.cancellation);
    logger.i("isDeclineButtonVisible : $isDeclineButtonVisible");
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Collects approval, return, and recommendation role references.
  Map<String, Set<String>> collectAllRoles() {
    final Set<String> approvalRoles = {};
    final Set<String> returnRoles = {};
    final Set<String> recommendRoles = {};

    // ------------------ APPROVAL ------------------
    final Reference selectedApprovalRef =
        Globals.approvalReferences.firstWhereOrNull(
              (ref) =>
                  ref.name ==
                  ServerConstants
                      .userRoleCode[Globals.user?.currentRole?.userRole],
            ) ??
            Reference();

    if (selectedApprovalRef.reference2?.isNotEmpty ?? false) {
      approvalRoles.addAll(
        selectedApprovalRef.reference2!.split(RegExp(r"\s*,\s*")),
      );
    }

    if (selectedApprovalRef.reference3?.isNotEmpty ?? false) {
      approvalRoles.addAll(
        selectedApprovalRef.reference3!.split(RegExp(r"\s*,\s*")),
      );
    }

    // ------------------ RETURN ------------------
    final Reference selectedReturnRef =
        Globals.returnReferences.firstWhereOrNull(
              (ref) =>
                  ref.name ==
                  ServerConstants
                      .userRoleCode[Globals.user?.currentRole?.userRole],
            ) ??
            Reference();

    if (selectedReturnRef.reference1?.isNotEmpty ?? false) {
      returnRoles.addAll(
        selectedReturnRef.reference1!.split(RegExp(r"\s*,\s*")),
      );
    }

    // ------------------ RECOMMEND ------------------
    final Reference selectedRecommendRef =
        Globals.recommendReferences.firstWhereOrNull(
              (ref) =>
                  ref.name ==
                  ServerConstants
                      .userRoleCode[Globals.user?.currentRole?.userRole],
            ) ??
            Reference();

    if (selectedRecommendRef.reference1?.isNotEmpty ?? false) {
      recommendRoles.addAll(
        selectedRecommendRef.reference1!.split(RegExp(r"\s*,\s*")),
      );
    }

    return {
      "approval": approvalRoles,
      "return": returnRoles,
      "recommend": recommendRoles,
    };
  }

  /// Fetches all users required for approval, return, and recommendation once.
  Future<List<User>> fetchAllUsersOnce() async {
    roleMap = {
      for (final role in Globals.superUserRoles) ...role,
    };

    final Map<String, Set<String>> roleMapData = collectAllRoles();

    final Set<String> allRoles = {
      ...roleMapData["approval"]!,
      ...roleMapData["return"]!,
      ...roleMapData["recommend"]!,
    };

    final Set<String> bpmRoles =
        allRoles.map((ref) => roleMap[ref]).whereType<String>().toSet();

    if (bpmRoles.isEmpty) {
      return [];
    }

    final String roles = bpmRoles.join(",");

    return approvalRepository.getFilteredUsersByrole([roles]);
  }

  /// Returns users grouped by role for recommendation or return actions.
  Future<Map<String, List<User>>> getUserListByGroup(String type) async {
    final bool isReturn = (type == ReferenceDataKeys.returnedRolesList);

    final Set<String> targetRoles =
        isReturn ? roleMapData["return"]! : roleMapData["recommend"]!;

    final Set<String> bpmRoles =
        targetRoles.map((ref) => roleMap[ref]).whereType<String>().toSet();

    List<User> filteredUsers = allUsers.where((user) {
      return bpmRoles.contains(user.currentRole?.bpmRole);
    }).toList();

    if (isReturn && initRoleId != 0) {
      filteredUsers = filteredUsers
          .where((user) => user.currentRole!.roleId! >= initRoleId)
          .toList();
    }

    return getUsersByRole(filteredUsers);
  }

  /// Returns approval users grouped by role.
  Future<Map<String, List<User>>> getApprovalUserListByGroup() async {
    try {
      const String cfoBpm = ServerConstants.cfoBpmRole;

      final Set<String> approvalBpmRoles = roleMapData["approval"]!
          .map((ref) => roleMap[ref])
          .whereType<String>()
          .toSet();

      final List<User> approveUserList = allUsers.where((user) {
        return approvalBpmRoles.contains(user.currentRole?.bpmRole);
      }).toList();

      if (isRiskRatingInit) {
        approveUserList
          ..removeWhere((user) => user.currentRole?.bpmRole == cfoBpm)
          ..add(
            User(
              currentRole: Role(bpmRole: cfoBpm, name: cfo),
            ),
          );
      }

      return getUsersByRole(approveUserList);
    } on Object catch (e) {
      logger.e("Error Fetching : $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }

    return {};
  }

  /// Returns available approval delegation labels.
  Future<List<String>> getApprovalDelegationList(String type) async {
    // emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    final List<String> selectedDelegation = Globals.delegationReferences
        .map((ref) {
          final roles = ref.reference1?.split(RegExp(r"\s*,\s*")) ?? [];
          if (roles.contains(Globals.user?.currentRole?.roleId.toString())) {
            return ref.name;
          }
        })
        .whereType<String>()
        .toList();
    if (selectedDelegation.contains(cfo) && !isRiskRatingInit) {
      selectedDelegation.remove(cfo); // show CFO heading only if app is RR
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    return selectedDelegation;
  }

  /// Fetches comments for the given comment type and entity identifier.
  Future<void> getComments(
    CommentsType type,
    EntityIdentifier entityIdentifier,
  ) async {
    try {
      comments =
          await CommonRepository.instance.getComments(type, entityIdentifier);

      final ProcessCommentResult processComments =
          ProcessComments.process(comments);
      isCommentVisible = processComments.isCommentVisible;
      reviewCommentId = processComments.reviewCommentId;
      initialText = processComments.initialText;
      controller.setText(initialText);
      comments = processComments.comments;

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
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
    logger.i("categoryId : $optsActionId");
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles save button press for approval comments.
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
      if (Globals.request?.applicationSubType != ServerConstants.manualEntry) {
        if (text.isEmpty) {
          AlertManager().showFailureToast(
            "approval.comments.pleaseEnterRemarks".tr(),
          );
          return;
        }
      }
      reviewCommentId = await saveReviewComments();
      unawaited(deleteDraft());
      if (int.tryParse(reviewCommentId) is int) {
        AlertManager().showSuccessToast(
          "approval.comments.savedSuccessfully".tr(),
        );
      }

      if (isContinue) {
        LayoutViewModel().goToNextRoute();
      }

      await getComments(CommentsType.approval, EntityIdentifier.approval);
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Saves approval review comments.
  Future<String> saveReviewComments() async {
    try {
      final String rawHtml = await controller.getText();

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
      logger.i("reviewCommentId : $reviewCommentId");
      return reviewCommentId;
    } on Object catch (e) {
      logger.e("Error Saving : $e");
      AlertManager().showFailureToast(e.toString());
    }
    return reviewCommentId;
  }

  /// Converts grouped users into custom dropdown items.
  List<CustomDropdownItem> getUserListDropDownItems(
    Map<String, List<User>> users,
  ) {
    final List<CustomDropdownItem> usersList = [];
    logger.i("user prefill $assignedBy $assignedByRole $userAction");
    users.forEach((role, users) {
      usersList
          .add(CustomDropdownItem(value: role, label: role, isHeader: true));
      for (final user in users) {
        if (user.name != null || user.id != null) {
          usersList.add(
            CustomDropdownItem(
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
              logger.i(
                "user prefill recommend ${user.toJson()} "
                "${user.id} ${user.currentRole?.roleId} "
                "$assignedByRole "
                "${assignedByRole == user.currentRole?.roleId}",
              );
              recommendPrefill = CustomDropdownItem(
                value: "${user.id}:${user.currentRole?.bpmRole}",
                label: "${user.name} - ${user.id}",
                onPressed: () {
                  selectedUser = user;
                },
              );
            } else if (ServerConstants.userActionRecommend == userAction &&
                returnPrefill == null) {
              logger.i(
                "user prefill return ${user.toJson()} "
                "${user.id} ${user.currentRole?.roleId}",
              );
              returnPrefill = CustomDropdownItem(
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
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    return usersList;
  }

  /// Groups users by their current role name.
  Map<String, List<User>> getUsersByRole(List<User> users) {
    final Map<String, List<User>> grouped = {};
    if (users.isEmpty) {
      return grouped;
    }
    for (final user in users) {
      grouped.putIfAbsent(user.currentRole?.name ?? "", () => []);
      grouped[user.currentRole?.name]?.add(user);
    }
    return grouped;
  }

  /// Sets selected user role state.
  void setSelectedUser(String userRole) {
    isRMselected = (userRole ==
        roleMap[ServerConstants.userRoleCode[UserRole.relationshipManager]]);
    emit(state.copyWith(isRMselected: isRMselected));
  }

  /// Validates the RSA token.
  Future<bool> validateRsaToken() async {
    if (rsaDigit.length == 10) {
      final bool value = await approvalRepository.validateRSAToken(rsaDigit);
      logger.i("value : $value");
      return value;
    }
    return false;
  }

  /// Validates approval action before submission.
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

  /// Submits the application with the selected user action.
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
    if (Globals.request?.applicationSubType != ServerConstants.manualEntry) {
      if (text.isEmpty || initialText.isEmpty) {
        logger.i("isEmpty initialText:$initialText text:$text");
        AlertManager().showFailureToast(
          "approval.comments.pleaseEnterRemarks".tr(),
        );
        return [];
      }
    }
    try {
      final List<String> selectedValue = selectedUserId.split(":");
      final String userId = selectedValue.first;
      final String role = selectedValue.last;
      logger.i("selectedValue : $selectedValue");

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

      // Resolve the selected user from every role group of the action's map.
      final Map<String, List<User>>? userMap = switch (userAction) {
        UserAction.returned => returnUserMap,
        UserAction.approveOnBehalfOf => approveUserMap,
        UserAction.recommended => recommendUserMap,
        _ => null,
      };
      if (userMap != null) {
        final User? matchedUser = userMap.values
            .expand((users) => users)
            .firstWhereOrNull(
              (user) =>
                  (user.id == userId) && (user.currentRole?.bpmRole == role),
            );
        if (matchedUser == null) {
          AlertManager().showFailureToast(
            "approval.comments.selectUserbeforeSubmit".tr(),
          );
          return [];
        }
        selectedUser = matchedUser;
        // selectedUser.currentRole?.bpmRole = role;
      }
      logger.i("selectedUser : ${selectedUser.toJson()}");

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
        if (Globals.request?.applicationSubType !=
            ServerConstants.manualEntry) {
          if (selectedDelegation.isEmpty) {
            AlertManager().showFailureToast(
              "approval.comments.selectDelegationbeforeSubmit".tr(),
            );
            return [];
          }
        }
      }
      if (UserAction.declined == userAction) {
        action = "approval.comments.declined";
        if (Globals.request?.applicationSubType !=
            ServerConstants.manualEntry) {
          if (selectedReason.isEmpty) {
            AlertManager().showFailureToast(
              "approval.comments.selectReasonbeforeSubmit".tr(),
            );
            return [];
          }
        }
      }

      commentId = int.tryParse(reviewCommentId) ?? 0;
      response = await approvalRepository.submitApplication(
        selectedUser,
        commentId,
        actionId,
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
                "id": selectedUser.name ?? "",
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
    } on Object catch (e) {
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
