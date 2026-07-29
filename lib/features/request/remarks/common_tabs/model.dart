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

/// View model for the Common Tabs screen.
class CommonTabsViewModel extends SafeCubit<CommonTabsState>
    with DraftMixin<CommonTabsViewModel> {
  /// Creates a Common Tabs view model.
  CommonTabsViewModel()
      : super(CommonTabsState(loaderStatus: LoadingStatus.loading));

  /// Repository for loading and saving remarks data.
  late RequestRepository repository;

  /// Rich text editor controller for remarks content.
  final UnifiedEditorController rteController = UnifiedEditorController();

  /// Scroll controller for the screen.
  final ScrollController scrollController = ScrollController();

  /// Form key used for validation and form state management.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Currently selected customer.
  Customer? selectedCustomer;

  /// Loaded comment data for the active tab.
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

  /// Remarks tabs that use dedicated screens instead of the common editor.
  List<RemarksTabs> otherRemarksTabs = [
    RemarksTabs.feeStructure,
    RemarksTabs.guarantorFinancials,
    RemarksTabs.financialRatiosAndAnalysis,
  ];

  /// Available customers for selection.
  List<Customer>? customerList = [];

  /// Returns the current request.
  Request get request {
    return Globals.request!;
  }

  /// Tabs that require mandatory indicators.
  List<RemarksTabs> showAsteriskTabs = [];

  /// Determines if the current active tab requires validation based on asterisk
  /// tabs
  bool get shouldValidateField => showAsteriskTabs.contains(state.activeTab);

  /// Current page mode.
  PageMode pageMode = PageMode.na;

  /// Indicates whether the page is in read-only mode.
  bool get isReadOnlyMode => pageMode == PageMode.view;

  /// Indicates whether the current flow is for Financial Institutions.
  bool isFI = false;

  /// Initializes the view model with optional tab parameter and loads initial
  /// data
  Future<void> init(BuildContext context, {RemarksTabs? tab}) async {
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

  /// Loads child RIMs for group applications and updates the
  /// selected customer.
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
    } on Object catch (e) {
      logger.i("Error fetching getChildRimsForGroup : $e");
      defaultSelectedCustomer();
      rethrow;
    }
  }

  /// Sets the default selected customer.

  void defaultSelectedCustomer() {
    final List<Customer> borrowers = Globals.request?.borrowers ?? [];
    final List<Customer> customers = Globals.request?.customers ?? [];

    if (borrowers.isNotEmpty) {
      selectedCustomer = borrowers.first;
    } else if (customers.isNotEmpty) {
      selectedCustomer = customers.first;
    } else if (Globals.request?.customerRimNo != null) {
      selectedCustomer = Customer(
        customerRimNo: Globals.request?.customerRimNo,
        customerName: Globals.request?.customerName,
        type: selectedCustomer?.type,
      );
    } else {
      selectedCustomer = null;
    }

    if (selectedCustomer != null) {
      customerList = [selectedCustomer!];
    }

    Globals.selectedCustomer = selectedCustomer;
  }

  /// Sets which tabs should display asterisks based on business segment and
  /// customer type
  void setAsterisks() {
    if (selectedCustomer == null) {
      showAsteriskTabs = [];
      return;
    }

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
    } on Object catch (e) {
      commentData = Comment();
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Changes the active tab and loads corresponding data or navigates to
  /// external routes
  Future<void> changeTab(RemarksTabs tab) async {
    if (otherRemarksTabs.contains(tab)) {
      setAsterisks();
      router.go(TabConstants.remarksRoutes[tab]!);
    } else {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading, activeTab: tab));
      await getRemarks();
      setAsterisks();

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

      if (Globals.request?.applicationSubType != ServerConstants.manualEntry &&
          shouldValidateField &&
          richText.isEmpty) {
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

      if (Globals.request?.applicationSubType == ServerConstants.manualEntry ||
          richText.isNotEmpty) {
        await repository.saveRemarkStrategyData(selectedCustomer, comment);

        unawaited(deleteDraft());
        if (richText.trim().isNotEmpty) {
          AlertManager().showSuccessToast(
            "common.commentSaveSuccess".tr(),
          );
        }
      }

      if (shouldNavigate) {
        navigate();
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    } finally {
      emit(state.copyWith(buttonLoaderStatus: LoadingStatus.loaded));
    }
  }

  /// Navigates to the next *visible* tab (filtered by customer/FI rules)
  /// in sequence, or to the next route if at the end
  void navigate() {
    // Filtering requires a customer; if none, just fall through to the next route.
    final Customer? currentCustomer = selectedCustomer;
    if (currentCustomer == null) {
      LayoutViewModel().goToNextRoute();
      return;
    }

    // Visibility rules (e.g. isFI) that hide certain tabs for non-FI customers.
    final Map<RemarksTabs, bool Function()> tabVisibilityRules =
        TabConstants.getRemarksRoutes(currentCustomer);

    // Keep remarksRoutes' original order, but drop tabs hidden for this customer.
    final List<RemarksTabs> orderedVisibleTabs =
        TabConstants.remarksRoutes.entries
            .where((entry) {
              // No rule => always visible; otherwise defer to the rule.
              final bool Function()? isVisible = tabVisibilityRules[entry.key];
              return isVisible == null || isVisible();
            })
            .map((entry) => entry.key)
            .toList();

    // Locate the current tab within the filtered/visible list.
    final int currentIndex = orderedVisibleTabs.indexOf(state.activeTab);
    if (currentIndex != -1 && currentIndex < orderedVisibleTabs.length - 1) {
      // Advance to the next visible tab.
      changeTab(orderedVisibleTabs[currentIndex + 1]);
      return;
    }
    // No next visible tab => hand off to the layout's next route.
    LayoutViewModel().goToNextRoute();
  }

  /// Only FI types should show the "View more / View less" affordance.
  /// Country (and other non-FI) show all chips without the toggle.
  bool get showViewMore =>
      selectedCustomer?.type == CustomerType.belowInvestmentGradeBanks ||
      selectedCustomer?.type == CustomerType.investmentGradeBanks;
}
