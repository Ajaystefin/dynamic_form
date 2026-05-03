import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/approval/utils/approval_utils.dart";
import "package:wcas_frontend/features/request/ccsys/approval/draft_handler.dart";
import "package:wcas_frontend/features/request/ccsys/approval/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/ccsys/ccsys_approval.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/ccsys_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class CcsysApprovalViewModel extends SafeCubit<CcsysApprovalState>
    with DraftMixin<CcsysApprovalViewModel> {
  CcsysApprovalViewModel()
      : super(
          CcsysApprovalState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

  late RequestRepository repository;
  late CcsysRepository repositoryCcsys;
  late ApprovalRepository approvalRepository;
  final UnifiedEditorController controller = UnifiedEditorController();

  final ScrollController scrollController =
      ScrollController(keepScrollOffset: false);

  List<Comment> comments = [];
  Comment? comment;
  bool isRSAEnabled = false;

  Role? lastAssignedRole;
  List<User> users = [];
  List<User> usersReturn = [];
  List<CustomDropdownItem> userList = <CustomDropdownItem>[];
  List<CustomDropdownItem> userListReturn = <CustomDropdownItem>[];
  UserRole? userRole = Globals.user?.currentRole?.userRole;
  String? roleCode = "";
  Request requests = Globals.request!;
  String? appRefNo = Globals.request?.applicationRefNo;

  List<Reference> applicationType = [];
  List<Reference> ccsysRoleType = [];
  List<Reference> ccsysRecommendenRolesList = [];
  List<Reference> ccsysReturnedRolesList = [];

  String? selectedUserId;
  String? selectedUserName;
  String? selectedUserBpmRole;
  String? selectedUserBpmRoleCode;

  String? selectedReturnUserId;
  String? selectedReturnUserName;
  String? selectedReturnUserBpmRole;

  String rsaDigit = "";

  bool canEdit = false;
  // State
  PageMode pageMode = PageMode.na;

  void initRightsAndMode(Request request) {
    final bool rights = request.ccsysCanEditReadOnly ?? true;
    pageMode =
        AuthRepository.getPageMode(RightConstants.ccsysRecommendationApproval);
    if (!rights) {
      canEdit = false;
      return;
    }
    canEdit = pageMode == PageMode.edit;
  }

  // AutoSave related changes by extended team
  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.ccsys;

  @override
  String get draftFormKey => Routes.ccsysApproval;

  @override
  DraftHandler<CcsysApprovalViewModel> get draftHandler =>
      CcsysApprovalDraftHandler();

  // ---------------------------------------------------------------------------

  Future<void> init(context) async {
    logger.i("initialising CcsysApprovalViewModel");
    repository = RequestRepository.instance;
    repositoryCcsys = CcsysRepository.instance;
    approvalRepository = ApprovalRepository.instance;

    userRole = Globals.user?.currentRole?.userRole;

    initRightsAndMode(Globals.request ?? Request());

    try {
      await Future.wait([
        getReferenceData(),
        getUsersByRoles(),
        getLastAssignedRole(),
        fetchAndSetStrategyComments(),
      ]);

      await loadRecommendUsers();

      await loadReturnUsers();

      getUserRole(userRole!);

      // AutoSave related changes by extended team
      if (canEdit) {
        registerDraftCallback();
        await loadDraftIfAvailable();
      }
    } catch (e) {
      if (e.toString().isNotEmpty) {
        AlertManager().showFailureToast(e.toString());
      }
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // AutoSave related changes by extended team
  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }

  Future<void> getReferenceData() async {
    try {
      final Map<String, List<Reference>> referenceData =
          await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.applicationType,
        ReferenceDataKeys.roleType,
        ReferenceDataKeys.ccsysRecommendenRolesList,
        ReferenceDataKeys.ccsysEmirateList,
        ReferenceDataKeys.ccsysReturnedRolesList, // <--- added
      ]);
      applicationType = referenceData[ReferenceDataKeys.applicationType] ?? [];
      ccsysRoleType = referenceData[ReferenceDataKeys.roleType] ?? [];
      ccsysRecommendenRolesList =
          referenceData[ReferenceDataKeys.ccsysRecommendenRolesList] ?? [];
      ccsysReturnedRolesList =
          referenceData[ReferenceDataKeys.ccsysReturnedRolesList] ?? [];
      final Reference appType = applicationType.firstWhere(
        (e) => e.id == ServerConstants.ccsysAppReferenceId,
        orElse: () => Reference(
          id: ServerConstants.ccsysAppReferenceId,
          name: ServerConstants.ccsysAppReferenceName,
          reference1: ServerConstants.ccsysAppReference1,
          reference2: ServerConstants.ccsysAppReference2,
          reference3: ServerConstants.ccsysAppReference3,
          reference4: ServerConstants.ccsysAppReference4,
          reference5: ServerConstants.ccsysAppReference5,
        ),
      );
      appType;
      isRSAEnabled =
          (ApprovalUtils.passwordModeReference.firstOrNull?.name == "2");
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getLastAssignedRole() async {
    try {
      lastAssignedRole = await repositoryCcsys.getLastAssignedRole();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getUsersByRoles() async {
    try {
      // users = await repositoryCcsys
      //     .getUsersByRoles(getUserRoleNames(Globals.user?.availableRoles));
      // userList = await getUserListDropDownItems(users);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchAndSetStrategyComments() async {
    try {
      final List<Comment> commentsd = await CommonRepository.instance
          .getComments(CommentsType.ccsys, EntityIdentifier.ccsys);
      if (commentsd.isNotEmpty) {
        comments = commentsd
            .where(
              (cmt) => cmt.applicationRefNo
                      ?.contains(Globals.request?.applicationRefNo ?? "") ??
                  false,
            )
            .toList();
        debugPrint("Strategy comment: ${comments[0].comment}");
        // controller.setText(comments.last.comment ?? '');
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      comments = [Comment(strategyComment: "")];
      logger.e("Error fetching strategy comments: $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  Future<void> submitComments() async {
    try {
      final detailsRawValue = await getCleanText(controller);
      if (detailsRawValue.isNotEmpty) {
        comment?.strategyComment = detailsRawValue;
        comment = Comment.fromInputData(
          comment: detailsRawValue,
          type: CommentsType.ccsys,
          entityType: EntityIdentifier.ccsys,
          categoryId: ServerConstants.commentTypeId[CommentsType.ccsys],
        );
        await CommonRepository.instance.saveComment(comment ?? Comment());
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        AlertManager().showSuccessToast("common.dataSaveSuccess".tr());
        await fetchAndSetStrategyComments();
        // moveToNext();
      }
      // else {
      //   emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      //   AlertManager().showFailureToast(
      //       "ccsys.recommendationApproval.emptyCommentError".tr());
      // }
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      if (e.toString().isNotEmpty) {
        AlertManager().showFailureToast(e.toString());
      }
    }
  }

  List<String> getUserRoleNames(List<Role>? roles) {
    final List<String> userRoles = [];
    for (final role in roles!) {
      userRoles.add(role.bpmRole.toString());
    }
    return userRoles;
  }

  Future<List<CustomDropdownItem>> getUserListDropDownItems(
    List<User> users,
  ) async {
    final List<CustomDropdownItem> usersList = [];
    for (final user in users) {
      usersList.add(
        CustomDropdownItem(
          label: user.name,
          value: user.id,
          onPressed: () {},
        ),
      );
    }

    return usersList;
  }

  void getUserRole(UserRole commentUserRole) {
    switch (commentUserRole) {
      case UserRole.relationshipOfficer:
        roleCode = ServerConstants.userRoleCode[UserRole.relationshipOfficer];
      case UserRole.relationshipManagerBussiness:
        roleCode =
            ServerConstants.userRoleCode[UserRole.relationshipManagerBussiness];
      case UserRole.businessUnitHead:
        roleCode = ServerConstants.userRoleCode[UserRole.businessUnitHead];
      case UserRole.creditCordinator:
        roleCode = ServerConstants.userRoleCode[UserRole.creditCordinator];
      default:
        roleCode = "";
    }
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
      ),
    );
  }

  bool get showRecommendButton => Utils.checkRoles([
        UserRole.relationshipManagerBussiness,
        UserRole.relationshipManager,
        UserRole.relationshipOfficer,
        UserRole.commercialAreaManager,
        UserRole.teamLeaderBusiness,
        UserRole.segmentHeadBusiness,
      ]);

  bool get showApproveButton => Utils.checkRoles([
        UserRole.ccuMaker,
        UserRole.ccuChecker,
      ]);

  bool get showDeclineCancelButton => Utils.checkRoles([
        UserRole.ccuMaker,
        UserRole.ccuChecker,
      ]);

  bool get showReturnButton => Utils.checkRoles([
        UserRole.relationshipManager,
        UserRole.relationshipManagerBussiness,
        UserRole.commercialAreaManager,
        UserRole.teamLeaderBusiness,
        UserRole.segmentHeadBusiness,
      ]);

  //Only for Credit control team for check for alert manager.
  bool checkRoleCreditControlTeamByEnum(UserRole? role) {
    if (role == null) return false;
    return role == UserRole.ccuMaker || role == UserRole.ccuChecker;
  }

// Or using the map to resolve from code → enum (reverse lookup) when you only
// have code:
  UserRole? getUserRoleFromCode(String? code) {
    if (code == null || code == "—") return null;
    try {
      return ServerConstants.userRoleCode.entries
          .firstWhere((e) => e.value == code)
          .key;
    } catch (_) {
      return null;
    }
  }

  //Only for Credit control team
  bool checkRoleCreditControlTeam(String? roleCode) {
    final UserRole? role = getUserRoleFromCode(roleCode);
    return checkRoleCreditControlTeamByEnum(role);
  }

  Future<void> onSavePress(BuildContext context, String action) async {
    try {
      bool isValid = false;
      if (action != "saveAndContinue") {
        final CCSYSApproval ccsysApproval = CCSYSApproval()
          ..appRefNo = Globals.request?.applicationRefNo
          ..mode = 0
          ..commentId = (comments.isNotEmpty
              ? (int.tryParse(comments.first.reviewCommentId.toString()) ?? 0)
              : 0)
          ..avoidWarning = true
          ..approveOnBehalfOf = null
          ..approveOnBehalfOfRole = null;

        if (action == "recommend" && showRecommendButton) {
          ccsysApproval
            ..userAction = ServerConstants.userActionRecommend
            ..returnToUser = false;
          if ((selectedUserId ?? "").isNotEmpty) {
            ccsysApproval
              ..assignedTo = selectedUserId
              ..assignedRole = selectedUserBpmRole;
          } else {
            AlertManager().showFailureToast(
              "approval.comments.selectUserbeforeSubmit".tr(),
            );
            return;
          }
        }

        if (action == "approve" && showApproveButton) {
          ccsysApproval
            ..userAction = ServerConstants.userActionApproved
            ..returnToUser = false
            ..assignedTo = ""
            ..assignedRole = "";
        }

        if (action == "cancel" && showDeclineCancelButton) {
          ccsysApproval
            ..userAction = ServerConstants.userActionDeclineCancel
            ..returnToUser = false
            ..assignedTo = ""
            ..assignedRole = "";
        }

        if (action == "return" && showReturnButton) {
          ccsysApproval
            ..userAction = ServerConstants.userActionReturn
            ..returnToUser = true;
          if ((selectedReturnUserId ?? "").isNotEmpty) {
            ccsysApproval
              ..assignedTo = selectedReturnUserId
              ..assignedRole = selectedReturnUserBpmRole;
          } else {
            AlertManager().showFailureToast(
              "approval.comments.selectUserbeforeSubmit".tr(),
            );
            return;
          }
        }

        //debugPrint("-------$selectedUserBpmRoleCode");
        if (action == "approve" && context.mounted && isRSAEnabled) {
          isValid = await showRsaDialog(context);
          if (isValid) {
            await repositoryCcsys.submitApplication(ccsysApproval);
          } else {
            AlertManager()
                .showFailureToast("approval.comments.failedToAuth".tr());
            return;
          }
        } else {
          await repositoryCcsys.submitApplication(ccsysApproval);
        }

        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      }

      if (action == "saveAndContinue") {
        await submitComments();
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

      if (action != "saveAndContinue") {
        if (context.mounted) {
          showDialogSuccessAppRefNo(
            context,
            appRefNo: Globals.request?.applicationRefNo,
            action: action,
            userId: (action == "return" && showReturnButton)
                ? selectedReturnUserId
                : selectedUserId,
            userName: (action == "return" && showReturnButton)
                ? selectedReturnUserName
                : selectedUserName,
            targetRole: selectedUserBpmRole,
          );
        }
      }
      // else {
      //   AlertManager().showSuccessToast("common.dataSaveSuccess".tr());
      // }
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      if (e.toString().isNotEmpty) {
        AlertManager().showFailureToast(e.toString());
      }
    }
  }

  /// Helper to clean HTML tags and spaces
  Future<String> getCleanText(UnifiedEditorController controller) async {
    final rawHtml = await controller.getText();
    return rawHtml;
    // .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
    // .replaceAll('&nbsp;', ' ') // Handle non-breaking spaces
    // .replaceAll('\u00A0', ' ') // Replace non-breaking spaces
    // .trim();
  }

  Future<bool> showRsaDialog(BuildContext context) async {
    bool returnValue = false;
    await DialogHelper.showCustomDialog(
      context: context,
      title: "approval.comments.authentication".tr(),
      content: Column(
        children: [
          // Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical:
          // 8),
          //     decoration: BoxDecoration(
          //         border: Border.all(color: Colors.grey, width: 1),
          //         borderRadius: BorderRadius.circular(4)),
          //     child: Text(description))
          LabelWidget(
            isRequired: true,
            label: "approval.comments.rsaToken".tr(),
            child: CustomTextField(
              isPassword: true,
              semanticLabel: "approval.comments.rsaToken".tr(),
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                return CustomValidator.requiredCustomField(
                  value,
                  "approval.comments.rsaToken".tr(),
                );
              },
              onChanged: (value) {
                rsaDigit = value;
              },
            ),
          ),
        ],
      ),
      width: context.isDesktop ? 400.w : null,
      actions: [
        CustomButton(
          label: "approval.comments.cancel".tr(),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
        const Gap(
          direction: Axis.horizontal,
        ),
        CustomButton(
          label: "approval.comments.submit".tr(),
          onPressed: () async {
            returnValue = await validateRsaToken();
            if (context.mounted) {
              Navigator.pop(context);
            }
            // router.go(Routes.loadingPage);
            // await Future.delayed(const Duration(milliseconds: 100), () {
            //   router.go(Routes.home); // Navigate back to home
            // });
          },
        ),
      ],
    );
    return returnValue;
  }

  Future<bool> validateRsaToken() async {
    if (rsaDigit.length == 10) {
      final bool value = await approvalRepository.validateRSAToken(rsaDigit);
      debugPrint("value : $value");
      return value;
    }
    return false;
  }

  void showDialogSuccessAppRefNo(
    BuildContext context, {
    String? appRefNo,
    String? action,
    String? userId,
    String? userName,
    String? targetRole,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DialogHelper.showCustomDialog(
        barrierDismissible: false,
        onClosePressed: () {
          context.pop();
          moveToNext();
        },
        width: Scale.scaleHorizontally(350),
        context: context,
        title: "requestInformation.requestInformation.confirmation".tr(),
        content: CustomSelectableText(
          text: (action == "recommend" && showRecommendButton)
              ? (checkRoleCreditControlTeam(selectedUserBpmRoleCode))
                  ? "ccsys.recommendationApproval.informationMsgRoleCAM".tr(
                      namedArgs: {"refno": appRefNo ?? ""},
                    )
                  : "ccsys.recommendationApproval.informationMsgRoleRO".tr(
                      namedArgs: {
                        "refno": appRefNo ?? "",
                        "userId": userId ?? userName ?? targetRole ?? "",
                      },
                    )
              : (action == "approve" && showApproveButton)
                  ? "ccsys.recommendationApproval.informationMsgRoleCCU".tr(
                      namedArgs: {
                        "refno": appRefNo ?? "",
                      },
                    )
                  : (action == "return" && showReturnButton)
                      ? "ccsys.recommendationApproval.informationMsgRoleReturn"
                          .tr(
                          namedArgs: {
                            "refno": appRefNo ?? "",
                            "userId": userId ?? userName ?? targetRole ?? "",
                          },
                        )
                      : (action == "recommend" && showRecommendButton)
                          ? "ccsys.recommendationApproval.informationMsgRoleRO"
                              .tr(
                              namedArgs: {
                                "refno": appRefNo ?? "",
                                "userId":
                                    userId ?? userName ?? targetRole ?? "",
                              },
                            )
                          : (action == "cancel" && showDeclineCancelButton)
                              ? "ccsys.recommendationApproval."
                                      "informationMsgRoleCancel"
                                  .tr(
                                  namedArgs: {"refno": appRefNo ?? ""},
                                )
                              : (action == "saveAndContinue")
                                  ? "common.dataSaveSuccess".tr()
                                  : "",
        ),
        actions: [
          CustomButton(
            label: "requestInformation.requestInformation.okay".tr(),
            onPressed: () {
              context.pop();
              moveToNext();
            },
          ),
        ],
      );
    });
  }

  void moveToNext() {
    router.go(Routes.home);
  }

// --- Helpers & extensions (ADD THIS) ---

  String _norm(String? s) => (s ?? "").trim().toLowerCase();

  bool _equalsIC(String? a, String? b) => _norm(a) == _norm(b);

  /// Convert role representations to the short code used in references (e.g.,
  /// "RM", "RO").
  String _normalizeRoleToCode(Object? raw) {
    final s = raw?.toString() ?? "";

    switch (s) {
      case "UserRole.relationshipManagerBussiness":
      case "UserRole.relationshipManager":
      case "RM":
        return "RM";
      case "UserRole.relationshipOfficer":
      case "RO":
        return "RO";
      case "UserRole.teamLeaderBusiness":
      case "TLB":
        return "TLB";
      case "UserRole.commercialAreaManager":
      case "CAM":
        return "CAM";
      case "UserRole.segmentHeadBusiness":
      case "SHB":
        return "SHB";
      case "UserRole.regionalManagerBusiness":
      case "RMB":
        return "RMB";
    }

    final last = s.split(".").last;
    return last.isNotEmpty ? last : s;
  }

// --- ADD: resolve WCAS roles from reference mapping ---
  Future<String> buildRecommendWcasRolesForCurrentUser() async {
    final code = _currentLoggedInRoleCode();
    if (code.isEmpty) return "";
    return _buildWcasRolesFor(
      loggedRoleCode: code,
      listKey: ReferenceDataKeys.ccsysRecommendenRolesList,
    );
  }

  Future<String> buildReturnWcasRolesForCurrentUser() async {
    final code = _currentLoggedInRoleCode();
    if (code.isEmpty) return "";
    return _buildWcasRolesFor(
      loggedRoleCode: code,
      listKey: ReferenceDataKeys.ccsysReturnedRolesList,
    );
  }

  Future<String> _buildWcasRolesFor({
    required String loggedRoleCode,
    required String
        // ReferenceDataKeys.ccsysRecommendenRolesList
        // or ReferenceDataKeys.ccsysReturnedRolesList
        listKey,
  }) async {
    // Ensure reference data is loaded (getReferenceData() is already called in
    // init()).
    final List<Reference> roleMatrix =
        (listKey == ReferenceDataKeys.ccsysRecommendenRolesList)
            ? ccsysRecommendenRolesList
            : ccsysReturnedRolesList;

    final List<Reference> roleType = ccsysRoleType;

    // --- helper: split CSV safely and trim tokens ---
    List<String> csvTokens(String? s) => (s ?? "")
        .split(",")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // --- SELECT the row differently for Returned vs Recommended ---
    final Reference? selected = (listKey ==
            ReferenceDataKeys.ccsysReturnedRolesList)
        // RETURNED: match when reference1 CSV contains the current role code
        // (token-wise).
        ? roleMatrix.firstWhereOrNull((r) => _equalsIC(r.name, loggedRoleCode))
        // { Need for logic dont remove commented line
        //     final tokens = csvTokens(r.reference1);
        //     return tokens.any((t) => _equalsIC(t, loggedRoleCode));
        //   })
        // RECOMMENDED: keep original intent (match by name or code-ish field).
        : roleMatrix.firstWhereOrNull(
            (r) =>
                _equalsIC(r.name, loggedRoleCode) ||
                _equalsIC(
                  r.reference1,
                  loggedRoleCode,
                ) || // keep if you rely on this as well
                _equalsIC(
                  r.name,
                  loggedRoleCode,
                ), // if your model has a code field
          );

    if (selected == null) return "";

    // Parse CSV from selected.reference1 (existing logic preserved)
    final List<String> codes = csvTokens(selected.reference1);

    final seen = <String>{};
    final result = <String>[];

    // Robust label derivation for roleType rows (in case reference3 can be
    // null)
    String labelFromRoleType(Reference rt) {
      final c3 = (rt.reference3 ?? "").trim();
      if (c3.isNotEmpty) return c3;
      final c2 = (rt.reference2 ?? "").trim();
      if (c2.isNotEmpty) return c2;
      final nm = (rt.name ?? "").trim();
      return nm;
    }

    // Existing mapping: roleType.reference1 (code) -> label (reference3/ref2/name)
    for (final code in codes) {
      final rt =
          roleType.firstWhereOrNull((r) => _equalsIC(r.reference1, code));
      final wcasRole = (rt == null) ? "" : labelFromRoleType(rt);
      if (wcasRole.isEmpty) continue;
      if (seen.add(wcasRole)) result.add(wcasRole);
    }

    // If you still need the earlier enrichment for Returned:
    // when a token matches the current role, also add selected.name
    if (listKey == ReferenceDataKeys.ccsysReturnedRolesList) {
      final hasExactRoleTokenMatch =
          codes.any((c) => _equalsIC(c, loggedRoleCode));
      final selectedName = (selected.name ?? "").trim();
      if (hasExactRoleTokenMatch && selectedName.isNotEmpty) {
        if (seen.add(selectedName)) result.add(selectedName);
      }
    }

    // Return a single CSV string for the API
    return result.join(",");
  }

  String _currentLoggedInRoleCode() {
    final cr = Globals.user?.currentRole;
    final candidates = <Object?>[
      // cr?.shortCode,
      // cr?.roleCode,
      cr?.userRole,
      // cr?.roleName,
    ];
    for (final c in candidates) {
      final code = _normalizeRoleToCode(c);
      if (code.isNotEmpty) return code;
    }
    final roles = Globals.user?.availableRoles ?? <Role>[];
    if (roles.isNotEmpty) return _normalizeRoleToCode(roles.first.bpmRole);
    return "";
  }

// --- ADD: load recommend users using WCAS roles mapping ---

  Future<void> loadRecommendUsers() async {
    if (!showRecommendButton) return;

    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));

      // 1) Build WCAS role names via mapping (you added this earlier)
      final String wcasRoles = await buildRecommendWcasRolesForCurrentUser();

      if (wcasRoles.isEmpty) {
        userList = <CustomDropdownItem>[];
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        AlertManager().showFailureToast(
          "ccsys.recommendationApproval.roleMappingNotFound".tr(),
        );
        return;
      }

      // 2) New grouped call that keeps bpmRoleName per group
      final List<Role> groups =
          await repositoryCcsys.getUsersByRoles(wcasRoles);

      final List<CustomDropdownItem> items = [];

      for (final g in groups) {
        final String roleTitle = g.bpmRole ?? "—";
        final String roleCode = g.code ?? "—";

        // Header row
        items.add(
          CustomDropdownItem(
            value: "__header__:$roleTitle",
            label: roleTitle,
            title: roleTitle,
            roleCode: roleCode,
            isHeader: true,
          ),
        );

        // Users under header
        for (final User u in (g.users ?? [])) {
          items.add(
            CustomDropdownItem(
              value: u.id, // keep plain ID
              label: "${u.id} - ${u.name}",
              // (u.name?.trim().isNotEmpty == true)
              //     ? '  ${u.name}'
              //     : '  ${u.id}',
              title: roleTitle, // for grouping if you need it
              headerName: roleTitle, // the *actual* role for this row
              roleCode: roleCode, isHeader: false,
              onPressed: () {}, // optional
            ),
          );
        }
      }

      users = groups.expand<User>((g) => g.users ?? []).toList();

      userList = items;

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      // AlertManager().showFailureToast(
      //     'Unable to load recommended users. ${e.toString()}');
    }
  }

  Future<void> loadReturnUsers() async {
    if (!showReturnButton) return;

    // --- Local helpers to reduce duplication (no behavior change)
    void addHeaderRow(List<CustomDropdownItem> items, String roleTitle) {
      // 1) HEADER ROW (non-selectable)
      items.add(
        CustomDropdownItem(
          value: "__header__:$roleTitle", // special marker
          label: roleTitle, // <-- explicit, non-empty
          title: roleTitle, // used to group (optional)
          onPressed: null, // non-selectable

          headerName: roleTitle, // the *actual* role for this row

          isHeader: true,
        ),
      );
    }

    void addCreatedRMSelectableRow(
      List<CustomDropdownItem> items,
      String roleTitle,
    ) {
      final createdRm = lastAssignedRole?.createdRM;
      final createdLabel = (createdRm?.trim().isNotEmpty == true)
          ? "  $createdRm" // small indent for grouping
          : "  $createdRm"; // fallback (same as original)

      items.add(
        CustomDropdownItem(
          value: createdRm, // sent back to callback
          label: createdLabel, // label constructed exactly as before
          title: roleTitle, // group name

          headerName: roleTitle, // the *actual* role for this row

          onPressed: () {}, // selectable
          isHeader: false,
        ),
      );
    }

    void addUserSelectableRow(
      List<CustomDropdownItem> items, {
      required String roleTitle,
      required String roleCode,
      required String? id,
      required String? name,
    }) {
      items.add(
        CustomDropdownItem(
          value: id ?? "_", // null → '_' (safe fallback)
          label: "$name - $id",
          // (name?.trim().isNotEmpty == true)
          //     ? '  $name' // name is valid
          //     : '  ${id ?? '_'}', // fallback to id, and if id null → '_'
          title: roleTitle,
          roleCode: roleCode,
          headerName: roleTitle,
          onPressed: () {},
          isHeader: false,
        ),
      );
    }

    try {
      final String rolesReturn = await buildReturnWcasRolesForCurrentUser();

      final List<CustomDropdownItem> itemsReturn = [];

      if (rolesReturn.isEmpty) {
        if (lastAssignedRole != null) {
          //const roleTitle = 'App Initiator'; // lastAssignedRole?.roleRM ?? '—';
          // 1) HEADER ROW (non-selectable)
          addHeaderRow(
            itemsReturn,
            "ccsys.recommendationApproval.appInitiator".tr(),
          );

          // 2) createdRM under the header (selectable)
          addCreatedRMSelectableRow(
            itemsReturn,
            "ccsys.recommendationApproval.appInitiator".tr(),
          );
        } else {
          userListReturn = <CustomDropdownItem>[];
          emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
          AlertManager().showFailureToast(
            "ccsys.recommendationApproval.roleMappingNotFound".tr(),
          );
          // return;
        }
      }

      // 2) New grouped call that keeps bpmRoleName per group
      final List<Role> groupsReturn =
          await repositoryCcsys.getUsersByRoles(rolesReturn);
      groupsReturn; // (preserved no-op line)

      // Keep original behavior: if lastAssignedRole != null, add "App
      // Initiator" block
      if (lastAssignedRole != null) {
        //const roleTitle = 'App Initiator'; // lastAssignedRole?.roleRM ?? '—';
        // 1) HEADER ROW (non-selectable)
        addHeaderRow(
          itemsReturn,
          "ccsys.recommendationApproval.appInitiator".tr(),
        );

        // 2) createdRM under the header (selectable)
        addCreatedRMSelectableRow(
          itemsReturn,
          "ccsys.recommendationApproval.appInitiator".tr(),
        );
      }

      if (groupsReturn.isEmpty) {
        // Original code added the "App Initiator" block above when
        // lastAssignedRole != null.
        // No further changes here to preserve logic.
      }

      if (groupsReturn.isNotEmpty) {
        // PSEUDO: for each group returned by API
        for (final g in groupsReturn) {
          final String roleTitle = g.bpmRole ?? "—";
          final String roleCode = g.code ?? "—";

          // 1) HEADER ROW (non-selectable)
          addHeaderRow(itemsReturn, roleTitle);

          // 2) USERS UNDER THIS HEADER (selectable)
          for (final u in (g.users ?? [])) {
            addUserSelectableRow(
              itemsReturn,
              roleTitle: roleTitle,
              roleCode: roleCode,
              id: u.id,
              name: u.name,
            );
          }
        }

        usersReturn = groupsReturn.expand<User>((g) => g.users ?? []).toList();
      }

      userListReturn = itemsReturn;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      // AlertManager().showFailureToast(
      //     'Unable to load recommended users. ${e.toString()}');
    }
  }

  String commentsInitialValue() {
    if (comments.isEmpty) return "";

    final String currentRoleCode =
        (Globals.user?.currentRole?.code ?? "").toString();
    final String currentUserId = (Globals.user?.id ?? "").toString();

    final StringBuffer buffer = StringBuffer();

    for (final Comment commentSel in comments) {
      final bool isSameRole =
          commentSel.userRoleCode?.toString() == currentRoleCode;
      final bool isSameUser = commentSel.userId?.toString() == currentUserId;

      if (isSameRole && isSameUser) {
        final String text = (commentSel.comment ?? "").trim();
        if (text.isNotEmpty) {
          if (buffer.isNotEmpty) buffer.writeln();
          buffer.write(text);
        }
      }
    }

    return buffer.toString();
  }
}

extension IterableX<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T e) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
