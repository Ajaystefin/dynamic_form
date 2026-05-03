import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
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
import "package:wcas_frontend/features/request/approval/credit_assessment_fi/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment_fi/state.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// ViewModel for managing the state and logic of the Credit Assessment screen.
///
/// This class handles initialization, form validation, saving remarks,
/// and navigation to the next screen. It uses BLoC for state management.
class CreditAssessmentFIViewModel extends SafeCubit<CreditAssessmentFIState>
    with DraftMixin<CreditAssessmentFIViewModel> {
  /// Constructor initializes the state with a loading status.
  CreditAssessmentFIViewModel()
      : super(CreditAssessmentFIState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for handling request-related operations.
  late RequestRepository repository;

  /// Controller for the HTML editor used to input RM comments.
  UnifiedEditorController controller = UnifiedEditorController();
  final ScrollController scrollController = ScrollController();
  Map<int, UnifiedEditorController> rimController = {};

  /// Global key for validating the RM comments form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // --- DRAFT IDENTITY ---
  @override
  String get draftModuleKey => DraftModuleKeys.approval;

  // Create a unique form key based on the route, customer string identifier,
  // and the active tab's name
  @override
  String get draftFormKey => Routes.creditAssessmentFI;

  @override
  DraftHandler<CreditAssessmentFIViewModel> get draftHandler =>
      CreditAssessmentFIDraftHandler();

  late ApprovalRepository approvalRepository;
  Comment? comment;
  List<Comment>? comments = [];
  List<Customer> rims = [];
  bool canSubmit = false;
  bool isReadOnly = true;
  bool isApproved = Globals.checkCurrentStatus([RequestStatus.approved]);
  int rimNo = 0;
  Map<int, String> initialTextMap = {};

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
      rims = Globals.applicationDetails?.borrowers
              ?.where(
                (cust) =>
                    (cust.type == CustomerType.belowInvestmentGradeBanks) ||
                    (cust.type == CustomerType.investmentGradeBanks),
              )
              .toList() ??
          [];
      isReadOnly = Utils.checkIfAppReadOnly();
      for (final Customer rim in rims) {
        rimController[rim.customerRimNo ?? 0] = UnifiedEditorController();
      }
      await getApplicationStrategyDetails();
      await repository.getApplicationDetails();
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
      final List<Comment> comments = [];
      for (final Customer rim in rims) {
        final UnifiedEditorController controller =
            rimController[rim.customerRimNo]!;
        final String rawHtml = await controller.getText();
        final String text = rawHtml
            .replaceAll(RegExp("<[^>]*>"), "")
            .replaceAll("&nbsp;", " ")
            .trim();

        if (text.isEmpty) {
          AlertManager().showFailureToast(
            "approval.creditAssessment.pleaseEnterRemarks".tr(),
          );
          return;
        }

        comments.add(
          Comment.fromInputData(
            type: CommentsType.creditAppraisal,
            categoryId: ServerConstants
                .approvalCategoryId[ApprovalCategory.creditAppraisal],
            categoryType: ServerConstants
                .approvalCategoryType[ApprovalCategory.creditAppraisal],
            strategyComment: rawHtml,
            rimNo: rim.customerRimNo,
          ),
        );
      }

      await approvalRepository.saveApplicationStrategyDetails(
        ServerConstants.commentTypeId[CommentsType.creditAppraisal],
        comments,
      );
      unawaited(deleteDraft());
      AlertManager().showSuccessToast(
        "approval.creditAssessment.savedSuccessfully".tr(),
      );
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

      if (isContinue && context.mounted) {
        // LayoutViewModel().goToNextRoute();
        LayoutViewModel().goToNextRouteAccess(context);
      }

      if (context.mounted) {
        await context.read<CreditAssessmentFIViewModel>().init(context);
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> getApplicationStrategyDetails() async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
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
          for (final Comment comment in comments!) {
            final int rimNo = comment.rimNo ?? 0;
            final UnifiedEditorController? controller = rimController[rimNo];
            if (controller != null) {
              debugPrint("strategyComment : ${comment.strategyComment}");
              initialTextMap[rimNo] = comment.strategyComment ?? "";
              rimController[rimNo]?.setText(comment.strategyComment ?? "");
              controller.setText(comment.strategyComment ?? "");
            }
          }
        }
      }

      logger.i("Strategy comment: $comments?[0].strategyComment");
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}
