import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/safe_cubit.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/repositories/approval_repository.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

/// ViewModel for managing the state and logic of the Management Comments screen.
///
/// This class handles initialization, form validation, and saving of various
/// management-level comments using the BLoC pattern for state management.
class ManagementCommentsViewModel extends SafeCubit<ManagementCommentsState> {
  /// Constructor initializes the state with a loading status.
  ManagementCommentsViewModel()
      : super(ManagementCommentsState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for handling request-related operations.
  late RequestRepository repository;

  late ApprovalRepository approvalRepository;

  /// Global key for validating the management comments form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Management comment fields

  /// Initial recommendation from the Credit Committee.
  String creditCommitteeRecommendations = '';

  /// Comments from the Chief Credit Officer (CCO).
  String ccoComments = '';

  /// Comments from the Chief Executive Officer (CEO).
  String ceoComments = '';

  /// Comments from the BCIC (Board Credit Investment Committee).
  String bcicComments = '';

  bool canSubmit = false;
  List<Comment> comments = [];
  bool isReadOnly = Globals.checkAccessbility()['isReadOnly'] ?? true;
  Map<String, bool> commentValidations = {}; // for global function value
  bool visibilityStatus = false; // check app status

  /// Initializes the ViewModel by setting up the repository and updating the loader status.
  ///
  /// Logs the initialization and sets the loader status to `loaded`.
  ///
  /// [context] - The build context used for localization and navigation.
  void init(context) async {
    logger.i('initialising ManagementCommentsViewModel');
    repository = RequestRepository.instance;
    approvalRepository = ApprovalRepository.instance;
    await getApplicationStrategyDetails();
    commentValidations =
        Globals.checkAccessbility(status: [RequestStatus.approved]);
    isReadOnly = commentValidations['isReadOnly'] ??
        true && commentValidations['status']!;
    await repository.getApplicationDetails();
    await approvalRepository.fetchReference();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onTextChange(String plainText, int type) async {
    if (type == 1) {
      creditCommitteeRecommendations = plainText;
    } else if (type == 2) {
      ccoComments = plainText;
    } else if (type == 3) {
      ceoComments = plainText;
    } else if (type == 4) {
      bcicComments = plainText;
    }
    canSubmit = creditCommitteeRecommendations.trim().isNotEmpty &&
        ccoComments.trim().isNotEmpty &&
        ceoComments.trim().isNotEmpty &&
        bcicComments.trim().isNotEmpty;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles the save button press logic for management comments.
  ///
  /// Validates the form, saves the input, and shows a success toast.
  /// Updates the loader status accordingly.
  Future<void> onSave() async {
    try {
      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();

        AlertManager().showSuccessToast(
          "approval.managementComments.savedSuccessfully".tr(),
        );
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  Future<void> onSavePress({
    required BuildContext context,
  }) async {
    try {
      if (creditCommitteeRecommendations.isEmpty ||
          ccoComments.isEmpty ||
          ceoComments.isEmpty ||
          bcicComments.isEmpty) {
        AlertManager().showFailureToast(
          'approval.groupSummary.pleaseEnterSummary'.tr(),
        );
        return;
      }

      List<Comment> comments;

      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();
        emit(state.copyWith(loaderStatus: LoadingStatus.loading));
        comments = [
          Comment.fromInputData(
            type: CommentsType.approval,
            categoryId: ServerConstants
                .approvalCategoryId[ApprovalCategory.creditCommittee],
            categoryType: ServerConstants
                .approvalCategoryType[ApprovalCategory.creditCommittee],
            strategyComment: creditCommitteeRecommendations,
          ),
          Comment.fromInputData(
            type: CommentsType.approval,
            categoryId:
                ServerConstants.approvalCategoryId[ApprovalCategory.ccoComment],
            categoryType: ServerConstants
                .approvalCategoryType[ApprovalCategory.ccoComment],
            strategyComment: ccoComments,
          ),
          Comment.fromInputData(
            type: CommentsType.approval,
            categoryId:
                ServerConstants.approvalCategoryId[ApprovalCategory.ceoComment],
            categoryType: ServerConstants
                .approvalCategoryType[ApprovalCategory.ceoComment],
            strategyComment: ceoComments,
          ),
          Comment.fromInputData(
            type: CommentsType.approval,
            categoryId: ServerConstants
                .approvalCategoryId[ApprovalCategory.bcicComment],
            categoryType: ServerConstants
                .approvalCategoryType[ApprovalCategory.bcicComment],
            strategyComment: bcicComments,
          ),
        ];

        // debugPrint(
        //     "Save Comment List : ${comments.map((ele) => ele.toStrategyJson().toString())}");

        await approvalRepository.saveApplicationStrategyDetails(
            ServerConstants.commentTypeId[CommentsType.managementComment],
            comments);
        AlertManager().showSuccessToast(
          "approval.groupSummary.savedSuccessfully".tr(),
        );
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

        if (context.mounted) {
          context.read<ManagementCommentsViewModel>().init(context);
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
        CommentsType.managementComment,
        EntityIdentifier.managementComment,
      );

      List<int?> categoryIds = [
        ServerConstants.approvalCategoryId[ApprovalCategory.creditCommittee],
        ServerConstants.approvalCategoryId[ApprovalCategory.groupOverview],
        ServerConstants.approvalCategoryId[ApprovalCategory.groupRisk],
        ServerConstants.approvalCategoryId[ApprovalCategory.groupStrategy],
      ];

      if (comments.isNotEmpty) {
        List<Comment> commentList = [];
        for (final com in comments) {
          if (com.createdBy == Globals.user?.id) {
            commentList.add(com);
          }
        }
        if (commentList.length >= 4) {
          creditCommitteeRecommendations = commentList[0].strategyComment ?? "";
          ccoComments = commentList[1].strategyComment ?? "";
          ceoComments = commentList[2].strategyComment ?? "";
          bcicComments = commentList[3].strategyComment ?? "";
          canSubmit = true;
        }
      }

      final commentItem = comments
          .where((item) => categoryIds.contains(item.categoryId))
          .toList();

      if (comments.isNotEmpty) {
        comments[0].strategyComment = commentItem.isNotEmpty
            ? commentItem.first.strategyComment
            : "comment item not matched";
      }

      logger.i('Strategy comment: $comments?[0].strategyComment');
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  // bool checkVisibility(RequestStatus requestStatus) {
  //   int? status = ServerConstants.requestStatusId[requestStatus];
  //   return (applicationDetails?.status != status);
  // }
}
