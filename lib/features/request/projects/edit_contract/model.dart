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
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";
import "package:wcas_frontend/repositories/project_repository.dart";

class EditContractViewModel extends SafeCubit<EditContractState>
    with DraftMixin<EditContractViewModel> {
  EditContractViewModel()
      : super(
          EditContractState(
            loaderStatus: LoadingStatus.loading,
            linkCommitmentStatus: LoadingStatus.loading,
            ppcStatus: LoadingStatus.loading,
          ),
        );

  late ProjectRepository repository;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<String> dropdownItems = ["Main Contractor", "Sub-Contractor"];
  Map<String, List<Reference>> referenceData = {};

  TextEditingController convertedAmountController = TextEditingController();
  TextEditingController contractorValueController = TextEditingController();

  List<Reference> countryCodes = [];

  List<Reference>? borrowerRole = [];
  List<Reference>? facilityType = [];

  TextEditingController searchRimController = TextEditingController();
  TextEditingController searchNameController = TextEditingController();
  TextEditingController customerRimController = TextEditingController();
  TextEditingController customerNameController = TextEditingController();
  TextEditingController projectTenorController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController completionDateController = TextEditingController();
  TextEditingController paymasterNameController = TextEditingController();
  TextEditingController contractorScopeController = TextEditingController();
  TextEditingController contractorCommentsController = TextEditingController();
  TextEditingController completionPercentageController =
      TextEditingController();
  TextEditingController variationController = TextEditingController();
  TextEditingController variationCompletionDateController =
      TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  String? selectedCurrencyLabel = ServerConstants.aedCurrency;

  static const Map<String, double> _exchangeRates = {
    "AED": 1.0,
    "USD": 3.67,
    "KWD": 0.044,
  };

  Reference? selectedBorrowerRole;
  Reference? selectedContractValueCurrency;
  bool isAedRates = false;
  bool isAddPPC = true;

  Contract contract = Contract();
  List<PPC> ppc = [];
  List<LinkCommitmentNumber>? linkContract = [];
  late Project project = Project();
  late Contract contracts;

  List<Comment> commentItem = [];
  List<String> commentInputs = [""];
  List<String> getCommentInputs() => commentInputs;
  // List<ContractComment> getComments() => comments;

  // Contract value (needed for % calculations)
  double contractValue = 0;
  String? customerNameContract;

  // Model rows + controllers
  List<PpcControllers> ppcControllers = [];
  bool get canEdit => pageMode == PageMode.edit;
  PageMode pageMode = PageMode.na;
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

  Future<void> init(
    context, {
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
    for (final c in ppcControllers) {
      c.dispose(); // - SAFE: widget tree is gone
    }
    ppcControllers.clear();

    unregisterDraftCallback();
    return super.close();
  }

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
    } catch (e) {
      if (e.toString().isNotEmpty) {
        AlertManager().showFailureToast(e.toString());
      }
    }
  }

