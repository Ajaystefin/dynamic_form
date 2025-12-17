import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';
import 'package:wcas_frontend/repositories/profitability_repository.dart';

import '../../../../core/utils/logger.dart';
import '../../../../core/utils/utils.dart';
import '../../../../models/request/customer.dart';
import '../../../../models/request/profitability/account_stat.dart';
import 'state.dart';

class AccountStatsViewModel extends Cubit<AccountStatsState> {
  AccountStatsViewModel()
      : super(AccountStatsState(loaderStatus: LoadingStatus.loading));
  ProfitabilityRepository? repository = ProfitabilityRepository();

  Map<Customer, List<AccountStat>> customerWiseAccountStat = {};
  String? comment;
  Comment? commentData;

  /// Initializes the AccountStatsViewModel.
  ///
  /// This function sets up the repository, logs the initialization
  /// process, retrieves account statistics, and updates the loader status.
  ///
  /// [context] - The BuildContext, if needed for additional initialization steps.
  ///
  /// Throws:
  /// - If `getAccountStats` encounters an issue, it may affect
  ///   data retrieval and state updates.
  Future<void> init(context) async {
    logger.i('initialising AccountStatsViewModel');
    await getAccountStats();
    await getApplicationStrategyDetails();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

// The getAccountStats function is an asynchronous method responsible for retrieving Account stats data from a repository.
// It handles potential errors gracefully and updates the application state accordingly.
  Future<void> getAccountStats() async {
    try {
      customerWiseAccountStat = await repository!.getAccountStats();
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// to save comment data
  Future<void> saveComments({bool isContinue = false}) async {
    try {
      isContinue
          ? emit(state.copyWith(continueButtonLoading: LoadingStatus.loading))
          : emit(state.copyWith(saveButtonLoading: LoadingStatus.loading));

      commentData = Comment.fromInputData(
        type: CommentsType.accountStats,
        strategyComment: comment,
        entityType: EntityIdentifier.accountStats,
        categoryId: ServerConstants.accountStatsCommentCategoryId,
        categoryType: ServerConstants.accountStatsCommentCategoryType,
      );

      String? response = await CommonRepository.instance
          .saveApplicationStrategyDetails(
              ServerConstants.commentTypeId[CommentsType.accountStats]!,
              ServerConstants.commentTypeId[CommentsType.accountStats]!,
              commentData);
      isContinue
          ? emit(state.copyWith(continueButtonLoading: LoadingStatus.loaded))
          : emit(state.copyWith(saveButtonLoading: LoadingStatus.loaded));
      AlertManager().showSuccessToast(response!);
      if (isContinue) {
        LayoutViewModel().goToNextRoute();
        // router.goNamed(Routes.accountConduct);
      }
    } catch (e) {
      isContinue
          ? emit(state.copyWith(continueButtonLoading: LoadingStatus.loaded))
          : emit(state.copyWith(saveButtonLoading: LoadingStatus.loaded));
      AlertManager().showFailureToast(e.toString());
    }
  }

  Future<void> getApplicationStrategyDetails() async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      final commentList = await CommonRepository.instance
          .getApplicationStrategyDetails(
              CommentsType.accountStats, EntityIdentifier.accountStats);

      final relevantComments = commentList
          .where((item) =>
              item.categoryId == ServerConstants.accountStatsCommentCategoryId)
          .toList();

      commentList[0].strategyComment = relevantComments.isNotEmpty
          ? relevantComments.first.strategyComment
          : "";
      comment = commentList[0].strategyComment;
    } catch (e) {
      logger.e('Error fetching strategy details: $e');
      // AlertManager().showFailureToast(
      //   '$e',
      // );
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }
}
