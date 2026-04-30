import "package:flutter/material.dart";
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
import "package:wcas_frontend/features/request/profitability_account_conduct/account_stats/draft_handler.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/account_stats/state.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/profitability/account_stat.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/profitability_repository.dart";

class AccountStatsViewModel extends SafeCubit<AccountStatsState>
    with DraftMixin<AccountStatsViewModel> {
  AccountStatsViewModel()
      : super(AccountStatsState(loaderStatus: LoadingStatus.loading));
  ProfitabilityRepository? repository = ProfitabilityRepository();

  Map<Customer, List<AccountStat>> customerWiseAccountStat = {};
  String? comment;
  Comment? commentData;
  bool isEdit =
      Globals.user?.currentRole?.rights?[RightConstants.businessVolume] ==
          AccessType.edit;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.profitabilityAndAccountConduct;

  @override
  String get draftFormKey => Routes.accountStats;

  @override
  DraftHandler<AccountStatsViewModel> get draftHandler =>
      AccountStatsDraftHandler();

  PageMode pageMode = PageMode.na;
  bool get canEdit => (pageMode == PageMode.edit);

  /// Initializes the AccountStatsViewModel.
  ///
  /// This function sets up the repository, logs the initialization
  /// process, retrieves account statistics, and updates the loader status.
  ///
  /// [context] - The BuildContext, if needed for additional initialization
  /// steps.
  ///
  /// Throws:
  /// - If `getAccountStats` encounters an issue, it may affect
  ///   data retrieval and state updates.
  Future<void> init(context) async {
    logger.i("initialising AccountStatsViewModel");
    pageMode = AuthRepository.getPageMode(RightConstants.accountStats);
    await getAccountStats();
    await getApplicationStrategyDetails();
    if (canEdit) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Retrieves Account Stats data from the repository and updates state on
  /// failure.
  ///
  /// - Calls `repository.getAccountStats()` and assigns the result to
  /// `customerWiseAccountStat`.
  /// - On any exception, emits a state with `loaderStatus:
  /// LoadingStatus.error`.
  Future<void> getAccountStats() async {
    try {
      customerWiseAccountStat = await repository!.getAccountStats();
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Saves the comment for Account Stats and optionally navigates to the next
  /// screen.
  ///
  /// Behavior:
  /// - Toggles loading state on either the **Save** or **Continue** button
  /// based on [isContinue].
  /// - Builds a [Comment] using `Comment.fromInputData` with
  /// `CommentsType.accountStats`.
  /// - Persists via `CommonRepository.saveApplicationStrategyDetails`.
  /// - Shows success toast on completion and navigates forward if [isContinue]
  /// is `true`.
  ///
  /// Error handling:
  /// - Resets the corresponding button loading state.
  /// - Shows a failure toast with the error message.
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

      final String? response =
          await CommonRepository.instance.saveApplicationStrategyDetails(
        ServerConstants.commentTypeId[CommentsType.accountStats]!,
        ServerConstants.commentTypeId[CommentsType.accountStats]!,
        commentData,
      );

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

  /// Loads previously saved application strategy details for Account Stats.
  ///
  /// Flow:
  /// - Emits `LoadingStatus.loading`.
  /// - Fetches strategy comments via
  /// `CommonRepository.getApplicationStrategyDetails`
  ///   with `CommentsType.accountStats` and `EntityIdentifier.accountStats`.
  /// - Filters by `ServerConstants.accountStatsCommentCategoryId` and
  ///   assigns the `strategyComment` to local `comment`.
  ///
  /// Error handling:
  /// - Logs the error and emits `LoadingStatus.error`.
  Future<void> getApplicationStrategyDetails() async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      final commentList =
          await CommonRepository.instance.getApplicationStrategyDetails(
        CommentsType.accountStats,
        EntityIdentifier.accountStats,
      );

      if (commentList.isNotEmpty) {
        final relevantComments = commentList
            .where(
              (item) =>
                  item.categoryId ==
                  ServerConstants.accountStatsCommentCategoryId,
            )
            .toList();

        commentList[0].strategyComment = relevantComments.isNotEmpty
            ? relevantComments.first.strategyComment
            : "";
        comment = commentList[0].strategyComment;
      } else {
        comment = "";
      }
    } catch (e) {
      logger.e("Error fetching strategy details: $e");
      // AlertManager().showFailureToast(
      //   '$e',
      // );
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }
}
