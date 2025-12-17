import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/project/contract.dart';
import 'package:wcas_frontend/models/request/project/contract_comment.dart';
import 'package:wcas_frontend/models/request/project/link_contract.dart';
import 'package:wcas_frontend/models/request/project/ppc.dart';
import 'package:wcas_frontend/models/request/project/project.dart';
import 'package:wcas_frontend/repositories/project_repository.dart';

import 'state.dart';

class EditContractViewModel extends Cubit<EditContractState> {
  EditContractViewModel()
      : super(EditContractState(
          loaderStatus: LoadingStatus.loading,
          linkCommitmentStatus: LoadingStatus.loading,
          ppcStatus: LoadingStatus.loading,
        ));

  late ProjectRepository repository;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<String> dropdownItems = ["Main Contractor", "Sub-Contractor"];
  Map<String, List<Reference>> referenceData = {};

  final TextEditingController convertedAmountController =
      TextEditingController();
  final TextEditingController contractorValueController =
      TextEditingController();

  List<Reference> countryCodes = [];
  final List<Reference> _defaultCodes = [
    Reference(id: 0, name: 'AED', description: '', status: 'ACTIVE'),
    Reference(id: 1, name: 'USD', description: '', status: 'ACTIVE'),
    Reference(id: 2, name: 'KWD', description: '', status: 'ACTIVE'),
  ];

  final List<Reference> borrowerRole = [
    Reference(id: 0, name: 'Pledgor', description: '', status: 'ACTIVE'),
    Reference(id: 0, name: 'Mortgagor', description: '', status: 'ACTIVE'),
    Reference(id: 0, name: 'Not Applicable', description: '', status: 'ACTIVE'),
  ];

  List<Reference> get safeCountryCodes =>
      countryCodes.isNotEmpty ? countryCodes : _defaultCodes;

  Reference get selectedRef => safeCountryCodes.firstWhere(
        (r) => r.name == selectedCurrencyLabel,
        orElse: () => safeCountryCodes.first,
      );

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

  DateTime? _startDate;
  DateTime? _endDate;

  String? selectedCurrencyLabel = ServerConstants.aedCurrency;

  static const Map<String, double> _exchangeRates = {
    'AED': 1.0,
    'USD': 3.67,
    'KWD': 0.044,
  };

  Contract contract = Contract();
  List<PPC> ppc = [];
  List<LinkContract> linkContract = [];
 late Project project = Project();
  late List<Contract> contracts = [];
  Future<void> init(context) async {
    repository = ProjectRepository.instance;
    await Future.wait([
      getContract(),
      getLinkCommitment(),
      getPpc(),
    ]);

    await getcountryCode();
    updateConvertedAmount();
    await loadReferenceData();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> getcountryCode() async {
    try {
      countryCodes = await repository.getcountryCode();
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  List<ContractComment> comments = [];

  List<String> commentInputs = [''];

  /// Retrieves contract details from the repository and updates the UI state.
  ///
  /// This asynchronous function performs the following:
  /// - Calls `repository.getContractDetails()` to fetch contract data.
  /// - Assigns the retrieved data to the `contract` variable.
  /// - Emits a `loaded` status to indicate successful data retrieval.
  /// - If an error occurs during the fetch, emits an `error` status to reflect the failure.
  Future<void> getContract() async {
    try {
      project = await repository.getProjectDetails();
      contracts = project.contract ?? [];
      contract = contracts.first;
    
      // ✅ Initialize internal date variables
      _startDate = contract.expectedStartDate;
      _endDate = contract.expectedCompletionDate;


      // ✅ Update tenor
      _updateTenor();

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }
 
  Future<void> getLinkCommitment() async {
    try {
      linkContract = await repository.getLinkContract();
      emit(state.copyWith(linkCommitmentStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(linkCommitmentStatus: LoadingStatus.error));
    }
  }

  Future<void> getPpc() async {
    try {
      ppc = await repository.getPPC();
      emit(state.copyWith(ppcStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  Future<void> loadReferenceData() async {
    try {
      referenceData = await ReferenceDataService()
          .getReferenceData([ReferenceDataKeys.certificateType]);
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
      rethrow;
    }
  }

  void onCurrencyChanged(Reference ref) {
    selectedCurrencyLabel = ref.name;
    updateConvertedAmount();
  }

  void onContractValueChanged(String raw) {
    updateConvertedAmount();
  }

  void updateConvertedAmount() {
    final rawText = contractorValueController.text;
    final rawValue = double.tryParse(rawText) ?? 0.0;
    final rate = _exchangeRates[selectedCurrencyLabel] ?? 1.0;
    final converted = rawValue * rate;

    if (rawText.isEmpty || converted == 0.0) {
      convertedAmountController.clear();
    } else {
      convertedAmountController.text = converted.toStringAsFixed(2);
    }

    emit(state.copyWith());
  }

  Future<void> onSubmit() async {
    if (!formKey.currentState!.validate()) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      logger.w('Validation failed');
      return;
    }

    // Null safety checks before submission
    if (contract.expectedStartDate == null ||
        contract.expectedCompletionDate == null ||
        contract.projectTenor == null ||
        selectedCurrencyLabel == null ||
        contractorValueController.text.isEmpty) {
      AlertManager().showFailureToast("Please fill all required fields.");
      return;
    }

    try {
      logger.d('Submitting contract: ${contract.toJson()}');
      await repository.saveContractDetails(contract.toJson());
      AlertManager().showSuccessToast("editContract.savedSuccessfully".tr());
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  Future<void> onReset() async => await getContract();

  void onStartDateSubmitted2(DateTime? raw) {
    logger.d('Picked start="$raw"');
    if (raw != null) {
      startDateController.text = raw.toString();
      contract.expectedStartDate = raw;
      _startDate = raw;
      _updateTenor();
    }
  }

  void onCompletionDateSubmitted2(DateTime? raw) {
    logger.d('Picked end="$raw"');
    if (raw != null) {
      completionDateController.text = raw.toString();
      contract.expectedCompletionDate = raw;
      _endDate = raw;
      _updateTenor();
    }
  }

  void _updateTenor() {
    if (_startDate == null || _endDate == null) {
      logger.w('Cannot calculate tenor: start or end date is null');
      contract.projectTenor = null;
      projectTenorController.clear();
      return;
    }

    var months = (_endDate!.year - _startDate!.year) * 12 +
        (_endDate!.month - _startDate!.month);
    if (_endDate!.day < _startDate!.day) months--;

    final daySpan = _endDate!.difference(_startDate!).inDays;
    if (months < 1 || daySpan < 30) {
      logger.i('ℹ️ forcing 1 month (span < 30 days)');
      months = 1;
    }

    final text = '$months month${months == 1 ? '' : 's'}';
    contract.projectTenor = text;
    projectTenorController.text = text;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void addCommentInput() {
    commentInputs.add('');
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateCommentInput(int index, String value) {
    if (index < commentInputs.length) {
      commentInputs[index] = value;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  void submitComments() {
    for (var comment in commentInputs) {
      if (comment.trim().isNotEmpty) {
        comments.add(
          ContractComment(text: comment.trim(), timestamp: DateTime.now()),
        );
      }
    }
    commentInputs = [''];
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  List<String> getCommentInputs() => commentInputs;
  List<ContractComment> getComments() => comments;
}
