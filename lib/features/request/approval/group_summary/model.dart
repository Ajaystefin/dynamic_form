import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
// import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/approval/group_summary/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/group_summary/state.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// ViewModel for managing the state and logic of the Group Summary screen.
///
/// This class handles tab switching, form validation, saving comments,
/// and updating the UI state using the BLoC pattern.
class GroupSummaryViewModel extends SafeCubit<GroupSummaryState>
    with DraftMixin<GroupSummaryViewModel> {
  /// Constructor initializes the state with a loading status.
  GroupSummaryViewModel() : super(const GroupSummaryState());

  /// Repository instance for handling request-related operations.
  late RequestRepository repository;

  /// Controller for the HTML editor used to input group summary comments.
  UnifiedEditorController controller = UnifiedEditorController();

  /// Scroll controller used by the group summary screen.
  final ScrollController scrollController = ScrollController();

  /// Global key for validating the group summary form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // --- DRAFT IDENTITY ---

  /// Module key used for saving and loading approval draft data.
  @override
  String get draftModuleKey => DraftModuleKeys.approval;

  // Create a unique form key based on the route, customer string identifier,
  // and the active tab's name

  /// Form key used to uniquely identify the draft for the active tab.
  @override
  String get draftFormKey => "${Routes.groupSummary}_${state.activeTab.name}";

  /// Draft handler used to build and apply group summary draft data.
  @override
  DraftHandler<GroupSummaryViewModel> get draftHandler =>
      GroupSummaryTabsDraftHandler();

  // Comments

  /// List of comments loaded or saved for the selected group summary tab.
  List<Comment>? comments = [];

  /// Current comment model for the selected group summary tab.
  Comment? comment = Comment();

  /// Repository instance for handling approval-related operations.
  late ApprovalRepository approvalRepository;

  /// Selected approval category id for the active tab.
  int? categoryId =
      ServerConstants.approvalCategoryId[ApprovalCategory.groupOverview];

  /// Selected approval category type for the active tab.
  String? categoryType =
      ServerConstants.approvalCategoryType[ApprovalCategory.groupOverview];

  /// Application details loaded for the current request.
  ApplicationDetails? applicationDetails;

  /// Initial text loaded into the editor.
  String initialText = "";

  /// Indicates whether submit actions are allowed.
  bool canSubmit = false;

  /// Indicates whether the screen is in read-only mode.
  bool isReadOnly = false;

  /// Last assigned role information for the request.
  Role? assignedRole;

  /// Indicates whether the current request was initiated by the current user.
  bool isInitByUser = false;

  /// Indicates whether the current application is a risk rating application.
  bool isRiskRatingApp = false;

  /// Indicates whether the request was initiated by a credit analyst.
  bool isInitByCA = false;

  /// Indicates whether the request was initiated by CCOOD.
  bool isInitByCCOOD = false;

  /// User roles that can access group summary.
  List<int?> userRoleList = [
    // user role that can access group summary
    ServerConstants.userRoleId[UserRole.relationshipOfficer],
    ServerConstants.userRoleId[UserRole.relationshipManager],
    ServerConstants.userRoleId[UserRole.teamLeaderBusiness],
    ServerConstants.userRoleId[UserRole.commercialAreaManager],
    ServerConstants.userRoleId[UserRole.relationshipManagerBussiness],
    ServerConstants.userRoleId[UserRole.segmentHeadBusiness],
    ServerConstants.userRoleId[UserRole.businessUnitHead],
  ];

  /// Request statuses in which group summary can be edited.
  List<RequestStatus> requestStatus = [
    RequestStatus.initiated,
    RequestStatus.pendingForApproval,
  ];

  /// Initializes the ViewModel by setting up the repository and updating the
  /// loader status.
  ///
  /// Logs the initialization and sets the loader status to `loaded`.
  ///
  /// [context] - The build context used for localization and navigation.
  Future<void> init(BuildContext? context) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    logger.i("initialising GroupSummaryViewModel");
    repository = RequestRepository.instance;
    approvalRepository = ApprovalRepository.instance;
    applicationDetails = await repository.getApplicationDetails();
    await getApplicationStrategyDetails(categoryId);
    await approvalRepository.fetchReference();
    final String role = await checkIsInitiated();
    isInitByUser =
        (role == Globals.user?.currentRole?.code) && Globals.checkIsInitiated();
    isReadOnly = Utils.checkIfAppReadOnly() ||
        !userRoleList.contains(Globals.user?.currentRole?.roleId) ||
        !Globals.checkCurrentStatus(requestStatus);
    isInitByCA = (role == ServerConstants.userRoleCode[UserRole.creditAnalyst]);
    isInitByCCOOD =
        (role == ServerConstants.userRoleCode[UserRole.creditCordinator]);
    isRiskRatingApp = Globals.checkAppSubStatus(
      ServerConstants.applicationSubType[ApplicationSubType.riskRating] ?? "",
    );
    if (isRiskRatingApp &&
        (Utils.checkRoles([
          UserRole.creditAnalyst,
          UserRole.creditCordinator,
        ]))) {
      isReadOnly = Utils.checkIfAppReadOnly() ||
          !(isInitByCCOOD || isInitByCA) ||
          !Globals.checkCurrentStatus(requestStatus);
    }
    logger.i("isReadOnly : $isReadOnly");
    if (!isReadOnly) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles tab switching in the Group Summary screen.
  ///
  /// Emits a loading state, simulates a delay (e.g., for data fetching),
  /// and then updates the active tab and loader status.
  ///
  /// [tab] - The selected tab to switch to.
  Future<void> changeTab(GroupSummaryTabs tab) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    // Simulate API call or data loading
    await Future.delayed(const Duration(seconds: 1));
    categoryId = switch (tab) {
      GroupSummaryTabs.groupManagementTeam =>
        ServerConstants.approvalCategoryId[ApprovalCategory.groupManagement],
      GroupSummaryTabs.ownershipCorporateStructure =>
        ServerConstants.approvalCategoryId[ApprovalCategory.groupOverview],
      GroupSummaryTabs.relationshipFutureStrategy =>
        ServerConstants.approvalCategoryId[ApprovalCategory.groupStrategy],
      GroupSummaryTabs.successsionkeyManRisk =>
        ServerConstants.approvalCategoryId[ApprovalCategory.groupRisk],
    };
    categoryType = switch (tab) {
      GroupSummaryTabs.groupManagementTeam =>
        ServerConstants.approvalCategoryType[ApprovalCategory.groupManagement],
      GroupSummaryTabs.ownershipCorporateStructure =>
        ServerConstants.approvalCategoryType[ApprovalCategory.groupOverview],
      GroupSummaryTabs.relationshipFutureStrategy =>
        ServerConstants.approvalCategoryType[ApprovalCategory.groupStrategy],
      GroupSummaryTabs.successsionkeyManRisk =>
        ServerConstants.approvalCategoryType[ApprovalCategory.groupRisk],
    };
    await getApplicationStrategyDetails(categoryId);
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        activeTab: tab,
      ),
    );
    if (!isReadOnly) {
      await loadDraftIfAvailable();
    }
  }

  /// Checks and returns the role code that initiated the request.
  Future<String> checkIsInitiated() async {
    try {
      assignedRole = await approvalRepository.getLastAssignedRole();
      logger.i("role : ${assignedRole?.roleRM} ${assignedRole?.createdRM}");
      for (final Map<String, String> map in Globals.superUserRoles) {
        final entry = map.entries.firstWhere(
          (e) => e.value == assignedRole?.roleRM,
          orElse: () => const MapEntry("", ""),
        );
        if (entry.key.isNotEmpty) {
          return entry.key;
        }
      }
    } on Object catch (e) {
      logger.i("is $e");
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    return "";
  }

  //get active for label heading

  /// Returns the localized label for the given group summary tab.
  String getTabLabel(GroupSummaryTabs tab) {
    return TabConstants.groupSummaryTitles[tab]!.tr();
  }

  /// Handles the save button press logic.
  ///
  /// Validates the comments field, extracts plain text from the HTML editor,
  /// and shows appropriate success or failure toasts. Updates the loader status
  /// accordingly.
  ///
  /// [context] - The build context used for localization and toast display.
  Future<void> onSavePress({
    required bool isContinue,
    required BuildContext context,
  }) async {
    try {
      final String rawHtml = await controller.getText();
      if (Globals.request?.applicationSubType != ServerConstants.manualEntry) {
        if (rawHtml.isEmpty) {
          AlertManager().showFailureToast(
            "approval.groupSummary.pleaseEnterSummary".tr(),
          );
          return;
        }
      }

      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();
        // emit(state.copyWith(loaderStatus: LoadingStatus.loading));
        // saveComment(newComment);
        comments = [
          Comment.fromInputData(
            type: CommentsType.groupSummary,
            categoryId: categoryId,
            categoryType: categoryType,
            strategyComment: rawHtml,
          ),
        ];

        await approvalRepository.saveApplicationStrategyDetails(
          ServerConstants.commentTypeId[CommentsType.groupSummary],
          comments,
        );
        unawaited(deleteDraft());
        AlertManager().showSuccessToast(
          "approval.groupSummary.savedSuccessfully".tr(),
        );
        if (isContinue && context.mounted) {
          navigate(context);
        }

        // if (context.mounted) {
        //   await context.read<GroupSummaryViewModel>().init(context);
        // }
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Navigates to the next group summary tab or the next accessible route.
  void navigate(BuildContext context) {
    bool isCurrentRouteFound = false;
    for (final MapEntry<GroupSummaryTabs, String> entry
        in TabConstants.groupSumaryRoutes.entries) {
      if (isCurrentRouteFound) {
        // can move to next tab/route
        changeTab(entry.key);
        return;
      }
      if (entry.key == state.activeTab) {
        isCurrentRouteFound = true;
      }
    }
    LayoutViewModel().goToNextRouteAccess(context);
  }

  /// Gets application strategy details for the selected category.
  Future<void> getApplicationStrategyDetails(int? selectedCategory) async {
    try {
      comments = await approvalRepository.getApplicationStrategyDetails(
        CommentsType.groupSummary,
        EntityIdentifier.groupSummary,
      );

      comments = comments
          ?.where((item) => selectedCategory == item.categoryId)
          .toList();

      if (comments != null) {
        if (comments?.firstOrNull != null) {
          comment = comments?.first;
          initialText = comment?.strategyComment ?? "";
          controller.setText(initialText);
        } else {
          initialText = "";
          controller.setText("");
        }
      } else {
        initialText = "";
        controller.setText("");
      }
      // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      logger.i("Strategy comment: $comments?[0].strategyComment");
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }
}
