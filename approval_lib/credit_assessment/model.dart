import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/safe_cubit.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/repositories/approval_repository.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';
import 'package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart';
import 'state.dart';

/// ViewModel for managing the state and logic of the Credit Assessment screen.
///
/// This class handles initialization, form validation, saving remarks,
/// and navigation to the next screen. It uses BLoC for state management.
class CreditAssessmentViewModel extends SafeCubit<CreditAssessmentState> {
  /// Constructor initializes the state with a loading status.
  CreditAssessmentViewModel()
      : super(CreditAssessmentState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for handling request-related operations.
  late RequestRepository repository;

  /// Controller for the HTML editor used to input RM comments.
  UnifiedEditorController controller1 = UnifiedEditorController();
  UnifiedEditorController controller2 = UnifiedEditorController();
  final ScrollController scrollController = ScrollController();

  /// Global key for validating the RM comments form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late ApprovalRepository approvalRepository;
  Comment? comment;
  List<Comment>? comments = [];
  String creditBrief = "";
  String creditAppraisal = "";
  bool canSubmit = false;
  bool isReadOnly = Globals.checkAccessbility()['isReadOnly'] ?? true;
  bool isApproved = Globals.checkCurrentStatus([RequestStatus.approved]);
  bool isCommentVisible = false;

  /// Initializes the ViewModel by setting up the repository and updating the loader status.
  ///
  /// Logs the initialization and sets the loader status to `loaded`.
  ///
  /// [context] - The build context used for localization and navigation.
  Future<void> init(context) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    logger.i('initialising CreditAssessmentViewModel');
    repository = RequestRepository.instance;
    approvalRepository = ApprovalRepository.instance;
    await getApplicationStrategyDetails();
    await repository.getApplicationDetails();
    debugPrint("isReadOnly : $isReadOnly");
    await approvalRepository.fetchReference();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
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
    bool isContinue = false,
    required BuildContext context,
  }) async {
    try {
      final String rawHtml1 = await controller1.getText();

      String rawHtml2 = "";
      if (isApproved) {
        rawHtml2 = await controller2.getText();
      }

      if (rawHtml1.isEmpty) {
        AlertManager().showFailureToast(
          'approval.creditAssessment.pleaseEnterRemarks'.tr(),
        );
        return;
      }

      if (isApproved && rawHtml2.isEmpty) {
        AlertManager().showFailureToast(
          'approval.creditAssessment.pleaseEnterRemarks'.tr(),
        );
        return;
      }

      List<Comment> comments = [];

      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();
        emit(state.copyWith(loaderStatus: LoadingStatus.loading));
        debugPrint("Save function");
        if (isApproved) {
          comments = [
            Comment.fromInputData(
                type: CommentsType.creditBrief,
                categoryId: ServerConstants
                    .approvalCategoryId[ApprovalCategory.creditBreif],
                categoryType: ServerConstants
                    .approvalCategoryType[ApprovalCategory.creditBreif],
                strategyComment: rawHtml2),
          ];
        } else {
          comments = [
            Comment.fromInputData(
                type: CommentsType.creditAppraisal,
                categoryId: ServerConstants
                    .approvalCategoryId[ApprovalCategory.creditAppraisal],
                categoryType: ServerConstants
                    .approvalCategoryType[ApprovalCategory.creditAppraisal],
                strategyComment: rawHtml1),
          ];
        }

        approvalRepository.saveApplicationStrategyDetails(
            ServerConstants.commentTypeId[CommentsType.creditAppraisal],
            comments);

        AlertManager().showSuccessToast(
          "approval.creditAssessment.savedSuccessfully".tr(),
        );
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

        if (isContinue && context.mounted) {
          // LayoutViewModel().goToNextRoute();
          LayoutViewModel().goToNextRouteAccess(context);
        }

        await repository.getApplicationDetails();

        if (context.mounted) {
          GoRouter.of(context).refresh();
          context.read<CreditAssessmentViewModel>().init(context);
          context.go(GoRouter.of(context).location);
        }
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  Future<void> getApplicationStrategyDetails() async {
    try {
      comments = await approvalRepository.getApplicationStrategyDetails(
        CommentsType.creditAppraisal,
        EntityIdentifier.creditAssesment,
      );
      if (comments != null && comments!.isNotEmpty) {
        final commentItem = comments
            ?.where((item) =>
                item.categoryId ==
                ServerConstants
                    .approvalCategoryId[ApprovalCategory.creditAppraisal])
            .toList();
        if (comments?.firstOrNull != null) {
          comments?.first.strategyComment =
              commentItem != null && commentItem.isNotEmpty
                  ? commentItem.first.strategyComment
                  : "commentitem not matched";
        }
      }

      if (comments != null) {
        List<Comment> commentList = [];
        if (comments?.length == 1) {
          isCommentVisible = comments?.first.userId != Globals.user?.id &&
              comments?.first.userRole != Globals.user?.currentRole?.roleId;
          debugPrint("isCommentVisible : $isCommentVisible");
        } else {
          isCommentVisible = true;
        }
        // new comparision with roleId
        for (final com in comments!) {
          if (com.createdBy == Globals.user?.id &&
              com.userRole == Globals.user?.currentRole?.roleId) {
            commentList.add(com);
          }
        }
        if (commentList.firstOrNull != null) {
          controller1.setText(commentList.first.strategyComment ?? '');
          creditAppraisal = commentList.first.strategyComment ?? '';
          controller2.setText(commentList.last.strategyComment ?? '');
          creditBrief = commentList.last.strategyComment ?? '';
        }
      }

      logger.i('Strategy comment: $comments?[0].strategyComment');
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  String getPlainText(rawHtml) {
    return rawHtml
        .replaceAll(RegExp(r'<[^>]*>'), '') // remove HTML tags
        .replaceAll('&nbsp;', ' ') // handle non-breaking spaces
        .trim();
  }

  // bool checkVisibility(RequestStatus requestStatus) {
  //   int? status = ServerConstants.requestStatusId[requestStatus];
  //   return (applicationDetails?.status != status);
  // }
}
