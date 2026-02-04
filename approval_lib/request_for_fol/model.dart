import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:wcas_frontend/core/components/dropdown/model.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/safe_cubit.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/admin/reference_type.dart';
import 'package:wcas_frontend/models/login/role.dart';
import 'package:wcas_frontend/models/login/user.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/repositories/admin_repository.dart';
import 'package:wcas_frontend/repositories/approval_repository.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';
import 'package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart';
import 'state.dart';

class RequestForFolViewModel extends SafeCubit<RequestForFolState> {
  RequestForFolViewModel()
      : super(RequestForFolState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for handling request-related operations.
  late ApprovalRepository repository;
  final UnifiedEditorController controller = UnifiedEditorController();
  final ScrollController scrollController = ScrollController();
  late AdminRepository adminRepository;
  late RequestRepository requestRepository;

  String initialText = "";
  int? rowsPerPage = 5;
  UserRole? userRole = Globals.user?.currentRole!.userRole;

  // Comments
  List<Comment> comments = [];
  Comment? comment;
  List<User> users = [];
  // List<CustomDropdownItem> userList = <CustomDropdownItem>[];
  List<User> userList = <User>[];
  User selectedUser = User();
  String selectedUserId = "";
  List<ReferenceType> allReferences = [];
  List<Reference> references = [];

  final Map<ApprovalFields, bool Function()> buttonVisibilityStatus = {
    ApprovalFields.initiateFinalFOL: () => Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
        ]),
    ApprovalFields.documentationSubmitted: () => Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
        ]),
    ApprovalFields.sendToDocumentation: () => Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
        ]),
    ApprovalFields.returnToDocumentationMaker: () => Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
        ]),
    ApprovalFields.initiateFitToLend: () => Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
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
        ]),
    ApprovalFields.documentationCompleted: () => Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
    ApprovalFields.sendToDocumentationChecker: () => Utils.checkRoles([
          UserRole.documentationMaker,
        ]),
  };
  final List<String> stageList = [
    // "FOL Draft under Preparation",
    // "FOL Draft under RM/RO review",
    // "FOL Draft under DC review",
    // "FOL Draft under Finalization",
    // "FOL under client sign off",
    // "Executed Documents under review",
    // "Discrepancies advised to RM",
    // "Final Fit to lend checks",
    // "Final fit to lend checks review with DC",
    // "Fit to Lend checks completed",
    // "FOL not required"
  ];

  final List<String> yesNo = ['Yes', 'No'];
  bool canSubmit = false;
  bool isReadOnly = true;

  void init(context) async {
    logger.i('initialising RequestForFolViewModel');
    repository = ApprovalRepository.instance;
    adminRepository = AdminRepository.instance;
    requestRepository = RequestRepository.instance;
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    try {
      await repository.getLegalAndLimitDetails();
    } catch (e) {
      logger.e("Error Fetching : $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
    await requestRepository.getApplicationDetails();
    await repository.fetchReference();
    isReadOnly = Globals.checkAccessbility()['isReadOnly'] ?? true;

    await getComments(
        CommentsType.requestForFOL, EntityIdentifier.requestForFOL);
    userList = await repository
        .getUsersByRoles(getUserRoleNames(Globals.user?.availableRoles));
    allReferences = await adminRepository.getReferenceTypes();

    ReferenceType selectedValue = allReferences
        .firstWhere((ref) => ref.name == "APPROVAL_DOCUMENTATION STAGES");

    references = await adminRepository.getReferenceData(selectedValue);
    stageList.addAll(references.map((ref) => ref.name ?? ""));

    selectedValue.name = "FOL_TYPES";
    references = await adminRepository.getReferenceData(selectedValue);
    Globals.folTypeStatus =
        references.map((ref) => {ref.name: ref.id}).toList();

    // userList = await getUserListDropDownItems(users);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onTextChange(String text) async {
    final plainText = text
        .replaceAll(RegExp(r'<[^>]*>'), '') // remove HTML tags
        .replaceAll('&nbsp;', ' ') // handle non-breaking spaces
        .trim();
    canSubmit = plainText.trim().isNotEmpty;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Saves the strategy comment entered in the form and handles the result.
  ///
  /// This method performs the following steps:
  /// - Validates the form using [formKey].
  /// - If validation passes, saves the form state and logs the [strategyComment].
  /// - Sends the comment to the repository via [saveComments].
  /// - If an exception occurs during the process, displays a failure toast
  ///   and updates the state to [LoadingStatus.error] for [covenantsSummaryLoader].
  ///
  /// Parameters:
  /// - [ifNavigate] (optional): A flag indicating whether to navigate after saving. Currently unused.
  ///
  /// This method is asynchronous and should be awaited.
  Future<void> saveComment({bool ifNavigate = false}) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      comment = Comment.fromInputData(
        comment: "plainText",
        type: CommentsType.requestForFOL,
        entityType: EntityIdentifier.requestForFOL,
        categoryId: ServerConstants.commentTypeId[CommentsType.requestForFOL]!,
      );

      String responseMessage =
          await CommonRepository.instance.saveComment(comment!);
      AlertManager().showSuccessToast(responseMessage);
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
  /// - [entityIdentifier]: The identifier for the entity associated with the comments.
  ///
  /// Returns:
  /// - A [Future] that completes when the comments are successfully fetched or
  ///   an error is handled.
  Future<void> getComments(
      CommentsType type, EntityIdentifier entityIdentifier) async {
    try {
      comments =
          await CommonRepository.instance.getComments(type, entityIdentifier);
      if (comments.isNotEmpty) {
        comment = comments
            .reduce((a, b) => a.createdDate!.isAfter(b.createdDate!) ? a : b);
        initialText = comment?.comment ?? "";
        controller.setText(initialText);
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  void onSavePress({bool isContinue = false}) async {
    try {
      final String rawHtml = await controller.getText();

      if (rawHtml.isEmpty) {
        AlertManager().showFailureToast(
          'approval.comment.requestForLimitRelease.pleaseEnterRemarks'.tr(),
        );
        return;
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      comment = Comment.fromInputData(
          type: CommentsType.requestForFOL,
          entityType: EntityIdentifier.requestForFOL,
          categoryId: ServerConstants.commentTypeId[CommentsType.requestForFOL],
          comment: rawHtml);

      // debugPrint("Comment value : ${comment?.toJson().toString()}");

      await CommonRepository.instance.saveComment(comment!);
      await requestRepository.getApplicationDetails();
      AlertManager().showSuccessToast(
        "approval.creditAssessment.savedSuccessfully".tr(),
      );

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      if (isContinue) {
        LayoutViewModel().goToNextRoute();
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  // bool checkVisibility(RequestStatus requestStatus) {
  //   int? status = ServerConstants.requestStatusId[requestStatus];
  //   return (applicationDetails?.status == status);
  // }

  List<CustomDropdownItem> getUserListDropDownItems(List<User> users) {
    List<CustomDropdownItem> usersList = [];
    for (final user in users) {
      usersList.add(CustomDropdownItem(
          label: user.name,
          value: user.id,
          onPressed: () {
            selectedUser = user;
          }));
    }
    return usersList;
  }

  List<String> getUserRoleNames(List<Role>? roles) {
    List<String> userRoles = [];
    for (final role in roles!) {
      userRoles.add(role.bpmRole.toString());
    }
    return userRoles;
  }

  Future<void> submitApplication(UserAction userAction) async {
    //debugPrint("selectedUserId : $selectedUserId  ");

    selectedUser = userList.firstWhere((user) => user.name == selectedUserId);
    debugPrint("selectUser : ${selectedUser.toJson()}");

    int? actionId = Globals.userAction.firstWhere(
      (map) => map.containsKey(ServerConstants.userActionList[userAction]),
    )[ServerConstants.userActionList[userAction]];

    await repository.submitApplication(selectedUser,
        ServerConstants.commentTypeId[CommentsType.requestForFOL], actionId,
        mode: 1);
  }

  Future<void> submitApplicationFOL(FOLTypeAction userAction) async {
    //debugPrint("selectedUserId : $selectedUserId  ");

    selectedUser = userList.firstWhere((user) => user.name == selectedUserId);
    debugPrint("selectUser : ${selectedUser.toJson()}");

    int? actionId = Globals.userAction.firstWhere(
      (map) => map.containsKey(ServerConstants.folTypeActionList[userAction]),
    )[ServerConstants.folTypeActionList[userAction]];

    await repository.submitApplication(selectedUser,
        ServerConstants.commentTypeId[CommentsType.requestForFOL], actionId,
        mode: 1);
  }
}
