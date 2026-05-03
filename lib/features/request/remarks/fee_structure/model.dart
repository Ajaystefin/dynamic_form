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

/// ViewModel for managing fee structure data, including form state,
/// controller bindings, API interactions, and UI synchronization.
class FeeStructureViewModel extends SafeCubit<FeeStructureState>
    with DraftMixin<FeeStructureViewModel> {
  /// Initializes the ViewModel with default loader state.
  FeeStructureViewModel()
      : super(FeeStructureState(loaderStatus: LoadingStatus.loaded));

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

  /// Tabs that require asterisk indicators.
  List<RemarksTabs> showAsteriskTabs = [];
  PageMode pageMode = PageMode.na;
  bool get isReadOnlyMode => pageMode == PageMode.view;

  /// List of mandatory fee types.
  List<String> defaultFeeTypes = <String>[
    "remarks.feeStructure.arrangementFee".tr(),
    "remarks.feeStructure.processingFee".tr(),
    "remarks.feeStructure.commitmentFee".tr(),
    "remarks.feeStructure.prePaymentFee".tr(),
    "remarks.feeStructure.breachOfCovenant".tr(),
  ];

  List<Customer>? customerList = [];

  /// Returns default fee rows, ensuring each mandatory type is present.
  List<FeeStructure> get defaultRows {
    for (final String type in defaultFeeTypes) {
      if (!feeRows.any((row) => row.feeType == type)) {
        feeRows.add(
          FeeStructure(
            id: "default_$type",
            isNew: true,
            feeType: type,
            amount: 0,
            comments: "",
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

  /// Sets default values for appRefNo and rimNo in each row.
  void _defaultRows(List<FeeStructure> rowsTodefault) {
    for (final FeeStructure row in rowsTodefault) {
      row
        ..appRefNo = Globals.request?.applicationRefNo
        ..rimNo = selectedCustomer?.customerRimNo;
    }
  }

  bool isFI = false;

  bool get isEdit => pageMode == PageMode.edit; //&& Utils.canEditApplication();

  @override
  String get draftModuleKey => DraftModuleKeys
      .remarks; // Backend category (adjust if you have a specific one)
  @override
  String get draftFormKey => Routes.feeStructure; // This screen's route key
  @override
  DraftHandler<FeeStructureViewModel> get draftHandler =>
      FeeStructureDraftHandler();

  /// Initializes the ViewModel and loads fee structure data.
  Future<void> init(BuildContext context) async {
    pageMode = AuthRepository.getPageMode(RightConstants.remarksCommentary);
    // for checkup with request type creditRisk
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
      //logger.i('Error fetching getChildRimsForGroup : $e');
      defaultSelectedCustomer();
      rethrow;
    }
  }

  void defaultSelectedCustomer() {
    selectedCustomer = ((Globals.request?.borrowers ?? []).isNotEmpty)
        ? Globals.request?.borrowers?.first
        : Globals.request?.customers?.first;
  }

  /// Fetches fee structure data from the API and initializes controllers.
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
        // normalize and check if the raw value is a textual zero ("0", "0.00",
        // "000.000", etc.)
        final String raw = (row.amountRaw ?? "").trim();
        final bool isRawZero =
            raw.isNotEmpty && RegExp(r"^0+(\.0+)?$").hasMatch(raw);

        // also treat textual zero as N/A
        final bool isNa = (raw.toUpperCase() == "N/A") ||
            isRawZero ||
            (((row.amount ?? 0.0) == 0.0) && raw.isEmpty);

        _showNaForId[row.id] = isNa;

        String amountText;
        if (isNa) {
          amountText = "";
        } else if (raw.isNotEmpty) {
          amountText =
              raw.contains(".") ? raw : "$raw.00"; // exact + two decimals
        } else {
          amountText = (row.amount ?? 0.0).toStringAsFixed(2);
        }

        amountControllers.add(TextEditingController(text: amountText));
        commentsControllers.add(TextEditingController(text: row.comments));
      }

      emit(state.copyWith(tableLoader: LoadingStatus.loaded));
    } catch (e) {
      feeRows = [];
      emit(state.copyWith(tableLoader: LoadingStatus.error));
    }
  }

  /// Returns the display value for amount, showing 'N/A' if flagged.
  String displayAmount(FeeStructure row) {
    final double amt = row.amount ?? 0.0;
    if (amt == 0.0 || amt == 0) {
      return (_showNaForId[row.id] ?? false) ? "N/A" : "";
    }
    return amt.toString();
  }

  /// Updates the model when the amount field changes.
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
        ..amount = 0.0;
      _showNaForId[row.id] = true;
      return;
    }

    // Preserve EXACT value
    row.amountRaw = raw;

    // Optional: set amount only when it can be represented safely (<= 16
    // digits)
    final bool safeLength = raw.replaceAll(".", "").length <= 16;
    row.amount = safeLength ? double.tryParse(raw) : null;

    _showNaForId[row.id] = raw == "0" || raw == "0.00";
  }

  /// Handles customer change and reloads fee structure data.
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

  /// Adds a new empty fee row and initializes its controllers.
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

  /// Deletes a fee row and its associated controllers.
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
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(tableLoader: LoadingStatus.error));
    }
  }

  /// Validates and saves the fee structure form, optionally navigating to the
  /// next tab.
  Future<void> onSavePress(bool isContinue, BuildContext context) async {
    try {
      final List<FeeStructure> rowsToSave = combinedRows;
      for (int i = 0; i < rowsToSave.length; i++) {
        final FeeStructure row = rowsToSave[i];
        final String text = amountControllers[i].text.trim();

        if (text.isEmpty) {
          row
            ..amountRaw = null
            ..amount = null;
          _showNaForId[row.id] = false;
        } else if (text.toUpperCase() == "N/A") {
          row
            ..amountRaw = "N/A"
            ..amount = 0.0;
          _showNaForId[row.id] = true;
        } else {
          row.amountRaw = text; // Exact
          final bool safeLength = text.replaceAll(".", "").length <= 16;
          row.amount = safeLength ? double.tryParse(text) : null;
          _showNaForId[row.id] = text == "0" || text == "0.00";
        }

        row.comments = commentsControllers[i].text.trim();
      }

      _defaultRows(rowsToSave);

      final String response = await repository.saveFeeStructure(rowsToSave);
      unawaited(
        deleteDraft(),
      ); // fire-and-forget: remove backend draft now that data is saved
      AlertManager().showSuccessToast(response);

      final List<String> cachedAmounts =
          amountControllers.map((c) => c.text).toList();
      final List<String> cachedComments =
          commentsControllers.map((c) => c.text).toList();

      await getFeeStructureData();

      for (int i = 0; i < combinedRows.length; i++) {
        if (i < cachedAmounts.length) {
          amountControllers[i].text = cachedAmounts[i];
        }
        if (i < cachedComments.length) {
          commentsControllers[i].text = cachedComments[i];
        }
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

      if (isContinue) {
        if (!context.mounted) return;
        context.go(Routes.rmCertification);
      }
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Navigates to the specified remarks tab.
  Future<void> changeTab(RemarksTabs tab) async {
    router.go(TabConstants.remarksRoutes[tab]!, extra: tab);
  }

  Future<void> setAsterisks() async {
    showAsteriskTabs = Utils.getMandatoryRemarksTabs(selectedCustomer);
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
}
