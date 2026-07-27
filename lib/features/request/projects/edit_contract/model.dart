import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/draft_handler.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/state.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/utils/project_contract_numeric_helper.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/facility_security/exchange_rate.dart";
import "package:wcas_frontend/models/request/project/contract.dart";
import "package:wcas_frontend/models/request/project/link_commitment_number.dart";
import "package:wcas_frontend/models/request/project/ppc.dart";
import "package:wcas_frontend/models/request/project/project.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";
import "package:wcas_frontend/repositories/project_repository.dart";

/// View model for managing edit contract screen data and actions.
class EditContractViewModel extends SafeCubit<EditContractState>
    with DraftMixin<EditContractViewModel> {
  /// Creates an edit contract view model.
  EditContractViewModel()
      : super(
          EditContractState(
            loaderStatus: LoadingStatus.loading,
            linkCommitmentStatus: LoadingStatus.loading,
            ppcStatus: LoadingStatus.loading,
          ),
        );

  /// Repository used for project and contract APIs.
  late ProjectRepository repository;

  /// Form key for edit contract form validation and saving.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Contractor type dropdown items.
  List<String> dropdownItems = ["Main Contractor", "Sub-Contractor"];

  /// Reference data mapped by reference data key.
  Map<String, List<Reference>> referenceData = {};

  /// Controller for converted AED amount.
  TextEditingController convertedAmountController = TextEditingController();

  /// Controller for contract value amount.
  TextEditingController contractorValueController = TextEditingController();

  /// Currency/country code reference data.
  List<Reference> countryCodes = [];

  /// Borrower role reference list.
  List<Reference>? borrowerRole = [];

  /// Facility type reference list.
  List<Reference>? facilityType = [];

  /// Search RIM controller.
  TextEditingController searchRimController = TextEditingController();

  /// Search name controller.
  TextEditingController searchNameController = TextEditingController();

  /// Customer RIM controller.
  TextEditingController customerRimController = TextEditingController();

  /// Customer name controller.
  TextEditingController customerNameController = TextEditingController();

  /// Project tenor controller.
  TextEditingController projectTenorController = TextEditingController();

  /// Expected start date controller.
  TextEditingController startDateController = TextEditingController();

  /// Expected completion date controller.
  TextEditingController completionDateController = TextEditingController();

  /// Paymaster name controller.
  TextEditingController paymasterNameController = TextEditingController();

  /// Contractor scope controller.
  TextEditingController contractorScopeController = TextEditingController();

  /// Contractor comments controller.
  TextEditingController contractorCommentsController = TextEditingController();

  /// Completion percentage controller.
  TextEditingController completionPercentageController =
      TextEditingController();

  /// Contract value variation controller.
  TextEditingController variationController = TextEditingController();

  /// Completion date variation controller.
  TextEditingController variationCompletionDateController =
      TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  /// Selected currency label.
  String? selectedCurrencyLabel = ServerConstants.aedCurrency;

  static const Map<String, double> _exchangeRates = {
    "AED": 1.0,
    "USD": 3.67,
    "KWD": 0.044,
  };

  /// Selected borrower role.
  Reference? selectedBorrowerRole;

  /// Selected contract value currency.
  Reference? selectedContractValueCurrency;

  /// Indicates whether selected currency is AED.
  bool isAedRates = false;

  /// Indicates whether PPC row can be added.
  bool isAddPPC = true;

  /// Current contract model.
  Contract contract = Contract();

  /// PPC list used for submission.
  List<PPC> ppc = [];

  /// Link commitment data available for selection.
  List<LinkCommitmentNumber>? linkContract = [];

  /// Current project model.
  late Project project = Project();

  /// Loaded contract details.
  late Contract contracts;

  /// Contract comment history items.
  List<Comment> commentItem = [];

  /// Contract comment input rows.
  List<String> commentInputs = [""];

  /// Returns comment input rows.
  List<String> getCommentInputs() => commentInputs;

  // List<ContractComment> getComments() => comments;

  /// Contract value used for percentage calculations.
  double contractValue = 0;

  /// Customer name resolved from contract details.
  String? customerNameContract;

  // Model rows + controllers
  // List<PpcControllers> ppcControllers = [];

  /// Indicates whether current page can be edited.
  bool get canEdit => pageMode == PageMode.edit;

  /// Current page mode.
  PageMode pageMode = PageMode.na;

  /// Indicates whether completion date validation failed.
  bool completionDateValidate = false;

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.projects;

  @override
  String get draftFormKey => "${Routes.editContract}_${contract.contractCode}";

  @override
  DraftHandler<EditContractViewModel> get draftHandler =>
      EditContractDraftHandler();

  // ---------------------------------------------------------------------------

  /// Initializes edit contract view model.
  Future<void> init(
    BuildContext context, {
    required Contract contractItem,
    required Project projectItem,
  }) async {
    await AuthRepository.instance
        .updateRole(Globals.user!.currentRole!, request: Globals.request);
    pageMode = AuthRepository.getPageMode(RightConstants.editContract);
    repository = ProjectRepository.instance;
    contract = contractItem;
    project = projectItem;
    await callInitMethod();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  @override
  Future<void> close() {
    for (final c in ppcControllerss) {
      c.dispose(); // - SAFE: widget tree is gone
    }
    ppcControllerss.clear();

    unregisterDraftCallback();
    return super.close();
  }

  /// Calls all initialization methods.
  Future<void> callInitMethod() async {
    try {
      await Future.wait([
        loadReferenceData(),
        getContract(),
        getcountryCode(),
        getLinkCommitment(),
      ]);

      //Apply draft BEFORE widgets finish building
      if (canEdit) {
        registerDraftCallback();
        await loadDraftIfAvailable();
      }
    } on Object catch (e) {
      if (e.toString().isNotEmpty) {
        AlertManager().showFailureToast(e.toString());
      }
    }
  }

// --------------------------------------------------
// Sync MODEL ← STATIC controllers
// (used before saving draft / submit)
// --------------------------------------------------

  /// Syncs static controller values into the contract model.
  void syncModelFromControllers() {
    contract
      ..contractName = customerNameController.text
      ..contractValue = contractorValueController.text
      ..contractScope = contractorScopeController.text
      ..completionPercentage =
          double.tryParse(completionPercentageController.text)
      ..contractCurrency = selectedCurrencyLabel;
  }

// --------------------------------------------------
// Sync STATIC controllers ← MODEL
// (used after draft / API restore)
// --------------------------------------------------

  /// Syncs contract model values into static controllers.
  void syncControllersFromModel() {
    completionPercentageController.text =
        contract.completionPercentage.toString();

    customerNameController.text = contract.contractName ?? "";

    contractorValueController.text = contract.contractValue?.toString() ?? "";

    contractorScopeController.text = contract.contractScope ?? "";

    projectTenorController.text =
        contract.projectTenor != null ? "${contract.projectTenor} Months" : "";

    selectedCurrencyLabel = contract.contractCurrency;

    // ❌ DO NOT TOUCH:
    // - PPC controllers
    // - Date controllers
    // - Derived fields
  }

  /// Resets contract edit screen by navigating to edit project view.
  Future<void> onReset(BuildContext context) async {
    //  => await callInitMethod();
    if (context.mounted) {
      context.go(Routes.editViewProject, extra: project);
    }
  }

  /// Loads supported country/currency codes.
  Future<void> getcountryCode() async {
    try {
      countryCodes = await repository.getcountryCode();
      //sorting for make AED in first
      countryCodes.sort(
        (a, b) =>
            (b.name?.toUpperCase() == ReferenceDataKeys.currencyAED ? 1 : 0) -
            (a.name?.toUpperCase() == ReferenceDataKeys.currencyAED ? 1 : 0),
      );
      // final Reference aed = countryCodes.firstWhere(
      //   (r) => (r.name ?? r.name)?.toUpperCase() ==
      // ServerConstants.aedCurrency,
      //   orElse: () =>
      //       countryCodes.isNotEmpty ? countryCodes.first : Reference(),
      // );
      // aed;

      selectedContractValueCurrency = null;
      if (contract.contractCurrency != null) {
        selectedContractValueCurrency = countryCodes.firstWhere(
          (element) => element.name == contract.contractCurrency,
          orElse: () => Reference(name: contract.contractCurrency),
        );
        isAEDCurrencyRate(contract: contract);
      }
    } on Object {
      rethrow;
    }
  }

  /// Retrieves contract details from the repository and updates the UI state.
  ///
  /// This asynchronous function performs the following:
  /// - Calls `repository.getContractDetails()` to fetch contract data.
  /// - Assigns the retrieved data to the `contract` variable.
  /// - Emits a `loaded` status to indicate successful data retrieval.
  /// - If an error occurs during the fetch, emits an `error` status to reflect
  /// the failure.
  Future<void> getContract() async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      contracts = await repository.getContractByContractCodeDetails(
        contractCode: contract.contractCode,
      ); //if need contractorId also pass.
      contract = contracts;
      await getcountryCode();
      if (contract.contractName == null) {
        if (contract.projectId != null) {
          project.projectId = int.tryParse(contract.projectId.toString());
          await getContractDetailsData(project, contract);
        }
      } else {
        customerNameController.text = contract.contractName ?? "";
      }

      isAEDCurrencyRate(contract: contract);
      //First time other currency
      selectedCurrencyLabel = contract.contractCurrency;
      if (!isAedRates) {
        convertedAmountController.text =
            contract.contractValueAedAmount != null ||
                    contract.contractValueAedAmount.toString() != "null"
                ? contract.contractValueAedAmount.toString()
                : "";
        // contract.contractAmount = contract.contractValueAedAmount.toString();
        // getCurrencyRates(Reference(name: contract.contractCurrency),
        // isFirst: true);
      }

      selectedBorrowerRole = null;
      if (contract.borrowerRole != null) {
        selectedBorrowerRole =
            referenceData[ReferenceDataKeys.borrowerRole]?.firstWhere(
          (element) => element.name == contract.borrowerRole,
          orElse: () => Reference(name: contract.borrowerRole),
        );
      }

      _startDate = contract.expectedStartDate;
      _endDate = contract.expectedEndDate;
      projectTenorController.text = contract.projectTenor != null
          ? contract.projectTenor == 1
              ? "${contract.projectTenor} Month"
              : "${contract.projectTenor} Months"
          : "";
      contractorValueController.text = !isAedRates
          ? contract.contractValue.toString()
          : clean(contract.contractValueAedAmount).isNotEmpty
              ? contract.contractValueAedAmount.toString()
              : contract.contractValue.toString();
      variationController.text = contract.variationContractValue != null ||
              contract.variationContractValue.toString() != "null"
          ? contract.variationContractValue.toString()
          : "NA";
      variationCompletionDateController.text =
          ((contract.variationCompletionDate ??= 0).toString() == "0")
              ? "NA"
              : (contract.variationCompletionDate ??= 0).toString();

      contractValue =
          ProjectContractNumericHelper.toDoubleOrNull(contract.contractValue) ??
              0.0;

      if ((contract.contractCode ?? "").isNotEmpty) {
        await fetchAndSetStrategyComments(appRefNo: contract.contractCode);
      }

      if ((contract.ppcList ?? []).isNotEmpty) {
        ppc = contract.ppcList ?? [];
        // ppcList = contract.ppcList ?? [];
        loadPpcFromApi(contract.ppcList ?? []);
        // >>> Initialize per-row "new" flags for API-loaded rows (all false)
        isNewRow = List<bool>.filled(ppc.length, false, growable: true);

        emit(
          state.copyWith(
            refreshKey: DateTime.now().millisecondsSinceEpoch,
            loaderStatus: LoadingStatus.loaded,
            ppcStatus: LoadingStatus.loaded,
          ),
        );
      }

      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.loaded,
          ppcStatus: LoadingStatus.loaded,
        ),
      );

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object {
      rethrow;
    }
  }

  /// Fetches project contract details from the repository and updates state.
  Future<void> getContractDetailsData(
    Project? project,
    Contract? contract,
  ) async {
    try {
      final List<Contract> contractsList =
          await repository.getProjectContractDetails(project);

      final Contract matched = contractsList.firstWhere(
        (c) => c.contractCode?.toString() == contract?.contractCode?.toString(),
        orElse: Contract.new,
      );

      // Name or empty string
      customerNameContract = matched.contractName ?? "";
      customerNameController.text = customerNameContract.toString().trim();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object {
      rethrow;
    }
  }

  /// Loads linked commitment numbers for the contract RIM.
  Future<void> getLinkCommitment() async {
    try {
      linkContract = await repository.getLinkedCMNForRimDetails(
        contractRimNo: contract.rimNo,
      );

      // keep your existing emit
      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.loaded,
          linkCommitmentStatus: LoadingStatus.loaded,
        ),
      );

      //NEW: after we have full details, enrich the contract list
      enrichLinkCommitmentNumberWith();
    } on Object {
      rethrow;
    }
  }

  /// Loads borrower role and facility type reference data.
  Future<void> loadReferenceData() async {
    try {
      referenceData = await ReferenceDataService().getReferenceData(
        [ReferenceDataKeys.borrowerRole, ReferenceDataKeys.facilityTypes],
      );
      borrowerRole = referenceData[ReferenceDataKeys.borrowerRole] ?? [];
      facilityType = referenceData[ReferenceDataKeys.facilityTypes] ?? [];
    } on Object {
      rethrow;
    }
  }

  /// Fetches and sets strategy comments for the given application reference.
  Future<void> fetchAndSetStrategyComments({String? appRefNo}) async {
    try {
      final List<Comment> comments = await repository.getComments(
        CommentsType.contract,
        EntityIdentifier.contract,
        appRefNo,
      );

      commentItem = comments
          .where(
            (item) =>
                item.contractCode == appRefNo ||
                item.categoryId == ServerConstants.contractCategoryID,
          )
          .toList();

      if (comments.isNotEmpty) {
        logger.i("Strategy comment: ${comments[0].strategyComment}");
      }
      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.loaded,
        ),
      );
    } on Object catch (e) {
      commentItem = [Comment(strategyComment: "")];
      logger.e("Error fetching strategy comments: $e");
    }
  }

