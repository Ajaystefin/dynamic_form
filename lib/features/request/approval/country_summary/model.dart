import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
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
import "package:wcas_frontend/features/request/approval/country_summary/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/country_summary/state.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// ViewModel for managing the state and logic of the Country Summary screen.
class CountrySummaryViewModel extends SafeCubit<CountrySummaryState>
    with DraftMixin<CountrySummaryViewModel> {
  CountrySummaryViewModel({
    RequestRepository? repository,
    ApprovalRepository? approvalRepository,
    CommonRepository? commonRepository,
    UnifiedEditorController? controller,
    AlertManager? alertManager,
    bool Function()? checkIfAppReadOnly,
    String? Function()? getCustomerType,
    void Function(BuildContext context)? goToNextRouteAccess,
    Duration? changeTabDelay,
  })  : repository = repository ?? RequestRepository.instance,
        approvalRepository = approvalRepository ?? ApprovalRepository.instance,
        commonRepository = commonRepository ?? CommonRepository.instance,
        controller = controller ?? UnifiedEditorController(),
        alertManager = alertManager ?? AlertManager(),
        checkIfAppReadOnly = checkIfAppReadOnly ?? Utils.checkIfAppReadOnly,
        getCustomerType =
            getCustomerType ?? (() => Globals.applicationDetails?.customerType),
        goToNextRouteAccess = goToNextRouteAccess ??
            ((context) => LayoutViewModel().goToNextRouteAccess(context)),
        changeTabDelay = changeTabDelay ?? const Duration(seconds: 1),
        super(
          const CountrySummaryState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

  final RequestRepository repository;
  final ApprovalRepository approvalRepository;
  final CommonRepository commonRepository;
  final UnifiedEditorController controller;
  final AlertManager alertManager;

  final bool Function() checkIfAppReadOnly;
  final String? Function() getCustomerType;
  final void Function(BuildContext context) goToNextRouteAccess;
  final Duration changeTabDelay;

  final ScrollController scrollController = ScrollController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<Comment> comments = [];
  Comment? comment = Comment();
  bool isReadOnly = false;
  String initialText = "";
  int? categoryId =
      ServerConstants.approvalCategoryId[ApprovalCategory.request];
  String? categoryType =
      ServerConstants.approvalCategoryType[ApprovalCategory.request];
  bool isEditable = false;

  @override
  String get draftModuleKey => DraftModuleKeys.approval;

  @override
  String get draftFormKey => "${Routes.countrySummary}_${state.activeTab.name}";

  @override
  DraftHandler<CountrySummaryViewModel> get draftHandler =>
      CountrySummaryTabsDraftHandler();

  /// Wrapped for easier testing.
  @visibleForTesting
  Future<void> doRegisterDraftCallback() async {
    registerDraftCallback();
  }

  /// Wrapped for easier testing.
  @visibleForTesting
  Future<void> doLoadDraftIfAvailable() async {
    await loadDraftIfAvailable();
  }

  /// Wrapped for easier testing.
  @visibleForTesting
  Future<void> doDeleteDraft() async {
    unawaited(deleteDraft());
  }

  /// Wrapped for easier testing.
  @visibleForTesting
  bool validateAndSaveForm() {
    final FormState? currentState = formKey.currentState;
    if (currentState?.validate() ?? false) {
      currentState!.save();
      return true;
    }
    return false;
  }

  /// Wrapped for easier testing.
  @visibleForTesting
  Future<void> refreshAfterSave(BuildContext context) async {
    await init(context);
  }

  /// Initializes the ViewModel.
  Future<void> init(BuildContext? context) async {
    logger.i("initialising CountrySummaryViewModel");

    await repository.getApplicationDetails();
    await getApplicationStrategyDetails(categoryId);

    isReadOnly = checkIfAppReadOnly();

    if (!isReadOnly) {
      await doRegisterDraftCallback();
      await doLoadDraftIfAvailable();
    }

    isEditable =
        (getCustomerType()?.toLowerCase() == CustomerType.country.name);

    isReadOnly = !isEditable;

    debugPrint("isEditable $isEditable $isReadOnly");
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
      ),
    );
  }

  /// Handles tab switching.
  Future<void> changeTab(CountrySummaryTabs tab) async {
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loading,
      ),
    );

    await Future.delayed(changeTabDelay);

    categoryId = switch (tab) {
      CountrySummaryTabs.request =>
        ServerConstants.approvalCategoryId[ApprovalCategory.request],
      CountrySummaryTabs.rational =>
        ServerConstants.approvalCategoryId[ApprovalCategory.rational],
      CountrySummaryTabs.summaryOfLatestDev =>
        ServerConstants.approvalCategoryId[ApprovalCategory.summaryOfLastDev],
      CountrySummaryTabs.bankingSector =>
        ServerConstants.approvalCategoryId[ApprovalCategory.bankingSector],
      CountrySummaryTabs.fiRecommend =>
        ServerConstants.approvalCategoryId[ApprovalCategory.fiRecommendation],
    };

    categoryType = switch (tab) {
      CountrySummaryTabs.request =>
        ServerConstants.approvalCategoryType[ApprovalCategory.request],
      CountrySummaryTabs.rational =>
        ServerConstants.approvalCategoryType[ApprovalCategory.rational],
      CountrySummaryTabs.summaryOfLatestDev =>
        ServerConstants.approvalCategoryType[ApprovalCategory.summaryOfLastDev],
      CountrySummaryTabs.bankingSector =>
        ServerConstants.approvalCategoryType[ApprovalCategory.bankingSector],
      CountrySummaryTabs.fiRecommend =>
        ServerConstants.approvalCategoryType[ApprovalCategory.fiRecommendation],
    };

    await getApplicationStrategyDetails(categoryId);

    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        activeTab: tab,
      ),
    );

    if (!isReadOnly) {
      await doLoadDraftIfAvailable();
    }
  }

  String getTabLabel(CountrySummaryTabs tab) {
    return TabConstants.countrySummaryTitles[tab]!.tr();
  }

  Future<void> onSavePress(
    bool isContinue, {
    required BuildContext context,
  }) async {
    try {
      final String rawHtml = await controller.getText();
      final String text = rawHtml
          .replaceAll(RegExp("<[^>]*>"), "")
          .replaceAll("&nbsp;", " ")
          .trim();

      if (text.isEmpty && isEditable) {
        alertManager.showFailureToast(
          "approval.countrySummary.pleaseEnterSummary".tr(),
        );
        return;
      }

      if (validateAndSaveForm()) {
        emit(
          state.copyWith(
            loaderStatus: LoadingStatus.loading,
          ),
        );

        comments = <Comment>[
          Comment.fromInputData(
            type: CommentsType.countrySummary,
            categoryId: categoryId,
            categoryType: categoryType,
            strategyComment: rawHtml,
          ),
        ];

        await approvalRepository.saveApplicationStrategyDetails(
          ServerConstants.commentTypeId[CommentsType.countrySummary],
          comments,
        );

        await doDeleteDraft();

        alertManager.showSuccessToast(
          "approval.countrySummary.savedSuccessfully".tr(),
        );

        if (!context.mounted) {
          emit(
            state.copyWith(
              loaderStatus: LoadingStatus.loaded,
            ),
          );
          return;
        }

        if (isContinue) {
          navigate(context);

          if (!context.mounted) {
            emit(
              state.copyWith(
                loaderStatus: LoadingStatus.loaded,
              ),
            );
            return;
          }
        }

        await refreshAfterSave(context);

        emit(
          state.copyWith(
            loaderStatus: LoadingStatus.loaded,
          ),
        );
      }
    } catch (e) {
      alertManager.showFailureToast(e.toString());
      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.error,
        ),
      );
    }
  }

  Future<void> saveComment(String newComment) async {
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loading,
      ),
    );

    try {
      comment = Comment.fromInputData(
        comment: newComment,
        type: CommentsType.requestForFOL,
        entityType: EntityIdentifier.requestForFOL,
        categoryId: ServerConstants.commentTypeId[CommentsType.requestForFOL],
      );

      await commonRepository.saveComment(comment!);
    } catch (e) {
      alertManager.showFailureToast(e.toString());
    }

    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
      ),
    );
  }

  void navigate(BuildContext context) {
    bool isCurrentRouteFound = false;

    for (final MapEntry<CountrySummaryTabs, String> entry
        in TabConstants.countrySumaryRoutes.entries) {
      if (isCurrentRouteFound) {
        changeTab(entry.key);
        return;
      }

      if (entry.key == state.activeTab) {
        isCurrentRouteFound = true;
      }
    }

    goToNextRouteAccess(context);
  }

  Future<void> getApplicationStrategyDetails(int? selectedCategory) async {
    try {
      final List<Comment> fetchedComments =
          await approvalRepository.getApplicationStrategyDetails(
        CommentsType.countrySummary,
        EntityIdentifier.countrySummary,
      );

      comments = fetchedComments
          .where((Comment item) => selectedCategory == item.categoryId)
          .toList();

      if (comments.isNotEmpty) {
        comment = comments.first;
        initialText = comment?.strategyComment ?? "";
        controller.setText(initialText);
      } else {
        comment = null;
        initialText = "";
        controller.setText("");
      }

      logger.i("Strategy comment count: ${comments.length}");
    } catch (e) {
      alertManager.showFailureToast(e.toString());
    }
  }
}
