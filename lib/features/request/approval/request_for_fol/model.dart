import "dart:async";
import "package:collection/collection.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/screen_access_conditions.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/approval/request_for_fol/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/request_for_fol/state.dart";
import "package:wcas_frontend/features/request/approval/utils/process_comments.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// ViewModel for managing the state and workflow logic of Request for FOL.
class RequestForFolViewModel extends SafeCubit<RequestForFolState>
    with DraftMixin<RequestForFolViewModel> {
  /// Constructor initializes the state with a loading status.
  RequestForFolViewModel()
      : super(RequestForFolState(loaderStatus: LoadingStatus.loading));

  // --- DRAFT IDENTITY ---

  /// Module key used for saving and loading approval draft data.
  @override
  String get draftModuleKey => DraftModuleKeys.approval;

  // Create a unique form key based on the route, customer string identifier,
  // and the active tab's name

  /// Form key used to uniquely identify the request for FOL draft.
  @override
  String get draftFormKey => Routes.requestForFOL;

  /// Draft handler used to build and apply request for FOL draft data.
  @override
  DraftHandler<RequestForFolViewModel> get draftHandler =>
      RequestFOLDraftHandler();

  /// Repository instance for handling request-related operations.
  late ApprovalRepository repository;

  /// Controller for the rich text editor used to enter FOL comments.
  UnifiedEditorController controller = UnifiedEditorController();

  /// Scroll controller used by the request for FOL screen.
  final ScrollController scrollController = ScrollController();

  /// Repository instance for handling admin-related operations.
  late AdminRepository adminRepository;

  /// Repository instance for handling request-related operations.
  late RequestRepository requestRepository;

  /// Repository instance for handling common comment-related operations.
  late CommonRepository commonRepository;

  /// Initial text loaded into the comments editor.
  String initialText = "";

  /// Number of rows to display per page.
  int? rowsPerPage = 5;

  /// Current user role.
  UserRole? userRole = Globals.user?.currentRole!.userRole;

  // Comments

  /// List of FOL comments loaded for the request.
  List<Comment> comments = [];

  /// Current FOL comment.
  Comment? comment;

  /// List of users available for workflow actions.
  List<User> users = [];

  /// Currently selected user for workflow assignment.
  User selectedUser = User();

  /// Selected user id and BPM role value.
  String selectedUserId = "";

  /// List of all reference types.
  List<ReferenceType> allReferences = [];

  /// List of references used by this screen.
  List<Reference> references = [];

  /// Mapping of role codes to BPM role values.
  Map<String, String> roleMap = {};

  /// Selected document stage.
  String selectedStage = "";

  /// Yes or no options used for right-first-time selection.
  final List<String> yesNo = ["Yes", "No"];

  /// Indicates whether submit actions are allowed.
  bool canSubmit = false;

  /// Indicates whether the request for FOL screen is read-only.
  bool isReadOnly = false;

  /// List of users available for return action.
  List<User> returnUserList = <User>[];

  /// Return users grouped by role.
  Map<String, List<User>> returnUserMap = {};

  /// RO/RM users grouped by role.
  Map<String, List<User>> sendRoRmUserMap = {};

  /// Documentation maker users grouped by role.
  Map<String, List<User>> sendDmUserMap = {};

  /// Documentation checker users grouped by role.
  Map<String, List<User>> sendDcUserMap = {};

  /// Documentation users grouped by role.
  Map<String, List<User>> sendDocumentUserMap = {};

  /// Initiated role id for the current workflow.
  int initRoleId = 0;

  /// Indicates whether comment history should be visible.
  bool isCommentVisible = false;

  /// Review comment identifier used for saving or updating comments.
  String reviewCommentId = "0";

  /// Selected right-first-time option.
  String selectedOpt = "";

  /// Indicates whether a return user has been selected.
  bool isReturnSelected = false;

  /// Indicates whether the additional comment field should be shown.
  bool showAdditionalComment = false;

  /// Prefilled return dropdown option.
  CustomDropdownItem? returnPrefill;

  /// Additional comment entered when right-first-time is no.
  String additionalComment = "";

  /// Current workflow activity name.
  String activityName = "";

  /// Indicates whether right-first-time options are visible.
  bool isOptionsVisible = false;

  /// Indicates whether documentation completed action is visible.
  bool isCompleteVisible = false;

  /// Indicates whether initiate fit-to-lend action is visible.
  bool isInitiateFitVisible = false;

  /// Indicates whether return action is visible.
  bool isReturnVisible = false;

  // bool isCCUVisible = false;

  /// Indicates whether send to documentation checker action is visible.
  bool isSendToDcVisible = false;

  /// Current workflow user action id.
  int userActionId = 0;

  /// List of document stages displayed in the dropdown.
  List<String> stageList = [];

  /// Mapping of document stage ids to names.
  Map<String, String> stagesMap = {};

  /// Request statuses that allow request for FOL workflow actions.
  List<RequestStatus> requestStatus = [
    RequestStatus.pendingFolIssuance,
    RequestStatus.folIssuedPendingSignOff,
    RequestStatus.folSignOffCompletedPendingFitToLend,
  ];

  /// List of all users returned for available FOL workflow roles.
  List<User> allUserList = [];

  /// Define role-based permissions
  final Map<ApprovalFields, bool Function()> buttonVisibilityStatus = {
    ApprovalFields.initiateFinalFOL: () => Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
        ]),
    ApprovalFields.documentationSubmitted: () => Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
        ]),
    ApprovalFields.sendToDocumentation: () => Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
        ]),
    ApprovalFields.returnToDocumentationMaker: () => Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
        ]),
    ApprovalFields.initiateFitToLend: () => Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
        ]),
    ApprovalFields.stage: () => Utils.checkRoles([
          UserRole.documentationChecker,
          UserRole.documentationMaker,
        ]),
    ApprovalFields.returns: () => Utils.checkRoles([
          UserRole.documentationChecker,
          UserRole.documentationMaker,
        ]),
    ApprovalFields.sendToCCU: () => Utils.checkRoles([
          UserRole.documentationChecker,
          UserRole.documentationMaker,
        ]),
    ApprovalFields.sendToDocumentationMaker: () => Utils.checkRoles([
          UserRole.documentationChecker,
        ]),
    ApprovalFields.rightFirstTime: () => Utils.checkRoles([
          UserRole.documentationChecker,
        ]),
    ApprovalFields.sendToRORM: () => Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
    ApprovalFields.draftFolGenerated: () => Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
    ApprovalFields.finalFOLGenerated: () => Utils.checkRoles([
          UserRole.documentationMaker,
          UserRole.documentationChecker,
        ]),
    ApprovalFields.documentationCompleted: () => Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
    ApprovalFields.sendToDocumentationChecker: () => Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
    ApprovalFields.saveAndContinue: () => Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
          UserRole.documentationMaker,
          UserRole.documentationChecker,
        ]),
    ApprovalFields.save: () => Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
          UserRole.documentationMaker,
          UserRole.documentationChecker,
        ]),
    ApprovalFields.previewApplication: () => Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
          UserRole.documentationMaker,
          UserRole.documentationChecker,
        ]),
  };

  /// Initializes repositories, loads application details, users, comments,
  /// references, workflow visibility flags, and draft data.
  Future<void> init(BuildContext context) async {
    logger.i("initialising RequestForFolViewModel");
    repository = ApprovalRepository.instance;
    adminRepository = AdminRepository.instance;
    requestRepository = RequestRepository.instance;
    commonRepository = CommonRepository.instance;
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    try {
      await requestRepository.getApplicationDetails();
      await repository.fetchReference();
      isReadOnly = !ScreenAccessConditions.isAssignedToCurrentUser() ||
          !Globals.checkCurrentStatus(requestStatus);
      final ApplicationLifeCycle? appLifeCycle =
          Globals.applicationDetails?.applicationLifeCycle;
      activityName = appLifeCycle?.activityName ?? "";
      userActionId = appLifeCycle?.userAction ?? 0;
      final int appStatus = Globals.applicationDetails?.status ?? 0;
      isCompleteVisible =
          (userActionId == ServerConstants.sendToDocumentMaker) &&
              checkCurrentStatus([FOLTypeAction.executedDocsUnderReview]);
      isReturnVisible =
          !((userActionId == ServerConstants.sendToDocumentMaker ||
                  userActionId == ServerConstants.sendToDocumentChecker ||
                  userActionId == ServerConstants.finalFOLGenerated) &&
              checkCurrentStatus([
                FOLTypeAction.executedDocsUnderReview,
                FOLTypeAction.draftFolGenerated,
                FOLTypeAction.finalFolGenerated,
              ]));
      // isCCUVisible = (userActionId == ServerConstants.sendToDocumentMaker) &&
      //     checkCurrentStatus([FOLTypeAction.finalFolGenerated]);
      isSendToDcVisible = checkCurrentStatus([
            FOLTypeAction.returnToDM,
          ]) ||
          (checkCurrentStatus([
                FOLTypeAction.executedDocsUnderReview,
              ]) &&
              userActionId != ServerConstants.sendToDocumentMaker);
      isInitiateFitVisible = ((userActionId == ServerConstants.sendToRORM) &&
              checkCurrentStatus([
                FOLTypeAction.documentationSubmitted,
              ])) ||
          checkCurrentStatus([
                FOLTypeAction.returnForAmendmentCMO,
              ]) &&
              (appStatus ==
                  ServerConstants
                      .requestStatusId[RequestStatus.folIssuedPendingSignOff]);
      isOptionsVisible = (userActionId == ServerConstants.finalFOLGenerated) &&
          checkCurrentStatus([
            FOLTypeAction.finalFolGenerated,
          ]);
      logger.i("checkDocumentFlow : $isReadOnly");

      await getComments(
        CommentsType.requestForFOL,
        EntityIdentifier.requestForFOL,
      );

      allUserList = await getAllUserRoleLists();

      final Map<FOLTypeAction, Map<String, List<User>>> allUserMaps =
          await getAllUserLists();

      sendRoRmUserMap = allUserMaps[FOLTypeAction.sendToRoRm] ?? {};
      returnUserMap = allUserMaps[FOLTypeAction.returnFromDocCCU] ?? {};
      sendDmUserMap = allUserMaps[FOLTypeAction.sendToDocumentationMaker] ?? {};
      sendDcUserMap =
          allUserMaps[FOLTypeAction.sendToDocumentationChecker] ?? {};
      sendDocumentUserMap =
          allUserMaps[FOLTypeAction.sendToDocumentation] ?? {};
      stagesMap.addAll({
        for (final ref in Globals.documentStagesReferences)
          ref.id.toString(): ref.name ?? "",
      });
      stageList = stagesMap.values.toList();
      logger.i("getStages : ${stageList.length}");
    } on Object catch (e) {
      logger..i("getStages : $e")
      ..e("Error Fetching : $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
    if (!isReadOnly) {
      registerDraftCallback();
      await loadDraftIfAvailable();
      logger.i("registerDraftCallback FOL");
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the right-first-time option and additional comment visibility.
  void onOptChanged(String value) {
    selectedOpt = value;
    if (selectedOpt == yesNo.first) {
      showAdditionalComment = false;
    } else {
      showAdditionalComment = true;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Checks whether the current FOL activity matches any of the given statuses.
  bool checkCurrentStatus(List<Enum> statusList) {
    bool status = false;
    status = statusList.any((status) {
      final String title = ServerConstants.folTypeActionList[status] ?? "";
      logger.i("FOL title : $title $activityName");
      return (activityName == title);
    });
    logger.i("FOL status : $status");
    return status;
  }

  /// Fetches comments for a given entity and comment type.
  ///
  /// This asynchronous method retrieves comments from the [CommonRepository]
  /// based on the specified [type] and [entityIdentifier]. If the fetch fails,
  /// an error toast is displayed using [AlertManager].
  ///
  /// Parameters:
  /// - [type]: The type of comments to retrieve (e.g., general, feedback).
  /// - [entityIdentifier]: The identifier for the entity associated with the
  /// comments.
  ///
  /// Returns:
  /// - A [Future] that completes when the comments are successfully fetched or
  ///   an error is handled.
  Future<void> getComments(
    CommentsType type,
    EntityIdentifier entityIdentifier,
  ) async {
    try {
      comments = await commonRepository.getComments(type, entityIdentifier);
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

  /// Saves the current FOL comment and optionally continues to the next route.
  Future<void> onSavePress({bool isContinue = false}) async {
    try {
      final rawHtml = await controller.getText();

      if (rawHtml.isEmpty) {
        AlertManager().showFailureToast(
          "approval.requestForLimitRelease.pleaseEnterRemarks".tr(),
        );
        return;
      }
      // emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      comment = Comment.fromInputData(
        type: CommentsType.requestForFOL,
        entityType: EntityIdentifier.requestForFOL,
        categoryId: ServerConstants.commentTypeId[CommentsType.requestForFOL],
        reviewCommentId: reviewCommentId,
        comment: rawHtml,
      );

      reviewCommentId = await repository.saveReviewComments(comment!);
      await getComments(
        CommentsType.requestForFOL,
        EntityIdentifier.requestForFOL,
      );
      AlertManager().showSuccessToast(
        "approval.creditAssessment.savedSuccessfully".tr(),
      );
      unawaited(deleteDraft());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      if (isContinue) {
        LayoutViewModel().goToNextRoute();
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Converts grouped users into dropdown items used by workflow action buttons.
  List<CustomDropdownItem> getUserListDropDownItems(
    Map<String, List<User>> users,
  ) {
    final List<CustomDropdownItem> usersList = [];
    String assignedBy = "";
    int assignedByRole = 0;
    int userAction = 0;
    final ApplicationLifeCycle? appLifeCycle =
        Globals.applicationDetails?.applicationLifeCycle;
    if (appLifeCycle != null) {
      assignedBy = appLifeCycle.assignedBy ?? "";
      assignedByRole = appLifeCycle.assignedByRole ?? 0;
      userAction = appLifeCycle.userAction ?? 0;
    }
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
          if (ServerConstants.sendToDocumentMaker == userAction &&
              assignedBy == user.id &&
              assignedByRole == user.currentRole?.roleId) {
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
    });
    return usersList;
  }

  /// Returns the role reference list required for the given FOL action type.
  List<String> getReferenceList(FOLTypeAction type) {
    List<String> referenceList = [];

    if (type == FOLTypeAction.sendToRoRm ||
        type == FOLTypeAction.returnFromDocCCU) {
      referenceList = [
        ServerConstants.userRoleCode[UserRole.relationshipOfficer] ?? "",
        ServerConstants.userRoleCode[UserRole.relationshipManager] ?? "",
      ];

      if (type == FOLTypeAction.returnFromDocCCU &&
          Utils.checkRole(UserRole.documentationMaker)) {
        referenceList.add(
          ServerConstants.userRoleCode[UserRole.documentationChecker] ?? "",
        );
      }
    } else if (type == FOLTypeAction.sendToDocumentationChecker) {
      referenceList = [
        ServerConstants.userRoleCode[UserRole.documentationChecker] ?? "",
      ];
    } else if (type == FOLTypeAction.sendToDocumentationMaker) {
      referenceList = [
        ServerConstants.userRoleCode[UserRole.documentationMaker] ?? "",
      ];
    } else {
      referenceList = [
        ServerConstants.userRoleCode[UserRole.documentationMaker] ?? "",
        ServerConstants.userRoleCode[UserRole.documentationChecker] ?? "",
      ];
    }

    return referenceList.toSet().toList();
  }

  /// Fetches and groups users required for all FOL workflow action types.
  Future<Map<FOLTypeAction, Map<String, List<User>>>> getAllUserLists() async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    final List<FOLTypeAction> allTypes = [
      FOLTypeAction.sendToRoRm,
      FOLTypeAction.returnFromDocCCU,
      FOLTypeAction.sendToDocumentationMaker,
      FOLTypeAction.sendToDocumentationChecker,
      FOLTypeAction.sendToDocumentation,
    ];

    final Map<FOLTypeAction, List<String>> typeRoleMap = {};

    for (final FOLTypeAction type in allTypes) {
      typeRoleMap[type] = getReferenceList(type);
    }

    final List<String> allRoles =
        typeRoleMap.values.expand((e) => e).toSet().toList();

    roleMap = {
      for (final Map<String, String> role in Globals.superUserRoles) ...role,
    };

    final List<String> bpmRoles = allRoles
        .map((ref) => roleMap[ref])
        .whereType<String>()
        .toSet()
        .toList();

    final String roles = bpmRoles.join(",");

    if (roles.isEmpty) {
      return {};
    }

    final List<User> allUsers =
        await repository.getFilteredUsersByrole([roles]);

    final Map<FOLTypeAction, Map<String, List<User>>> result = {};

    for (final FOLTypeAction type in allTypes) {
      final List<String> typeRoles = typeRoleMap[type]!;

      final List<User> filteredUsers = allUsers.where((user) {
        return typeRoles.contains(user.currentRole?.code); // adjust if needed
      }).toList();

      result[type] = getUsersByRole(filteredUsers);
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

    return result;
  }

  /// Fetches all users for all roles involved in the FOL workflow.
  Future<List<User>> getAllUserRoleLists() async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    final List<FOLTypeAction> allTypes = [
      FOLTypeAction.sendToRoRm,
      FOLTypeAction.returnFromDocCCU,
      FOLTypeAction.sendToDocumentationMaker,
      FOLTypeAction.sendToDocumentationChecker,
      FOLTypeAction.sendToDocumentation,
    ];

    final Map<FOLTypeAction, List<String>> typeRoleMap = {};

    for (final FOLTypeAction type in allTypes) {
      typeRoleMap[type] = getReferenceList(type);
    }

    final List<String> allRoles =
        typeRoleMap.values.expand((e) => e).toSet().toList();

    roleMap = {
      for (final Map<String, String> role in Globals.superUserRoles) ...role,
    };

    final List<String> bpmRoles = allRoles
        .map((ref) => roleMap[ref])
        .whereType<String>()
        .toSet()
        .toList();

    final String roles = bpmRoles.join(",");

    if (roles.isEmpty) {
      return [];
    }

    final List<User> allUsers = await repository.getUsersByRoles([roles]);

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

    return allUsers;
  }

  /// Groups the given users by their current role name.
  Map<String, List<User>> getUsersByRole(List<User> users) {
    final Map<String, List<User>> grouped = {};
    if (users.isEmpty) {
      return grouped;
    }
    for (final user in users) {
      grouped.putIfAbsent(user.currentRole!.name!, () => []);
      grouped[user.currentRole!.name]?.add(user);
    }
    return grouped;
  }

  /// Submits the selected FOL workflow action and returns dialog messages.
  Future<List<String>> submitApplication(
    FOLTypeAction userAction, {
    String bpmRole = "",
  }) async {
    final List<String> description = [];
    final List<FOLTypeAction> actions = [
      // for validation of user selection
      FOLTypeAction.sendToDocumentation,
      FOLTypeAction.sendToDocumentationChecker,
      FOLTypeAction.sendToDocumentationMaker,
      FOLTypeAction.sendToRoRm,
      FOLTypeAction.returnFromDocCCU,
      FOLTypeAction.finalFolGenerated,
      FOLTypeAction.draftFolGenerated,
      FOLTypeAction.documentationSubmitted,
      FOLTypeAction.initiateFitToLend,
    ];
    int commentId = 0;
    final bool isReturn = (userAction == FOLTypeAction.returnFromDocCCU);
    int rightFirstTime = 0;
    String userId = "";
    String role = "";

    // final String rawText = await controller.getText();
    // final String text = rawText
    //     .replaceAll(RegExp("<[^>]*>"), "")
    //     .replaceAll("&nbsp;", " ")
    //     .trim();

    // if (text.isEmpty) {
    //   AlertManager().showFailureToast(
    //     "approval.creditAssessment.pleaseEnterRemarks".tr(),
    //   );
    //   return [];
    // }
    if (initialText.isEmpty) {
      AlertManager().showFailureToast(
        "approval.requestForFOL.pleaseEnterRemarks".tr(),
      );
      return [];
    }
    if (Utils.checkRole(UserRole.documentationChecker) && isOptionsVisible) {
      if (selectedOpt.isEmpty) {
        AlertManager().showFailureToast(
          "approval.requestForFOL.selectOptbeforeSubmit".tr(),
        );
        return [];
      } else if (selectedOpt == yesNo.last && additionalComment.isEmpty) {
        AlertManager().showFailureToast(
          "approval.requestForFOL.pleaseEnterComment".tr(),
        );
        return [];
      } else if (selectedOpt == yesNo.last && additionalComment.isNotEmpty) {
        comment = Comment.fromInputData(
          categoryId:
              ServerConstants.commentTypeId[CommentsType.folAdditionalComment],
          comment: additionalComment,
        );
        await repository.saveReviewComments(comment!);
      }
    }
    logger.i("additionalComment : $additionalComment");
    try {
      if (Globals.request?.applicationSubType != ServerConstants.manualEntry) {
        if (selectedStage.isEmpty &&
            Utils.checkRoles([
              UserRole.documentationChecker,
              UserRole.documentationMaker,
            ])) {
          AlertManager().showFailureToast(
            "approval.requestForFOL.selectStageBeforeSubmit".tr(),
          );
          return [];
        }
      }

      if (selectedUserId.isNotEmpty) {
        final List<String> selectedValue = selectedUserId.split(":");
        userId = selectedValue.first;
        role = selectedValue.last;
        // logger.i("selectedValue : ${selectedValue.toString()}");
      }

      if (userId.isEmpty && actions.contains(userAction)) {
        AlertManager().showFailureToast(
          "approval.requestForFOL.selectUserbeforeSubmit".tr(),
        );
        return [];
      }

      // all user list with all roles
      selectedUser =
          allUserList.firstWhereOrNull((user) => user.id == userId) ?? User();
      selectedUser.currentRole?.bpmRole = role;

      logger.i("selectedUser : ${selectedUser.toJson()}");

      int? actionId = Globals.folTypeAction.firstWhereOrNull(
        (map) => map.containsKey(ServerConstants.folTypeActionList[userAction]),
      )?[ServerConstants.folTypeActionList[userAction]];

      if (userAction == FOLTypeAction.initiateFinalFOL) {
        actionId = ServerConstants.initiateFinalFOL;
      }

      if (userAction == FOLTypeAction.sendToDocumentationMaker &&
          activityName ==
              ServerConstants
                  .folTypeActionList[FOLTypeAction.documentationSubmitted]) {
        actionId = ServerConstants.assignToUser; // need to check
      }

      commentId = int.tryParse(reviewCommentId) ?? 0;
      if (selectedOpt == yesNo.first) {
        rightFirstTime = 1;
      }
      final AppResponse response = await repository.submitApplication(
        selectedUser,
        commentId,
        actionId,
        returnToUser: isReturn,
        mode: 1,
        userAction: userAction,
        stage: selectedStage,
        assignedRole: bpmRole,
        rightFirstTime: rightFirstTime,
      );

      if (response.status == ResponseStatus.success) {
        AlertManager().showSuccessToast(
          "approval.requestForFOL.applicationSuccessfulSubmitted".tr(),
        );
        if ((userAction == FOLTypeAction.sendToCCU) ||
            (userAction == FOLTypeAction.documentationCompleted)) {
          final ccuMessage =
              "Your Application ${Globals.request?.applicationRefNo} "
              "has been moved to CCU successfully";

          description.addAll([
            "layout.topmenu.comfirmation".tr(),
            ccuMessage,
          ]);
        } else if (userAction == FOLTypeAction.initiateFinalFOL) {
          final dcSuccessMessage =
              "Your Application ${Globals.request?.applicationRefNo} "
              "has been moved to DC successfully";

          description.addAll([
            "layout.topmenu.comfirmation".tr(),
            dcSuccessMessage,
          ]);
        } else {
          final successMessage =
              "Your Application ${Globals.request?.applicationRefNo} "
              "has been moved to ${selectedUser.name} successfully";

          description.addAll([
            "layout.topmenu.comfirmation".tr(),
            successMessage,
          ]);
        }
        return description;
      } else {
        AlertManager()
            .showFailureToast("approval.requestForFOL.applicationFailed".tr());
        return description;
      }
    } on Object catch (e) {
      logger.e("Error details: $e");
      AlertManager()
          .showFailureToast("approval.requestForFOL.applicationFailed".tr());
      return description;
    }
  }
}
