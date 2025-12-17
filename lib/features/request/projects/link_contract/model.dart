// ignore_for_file: avoid_print

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/state.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/project/contract.dart';
import 'package:wcas_frontend/models/request/project/contract_comment.dart';
import 'package:wcas_frontend/repositories/project_repository.dart';

/// ViewModel for managing the state and logic of the Link Contract screen.
///
/// This class handles form input, contract data binding, date selection,
/// tenor calculation, and saving contract details using the BLoC pattern.
class LinkContractViewModel extends Cubit<LinkContractState> {
  /// Constructor initializes the state with a loading status.
  LinkContractViewModel()
      : super(LinkContractState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for handling project-related operations.
  late ProjectRepository repository;

  /// Contract model that holds the form data.
  late Contract contract = Contract();

  /// Global key for validating the contract form.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Dropdown options for contractor roles.
  List<String> dropdownItems = ["Main Contractor", "Sub-Contractor"];

  Map<String, List<Reference>> referenceData = {};

  /// 1) Controller for the converted-amount field
  final TextEditingController convertedAmountController =
      TextEditingController();
  // 1) Raw contract value entered by user
  final TextEditingController contractorValueController =
      TextEditingController();

  List<Reference> countryCodes = [];

  // 4) Default currency references if none loaded from repo
  final List<Reference> defaultCodes = [
    Reference(id: 0, name: 'AED', description: '', status: 'ACTIVE'),
    Reference(id: 1, name: 'USD', description: '', status: 'ACTIVE'),
    Reference(id: 2, name: 'KWD', description: '', status: 'ACTIVE'),
  ];

  final List<Reference> borrowerRole = [
    Reference(
        id: 0, name: 'Main Contractor', description: '', status: 'ACTIVE'),
    Reference(id: 0, name: 'Sub-Contractor', description: '', status: 'ACTIVE'),
  ];

  // Getter: either loaded codes or fallback defaults
  List<Reference> get safeCountryCodes =>
      countryCodes.isNotEmpty ? countryCodes : defaultCodes;

  // Text controllers for form fields
  TextEditingController searchRimController = TextEditingController();
  TextEditingController searchNameController = TextEditingController();
  final TextEditingController customerRimController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController projectTenorController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController completionDateController =
      TextEditingController();
  final TextEditingController paymasterNameController = TextEditingController();
  final TextEditingController contractorScopeController =
      TextEditingController();

  List<ContractComment> comments = [];

  /// Internal variables to store selected start and end dates.
  DateTime? _startDate;
  DateTime? _endDate;

  /// The currently selected currency code (e.g. 'AED', 'USD', 'INR')
  String selectedCurrencyLabel = ServerConstants.aedCurrency;
  // Getter: find the Reference matching the selected label
  Reference get selectedRef => safeCountryCodes.firstWhere(
        (r) => r.name == selectedCurrencyLabel,
        orElse: () => safeCountryCodes.first,
      );

  /// Hard-coded rates to convert into AED
  static const Map<String, double> _exchangeRates = {
    'AED': 1.0,
    'USD': 3.67,
    'KWD': 0.044,
  };

  /// Initializes the ViewModel and sets the repository instance.
  ///
  /// [context] - The build context used for localization or navigation.
  Future<void> init(context) async {
    logger.i('Initialising ViewModel…');
    repository = ProjectRepository.instance;
    getcountryCode();
    _updateConvertedAmount();
    loadReferenceData();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Fetches the list of country codes from the repository and stores
  /// them in the `countryCodes` variable.
  /// Displays an error toast if the operation fails.
  Future<void> getcountryCode() async {
    try {
      countryCodes = await repository.getcountryCode();
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Loads reference data for search criteria, segment types, region list,
  /// advance request types, and role types. Populates the [referenceData] map
  /// with the fetched data. If an error occurs during the fetching process,
  /// it updates the loader status to [LoadingStatus.error].
  Future<void> loadReferenceData() async {
    try {
      referenceData = await ReferenceDataService()
          .getReferenceData([ReferenceDataKeys.borrowerRole]);
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
      rethrow;
    }
  }

  // Called when user picks a currency
  void onCurrencyChanged(Reference ref) {
    selectedCurrencyLabel = ref.name!;
    _updateConvertedAmount();
    emit(state.copyWith()); // Trigger UI update if needed
  }

  // Called when user types contract value
  void onContractValueChanged(String raw) {
    _updateConvertedAmount();
  }

void _updateConvertedAmount() {
  final rawText = contractorValueController.text;
  final rawValue = double.tryParse(rawText) ?? 0.0;

  print('Updating converted amount...');
  print('Selected currency: $selectedCurrencyLabel');
  print('Raw value: $rawValue');

  if (selectedCurrencyLabel != 'AED') {
    final rate = _exchangeRates[selectedCurrencyLabel] ?? 1.0;
    final converted = rawValue * rate;

    print('Exchange rate: $rate');
    print('Converted value: $converted');

    if (rawText.isEmpty || converted == 0.0) {
      convertedAmountController.clear();
    } else {
      convertedAmountController.text = converted.toStringAsFixed(2);
    }
  } else {
    convertedAmountController.clear();
    logger.d('Conversion skipped: selected currency is AED');
  }

  emit(state.copyWith());
}

  /// Handles the proceed action by validating and assigning customer details.
Future<void> onProceed() async {
  final rimText = searchRimController.text.trim();
  final nameText = searchNameController.text.trim();

  logger.d('>> onProceed: rim="$rimText", name="$nameText"');

  // Custom validation: at least one must be filled
  if (rimText.isEmpty && nameText.isEmpty) {
    AlertManager().showFailureToast(
      "project.linkContract.pleaseEnterRimCustomerName".tr(),
    );
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    return;
  }

  // Parse RIM number if provided
  final rimNo = rimText.isNotEmpty ? int.tryParse(rimText) : null;

  contract
    ..customerRimNo = rimNo
    ..customerName = nameText;

  customerRimController.text = rimNo?.toString() ?? '';
  customerNameController.text = nameText;

  emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
}

  /// Clears all form fields and resets the contract model.
  void clearAll() {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    searchRimController.clear();
    searchNameController.clear();
    customerRimController.clear();
    customerNameController.clear();
    projectTenorController.clear();
    paymasterNameController.clear();
    contractorScopeController.clear();
    startDateController.clear();
    completionDateController.clear();

    contract
      ..borrowerRole = null
      ..contractorValue = null
      ..paymasterName = null
      ..contractorScope = null
      ..expectedStartDate = null
      ..expectedCompletionDate = null
      ..projectTenor = null;

    _startDate = null;
    _endDate = null;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

Future<void> onSave(BuildContext context) async {
  final rimText = searchRimController.text.trim();
  final nameText = searchNameController.text.trim();

  // Custom validation: at least one must be filled
  if (rimText.isEmpty && nameText.isEmpty) {
    AlertManager().showFailureToast(
      "Please enter either RIM number or Customer name.",
    );
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    return;
  }

  // Validate other fields in the form
  if (!formKey.currentState!.validate()) {
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    logger.w('Validation failed');
    return;
  }

  try {
    final rimNo = rimText.isNotEmpty ? int.tryParse(rimText) : null;

    contract
      ..customerRimNo = rimNo
      ..customerName = nameText;

    await repository.saveLinkContractDetails(contract);

    AlertManager().showSuccessToast(
      "Contract has been successfully created against Contract Code ${contract.contractCode} and linked with Project Code ${contract.projectCode}"
    );

    router.go(Routes.editContract);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  } catch (e) {
    emit(state.copyWith(loaderStatus: LoadingStatus.error));
    AlertManager().showFailureToast("Failed to save contract: ${e.toString()}");
  }
}

// LinkContractViewModel.dart

  // Future<void> onSave() async {
  //   // 1) trigger all field validators
  //   final form = formKey.currentState!;
  //   final isValid = form.validate();

  //   if (!isValid) {
  //     // 2) find the first error message
  //     String firstError = 'Please complete all required fields';

  //     // 3) show that message as a toast
  //     AlertManager().showFailureToast(firstError);

  //     // 4) stop the save flow
  //     return;
  //   }

  //   // 5) everything’s valid → proceed to save
  //   try {
  //     emit(state.copyWith(loaderStatus: LoadingStatus.loading));
  //     await repository.saveLinkContractDetails(contract);
  //     emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  //     AlertManager().showSuccessToast(
  //       "project.linkContract.savedContractSuccessfully".tr(),
  //     );
  //   } catch (e) {
  //     emit(state.copyWith(loaderStatus: LoadingStatus.error));
  //   }
  // }

  /// Handles start date selection and updates the contract model.
  ///
  /// [raw] - The selected start date.
  void onStartDateSubmitted2(DateTime? raw) {
    logger.d('Picked start="$raw"');
    startDateController.text = raw.toString();
    contract.expectedStartDate = raw;
    _startDate = raw;
    _updateTenor();
  }

  /// Handles completion date selection and updates the contract model.
  ///
  /// [raw] - The selected completion date.
  void onCompletionDateSubmitted2(DateTime? raw) {
    if (_startDate != null && raw != null && raw.isBefore(_startDate!)) {
      AlertManager().showWarningToast(
          "Completion date cannot be earlier than start date.");
      return;
    }

    // Valid date — update everything
    completionDateController.text = DateFormat('dd/MM/yyyy').format(raw!);
    contract.expectedCompletionDate = raw;
    _endDate = raw;
    _updateTenor();
  }

  /// Calculates the project tenor based on start and end dates.
  ///
  /// Updates the contract model and the UI state.
  void _updateTenor() {
    if (_startDate == null || _endDate == null) {
      contract.projectTenor = null;
      projectTenorController.clear();
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      AlertManager().showWarningToast(
          "Completion date cannot be earlier than start date.");
      contract.projectTenor = null;
      projectTenorController.clear();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded, tenor: null));
      return;
    }

    final daySpan = _endDate!.difference(_startDate!).inDays;
    final months = daySpan ~/ 30;
    final days = daySpan % 30;

    String text;
    if (months > 0 && days > 0) {
      text =
          '$months month${months == 1 ? '' : 's'} $days day${days == 1 ? '' : 's'}';
    } else if (months > 0) {
      text = '$months month${months == 1 ? '' : 's'}';
    } else {
      text = '$days day${days == 1 ? '' : 's'}';
    }

    contract.projectTenor = text;
    projectTenorController.text = text;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded, tenor: text));
  }

  /// Updates the contract model and controller when paymaster name changes.
  ///
  /// [val] - The new paymaster name.
  void onPaymasterNameChanged(String val) {
    contract.paymasterName = val;
    paymasterNameController.text = val;
  }

  /// Updates the contract model and controller when contractor scope changes.
  ///
  /// [val] - The new contractor scope.
  void onContractorScopeChanged(String val) {
    contract.contractorScope = val;
    contractorScopeController.text = val;
  }

  void addComment(String commentText) {
    if (commentText.trim().isEmpty) return;
    comments.add(
      ContractComment(text: commentText.trim(), timestamp: DateTime.now()),
    );
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  List<ContractComment> getComments() => comments;
}
