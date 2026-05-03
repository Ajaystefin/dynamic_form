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
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/approval/request_for_limit_release/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/request_for_limit_release/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class RequestForLimitReleaseViewModel
    extends SafeCubit<RequestForLimitReleaseState>
    with DraftMixin<RequestForLimitReleaseViewModel> {
  RequestForLimitReleaseViewModel()
      : super(RequestForLimitReleaseState(loaderStatus: LoadingStatus.loading));
  late RequestRepository repository;
  late ApprovalRepository approvalRepository;
  late AdminRepository adminRepository;
  late final UnifiedEditorController controller;

  String initialText = "";
  int? rowsPerPage = 5;
  UserRole? userRole = Globals.user?.currentRole!.userRole;

// Comments
  List<Comment> comments = [];
  Comment? comment;

  List<User> users = [];
  // List<CustomDropdownItem> userList = <CustomDropdownItem>[];
  String selectedUserId = "";
  User selectedUser = User();
  bool canSubmit = false;
  bool isReadOnly = false;
  List<Reference> references = [];
  List<String> stageList = [];
  CustomDropdownItem? returnPrefill;
  Map<String, String> roleMap = {};
  List<User> sendToCcuMakerList = <User>[];
  List<User> sendToCcuCheckerList = <User>[];
  List<User> returnCcuMakerList = <User>[];
  Map<String, List<User>> sendToCcuMakerMap = {};
  Map<String, List<User>> sendToCcuCheckerMap = {};
  Map<String, List<User>> returnCcuMakerMap = {};
  String activityName = "";
  String reviewCommentId = "0";
  bool isCommentVisible = false;
  String selectedStage = "";
  bool isReturnSelected = false;
  bool isButtonVisible = false;
  int userAction = 0;
  Map<String, String> stagesMap = {};
  List<RequestStatus> requestStatus = [
    RequestStatus.fitToLendCompletedPendingLimitRelease,
    RequestStatus.pendingLimitRelease,
    RequestStatus.folNotRequired,
  ];

  @override
  String get draftModuleKey => DraftModuleKeys.approval;

  @override
  String get draftFormKey => Routes.requestForLimitRelease;

  @override
  DraftHandler<RequestForLimitReleaseViewModel> get draftHandler =>
      RequestForLimitReleaseDraftHandler();

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
  };

  Future<void> init(context) async {
    try {
      controller = UnifiedEditorController();
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      logger.i("initialising RequestForLimitReleaseViewModel");
      repository = RequestRepository.instance;
      approvalRepository = ApprovalRepository.instance;
      adminRepository = AdminRepository.instance;
      await repository.getApplicationDetails();
      await approvalRepository.fetchReference();
      isReadOnly = !Globals.checkCurrentStatus(requestStatus);
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
              (userAction == ServerConstants.assignToMeAction));
      // stageList.addAll(
      //     Globals.limitReleaseStagesReferences.map((ref) => ref.name ?? ""));
      sendToCcuCheckerMap =
          await getUserListByGroup(FOLTypeAction.sendToCCUChecker);
      sendToCcuMakerMap =
          await getUserListByGroup(FOLTypeAction.sendToCCUMaker);
      returnCcuMakerMap =
          await getUserListByGroup(FOLTypeAction.returnFromDocCCU);
      stagesMap.addAll({
        for (final ref in Globals.limitReleaseStagesReferences)
          ref.id.toString(): ref.name ?? "",
      });
      stageList = stagesMap.values.toList();
      if (!isReadOnly) {
        registerDraftCallback();
        await loadDraftIfAvailable();
      }
    } catch (e) {
      logger.e("Error Fetching : $e");
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // AutoSave related changes by extended team
  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }

  Future<void> onTextChange(String text) async {
    final plainText = text
        .replaceAll(RegExp("<[^>]*>"), "") // remove HTML tags
        .replaceAll("&nbsp;", " ") // handle non-breaking spaces
        .trim();
    canSubmit = plainText.trim().isNotEmpty;
    initialText = text;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Saves the strategy comment entered in the form and handles the result.
  ///
  /// This method performs the following steps:
  /// - Validates the form using [formKey].
  /// - If validation passes, saves the form state and logs the
  /// [strategyComment].
  /// - Sends the comment to the repository via [saveComments].
  /// - If an exception occurs during the process, displays a failure toast
  ///   and updates the state to [LoadingStatus.error] for
  /// [covenantsSummaryLoader].
  ///
  /// Parameters:
  /// - [ifNavigate] (optional): A flag indicating whether to navigate after
  /// saving. Currently unused.
  ///
  /// This method is asynchronous and should be awaited.
  Future<void> saveComment({bool ifNavigate = false}) async {
    try {
      final rawHtml = await controller.getText();
      final plainText = rawHtml
          .replaceAll(RegExp("<[^>]*>"), "") // remove HTML tags
          .replaceAll("&nbsp;", " ") // handle non-breaking spaces
          .trim();

      if (plainText.isEmpty) {
        AlertManager().showFailureToast(
          "approval.comment.requestForLimitRelease.pleaseEnterRemarks".tr(),
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
        comment: plainText,
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
    } catch (e) {
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

  Future<Map<String, List<User>>> getUserListByGroup(FOLTypeAction type) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
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
    referenceList = referenceList.toSet().toList();
    debugPrint("referenceList : ${referenceList.toString()}");
    roleMap = {
      for (final role in Globals.superUserRoles) ...role,
    };
    final List<String> bpmRoleList =
        referenceList.map((ref) => roleMap[ref]).whereType<String>().toList();
    final String roles = bpmRoleList.join(",");
    if (roles.isNotEmpty) {
      if (type == FOLTypeAction.sendToCCUMaker) {
        sendToCcuMakerList = await approvalRepository.getUsersByRoles([roles]);
        return getUsersByRole(sendToCcuMakerList);
      } else if (type == FOLTypeAction.sendToCCUChecker) {
        sendToCcuCheckerList =
            await approvalRepository.getUsersByRoles([roles]);
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return getUsersByRole(sendToCcuCheckerList);
      } else {
        returnCcuMakerList = await approvalRepository.getUsersByRoles([roles]);
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return getUsersByRole(returnCcuMakerList);
      }
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    return {};
  }

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
              isHeader: false,
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
    });
    return usersList;
  }

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

    if (initialText.isEmpty) {
      AlertManager().showFailureToast(
        "approval.requestForFOL.pleaseEnterRemarks".tr(),
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
      debugPrint("selectedValue : ${selectedValue.toString()}");

      if (userId.isEmpty && actions.contains(userAction)) {
        AlertManager().showFailureToast(
          "approval.requestForFOL.selectUserbeforeSubmit".tr(),
        );
        return [];
      }

      if (userAction == FOLTypeAction.returnFromDocCCU) {
        selectedUser = returnCcuMakerList.firstWhereOrNull(
              (user) =>
                  (user.id == userId) && (user.currentRole?.bpmRole == role),
            ) ??
            User();
        selectedUser.currentRole?.bpmRole = role;
      } else if (userAction == FOLTypeAction.sendToCCUChecker) {
        selectedUser = sendToCcuCheckerList
                .firstWhereOrNull((user) => user.id == userId) ??
            User();
        selectedUser.currentRole?.bpmRole = role;
      } else if (userAction == FOLTypeAction.sendToCCUMaker) {
        selectedUser =
            sendToCcuMakerList.firstWhereOrNull((user) => user.id == userId) ??
                User();
        selectedUser.currentRole?.bpmRole = role;
      }

      debugPrint("selectedUser : ${selectedUser.toJson()}");

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
        debugPrint("actionId : ${selectedUser.currentRole?.name}");
        actionId = ServerConstants.returnToCCUmaker;
      }

      if (FOLTypeAction.documentationCompleted == userAction) {
        actionId = ServerConstants.acceptCloseApplication;
      }

      commentId = int.tryParse(reviewCommentId) ?? 0;

      final AppResponse response = await approvalRepository.submitApplication(
        selectedUser, commentId, actionId,
        returnToUser: isReturn,
        avoidWarning:
            true, // for further process made it as true change it to false
        mode: mode,
        userAction: userAction,
        stage: selectedStage,
      );
      if (response.status == ResponseStatus.success) {
        AlertManager().showSuccessToast(
          "approval.requestForFOL.applicationSuccessfulSubmitted".tr(),
        );
        if (FOLTypeAction.documentationCompleted == userAction) {
          description.addAll([
            "layout.topmenu.comfirmation".tr(),
            "Your Application ${Globals.request?.applicationRefNo} "
                "has been approved successfully",
          ]);
        } else {
          description.addAll([
            "layout.topmenu.comfirmation".tr(),
            "Your Application ${Globals.request?.applicationRefNo} "
                "has been moved to ${selectedUser.id} successfully",
          ]);
        }

        return description;
      } else {
        AlertManager()
            .showFailureToast("approval.requestForFOL.applicationFailed".tr());
        return description;
      }
    } catch (e) {
      logger.e("Error details: $e");
      AlertManager()
          .showFailureToast("approval.requestForFOL.applicationFailed".tr());
      return description;
    }
  }
}
