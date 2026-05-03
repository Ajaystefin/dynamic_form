// ignore_for_file: avoid_print

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
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
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
import "package:wcas_frontend/models/request/facility_security/exchange_rate.dart";
// import 'package:wcas_frontend/models/request/facility_security/facility.dart';
import "package:wcas_frontend/models/request/project/contract.dart";
import "package:wcas_frontend/models/request/project/contract_comment.dart";
import "package:wcas_frontend/models/request/project/project.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";
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

  Map<String, List<Reference>> referenceData = {};

  List<Reference> countryCodes = [];

  bool completionDateValidate = false;

  /// Controller for the converted-amount field
  TextEditingController convertedAmountController = TextEditingController();
  TextEditingController contractorValueController = TextEditingController();
  TextEditingController searchRimController = TextEditingController();
  TextEditingController searchNameController = TextEditingController();
  TextEditingController customerRimController = TextEditingController();
  TextEditingController customerNameController = TextEditingController();
  TextEditingController projectTenorController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController completionDateController = TextEditingController();
  TextEditingController paymasterNameController = TextEditingController();
  TextEditingController contractorScopeController = TextEditingController();

  List<ContractComment> comments = [];

  /// Internal variables to store selected start and end dates.
  DateTime? _startDate;
  DateTime? _endDate;

  String? custRimNo;
  String? custName;
  String? borrowerAppRefNo;

  /// The currently selected currency code (e.g. 'AED', 'USD', 'INR')
  String selectedCurrencyLabel = ServerConstants.aedCurrency;

  List<Customer> borrowerCustomer = [];
  List<Reference>? borrowerRole = [];
  Reference? selectedBorrowerRole;
  Project? project = Project();

  bool get canEdit => pageMode == PageMode.edit;
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
  Future<void> init(context, {required Project projectItemView}) async {
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

      await Future.wait([getcountryCode(), loadReferenceData()]);
      // _updateConvertedAmount();
    } catch (e) {
      if (e.toString().isNotEmpty) {
        AlertManager().showFailureToast(e.toString());
      }
    }
    if (canEdit) {
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

  /// Fetches the list of country codes from the repository and stores
  /// them in the `countryCodes` variable.
  /// Displays an error toast if the operation fails.
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
      borrowerRole = referenceData[ReferenceDataKeys.borrowerRole] ?? [];
    } catch (e) {
      // emit(state.copyWith(loaderStatus: LoadingStatus.error));
      rethrow;
    }
  }

  bool disableFxRates = false;

  // Called when user picks a currency
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

  num exchangeRate = 0;

  Future<void> getCurrencyRates(Reference? selectedCurrency) async {
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
      contract.contractValueAedAmount = formattedAED;
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

  // Called when user types contract value
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

  void onDiscard(BuildContext context) {
    if (context.mounted) {
      router.go(Routes.editViewProject, extra: project);
    }
  }

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
      if (isCreate == true) {
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
    } catch (e) {
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
      emit(state.copyWith(tenor: null));
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      AlertManager().showWarningToast(
        "project.viewEditContractDetails.completionDateStartDate".tr(),
      );
      contract.projectTenor = null;
      projectTenorController.clear();
      emit(state.copyWith(tenor: null));
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

  void addComment(String commentText) {
    if (commentText.trim().isEmpty) return;
    comments.add(
      ContractComment(text: commentText.trim(), timestamp: DateTime.now()),
    );
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  List<ContractComment> getComments() => comments;

  Future<void> onBorrowerOnPressed() async {
    try {
      borrowerCustomer = await repository.getProjectBorrowerSearch(
        customerName: searchNameController.text.toString(),
        customerRimNo: searchRimController.text.toString(),
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
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  void onBorrowerRoleSelected(Reference selected) {
    selectedBorrowerRole = selected;
    contract.borrowerRole = selected.name;
    contract.isMainContractor =
        (selected.id == ServerConstants.mainContractorId);
    if (selected.id == ServerConstants.mainContractorId) {
      paymasterNameController.text = project?.projectUltimateOwnerName ?? "";
      contract.paymasterName = project?.projectUltimateOwnerName ?? "";
    } else {
      paymasterNameController.text = "";
      contract.paymasterName = "";
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

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
}
