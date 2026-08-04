import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/currency_rates_service.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/utils/project_contract_numeric_helper.dart";
import "package:wcas_frontend/features/request/projects/link_contract/draft_handler.dart";
import "package:wcas_frontend/features/request/projects/link_contract/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/customer.dart";
// import 'package:wcas_frontend/models/request/facility_security/facility.dart';
import "package:wcas_frontend/models/request/project/contract.dart";
import "package:wcas_frontend/models/request/project/contract_comment.dart";
import "package:wcas_frontend/models/request/project/project.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/project_repository.dart";

/// ViewModel for managing the state and logic of the Link Contract screen.
///
/// This class handles form input, contract data binding, date selection,
/// tenor calculation, and saving contract details using the BLoC pattern.
class LinkContractViewModel extends SafeCubit<LinkContractState>
    with DraftMixin<LinkContractViewModel> {
  /// Constructor initializes the state with a loading status.
  LinkContractViewModel()
      : super(LinkContractState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for handling project-related operations.
  late ProjectRepository repository;

  /// Contract model that holds the form data.
  late Contract contract = Contract();

  /// Global key for validating the contract form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // CreateFacilityArgs?
  //     facilityArgsFromFacility; // NEW: keep original Facility extras
  /// Dropdown options for contractor roles.
  // List<String> dropdownItems = ["Main Contractor", "Sub-Contractor"];

  /// Reference data mapped by reference data key.
  Map<String, List<Reference>> referenceData = {};

  /// Country/currency code reference list.
  List<Reference> countryCodes = [];

  /// Indicates whether completion date validation failed.
  bool completionDateValidate = false;

  /// Controller for the converted-amount field
  TextEditingController convertedAmountController = TextEditingController();

  /// Controller for the contract value field.
  TextEditingController contractorValueController = TextEditingController();

  /// Controller for borrower search RIM field.
  TextEditingController searchRimController = TextEditingController();

  /// Controller for borrower search name field.
  TextEditingController searchNameController = TextEditingController();

  /// Controller for selected customer RIM field.
  TextEditingController customerRimController = TextEditingController();

  /// Controller for selected customer name field.
  TextEditingController customerNameController = TextEditingController();

  /// Controller for project tenor field.
  TextEditingController projectTenorController = TextEditingController();

  /// Controller for expected start date field.
  TextEditingController startDateController = TextEditingController();

  /// Controller for expected completion date field.
  TextEditingController completionDateController = TextEditingController();

  /// Controller for paymaster name field.
  TextEditingController paymasterNameController = TextEditingController();

  /// Controller for contractor scope field.
  TextEditingController contractorScopeController = TextEditingController();
  TextEditingController paymasterRimSearchController = TextEditingController();

  /// Indicates whether Limit Type is currently in edit mode.
  bool isLimitTypeInEditMode = false;

  /// Contract comments added locally.
  List<ContractComment> comments = [];
  List<String> paymasterNameList = [];

  /// Internal variables to store selected start and end dates.
  DateTime? _startDate;
  DateTime? _endDate;

  /// Selected customer RIM number from borrower search.
  String? custRimNo;

  /// Selected customer name from borrower search.
  String? custName;

  /// Borrower application reference number from borrower search.
  String? borrowerAppRefNo;

  /// The currently selected currency code (e.g. 'AED', 'USD', 'INR')
  String selectedCurrencyLabel = ServerConstants.aedCurrency;

  /// Borrower customer search results.
  List<Customer> borrowerCustomer = [];

  /// Borrower role reference options.
  List<Reference>? borrowerRole = [];

  /// Currently selected borrower role.
  Reference? selectedBorrowerRole;

  /// Project linked to the contract.
  Project? project = Project();
  List<Contract> contracts = [];

  /// Indicates whether the current page can be edited.
  bool get canEdit => pageMode == PageMode.edit;

  /// Current page mode.
  PageMode pageMode = PageMode.na;

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.projects;

  @override
  String get draftFormKey => project?.projectCode != null
      ? "${Routes.linkContract}_${project?.projectCode}"
      : "${Routes.linkContract}_${project?.projectName}";

  @override
  DraftHandler<LinkContractViewModel> get draftHandler =>
      LinkContractDraftHandler();

  // ---------------------------------------------------------------------------

  /// Initializes the ViewModel and sets the repository instance.
  ///
  /// [context] - The build context used for localization or navigation.
  Future<void> init(
    BuildContext context, {
    required Project projectItemView,
  }) async {
    logger.i("Initialising ViewModel…");
    repository = ProjectRepository.instance;
    project = projectItemView;

    // Object? extras = GoRouterState.of(context).extra;
    // if (extras is Map) {
    //   // If Link Contract was opened with the standard map, prefer it:
    //   // project = (extras['project'] as Project?) ?? projectItemView;
    //   facilityArgsFromFacility = extras['facilityArgs'] as
    // CreateFacilityArgs?;
    // }

    try {
      await AuthRepository.instance
          .updateRole(Globals.user!.currentRole!, request: Globals.request);
      pageMode = AuthRepository.getPageMode(RightConstants.linkContract);

      await Future.wait([
        getcountryCode(),
        loadReferenceData(),
        getContractDetailsData(project),
      ]);
      // _updateConvertedAmount();

      paymasterNameList
        ..add(project?.projectUltimateOwnerName ?? "")
        ..addAll(
          contracts
              .where(
                (f) =>
                    (f.contractorType ?? "").trim().toUpperCase() ==
                    "MAIN CONTRACTOR",
              )
              .map((c) => (c.contractName ?? "").trimLeft().trimRight()),
        );

      if (canEdit) {
        registerDraftCallback();
        await loadDraftIfAvailable();
      }
    } on Object catch (e) {
      if (e.toString().isNotEmpty) {
        AlertManager().showFailureToast(e.toString());
      }
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }

  Future<void> getContractDetailsData(Project? project) async {
    try {
      contracts = await repository.getProjectContractDetails(project);
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Fetches the list of country codes from the repository and stores
  /// them in the `countryCodes` variable.
  /// Displays an error toast if the operation fails.
  Future<void> getcountryCode() async {
    try {
      countryCodes = await CurrencyRatesService().getCurrencies();
    } on Object catch (e) {
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
      borrowerRole = referenceData[ReferenceDataKeys.borrowerRole] ?? [];
    } on Object {
      // emit(state.copyWith(loaderStatus: LoadingStatus.error));
      rethrow;
    }
  }

  /// Indicates whether FX rate controls should be disabled.
  bool disableFxRates = false;

  // Called when user picks a currency

  /// Handles currency selection change.
  void onCurrencyChanged(Reference ref) {
    selectedCurrencyLabel = ref.name ?? ServerConstants.aedCurrency;

    // contract.contractAmountCurrency = ref;
    contract.contractCurrency = ref.name;
    // If you still need a "currently selected" code, scope it per-field
    final selectedCode = (ref.name ?? "").toUpperCase();

    final bool isAed = selectedCode == ServerConstants.aedCurrency;
    disableFxRates = !isAed;

    // _updateConvertedAmount();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Current exchange rate used for conversion.
  num exchangeRate = 0;

  /// Fetches currency rates and updates the converted AED amount.
  Future<void> getCurrencyRates(Reference? selectedCurrency) async {
    try {
      final Map<String, num> rates = await CurrencyRatesService().getRates();

      // Resolve the selected currency code/name safely
      final String selectedCode = selectedCurrency?.name ?? "";

      // Get exchange rate for the selected currency
      exchangeRate = rates[selectedCode] ?? 0;

      // Pick the correct amount based on the flag
      final double amount =
          double.tryParse(contract.contractAmount.toString()) ?? 0;

      // Convert
      final double convertedValue = amount * exchangeRate;

      // Format values
      final formatter = NumberFormat("#,###");
      final String formattedAED = formatter.format(convertedValue);
      contract.contractValueAedAmount = formattedAED;
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

  // Called when user types contract value

  /// Handles contract value input changes.
  void onContractValueChanged(String raw) {
    // _updateConvertedAmount();
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
      ..appReffNo = borrowerCustomer.isNotEmpty
          ? borrowerCustomer.first.applicationRefNo ?? ""
          : ""
      ..customerRimNo = rimNo
      ..customerName = nameText;

    customerRimController.text = rimNo?.toString() ?? "";
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
      ..contractValue = null
      ..paymasterName = null
      ..contractorScope = null
      ..expectedStartDate = null
      ..expectedCompletionDate = null
      ..projectTenor = null;

    _startDate = null;
    _endDate = null;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Discards changes and navigates back to edit project.
  void onDiscard(BuildContext context) {
    if (context.mounted) {
      router.go(Routes.editViewProject, extra: project);
    }
  }

  /// Saves or creates the link contract.
  Future<void> onSave(
    BuildContext context, {
    bool? isCreate = false,
    YearRules rules = const YearRules(),
  }) async {
    final rimText = searchRimController.text.trim();
    final nameText = searchNameController.text.trim();

    // Custom validation: at least one must be filled
    if (rimText.isEmpty && nameText.isEmpty) {
      AlertManager()
          .showFailureToast("project.linkContract.enterRimCustomerName".tr());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return;
    }

    contract.expectedStartDate = _startDate;
    contract.expectedEndDate = _endDate;
    contract.expectedCompletionDate = _endDate;

    // Validate other fields in the form
    if (!formKey.currentState!.validate()) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      logger.w("Validation failed");
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

    try {
      final rimNo = rimText.isNotEmpty ? int.tryParse(rimText) : null;

      contract
        ..projectId = project?.projectId.toString()
        ..projectCode = project?.projectCode
        ..projectName = project?.projectName
        ..appReffNo = borrowerAppRefNo ?? ""
        ..customerRimNo = rimNo ?? int.tryParse(custRimNo.toString())
        ..customerName = nameText.isNotEmpty ? nameText : (custName ?? "");

      final String? contractCode =
          await repository.saveLinkContractDetails(contract);
      unawaited(deleteDraft());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      contract.contractCode = contractCode;
      contract.rimNo = rimNo.toString();
      if (isCreate ?? false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          DialogHelper.showCustomDialog(
            barrierDismissible: false,
            onClosePressed: () {
              context.pop();
              router.go(
                Routes.editContract,
                extra: {
                  "contract":
                      contract, // or contracts if it's already a Contract
                  "project": project, // your Project instance
                },
              );

              // If we came from Create Facility, go back there with the same
              // extras.
              // Otherwise, keep the existing logic (go to Edit Contract).
              // if (facilityArgsFromFacility != null) {
              //   router.go(
              //     Routes.createFacility, // your Create Facility route
              //     extra: facilityArgsFromFacility, // original extras
              //   );
              // } else {
              //   router.go(
              //     Routes.editContract,
              //     extra: {
              //       'contract': contract,
              //       'project': project,
              //     },
              //   );
              // }
            },
            width: Scale.scaleHorizontally(350),
            context: context,
            title: "requestInformation.requestInformation.confirmation".tr(),
            content: CustomSelectableText(
              text: "project.linkContract.createContractSuccess".tr(
                namedArgs: {
                  "contractCode": contract.contractCode ?? "",
                  "projectCode": project?.projectCode ?? "",
                },
              ),
            ),
            actions: [
              CustomButton(
                label: "requestInformation.requestInformation.okay".tr(),
                onPressed: () {
                  context.pop();
                  router.go(
                    Routes.editContract,
                    extra: {
                      "contract":
                          contract, // or contracts if it's already a Contract
                      "project": project, // your Project instance
                    },
                  );

                  // if (facilityArgsFromFacility != null) {
                  //   router.go(
                  //     Routes.createFacility,
                  //     extra: facilityArgsFromFacility,
                  //   );
                  // } else {
                  //   router.go(
                  //     Routes.editContract,
                  //     extra: {
                  //       'contract': contract,
                  //       'project': project,
                  //     },
                  //   );
                  // }
                },
              ),
            ],
          );
        });
      } else {
        AlertManager().showSuccessToast("common.dataSaveSuccess".tr());
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
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
    contract.expectedCompletionDate = proposedEnd;
    completionDateController.text = proposedEnd == null
        ? ""
        : ProjectContractNumericHelper.fmt.format(proposedEnd);

    completionDateValidate = false;
    callEndDateTenor(raw, rules, isFirst: true);
  }

  /// Updates end date, completion controller, and optionally tenor.
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

  /// Calculates the project tenor based on start and end dates.
  ///
  /// Updates:
  ///  - contract.projectTenor: the count in days (string)
  ///  - projectTenorController.text: the human-readable "X months Y days" text
  ///  - state.tenor: same text

  void _updateTenor({YearRules rules = const YearRules()}) {
    if (_startDate == null || _endDate == null) {
      contract.projectTenor = null;
      projectTenorController.clear();
      emit(state.copyWith());
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      AlertManager().showWarningToast(
        "project.viewEditContractDetails.completionDateStartDate".tr(),
      );
      contract.projectTenor = null;
      projectTenorController.clear();
      emit(state.copyWith());
      return;
    }

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
        tenor: text,
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

  /// Adds a contract comment to the local comments list.
  void addComment(String commentText) {
    if (commentText.trim().isEmpty) {
      return;
    }
    comments.add(
      ContractComment(text: commentText.trim(), timestamp: DateTime.now()),
    );
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Returns locally added contract comments.
  List<ContractComment> getComments() => comments;

  /// Searches borrower by RIM/name and populates customer fields.
  Future<void> onBorrowerOnPressed() async {
    try {
      borrowerCustomer = await repository.getProjectBorrowerSearch(
        customerName: searchNameController.text,
        customerRimNo: searchRimController.text,
      );
      if (borrowerCustomer.isNotEmpty) {
        customerNameController.text = borrowerCustomer.first.preferredName ??
            borrowerCustomer.first.displayRIMName ??
            "";
        customerRimController.text =
            borrowerCustomer.first.customerRimNo.toString();
        custRimNo = borrowerCustomer.first.customerRimNo.toString();
        custName = borrowerCustomer.first.preferredName ??
            borrowerCustomer.first.displayRIMName ??
            "";
        borrowerAppRefNo = borrowerCustomer.first.applicationRefNo ?? "";
      } else {
        customerNameController.text = "";
        customerRimController.text = "";
        custName = "";
        custRimNo = "";
        borrowerAppRefNo = "";
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Handles borrower role selection and paymaster defaults.
  void onBorrowerRoleSelected(Reference selected) {
    selectedBorrowerRole = selected;
    contract.borrowerRole = selected.name;
    contract.isMainContractor =
        (selected.id == ServerConstants.mainContractorId);
    if (selected.id == ServerConstants.mainContractorId) {
      paymasterNameController.text = project?.projectUltimateOwnerName ?? "";
      contract.paymasterName = project?.projectUltimateOwnerName ?? "";
      emit(
        state.copyWith(
          subContractor: false,
          loaderStatus: LoadingStatus.loaded,
        ),
      );
    } else {
      paymasterNameController.text = "";
      contract.paymasterName = "";
      emit(
        state.copyWith(
          subContractor: true,
          loaderStatus: LoadingStatus.loaded,
        ),
      );
    }
  }

  /// Handles back to request status button press.
  Future<void> onBacktoRequestStatusPressed(BuildContext context) async {
    // if (context.mounted) {
    //   context.go(Routes.home);
    // }
    if (canEdit) {
      unawaited(Globals.onAutoSave?.call());
    }
    onDiscard(context);
  }

  //The Business group users, namely RMB, TLB, RMB, CAM, SHB (Business Unit
  //Heads) should be able to create project.
  //Credit team user (Credit Coordinator, Credit Analyst, CC Proxy, BOD Proxy)
  //shall be able to view the projects but cannot edit.

  /// Checks whether current user has edit access roles.
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

  /// Checks whether current user has view-only access roles.
  bool viewAccessRolesCheck() {
    return Utils.checkRoles([
      UserRole.creditCordinator,
      UserRole.creditAnalyst,
      UserRole.creditCommitteeProxy,
      UserRole.boardDirectorProxy,
    ]);
  }

  // Checkbox toggles
  void hasRimSelected({bool? isChecked}) {
    contract.hasRim = isChecked;
    paymasterNameController.clear();
    paymasterRimSearchController.clear();
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        hasRim: isChecked ?? false,
      ),
    );
  }

  // Checkbox toggles
  void canEditPaymaster() {
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        hasRim: false,
      ),
    );
  }

  /// Update RIM No and Customer Name from API
  Future<void> updateRimNo(String rimNo) async {
    try {
      final Customer? customer = await CustomerRepository.instance
          .searchUserDetailsPartyInqOnly(rimNo, "", "", "");
      if (customer == null) {
        //"PartyStatus": "Closed             ",
        throw ApiException("common.noUserFound".tr());
      }

      if (customer.partyStatus.toString().trim() ==
          ServerConstants.partyStatusClosed) {
        throw ApiException("common.noUserFoundClosedPartyStatus".tr());
      }

      paymasterNameController.text = customer.concatCustomerFullName;
      contract.paymasterName = customer.concatCustomerFullName;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      logger.i("Error updating RIM No: $e");
      // rethrow;
      AlertManager().showFailureToast(e.toString());
    }
  }

  bool get isLimitTypeMissing {
    if (isLimitTypeInEditMode) {
      return (contract.paymasterName ?? "").trim().isEmpty;
    }
    return false;
  }
}
