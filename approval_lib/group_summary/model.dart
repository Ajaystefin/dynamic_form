import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
// import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/safe_cubit.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/request/application_details.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/repositories/approval_repository.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';

import 'package:wcas_frontend/repositories/request_repository.dart';
import 'package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart';
import 'state.dart';

/// ViewModel for managing the state and logic of the Group Summary screen.
///
/// This class handles tab switching, form validation, saving comments,
/// and updating the UI state using the BLoC pattern.
class GroupSummaryViewModel extends SafeCubit<GroupSummaryState> {
  /// Constructor initializes the state with a loading status.
  GroupSummaryViewModel()
      : super(const GroupSummaryState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for handling request-related operations.
  late RequestRepository repository;

  /// Controller for the HTML editor used to input group summary comments.
  UnifiedEditorController controller = UnifiedEditorController();
  final ScrollController scrollController = ScrollController();

  /// Global key for validating the group summary form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Comments
  List<Comment>? comments = [];
  Comment? comment;

  late ApprovalRepository approvalRepository;
  int? categoryId;
  String? categoryType;
  ApplicationDetails? applicationDetails;
  String initialText = "";
  bool canSubmit = false;
  bool isReadOnly = true;
  List<int?> userRoleList = [
    // user role that can access group summary
    ServerConstants.userRoleId[UserRole.relationshipOfficer],
    ServerConstants.userRoleId[UserRole.relationshipManager],
    ServerConstants.userRoleId[UserRole.teamLeaderBusiness],
    ServerConstants.userRoleId[UserRole.commercialAreaManager],
    ServerConstants.userRoleId[UserRole.relationshipManagerBussiness],
    ServerConstants.userRoleId[UserRole.segmentHeadLevelB],
    ServerConstants.userRoleId[UserRole.businessUnitHead]
  ];

  /// Initializes the ViewModel by setting up the repository and updating the loader status.
  ///
  /// Logs the initialization and sets the loader status to `loaded`.
  ///
  /// [context] - The build context used for localization and navigation.
  void init(context) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    logger.i('initialising GroupSummaryViewModel');
    repository = RequestRepository.instance;
    approvalRepository = ApprovalRepository.instance;
    // initial value before switching tab
    categoryId =
        ServerConstants.approvalCategoryId[ApprovalCategory.groupOverview];
    categoryType =
        ServerConstants.approvalCategoryType[ApprovalCategory.groupOverview];
    applicationDetails = await repository.getApplicationDetails();
    await getApplicationStrategyDetails(categoryId);
    await approvalRepository.fetchReference();
    isReadOnly = Globals.isAllReadOnly ||
        !(userRoleList.contains(Globals.user?.currentRole?.roleId));
    // await getComments(categoryId, entityIdentifier);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles tab switching in the Group Summary screen.
  ///
  /// Emits a loading state, simulates a delay (e.g., for data fetching),
  /// and then updates the active tab and loader status.
  ///
  /// [tab] - The selected tab to switch to.
  void changeTab(GroupSummaryTabs tab) async {
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
    emit(state.copyWith(
      loaderStatus: LoadingStatus.loaded,
      activeTab: tab,
    ));
  }

  //get active for label heading
  String getTabLabel(GroupSummaryTabs tab) {
    return TabConstants.groupSummaryTitles[tab]!.tr();
  }

  void onTextChange(String text) async {
    final plainText = text
        .replaceAll(RegExp(r'<[^>]*>'), '') // remove HTML tags
        .replaceAll('&nbsp;', ' ') // handle non-breaking spaces
        .trim();
    canSubmit = plainText.trim().isNotEmpty;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles the save button press logic.
  ///
  /// Validates the comments field, extracts plain text from the HTML editor,
  /// and shows appropriate success or failure toasts. Updates the loader status accordingly.
  ///
  /// [context] - The build context used for localization and toast display.
  Future<void> onSavePress(
    bool isContinue, {
    required BuildContext context,
  }) async {
    try {
      final String rawHtml = await controller.getText();

      if (rawHtml.isEmpty) {
        AlertManager().showFailureToast(
          'approval.groupSummary.pleaseEnterSummary'.tr(),
        );
        return;
      }

      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();
        emit(state.copyWith(loaderStatus: LoadingStatus.loading));
        // saveComment(newComment);
        comments = [
          Comment.fromInputData(
            type: CommentsType.groupSummary,
            categoryId: categoryId,
            categoryType: categoryType,
            strategyComment: rawHtml,
          ),
        ];

        approvalRepository.saveApplicationStrategyDetails(
            ServerConstants.commentTypeId[CommentsType.groupSummary], comments);
        AlertManager().showSuccessToast(
          "approval.groupSummary.savedSuccessfully".tr(),
        );
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        if (isContinue && context.mounted) {
          navigate(context);
        }
        await getApplicationStrategyDetails(categoryId);
        applicationDetails = await repository.getApplicationDetails();
        // if (context.mounted) {
        //   context.read<GroupSummaryViewModel>().init(context);
        //   context.go(GoRouter.of(context).location);
        //   GoRouter.of(context).refresh();
        // }
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  Future<void> saveComment(String newComment) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      comment = Comment.fromInputData(
        comment: newComment,
        type: CommentsType.approval,
        entityType: EntityIdentifier.approval,
        categoryId: ServerConstants.commentTypeId[CommentsType.approval]!,
      );

      await CommonRepository.instance.saveComment(comment!);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void navigate(BuildContext context) {
    bool isCurrentRouteFound = false;
    for (MapEntry<GroupSummaryTabs, String> entry
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
    // LayoutViewModel().goToNextRoute();
    LayoutViewModel().goToNextRouteAccess(context);
  }

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
        List<Comment> commentList = [];
        for (final com in comments!) {
          if (com.createdBy == Globals.user?.id) {
            commentList.add(com);
          }
        }
        if (commentList.length > 1) {
          comment = commentList
              .reduce((a, b) => a.createdDate!.isAfter(b.createdDate!) ? a : b);
          initialText = comment?.strategyComment ?? "";
          controller.setText(initialText);
        }
        if (commentList.isNotEmpty) {
          comment = commentList.first;
          initialText = comment?.strategyComment ?? "";
          controller.setText(initialText);
        }
      }

      logger.i('Strategy comment: $comments?[0].strategyComment');
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  bool checkVisibility(RequestStatus requestStatus) {
    int? status = ServerConstants.requestStatusId[requestStatus];
    return (applicationDetails?.status != status);
  }
}
