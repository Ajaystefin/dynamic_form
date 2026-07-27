import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";

import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/draft_handler.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/ccsys/customer_information.dart";
import "package:wcas_frontend/models/request/country.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/ccsys_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";

/// View model that manages CCSYS customer information form data and actions.
class CustomerInformationViewModel extends SafeCubit<CustomerInformationState>
    with DraftMixin<CustomerInformationViewModel> {
  /// Creates a [CustomerInformationViewModel] with initial loading state.
  CustomerInformationViewModel()
      : super(
          CustomerInformationState(
            loaderStatus: LoadingStatus.loading,
            partnerShareholderStatus: LoadingStatus.loading,
          ),
        );

  /// Repository used for CCSYS customer information API calls.
  late CcsysRepository repository;

  /// Repository used for customer-related API calls.
  late CustomerRepository repositoryCustomer;

  /// Focus node used by the customer information form.
  final FocusNode formFocusNode = FocusNode();

  /// Form key used to validate and save the customer information form.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // List<Customer>? customers = [];

  /// List of available countries.
  List<Country>? countries = [];

  // List<Reference>? status = [];

  // Customer? customer;

  /// Current request object used by this screen.
  Request request = Request();

  /// Customer information model used by the CCSYS form.
  CcsysCustomerInformation customerInformation = CcsysCustomerInformation();

  /// Application details associated with the current request.
  ApplicationDetails? applicationDetails = ApplicationDetails();

  /// Identifier of the CCSYS customer information record.
  int? ccsysCustomerInformationId;

  /// Controller for the LEI number field.
  final TextEditingController leiController = TextEditingController();

  /// Controller for the group ultimate parent field.
  final TextEditingController controllerGroupUltimate = TextEditingController();

  /// Controller for the group immediate parent field.
  final TextEditingController controllerGroupImmediate =
      TextEditingController();

  /// Controller for the capital field.
  final TextEditingController capitalController = TextEditingController();

  /// Controller for the turnover field.
  final TextEditingController turnoverController = TextEditingController();

  /// Controller for the auditor field.
  final TextEditingController auditorController = TextEditingController();

  /// Controller for the number of employees field.
  final TextEditingController numberOfEmployeeController =
      TextEditingController();

  /// Indicates whether the borrower is a borrowing subsidiary.
  bool isBorrowingSubsidiary = false;

  /// Indicates whether legal entity identifier is enabled.
  bool isLegalEntityIdentifier = false;

  /// List of supported application types.
  List<Reference> applicationTypes = [];

  /// Yes-or-no radio button options.
  List<Reference> radioButtonItems = [
    Reference(id: 1904, name: "Yes"),
    Reference(id: 1905, name: "No"),
  ];

  /// Yes, no, and NA reference options.
  List<Reference> yesNoNaItems = [];

  /// Selected borrowing subsidiary option.
  Reference? selectedBorroweSubsidiary;

  /// Selected legal entity identifier option.
  Reference? selectedLegalEntityIdentifier;

  /// Selected emirate license option.
  Reference? selectedEmirateLicense;

  /// Selected emirate establishment option.
  Reference? selectedEmirateEstablishment;

  /// Default NA reference value.
  Reference defaultField = Reference(id: 0, name: "NA");

  /// Partner or shareholder rows displayed in the form.
  List<PartnerShareholder> rows = [];

  /// Text controllers associated with partner or shareholder rows.
  List<PartnerShareholderControllers> ctrls = [];

  /// CCSYS country reference list.
  List<Reference> ccsysCountryList = [];

  /// CCSYS emirate reference list.
  List<Reference> ccsysEmirateList = [];

  /// CCSYS gender reference list.
  List<Reference> ccsysGender = [];

  /// CCSYS partner legal status reference list.
  List<Reference> ccsysPartnerLegalStatus = [];

  /// CCSYS partner shareholder residence reference list.
  List<Reference> ccsysPartnerShareholderResidence = [];

  /// CCSYS partner shareholder type reference list.
  List<Reference> ccsysPartnerShareholderType = [];

  /// Allowed country codes used for passport validation.
  Set<String> allowedCountryCodes = {};

  /// Indicates whether the current page can be edited.
  bool canEdit = false;

  /// Current page mode.
  PageMode pageMode = PageMode.na;

  /// Initializes user rights and page mode for the request.
  void initRightsAndMode(Request request) {
    final bool rights = request.ccsysCanEditReadOnly ?? true;
    pageMode =
        AuthRepository.getPageMode(RightConstants.ccsysCustomerInformation);
    if (!rights) {
      canEdit = false;
      return;
    }
    canEdit = pageMode == PageMode.edit;
  }

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  /// Draft module key used by the CCSYS customer information form.
  @override
  String get draftModuleKey => DraftModuleKeys.ccsys;

  /// Draft form key used by the CCSYS customer information form.
  @override
  String get draftFormKey => Routes.customerInformation;

  /// Draft handler for customer information draft operations.
  @override
  DraftHandler<CustomerInformationViewModel> get draftHandler =>
      CustomerInformationDraftHandler();

  // ---------------------------------------------------------------------------

  /// Initializes repositories, request data, references, and customer information.
  Future<void> init(BuildContext context) async {
    repository = CcsysRepository.instance;
    repositoryCustomer = CustomerRepository.instance;
    request = Globals.request ?? Request();
    applicationTypes = [Reference(name: "CCSYS")];
    initRightsAndMode(request);

    try {
      await Future.wait([getReferenceData(), getCustomerInformation()]);
    } on Object catch (e) {
      if (e.toString().isNotEmpty) {
        AlertManager().showFailureToast(e.toString());
      }
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// *************getCustomerInformation********************
  /// Keeps your `Request` model unchanged; performs safe type conversions.
  Future<void> getCustomerInformation() async {
    try {
      customerInformation = await repository.getCustomerInformationCCSYS() ??
          CcsysCustomerInformation();

      ccsysCustomerInformationId = customerInformation.ccsysCustomerId;
      final List<Reference> yesNoNa =
          yesNoNaItems.isEmpty ? radioButtonItems : yesNoNaItems;

      final bool? borroweSubsidiary = customerInformation.borrowerSubsidiary;
      final bool? legalEntityIdentifier =
          customerInformation.legalEntityIdentifier;
      final int target = borroweSubsidiary ?? false
          ? ServerConstants.yesRefId
          : ServerConstants.noRefId;
      final int targetlegal = legalEntityIdentifier ?? false
          ? ServerConstants.yesRefId
          : ServerConstants.noRefId;

      selectedBorroweSubsidiary = yesNoNa.firstWhere(
        (e) => e.id == target,
        orElse: Reference.new,
      );

      selectedLegalEntityIdentifier = yesNoNa.firstWhere(
        (e) => e.id == targetlegal,
        orElse: Reference.new,
      );

      emit(
        state.copyWith(
          borrowerSubsidiary: borroweSubsidiary ?? false,
          legalEntityIdentifier: legalEntityIdentifier ?? false,
        ),
      );

      if (borroweSubsidiary == null) {
        customerInformation.borrowerSubsidiary = false;
        isBorrowingSubsidiary = false;
        controllerGroupImmediate.text = "NA";
        controllerGroupUltimate.text = "NA";
      } else {
        if (!borroweSubsidiary) {
          customerInformation.borrowerSubsidiary = false;
          isBorrowingSubsidiary = false;
          controllerGroupImmediate.text = "NA";
          controllerGroupUltimate.text = "NA";
        } else {
          controllerGroupImmediate
              .text = customerInformation.groupImmediateParent != null ||
                  customerInformation.groupImmediateParent.toString() != "null"
              ? customerInformation.groupImmediateParent.toString()
              : "NA";
          controllerGroupUltimate
              .text = customerInformation.groupUltimateParent != null ||
                  customerInformation.groupUltimateParent.toString() != "null"
              ? customerInformation.groupUltimateParent.toString()
              : "NA";
        }
      }

      if (legalEntityIdentifier == null) {
        leiController.text = "NA";
        selectedEmirateLicense = null;
        selectedEmirateEstablishment = null;
      } else {
        if (!legalEntityIdentifier) {
          leiController.text = "NA";
          selectedEmirateLicense = null;
          selectedEmirateEstablishment = null;
        } else {
          leiController.text = customerInformation.leiNumber != null ||
                  customerInformation.leiNumber.toString() != "null"
              ? customerInformation.leiNumber.toString() != "NA"
                  ? customerInformation.leiNumber.toString()
                  : ""
              : "NA";

          selectedEmirateEstablishment = null;
          if (customerInformation.emiEst != null) {
            selectedEmirateEstablishment = ccsysEmirateList.firstWhere(
              (element) => element.name == customerInformation.emiEst,
              orElse: () => Reference(name: customerInformation.emiEst),
            );
          }

          selectedEmirateLicense = null;
          if (customerInformation.emiLic != null) {
            selectedEmirateLicense = ccsysEmirateList.firstWhere(
              (element) => element.name == customerInformation.emiLic,
              orElse: () => Reference(name: customerInformation.emiLic),
            );
          }
        }
      }

      initializeControllers(
        customerInformation.ccsysCustomerPartnerShareholderList ?? [],
      );

      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.loaded,
          partnerShareholderStatus: LoadingStatus.loaded,
        ),
      );

      if (canEdit) {
        registerDraftCallback();
        await loadDraftIfAvailable();
      }
    } on Object {
      rethrow;
    }
  }

  /// Fetches reference data related to CCC status and updates the local
  /// `status` variable.
  ///
  /// This asynchronous function performs the following:
  /// - Calls `ReferenceDataService().getReferenceData()` with the `cccStatus`
  /// key.
  /// - Retrieves a map of reference data categorized by keys.
  /// - Extracts the list of references associated with `cccStatus`.
  /// - Updates the local `status` variable with the retrieved list, or an empty
  /// list if none is found.
  Future<void> getReferenceData() async {
    try {
      final Map<String, List<Reference>> referenceData =
          await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.ccsysCountryList,
        ReferenceDataKeys.ccsysEmirateList,
        ReferenceDataKeys.ccsysGender,
        ReferenceDataKeys.ccsysPsLegalStatus,
        ReferenceDataKeys.ccsysPsResidence,
        ReferenceDataKeys.ccsysPsType,
        ReferenceDataKeys.yesNoNa,
      ]);

      ccsysCountryList = (referenceData[ReferenceDataKeys.ccsysCountryList] ??
          [])
        ..sort((a, b) => (a.name ?? "").compareTo(b.name ?? ""));
      ccsysEmirateList =
          referenceData[ReferenceDataKeys.ccsysEmirateList] ?? [];
      ccsysGender = referenceData[ReferenceDataKeys.ccsysGender] ?? [];
      ccsysPartnerLegalStatus =
          referenceData[ReferenceDataKeys.ccsysPsLegalStatus] ?? [];
      ccsysPartnerShareholderResidence =
          referenceData[ReferenceDataKeys.ccsysPsResidence] ?? [];
      ccsysPartnerShareholderType =
          referenceData[ReferenceDataKeys.ccsysPsType] ?? [];
      yesNoNaItems = referenceData[ReferenceDataKeys.yesNoNa] ?? [];
    } on Object {
      rethrow;
    }
  }

  /// Handles legal status partner selection.
  void onLegalStatusPartnerSelected(Reference legalStatusPartners) {}

  /// Returns whether legal status is NP and residency status is RE.
  bool isLegalNpAndResidencyRE() {
    return false;
  }

  /// Handles borrowing subsidiary radio option changes.
  void onChangeBorrowingSubsidiary(Reference? selectedOption) {
    selectedOption == radioButtonItems[0]
        ? isBorrowingSubsidiary = false
        : isBorrowingSubsidiary = true;
    customerInformation.radioButtonItems = selectedOption;

    selectedBorroweSubsidiary = selectedOption;
    if (selectedBorroweSubsidiary?.id == ServerConstants.yesRefId) {
      customerInformation.borrowerSubsidiary = true;
    } else if (selectedBorroweSubsidiary?.id == ServerConstants.noRefId) {
      customerInformation.borrowerSubsidiary = false;
    }

    emit(
      state.copyWith(
        borrowerSubsidiary:
            selectedBorroweSubsidiary?.id == ServerConstants.yesRefId,
      ),
    );

    if (!(selectedOption?.id == ServerConstants.yesRefId)) {
      controllerGroupImmediate.text = "NA";
      controllerGroupUltimate.text = "NA";
    } else {
      controllerGroupImmediate.text =
          customerInformation.groupUltimateParent != null
              ? customerInformation.groupUltimateParent?.toString() ?? ""
              : "";
      controllerGroupUltimate.text =
          customerInformation.groupImmediateParent != null
              ? customerInformation.groupImmediateParent?.toString() ?? ""
              : "";
    }
    if (selectedOption?.id == ServerConstants.noRefId) {
      controllerGroupImmediate.text = "NA";
      controllerGroupUltimate.text = "NA";
    } else {
      controllerGroupImmediate.text =
          customerInformation.groupImmediateParent != null ||
                  customerInformation.groupImmediateParent.toString() != "null"
              ? customerInformation.groupImmediateParent.toString() != "NA"
                  ? customerInformation.groupImmediateParent.toString()
                  : ""
              : "";
      controllerGroupUltimate.text =
          customerInformation.groupUltimateParent != null ||
                  customerInformation.groupUltimateParent.toString() != "null"
              ? customerInformation.groupUltimateParent.toString() != "NA"
                  ? customerInformation.groupUltimateParent.toString()
                  : ""
              : "";
    }

    emit(state.copyWith(customerSelectedStatus: LoadingStatus.loaded));
  }

  /// Sets the partner emirates ID value.
  void setEmiratesId(String? emiratesIdPartner) {
    customerInformation.emiratesIdPartner = emiratesIdPartner;
    emit(state.copyWith(customerSelectedStatus: LoadingStatus.loaded));
  }

  /// Handles legal entity identifier option changes.
  void onChangeisLegalEntityIdentifier(Reference legalEntityIdentifier) {
    legalEntityIdentifier == radioButtonItems[0]
        ? isLegalEntityIdentifier = false
        : isLegalEntityIdentifier = true;

    selectedLegalEntityIdentifier = legalEntityIdentifier;
    customerInformation.legalEntityIdentifier =
        (legalEntityIdentifier.id == ServerConstants.yesRefId);
    emit(
      state.copyWith(
        legalEntityIdentifier:
            legalEntityIdentifier.id == ServerConstants.yesRefId,
      ),
    );

    if (legalEntityIdentifier.id == ServerConstants.noRefId) {
      leiController.text = "NA";
      selectedEmirateLicense = null;
      selectedEmirateEstablishment = null;
    } else {
      if (selectedEmirateLicense?.name == "NA") {
        selectedEmirateLicense = null;
      }
      if (selectedEmirateEstablishment?.name == "NA") {
        selectedEmirateEstablishment = null;
      }

      leiController.text = customerInformation.leiNumber != null ||
              customerInformation.leiNumber.toString() != "null"
          ? customerInformation.leiNumber.toString() != "NA"
              ? customerInformation.leiNumber.toString()
              : ""
          : "";
    }

    emit(state.copyWith(customerSelectedStatus: LoadingStatus.loaded));
  }

  /// Deletes a selected country chip by index.
  void onCountryChipDeleted(int index) {
    final list = customerInformation.countryOfRiskFundUtilization;
    if (list == null || index < 0 || index >= list.length) {
      return;
    }

    list.removeAt(index);

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the countries of risk fund utilization selection.
  void updateCountriesOfRisk(List<Reference> selected) {
    customerInformation.countryOfRiskFundUtilization = selected;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// ****** save customer information and manages loading state.*****
  ///
  /// This function performs the following:
  /// - Emits a loading state to indicate the start of the save operation.
  /// - Catches and displays any errors using `AlertManager`.
  /// - Emits a loaded state after the operation completes, regardless of
  /// success or failure.

  Future<void> saveCustomerInformation({bool ifNavigate = false}) async {
    try {
      final isValid = formKey.currentState?.validate() ?? false;
      if (!isValid) {
        if (isDateValid ?? false) {
          throw ApiException(
            "ccsys.customerInformation.dateAutitedEnterError".tr(),
          );
        }
        // if (isDateValidPassportExpiry ?? false) {
        //   throw "ccsys.customerInformation.passportExpiryEnterError".tr();
        // } //
        AlertManager().showFailureToast(
          "requestInformation.requestInformation.requiredFeild".tr(),
        );
        return;
      }

      formKey.currentState?.save();

      if (isDateValid ?? false) {
        throw ApiException(
          "ccsys.customerInformation.dateAutitedEnterError".tr(),
        );
      }
      // if (isDateValidPassportExpiry ?? false) {
      //   throw "ccsys.customerInformation.passportExpiryEnterError".tr();
      // } //

      // Validate rows before saving
      final errors = validateAll();
      if (errors.isNotEmpty) {
        AlertManager().showFailureToast(
          'Please fix the following:\n${errors.map((e) => '• $e').join('\n')}',
        );
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }

      if (rows.isEmpty) {
        AlertManager().showFailureToast(
          "ccsys.customerInformation.fillPartnerShareholder".tr(),
        );
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }

      final String? shareHolderMessage = shareHoldingPercentageValidator("0");
      if (shareHolderMessage != null) {
        throw ApiException(
          shareHolderMessage,
        );
      }

      // Assign into the model (use your actual property names)
      customerInformation
        ..appRefNo ??= Globals.request?.applicationRefNo
        ..customerName ??= Globals.request?.customerName
        ..ccsysCustomerId = ccsysCustomerInformationId;

      if (customerInformation.ccsysCustomerPartnerShareholderList != null &&
          customerInformation.ccsysCustomerPartnerShareholderList!.isNotEmpty) {
        for (int i = 0; i < rows.length; i++) {
          if (i <
              customerInformation.ccsysCustomerPartnerShareholderList!.length) {
            // rows[i].ccsysCustomerPartnerShareholderId ??=

            rows[i].ccsysCustomerId ??= customerInformation
                .ccsysCustomerPartnerShareholderList![i].ccsysCustomerId;
          }
          rows[i].ccsysCustomerId ??= ccsysCustomerInformationId;
        }
      }

      customerInformation.ccsysCustomerPartnerShareholderList = rows;

      //final payload = customerInformation.toJsonGetCCSYSCustomerInfo();
      //logger.i('Payload: $payload');

      final String response =
          await repository.saveCustomerInformation(customerInformation);
      await getCustomerInformation();

      if (response == "common.success".tr()) {
        AlertManager().showSuccessToast("common.saveSuccess".tr());
        if (ifNavigate) {
          moveToNext();
        }
      } else {
        AlertManager().showFailureToast(response);
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    unawaited(deleteDraft());
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Navigates to the CCSYS approval screen.
  void moveToNext() {
    router.go(Routes.ccsysApproval);
  }

  /// Validates "Date of audited FS"
  /// Rules:
  /// - Mandatory: must not be empty
  /// - Format: dd/MM/yyyy
  /// - Cannot be in the future (must be ≤ today)
  bool? isDateValid = false;

  /// Indicates whether passport expiry date is invalid.
  bool? isDateValidPassportExpiry = false;

  /// Validates the audited FS date or passport expiry date.
  String? checkAuditedFsDate(
    String? value, {
    bool isToday = false,
    bool isDateFs = false,
  }) {
    if (isToday) {
      if (value == null || value.trim().isEmpty) {
        if (isDateFs) {
          isDateValid = true;
        } else {
          isDateValidPassportExpiry = true;
        }
        return "ccsys.customerInformation.dateAutitedError".tr();
      }
    }

    final parsed = DateTimeUtils.parseToDateOnly(value);
    if (parsed == null) {
      if (isDateFs) {
        isDateValid = true;
      } else {
        isDateValidPassportExpiry = true;
      }
      return "ccsys.customerInformation.dateAutitedEnterValidDate".tr();
    }

    if (isToday) {
      final today = DateTimeUtils.toDateOnly(DateTime.now());
      if (parsed.isAfter(today)) {
        if (isDateFs) {
          isDateValid = true;
        } else {
          isDateValidPassportExpiry = true;
        }
        return "ccsys.customerInformation.dateAutitedErrorFuture".tr();
      }
    }

    isDateValid = false;
    return null; // valid
  }

  /// Validates total shareholding percentage across all rows.
  String? shareHoldingPercentageValidator(String? value) {
    if (value == null) {
      return "ccsys.customerInformation.shareHoldingEmpty".tr();
    }
    double totalPercentage = 0;
    for (final PartnerShareholder owner in rows) {
      if ((owner.shareholdingPartnershipPercentage ?? 0) == 0) {
        return "ccsys.customerInformation.shareHoldingZero".tr();
      }
      totalPercentage += owner.shareholdingPartnershipPercentage ?? 0;
    }
    if (totalPercentage != 100) {
      return "ccsys.customerInformation.shareHoldingPercent".tr();
    }
    return null;
  }

////REUSABLE METHODS
// Reusable method to Validator
  String? validateSelection(
    String? value,
    List<Reference> options,
    String errorKey,
  ) {
    final trimmedValue = value?.trim();
    final isValid = options.any((ref) => ref.name == trimmedValue);
    return isValid ? null : errorKey.tr();
  }

  /// Returns reference options excluding the NA option.
  List<Reference> getFilteredOptions(List<Reference> options) {
    return options.where((ref) => ref.id != ServerConstants.naRefId).toList();
  }

  /// Gets the selected reference value with yes or no fallback.
  Reference getSelectedReference({
    required List<Reference> options,
    required Reference? selectedValue,
    required bool? fallbackFlag,
  }) {
    final List<Reference> yesNoNa =
        yesNoNaItems.isEmpty ? radioButtonItems : yesNoNaItems;
    final filtered = getFilteredOptions(options);
    if (selectedValue != null && filtered.contains(selectedValue)) {
      return selectedValue;
    }

    final int targetId = (fallbackFlag = true)
        ? ServerConstants.yesRefId
        : ServerConstants.noRefId;
    return filtered.firstWhere(
      (ref) => ref.id == targetId,
      orElse: () => yesNoNa.firstWhere(
        (ref) => ref.id == targetId,
      ),
    );
  }

  /// Initializes partner/shareholder row controllers.
  void initializeControllers(List<PartnerShareholder> initial) {
    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loading));

    rows = List<PartnerShareholder>.from(initial);
    ctrls = rows.map((m) {
      final c = PartnerShareholderControllers()..attach(m);
      return c;
    }).toList();
    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  /// Disposes all partner/shareholder row controllers.
  void disposeControllers() {
    for (final c in ctrls) {
      c.dispose();
    }
    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  /// Adds a new partner/shareholder row.
  void addRow() {
    // emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loading));

    final PartnerShareholder m = PartnerShareholder();
    final PartnerShareholderControllers c = PartnerShareholderControllers()
      ..attach(m);
    rows.add(m);
    ctrls.add(c);

    rows = List<PartnerShareholder>.from(rows);
    ctrls = List<PartnerShareholderControllers>.from(ctrls);

    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  /// Removes a partner/shareholder row by index.
  void removeRow(int index) {
    if (index < 0 || index >= rows.length) {
      return;
    }
    // emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loading));

    rows.removeAt(index);
    ctrls[index].dispose();
    ctrls.removeAt(index);

    rows = List<PartnerShareholder>.from(rows);
    ctrls = List<PartnerShareholderControllers>.from(ctrls);

    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  /// Applies row changes and refreshes the partner/shareholder state.
  Future<void> updateRow(void Function() changes) async {
    // Apply changes
    changes();

    // Trigger UI refresh (important for Bloc/Equatable)
    rows = List<PartnerShareholder>.from(rows);
    await Future.delayed(const Duration(milliseconds: 500));
    emit(
      state.copyWith(
        partnerShareholderStatus: LoadingStatus.loaded,
      ),
    );
  }

  /// Sets the residency value for a partner/shareholder row.
  Future<void> setResidency(int i, Reference v) async {
    if (!validIndex(i)) {
      return;
    }
    await updateRow(() {
      rows[i].partnerShareholderResidence = v.reference1;

      if (v.reference1 == "RE") {
        // Resident → clear passport
        rows[i].passportNumberExpiryDatePartnerShareholder = null;
        ctrls[i].passport.text = "";
      } else if (v.reference1 == "NR") {
        // Non-resident → clear emirates ID
        rows[i].emiratesIdPartnerShareholder = "";
        rows[i].emiratesIdExpiryDatePartnerShareholder = null;
      }
    });
  }

  /// Sets the legal status value for a partner/shareholder row.
  Future<void> setLegalStatus(int i, Reference v) async {
    if (!validIndex(i)) {
      return;
    }
    await updateRow(() {
      rows[i].legalStatusOfPartnerShareholder = v.reference1;

      if (v.reference1 == "JP") {
        // Juridical Person
        rows[i].nationalityPartnerShareholder = null;
        rows[i].emiratesIdPartnerShareholder = "";
        rows[i].emiratesIdExpiryDatePartnerShareholder = null;
        ctrls[i].netWorth.text = "";
      } else if (v.reference1 == "NP") {
        // Natural Person
        rows[i].tradeLicenseNumberPartnerShareholder = "";
        rows[i].placeIssueTradeLicenseNumberPartnerShareholder = null;
        rows[i].psLei = null;
        rows[i].leiNumberPartnerShareholder = "";
        ctrls[i].tradeLicense.text = "";
        ctrls[i].leiNumber.text = "";
        ctrls[i].netWorth.text = "0";
      }
    });
  }

  /// Sets the nationality value for a partner/shareholder row.
  Future<void> setNationality(int i, Reference v) async {
    if (!validIndex(i)) {
      return;
    }
    await updateRow(() {
      rows[i].nationalityPartnerShareholder = v.name;
    });
  }

  /// Sets the trade license place of issue for a partner/shareholder row.
  Future<void> setTradeLicensePlace(int i, Reference v) async {
    if (!validIndex(i)) {
      return;
    }
    await updateRow(() {
      rows[i].placeIssueTradeLicenseNumberPartnerShareholder = v.name;
    });
  }

  /// Sets the LEI option for a partner/shareholder row.
  Future<void> setLeiOpt(int i, Reference v) async {
    if (!validIndex(i)) {
      return;
    }
    await updateRow(() {
      final isNo = v.id == ServerConstants.noRefId;
      final isYes = v.id == ServerConstants.yesRefId;

      rows[i].psLei = isYes ? "Y" : "N";

      if (isNo) {
        rows[i].leiNumberPartnerShareholder = "";
        ctrls[i].leiNumber.text = "";
      }
    });
  }

  /// Sets emirates ID expiry date for a partner/shareholder row.
  Future<void> setEmiratesIdExpiry(int i, DateTime? d) async {
    if (!validIndex(i)) {
      return;
    }

    await updateRow(() {
      rows[i].emiratesIdExpiryDatePartnerShareholder = d;
    });
  }

  /// Sets partner/shareholder type for a row.
  Future<void> setType(int i, Reference v) async {
    if (!validIndex(i)) {
      return;
    }
    await updateRow(() {
      rows[i].partnerShareholderType = v.name;
    });
  }

  /// Sets gender for a partner/shareholder row.
  Future<void> setGender(int i, Reference v) async {
    if (!validIndex(i)) {
      return;
    }
    await updateRow(() {
      rows[i].gender = v.name;
    });
  }

  /// Sets passport expiry date for a partner/shareholder row.
  Future<void> setPassportExpiry(int i, DateTime? d) async {
    if (!validIndex(i)) {
      return;
    }

    await updateRow(() {
      rows[i].passportNumberExpiryDatePartnerShareholder = d;
    });
  }

  /// Notifies listeners that a partner/shareholder row has changed.
  Future<void> notifyRowChanged() async {
    rows = List<PartnerShareholder>.from(rows); // new list identity
    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  /// Updates trade license number for a partner/shareholder row.
  void onChangeTLNumber(String value, int index) {
    rows[index].tradeLicenseNumberPartnerShareholder = value;
    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  /// Updates passport number for a partner/shareholder row.
  void onChangePassport(String value, int index) {
    if (value.isEmpty) {
      isDateValidPassportExpiry = false;
      rows[index].passportNumberExpiryDatePartnerShareholder = null;
      rows[index].passportNumberPartnerShareholder = null;
    }
    rows[index].passportNumberPartnerShareholder = value;
    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  /// Updates emirates ID for a partner/shareholder row.
  void onChangeEmiratesId(String value, int index) {
    rows[index].emiratesIdPartnerShareholder = value;
    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  /// Updates LEI number for a partner/shareholder row.
  void onChangeLEINumber(String value, int index) {
    rows[index].leiNumberPartnerShareholder = value;
    // emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  /// Returns whether the given row index is valid.
  bool validIndex(int i) => i >= 0 && i < rows.length;

  PartnerShareholder _row(int i) => rows[i];

  bool _isNP(int i) =>
      validIndex(i) &&
      _row(i).legalStatusOfPartnerShareholder == ServerConstants.legalStatusNP;

  bool _isJP(int i) =>
      validIndex(i) &&
      _row(i).legalStatusOfPartnerShareholder == ServerConstants.legalStatusJP;

  bool _isRE(int i) =>
      validIndex(i) &&
      _row(i).partnerShareholderResidence == ServerConstants.residenceRE;

  bool _isNR(int i) =>
      validIndex(i) &&
      _row(i).partnerShareholderResidence == ServerConstants.residenceNR;

  /// Returns whether the net worth field is editable for a row.
  bool isnetworkEditable(int i) {
    if (canEdit) {
      final bool valid = validIndex(i);

      final bool np = _isNP(i);
      final bool result = valid && np;
      if (result) {
        rows[i].networthPartnerShareholderAed = "0";
      }
      return result;
    } else {
      return true;
    }
  }

  /// Returns whether emirates ID field is enabled for a row.
  bool eidEnabled(int i) {
    if (canEdit) {
      final bool valid = validIndex(i);
      final bool re = _isRE(i);
      final bool jp = _isJP(i);
      final bool result = valid && !(re && jp);

      logger.i(
        "[EID DEBUG] index=$i  valid=$valid  "
        "RE=$re  NP=$jp  ->  eidEnabled=$result",
      );

      return result;
    } else {
      return true;
    }
  }

  /// Returns whether emirates ID expiry field is enabled for a row.
  bool eidExpiryEnabled(int i) {
    if (canEdit) {
      return validIndex(i) &&
          (_row(i).emiratesIdPartnerShareholder?.trim().isNotEmpty ?? false);
    } else {
      return false;
    }
  }

  /// Returns whether passport field is enabled for a row.
  bool passportEnabled(int i) {
    final bool valid = validIndex(i);
    final bool re = _isRE(i);
    final bool np = _isNP(i);

    final bool result = valid && !(re && np);

    // DEBUG PRINT
    logger.i(
      "[PASSPORT-ENABLED] index=$i  valid=$valid  RE=$re  NP=$np  ->  $result",
    );

    return result;
  }

  /// Returns whether passport expiry field is enabled for a row.
  bool passportExpiryEnabled(int i) {
    if (canEdit) {
      return validIndex(i) &&
          (_row(i).passportNumberPartnerShareholder?.trim().isNotEmpty ??
              false);
    } else {
      return false;
    }
  }

  /// Returns whether nationality is required for a row.
  bool nationalityRequired(int i) => validIndex(i) && _isNP(i);

  /// Returns whether trade license field is enabled for a row.
  bool tradeLicenseEnabled(int i) {
    if (canEdit) {
      return validIndex(i) && _isJP(i);
    } else {
      return false;
    }
  }

  /// Returns whether trade license place field is enabled for a row.
  bool tradeLicensePlaceEnabled(int i) {
    if (canEdit) {
      return validIndex(i) &&
          (_row(i).tradeLicenseNumberPartnerShareholder?.trim().isNotEmpty ??
              false);
    } else {
      return false;
    }
  }

  /// Returns whether LEI fields are visible for a row.
  bool leiVisible(int i) => validIndex(i) && _isJP(i);

  /// Returns whether LEI number field is enabled for a row.
  bool leiNumberEnabled(int i) =>
      validIndex(i) && _isJP(i) && _row(i).psLei == ServerConstants.psLeiYes;
  //&& (selectedLegalEntityIdentifier?.id == ServerConstants.yesRefId);
  //yesNoNaItems[0]; // JP and LEI-yes :)

  /// Validates all partner/shareholder rows.
  List<String> validateAll() {
    final allErrors = <String>[];
    for (var i = 0; i < rows.length; i++) {
      final errs = validateRow(i);
      allErrors.addAll(errs.map((e) => "Row ${i + 1}: $e"));
    }
    return allErrors;
  }

  /// Validates a partner/shareholder row by index.
  List<String> validateRow(int i) {
    final m = rows[i];
    final errs = <String>[];

    final isRE = _isRE(i);
    final isNR = _isNR(i);
    final isNP = _isNP(i);
    final isJP = _isJP(i);

    // ---------- Mandatory fields ----------
    if ((m.partnerShareholderInEnglish ?? "").trim().isEmpty) {
      errs.add("ccsys.customerInformation.nameEnglishRequired".tr());
    }
    if ((m.partnerShareholderResidence ?? "").isEmpty) {
      errs.add("ccsys.customerInformation.residenceRequired".tr());
    }
    if ((m.partnerShareholderType ?? "").isEmpty) {
      errs.add("ccsys.customerInformation.typeRequired".tr());
    }
    if (m.shareholdingPartnershipPercentage == null ||
        m.shareholdingPartnershipPercentage! < 0 ||
        m.shareholdingPartnershipPercentage! > 100) {
      errs.add("ccsys.customerInformation.holdingOutOfRange".tr());
    }
    // If you allow decimals for net worth, ensure the model type supports it
    // (double?).
    if (m.networthPartnerShareholderAed == null ||
        (m.networthPartnerShareholderAed ?? "").isEmpty) {
      errs.add("ccsys.customerInformation.networthRequired".tr());
    }
    // if ((m.networthPartnerShareholderAed ?? '').trim() == '0') {
    // errs.add('Networth cannot be 0 for NP');
    // }
    // ---------- Conditional — Emirates ID ----------
    if (isRE && isNP) {
      if ((m.emiratesIdPartnerShareholder ?? "").trim().isEmpty) {
        errs.add("ccsys.customerInformation.emiratesIdRequiredReNp".tr());
      } else if (m.emiratesIdExpiryDatePartnerShareholder == null) {
        errs.add("ccsys.customerInformation.emiratesIdExpiryRequired".tr());
      }
    }

    // ---------- Conditional — Passport ----------
    final mustProvidePassport = isNR && isNP;
    final passport = (m.passportNumberPartnerShareholder ?? "").trim();
    if (mustProvidePassport) {
      if (passport.isEmpty) {
        errs.add("ccsys.customerInformation.passportRequiredNrNp".tr());
      } else {
        // Format: <ALPHANUMERIC>/<COUNTRY CODE> e.g., AK00000/CA
        final passportPattern = RegExp(r"^[A-Za-z0-9]+/[A-Za-z]{2,3}$");
        if (!passportPattern.hasMatch(passport)) {
          errs.add("ccsys.customerInformation.passportFormat".tr());
        }
      }
    }

    // Passport expiry is mandatory only if passport value is provided
    if (passport.isNotEmpty &&
        m.passportNumberExpiryDatePartnerShareholder == null) {
      errs.add("ccsys.customerInformation.passportExpiryRequired".tr());
    }

    // ---------- Conditional — Nationality ----------
    if (isNP && (m.nationalityPartnerShareholder ?? "").isEmpty) {
      errs.add("ccsys.customerInformation.nationalityRequiredNp".tr());
    }

    // ---------- Conditional — Trade License ----------
    final tl = (m.tradeLicenseNumberPartnerShareholder ?? "").trim();
    if (isJP) {
      if (tl.isEmpty) {
        errs.add("ccsys.customerInformation.tradeLicenseRequiredJp".tr());
      }
    }
    if (tl.isNotEmpty &&
        (m.placeIssueTradeLicenseNumberPartnerShareholder ?? "").isEmpty) {
      errs.add("ccsys.customerInformation.placeOfIssueRequiredWithTl".tr());
    }

    // ---------- Conditional — LEI (JP only) ----------
    if (isJP) {
      // if ((m.psLei ?? '').isEmpty) {
      //   errs.add(
      //       'Legal Entity Identifier (Y/N) is mandatory when Legal Status = JP');
      // } else
      if (m.psLei == "Y") {
        final lei = (m.leiNumberPartnerShareholder ?? "").trim();
        if (lei.isEmpty) {
          errs.add("ccsys.customerInformation.leiFieldsRequired".tr());
        }
        // final leiPattern = RegExp(r'^[A-Za-z0-9]{20}$');
        // if (!leiPattern.hasMatch(lei)) {
        //   errs.add('LEI Number must be exactly 20 alphanumeric characters');
        // }
      }
    }

    // ---------- Gender ----------
    if ((m.gender ?? "").isEmpty) {
      errs.add("ccsys.customerInformation.genderRequired".tr());
    }

    return errs;
  }

  /// Closes the view model and unregisters draft callback.
  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }
}

/// Holds text editing controllers for a partner/shareholder row.
class PartnerShareholderControllers {
  /// Controller for partner/shareholder English name.
  final TextEditingController name = TextEditingController();

  /// Controller for shareholding percentage.
  final TextEditingController sharePercent = TextEditingController();

  /// Controller for net worth.
  final TextEditingController netWorth = TextEditingController();

  /// Controller for emirates ID.
  final TextEditingController emiratesId = TextEditingController();

  /// Controller for passport number.
  final TextEditingController passport = TextEditingController();

  /// Controller for trade license number.
  final TextEditingController tradeLicense = TextEditingController();

  /// Controller for LEI number.
  final TextEditingController leiNumber = TextEditingController();

  /// Attaches controller listeners to the given partner/shareholder model.
  void attach(PartnerShareholder m) {
    // set initial text
    name.text = m.partnerShareholderInEnglish ?? "";
    sharePercent.text = m.shareholdingPartnershipPercentage?.toString() ?? "";
    netWorth.text = m.networthPartnerShareholderAed?.toString() ?? "";
    emiratesId.text = m.emiratesIdPartnerShareholder ?? "";
    passport.text = m.passportNumberPartnerShareholder ?? "";
    tradeLicense.text = m.tradeLicenseNumberPartnerShareholder ?? "";
    leiNumber.text = m.leiNumberPartnerShareholder ?? "";

    // keep model in sync when user types
    name.addListener(() => m.partnerShareholderInEnglish = name.text);
    sharePercent.addListener(() {
      final s = sharePercent.text.trim();
      m.shareholdingPartnershipPercentage = int.tryParse(s);
    });
    netWorth.addListener(() {
      final s = netWorth.text.trim();
      // model is int?; parse as int (if backend supports decimals, switch model
      // to double?)
      m.networthPartnerShareholderAed = s;
    });
    emiratesId
        .addListener(() => m.emiratesIdPartnerShareholder = emiratesId.text);
    passport
        .addListener(() => m.passportNumberPartnerShareholder = passport.text);
    tradeLicense.addListener(
      () => m.tradeLicenseNumberPartnerShareholder = tradeLicense.text,
    );
    leiNumber.addListener(() => m.leiNumberPartnerShareholder = leiNumber.text);
  }

  /// Disposes all text editing controllers.
  void dispose() {
    name.dispose();
    sharePercent.dispose();
    netWorth.dispose();
    emiratesId.dispose();
    passport.dispose();
    tradeLicense.dispose();
    leiNumber.dispose();
  }
}
