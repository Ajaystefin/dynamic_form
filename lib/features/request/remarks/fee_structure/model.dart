import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/remarks/fee_structure.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'package:wcas_frontend/repositories/auth_repository.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

/// ViewModel for managing fee structure data, including form state,
/// controller bindings, API interactions, and UI synchronization.
class FeeStructureViewModel extends Cubit<FeeStructureState> {
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
  Customer? selectedCustomer = Globals.request?.customers?.first;

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
  final defaultFeeTypes = <String>[
    "remarks.feeStructure.arrangementFee".tr(),
    "remarks.feeStructure.processingFee".tr(),
    "remarks.feeStructure.commitmentFee".tr(),
    "remarks.feeStructure.prePaymentFee".tr(),
    "remarks.feeStructure.breachOfCovenant".tr()
  ];

  /// Returns default fee rows, ensuring each mandatory type is present.
  List<FeeStructure> get defaultRows {
    for (var type in defaultFeeTypes) {
      if (!feeRows.any((row) => row.feeType == type)) {
        feeRows.add(FeeStructure(
          id: 'default_$type',
          isNew: true,
          feeType: type,
          amount: 0.0,
          comments: '',
        ));
      }
    }

    final Map<String, FeeStructure> existingByType = {
      for (final FeeStructure row in feeRows) row.feeType: row
    };
    return defaultFeeTypes.map<FeeStructure>((String type) {
      final FeeStructure row = existingByType[type]!;
      row.isNew = false;
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
    for (var row in rowsTodefault) {
      row.appRefNo = "201902APNAR000056"; //Globals.request?.applicationRefNo;
      row.rimNo = 9992; //selectedCustomer?.customerRimNo;
    }
  }

  /// Initializes the ViewModel and loads fee structure data.
  Future<void> init(BuildContext context) async {
    pageMode = AuthRepository.getPageMode(RightConstants.remarksCommentary);

    showAsteriskTabs = Utils.getMandatoryRemarksTabs(selectedCustomer!);
    await getFeeStructureData();
  }

  /// Fetches fee structure data from the API and initializes controllers.
  Future<void> getFeeStructureData() async {
    emit(state.copyWith(tableLoader: LoadingStatus.loading));
    try {
      feeRows = await repository.getFeeStructureData(
        selectedCustomer?.customerRimNo,
      );

      final rows = combinedRows;

      amountControllers.clear();
      commentsControllers.clear();

      for (final row in rows) {
        final isNa = (row.amount ?? 0.0) == 0.0;
        _showNaForId[row.id] = isNa;

        final amountText = isNa ? 'N/A' : row.amount?.toString() ?? '';
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
    final amt = row.amount ?? 0.0;
    if (amt == 0.0 || amt == 0) {
      return (_showNaForId[row.id] ?? false) ? 'N/A' : '';
    }
    return amt.toString();
  }

  /// Updates the model when the amount field changes.
  void onAmountFieldChanged(int index, String input) {
    final row = combinedRows[index];
    final text = input.trim().toUpperCase();

    if (text.isEmpty) {
      row.amount = null;
      _showNaForId[row.id] = false;
      return;
    }

    if (text == 'N/A') {
      row.amount = 0.0;
      _showNaForId[row.id] = true;
    } else {
      final newAmt = double.tryParse(text) ?? 0.0;
      row.amount = newAmt;
      _showNaForId[row.id] = newAmt == 0.0;
    }
  }

  /// Handles customer change and reloads fee structure data.
  Future<void> onCustomerChanged(Customer customer) async {
    emit(state.copyWith(tableLoader: LoadingStatus.loading));
    selectedCustomer = customer;
    await getFeeStructureData();
    emit(state.copyWith(tableLoader: LoadingStatus.loaded));
  }

  /// Adds a new empty fee row and initializes its controllers.
  void addRow() {
    emit(state.copyWith(tableLoader: LoadingStatus.loading));
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final newRow = FeeStructure(id: newId, isNew: true, feeType: '');
    feeRows.add(newRow);
    amountControllers.add(TextEditingController());
    commentsControllers.add(TextEditingController());
    emit(state.copyWith(tableLoader: LoadingStatus.loaded));
  }

  /// Deletes a fee row and its associated controllers.
  Future<void> deleteRow(FeeStructure data) async {
    emit(state.copyWith(tableLoader: LoadingStatus.loading));
    try {
      final index = combinedRows.indexWhere((r) => r.id == data.id);
      if (index != -1) {
        feeRows.remove(data);
        amountControllers.removeAt(index);
        commentsControllers.removeAt(index);
      }

      if (!data.isNew) {
        final response = await repository.deleteFeeStructureData(data);
        AlertManager().showSuccessToast(response);
      }

      emit(state.copyWith(tableLoader: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(tableLoader: LoadingStatus.error));
    }
  }

  /// Validates and saves the fee structure form, optionally navigating to the next tab.
  Future<void> onSavePress(bool isContinue, BuildContext context) async {
    try {
      final rowsToSave = combinedRows;

      // Sync controller values into model
      for (int i = 0; i < rowsToSave.length; i++) {
        final row = rowsToSave[i];

        final amountText = amountControllers[i].text.trim().toUpperCase();
        if (amountText.isEmpty) {
          row.amount = null;
          _showNaForId[row.id] = false;
        } else if (amountText == 'N/A') {
          row.amount = 0.0;
          _showNaForId[row.id] = true;
        } else {
          final parsed = double.tryParse(amountText) ?? 0.0;
          row.amount = parsed;
          _showNaForId[row.id] = parsed == 0.0;
        }

        row.comments = commentsControllers[i].text.trim();
      }

      _defaultRows(rowsToSave);

      final response = await repository.saveFeeStructure(rowsToSave);
      AlertManager().showSuccessToast(response);

      final cachedAmounts = amountControllers.map((c) => c.text).toList();
      final cachedComments = commentsControllers.map((c) => c.text).toList();

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
  void changeTab(RemarksTabs tab) async {
    router.go(TabConstants.remarksRoutes[tab]!, extra: tab);
  }
}
