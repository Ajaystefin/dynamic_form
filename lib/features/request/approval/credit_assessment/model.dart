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
      : super(CreditAssessmentState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for handling request-related operations.
  late RequestRepository repository;

  /// Controller for the HTML editor used to input RM comments.
  UnifiedEditorController appraisalController = UnifiedEditorController();
  UnifiedEditorController briefController = UnifiedEditorController();
  final ScrollController scrollController = ScrollController();

  /// Global key for validating the RM comments form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // --- DRAFT IDENTITY ---
  @override
  String get draftModuleKey => DraftModuleKeys.approval;

  // Create a unique form key based on the route, customer string identifier,
  // and the active tab's name
  @override
  String get draftFormKey => Routes.creditAssessment;

  @override
  DraftHandler<CreditAssessmentViewModel> get draftHandler =>
      CreditAssessmentDraftHandler();

  late ApprovalRepository approvalRepository;
  Comment? comment;
  List<Comment>? comments = [];
  String creditBrief = "";
  String creditAppraisal = "";
  bool canSubmit = false;
  bool isReadOnly = false;
  bool isApproved = Globals.checkCurrentStatus([RequestStatus.approved]);
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
  Future<void> init(context) async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      logger.i("initialising CreditAssessmentViewModel");
      repository = RequestRepository.instance;
      approvalRepository = ApprovalRepository.instance;
      await getApplicationStrategyDetails();
      await repository.getApplicationDetails();
      final String route = GoRouterState.of(context).name ?? "";
      final bool hasAccess =
          Globals.checkMasterAccessibilityForRoute(route, forReadOnly: true);
      isReadOnly = Utils.checkIfAppReadOnly() ||
          (userRoleList.contains(Globals.user?.currentRole?.roleId) &&
              isApproved) ||
          !hasAccess;
      debugPrint("hasAccess : $route $hasAccess $isReadOnly");
      debugPrint("isReadOnly : $isReadOnly");
      await approvalRepository.fetchReference();
      if (!isReadOnly) {
        registerDraftCallback();
        await loadDraftIfAvailable();
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
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

      if (appraisalRawHtml.isEmpty || breifRawHtml.isEmpty) {
        AlertManager().showFailureToast(
          "approval.creditAssessment.pleaseEnterRemarks".tr(),
        );
        return;
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
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

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
        if (comments?.isNotEmpty == true) {
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
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }
}
