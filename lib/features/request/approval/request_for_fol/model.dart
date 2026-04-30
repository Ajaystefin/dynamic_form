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
import "package:wcas_frontend/features/request/approval/request_for_fol/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/request_for_fol/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class RequestForFolViewModel extends SafeCubit<RequestForFolState>
    with DraftMixin<RequestForFolViewModel> {
  RequestForFolViewModel()
      : super(RequestForFolState(loaderStatus: LoadingStatus.loading));

  // --- DRAFT IDENTITY ---
  @override
  String get draftModuleKey => DraftModuleKeys.approval;

  // Create a unique form key based on the route, customer string identifier,
  // and the active tab's name
  @override
  String get draftFormKey => Routes.requestForFOL;

  @override
  DraftHandler<RequestForFolViewModel> get draftHandler =>
      RequestFOLDraftHandler();

  /// Repository instance for handling request-related operations.
  late ApprovalRepository repository;
  UnifiedEditorController controller = UnifiedEditorController();
  final ScrollController scrollController = ScrollController();
  late AdminRepository adminRepository;
  late RequestRepository requestRepository;
  late CommonRepository commonRepository;

  String initialText = "";
  int? rowsPerPage = 5;
  UserRole? userRole = Globals.user?.currentRole!.userRole;

  // Comments
  List<Comment> comments = [];
  Comment? comment;
  List<User> users = [];
  // List<CustomDropdownItem> userList = <CustomDropdownItem>[];
  List<User> sendRoRmUserList = <User>[];
  List<User> sendDmUserList = <User>[];
  List<User> sendDcUserList = <User>[];
  List<User> sendDocumentList = <User>[];
  User selectedUser = User();
  String selectedUserId = "";
  List<ReferenceType> allReferences = [];
  List<Reference> references = [];
  Map<String, String> roleMap = {};
  String selectedStage = "";
  final List<String> yesNo = ["Yes", "No"];
  bool canSubmit = false;
  bool isReadOnly = false;
  List<User> returnUserList = <User>[];
  Map<String, List<User>> returnUserMap = {};
  Map<String, List<User>> sendRoRmUserMap = {};
  Map<String, List<User>> sendDmUserMap = {};
  Map<String, List<User>> sendDcUserMap = {};
  Map<String, List<User>> sendDocumentUserMap = {};
  int initRoleId = 0;
  bool isCommentVisible = false;
  String reviewCommentId = "0";
  String selectedOpt = "";
  bool isReturnSelected = false;
  bool showAdditionalComment = false;
  CustomDropdownItem? returnPrefill;
  String additionalComment = "";
  String activityName = "";
  bool isOptionsVisible = false;
  bool isCompleteVisible = false;
  bool isInitiateFitVisible = false;
  bool isReturnVisible = false;
  bool isCCUVisible = false;
  int userActionId = 0;
  List<String> stageList = [];
  Map<String, String> stagesMap = {};
  List<RequestStatus> requestStatus = [
    RequestStatus.pendingFolIssuance,
    RequestStatus.folIssuedPendingSignOff,
    RequestStatus.folSignOffCompletedPendingFitToLend,
  ];

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
  };

  Future<void> init(context) async {
    logger.i("initialising RequestForFolViewModel");
    repository = ApprovalRepository.instance;
    adminRepository = AdminRepository.instance;
    requestRepository = RequestRepository.instance;
    commonRepository = CommonRepository.instance;
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    try {
      await requestRepository.getApplicationDetails();
      await repository.fetchReference();
      isReadOnly = !Globals.checkCurrentStatus(requestStatus);
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
      isCCUVisible = (userActionId == ServerConstants.sendToDocumentMaker) &&
          checkCurrentStatus([FOLTypeAction.finalFolGenerated]);
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
      debugPrint("checkDocumentFlow : $isReadOnly");

      await getComments(
        CommentsType.requestForFOL,
        EntityIdentifier.requestForFOL,
      );
      sendRoRmUserMap = await getUserListByGroup(FOLTypeAction.sendToRoRm);
      returnUserMap = await getUserListByGroup(FOLTypeAction.returnFromDocCCU);
      sendDmUserMap =
          await getUserListByGroup(FOLTypeAction.sendToDocumentationMaker);
      sendDcUserMap =
          await getUserListByGroup(FOLTypeAction.sendToDocumentationChecker);
      sendDocumentUserMap =
          await getUserListByGroup(FOLTypeAction.sendToDocumentation);
      stagesMap.addAll({
        for (final ref in Globals.documentStagesReferences)
          ref.id.toString(): ref.name ?? "",
      });
      stageList = stagesMap.values.toList();
      debugPrint("getStages : ${stageList.length}");
    } catch (e) {
      debugPrint("getStages : $e");
      logger.e("Error Fetching : $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
    if (!isReadOnly) {
      registerDraftCallback();
      await loadDraftIfAvailable();
      debugPrint("registerDraftCallback FOL");
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onTextChange(String text) {
    final plainText = text
        .replaceAll(RegExp("<[^>]*>"), "") // remove HTML tags
        .replaceAll("&nbsp;", " ") // handle non-breaking spaces
        .trim();
    canSubmit = plainText.trim().isNotEmpty;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onOptChanged(String value) {
    selectedOpt = value;
    if (selectedOpt == yesNo.first) {
      showAdditionalComment = false;
    } else {
      showAdditionalComment = true;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // void showOpts() {
  //   isOptionsVisible = true;
  //   emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  // }

  bool checkCurrentStatus(List<Enum> statusList) {
    bool status = false;
    status = statusList.any((status) {
      final String title = ServerConstants.folTypeActionList[status] ?? "";
      debugPrint("FOL title : $title $activityName");
      return (activityName == title);
    });
    debugPrint("FOL status : $status");
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
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
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

  Future<Map<String, List<User>>> getUserListByGroup(FOLTypeAction type) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    List<String> referenceList = [];
    if (type == FOLTypeAction.sendToRoRm) {
      referenceList = [
        ServerConstants.userRoleCode[UserRole.relationshipOfficer] ?? "",
        ServerConstants.userRoleCode[UserRole.relationshipManager] ?? "",
      ];
    } else if (type == FOLTypeAction.returnFromDocCCU) {
      referenceList = [
        ServerConstants.userRoleCode[UserRole.relationshipOfficer] ?? "",
        ServerConstants.userRoleCode[UserRole.relationshipManager] ?? "",
      ];
      if (Utils.checkRole(UserRole.documentationMaker)) {
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
    referenceList = referenceList.toSet().toList();
    debugPrint("referenceList : ${referenceList.toString()}");
    roleMap = {
      for (final role in Globals.superUserRoles) ...role,
    };
    final List<String> bpmRoleList =
        referenceList.map((ref) => roleMap[ref]).whereType<String>().toList();
    final String roles = bpmRoleList.join(",");
    if (roles.isNotEmpty) {
      if (type == FOLTypeAction.returnFromDocCCU) {
        returnUserList = await repository.getUsersByRoles([roles]);
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return getUsersByRole(returnUserList);
      } else if (type == FOLTypeAction.sendToRoRm) {
        sendRoRmUserList = await repository.getUsersByRoles([roles]);
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return getUsersByRole(sendRoRmUserList);
      } else if (type == FOLTypeAction.sendToDocumentationMaker) {
        sendDmUserList = await repository.getUsersByRoles([roles]);
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return getUsersByRole(sendDmUserList);
      } else if (type == FOLTypeAction.sendToDocumentationChecker) {
        sendDcUserList = await repository.getUsersByRoles([roles]);
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return getUsersByRole(sendDcUserList);
      } else {
        sendDocumentList = await repository.getUsersByRoles([roles]);
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return getUsersByRole(sendDocumentList);
      }
    }
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
    debugPrint("additionalComment : $additionalComment");
    try {
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

      final List<String> selectedValue = selectedUserId.split(":");
      final String userId = selectedValue.first;
      final String role = selectedValue.last;
      // debugPrint("selectedValue : ${selectedValue.toString()}");

      if (userId.isEmpty && actions.contains(userAction)) {
        AlertManager().showFailureToast(
          "approval.requestForFOL.selectUserbeforeSubmit".tr(),
        );
        return [];
      }

      if (userAction == FOLTypeAction.returnFromDocCCU) {
        selectedUser =
            returnUserList.firstWhereOrNull((user) => user.id == userId) ??
                User();
        selectedUser.currentRole?.bpmRole = role;
      } else if (userAction == FOLTypeAction.sendToRoRm) {
        selectedUser =
            sendRoRmUserList.firstWhereOrNull((user) => user.id == userId) ??
                User();
        selectedUser.currentRole?.bpmRole = role;
      } else if (userAction == FOLTypeAction.sendToDocumentationMaker) {
        selectedUser =
            sendDmUserList.firstWhereOrNull((user) => user.id == userId) ??
                User();
        selectedUser.currentRole?.bpmRole = role;
      } else if (userAction == FOLTypeAction.sendToDocumentationChecker) {
        selectedUser =
            sendDcUserList.firstWhereOrNull((user) => user.id == userId) ??
                User();
        selectedUser.currentRole?.bpmRole = role;
      } else {
        selectedUser =
            sendDocumentList.firstWhereOrNull((user) => user.id == userId) ??
                User();
        selectedUser.currentRole?.bpmRole = role;
      }

      // debugPrint('selectedUser : ${selectedUser.toJson()}');

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
        selectedUser, commentId, actionId,
        returnToUser: isReturn,
        avoidWarning:
            true, // for further process made it as true change it to false
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
          description.addAll([
            "layout.topmenu.comfirmation".tr(),
            "Your Application ${Globals.request?.applicationRefNo} "
                "has been moved to CCU successfully",
          ]);
        } else if (userAction == FOLTypeAction.initiateFinalFOL) {
          description.addAll([
            "layout.topmenu.comfirmation".tr(),
            "Your Application ${Globals.request?.applicationRefNo} "
                "has been moved to DC successfully",
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