// --------------------------------------------------
// Sync MODEL ← STATIC controllers
// (used before saving draft / submit)
// --------------------------------------------------
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

  Future<void> onReset(BuildContext context) async {
    //  => await callInitMethod();
    if (context.mounted) {
      context.go(Routes.editViewProject, extra: project);
    }
  }

  Future<void> getcountryCode() async {
    try {
      countryCodes = await repository.getcountryCode();
      //sorting for make AED in first
      countryCodes.sort(
        (a, b) =>
            (b.name?.toUpperCase() == ReferenceDataKeys.currencyAED ? 1 : 0) -
            (a.name?.toUpperCase() == ReferenceDataKeys.currencyAED ? 1 : 0),
      );
      final Reference aed = countryCodes.firstWhere(
        (r) => (r.name ?? r.name)?.toUpperCase() == ServerConstants.aedCurrency,
        orElse: () =>
            countryCodes.isNotEmpty ? countryCodes.first : Reference(),
      );
      aed;

      selectedContractValueCurrency = null;
      if (contract.contractCurrency != null) {
        selectedContractValueCurrency = countryCodes.firstWhere(
          (element) => element.name == contract.contractCurrency,
          orElse: () => Reference(name: contract.contractCurrency),
        );
        isAEDCurrencyRate(contract: contract);
      }
    } catch (e) {
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

      if ((contract.appRefNo ?? "").isNotEmpty) {
        await fetchAndSetStrategyComments(appRefNo: contract.appRefNo);
      }

      if ((contract.ppcList ?? []).isNotEmpty) {
        ppc = contract.ppcList ?? [];

        // >>> Initialize per-row "new" flags for API-loaded rows (all false)
        isNewRow = List<bool>.filled(ppc.length, false, growable: true);

        emit(
          state.copyWith(
            loaderStatus: LoadingStatus.loaded,
            ppcStatus: LoadingStatus.loaded,
          ),
        );
      }

      recomputeDerived();
      initializeControllers(ppc);

      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.loaded,
          ppcStatus: LoadingStatus.loaded,
        ),
      );

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches project details from the repository and updates the state.
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
    } catch (e) {
      rethrow;
    }
  }

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
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadReferenceData() async {
    try {
      referenceData = await ReferenceDataService().getReferenceData(
        [ReferenceDataKeys.borrowerRole, ReferenceDataKeys.facilityTypes],
      );
      borrowerRole = referenceData[ReferenceDataKeys.borrowerRole] ?? [];
      facilityType = referenceData[ReferenceDataKeys.facilityTypes] ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchAndSetStrategyComments({String? appRefNo}) async {
    try {
      final List<Comment> comments =
          await CommonRepository.instance.getStategyComment(
        ServerConstants.commentTypeId[CommentsType.contract],
        ServerConstants.strategyCategoryContract,
        appRefNo: appRefNo,
      );

      commentItem = comments
          .where(
            (item) => item.categoryId == ServerConstants.contractCategoryID,
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
    } catch (e) {
      commentItem = [Comment(strategyComment: "")];
      logger.e("Error fetching strategy comments: $e");
    }
  }

// Called when user picks a currency
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
  bool isAEDCurrencyRate({Reference? ref, Contract? contract}) {
    // Prefer explicit ref.name, else contract.contractCurrency, else previously
    // selected label
    final code =
        (ref?.name ?? contract?.contractCurrency ?? selectedCurrencyLabel ?? "")
            .toUpperCase();

    return isAedRates = code == ServerConstants.aedCurrency;
  }

  num exchangeRate = 0;

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
      final String formattedAED = formatter.format(convertedValue.toDouble());
      if (isFirst == false) {
        contract.contractValueAedAmount = formattedAED;
      }
      // Update the correct controller (present vs proposed)
      convertedAmountController.value = TextEditingValue(
        text: formattedAED,
        selection: TextSelection.collapsed(offset: formattedAED.length),
      );
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
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

    if (ppcControllers.isNotEmpty && _isRowBlank(ppcControllers.last)) {
      AlertManager().showFailureToast(
        "project.viewEditContractDetails.requiredFieldPPC".tr(),
      );
      return;
    }

    // 1) Hard validation (source of truth)
    final bool isValidDate = ProjectContractNumericHelper.validateDates(
      start: _startDate,
      end: _endDate,
      rules: rules,
      showToast: true, // show the user why we're blocking
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
        ..ppcList = ppc;

      //contract.toSaveContractJson();
      //logger.d('Submitting contract: ${contract.toSaveContractJson()}');
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
    } catch (e) {
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
      showToast: true,
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

  void onCompletionDateSubmitted2(
    DateTime? raw, {
    YearRules rules = const YearRules(),
  }) {
    _endDate = raw;
    final DateTime? proposedEnd = ProjectContractNumericHelper.dateOnly(raw);

    // Validate proposed end vs current start
    final bool isValidDate = ProjectContractNumericHelper.validateDates(
      start: _startDate,
      end: proposedEnd,
      rules: rules,
      showToast: true,
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
  }

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

    if (isFirst == true) {
      _updateTenor(rules: rules);
    }
  }

  void onOriginalCompletionDateSubmitted2(DateTime? raw) {
    logger.d('Picked end="$raw"');
    if (raw != null) {
      contract.originalCompletionDate = raw;
      updateCompletionVariation(); // <-- ADD THIS
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
    if (list == null || index < 0 || index >= list.length) return;

    list.removeAt(index);

    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        linkCommitmentStatus: LoadingStatus.loaded,
      ),
    );
  }

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

  // Add a new empty input row in the UI (not a Comment yet)
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
  void updateCommentInput(int index, String value) {
    if (index >= 0 && index < commentInputs.length) {
      commentInputs[index] = value;
      contractorCommentsController.text = value;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  void clearCommentInputs({bool leaveOneBlank = true}) {
    commentInputs.clear();
    if (leaveOneBlank) {
      commentInputs.add("");
      contractorCommentsController.text = "";
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

// Used ONLY for draft restore
  void setDraftComment(String? value) {
    contractorCommentsController.text = value ?? "";
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

// Clear after successful submit
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
  //       } catch (e) {
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

  Future<void> submitComments() async {
    final text = contractorCommentsController.text.trim();

    if (text.isEmpty) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return;
    }

    try {
      final payload = Comment.fromInputData(
        type: CommentsType.contract,
        strategyComment: text,
        entityType: EntityIdentifier.contract,
        categoryId: ServerConstants.commentTypeId[CommentsType.contract],
        strategyCategory: ServerConstants.strategyCategoryContract,
      );

      if ((contract.appRefNo ?? "").isNotEmpty) {
        await CommonRepository.instance.saveStategyComment(
          payload,
          appRefNo: contract.appRefNo,
          rimNo: int.tryParse(contract.rimNo.toString()),
        );
      }

      //Clear after success
      clearDraftComment();

      if ((contract.appRefNo ?? "").isNotEmpty) {
        await fetchAndSetStrategyComments(
          appRefNo: contract.appRefNo,
        );
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

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

  int ppcControllerGeneration = 0;
  // ---------- CONTROLLERS INIT ----------
  void initializeControllers(List<PPC> rows) {
    // 1) Dispose old controllers (optional: detach listeners first if stored)

    // for (final controller in ppcControllers) {
    //   // If you kept references to listeners per row:
    //   // _detachRowListeners(controller);
    //   controller.dispose();
    // }

    // 2) Replace your data model list to mirror controllers (keep indices
    // aligned)
    // If rows is the authoritative list, update ppc to rows.
    // If ppc is already set elsewhere, skip this line.
    ppc = List<PPC>.from(rows);

    // 3) Create controllers per row with null-safe text
    ppcControllers = rows.map((row) {
      return PpcControllers._(
        ppcCtrl: TextEditingController(
          text: row.ppcNo
              .toString(), //?? ProjectContractNumericHelper.fmt6(row.ppc ?? 0),
        ),
        ppcDateCtrl: TextEditingController(text: row.ppcDate ?? ""),

        grossPPCValueCtrl: TextEditingController(
          text: ProjectContractNumericHelper.fmt6(row.grossPpcValue),
        ),

        advancePaymentDeductionCtrl: TextEditingController(
          text: ProjectContractNumericHelper.fmt6(row.advancePaymentDeduction),
        ),

        retentionDeductionCtrl: TextEditingController(
          text: ProjectContractNumericHelper.fmt6(row.retentionDeduction),
        ),

        vatAmountCtrl: TextEditingController(
          text: ProjectContractNumericHelper.fmt6(row.vatAmount),
        ),

        otherPaymentCtrl: TextEditingController(
          text: ProjectContractNumericHelper.fmt6(row.otherPayment),
        ),

        actualPaymentReceivedCtrl: TextEditingController(
          text: ProjectContractNumericHelper.fmt6(row.actualPaymentReceived),
        ),

        datePaymentReceivedCtrl: TextEditingController(
          text: row.datePaymentReceived ?? "",
        ),

        commentsCtrl: TextEditingController(text: row.comments ?? ""),

        // ---- Cumulative & percent fields: avoid "null" by using fmt6 or empty
        // ----
        cumulativePPCValueCtrl: TextEditingController(
          text: ProjectContractNumericHelper.fmt6(row.cumulativePPCValue),
        ),
        cumulativePpcValueCtrl: TextEditingController(
          text: ProjectContractNumericHelper.fmt6(row.cumulativePpcValue),
        ),
        cumulativeWorkDoneCtrl: TextEditingController(
          text: ProjectContractNumericHelper.fmt6(row.cumulativeWorkDone),
        ),
        cumulativeWorkDonePercentCtrl: TextEditingController(
          text:
              ProjectContractNumericHelper.fmt6(row.cumulativeWorkDonePercent),
        ),
        netCertifiedAmountVatCtrl: TextEditingController(
          text: ProjectContractNumericHelper.fmt6(row.netCertifiedAmountVat),
        ),
        netPPCValueCtrl: TextEditingController(
          text: ProjectContractNumericHelper.fmt6(row.netPPCValue),
        ),
        workDoneCtrl: TextEditingController(
          text: ProjectContractNumericHelper.fmt6(row.workDone),
        ),
        workDonePercentCtrl: TextEditingController(
          text: ProjectContractNumericHelper.fmt6(row.workDonePercent),
        ),
      );
    }).toList();

    // 4) Attach listeners for each new controller row so edits sync back to the
    // model
    for (var i = 0; i < ppcControllers.length; i++) {
      _attachRowListeners(
        ppcControllers[i],
        i,
      ); // internally resolves index dynamically
    }

    // Optionally recompute derived values after reload
    recomputeDerived();

    // VERY IMPORTANT
    ppcControllerGeneration++;

    // Emit UI update
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        ppcStatus: LoadingStatus.loaded,
      ),
    );
  }

  bool isRestoringDraft = false;

// bool get isRestoringDraft => _isRestoringDraft;
//
  // ---------- SYNC: controllers -> model, then recompute ----------
  void syncRowFromControllers(int index) {
    if (isRestoringDraft) return;
    final ctrls = ppcControllers[index];
    final old = ppc[index];

    ppc[index] = PPC(
      // ppcId: int.tryParse(ctrls.ppcCtrl.text),
      ppc:
          ProjectContractNumericHelper.ppcRowSyncParseValue(ctrls.ppcCtrl.text),
      ppcDate: ctrls.ppcDateCtrl.text,
      grossPPCValue: ProjectContractNumericHelper.ppcRowSyncParseValue(
        ctrls.grossPPCValueCtrl.text,
      ),
      cumulativePPCValue: ProjectContractNumericHelper.ppcRowSyncParseValue(
        ctrls.cumulativePPCValueCtrl.text,
      ),
      workDonePercent: ProjectContractNumericHelper.ppcRowSyncParseValue(
        ctrls.workDonePercentCtrl.text,
      ),
      cumulativeWorkDonePercent:
          ProjectContractNumericHelper.ppcRowSyncParseValue(
        ctrls.cumulativeWorkDonePercentCtrl.text,
      ),
      netPPCValue: ProjectContractNumericHelper.ppcRowSyncParseValue(
        ctrls.netPPCValueCtrl.text,
      ),
      // Legacy/lowerCamel numerics:
      grossPpcValue: ProjectContractNumericHelper.ppcRowSyncParseValue(
        ctrls.grossPPCValueCtrl.text,
      ),
      cumulativePpcValue: ProjectContractNumericHelper.ppcRowSyncParseValue(
        ctrls.cumulativePpcValueCtrl.text,
      ),
      workDone: ProjectContractNumericHelper.ppcRowSyncParseValue(
        ctrls.workDoneCtrl.text,
      ),
      cumulativeWorkDone: ProjectContractNumericHelper.ppcRowSyncParseValue(
        ctrls.cumulativeWorkDoneCtrl.text,
      ),
      advancePaymentDeduction:
          ProjectContractNumericHelper.ppcRowSyncParseValue(
        ctrls.advancePaymentDeductionCtrl.text,
      ),
      retentionDeduction: ProjectContractNumericHelper.ppcRowSyncParseValue(
        ctrls.retentionDeductionCtrl.text,
      ),
      netPpcValue: ProjectContractNumericHelper.ppcRowSyncParseValue(
        ctrls.netPPCValueCtrl.text,
      ), // if you use the same field
      vatAmount: ProjectContractNumericHelper.ppcRowSyncParseValue(
        ctrls.vatAmountCtrl.text,
      ),
      otherPayment: ProjectContractNumericHelper.ppcRowSyncParseValue(
        ctrls.otherPaymentCtrl.text,
      ),
      netCertifiedAmountVat: ProjectContractNumericHelper.ppcRowSyncParseValue(
        ctrls.netCertifiedAmountVatCtrl.text,
      ),
      actualPaymentReceived: ProjectContractNumericHelper.ppcRowSyncParseValue(
        ctrls.actualPaymentReceivedCtrl.text,
      ),

      datePaymentReceived: ctrls.datePaymentReceivedCtrl.text,
      comments: ctrls.commentsCtrl.text,

      // Optional: preserve fields that aren’t part of controllers (e.g.,
      // contractorId, ppcNo)
      contractorId: old.contractorId,
      ppcNo: old.ppcNo,
    );

    // If you compute derived totals, do it here or outside
    recomputeDerived();
  }

  // ---------- DERIVED ----------
  void recomputeDerived() {
    // Emit initial state changes
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        ppcStatus: LoadingStatus.loading,
      ),
    );

    double runningCumulative = 0;

    // Guard: non-positive contractValue disables % calculations and capping
    // logic
    final bool hasPositiveContract =
        (double.tryParse(contractorValueController.text.toString()) ??
                contractValue) >
            0.0;
    final double contractCap =
        hasPositiveContract ? contractValue : double.infinity;

    for (final row in ppc) {
      // Input gross for this row (requested)
      double requestedGross = row.grossPPCValue ?? 0.0;

      // Normalize negatives: treat negative gross as 0 (optional business rule)
      if (requestedGross < 0) {
        requestedGross = 0.0;
      }

      // (A) Cap the applied gross so cumulative never exceeds contract value
      // Remaining headroom before this row:
      final double remainingHeadroom = (contractCap.isFinite
          ? (contractCap - runningCumulative)
          : double.infinity);

      // If remaining headroom <= 0, no further gross can be applied
      final double appliedGross = remainingHeadroom <= 0
          ? 0.0
          : requestedGross.clamp(0.0, remainingHeadroom);

      // Optional: mark/record capping for UI transparency (if your model supports these fields)
      // row.wasCapped = (appliedGross < requestedGross);
      // row.appliedGrossPPCValue = appliedGross;

      // Use appliedGross for all downstream calculations
      final double gross = appliedGross;

      // (1) Cumulative PPC Value = running total of applied gross
      runningCumulative += gross;
      row.cumulativePPCValue = runningCumulative;

      // Inputs
      final double adv = row.advancePaymentDeduction ?? 0.0;
      final double ret = row.retentionDeduction ?? 0.0;
      final double vat = row.vatAmount ?? 0.0;
      final double other = row.otherPayment ?? 0.0;

      // (4) Net PPC Value = Gross – Advance – Retention
      final double net = gross - adv - ret;
      row
        ..advancePaymentDeduction = adv
        ..retentionDeduction = ret
        ..netPPCValue = net;

      // (5) Net Certified Amount + VAT = Net + VAT + Other
      final double total = net + vat + other;
      row.netCertifiedAmountVat = total;

      // Percentages (show 0 when not computable)
      if (hasPositiveContract) {
        // (2) % Work Done based on applied gross
        final double workDonePercent = (gross / contractValue) * 100.0;
        row.workDonePercent =
            double.tryParse(ProjectContractNumericHelper.fmt4(workDonePercent));

        // (3) % Cumulative Work Done based on capped cumulative
        final double cumulativeWorkDonePercent =
            (runningCumulative / contractValue) * 100.0;
        row.cumulativeWorkDonePercent = double.tryParse(
          ProjectContractNumericHelper.fmt4(cumulativeWorkDonePercent),
        );
      } else {
        row
          ..workDonePercent = 0.0
          ..cumulativeWorkDonePercent = 0.0;
      }

      // Optional: If you prefer to visibly overwrite the requested gross when
      // capped:
      // row.grossPPCValue = gross;
    }

    // KEEP your existing soft emit
    emitPpcSoft();
  }

  // Track which PPC rows are newly added (true) vs loaded from API (false)
  List<bool> isNewRow = [];

  // Flag to control PPC table edit mode
  bool isPpcEditable = false;

  // Toggle helpers
  void enablePpcEditMode() {
    isPpcEditable = true;
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        ppcStatus: LoadingStatus.loaded,
      ),
    );
  }

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
  bool _isRowBlank(PpcControllers c) => !_rowHasAnyInput(c);
  void onAddRowPressed() {
    if (ppcControllers.isNotEmpty && _isRowBlank(ppcControllers.last)) {
      AlertManager().showFailureToast(
        "project.viewEditContractDetails.requiredFieldPPCaddRow".tr(),
      );

      return;
    }
    addPpcRow(); // your existing method
  }

  void addPpcRow() {
    final newRow = PPC(
      ppc: null,
      ppcDate: "",
      grossPPCValue: null,
      cumulativePPCValue: null,
      workDonePercent: null,
      cumulativeWorkDonePercent: null,
      netPPCValue: null,
      contractorId: null,
      ppcNo: null,
      grossPpcValue: null,
      cumulativePpcValue: null,
      workDone: null,
      cumulativeWorkDone: null,
      advancePaymentDeduction: null,
      retentionDeduction: null,
      netPpcValue: null,
      vatAmount: null,
      otherPayment: null,
      netCertifiedAmountVat: null,
      actualPaymentReceived: null,
      datePaymentReceived: "",
      comments: "",
    );

    // Append model
    ppc = List<PPC>.from(ppc)..add(newRow);

    // Create fresh controllers and attach listeners
    final newCtrls = PpcControllers.empty()
      // (Optional) preload from model explicitly, will set all to empty strings
      ..loadFromModel(newRow);

    final index = ppcControllers.length;
    _attachRowListeners(newCtrls, index);

    // Append controllers
    ppcControllers = List<PpcControllers>.from(ppcControllers)..add(newCtrls);

    // Mark as new
    isNewRow = List<bool>.from(isNewRow)..add(true);

    recomputeDerived();
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        ppcStatus: LoadingStatus.loaded,
      ),
    );
  }

  // In removePpcRow(): keep existing logic and remove the flag accordingly
  void removePpcRow(int index) {
    if (index < 0 || index >= ppcControllers.length) return;

    // If you stored per-row listeners, detach first:
    // _detachRowListeners(ppcControllers[index]);
    ppcControllers[index].dispose();

    ppc = List<PPC>.from(ppc)..removeAt(index);
    ppcControllers = List<PpcControllers>.from(ppcControllers)..removeAt(index);
    isNewRow = List<bool>.from(isNewRow)..removeAt(index);

    recomputeDerived();
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        ppcStatus: LoadingStatus.loaded,
      ),
    );
  }

  Timer? _ppcEmitDebounce;
  void emitPpcSoft() {
    if (isRestoringDraft) return;
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

  /// Attach per-field listeners so logic applies only when the user types
  void _attachRowListeners(PpcControllers c, int rowIndex) {
    void onChanged() {
      final currentIndex = ppcControllers.indexOf(c);
      if (currentIndex < 0 || currentIndex >= ppc.length) return;

      // Sync row from these controllers
      syncRowFromControllers(currentIndex);
      emitPpcSoft();
      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.loaded,
          ppcStatus: LoadingStatus.loaded,
        ),
      );
    }

    c.ppcCtrl.addListener(onChanged);
    c.ppcDateCtrl.addListener(onChanged);
    c.grossPPCValueCtrl.addListener(onChanged);
    c.cumulativePpcValueCtrl.addListener(onChanged);
    c.cumulativePPCValueCtrl.addListener(onChanged);
    c.workDoneCtrl.addListener(onChanged);
    c.workDonePercentCtrl.addListener(onChanged);
    c.cumulativeWorkDoneCtrl.addListener(onChanged);
    c.cumulativeWorkDonePercentCtrl.addListener(onChanged);
    c.advancePaymentDeductionCtrl.addListener(onChanged);
    c.retentionDeductionCtrl.addListener(onChanged);
    c.netPPCValueCtrl.addListener(onChanged);
    c.vatAmountCtrl.addListener(onChanged);
    c.otherPaymentCtrl.addListener(onChanged);
    c.netCertifiedAmountVatCtrl.addListener(onChanged);
    c.actualPaymentReceivedCtrl.addListener(onChanged);
    c.datePaymentReceivedCtrl.addListener(onChanged);
    c.commentsCtrl.addListener(onChanged);
  }

  // ---------- DISPOSE ----------
  void disposeControllers() {
    for (final c in ppcControllers) {
      c.dispose();
    }
    ppcControllers.clear();
  }

  // Prevent multiple adds when Enter is pressed rapidly
  DateTime? _lastRowSubmitTs;
  final Duration _rowSubmitCooldown = const Duration(milliseconds: 600);

  // Track last alert tag to avoid repeated alerts
  DateTime? _lastAlertTs;
  String? _lastAlertTag;
  final Duration _alertCooldown = const Duration(seconds: 2);

  // Helper: show one-time alert per tag within cooldown
  void _showFailureToastOnce(String message, {String tag = "generic"}) {
    final now = DateTime.now();
    if (_lastAlertTag == tag && _lastAlertTs != null) {
      if (now.difference(_lastAlertTs!) < _alertCooldown) {
        return; // suppress duplicates
      }
    }
    _lastAlertTag = tag;
    _lastAlertTs = now;
    AlertManager().showFailureToast(message);
  }

  // Detect any content in the row
  bool _rowHasAnyInput(PpcControllers c) {
    final fields = <String>[
      c.ppcCtrl.text,
      c.ppcDateCtrl.text,
      c.grossPPCValueCtrl.text,
      c.advancePaymentDeductionCtrl.text,
      c.retentionDeductionCtrl.text,
      c.vatAmountCtrl.text,
      c.otherPaymentCtrl.text,
      c.actualPaymentReceivedCtrl.text,
      c.datePaymentReceivedCtrl.text,
      c.commentsCtrl.text,
    ];
    return fields.any((t) => t.trim().isNotEmpty);
  }

  // Guarded submit handler to avoid duplicate row adds & repeated alerts

  void handleSubmitForRow(
    BuildContext context,
    PpcControllers ctrls,
    int index,
    VoidCallback onAnyFieldChanged,
  ) {
    final now = DateTime.now();

    // Cooldown: ignore repeated Enter presses for a short period
    if (_lastRowSubmitTs != null &&
        now.difference(_lastRowSubmitTs!) < _rowSubmitCooldown) {
      // Just move focus forward; do not re-submit or re-alert
      FocusScope.of(context).nextFocus();
      return;
    }
    _lastRowSubmitTs = now;

    // If row is blank: don't submit, move focus and show single-shot alert
    if (!_rowHasAnyInput(ctrls)) {
      FocusScope.of(context).nextFocus();
      _showFailureToastOnce(
        "project.viewEditContractDetails.requiredFieldPPCbeforesubmit".tr(),
        //"Please enter at least one value in this row before submitting.",
        tag: "row_blank_submit_$index",
      );
      return;
    }

    // --- ADD: re-entrancy guard (optional)
    if (_currentlySubmittingIndex == index) {
      return;
    }
    _currentlySubmittingIndex = index;

    try {
      // Determine row type using your existing flag list
      final bool isRowEditableFlag =
          (index < isNewRow.length) && isNewRow[index];
      final bool isApiRow = !isRowEditableFlag;

      if (isApiRow) {
        // API row: avoid full-table recompute to prevent downstream duplication
        syncRowFromControllersSoft(index);

        final bool hasGross = ctrls.grossPPCValueCtrl.text.trim().isNotEmpty;
        if (hasGross) {
          recomputeDerivedForSingleRow(index); // only current row updates
        } else {
          emitPpcSoft(); // refresh UI while keeping API-derived values intact
        }

        // Keep UX consistent: advance focus inside the row
        FocusScope.of(context).nextFocus();
      } else {
        // New rows: keep your original behavior
        onAnyFieldChanged();
      }
    } finally {
      _currentlySubmittingIndex = null;
    }
  }

