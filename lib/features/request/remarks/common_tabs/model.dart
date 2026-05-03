import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/remarks/common_tabs/draft_handler.dart";
import "package:wcas_frontend/features/request/remarks/common_tabs/state.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class CommonTabsViewModel extends SafeCubit<CommonTabsState>
    with DraftMixin<CommonTabsViewModel> {
  /// Constructor that initializes the view model with a loading state
  CommonTabsViewModel()
      : super(CommonTabsState(loaderStatus: LoadingStatus.loading));
  late RequestRepository repository;
  final UnifiedEditorController rteController = UnifiedEditorController();
  final ScrollController scrollController = ScrollController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Customer? selectedCustomer;
  Comment? commentData = Comment();

  // --- DRAFT IDENTITY ---
  @override
  String get draftModuleKey => DraftModuleKeys.remarks;

  // Create a unique form key based on the route, customer string identifier,
  // and the active tab's name
  @override
  String get draftFormKey => "${Routes.remarksCommonTabs}_"
      "${selectedCustomer?.customerRimNo}_${state.activeTab.name}";

  @override
  DraftHandler<CommonTabsViewModel> get draftHandler =>
      CommonTabsDraftHandler();
  // ----------------------

  List<RemarksTabs> otherRemarksTabs = [
    RemarksTabs.feeStructure,
    RemarksTabs.guarantorFinancials,
    RemarksTabs.financialRatiosAndAnalysis,
  ];

  List<Customer>? customerList = [];

  /// Getter that returns the current global request instance
  Request get request {
    return Globals.request!;
  }

  List<RemarksTabs> showAsteriskTabs = [];

  /// Determines if the current active tab requires validation based on asterisk
  /// tabs
  bool get shouldValidateField => showAsteriskTabs.contains(state.activeTab);

  PageMode pageMode = PageMode.na;

  bool get isReadOnlyMode => pageMode == PageMode.view;

  bool isFI = false;

  /// Initializes the view model with optional tab parameter and loads initial
  /// data
  Future<void> init(context, {RemarksTabs? tab}) async {
    logger.i("initialising CommonTabsViewModel");
    pageMode = AuthRepository.getPageMode(RightConstants.remarksCommentary);

    if (tab != null) {
      emit(state.copyWith(activeTab: tab));
    }
    repository = RequestRepository.instance;
    defaultSelectedCustomer();
    await getChildRimsForGroup();
    setAsterisks();
    await getRemarks();

    // Register active tab draft autosave
    if (!isReadOnlyMode) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }

//get child rim list for rim dropdown
  Future<void> getChildRimsForGroup() async {
    try {
      if (Utils.isGroupApplication()) {
        customerList =
            await CustomerRepository.instance.getChildRimsForGroup() ?? [];
        if ((customerList ?? []).isNotEmpty) {
          selectedCustomer = customerList?.first;
        } else {
          defaultSelectedCustomer();
        }
      } else {
        defaultSelectedCustomer();
      }
    } catch (e) {
      logger.i("Error fetching getChildRimsForGroup : $e");
      defaultSelectedCustomer();
      rethrow;
    }
  }

  void defaultSelectedCustomer() {
    selectedCustomer = ((Globals.request?.borrowers ?? []).isNotEmpty)
        ? Globals.request?.borrowers?.first
        : Globals.request?.customers?.first;
  }

  /// Sets which tabs should display asterisks based on business segment and
  /// customer type
  void setAsterisks() {
    showAsteriskTabs = Utils.getMandatoryRemarksTabs(selectedCustomer);
  }

  /// Fetches remarks data for the selected customer and active tab from the
  /// repository
  Future<void> getRemarks() async {
    try {
      commentData = await repository.getRemarkStrategyData(
            selectedCustomer,
            ServerConstants.commentTypeId[CommentsType.remarks],
            ServerConstants.remarksTabId[state.activeTab],
          ) ??
          Comment();
    } catch (e) {
      commentData = Comment();
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Changes the active tab and loads corresponding data or navigates to
  /// external routes
  Future<void> changeTab(RemarksTabs tab) async {
    if (otherRemarksTabs.contains(tab)) {
      router.go(TabConstants.remarksRoutes[tab]!);
    } else {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading, activeTab: tab));
      await getRemarks();

      // Ensure the drafted data of the newly selected tab overrides live data
      // fetched
      // We don't need to manually invoke saveDraft() before changing tabs
      // because tab_menu.dart triggers the
      // global saving callback automatically prior to passing navigation here.
      if (!isReadOnlyMode) {
        await loadDraftIfAvailable();
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Handles customer selection change by updating selected customer and
  /// reloading data
  Future<void> onChangeCustomer(Customer customer) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    // global saving callback automatically prior to passing navigation here.
    unawaited(Globals.onAutoSave?.call());
    selectedCustomer = customer;
    Globals.selectedCustomer = customer;
    setAsterisks();
    await getRemarks();
    // Ensure the drafted data of the newly selected customer overrides live
    // data fetched

    if (!isReadOnlyMode) {
      await loadDraftIfAvailable();
    }
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
      ),
    );
  }

  /// Saves the comment data to the repository with validation and optional
  /// navigation
  Future<void> onSavePress({
    required BuildContext context,
    bool shouldNavigate = false,
  }) async {
    try {
      final String richText = await rteController.getText();

      if (shouldValidateField && richText.isEmpty) {
        AlertManager().showFailureToast(
          "common.validation.pleaseEnter".tr() + "common.comment".tr(),
        );
        return;
      }

      emit(
        state.copyWith(
          buttonLoaderStatus: LoadingStatus.loading,
          shouldNavigate: shouldNavigate,
        ),
      );
      final Comment comment = Comment.fromInputData(
        strategyComment: richText,
        categoryType: state.activeTab.name,
        type: CommentsType.remarks,
        entityType: EntityIdentifier.remarks,
        categoryId: ServerConstants.remarksTabId[state.activeTab],
        rimNo: selectedCustomer?.customerRimNo,
      );
      if (richText.isNotEmpty) {
        await repository.saveRemarkStrategyData(selectedCustomer, comment);

        // Remove draft once user explicitly saves the validated data
        unawaited(deleteDraft());

        AlertManager().showSuccessToast("common.commentSaveSuccess".tr());
      }
      if (shouldNavigate) {
        navigate();
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    } finally {
      emit(state.copyWith(buttonLoaderStatus: LoadingStatus.loaded));
    }
  }

  /// Navigates to the next tab in sequence or to the next route if at the end
  void navigate() {
    bool isCurrentRouteFound = false;
    for (final MapEntry<RemarksTabs, String> entry
        in TabConstants.remarksRoutes.entries) {
      if (isCurrentRouteFound) {
        // can move to next tab/route
        changeTab(entry.key);
        return;
      }
      if (entry.key == state.activeTab) {
        isCurrentRouteFound = true;
      }
    }
    LayoutViewModel().goToNextRoute();
  }

  /// Only FI types should show the "View more / View less" affordance.
  /// Country (and other non-FI) show all chips without the toggle.
  bool get showViewMore =>
      selectedCustomer?.type == CustomerType.belowInvestmentGradeBanks ||
      selectedCustomer?.type == CustomerType.investmentGradeBanks;
}
