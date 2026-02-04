import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wcas_frontend/core/components/dropdown/model.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';

import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
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

class RequestForLimitReleaseViewModel
    extends SafeCubit<RequestForLimitReleaseState> {
  RequestForLimitReleaseViewModel()
      : super(RequestForLimitReleaseState(loaderStatus: LoadingStatus.loading));
  late RequestRepository repository;
  late ApprovalRepository approvalRepository;
  late AdminRepository adminRepository;
  final UnifiedEditorController controller = UnifiedEditorController();
  final ScrollController scrollController = ScrollController();

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
  List<User> userList = <User>[];
  bool canSubmit = false;
  bool isReadOnly = true;
  List<ReferenceType> allReferences = [];
  List<Reference> references = [];
  final List<String> stageList = [
    // "Limit release instructions with maker",
    // "Limit release instructions with Checker",
    // "Limit release queries with RO/RM",
    // "Limit release queries with DC"
  ];

  final List<String> yesNo = ['Yes', 'No'];
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
    ApprovalFields.sendtoCCUMaker: () => Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManagerBussiness,
          UserRole.documentationChecker,
        ]),
    ApprovalFields.stage: () => Utils.checkRoles([
          UserRole.documentationChecker,
          UserRole.documentationMaker,
          UserRole.ccuMaker,
          UserRole.ccuChecker,
        ]),
    ApprovalFields.returns: () => Utils.checkRoles([
          UserRole.documentationChecker,
          UserRole.documentationMaker,
          UserRole.ccuMaker,
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
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    logger.i('initialising RequestForLimitReleaseViewModel');
    repository = RequestRepository.instance;
    approvalRepository = ApprovalRepository.instance;
    adminRepository = AdminRepository.instance;
    await repository.getApplicationDetails();
    await approvalRepository.fetchReference();
    isReadOnly = Globals.checkAccessbility()['isReadOnly'] ?? true;
    await getComments(CommentsType.requestForLimitRelease,
        EntityIdentifier.requestForLimitRelease);
    // await Future.delayed(const Duration(seconds: 2));
    allReferences = await adminRepository.getReferenceTypes();
    ReferenceType selectedValue = allReferences
        .firstWhere((ref) => ref.name == "APPROVAL_DOCUMENTATION STAGES");
    references = await adminRepository.getReferenceData(selectedValue);
    stageList.addAll(references.map((ref) => ref.name ?? ""));
    userList = await approvalRepository
        .getUsersByRoles(getUserRoleNames(Globals.user?.availableRoles));
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
        comment: initialText,
        categoryId:
            ServerConstants.commentTypeId[CommentsType.requestForLimitRelease],
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

  Future<void> onSavePress(
      {required BuildContext context, bool isContinue = false}) async {
    try {
      final String rawHtml = await controller.getText();

      if (rawHtml.isEmpty) {
        AlertManager().showFailureToast(
          'approval.requestForLimitRelease.pleaseEnterRemarks'.tr(),
        );
        return;
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      // String response =
      //     await repository.saveBussinessVoumes(customerWiseBusinessVolume);
      // AlertManager().showSuccessToast(response);

      comment = Comment.fromInputData(
          type: CommentsType.requestForLimitRelease,
          entityType: EntityIdentifier.requestForLimitRelease,
          categoryId: ServerConstants
              .commentTypeId[CommentsType.requestForLimitRelease],
          comment: rawHtml);

      // debugPrint("Comment value : ${comment?.toJson().toString()}");

      await CommonRepository.instance.saveComment(comment!);

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      if (isContinue) {
        LayoutViewModel().goToNextRoute();
      }
      if (context.mounted) {
        context.read<RequestForLimitReleaseViewModel>().init(context);
        context.go(GoRouter.of(context).location);
        GoRouter.of(context).refresh();
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  List<String> getUserRoleNames(List<Role>? roles) {
    List<String> userRoles = [];
    for (final role in roles!) {
      userRoles.add(role.bpmRole.toString());
    }
    return userRoles;
  }

  UserRole getUserCode(String role) {
    return ServerConstants.userCodeRole[role] ?? UserRole.na;
  }

  int getUserRoleId(UserRole userRole) {
    return ServerConstants.userRoleId[userRole] ?? 0;
  }

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

  Future<void> submitApplication(UserAction userAction) async {
    //debugPrint("selectedUserId : $selectedUserId  ");

    selectedUser = userList.firstWhere((user) => user.name == selectedUserId);
    // debugPrint("selectUser : ${selectedUser.toJson()}");

    int? actionId = Globals.userAction.firstWhere(
      (map) => map.containsKey(ServerConstants.userActionList[userAction]),
    )[ServerConstants.userActionList[userAction]];

    await approvalRepository.submitApplication(
        selectedUser,
        ServerConstants.commentTypeId[CommentsType.requestForLimitRelease],
        actionId,
        mode: 1);
  }
}
