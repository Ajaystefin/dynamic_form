import "dart:async";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/share_of_wallet/draft_handler.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/share_of_wallet/state.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/profitability/share_of_wallet.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/profitability_repository.dart";

/// A ViewModel that manages the state and operations related to "Share Of
/// Wallet".
///
/// This ViewModel interacts with the [ProfitabilityRepository] to retrieve
/// ShareOfWallet data,
/// handle form validation, and manage comment saving operations. It emits
/// different states
/// based on the loading, success, or error conditions.
class ShareOfWalletViewModel extends SafeCubit<ShareOfWalletState>
    with DraftMixin<ShareOfWalletViewModel> {
  ShareOfWalletViewModel()
      : super(ShareOfWalletState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for interacting with profitability-related backend
  /// APIs.
  late ProfitabilityRepository repository;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Local variable to store the list of ShareOfWallet records.
  List<ShareOfWallet> shareOfWalletList = [];

  // Comments
  List<Comment> comments = [];
  Comment? comment;

  // Field to store RM Comments.
  String? rmComments;

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------
//Autosave implementation by extended team
  @override
  String get draftModuleKey => DraftModuleKeys.profitabilityAndAccountConduct;

  @override
  String get draftFormKey => Routes.shareOfWalletView;

  @override
  DraftHandler<ShareOfWalletViewModel> get draftHandler =>
      ShareOfWalletDraftHandler();

  // ---------------------------------------------------------------------------
  PageMode pageMode = PageMode.na;
  bool get canEdit => (pageMode == PageMode.edit);

  /// Initializes the ViewModel.
  ///
  /// This method sets up the repository instance, logs the initialization
  /// process,
  /// and fetches the Share Of Wallet data.
  ///
  /// [context] The build context for UI-related operations.

  Future<void> init(context) async {
    logger.i("initialising ShareOfWalletViewModel");
    pageMode = AuthRepository.getPageMode(RightConstants.shareOfWallet);
    repository = ProfitabilityRepository.instance;

    try {
      await Future.wait([getShareOfWallet(), getApplicationStrategyDetails()]);
    } catch (e) {
      if (e.toString().isNotEmpty) {
        AlertManager().showFailureToast(e.toString());
      }
    }
    //Autosave implementation by extended team
    if (canEdit) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Fetches the Share Of Wallet data from the repository.
  ///
  /// This method attempts to retrieve the data via a POST API call. On a
  /// successful
  /// response, the [shareOfWalletList] is updated and the state is emitted as
  /// loaded.
  /// In case of an error, a failure toast is shown, the error is logged,
  /// and the state is updated to error.
  Future<void> getShareOfWallet() async {
    try {
      shareOfWalletList = (await repository.getShareOfWallet());
    } catch (e) {
      rethrow;
    }
  }

  /// Validates the form  the form using [formKey], saves state, and calls api
  /// from
  /// repository[repository.saveComments] to persist the comment text to the
  /// backend.
  ///
  /// On success, updates state to LoadingStatus.loaded and shows a success
  /// toast.
  /// On failure, updates state to LoadingStatus.error and shows a failure
  /// toast.
  /// [comments] The comment text to be saved.
  Future<void> onSaveAndContinue(BuildContext context) async {
    try {
      if (formKey.currentState?.validate() ?? true) {
        formKey.currentState?.save();
        final String? rmComment = rmComments?.trim();
        await saveComment(rmComment);
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (error) {
      logger.e("Error details: $error");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// repository[repository.saveComments] to persist the comment text to the
  /// backend.
  /// On success, updates state to LoadingStatus.loaded and shows a success
  /// toast.
  /// On failure, updates state to LoadingStatus.error and shows a failure
  /// toast.
  /// [comments] The comment text to be saved.
  Future<void> saveComment(String? walletComment) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      comment ??= Comment();
      comment = Comment.fromInputData(
        strategyComment: walletComment,
        type: CommentsType.shareWallet,
        entityType: EntityIdentifier.shareWallet,
        categoryId: ServerConstants.shareWalletCommentCategoryId,
        categoryType: ServerConstants.shareWalletCommentCategoryType,
      );
      final String? responseMessage =
          await CommonRepository.instance.saveApplicationStrategyDetails(
        ServerConstants.commentTypeId[CommentsType.shareWallet]!,
        ServerConstants.commentTypeId[CommentsType.shareWallet]!,
        comment,
      );
      //Autosave implementation by extended team
      unawaited(
        deleteDraft(),
      ); // fire-and-forget: remove backend draft now that data is saved
      AlertManager().showSuccessToast(responseMessage!);
      LayoutViewModel().goToNextRoute();
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Loads Share Wallet application strategy details and updates local RM
  /// comments.
  ///
  /// Flow:
  /// - Emits `LoadingStatus.loading` to indicate fetch in progress.
  /// - Retrieves the full comment list via
  ///   `CommonRepository.getApplicationStrategyDetails` using
  ///   `CommentsType.shareWallet` and `EntityIdentifier.shareWallet`.
  /// - Filters comments by `ServerConstants.shareWalletCommentCategoryId`.
  /// - Assigns the first relevant `strategyComment` (or empty string if none)
  /// to
  ///   `commentList[0].strategyComment`, and updates local `rmComments`.
  ///
  /// Error handling:
  /// - Logs the error with `logger.e`.
  /// - Emits `LoadingStatus.error` on failure

  Future<void> getApplicationStrategyDetails() async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      final List<Comment> commentList =
          await CommonRepository.instance.getApplicationStrategyDetails(
        CommentsType.shareWallet,
        EntityIdentifier.shareWallet,
      );
      if (commentList.isNotEmpty) {
        final List<Comment> relevantComments = commentList
            .where(
              (item) =>
                  item.categoryId ==
                  ServerConstants.shareWalletCommentCategoryId,
            )
            .toList();

        commentList[0].strategyComment = relevantComments.isNotEmpty
            ? relevantComments.first.strategyComment
            : "";
        rmComments = commentList[0].strategyComment;
      } else {
        rmComments = "";
      }
    } catch (e) {
      logger.e("Error fetching strategy details: $e");
    }
  }

  //Autosave implementation by extended team
  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }
}
