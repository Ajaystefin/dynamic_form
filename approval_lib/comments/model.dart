import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:wcas_frontend/core/components/dropdown/model.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/api_service/api_manager.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/safe_cubit.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/admin/reference_type.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/repositories/admin_repository.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';
import 'package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart';
import '../../../../models/login/role.dart';
import '../../../../models/login/user.dart';
import '../../../../repositories/approval_repository.dart';
import 'state.dart';

class CommentsViewModel extends SafeCubit<CommentsState> {
  CommentsViewModel()
      : super(CommentsState(
            loaderStatus: LoadingStatus.loading,
            getRole: Globals.user?.currentRole?.code ?? ""));
  late RequestRepository repository;
  late ApprovalRepository approvalRepository;
  int? rowsPerPage = 5;
  final UnifiedEditorController controller = UnifiedEditorController();
  final ScrollController scrollController = ScrollController();
  late AdminRepository adminRepository;
  List<Comment> comments = [];
  Comment? comment;
  List<User> users = [];
  // List<CustomDropdownItem> userList = <CustomDropdownItem>[];
  List<User> userList = <User>[];
  Map<String, List<User>> groupUserList = {};
  Map<String, List<User>> approveUserList = {};
  Map<String, List<User>> returnUserList = {};
  UserRole? userRole = Globals.user?.currentRole!.userRole;
  String? returnOptSelected = '';
  // bool isEdit =
  //     !Globals.isAllReadOnly && Globals.checkCanEdit(RightConstants.comments);
  bool isReadOnly = true; // not assigned & created
  List<Reference> references = [];
  List<ReferenceType> allReferences = [];
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<Role> assigned = [];
  String selectedUserId = ""; // for recommend
  User selectedUser = User(); // for recommend
  String initialText = ""; // inital value in editor
  bool canSubmit = false; // empty field validation
  bool visibilityStatus = false; // check app status
  String reviewCommentId = "0";
  bool isRiskRatingInit = false; // to check if role is initaitor and subtype RR
  List<Map<String, int>> reviewCommentCategory = [
    {'Rework for Clarification': ServerConstants.returnForClarification},
    {'Rework for Query': ServerConstants.returnForQuery}
  ];
  int categoryId = 0;
  bool isOneOffLimit = false;
  Map<String, List<Reference>> referenceData = {};
  List<int?> segmentHeadList = [
    ServerConstants.userRoleId[UserRole.segmentHeadLevelB],
    ServerConstants.userRoleId[UserRole.segmentHeadCreditLevelD],
    ServerConstants.userRoleId[UserRole.segmentHeadLevelC],
    ServerConstants.userRoleId[UserRole.segmentHeadLevelB1],
  ];
  String selectedDelegation = "";
  bool isCommentVisible = false;
  Role? assignedRole;
  bool isInitByCA = false;

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
          UserRole.relationshipOfficer,
          UserRole.relationshipManager
        ]),
    ApprovalFields.noReturn: () => Utils.checkRoles([
          UserRole.admin,
        ]),
    ApprovalFields.recommend: () => Utils.checkRoles([
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
        ]),
    ApprovalFields.returns: () => Utils.checkRoles([
          UserRole.admin,
          UserRole.relationshipManagerBussiness,
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
    'Rework for Clarification',
    'Rework for Query'
  ];

  List<String> reasonForDecline = [];

  void onTextChange(String text) async {
    initialText = text
        .replaceAll(RegExp(r'<[^>]*>'), '') // remove HTML tags
        .replaceAll('&nbsp;', ' ') // handle non-breaking spaces
        .trim();
    canSubmit = initialText.trim().isNotEmpty;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> init(context) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    logger.i('initialising CommentsViewModel');
    repository = RequestRepository.instance;
    approvalRepository = ApprovalRepository.instance;
    adminRepository = AdminRepository.instance;
    try {
      allReferences = await adminRepository.getReferenceTypes();
      await repository.getApplicationDetails();
      await approvalRepository.fetchReference();
      isReadOnly = Globals.isAllReadOnly;
      await getComments(CommentsType.approval, EntityIdentifier.approval);

      String role = await checkIsInitiated();
      debugPrint("role : $role");
      isInitByCA = role == ServerConstants.userRoleCode[UserRole.creditAnalyst];
      debugPrint(" isInitByCA : $isInitByCA");

      isRiskRatingInit = Globals.checkAppSubStatus(
          ServerConstants.applicationSubType[ApplicationSubType.riskRating] ??
              "");
      isOneOffLimit = Globals.checkAppSubStatus(ServerConstants
                  .applicationSubType[ApplicationSubType.cashMargin] ??
              "") &&
          Globals.applicationDetails?.requestType == "MEMO";
      // isOneOffLimit = true; // for test
      groupUserList =
          await getUserListByGroup(ReferenceDataKeys.recommendationList);
      if (Globals.checkCurrentStatus([RequestStatus.approved]) ||
          isOneOffLimit ||
          segmentHeadList.contains(Globals.user?.currentRole?.roleId)) {
        approveUserList = await getApprovalUserListByGroup(
            ReferenceDataKeys.approvalsOnBeHelafOf);
      } else if (Globals.checkCurrentStatus([RequestStatus.declined])) {
        referenceData = await ReferenceDataService()
            .getReferenceData([ReferenceDataKeys.reasonForDecline]);
        reasonForDecline = referenceData[ReferenceDataKeys.reasonForDecline]!
            .map((ref) => ref.name ?? "")
            .toList();
        debugPrint("reasonForDecline : ${reasonForDecline.length}");
      }
      if (isOneOffLimit ||
          segmentHeadList.contains(Globals.user?.currentRole?.roleId)) {
        approvalDelegationList = await getApprovalDelegationList(
            ReferenceDataKeys.approvalDelegationList);
        debugPrint("approvalDelegationList : ${approvalDelegationList.length}");
      }
      // if (Utils.checkRole(UserRole.creditAnalyst)) {
      //   Map<String, List<Reference>> referenceData =
      //       await ReferenceDataService()
      //           .getReferenceData([ReferenceDataKeys.reasonForDecline]);
      //   reviewCommentCategory =
      //       referenceData[ReferenceDataKeys.reviewCommentCategory]!
      //           .map((ref) => {ref.name ?? "": ref.id ?? 0})
      //           .toList();
      //   debugPrint("reviewCommentCategory : ${reviewCommentCategory.length}");
      // }
      returnUserList =
          await getUserListByGroup(ReferenceDataKeys.returnedRolesList);
    } catch (e) {
      logger.e("Error Fetching : $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<String> checkIsInitiated() async {
    assignedRole = await approvalRepository.getLastAssignedRole();
    debugPrint("role : ${assignedRole?.roleRM} ${assignedRole?.createdRM}");
    try {
      for (Map<String, String> map in Globals.superUserRoles) {
        final entry = map.entries.firstWhere(
            (e) => e.value == assignedRole?.roleRM,
            orElse: () => const MapEntry("", ""));
        if (entry.key.isNotEmpty) {
          return entry.key;
        }
      }
    } catch (e) {
      debugPrint("is $e");
    }
    return "";
  }

  Future<Map<String, List<User>>> getUserListByGroup(String type) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    ReferenceType selectedValue = ReferenceType(name: type);
    references = await adminRepository.getReferenceData(selectedValue);
    Reference selectedReference = references.firstWhere((ref) =>
        ref.name ==
        ServerConstants.userRoleCode[Globals.user?.currentRole?.userRole]);
    List<String> referenceList = [];
    if (selectedReference.reference1?.isNotEmpty ?? false) {
      referenceList.addAll(
          selectedReference.reference1?.split(RegExp(r'\s*,\s*')) ?? []);
    }
    Map<String, String> roleMap = {
      for (final role in Globals.superUserRoles) ...role,
    };
    List<String> bpmRoleList =
        referenceList.map((ref) => roleMap[ref]).whereType<String>().toList();
    String roles = bpmRoleList.join(',');

    userList = await approvalRepository.getUsersByRoles([roles]);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    return getUsersByRole(userList);
  }

  Future<Map<String, List<User>>> getApprovalUserListByGroup(
      String type) async {
    ReferenceType selectedValue = ReferenceType(name: type);
    references = await adminRepository.getReferenceData(selectedValue);
    Reference selectedReference = references.firstWhere((ref) => (ref.name ==
        ServerConstants.userRoleCode[Globals.user?.currentRole?.userRole]));
    List<String> referenceList = [];
    if (selectedReference.reference1?.isNotEmpty ?? false) {
      referenceList.addAll(
          selectedReference.reference1?.split(RegExp(r'\s*,\s*')) ?? []);
    }
    if (selectedReference.reference2?.isNotEmpty ?? false) {
      referenceList.addAll(
          selectedReference.reference2?.split(RegExp(r'\s*,\s*')) ?? []);
    }
    if (selectedReference.reference3?.isNotEmpty ?? false) {
      referenceList.addAll(
          selectedReference.reference3?.split(RegExp(r'\s*,\s*')) ?? []);
    }
    // debugPrint("referenceList : ${referenceList.length}");

    Map<String, String> roleMap = {
      for (final role in Globals.superUserRoles) ...role,
    };
    List<String> bpmRoleList =
        referenceList.map((ref) => roleMap[ref]).whereType<String>().toList();
    String roles = bpmRoleList.join(',');

    userList = await approvalRepository.getUsersByRoles([roles]);
    debugPrint("userList : ${userList.length}");
    return getUsersByRole(userList);
  }

  Future<List<String>> getApprovalDelegationList(String type) async {
    ReferenceType selectedValue = ReferenceType(name: type);
    references = await adminRepository.getReferenceData(selectedValue);

    List<Map<String, String>> selectedDelegation = references
        .map((ref) {
          final roles = ref.reference1?.split(RegExp(r'\s*,\s*')) ?? [];
          debugPrint(
              "roles List ${roles.toString()} in ${Globals.user?.currentRole?.roleId.toString()}");
          if (roles.contains(Globals.user?.currentRole?.roleId.toString())) {
            return {ref.name ?? "": ref.reference2 ?? ""};
          }
          return null;
        })
        .whereType<Map<String, String>>()
        .toList();
    // debugPrint("selectedReference : ${selectedDelegation.length}");
    List<String> delegationList = selectedDelegation
        .map((del) => "${del.keys.first}:${del.values.first}")
        .toList();
    // final Map<String, String> delegationMap = {
    //   for (final del in selectedDelegation) ...del,
    // };
    return delegationList;
  }

  Future<void> getComments(
      CommentsType type, EntityIdentifier entityIdentifier) async {
    try {
      comments =
          await CommonRepository.instance.getComments(type, entityIdentifier);

      if (comments.isNotEmpty) {
        if (comments.length == 1) {
          isCommentVisible = comments.first.userId != Globals.user?.id &&
              comments.first.userRole != Globals.user?.currentRole?.roleId;
          debugPrint("isCommentVisible : $isCommentVisible");
        } else {
          isCommentVisible = true;
        }

        List<Comment> commentList = [];
        for (final com in comments) {
          if (com.userId == Globals.user?.id &&
              com.userRole == Globals.user?.currentRole?.roleId) {
            commentList.add(com);
          }
        }
        if (commentList.length > 1) {
          comment = commentList
              .reduce((a, b) => a.createdDate!.isAfter(b.createdDate!) ? a : b);
        }
        if (commentList.isNotEmpty) {
          comment = commentList.first;
        }

        if (comment != null) {
          reviewCommentId = comment?.reviewCommentId ?? "0";
          initialText = comment?.comment ?? "";
          controller.setText(initialText);
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
    categoryId = reviewCommentCategory.firstWhere(
          (cat) => cat.containsKey(returnOptSelected),
        )[returnOptSelected] ??
        0;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onSavePress({
    required BuildContext context,
    bool isContinue = false,
  }) async {
    try {
      await saveReviewComments();

      if (isContinue) {
        LayoutViewModel().goToNextRoute();
      }

      await getComments(CommentsType.approval, EntityIdentifier.approval);
      await repository.getApplicationDetails();

      AlertManager().showSuccessToast(
        "approval.creditAssessment.savedSuccessfully".tr(),
      );
      // if (context.mounted) {
      //   GoRouter.of(context).refresh();
      //   context.read<CommentsViewModel>().init(context);
      //   context.go(GoRouter.of(context).location);
      // }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  Future<void> saveReviewComments() async {
    final String rawHtml = await controller.getText();

    if (rawHtml.isEmpty) {
      AlertManager().showFailureToast(
        'approval.creditAssessment.pleaseEnterRemarks'.tr(),
      );
      return;
    }
    comment = Comment.fromInputData(
        type: CommentsType.approval,
        entityType: EntityIdentifier.approval,
        categoryId: (categoryId != 0)
            ? categoryId
            : ServerConstants.commentCategoryId[CommentsCategory.approval],
        reviewCommentId: reviewCommentId,
        comment: rawHtml);

    await approvalRepository.saveReviewComments(comment!);
    categoryId = 0; // reset the condition
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

  List<CustomDropdownItem> getUserListDropDownItems(
      Map<String, List<User>> users) {
    List<CustomDropdownItem> usersList = [];
    users.forEach((role, users) {
      usersList
          .add(CustomDropdownItem(value: role, label: role, isHeader: true));
      for (final user in users) {
        usersList.add(CustomDropdownItem(
            isHeader: false,
            value: "${user.id}:$role",
            label: "${user.name} - ${user.id}",
            onPressed: () {
              selectedUser = user;
            }));
      }
    });
    return usersList;
  }

  List<ItemGroup> groupItemsByTitle(List<CustomDropdownItem> items) {
    final Map<String?, List<CustomDropdownItem>> map = {};

    for (CustomDropdownItem item in items) {
      if (!map.containsKey(item.title)) {
        map[item.title] = [];
      }
      map[item.title]!.add(item);
    }

    return map.entries
        .map((entry) => ItemGroup(entry.key, entry.value))
        .toList();
  }

  Map<String, List<User>> getUsersByRole(List<User> users) {
    Map<String, List<User>> grouped = {};
    if (users.isEmpty) {
      return grouped;
    }
    for (final user in users) {
      grouped.putIfAbsent(user.currentRole!.bpmRole!, () => []);
      grouped[user.currentRole!.bpmRole]?.add(user);
    }
    // debugPrint("GROUP user : ${grouped['RO-WCAS']?.first.toJson().toString()}");
    return grouped;
  }

  Future<List<String>> submitApplication(UserAction userAction) async {
    List<String> description = [];
    List<UserAction> actions = [
      // for validation of user selection
      UserAction.recommended,
      UserAction.returned,
      UserAction.approveOnBehalfOf
    ];

    if (initialText.isEmpty) {
      AlertManager().showFailureToast(
        'approval.creditAssessment.pleaseEnterRemarks'.tr(),
      );
      return [];
    }

    List<String> selectedValue = selectedUserId.split(":");
    selectedUserId = selectedValue.first;
    String role = selectedValue.last;

    if (selectedUserId.isEmpty && actions.contains(userAction)) {
      AlertManager().showFailureToast(
        'approval.comments.selectUserbeforeSubmit'.tr(),
      );
      return [];
    }

    if (userList.isNotEmpty && actions.contains(userAction)) {
      selectedUser = userList.firstWhere((user) => user.name == selectedUserId);
      selectedUser.currentRole?.bpmRole = role;
    }
    // debugPrint("selectedUser : ${selectedUser.toJson()}");

    int? actionId = Globals.userAction.firstWhere(
      (map) => map.containsKey(ServerConstants.userActionList[userAction]),
    )[ServerConstants.userActionList[userAction]];
    try {
      AppResponse response;
      if (isRiskRatingInit && userAction == UserAction.acceptCloseApplication) {
        await saveReviewComments();
        if (comment == null) {
          return [];
        }
      }
      if ([UserAction.approved, UserAction.approveOnBehalfOf]
          .contains(userAction)) {
        if (selectedDelegation.isEmpty) {
          AlertManager().showFailureToast(
            'approval.comments.selectDelegationbeforeSubmit'.tr(),
          );
          return [];
        }
        debugPrint(
            "selectedDelegation : ${selectedDelegation.split(":").first}");
        selectedUser.currentRole =
            Role(bpmRole: selectedDelegation.split(":").first);
        debugPrint("selectedUser : ${selectedUser.currentRole?.bpmRole}");
        selectedUser.id = selectedDelegation.split(":").last;
      }
      response = await approvalRepository.submitApplication(selectedUser,
          ServerConstants.commentTypeId[CommentsType.approval], actionId,
          avoidWarning:
              false); // for further process made it as true change it to false
      if (response.status == ResponseStatus.success) {
        AlertManager().showSuccessToast(
            "approval.comments.applicationSuccessfulSubmitted".tr());
        description.addAll([
          "layout.topmenu.comfirmation".tr(),
          "Your Application ${Globals.request?.applicationRefNo} has been moved to ${selectedUser.id} successfully"
        ]);
        return description;
      } else if (response.body['baseResponse'] != null &&
          response.body['baseResponse']['status']['errorCode'] == "422") {
        String errorDescription =
            response.body['baseResponse']['status']['errorDescription'];
        List<String> description = errorDescription.split('; ');
        return description;
      } else {
        AlertManager()
            .showFailureToast("approval.comments.applicationFailed".tr());
        return description;
      }
    } catch (e) {
      logger.e('Error details: $e');
      AlertManager()
          .showFailureToast("approval.comments.applicationFailed".tr());
      return description;
    }
  }
}