// In model.dart, inside EditContractViewModel { ... }
// ADD: a soft sync that updates only this row from controllers without calling
// recomputeDerived()
  void syncRowFromControllersSoft(int index) {
    final ctrls = ppcControllers[index];
    final old = ppc[index];
    ppc[index] = PPC(
      ppcId: old.ppcId,
      ppc:
          ProjectContractNumericHelper.ppcRowSyncParseValue(ctrls.ppcCtrl.text),
      ppcDate: ctrls.ppcDateCtrl.text,

      // accept lowerCamel
      grossPpcValue: ProjectContractNumericHelper.ppcRowSyncParseValue(
        ctrls.grossPPCValueCtrl.text,
      ),
      cumulativePpcValue:
          old.cumulativePpcValue, // keep; will be recomputed below
      workDone: old.workDone, // keep; will be recomputed below
      cumulativeWorkDone:
          old.cumulativeWorkDone, // keep; will be recomputed below
      netPpcValue: old.netPpcValue, // keep; will be recomputed below

      // keep uppercase mirrors too
      grossPPCValue: ProjectContractNumericHelper.ppcRowSyncParseValue(
        ctrls.grossPPCValueCtrl.text,
      ),
      cumulativePPCValue: old.cumulativePPCValue,
      workDonePercent: old.workDonePercent,
      cumulativeWorkDonePercent: old.cumulativeWorkDonePercent,
      netPPCValue: old.netPPCValue,

      advancePaymentDeduction:
          ProjectContractNumericHelper.ppcRowSyncParseValue(
        ctrls.advancePaymentDeductionCtrl.text,
      ),
      retentionDeduction: ProjectContractNumericHelper.ppcRowSyncParseValue(
        ctrls.retentionDeductionCtrl.text,
      ),
      vatAmount: ProjectContractNumericHelper.ppcRowSyncParseValue(
        ctrls.vatAmountCtrl.text,
      ),
      otherPayment: ProjectContractNumericHelper.ppcRowSyncParseValue(
        ctrls.otherPaymentCtrl.text,
      ),
      netCertifiedAmountVat: old.netCertifiedAmountVat, // recomputed below

      actualPaymentReceived: ProjectContractNumericHelper.ppcRowSyncParseValue(
        ctrls.actualPaymentReceivedCtrl.text,
      ),
      datePaymentReceived: ctrls.datePaymentReceivedCtrl.text,

      contractorId: old.contractorId,
      ppcNo: old.ppcNo,
      comments: ctrls.commentsCtrl.text,
    );
    // intentionally no global recompute here
  }