// Called when user picks a currency

  /// Handles currency selection change.
  void onCurrencyChanged(Reference ref) {
    // Safely read the selected label
    final picked = ref.name ?? "";

    // Update the ViewModel fields
    selectedCurrencyLabel = picked;
    contract.contractCurrency = picked;

    // If you need to reuse the same AED detection logic elsewhere,
    // you can still call your helper with ref:
    isAEDCurrencyRate(ref: ref);

    // Keep your existing emit
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

// Helper to check if the currently selected currency is AED.
// Accepts either a Reference or a Contract (or uses existing selection).

  /// Checks whether selected currency is AED.
  bool isAEDCurrencyRate({Reference? ref, Contract? contract}) {
    // Prefer explicit ref.name, else contract.contractCurrency, else previously
    // selected label
    final code =
        (ref?.name ?? contract?.contractCurrency ?? selectedCurrencyLabel ?? "")
            .toUpperCase();

    return isAedRates = code == ServerConstants.aedCurrency;
  }

  /// Current exchange rate.
  num exchangeRate = 0;

  /// Fetches currency rates and updates converted AED amount.
  Future<void> getCurrencyRates(
    Reference? selectedCurrency, {
    bool? isFirst = false,
  }) async {
    try {
      final CurrencyRates currencyRates = await FacilitySecurityRepository
          .instance
          .getCurrencyRates(selectedCurrency);

      // Resolve the selected currency code/name safely
      final String selectedCode = selectedCurrency?.name ?? "";

      // Get exchange rate for the selected currency
      exchangeRate = currencyRates.rates[selectedCode] ?? 0;

      // Pick the correct amount based on the flag
      final double amount =
          double.tryParse(contract.contractAmount.toString()) ?? 0;

      // Convert
      final double convertedValue = amount * exchangeRate;

      // Format values
      final formatter = NumberFormat("#,###");
      final String formattedAED = formatter.format(convertedValue);
      if (isFirst == false) {
        contract.contractValueAedAmount = formattedAED;
      }
      // Update the correct controller (present vs proposed)
      convertedAmountController.value = TextEditingValue(
        text: formattedAED,
        selection: TextSelection.collapsed(offset: formattedAED.length),
      );
    } on Object catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles contract value change.
  void onContractValueChanged(String raw) {
    updateConvertedAmount();
  }

  /// Updates converted amount using local exchange rate map.
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

  /// Submits the contract details.
  Future<void> onSubmit(
    BuildContext context, {
    YearRules rules = const YearRules(),
  }) async {
    // Ensure model reflects the current picked dates before syncing controllers
    contract.expectedStartDate = _startDate;
    contract.expectedEndDate = _endDate;
    contract.expectedCompletionDate = _endDate;

    if (!formKey.currentState!.validate()) {
      AlertManager().showFailureToast(
        "project.viewEditContractDetails.requiredField".tr(),
      );
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      logger.w("Validation failed");
      return;
    }

// ADD THIS
    if (!validateAllPPCRows()) {
      return;
    }

    // 1) Hard validation (source of truth)
    final bool isValidDate = ProjectContractNumericHelper.validateDates(
      start: _startDate,
      end: _endDate,
      rules: rules,
    );

    if (!isValidDate) {
      // Optional: keep this for backward compatibility, but don't rely on it
      completionDateValidate = true;
      return;
    }

    // 2) Optional: If you still want to guard by the legacy flag, do it AFTER
    // the real validation (but it should never be the only check).
    if (completionDateValidate) {
      AlertManager().showWarningToast(
        "project.viewEditContractDetails.completionDateStartDate".tr(),
      );
      return;
    }

    // Null safety checks before submission
    if (contract.expectedStartDate == null ||
        contract.expectedEndDate == null ||
        contract.projectTenor == null ||
        selectedCurrencyLabel == null ||
        contractorValueController.text.isEmpty) {
      AlertManager().showFailureToast(
        "project.viewEditContractDetails.requiredField".tr(),
      );
      return;
    }

    formKey.currentState?.save();
    try {
      contract
        ..projectId = project.projectId?.toString() ?? ""
        ..projectCode = project.projectCode ?? ""
        ..projectName = project.projectName ?? ""
        ..ppcList = ppcList;

      // contract.toSaveContractJson();
      logger.i("Submitting contract: ${contract.toSaveContractJson()}");
      await submitComments();
      await repository.saveContractDetail(contract);
      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.loaded,
        ),
      );
      AlertManager().showSuccessToast(
        "project.viewEditContractDetails.contractDetailsSaved".tr(
          namedArgs: {
            "projectCode": project.projectCode.toString(),
          },
        ),
      );

      unawaited(deleteDraft());
      if (context.mounted) {
        context.go(Routes.editViewProject, extra: project);
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.loaded,
        ),
      );
    }
  }

  // void onStartDateSubmitted2(DateTime? raw) {
  //   logger.d('Picked start="$raw"');
  //   if (raw != null) {
  //     startDateController.text = raw.toString();
  //     contract.expectedStartDate = raw;
  //     _startDate = raw;
  //     _updateTenor();
  //   }
  // }

  /// Returns true if completion date is before start date.
  bool isCompletionBeforeStart(DateTime start, DateTime end) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);

    return e.isBefore(s);
  }

  /// Handles start date selection and updates the contract model.
  ///
  /// [raw] - The selected start date.
  void onStartDateSubmitted2(
    DateTime? raw, {
    YearRules rules = const YearRules(),
  }) {
    logger.d('Picked start="$raw"');
    _startDate = raw;
    final DateTime? proposedStart = ProjectContractNumericHelper.dateOnly(raw);

    // Validate proposed start vs current end
    final bool isValidDate = ProjectContractNumericHelper.validateDates(
      start: proposedStart,
      end: _endDate,
      rules: rules,
    );

    if (!isValidDate) {
      // invalidate both model + UI
      contract.expectedStartDate = null;
      startDateController.clear();
      // (you chose to “reject” the change)
      return;
    }

    // Commit after validation
    _startDate = proposedStart;
    contract.expectedStartDate = proposedStart;
    startDateController.text = proposedStart == null
        ? ""
        : ProjectContractNumericHelper.fmt.format(proposedStart);

    completionDateValidate = false; // consistent flag
    _updateTenor(rules: rules);
  }

  /// Handles completion date selection and updates the contract model.
  void onCompletionDateSubmitted2(
    DateTime? raw, {
    YearRules rules = const YearRules(),
  }) {
    if (raw != null) {
      _endDate = raw;
      final DateTime? proposedEnd = ProjectContractNumericHelper.dateOnly(raw);

      // Validate proposed end vs current start
      final bool isValidDate = ProjectContractNumericHelper.validateDates(
        start: _startDate,
        end: proposedEnd,
        rules: rules,
      );

      if (!isValidDate) {
        // invalidate both model + UI
        contract.expectedEndDate = null;
        contract.expectedCompletionDate = null;
        completionDateController.clear();

        contract.projectTenor = null;
        projectTenorController.clear();
        completionDateValidate = true;
        return;
      }

      // Commit after validation
      _endDate = proposedEnd;
      contract.expectedEndDate = proposedEnd;
      contract.expectedCompletionDate = proposedEnd;
      completionDateController.text = proposedEnd == null
          ? ""
          : ProjectContractNumericHelper.fmt.format(proposedEnd);

      completionDateValidate = false;
      callEndDateTenor(raw, rules, isFirst: true);
      updateCompletionVariation(); // <-- ADD THIS
    } else {
      variationCompletionDateController.text = "NA";
      contract.variationCompletionDate ??= 0;
    }
  }

  /// Updates end date, controller, and tenor when applicable.
  void callEndDateTenor(
    DateTime? raw,
    YearRules rules, {
    bool? isFirst = false,
  }) {
// Valid date — update everything
    _endDate = raw;
    contract.expectedCompletionDate = raw;
    completionDateController.text =
        raw == null ? "" : DateFormat("dd/MM/yyyy").format(raw);

    if (isFirst ?? false) {
      _updateTenor(rules: rules);
    }
  }

  /// Handles original completion date selection.
  void onOriginalCompletionDateSubmitted2(DateTime? raw) {
    logger.d('Picked end="$raw"');
    if (raw != null) {
      contract.originalCompletionDate = raw;
    } else {
      variationCompletionDateController.text = "NA";
      contract.variationCompletionDate ??= 0;
    }
  }

  void _updateTenor({YearRules rules = const YearRules()}) {
    if (_startDate == null || _endDate == null) {
      contract.projectTenor = null;
      projectTenorController.clear();
      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.loaded,
        ),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      completionDateValidate = true;
      AlertManager().showWarningToast(
        "project.viewEditContractDetails.completionDateStartDate".tr(),
      );
      contract.projectTenor = null;
      projectTenorController.clear();
      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.loaded,
        ),
      );
      return;
    }
    completionDateValidate = false;

    //  Calculate completed months

    final months = ProjectContractNumericHelper.completedMonthsBetween(
      _startDate!,
      _endDate!,
    );

    final text = '$months Month${months == 1 ? '' : 's'}';

    // Store and display
    contract.projectTenor = months; // months only
    projectTenorController.text = text;

    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
      ),
    );
  }

  /// Saves tenor value from field text.
  void onSavedTenor(String? tenor) {
    //final tenor = "3 months";
    final parts = tenor?.split(" ");
    final p0 = parts![0]; // "3"
    //final p1 = parts.length > 1 ? parts[1] : '';
    contract.projectTenor = int.tryParse(p0);
    //print(p0); // 3
    //print(p1); // months
  }

  /// NEW: Hydrates contract.linkCommitmentNumberWith using linkContract
  void enrichLinkCommitmentNumberWith() {
    if (contract.linkCommitmentNumberWith == null ||
        contract.linkCommitmentNumberWith!.isEmpty ||
        linkContract == null ||
        linkContract!.isEmpty) {
      return;
    }

    final List<LinkCommitmentNumber> getApiDetails =
        contract.linkCommitmentNumberWith!;
    final List<LinkCommitmentNumber> apiData = linkContract!;

    // Final list
    final List<LinkCommitmentNumber> merged = [];

    for (final LinkCommitmentNumber getData in getApiDetails) {
      // find the matching API record
      final LinkCommitmentNumber matchData = apiData.firstWhere(
        (item) =>
            item.projectAllocationAccount.toString().trim() ==
            getData.projectAllocationAccount,
        orElse: () => getData,
      );

      // merge matched data
      merged.add(
        LinkCommitmentNumber(
          projectAllocationAccount: getData.projectAllocationAccount,
          facilityType: matchData.facilityType,
          limitAmountInAED: matchData.limitAmountInAED,
          currentOSInAED: matchData.currentOSInAED,
        ),
      );
    }

    // update
    updateLinkCommitmentNumberWith(merged);
  }

  /// Called when a country-chip’s delete icon is tapped
  void linkCommitmentNumberDeleted(int index) {
    final list = contract.linkCommitmentNumberWith;
    if (list == null || index < 0 || index >= list.length) {
      return;
    }

    list.removeAt(index);

    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        linkCommitmentStatus: LoadingStatus.loaded,
      ),
    );
  }

  /// Updates selected link commitment numbers.
  void updateLinkCommitmentNumberWith(List<LinkCommitmentNumber> selected) {
    emit(state.copyWith(linkCommitmentStatus: LoadingStatus.loading));
    contract.linkCommitmentNumberWith = selected;
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        linkCommitmentStatus: LoadingStatus.loaded,
      ),
    );
  }

  /// Add a new empty input row in the UI (not a Comment yet)
  void addCommentInput() {
    // ADD: guard to prevent multiple blank inputs
    // if (commentInputs.isNotEmpty && commentInputs.last.trim().isEmpty) {
    //   AlertManager().showFailureToast(
    //       "Please type into the current comment before adding a new one.");
    //   emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    //   return;
    // }
    commentInputs.add(""); // existing behavior
    contractorCommentsController.text = "";
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

// Update the typed text for a given input row

  /// Updates typed comment text for the given input row.
  void updateCommentInput(int index, String value) {
    if (index >= 0 && index < commentInputs.length) {
      commentInputs[index] = value;
      contractorCommentsController.text = value;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Clears comment inputs.
  void clearCommentInputs({bool leaveOneBlank = true}) {
    commentInputs.clear();
    if (leaveOneBlank) {
      commentInputs.add("");
      contractorCommentsController.text = "";
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

// Used ONLY for draft restore

  /// Sets draft comment value into controller.
  void setDraftComment(String? value) {
    contractorCommentsController.text = value ?? "";
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

// Clear after successful submit

  /// Clears draft comment controller.
  void clearDraftComment() {
    contractorCommentsController.clear();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  //****Future Multi comments need can enable this now its disabled.****
  // Future<void> submitComments_multi() async {
  //   List<Comment> commentItem = [];
  //   // Build local list from inputs
  //   for (final text in commentInputs) {
  //     final trimmed = text.trim();
  //     if (trimmed.isNotEmpty) {
  //       commentItem.add(
  //         Comment(
  //           //id: id,
  //           strategyComment: trimmed,
  //           createdDate: DateTime.now(),
  //         ),
  //       );
  //     }
  //   }

  //   // If no non-empty inputs, show an alert and stop (ADD)
  //   if (commentItem.isEmpty) {
  //     // AlertManager()
  //     //     .showFailureToast("Please enter at least one comment before saving.");
  //     emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  //     return;
  //   } else {
  //     int successCount = 0;
  //     final List<String> failures = <String>[];

  //     for (final c in commentItem) {
  //       try {
  //         final payload = Comment.fromInputData(
  //           type: CommentsType.contract,
  //           strategyComment: c.strategyComment ?? '',
  //           entityType: EntityIdentifier.contract,
  //           categoryId: ServerConstants.commentTypeId[CommentsType.contract],
  //           strategyCategory: ServerConstants.strategyCategoryContract,
  //           id: c.id,
  //         );
  //         if ((contract.appRefNo ?? '').isNotEmpty) {
  //           await CommonRepository.instance.saveStategyComment(
  //             payload,
  //             appRefNo: contract.appRefNo,
  //             rimNo: int.tryParse(contract.rimNo.toString()),
  //           );
  //           successCount++;
  //         }
  //       } on Object catch (e) {
  //         failures.add(e.toString());
  //         logger.d('Save failed: ${e.toString()}');
  //       }
  //     }

  //     if (failures.isEmpty) {
  //       //AlertManager().showSuccessToast("common.saveSuccess".tr());
  //       // --- REMOVE INPUT ROWS AFTER SUCCESSFUL SAVE (ADD) ---
  //       // Clear all typed inputs and leave a single blank for UX
  //       clearCommentInputs(leaveOneBlank: true);
  //       // Also clear the in-memory list to avoid re-submitting duplicates (ADD)
  //       commentItem.clear();
  //     } else {
  //       // Show a consolidated error message
  //       final msg = failures.join('\n');
  //       AlertManager().showFailureToast(msg);
  //       // Keep inputs so the user can fix and re-save (no removal here)
  //     }

  //     // Refresh only if at least one succeeded
  //     if (successCount > 0) {
  //       await fetchAndSetStrategyComments(appRefNo: contract.appRefNo);
  //     }
  //     emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  //   }
  // }

  /// Submits contract comments.
  Future<void> submitComments() async {
    final text = contractorCommentsController.text.trim();

    if (text.isEmpty) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return;
    }

    try {
      Comment? comment;
      comment?.strategyComment = text;
      comment?.comment = text;
      comment?.applicationRefNo = contract.contractCode ?? "";
      comment = Comment.fromInputData(
        applicationRefNo: contract.contractCode ?? "",
        comment: text,
        type: CommentsType.contract,
        entityType: EntityIdentifier.contract,
        categoryId: ServerConstants.commentTypeId[CommentsType.contract],
      );

      await repository.saveComment(comment);

      //Clear after success
      clearDraftComment();

      if ((contract.contractCode ?? "").isNotEmpty) {
        await fetchAndSetStrategyComments(
          appRefNo: contract.contractCode,
        );
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles borrower role selection.
  void onBorrowerRoleSelected(Reference selected) {
    selectedBorrowerRole = selected;
    contract.borrowerRole = selected.name;
    contract.isMainContractor =
        (selected.id == ServerConstants.mainContractorId);
    // if ((selected.id == ServerConstants.mainContractorId)) {
    //   paymasterNameController.text = project.projectOwnerEntityName ?? '';
    // }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Track which PPC rows are newly added (true) vs loaded from API (false)
  List<bool> isNewRow = [];

  /// Flag to control PPC table edit mode
  bool isPpcEditable = false;

  // Toggle helpers

  /// Enables PPC edit mode.
  void enablePpcEditMode() {
    isPpcEditable = true;
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        ppcStatus: LoadingStatus.loaded,
      ),
    );
  }

  /// Disables PPC edit mode.
  void disablePpcEditMode() {
    isPpcEditable = false;
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        ppcStatus: LoadingStatus.loaded,
      ),
    );
  }

  // ---------- ADD ----------
  // In addPpcRow() (silent add, no alerts, as per your previous requirement)

  /// Indicates whether draft restore is in progress.
  bool isRestoringDraft = false;

  Timer? _ppcEmitDebounce;

  /// Emits PPC state change with debounce.
  void emitPpcSoft() {
    if (isRestoringDraft) {
      return;
    }
    _ppcEmitDebounce?.cancel();
    _ppcEmitDebounce = Timer(const Duration(milliseconds: 200), () {
      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.loaded,
          ppcStatus: LoadingStatus.loaded,
        ),
      );
    });
  }

  // ---------- DISPOSE ----------

  /// Disposes PPC controllers.
  void disposeControllers() {
    for (final c in ppcControllerss) {
      c.dispose();
    }
    ppcControllerss.clear();
  }

// Reusable: Numeric field validator with the rule

  /// Validates numeric PPC field when other PPC row fields are entered.
  String? mandatoryNumericIfOther({
    required PpcRowControllers c,
    required String? value,
    required String fieldLabel,
  }) {
    final String ppcValueTrimed = (value ?? "").trim();
    final String vNoCommas = ppcValueTrimed.replaceAll(",", "");

    // Regex: up to 21 digits before '.', up to 6 after
    final RegExp num21_6 = RegExp(r"^\d{1,15}(\.\d{1,6})?$");

    if (!rowHasAnyInput(c)) {
      // Row is blank -> optional; if provided, check format
      if (ppcValueTrimed.isEmpty) {
        return null;
      }
      return num21_6.hasMatch(vNoCommas)
          ? null
          : "$fieldLabel must be numeric (≤15 "
              "digits before decimal, ≤6 after).";
    }

    // Row has other details -> mandatory
    if (ppcValueTrimed.isEmpty) {
      return "$fieldLabel is required because other PPC details are provided.";
    }
    return num21_6.hasMatch(vNoCommas)
        ? null
        : "$fieldLabel must be numeric (≤15 digits before decimal, ≤6 after).";
  }

// Reusable: Date field validator with the rule

  /// Validates date PPC field when other PPC row fields are entered.
  String? mandatoryDateIfOther({
    required PpcRowControllers c,
    required String? value,
    required String fieldLabel,
  }) {
    final String ppcValueTrimed = (value ?? "").trim();

    if (!rowHasAnyInput(c)) {
      // Optional when row is blank
      if (ppcValueTrimed.isEmpty) {
        return null;
      }
      return ProjectContractNumericHelper.isValidDdMmYyyy(ppcValueTrimed)
          ? null
          : "$fieldLabel must be in DD/MM/YYYY format.";
    }

    // Mandatory when other details exist
    if (ppcValueTrimed.isEmpty) {
      return "$fieldLabel is required because other PPC details are provided.";
    }
    return ProjectContractNumericHelper.isValidDdMmYyyy(ppcValueTrimed)
        ? null
        : "$fieldLabel must be in DD/MM/YYYY format.";
  }

  /// Unified helper:
  /// - If `refs` is provided (non-null), it maps list of Reference -> "name,
  /// name".
  /// - Otherwise, if `id` is provided, it maps single id -> name.
  /// - If neither yields data, returns "--".
  String buildNames({
    required List<Reference> options,
    List<Reference>? refs,
    int? id,
  }) {
    // Case 1: List<Reference> -> names
    if (refs != null) {
      if (refs.isEmpty) {
        return "--";
      }
      return refs
          .map(
            (ref) =>
                options
                    .firstWhere(
                      (e) => e.id == ref.id,
                      orElse: () =>
                          Reference(id: 0, name: "--", reference4: "--"),
                    )
                    .name ??
                "--",
          )
          .join(", ");
    }
    // Case 2: Single id -> name
    if (id != null) {
      return options
              .firstWhere(
                (e) => e.id == id,
                orElse: () => Reference(id: 0, name: "--"),
              )
              .name ??
          "--";
    }
    // Fallback
    return "--";
  }

  /// Updates contract value variation field.
  void updateVariationField({double epsilon = 1e-6, bool? isChanged = false}) {
    // Ensure you have AED amounts for both initial and current values
    final double? initialAed =
        double.tryParse(contract.initialContractValue.toString());
    final double? currentAed = isAedRates
        ? double.tryParse(contract.contractValue.toString())
        : double.tryParse(
            contract.contractValueAedAmount.toString().replaceAll(",", ""),
          );
    // contract.contractValueAedAmount ?? contract.contractValue;

    final diff = ProjectContractNumericHelper.computeVariationAed(
      initialAed: initialAed,
      currentAed: currentAed,
    );

    // Update UI field
    final display = ProjectContractNumericHelper.formatSignedOrNA(
      diff,
      epsilon: epsilon,
      trimTrailingZeros: true,
    );
    variationController.text = display;

    // Optionally keep raw variation numeric for backend/save
    contract.variationAmount = (diff?.abs() ?? 0) < epsilon ? 0.0 : diff;

    // If you also store a display string:
    contract.variationContractValue = double.tryParse(display);
  }

  /// Updates completion date variation field.
  void updateCompletionVariation() {
    final diff = ProjectContractNumericHelper.daysDiffSigned(
      contract.originalCompletionDate,
      contract.expectedEndDate,
    );

    //final display = ProjectContractNumericHelper.formatVariationDays(diff);
    // contract.variationCompletionDate = display;
    contract.variationCompletionDate = diff; //diff ?? 0;
    variationCompletionDateController.text = diff.toString();
  }

  //The Business group users, namely RMB, TLB, RMB, CAM, SHB (Business Unit
  //Heads) should be able to create project.
  //Credit team user (Credit Coordinator, Credit Analyst, CC Proxy, BOD Proxy)
  //shall be able to view the projects but cannot edit.

  /// Checks whether the current user has edit access roles.
  bool editAccessRolesCheck() {
    return Utils.checkRoles([
      UserRole.relationshipManager,
      UserRole.relationshipOfficer,
      UserRole.relationshipManagerBussiness,
      UserRole.teamLeaderBusiness,
      UserRole.commercialAreaManager,
      UserRole.segmentHeadBusiness,
    ]);
  }

  /// Checks whether the current user has view access roles.
  bool viewAccessRolesCheck() {
    return Utils.checkRoles([
      UserRole.creditCordinator,
      UserRole.creditAnalyst,
      UserRole.creditCommitteeProxy,
      UserRole.boardDirectorProxy,
    ]);
  }

  /// Cleans null-like object values.
  String clean(Object? value) {
    if (value == null) {
      return "";
    }
    final String str = value.toString();
    if (str.toLowerCase() == "null") {
      return "";
    }
    return str;
  }

  /// Handles back to request status button press.
  Future<void> onBacktoRequestStatusPressed(BuildContext context) async {
    if (canEdit) {
      unawaited(Globals.onAutoSave?.call());
    }
    if (context.mounted) {
      //context.go(Routes.home);
      router.go(Routes.editViewProject, extra: project);
    }
  }

  /// Returns true when the PPC row is blank.
  bool isRowBlank(PpcRowControllers c) => !rowHasAnyInput(c);

  /// Returns true when any PPC row field has input.
  bool rowHasAnyInput(PpcRowControllers c) {
    final List<String> fields = <String>[
      c.ppcCtrl.text,
      c.ppcDateCtrl.text,
      c.grossPPCValueCtrl.text,
      c.advancePaymentDeductionCtrl.text,
      c.retentionDeductionCtrl.text,
      c.vatAmountCtrl.text,
      c.otherPaymentCtrl.text,
      c.actualPaymentReceivedCtrl.text,
      c.datePaymentReceivedCtrl.text,
      // c.commentsCtrl.text,
    ];
    return fields.any((t) => t.trim().isNotEmpty);
  }

  /// PPC table model rows.
  List<PPC> ppcList = [];

  /// PPC table row controllers.
  List<PpcRowControllers> ppcControllerss = [];

  /// Adds a new PPC row.
  void addPPCRow() {
    final bool canAdd = ppcList.isEmpty ||
        ppcControllerss.last.grossPPCValueCtrl.text.trim().isNotEmpty;

    if (!canAdd) {
      return;
    }

    // Add data model
    ppcList.add(
      PPC(
        ppcDate: "",
        datePaymentReceived: "",
        comments: "",
      ),
    );

    // Add controller set
    ppcControllerss.add(PpcRowControllers());

    //Track new row
    isNewRow.add(true);

    emit(
      state.copyWith(
        refreshKey: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        ppcStatus: LoadingStatus.loaded,
      ),
    );
  }

  /// Removes a PPC row at the given index.
  void removePPCRow(int index) {
    if (index < 0 || index >= ppcList.length) {
      return;
    }

    final PpcRowControllers ctrl = ppcControllerss[index];

    // Step 1: remove
    ppcList.removeAt(index);
    ppcControllerss.removeAt(index);
    isNewRow.removeAt(index);

    //Step 2: RECALCULATE from deleted index
    if (ppcList.isNotEmpty) {
      computePpcCommon(
        startIndex: index == 0 ? 0 : index - 1,
        capToContract: false,
      );
    }

    // Step 3: refresh UI
    emit(
      state.copyWith(
        refreshKey: DateTime.now().millisecondsSinceEpoch,
        loaderStatus: LoadingStatus.loaded,
        ppcStatus: LoadingStatus.loaded,
      ),
    );

    // Step 4: dispose
    Future.microtask(ctrl.dispose);
  }

  /// Calculates PPC row values starting at the given index.
  void calculatePPCRowAtIndex(int index) {
    computePpcCommon(startIndex: index, capToContract: false);
  }

  /// Loads PPC rows from API and prepares controllers.
  void loadPpcFromApi(List<PPC> apiList) {
    ppcList.clear();
    ppcControllerss.clear();
    isNewRow.clear();

    for (final PPC item in apiList) {
      ppcList.add(item);

      final PpcRowControllers ctrl = PpcRowControllers();

      /// Bind data safely
      ctrl.ppcCtrl.text = item.ppcNo ?? "";
      ctrl.ppcDateCtrl.text = item.ppcDate ?? "";

      ctrl.grossPPCValueCtrl.text = item.grossValue?.toString() ?? "";
      // ctrl.cumulativePPCValueCtrl.text = item.cumulativeValue?.toString() ?? "";

      // ctrl.workDoneCtrl.text = item.workDone?.toString() ?? "";
      // ctrl.cumulativeWorkDoneCtrl.text = item.cumulativeWorkDone?.toString() ?? "";

      ctrl.advancePaymentDeductionCtrl.text =
          item.advancePaymentDeduction?.toString() ?? "";

      ctrl.retentionDeductionCtrl.text =
          item.retentionDeduction?.toString() ?? "";

      ctrl.vatAmountCtrl.text = item.vatAmount?.toString() ?? "";
      ctrl.otherPaymentCtrl.text = item.otherPayment?.toString() ?? "";

      // ctrl.netValueCtrl.text = item.netValue?.toString() ?? "";
      // ctrl.totalWithVatCtrl.text = item.totalWithVat?.toString() ?? "";

      ctrl.actualPaymentReceivedCtrl.text =
          item.actualPaymentReceived?.toString() ?? "";

      ctrl.datePaymentReceivedCtrl.text = item.datePaymentReceived ?? "";

      // ctrl.commentsCtrl.text = item.comments ?? "";

      ppcControllerss.add(ctrl);

      ///API rows = NOT new
      isNewRow.add(false);
    }

    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        ppcStatus: LoadingStatus.loaded,
      ),
    );
  }

  /// Handles PPC row submit.
  void onSubmitted(
    int index, {
    String date = "",
    String fmt = "",
  }) {
    calculatePPCRowAtIndex(index);

    emit(
      state.copyWith(
        refreshKey: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        ppcStatus: LoadingStatus.loaded,
      ),
    );
  }

  /// Handles PPC row value change.
  void onChanged(int index) {
    calculatePPCRowAtIndex(index);
    emitPpcSoft();
  }

  /// Validates all PPC rows before submit.
  bool validateAllPPCRows() {
    for (int i = 0; i < ppcControllerss.length; i++) {
      final c = ppcControllerss[i];

      // Skip completely blank rows
      if (!rowHasAnyInput(c)) {
        continue;
      }

      // Validate required fields
      if (c.ppcCtrl.text.trim().isEmpty) {
        showError("PPC # is required at row ${i + 1}");
        // showError(
        //   tr("project.viewEditContractDetails.ppcRequired", args: ["${i + 1}"]),
        // );
        return false;
      }

      if (c.ppcDateCtrl.text.trim().isEmpty) {
        showError("PPC Date is required at row ${i + 1}");
        // showError(
        //   tr("project.viewEditContractDetails.ppcDateRequired",
        //       args: ["${i + 1}"]),
        // );
        return false;
      }

      if (c.grossPPCValueCtrl.text.trim().isEmpty) {
        showError("Gross PPC Value is required at row ${i + 1}");
        // showError(
        //   tr("project.viewEditContractDetails.grossPPCValueRequired",
        //       args: ["${i + 1}"]),
        // );
        return false;
      }

      if (c.advancePaymentDeductionCtrl.text.trim().isEmpty) {
        showError("Advance Deduction is required at row ${i + 1}");
        // showError(
        //   tr("project.viewEditContractDetails.advanceDeductionRequired",
        //       args: ["${i + 1}"]),
        // );
        return false;
      }

      if (c.retentionDeductionCtrl.text.trim().isEmpty) {
        showError("Retention Deduction is required at row ${i + 1}");
        // showError(
        //   tr("project.viewEditContractDetails.retentionDeductionRequired",
        //       args: ["${i + 1}"]),
        // );
        return false;
      }

      if (c.vatAmountCtrl.text.trim().isEmpty) {
        showError("VAT Amount is required at row ${i + 1}");
        // showError(
        //   tr("project.viewEditContractDetails.vatAmountRequired",
        //       args: ["${i + 1}"]),
        // );
        return false;
      }

      if (c.otherPaymentCtrl.text.trim().isEmpty) {
        showError("Other Payment is required at row ${i + 1}");
        // showError(
        //   tr("project.viewEditContractDetails.otherPaymentRequired",
        //       args: ["${i + 1}"]),
        // );
        return false;
      }

      // if (c.actualPaymentReceivedCtrl.text.trim().isEmpty) {
      //   showError("Actual Payment Received is required at row ${i + 1}");
      //   showError(
      //   tr("project.viewEditContractDetails.actualPaymentRequired",
      //       args: ["${i + 1}"]),
      // );
      // return false;
      // }

      // if (c.datePaymentReceivedCtrl.text.trim().isEmpty) {
      //   showError("Payment Date is required at row ${i + 1}");
      //   showError(
      //   tr("project.viewEditContractDetails.paymentDateRequired",
      //       args: ["${i + 1}"]),
      // );return false;
      // }

      final double cap =
          double.tryParse(contractorValueController.text.replaceAll(",", "")) ??
              contractValue;
      //  final String alertNewTotal =
      //       ProjectContractNumericHelper.fmt6(getTotalGrossPPC()) ;
      // final String alertcap = ProjectContractNumericHelper.fmt6(cap);
      if (getTotalGrossPPC() > cap) {
        showError(
          //"Total Gross PPC ($alertNewTotal) exceeds Contract Value ($alertcap)",
          "project.viewEditContractDetails.exceedingContractValue".tr(),
        );
        return false;
      }
    }

    return true;
  }

  /// Shows failure toast message.
  void showError(String message) {
    AlertManager().showFailureToast(message);
  }

  /// Returns total gross PPC value.
  double getTotalGrossPPC({int? ignoreIndex}) {
    double total = 0;

    for (int i = 0; i < ppcControllerss.length; i++) {
      if (ignoreIndex != null && i == ignoreIndex) {
        continue;
      }

      final double val =
          double.tryParse(ppcControllerss[i].grossPPCValueCtrl.text) ?? 0;
      total += val;
    }

    return total;
  }

  /// Recalculates all PPC rows.
  void recalculateAllPPC() {
    computePpcCommon(startIndex: 0, capToContract: true);

    emit(
      state.copyWith(
        refreshKey: DateTime.now().millisecondsSinceEpoch,
        loaderStatus: LoadingStatus.loaded,
        ppcStatus: LoadingStatus.loaded,
      ),
    );
  }

  double _toDouble(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(",", "")) ?? 0.0;
  //bool _isContractErrorShown = false;

  /// Computes PPC fields from a starting row.
  void computePpcCommon({
    required int startIndex,
    required bool capToContract,
  }) {
    double cumulative = 0;

    final double contractVal =
        double.tryParse(contractorValueController.text.replaceAll(",", "")) ??
            contractValue;

    if (capToContract) {
      if (getTotalGrossPPC() > contractVal) {
        // if (!_isContractErrorShown) {
        showError(
          "project.viewEditContractDetails.exceedingContractValue".tr(),
        );
        //_isContractErrorShown = true;
        // }
        return;
      } else {
        // Reset when valid again
        // _isContractErrorShown = false;
      }
    }

    // Calculate cumulative before startIndex
    for (int i = 0; i < startIndex; i++) {
      cumulative += ppcList[i].grossValue ?? 0;
    }

    // Loop from startIndex
    for (int i = startIndex; i < ppcList.length; i++) {
      final PPC row = ppcList[i];
      final PpcRowControllers c = ppcControllerss[i];

      final double gross = _toDouble(c.grossPPCValueCtrl);
      final double advance = _toDouble(c.advancePaymentDeductionCtrl);
      final double retention = _toDouble(c.retentionDeductionCtrl);
      final double vat = _toDouble(c.vatAmountCtrl);
      final double other = _toDouble(c.otherPaymentCtrl);
      final double actual = _toDouble(c.actualPaymentReceivedCtrl);
      final double ppcno = _toDouble(c.ppcCtrl);

      final bool isEmpty = c.grossPPCValueCtrl.text.trim().isEmpty;

      // Empty row handling
      if (isEmpty) {
        row
          ..cumulativeValue = cumulative
          ..workDone = 0
          ..cumulativeWorkDone = 0
          ..netValue = 0
          ..totalWithVat = 0;
        continue;
      }

      final double adjustedGross = gross;

      // Optional cap logic (used in recalculateAllPPC)
      if (capToContract) {
        final double temp = cumulative + gross;
        // if (temp > contractVal) { no need check contract value
        //   adjustedGross = (contractVal - cumulative).clamp(0, contractVal);
        //   cumulative = contractVal;
        // } else {
        cumulative = temp;
        // }
      } else {
        cumulative += gross;
      }

      // Percent calculations
      double workDone = contractVal > 0
          ? (adjustedGross / contractVal * 100).clamp(0, 100)
          : 0;

      double cumulativeWorkDone =
          contractVal > 0 ? (cumulative / contractVal * 100).clamp(0, 100) : 0;

      if (cumulativeWorkDone > 100) {
        cumulativeWorkDone = 100;
      }

      if (workDone > 100) {
        workDone = 100;
      }
      // Assign
      row
        ..ppcNo = ppcno.toString()
        ..grossValue = adjustedGross
        ..cumulativeValue = cumulative
        ..advancePaymentDeduction = advance
        ..retentionDeduction = retention
        ..vatAmount = vat
        ..otherPayment = other
        ..actualPaymentReceived = actual
        ..workDone = workDone
        ..cumulativeWorkDone = cumulativeWorkDone
        ..netValue = adjustedGross - advance - retention
        ..totalWithVat = (adjustedGross - advance - retention) + vat + other;

      logger.i(row.toJson().toString());
    }
  }
}

/// Controllers for one PPC row.
class PpcRowControllers {
  /// PPC number controller.
  final TextEditingController ppcCtrl = TextEditingController();

  /// PPC date controller.
  final TextEditingController ppcDateCtrl = TextEditingController();

  /// Gross PPC value controller.
  final TextEditingController grossPPCValueCtrl = TextEditingController();

  /// Advance payment deduction controller.
  final TextEditingController advancePaymentDeductionCtrl =
      TextEditingController();

  /// Retention deduction controller.
  final TextEditingController retentionDeductionCtrl = TextEditingController();

  /// VAT amount controller.
  final TextEditingController vatAmountCtrl = TextEditingController();

  /// Other payment controller.
  final TextEditingController otherPaymentCtrl = TextEditingController();

  /// Actual payment received controller.
  final TextEditingController actualPaymentReceivedCtrl =
      TextEditingController();

  /// Date payment received controller.
  final TextEditingController datePaymentReceivedCtrl = TextEditingController();

  /// Disposes all row controllers.
  void dispose() {
    ppcCtrl.dispose();
    ppcDateCtrl.dispose();
    grossPPCValueCtrl.dispose();
    advancePaymentDeductionCtrl.dispose();
    retentionDeductionCtrl.dispose();
    vatAmountCtrl.dispose();
    otherPaymentCtrl.dispose();
    actualPaymentReceivedCtrl.dispose();
    datePaymentReceivedCtrl.dispose();
  }
}
