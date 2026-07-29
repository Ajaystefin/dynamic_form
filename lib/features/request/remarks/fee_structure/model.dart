import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/remarks/fee_structure/draft_handler.dart";
import "package:wcas_frontend/features/request/remarks/fee_structure/state.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/remarks/fee_structure.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// ViewModel for the **Remarks → Fee Structure** screen.
///
/// Responsibilities:
/// - Loads fee structure rows for the selected customer (RIM)
/// - Ensures mandatory/default fee rows always exist
/// - Manages input controllers for amount/comments
/// - Saves data and clears drafts on successful save
/// - On **Save & Continue**, navigates to:
///   - Next visible Remarks tab (FI case), OR
///   - Certification screen (Corporate/non-FI last-tab case)
class FeeStructureViewModel extends SafeCubit<FeeStructureState>
    with DraftMixin<FeeStructureViewModel> {
  /// Creates a Fee Structure view model.
  FeeStructureViewModel()
      : super(
          FeeStructureState(
            loaderStatus: LoadingStatus.loaded,
          ),
        );

  /// Repository for fetching and saving fee structure data.
  RequestRepository repository = RequestRepository.instance;

  /// Form key for validating and saving the fee structure form.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Tracks whether a fee amount should be displayed as 'N/A'.
  final Map<String, bool> _showNaForId = {};

  /// Currently selected customer.
  Customer? selectedCustomer;

  /// Raw fee rows fetched from the API.
  List<FeeStructure> feeRows = [];

  /// Controllers for amount fields in the table.
  List<TextEditingController> amountControllers = [];

  /// Controllers for comments fields in the table.
  List<TextEditingController> commentsControllers = [];

  /// Shortcut to global request object.
  Request get request => Globals.request!;

  /// Tabs that require mandatory indicators.
  List<RemarksTabs> showAsteriskTabs = [];

  /// Current page mode.
  PageMode pageMode = PageMode.na;

  /// Indicates whether the page is in read-only mode.
  bool get isReadOnlyMode => pageMode == PageMode.view;

  /// List of mandatory fee types.
  List<String> defaultFeeTypes = <String>[
    "remarks.feeStructure.arrangementFee".tr(),
    "remarks.feeStructure.processingFee".tr(),
    "remarks.feeStructure.commitmentFee".tr(),
    "remarks.feeStructure.prePaymentFee".tr(),
    "remarks.feeStructure.breachOfCovenant".tr(),
  ];

  /// Customer list for dropdown (group application can have child rims).
  List<Customer>? customerList = [];

  /// Default rows derived from [defaultFeeTypes], ensuring each type exists.
  ///
  /// - If a default fee type is missing from [feeRows], it is added as a new row.
  /// - Returned list is always in the same order as [defaultFeeTypes]
  List<FeeStructure> get defaultRows {
    for (final String feeType in defaultFeeTypes) {
      if (!feeRows.any((row) => row.feeType == feeType)) {
        feeRows.add(
          FeeStructure(
            id: "default_$feeType ",
            isNew: true,
            feeType: feeType,
          ),
        );
      }
    }

    final Map<String, FeeStructure> existingByType = {
      for (final FeeStructure row in feeRows) row.feeType: row,
    };
    return defaultFeeTypes.map<FeeStructure>((String type) {
      final FeeStructure row = existingByType[type]!..isNew = false;
      return row;
    }).toList();
  }

  /// Returns non-default fee rows.
  List<FeeStructure> get extraRows =>
      feeRows.where((row) => !defaultFeeTypes.contains(row.feeType)).toList();

  /// Returns all fee rows (default + extra).
  List<FeeStructure> get combinedRows => [...defaultRows, ...extraRows];

  /// Indicates whether the current flow is for Financial Institutions.
  bool isFI = false;

  /// Indicates whether the page is in edit mode.
  bool get isEdit => pageMode == PageMode.edit;

  @override
  String get draftModuleKey => DraftModuleKeys
      .remarks; // Backend category (adjust if you have a specific one)
  @override
  String get draftFormKey => Routes.feeStructure; // This screen's route key
  @override
  DraftHandler<FeeStructureViewModel> get draftHandler =>
      FeeStructureDraftHandler();

  /// Initialization
  /// Loads:
  /// - page mode
  /// - selected customer (default or group child rim)
  /// - mandatory asterisk tabs
  /// - fee structure data and controllers
  /// - draft (only in edit mode)
  Future<void> init(BuildContext context) async {
    pageMode = AuthRepository.getPageMode(RightConstants.remarksCommentary);
    isFI = Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

    defaultSelectedCustomer();
    await getChildRimsForGroup();

    await setAsterisks();
    await getFeeStructureData();
    if (isEdit) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }

    emit(state.copyWith(tableLoader: LoadingStatus.loaded));
  }

  /// Loads child rims for group applications and sets [selectedCustomer].
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
    } on Object {
      defaultSelectedCustomer();
      rethrow;
    }
  }

  /// Selects a default customer from borrowers or customers list.
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
      );
    } else {
      selectedCustomer = null;
    }

    if (selectedCustomer != null) {
      customerList = [selectedCustomer!];
    }

    Globals.selectedCustomer = selectedCustomer;
  }

  /// Called when user changes customer from dropdown.
  ///
  /// Reloads:
  /// - mandatory asterisk tabs
  /// - fee structure data
  /// - draft (if edit mode)
  Future<void> onCustomerChanged(Customer customer) async {
    emit(state.copyWith(tableLoader: LoadingStatus.loading));
    selectedCustomer = customer;
    Globals.selectedCustomer = customer;

    await setAsterisks();
    await getFeeStructureData();

    if (isEdit) {
      await loadDraftIfAvailable();
    }

    emit(state.copyWith(tableLoader: LoadingStatus.loaded));
  }

  /// Fetches fee structure rows from backend and initializes controllers.
  ///
  /// This method:
  /// - populates [feeRows]
  /// - builds [combinedRows]
  /// - creates controllers for each row aligned by index
  /// - determines which rows should be treated as "N/A"
  Future<void> getFeeStructureData() async {
    emit(state.copyWith(tableLoader: LoadingStatus.loading));
    try {
      feeRows = await repository.getFeeStructureData(
        selectedCustomer?.customerRimNo,
      );

      final List<FeeStructure> rows = combinedRows;

      amountControllers.clear();
      commentsControllers.clear();

      for (final FeeStructure row in rows) {
        final String rawAmountText = (row.amountRaw ?? "").trim();

        // also treat textual zero as N/A
        final bool isNa = (rawAmountText.toUpperCase() == "N/A");

        _showNaForId[row.id] = isNa;

        String amountText;
        if (isNa) {
          amountText = "";
        } else if (rawAmountText.isNotEmpty) {
          amountText = rawAmountText;
        } else if (row.amount != null) {
          amountText = rawAmountText;
        } else {
          amountText = "";
        }

        amountControllers.add(TextEditingController(text: amountText));
        commentsControllers.add(TextEditingController(text: row.comments));
      }

      emit(state.copyWith(tableLoader: LoadingStatus.loaded));
    } on Object {
      feeRows = [];
      emit(state.copyWith(tableLoader: LoadingStatus.error));
    }
  }

  /// Updates the backing model when user edits an amount field.
  ///
  /// Supports:
  /// - Empty => clears amount/amountRaw
  /// - "N/A" => stores amountRaw "N/A" and amount 0.0
  /// - Numeric => stores exact raw text, and parses to double only if safe length
  void onAmountFieldChanged(int index, String input) {
    final FeeStructure row = combinedRows[index];
    final String raw = input.trim();

    if (raw.isEmpty) {
      row
        ..amountRaw = null
        ..amount = null; // small numbers also wiped
      _showNaForId[row.id] = false;
      return;
    }

    if (raw.toUpperCase() == "N/A") {
      row
        ..amountRaw = "N/A"
        ..amount = 0;
      _showNaForId[row.id] = true;
      return;
    }

    // Preserve EXACT value
    row.amountRaw = raw;
    final bool safeLength = raw.replaceAll(".", "").length <= 16;
    row.amount = safeLength ? double.tryParse(raw) : null;

    _showNaForId[row.id] = false;
  }

  /// Adds a new custom fee row and initializes empty controllers for it.
  void addRow() {
    emit(state.copyWith(tableLoader: LoadingStatus.loading));
    final String newId = DateTime.now().millisecondsSinceEpoch.toString();
    final FeeStructure newRow =
        FeeStructure(id: newId, isNew: true, feeType: "");
    feeRows.add(newRow);
    amountControllers.add(TextEditingController());
    commentsControllers.add(TextEditingController());
    emit(state.copyWith(tableLoader: LoadingStatus.loaded));
  }

  /// Deletes a row locally and (if persisted) deletes it in backend too.
  Future<void> deleteRow(FeeStructure data) async {
    emit(state.copyWith(tableLoader: LoadingStatus.loading));
    try {
      final int index = combinedRows.indexWhere((r) => r.id == data.id);
      if (index != -1) {
        feeRows.remove(data);
        amountControllers.removeAt(index);
        commentsControllers.removeAt(index);
      }

      if (!data.isNew) {
        final String response = await repository.deleteFeeStructureData(data);
        await getFeeStructureData();
        AlertManager().showSuccessToast(response);
      }

      emit(state.copyWith(tableLoader: LoadingStatus.loaded));
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(tableLoader: LoadingStatus.error));
    }
  }

  /// Saves fee structure rows and optionally navigates forward.
  ///
  /// If [isContinue] is true:
  /// - navigates to next visible remarks tab (FI),
  /// - otherwise navigates to Certification when Fee Structure is last.
  Future<void> onSavePress(
    BuildContext context, {
    required bool isContinue,
  }) async {
    try {
      final List<FeeStructure> rowsToSave = combinedRows;
      for (int rowIndex = 0; rowIndex < rowsToSave.length; rowIndex++) {
        final FeeStructure row = rowsToSave[rowIndex];
        final String text = amountControllers[rowIndex].text.trim();

        if (text.isEmpty) {
          row
            ..amountRaw = null
            ..amount = null;
          _showNaForId[row.id] = false;
        } else if (text.toUpperCase() == "N/A") {
          row
            ..amountRaw = "N/A"
            ..amount = 0;
          _showNaForId[row.id] = true;
        } else {
          row.amountRaw = text; // Exact
          final bool safeLength = text.replaceAll(".", "").length <= 16;
          row.amount = safeLength ? double.tryParse(text) : null;
          _showNaForId[row.id] = false;
        }

        row.comments = commentsControllers[rowIndex].text.trim();
      }

      _defaultRows(rowsToSave);

      final String response = await repository.saveFeeStructure(rowsToSave);
      unawaited(
        deleteDraft(),
      ); // fire-and-forget: remove backend draft now that data is saved
      AlertManager().showSuccessToast(response);

      // Preserve user input text after refresh.
      final List<String> cachedAmounts =
          amountControllers.map((controller) => controller.text).toList();
      final List<String> cachedComments = commentsControllers
          .map((commentsControllers) => commentsControllers.text)
          .toList();

      await getFeeStructureData();

      for (int rowIndex = 0; rowIndex < combinedRows.length; rowIndex++) {
        if (rowIndex < cachedAmounts.length) {
          amountControllers[rowIndex].text = cachedAmounts[rowIndex];
        }
        if (rowIndex < cachedComments.length) {
          commentsControllers[rowIndex].text = cachedComments[rowIndex];
        }
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

      if (isContinue) {
        if (!context.mounted) {
          return;
        }
        await navigateAfterFeeStructure(context);
      }
    } on Object catch (error) {
      AlertManager().showFailureToast(error.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Navigates to a specific Remarks tab route and passes the tab as `extra`
  /// so `CommonTabsView` can open the correct section
  Future<void> changeTab(RemarksTabs tab) async {
    router.go(TabConstants.remarksRoutes[tab]!, extra: tab);
  }

  /// Updates which tabs show asterisks, based on selected customer.
  Future<void> setAsterisks() async {
    showAsteriskTabs = Utils.getMandatoryRemarksTabs(selectedCustomer);
  }

  /// Sets default values for appRefNo and rimNo in each row.
  void _defaultRows(List<FeeStructure> rowsToDefault) {
    for (final FeeStructure row in rowsToDefault) {
      row
        ..appRefNo = Globals.request?.applicationRefNo
        ..rimNo = selectedCustomer?.customerRimNo;
    }
  }

  /// Only FI types should show the "View more / View less" affordance.
  /// Country (and other non-FI) show all chips without the toggle.
  bool get showViewMore =>
      selectedCustomer?.type == CustomerType.belowInvestmentGradeBanks ||
      selectedCustomer?.type == CustomerType.investmentGradeBanks;

  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }

  /// Navigates to the next visible Remarks tab after Fee Structure.
  /// - For Corporate: Fee Structure is last => goes to Certification.
  /// - For FI: goes to the next FI remarks tab (e.g. Business Experience, etc.)
  Future<void> navigateAfterFeeStructure(BuildContext context) async {
    // Safety: if customer not selected, fallback to certification.
    final Customer? currentCustomer = selectedCustomer;
    if (currentCustomer == null) {
      if (context.mounted) {
        context.go(Routes.rmCertification);
      }
      return;
    }

    // FI-only tabs are controlled via this conditional map.
    final Map<RemarksTabs, bool Function()> tabVisibilityRules =
        TabConstants.getRemarksRoutes(currentCustomer);

    // Build the ordered list of tabs that should be visible for this customer.
    final List<RemarksTabs> orderedVisibleTabs =
        TabConstants.remarksRoutes.entries
            .where((routeEntry) {
              final RemarksTabs tabKey = routeEntry.key;

              // If there is no rule for this tab, it's visible by default.
              final bool Function()? isTabVisible = tabVisibilityRules[tabKey];

              // return isVisibleRule == null ? true : isVisibleRule();

              // Lint-free simplification (instead of ?: true/false)
              return isTabVisible == null || isTabVisible();
            })
            .map((routeEntry) => routeEntry.key)
            .toList();

    // Find Fee Structure in the visible list.
    final int feeIndex = orderedVisibleTabs.indexOf(RemarksTabs.feeStructure);

    // If Fee Structure is missing or it is the last visible tab => go to Certification.
    if (feeIndex == -1 || feeIndex == orderedVisibleTabs.length - 1) {
      if (context.mounted) {
        context.go(Routes.rmCertification);
      }
      return;
    }

    // Otherwise navigate to the next visible tab.
    final RemarksTabs nextTab = orderedVisibleTabs[feeIndex + 1];
    router.go(
      TabConstants.remarksRoutes[nextTab]!,
      extra:
          nextTab, // important for Routes.remarksCommonTabs to open correct tab
    );
  }
}
