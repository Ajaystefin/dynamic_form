import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
// import 'package:flutter_bloc/flutter_bloc.dart';
import "package:go_router/go_router.dart";
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
import "package:wcas_frontend/features/request/approval/credit_assessment/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment/state.dart";
import "package:wcas_frontend/features/request/approval/utils/approval_utils.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// ViewModel for managing the state and logic of the Credit Assessment screen.
///
/// This class handles initialization, form validation, saving remarks,
/// and navigation to the next screen. It uses BLoC for state management.
class CreditAssessmentViewModel extends SafeCubit<CreditAssessmentState>
    with DraftMixin<CreditAssessmentViewModel> {
  /// Constructor initializes the state with a loading status.
  CreditAssessmentViewModel()
      : super(const CreditAssessmentState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for handling request-related operations.
  late RequestRepository repository;

  /// Controller for the HTML editor used to input RM comments.
  UnifiedEditorController appraisalController = UnifiedEditorController();

  /// Controller for the HTML editor used to input credit brief comments.
  UnifiedEditorController briefController = UnifiedEditorController();

  /// Scroll controller used by the credit assessment screen.
  final ScrollController scrollController = ScrollController();

  /// Global key for validating the RM comments form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // --- DRAFT IDENTITY ---

  /// Module key used for saving and loading approval draft data.
  @override
  String get draftModuleKey => DraftModuleKeys.approval;

  // Create a unique form key based on the route, customer string identifier,
  // and the active tab's name

  /// Form key used to uniquely identify the credit assessment draft.
  @override
  String get draftFormKey => Routes.creditAssessment;

  /// Draft handler used to build and apply credit assessment draft data.
  @override
  DraftHandler<CreditAssessmentViewModel> get draftHandler =>
      CreditAssessmentDraftHandler();

  /// Repository instance for handling approval-related operations.
  late ApprovalRepository approvalRepository;

  /// Current comment model used by the credit assessment screen.
  Comment? comment;

  /// List of comments loaded or saved for credit assessment.
  List<Comment>? comments = [];

  /// Credit brief content loaded into or saved from the editor.
  String creditBrief = "";

  /// Credit appraisal content loaded into or saved from the editor.
  String creditAppraisal = "";

  /// Indicates whether submit actions are allowed.
  bool canSubmit = false;

  /// Indicates whether the screen is in read-only mode.
  bool isReadOnly = false;

  /// Current route name used for accessibility checks.
  String route = "";

  /// Indicates whether the current request status is approved.
  bool isApproved = Globals.checkCurrentStatus([RequestStatus.approved]);

  /// User roles that can edit group exposure or credit brief summary.
  List<int?> userRoleList = [
    // user role that can edit group exposure/credit brief summary
    ServerConstants.userRoleId[UserRole.creditAnalyst],
    ServerConstants.userRoleId[UserRole.teamLeaderCreditLevelD1],
    ServerConstants.userRoleId[UserRole.segmentHeadLevelB],
    ServerConstants.userRoleId[UserRole.segmentHeadCreditLevelD],
    ServerConstants.userRoleId[UserRole.segmentHeadLevelC],
    ServerConstants.userRoleId[UserRole.segmentHeadLevelB1],
    ServerConstants.userRoleId[UserRole.creditCommitteeProxy],
    ServerConstants.userRoleId[UserRole.boardDirectorProxy],
    ServerConstants.userRoleId[UserRole.creditCommitteeProxyApprover],
    ServerConstants.userRoleId[UserRole.boardDirectorProxyApproval],
  ];

  /// Initializes the ViewModel by setting up the repository and updating the
  /// loader status.
  ///
  /// Logs the initialization and sets the loader status to `loaded`.
  ///
  /// [context] - The build context used for localization and navigation.
  Future<void> init(BuildContext context) async {
    // final String route = GoRouterState.of(context).name ?? "";
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      logger.i("initialising CreditAssessmentViewModel");
      repository = RequestRepository.instance;
      approvalRepository = ApprovalRepository.instance;
      await getApplicationStrategyDetails();
      await repository.getApplicationDetails();
      if (context.mounted) {
        route = GoRouterState.of(context).name ?? "";
      }
      final bool hasAccess = ApprovalUtils.checkMasterAccessibilityForRoute(
        route,
        forReadOnly: true,
      );
      isReadOnly = Utils.checkIfAppReadOnly() ||
          (userRoleList.contains(Globals.user?.currentRole?.roleId) &&
              isApproved) ||
          !hasAccess;
      logger..i("hasAccess : $route $hasAccess $isReadOnly")
      ..i("isReadOnly : $isReadOnly");
      await approvalRepository.fetchReference();
      if (!isReadOnly) {
        registerDraftCallback();
        await loadDraftIfAvailable();
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      logger.e("Error Fetching : $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Handles the save button press logic.
  ///
  /// Validates the RM comments field, extracts plain text from the HTML editor,
  /// and shows appropriate success or failure toasts. If `isContinue` is true,
  /// navigates to the proposed facilities screen.
  ///
  /// [isContinue] - Whether to navigate to the next screen after saving.
  /// [context] - The build context used for navigation and localization.
  Future<void> onSavePress({
    required BuildContext context,
    bool isContinue = false,
  }) async {
    try {
      final String appraisalRawHtml = await appraisalController.getText();
      final String breifRawHtml = await briefController.getText();
      if (Globals.request?.applicationSubType != ServerConstants.manualEntry) {
        if (appraisalRawHtml.isEmpty || breifRawHtml.isEmpty) {
          AlertManager().showFailureToast(
            "approval.creditAssessment.pleaseEnterRemarks".tr(),
          );
          return;
        }
      }
      List<Comment> comments = [];

      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();
        emit(state.copyWith(loaderStatus: LoadingStatus.loading));
        comments = [
          Comment.fromInputData(
            type: CommentsType.creditBrief,
            categoryId: ServerConstants
                .approvalCategoryId[ApprovalCategory.creditBreif],
            categoryType: ServerConstants
                .approvalCategoryType[ApprovalCategory.creditBreif],
            strategyComment: breifRawHtml,
          ),
          Comment.fromInputData(
            type: CommentsType.creditAppraisal,
            categoryId: ServerConstants
                .approvalCategoryId[ApprovalCategory.creditAppraisal],
            categoryType: ServerConstants
                .approvalCategoryType[ApprovalCategory.creditAppraisal],
            strategyComment: appraisalRawHtml,
          ),
        ];

        await approvalRepository.saveApplicationStrategyDetails(
          ServerConstants.commentTypeId[CommentsType.creditAppraisal],
          comments,
        );
        unawaited(deleteDraft());
        AlertManager().showSuccessToast(
          "approval.creditAssessment.savedSuccessfully".tr(),
        );

        if (isContinue && context.mounted) {
          LayoutViewModel().goToNextRouteAccess(context);
        }

        // if (context.mounted) {
        //   context.read<CreditAssessmentViewModel>().init(context);
        // }
        await getApplicationStrategyDetails();
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Gets application strategy details for credit assessment comments.
  Future<void> getApplicationStrategyDetails() async {
    try {
      comments = await approvalRepository.getApplicationStrategyDetails(
        CommentsType.creditAppraisal,
        EntityIdentifier.creditAssesment,
      );
      if (comments != null && comments!.isNotEmpty) {
        final List<Comment>? commentItem = comments
            ?.where(
              (item) => [
                ServerConstants
                    .approvalCategoryId[ApprovalCategory.creditAppraisal],
                ServerConstants
                    .approvalCategoryId[ApprovalCategory.creditBreif],
              ].contains(item.categoryId),
            )
            .toList();
        if (comments?.firstOrNull != null) {
          comments?.first.strategyComment =
              commentItem != null && commentItem.isNotEmpty
                  ? commentItem.first.strategyComment
                  : "commentitem not matched";
        }
      }

      if (comments != null) {
        if (comments?.isNotEmpty ?? false) {
          for (final Comment com in comments!) {
            if (com.categoryId ==
                ServerConstants
                    .approvalCategoryId[ApprovalCategory.creditAppraisal]) {
              creditAppraisal = com.strategyComment ?? "";
              appraisalController.setText(creditAppraisal);
            }
            if (com.categoryId ==
                ServerConstants
                    .approvalCategoryId[ApprovalCategory.creditBreif]) {
              creditBrief = com.strategyComment ?? "";
              briefController.setText(creditBrief);
            }
          }
        }
      }
      // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      logger.i("Strategy comment: $comments?[0].strategyComment");
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }
}