// ADD: recompute only ONE row’s derived values using previous row’s cumulative
// as baseline
  void recomputeDerivedForSingleRow(int index) {
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        ppcStatus: LoadingStatus.loading,
      ),
    );
    if (index < 0 || index >= ppc.length) {
      emitPpcSoft();
      return;
    }

    final bool hasPositiveContract =
        (double.tryParse(contractorValueController.text.toString()) ??
                contractValue) >
            0.0;
    final double contractCap =
        hasPositiveContract ? contractValue : double.infinity;

    final double prevCum = (index > 0)
        ? (ppc[index - 1].cumulativePPCValue ??
            ppc[index - 1].cumulativePpcValue ??
            0.0)
        : 0.0;
    final row = ppc[index];

    double requestedGross = row.grossPpcResolved ?? 0.0;
    if (requestedGross < 0) requestedGross = 0.0;

    final double remainingHeadroom =
        (contractCap.isFinite ? (contractCap - prevCum) : double.infinity);
    final double appliedGross = remainingHeadroom <= 0
        ? 0.0
        : requestedGross.clamp(0.0, remainingHeadroom);

    final double runningCumulative = prevCum + appliedGross;
    row
      ..cumulativePPCValue = runningCumulative
      ..cumulativePpcValue = runningCumulative;

    final double adv = row.advancePaymentDeduction ?? 0.0;
    final double ret = row.retentionDeduction ?? 0.0;
    final double vat = row.vatAmount ?? 0.0;
    final double other = row.otherPayment ?? 0.0;

    final double net = appliedGross - adv - ret;
    row
      ..netPPCValue = net
      ..netPpcValue = net;

    final double total = net + vat + other;
    row.netCertifiedAmountVat = total;

    if (hasPositiveContract) {
      final double workDonePercent = (appliedGross / contractValue) * 100.0;
      final double cumulativeWorkDonePercent =
          (runningCumulative / contractValue) * 100.0;
      row
        ..workDonePercent =
            double.tryParse(ProjectContractNumericHelper.fmt4(workDonePercent))
        ..workDone = row.workDonePercent
        ..cumulativeWorkDonePercent = double.tryParse(
          ProjectContractNumericHelper.fmt4(cumulativeWorkDonePercent),
        )
        ..cumulativeWorkDone = row.cumulativeWorkDonePercent;
    } else {
      row
        ..workDonePercent = 0.0
        ..cumulativeWorkDonePercent = 0.0
        ..workDone = 0.0
        ..cumulativeWorkDone = 0.0;
    }

    emitPpcSoft();
  }

