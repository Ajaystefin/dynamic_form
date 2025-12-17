import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/models/request/profitability/share_of_wallet.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';
import 'package:wcas_frontend/repositories/profitability_repository.dart';
import 'state.dart';

/// A ViewModel that manages the state and operations related to "Share Of Wallet".
///
/// This ViewModel interacts with the [ProfitabilityRepository] to retrieve ShareOfWallet data,
/// handle form validation, and manage comment saving operations. It emits different states
/// based on the loading, success, or error conditions.
class ShareOfWalletViewModel extends Cubit<ShareOfWalletState> {
  ShareOfWalletViewModel()
      : super(ShareOfWalletState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for interacting with profitability-related backend APIs.
  late ProfitabilityRepository repository;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Local variable to store the list of ShareOfWallet records.
  List<ShareOfWallet> shareOfWalletList = [];

  // Comments
  List<Comment> comments = [];
  Comment? comment;

  // Field to store RM Comments.
  String? rmComments;

  /// Initializes the ViewModel.
  ///
  /// This method sets up the repository instance, logs the initialization process,
  /// and fetches the Share Of Wallet data.
  ///
  /// [context] The build context for UI-related operations.
  Future<void> init(context) async {
    logger.i('initialising ShareOfWalletViewModel');
    repository = ProfitabilityRepository.instance;

    getShareOfWallet();
    await getApplicationStrategyDetails();
  }

  /// Fetches the Share Of Wallet data from the repository.
  ///
  /// This method attempts to retrieve the data via a POST API call. On a successful
  /// response, the [shareOfWalletList] is updated and the state is emitted as loaded.
  /// In case of an error, a failure toast is shown, the error is logged,
  /// and the state is updated to error.
  Future<void> getShareOfWallet() async {
    try {
      shareOfWalletList = (await repository.getShareOfWallet());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      logger.e('Error details: $e');
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Validates the form  the form using [formKey], saves state, and calls api from
  /// repository[repository.saveComments] to persist the comment text to the backend.
  ///
  /// On success, updates state to LoadingStatus.loaded and shows a success toast.
  /// On failure, updates state to LoadingStatus.error and shows a failure toast.
  /// [comments] The comment text to be saved.
  Future<void> onSaveAndContinue(BuildContext context) async {
    try {
      if (formKey.currentState?.validate() ?? true) {
        formKey.currentState?.save();
        String? rmComment = rmComments?.trim();
        if (rmComment != null && rmComment.isNotEmpty) {
          await saveComment(rmComment);
        }
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (error) {
      logger.e('Error details: $error');
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// repository[repository.saveComments] to persist the comment text to the backend.
  /// On success, updates state to LoadingStatus.loaded and shows a success toast.
  /// On failure, updates state to LoadingStatus.error and shows a failure toast.
  /// [comments] The comment text to be saved.
  Future<void> saveComment(String? walletComment) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      if (walletComment == null) {
        throw Exception();
      }
      comment ??= Comment();
      comment = Comment.fromInputData(
          strategyComment: walletComment,
          type: CommentsType.shareWallet,
          entityType: EntityIdentifier.shareWallet,
          categoryId: ServerConstants.shareWalletCommentCategoryId,
          categoryType: ServerConstants.shareWalletCommentCategoryType);
      String? responseMessage = await CommonRepository.instance
          .saveApplicationStrategyDetails(
              ServerConstants.commentTypeId[CommentsType.shareWallet]!,
              ServerConstants.commentTypeId[CommentsType.shareWallet]!,
              comment!);
      AlertManager().showSuccessToast(responseMessage!);
      LayoutViewModel().goToNextRoute();
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> getApplicationStrategyDetails() async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      final commentList = await CommonRepository.instance
          .getApplicationStrategyDetails(
              CommentsType.shareWallet, EntityIdentifier.shareWallet);

      final relevantComments = commentList
          .where((item) =>
              item.categoryId == ServerConstants.shareWalletCommentCategoryId)
          .toList();

      commentList[0].strategyComment = relevantComments.isNotEmpty
          ? relevantComments.first.strategyComment
          : "";
      rmComments = commentList[0].strategyComment!;
    } catch (e) {
      logger.e('Error fetching strategy details: $e');
      // AlertManager().showFailureToast(
      //   '$e',
      // );
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }
}
