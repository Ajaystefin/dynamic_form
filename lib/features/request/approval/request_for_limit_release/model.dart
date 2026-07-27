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
import "package:wcas_frontend/features/request/approval/request_for_limit_release/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/request_for_limit_release/state.dart";
import "package:wcas_frontend/features/request/approval/utils/process_comments.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// ViewModel for managing the request for limit release workflow.
class RequestForLimitReleaseViewModel
    extends SafeCubit<RequestForLimitReleaseState>
    with DraftMixin<RequestForLimitReleaseViewModel> {
  /// Constructor initializes the state with a loading status.
  RequestForLimitReleaseViewModel()
      : super(
          const RequestForLimitReleaseState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

  /// Repository instance for handling request-related operations.
  late RequestRepository repository;

  /// Repository instance for handling approval-related operations.
  late ApprovalRepository approvalRepository;

  /// Repository instance for handling admin-related operations.
  late AdminRepository adminRepository;

  /// Controller for the rich text editor used to enter comments.
  late final UnifiedEditorController controller;

  /// Initial text loaded into the editor.
  String initialText = "";

  /// Number of rows to display per page.
  int? rowsPerPage = 5;

  /// Current user role.
  UserRole? userRole = Globals.user?.currentRole!.userRole;

// Comments

  /// List of comments loaded for request for limit release.
  List<Comment> comments = [];

  /// Current request for limit release comment.
  Comment? comment;

  /// List of users available for workflow actions.
  List<User> users = [];

  /// Selected user id and BPM role value.
  String selectedUserId = "";

  /// Currently selected user for workflow assignment.
  User selectedUser = User();

  /// Indicates whether submit actions are allowed.
  bool canSubmit = false;

  /// Indicates whether the screen is read-only.
  bool isReadOnly = false;

  /// List of references used by this screen.
  List<Reference> references = [];

  /// List of limit release stages displayed in the dropdown.
  List<String> stageList = [];

  /// Prefilled return dropdown option.
  CustomDropdownItem? returnPrefill;

  /// Mapping of role codes to BPM role values.
  Map<String, String> roleMap = {};

  /// CCU maker users grouped by role.
  Map<String, List<User>> sendToCcuMakerMap = {};

  /// CCU checker users grouped by role.
  Map<String, List<User>> sendToCcuCheckerMap = {};

  /// Return CCU maker users grouped by role.
  Map<String, List<User>> returnCcuMakerMap = {};

  /// Current workflow activity name.
  String activityName = "";

  /// Review comment identifier used for saving or updating comments.
  String reviewCommentId = "0";

  /// Indicates whether comment history should be visible.
  bool isCommentVisible = false;

  /// Selected limit release stage.
  String selectedStage = "";

  /// Indicates whether a return user has been selected.
  bool isReturnSelected = false;

  /// Indicates whether the accept close application button is visible.
  bool isButtonVisible = false;

  /// Current workflow user action id.
  int userAction = 0;

  /// List of all users returned for available workflow roles.
  List<User> allUserList = [];

  /// Mapping of limit release stage ids to names.
  Map<String, String> stagesMap = {};

  /// Request statuses that allow request for limit release workflow actions.
  List<RequestStatus> requestStatus = [
    RequestStatus.fitToLendCompletedPendingLimitRelease,
    RequestStatus.pendingLimitRelease,
    RequestStatus.folNotRequired,
  ];

  /// Module key used for saving and loading approval draft data.
  @override
  String get draftModuleKey => DraftModuleKeys.approval;

  /// Form key used to uniquely identify the request for limit release draft.
  @override
  String get draftFormKey => Routes.requestForLimitRelease;

  /// Draft handler used to build and apply request for limit release draft data.
  @override
  DraftHandler<RequestForLimitReleaseViewModel> get draftHandler =>
      RequestForLimitReleaseDraftHandler();

  /// Defines role-based visibility conditions for limit release action buttons.
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
          UserRole.relationshipManager,
        ]),
    ApprovalFields.initiateFitToLend: () => Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
        ]),
    ApprovalFields.sendtoCCUMaker: () => Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
          UserRole.documentationChecker,
        ]),
    ApprovalFields.stage: () => Utils.checkRoles([
          UserRole.ccuMaker,
          UserRole.ccuChecker,
        ]),
    ApprovalFields.returns: () => Utils.checkRoles([
          UserRole.ccuMaker,
        ]),
    ApprovalFields.sendToCCU: () => Utils.checkRoles([
          UserRole.documentationChecker,
          UserRole.documentationMaker,
        ]),
    ApprovalFields.sendToDocumentationMaker: () => Utils.checkRoles([
          UserRole.documentationChecker,
        ]),
    ApprovalFields.draftFolGenerated: () => Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
    ApprovalFields.finalFOLGenerated: () => Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
    ApprovalFields.documentationCompleted: () => Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
    ApprovalFields.sendToDocumentationChecker: () => Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
    ApprovalFields.sendtoCCUChecker: () => Utils.checkRoles([
          UserRole.ccuMaker,
        ]),
    ApprovalFields.returntoCCUMaker: () => Utils.checkRoles([
          UserRole.ccuChecker,
        ]),
    ApprovalFields.acceptCloseApplication: () => Utils.checkRoles([
          UserRole.ccuChecker,
        ]),
    ApprovalFields.previewApplication: () => Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
          UserRole.documentationMaker,
          UserRole.documentationChecker,
          UserRole.ccuMaker,
          UserRole.ccuChecker,
        ]),
  };

  /// Initializes repositories, loads application details, users, comments,
  /// references, workflow visibility flags, and draft data.
  Future<void> init(BuildContext context) async {
    try {
      controller = UnifiedEditorController();
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      logger.i("initialising RequestForLimitReleaseViewModel");
      repository = RequestRepository.instance;
      approvalRepository = ApprovalRepository.instance;
      adminRepository = AdminRepository.instance;
      await repository.getApplicationDetails();
      await approvalRepository.fetchReference();
      isReadOnly = !ScreenAccessConditions.isAssignedToCurrentUser() ||
          !Globals.checkCurrentStatus(requestStatus);
      await getComments(
        CommentsType.requestForLimitRelease,
        EntityIdentifier.requestForLimitRelease,
      );
      activityName =
          Globals.applicationDetails?.applicationLifeCycle?.activityName ?? "";
      userAction =
          Globals.applicationDetails?.applicationLifeCycle?.userAction ?? 0;
      isButtonVisible = (ServerConstants
                  .folTypeActionList[FOLTypeAction.sentToLimitLoading] ==
              activityName) ||
          ((ServerConstants.folTypeActionList[FOLTypeAction.folNotRequired] ==
                  activityName) &&
              (userAction == ServerConstants.assignToMeActionCA ||
                  userAction == ServerConstants.assignToMeActionDM));

      allUserList = await getAllUserRoleLists();

      final Map<FOLTypeAction, Map<String, List<User>>> allUserMaps =
          await getAllUserLists();

      sendToCcuCheckerMap = allUserMaps[FOLTypeAction.sendToCCUChecker] ?? {};
      sendToCcuMakerMap = allUserMaps[FOLTypeAction.sendToCCUMaker] ?? {};
      returnCcuMakerMap = allUserMaps[FOLTypeAction.returnFromDocCCU] ?? {};
      stagesMap.addAll({
        for (final ref in Globals.limitReleaseStagesReferences)
          ref.id.toString(): ref.name ?? "",
      });
      stageList = stagesMap.values.toList();
      if (!isReadOnly) {
        registerDraftCallback();
        await loadDraftIfAvailable();
      }
    } on Object catch (e) {
      logger.e("Error Fetching : $e");
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // AutoSave related changes by extended team

  /// Closes the view model and unregisters draft callbacks.
  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }

  /// Saves the strategy comment entered in the form and handles the result.
  ///
  /// This method performs the following steps:
  /// - Validates the editor content.
  /// - Sends the comment to the repository.
  /// - Deletes the draft after successful save.
  /// - Optionally navigates to the next route.
  ///
  /// Parameters:
  /// - [ifNavigate] optional flag indicating whether to navigate after saving.
  Future<void> saveComment({bool ifNavigate = false}) async {
    try {
      final rawHtml = await controller.getText();
      final plainText = rawHtml
          .replaceAll(RegExp("<[^>]*>"), "") // remove HTML tags
          .replaceAll("&nbsp;", " ") // handle non-breaking spaces
          .trim();

      if (plainText.isEmpty) {
        AlertManager().showFailureToast(
          "approval.requestForLimitRelease.pleaseEnterRemarks".tr(),
        );
        return;
      }
      // emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      comment = Comment.fromInputData(
        type: CommentsType.requestForLimitRelease,
        entityType: EntityIdentifier.requestForLimitRelease,
        categoryId:
            ServerConstants.commentTypeId[CommentsType.requestForLimitRelease],
        reviewCommentId: reviewCommentId,
        comment: rawHtml,
      );

      reviewCommentId = await approvalRepository.saveReviewComments(comment!);
      await getComments(
        CommentsType.requestForLimitRelease,
        EntityIdentifier.requestForLimitRelease,
      );
      AlertManager().showSuccessToast(
        "approval.creditAssessment.savedSuccessfully".tr(),
      );
      unawaited(deleteDraft());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      if (ifNavigate) {
        LayoutViewModel().goToNextRoute();
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Fetches comments for a given entity and comment type.
  ///
  /// This asynchronous method retrieves comments from the [CommonRepository]
  /// based on the specified [type] and [entityIdentifier]. If the fetch fails,
  /// an error toast is displayed using [AlertManager].
  ///
  /// Parameters:
  /// - The type of comments to retrieve.
  /// - The identifier for the entity associated with the
  /// comments.
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

  /// Returns the role reference list required for the given workflow action.
  List<String> getReferenceList(FOLTypeAction type) {
    List<String> referenceList = [];

    if (type == FOLTypeAction.sendToCCUMaker) {
      referenceList = [
        ServerConstants.userRoleCode[UserRole.ccuMaker] ?? "",
      ];
    } else if (type == FOLTypeAction.sendToCCUChecker) {
      referenceList = [ServerConstants.userRoleCode[UserRole.ccuChecker] ?? ""];
    } else {
      if (Utils.checkRole(UserRole.ccuMaker)) {
        referenceList = [
          ServerConstants.userRoleCode[UserRole.documentationChecker] ?? "",
          ServerConstants.userRoleCode[UserRole.relationshipManager] ?? "",
          ServerConstants.userRoleCode[UserRole.relationshipOfficer] ?? "",
        ];
      } else {
        referenceList = [
          ServerConstants.userRoleCode[UserRole.ccuMaker] ?? "",
        ];
      }
    }

    return referenceList.toSet().toList();
  }

  /// Fetches and groups users required for all limit release workflow actions.
  Future<Map<FOLTypeAction, Map<String, List<User>>>> getAllUserLists() async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    final List<FOLTypeAction> allTypes = [
      FOLTypeAction.sendToCCUChecker,
      FOLTypeAction.sendToCCUMaker,
      FOLTypeAction.returnFromDocCCU,
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
        await approvalRepository.getUsersByRoles([roles]);

    final Map<FOLTypeAction, Map<String, List<User>>> result = {};

    for (final FOLTypeAction type in allTypes) {
      final List<String> typeRoles = typeRoleMap[type]!;

      final List<User> filteredUsers = allUsers.where((user) {
        return typeRoles.contains(user.currentRole?.code);
      }).toList();

      result[type] = getUsersByRole(filteredUsers);
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

    return result;
  }

  /// Fetches all users for all roles involved in the limit release workflow.
  Future<List<User>> getAllUserRoleLists() async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    final List<FOLTypeAction> allTypes = [
      FOLTypeAction.sendToCCUChecker,
      FOLTypeAction.sendToCCUMaker,
      FOLTypeAction.returnFromDocCCU,
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

    final List<User> allUsers =
        await approvalRepository.getUsersByRoles([roles]);

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

  /// Submits the selected workflow action and returns dialog messages.
  Future<List<String>> submitApplication(
    FOLTypeAction userAction, {
    int mode = 1,
  }) async {
    final List<String> description = [];
    final List<FOLTypeAction> actions = [
      // for validation of user selection
      FOLTypeAction.sendToCCUChecker,
      FOLTypeAction.sendToCCUMaker,
      FOLTypeAction.returnFromDocCCU,
      FOLTypeAction.returnToUser,
    ];
    int commentId = 0;
    final bool isReturn = (userAction == FOLTypeAction.returnFromDocCCU);

    // final String rawText = await controller.getText();
    // final String text = rawText
    //     .replaceAll(RegExp("<[^>]*>"), "")
    //     .replaceAll("&nbsp;", " ")
    //     .trim();

    if (initialText.isEmpty) {
      AlertManager().showFailureToast(
        "approval.requestForLimitRelease.pleaseEnterRemarks".tr(),
      );
      return [];
    }

    try {
      if (selectedStage.isEmpty &&
          Utils.checkRoles([
            UserRole.ccuChecker,
            UserRole.ccuMaker,
          ])) {
        AlertManager().showFailureToast(
          "approval.requestForFOL.selectStageBeforeSubmit".tr(),
        );
        return [];
      }

      final List<String> selectedValue = selectedUserId.split(":");
      final String userId = selectedValue.first;
      final String role = selectedValue.last;
      logger.i("selectedValue : $selectedValue");

      if (userId.isEmpty && actions.contains(userAction)) {
        AlertManager().showFailureToast(
          "approval.requestForFOL.selectUserbeforeSubmit".tr(),
        );
        return [];
      }

      // if (userAction == FOLTypeAction.returnFromDocCCU) {
      //   // selectedUser = returnCcuMakerList.firstWhereOrNull(
      //   //       (user) =>
      //   //           (user.id == userId) && (user.currentRole?.bpmRole == role),
      //   //     ) ??
      //   //     User();
      //   for (final users in returnCcuMakerMap.values) {
      //     selectedUser =
      //         users.firstWhereOrNull((user) => user.id == userId) ?? User();
      //   }
      //   selectedUser.currentRole?.bpmRole = role;
      // } else if (userAction == FOLTypeAction.sendToCCUChecker) {
      //   // selectedUser = sendToCcuCheckerList
      //   //         .firstWhereOrNull((user) => user.id == userId) ??
      //   //     User();
      //   for (final users in sendToCcuCheckerMap.values) {
      //     selectedUser =
      //         users.firstWhereOrNull((user) => user.id == userId) ?? User();
      //   }
      //   selectedUser.currentRole?.bpmRole = role;
      // } else if (userAction == FOLTypeAction.sendToCCUMaker) {
      //   // selectedUser =
      //   //     sendToCcuMakerList.firstWhereOrNull((user) => user.id == userId) ??
      //   //         User();
      //   for (final users in sendToCcuMakerMap.values) {
      //     selectedUser =
      //         users.firstWhereOrNull((user) => user.id == userId) ?? User();
      //   }
      //   selectedUser.currentRole?.bpmRole = role;
      // }

      // all user list with all roles
      selectedUser =
          allUserList.firstWhereOrNull((user) => user.id == userId) ?? User();
      selectedUser.currentRole?.bpmRole = role;

      logger.i("selectedUser : ${selectedUser.toJson()}");

      int? actionId = Globals.folTypeAction.firstWhereOrNull(
        (map) => map.containsKey(ServerConstants.folTypeActionList[userAction]),
      )?[ServerConstants.folTypeActionList[userAction]];

      if ((FOLTypeAction.returnFromDocCCU == userAction) &&
          Utils.checkRole(UserRole.ccuChecker)) {
        actionId = ServerConstants.returnToCCUmaker;
      }

      if ((FOLTypeAction.returnFromDocCCU == userAction) &&
          (selectedUser.currentRole?.name ==
              ServerConstants.userRoleCode[UserRole.documentationChecker])) {
        logger.i("actionId : ${selectedUser.currentRole?.name}");
        actionId = ServerConstants.returnToCCUmaker;
      }

      if (FOLTypeAction.documentationCompleted == userAction) {
        actionId = ServerConstants.acceptCloseApplication;
      }

      commentId = int.tryParse(reviewCommentId) ?? 0;

      final AppResponse response = await approvalRepository.submitApplication(
        selectedUser,
        commentId,
        actionId,
        returnToUser: isReturn,
        mode: mode,
        userAction: userAction,
        stage: selectedStage,
      );
      if (response.status == ResponseStatus.success) {
        AlertManager().showSuccessToast(
          "approval.requestForFOL.applicationSuccessfulSubmitted".tr(),
        );
        if (FOLTypeAction.documentationCompleted == userAction) {
          final approvedMessage =
              "Your Application ${Globals.request?.applicationRefNo} "
              "has been approved successfully";

          description.addAll([
            "layout.topmenu.comfirmation".tr(),
            approvedMessage,
          ]);
        } else {
          final moveSuccessMessage =
              "Your Application ${Globals.request?.applicationRefNo} "
              "has been moved to ${selectedUser.id} successfully";

          description.addAll([
            "layout.topmenu.comfirmation".tr(),
            moveSuccessMessage,
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