// Optional guard to prevent re-entrant submits
  int? _currentlySubmittingIndex;

// Does the row have ANY user-entered content?
  bool rowHasAnyInput(PpcControllers ppcCntrl) {
    final fields = <String>[
      ppcCntrl.ppcCtrl.text,
      ppcCntrl.ppcDateCtrl.text,
      ppcCntrl.grossPPCValueCtrl.text,
      ppcCntrl.advancePaymentDeductionCtrl.text,
      ppcCntrl.retentionDeductionCtrl.text,
      ppcCntrl.vatAmountCtrl.text,
      ppcCntrl.otherPaymentCtrl.text,
      ppcCntrl.actualPaymentReceivedCtrl.text,
      ppcCntrl.datePaymentReceivedCtrl.text,
      ppcCntrl.commentsCtrl.text,
      // (include additional ones if you consider them part of "details")
    ];
    return fields.any((t) => t.trim().isNotEmpty);
  }

// Reusable: Numeric field validator with the rule
  String? mandatoryNumericIfOther({
    required PpcControllers c,
    required String? value,
    required String fieldLabel,
  }) {
    final ppcValueTrimed = (value ?? "").trim();
    final vNoCommas = ppcValueTrimed.replaceAll(",", "");

    // Regex: up to 21 digits before '.', up to 6 after
    final RegExp num21_6 = RegExp(r"^\d{1,15}(\.\d{1,6})?$");

    if (!rowHasAnyInput(c)) {
      // Row is blank -> optional; if provided, check format
      if (ppcValueTrimed.isEmpty) return null;
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
  String? mandatoryDateIfOther({
    required PpcControllers c,
    required String? value,
    required String fieldLabel,
  }) {
    final ppcValueTrimed = (value ?? "").trim();

    if (!rowHasAnyInput(c)) {
      // Optional when row is blank
      if (ppcValueTrimed.isEmpty) return null;
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
      if (refs.isEmpty) return "--";
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
      decimals: 6,
      epsilon: epsilon,
      trimTrailingZeros: true,
    );
    variationController.text = display;

    // Optionally keep raw variation numeric for backend/save
    contract.variationAmount = (diff?.abs() ?? 0) < epsilon ? 0.0 : diff;

    // If you also store a display string:
    contract.variationContractValue = double.tryParse(display);
  }

  void updateCompletionVariation() {
    final diff = ProjectContractNumericHelper.daysDiffSigned(
      contract.originalCompletionDate,
      contract.expectedEndDate,
    );

    final display = ProjectContractNumericHelper.formatVariationDays(diff);
    // contract.variationCompletionDate = display;
    contract.variationCompletionDate = diff; //diff ?? 0;
    variationCompletionDateController.text = display;
  }

  /// Prefill controllers for an API-loaded row. It ONLY fills if the controller
  /// is empty,
  /// so it does not override anything the user already typed.
  ///
  /// Call this once per API row before rendering.
  void prefillPpcControllersFromModel(int index, PPC ppcData) {
    if (isRestoringDraft) return;

    if (index < 0 || index >= ppcControllers.length) return;
    final PpcControllers ppcCntrl = ppcControllers[index];

    // 1) PPC Number or PPC numeric (depending on your model)
    // Keeps your first cell logic flexible. If PPC is a numeric input for new
    // rows,
    // we still prefill it for API rows when empty.
    if (ppcCntrl.ppcCtrl.text.trim().isEmpty) {
      // Try PPC value first; fallback to PPC No
      // final ppcVal = m.ppc ?? m.ppc;
      // final ppcNo = m.ppcNo; // shown read-only in API rows
      ppcCntrl.ppcCtrl.text = ppcData.ppcNo ??
          ProjectContractNumericHelper.numToText(ppcData.ppcId);
    }

    // 2) PPC Date
    if (ppcCntrl.ppcDateCtrl.text.trim().isEmpty) {
      ppcCntrl.ppcDateCtrl.text =
          ProjectContractNumericHelper.fmtDateFromAny(ppcData.ppcDate);
    }

    // 3) Gross PPC Value (support both naming variants)
    if (ppcCntrl.grossPPCValueCtrl.text.trim().isEmpty) {
      final gross = ppcData.grossPPCValue ?? ppcData.grossPpcValue;
      ppcCntrl.grossPPCValueCtrl.text =
          ProjectContractNumericHelper.numToText(gross);
    }

    // 4) Advance Payment Deduction
    if (ppcCntrl.advancePaymentDeductionCtrl.text.trim().isEmpty) {
      ppcCntrl.advancePaymentDeductionCtrl.text =
          ProjectContractNumericHelper.numToText(
        ppcData.advancePaymentDeduction,
      );
    }

    // 5) Retention Deduction
    if (ppcCntrl.retentionDeductionCtrl.text.trim().isEmpty) {
      ppcCntrl.retentionDeductionCtrl.text =
          ProjectContractNumericHelper.numToText(ppcData.retentionDeduction);
    }

    // 6) VAT Amount
    if (ppcCntrl.vatAmountCtrl.text.trim().isEmpty) {
      ppcCntrl.vatAmountCtrl.text =
          ProjectContractNumericHelper.numToText(ppcData.vatAmount);
    }

    // 7) Other Payment
    if (ppcCntrl.otherPaymentCtrl.text.trim().isEmpty) {
      ppcCntrl.otherPaymentCtrl.text =
          ProjectContractNumericHelper.numToText(ppcData.otherPayment);
    }

    // 8) Actual Payment Received
    if (ppcCntrl.actualPaymentReceivedCtrl.text.trim().isEmpty) {
      ppcCntrl.actualPaymentReceivedCtrl.text =
          ProjectContractNumericHelper.numToText(ppcData.actualPaymentReceived);
    }

    // 9) Date Payment Received
    if (ppcCntrl.datePaymentReceivedCtrl.text.trim().isEmpty) {
      ppcCntrl.datePaymentReceivedCtrl.text =
          ProjectContractNumericHelper.fmtDateFromAny(
        ppcData.datePaymentReceived,
      );
    }

    // NOTE: Derived (read-only) cells like cumulativePPCValue, netPPCValue,
    // etc.
    // are NOT controller-backed here (you create TextEditingController on the
    // fly
    // in the widget). Their values should be recomputed via:
    // viewModel.syncRowFromControllers(index); // then emit as needed
  }

  //The Business group users, namely RMB, TLB, RMB, CAM, SHB (Business Unit
  //Heads) should be able to create project.
  //Credit team user (Credit Coordinator, Credit Analyst, CC Proxy, BOD Proxy)
  //shall be able to view the projects but cannot edit.
  bool editAccessRolesCheck() {
    return (Utils.checkRoles([
      UserRole.relationshipManager,
      UserRole.relationshipOfficer,
      UserRole.relationshipManagerBussiness,
      UserRole.teamLeaderBusiness,
      UserRole.commercialAreaManager,
      UserRole.segmentHeadBusiness,
    ]))
        ? true
        : false;
  }

  bool viewAccessRolesCheck() {
    return (Utils.checkRoles([
      UserRole.creditCordinator,
      UserRole.creditAnalyst,
      UserRole.creditCommitteeProxy,
      UserRole.boardDirectorProxy,
    ]))
        ? true
        : false;
  }

  String clean(dynamic value) {
    if (value == null) return "";
    final String str = value.toString();
    if (str.toLowerCase() == "null") return "";
    return str;
  }

  Future<void> onBacktoRequestStatusPressed(BuildContext context) async {
    if (canEdit) {
      unawaited(Globals.onAutoSave?.call());
    }
    if (context.mounted) {
      //context.go(Routes.home);
      router.go(Routes.editViewProject, extra: project);
    }
  }
}

class PpcControllers {
  PpcControllers._({
    required this.ppcCtrl,
    required this.ppcDateCtrl,
    required this.grossPPCValueCtrl,
    required this.cumulativePpcValueCtrl,
    required this.cumulativePPCValueCtrl,
    required this.workDoneCtrl,
    required this.workDonePercentCtrl,
    required this.cumulativeWorkDoneCtrl,
    required this.cumulativeWorkDonePercentCtrl,
    required this.advancePaymentDeductionCtrl,
    required this.retentionDeductionCtrl,
    required this.netPPCValueCtrl,
    required this.vatAmountCtrl,
    required this.otherPaymentCtrl,
    required this.netCertifiedAmountVatCtrl,
    required this.actualPaymentReceivedCtrl,
    required this.datePaymentReceivedCtrl,
    required this.commentsCtrl,
  });

  factory PpcControllers.empty() {
    // All new, empty controllers
    return PpcControllers._(
      ppcCtrl: TextEditingController(),
      ppcDateCtrl: TextEditingController(),
      grossPPCValueCtrl: TextEditingController(),
      cumulativePpcValueCtrl: TextEditingController(),
      cumulativePPCValueCtrl: TextEditingController(),
      workDoneCtrl: TextEditingController(),
      workDonePercentCtrl: TextEditingController(),
      cumulativeWorkDoneCtrl: TextEditingController(),
      cumulativeWorkDonePercentCtrl: TextEditingController(),
      advancePaymentDeductionCtrl: TextEditingController(),
      retentionDeductionCtrl: TextEditingController(),
      netPPCValueCtrl: TextEditingController(),
      vatAmountCtrl: TextEditingController(),
      otherPaymentCtrl: TextEditingController(),
      netCertifiedAmountVatCtrl: TextEditingController(),
      actualPaymentReceivedCtrl: TextEditingController(),
      datePaymentReceivedCtrl: TextEditingController(),
      commentsCtrl: TextEditingController(),
    );
  }
  final TextEditingController ppcCtrl;
  final TextEditingController ppcDateCtrl;
  final TextEditingController grossPPCValueCtrl;
  final TextEditingController cumulativePpcValueCtrl;
  final TextEditingController cumulativePPCValueCtrl;
  final TextEditingController workDoneCtrl;
  final TextEditingController workDonePercentCtrl;
  final TextEditingController cumulativeWorkDoneCtrl;
  final TextEditingController cumulativeWorkDonePercentCtrl;
  final TextEditingController advancePaymentDeductionCtrl;
  final TextEditingController retentionDeductionCtrl;
  final TextEditingController netPPCValueCtrl;
  final TextEditingController vatAmountCtrl;
  final TextEditingController otherPaymentCtrl;
  final TextEditingController netCertifiedAmountVatCtrl;
  final TextEditingController actualPaymentReceivedCtrl;
  final TextEditingController datePaymentReceivedCtrl;
  final TextEditingController commentsCtrl;

  // Populate controllers from a PPC model (used on edit)
  void loadFromModel(PPC row) {
    ppcCtrl.text = row.ppcNo?.toString() ?? "";
    // ppcCtrl.text = row.ppcId?.toString() ?? '';
    ppcDateCtrl.text = row.ppcDate ?? "";
    grossPPCValueCtrl.text =
        row.grossPpcValue?.toString() ?? row.grossPPCValue?.toString() ?? "";
    cumulativePpcValueCtrl.text = row.cumulativePpcValue?.toString() ?? "";
    cumulativePPCValueCtrl.text = row.cumulativePPCValue?.toString() ?? "";
    workDoneCtrl.text = row.workDone?.toString() ?? "";
    workDonePercentCtrl.text = row.workDonePercent?.toString() ?? "";
    cumulativeWorkDoneCtrl.text = row.cumulativeWorkDone?.toString() ?? "";
    cumulativeWorkDonePercentCtrl.text =
        row.cumulativeWorkDonePercent?.toString() ?? "";
    advancePaymentDeductionCtrl.text =
        row.advancePaymentDeduction?.toString() ?? "";
    retentionDeductionCtrl.text = row.retentionDeduction?.toString() ?? "";
    netPPCValueCtrl.text = row.netPPCValue?.toString() ?? "";
    vatAmountCtrl.text = row.vatAmount?.toString() ?? "";
    otherPaymentCtrl.text = row.otherPayment?.toString() ?? "";
    netCertifiedAmountVatCtrl.text =
        row.netCertifiedAmountVat?.toString() ?? "";
    actualPaymentReceivedCtrl.text =
        row.actualPaymentReceived?.toString() ?? "";
    datePaymentReceivedCtrl.text = row.datePaymentReceived ?? "";
    commentsCtrl.text = row.comments ?? "";
  }

  void dispose() {
    ppcCtrl.dispose();
    ppcDateCtrl.dispose();
    grossPPCValueCtrl.dispose();
    cumulativePpcValueCtrl.dispose();
    cumulativePPCValueCtrl.dispose();
    workDoneCtrl.dispose();
    workDonePercentCtrl.dispose();
    cumulativeWorkDoneCtrl.dispose();
    cumulativeWorkDonePercentCtrl.dispose();
    advancePaymentDeductionCtrl.dispose();
    retentionDeductionCtrl.dispose();
    netPPCValueCtrl.dispose();
    vatAmountCtrl.dispose();
    otherPaymentCtrl.dispose();
    netCertifiedAmountVatCtrl.dispose();
    actualPaymentReceivedCtrl.dispose();
    datePaymentReceivedCtrl.dispose();
    commentsCtrl.dispose();
  }
}
