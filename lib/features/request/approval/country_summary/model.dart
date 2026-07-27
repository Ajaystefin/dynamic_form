import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
// import "package:flutter_bloc/flutter_bloc.dart";
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

/// ViewModel for managing the state and logic of the Group Summary screen.
///
/// This class handles tab switching, form validation, saving comments,
/// and updating the UI state using the BLoC pattern.
class CountrySummaryViewModel extends SafeCubit<CountrySummaryState>
    with DraftMixin<CountrySummaryViewModel> {
  /// Constructor initializes the state with a loading status.
  CountrySummaryViewModel() : super(const CountrySummaryState());

  /// Repository instance for handling request-related operations.
  late RequestRepository repository;

  /// Repository instance for handling approval-related operations.
  late ApprovalRepository approvalRepository;

  /// Controller for the HTML editor used to input group summary comments.
  UnifiedEditorController controller = UnifiedEditorController();

  /// Scroll controller used by the country summary screen.
  final ScrollController scrollController = ScrollController();

  /// Global key for validating the group summary form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// List of comments loaded or saved for the selected country summary tab.
  List<Comment>? comments = [];

  /// Current comment model for the selected country summary tab.
  Comment? comment = Comment();

  /// Indicates whether the screen is in read-only mode.
  bool isReadOnly = false;

  /// Initial text loaded into the editor.
  String initialText = "";

  /// Selected approval category id for the active tab.
  int? categoryId =
      ServerConstants.approvalCategoryId[ApprovalCategory.request];

  /// Selected approval category type for the active tab.
  String? categoryType =
      ServerConstants.approvalCategoryType[ApprovalCategory.request];

  /// Indicates whether the country summary is editable.
  bool isEditable = false;

  // --- DRAFT IDENTITY ---

  /// Module key used for saving and loading approval draft data.
  @override
  String get draftModuleKey => DraftModuleKeys.approval;

  // Create a unique form key based on the route, customer string
  // identifier, and the active tab's name

  /// Form key used to uniquely identify the draft for the active tab.
  @override
  String get draftFormKey => "${Routes.countrySummary}_${state.activeTab.name}";

  /// Draft handler used to build and apply country summary draft data.
  @override
  DraftHandler<CountrySummaryViewModel> get draftHandler =>
      CountrySummaryTabsDraftHandler();

  /// Initializes the ViewModel by setting up the
  /// repository and updating the loader status.
  ///
  /// Logs the initialization and sets the loader status to `loaded`.
  ///
  /// [context] - The build context used for localization and navigation.
  Future<void> init(BuildContext context) async {
    logger.i("initialising CountrySummaryViewModel");
    repository = RequestRepository.instance;
    approvalRepository = ApprovalRepository.instance;
    await repository.getApplicationDetails();
    await getApplicationStrategyDetails(categoryId);
    isReadOnly = Utils.checkIfAppReadOnly();
    if (!isReadOnly) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }
    // must be editable for country rim only
    isEditable = (Globals.applicationDetails?.customerType?.toLowerCase() ==
        CustomerType.country.name);

    /// if it is non editable handling it with [isReadOnly]
    isReadOnly = !isEditable || isReadOnly;
    logger.i("isEditable $isEditable $isReadOnly");
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles tab switching in the Group Summary screen.
  ///
  /// Emits a loading state, simulates a delay (e.g., for data fetching),
  /// and then updates the active tab and loader status.
  ///
  /// [tab] - The selected tab to switch to.
  Future<void> changeTab(CountrySummaryTabs tab) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    await Future.delayed(const Duration(seconds: 1));
    // Simulate API call or data loading
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
      await loadDraftIfAvailable();
    }
  }

  //get active for label heading

  /// Returns the localized label for the given country summary tab.
  String getTabLabel(CountrySummaryTabs tab) {
    return TabConstants.countrySummaryTitles[tab]!.tr();
  }

  /// Handles the save button press logic.
  ///
  /// Validates the comments field, extracts plain text from the HTML editor,
  /// and shows appropriate success or failure toasts.
  /// Updates the loader status accordingly.
  ///
  /// [context] - The build context used for localization and toast display.
  Future<void> onSavePress({
    required bool isContinue,
    required BuildContext context,
  }) async {
    try {
      final String rawHtml = await controller.getText();
      final String text = rawHtml
          .replaceAll(RegExp("<[^>]*>"), "")
          .replaceAll("&nbsp;", " ")
          .trim();
      if (text.isEmpty && isEditable) {
        AlertManager().showFailureToast(
          "approval.countrySummary.pleaseEnterSummary".tr(),
        );
        return;
      }
      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();
        // emit(state.copyWith(loaderStatus: LoadingStatus.loading));
        comments = [
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
        await deleteDraft();
        AlertManager().showSuccessToast(
          "approval.countrySummary.savedSuccessfully".tr(),
        );

        if (isContinue && context.mounted) {
          navigate(context);
        }
        // if (context.mounted) {
        //   await context.read<CountrySummaryViewModel>().init(context);
        // }
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Saves a new comment for the request for FOL flow.
  Future<void> saveComment(String newComment) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      comment = Comment.fromInputData(
        comment: newComment,
        type: CommentsType.requestForFOL,
        entityType: EntityIdentifier.requestForFOL,
        categoryId: ServerConstants.commentTypeId[CommentsType.requestForFOL],
      );

      await CommonRepository.instance.saveComment(comment!);
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Navigates to the next country summary tab or the next accessible route.
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
    LayoutViewModel().goToNextRouteAccess(context);
  }

  /// Gets application strategy details for the selected category.
  Future<void> getApplicationStrategyDetails(int? selectedCategory) async {
    try {
      comments = await approvalRepository.getApplicationStrategyDetails(
        CommentsType.countrySummary,
        EntityIdentifier.countrySummary,
      );

      comments = comments
          ?.where((item) => selectedCategory == item.categoryId)
          .toList();

      if (comments != null) {
        if (comments?.firstOrNull != null) {
          comment = comments?.first;
          initialText = comment?.strategyComment ?? "";
          controller.setText(initialText);
        } else {
          initialText = "";
          controller.setText("");
        }
      } else {
        initialText = "";
        controller.setText("");
      }

      // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      logger.i("Strategy comment: $comments?[0].strategyComment");
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }
}
