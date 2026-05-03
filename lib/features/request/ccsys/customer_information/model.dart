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
import "package:wcas_frontend/core/utils/date_time_utils.dart";
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

class CustomerInformationViewModel extends SafeCubit<CustomerInformationState>
    with DraftMixin<CustomerInformationViewModel> {
  CustomerInformationViewModel()
      : super(
          CustomerInformationState(
            loaderStatus: LoadingStatus.loading,
            partnerShareholderStatus: LoadingStatus.loading,
          ),
        );
  late CcsysRepository repository;
  late CustomerRepository repositoryCustomer;
  final FocusNode formFocusNode = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // List<Customer>? customers = [];
  List<Country>? countries = [];
  // List<Reference>? status = [];

  // Customer? customer;
  Request request = Request();
  CcsysCustomerInformation customerInformation = CcsysCustomerInformation();
  ApplicationDetails? applicationDetails = ApplicationDetails();
  int? ccsysCustomerInformationId;
  final TextEditingController leiController = TextEditingController();
  final TextEditingController controllerGroupUltimate = TextEditingController();
  final TextEditingController controllerGroupImmediate =
      TextEditingController();
  final TextEditingController capitalController = TextEditingController();
  final TextEditingController turnoverController = TextEditingController();
  final TextEditingController auditorController = TextEditingController();
  final TextEditingController numberOfEmployeeController =
      TextEditingController();
  bool isBorrowingSubsidiary = false;
  bool isLegalEntityIdentifier = false;
  List<Reference> applicationTypes = [];

  List<Reference> radioButtonItems = [
    Reference(id: 0, name: "No"),
    Reference(id: 1, name: "Yes"),
  ];

  List<Reference> yesNoNaItems = [];

  Reference? selectedBorroweSubsidiary;
  Reference? selectedLegalEntityIdentifier;
  Reference? selectedEmirateLicense;
  Reference? selectedEmirateEstablishment;

  Reference defaultField = Reference(id: 0, name: "NA");

  // Rows + controllers
  List<PartnerShareholder> rows = [];
  List<PartnerShareholderControllers> ctrls = [];

  // Plug your references (set these from your outer ViewModel)
  List<Reference> ccsysCountryList = [];
  List<Reference> ccsysEmirateList = []; // if needed separately
  List<Reference> ccsysGender = [];
  List<Reference> ccsysPartnerLegalStatus = [];
  List<Reference> ccsysPartnerShareholderResidence = [];
  List<Reference> ccsysPartnerShareholderType = [];

  // country code set for passport validation (NUMBER/CC)
  Set<String> allowedCountryCodes = {};

  bool canEdit = false;
  // State
  PageMode pageMode = PageMode.na;

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

  @override
  String get draftModuleKey => DraftModuleKeys.ccsys;

  @override
  String get draftFormKey => Routes.customerInformation;

  @override
  DraftHandler<CustomerInformationViewModel> get draftHandler =>
      CustomerInformationDraftHandler();

  // ---------------------------------------------------------------------------

  Future<void> init(context) async {
    repository = CcsysRepository.instance;
    repositoryCustomer = CustomerRepository.instance;
    request = Globals.request ?? Request();
    applicationTypes = [Reference(name: "CCSYS")];
    initRightsAndMode(request);

    try {
      await Future.wait([getReferenceData(), getCustomerInformation()]);
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

  /// *************getCustomerInformation********************
  /// Keeps your `Request` model unchanged; performs safe type conversions.
  Future<void> getCustomerInformation() async {
    try {
      customerInformation = await repository.getCustomerInformationCCSYS() ??
          CcsysCustomerInformation();

      ccsysCustomerInformationId = customerInformation.ccsysCustomerId;

      if (customerInformation.borrowerSubsidiary == null) {
        customerInformation.borrowerSubsidiary = false;

        selectedBorroweSubsidiary = radioButtonItems.firstWhere(
          (e) => e.id == ServerConstants.noRefId,
          orElse: () => radioButtonItems[0],
        );

        isBorrowingSubsidiary = false;
        controllerGroupImmediate.text = "NA";
        controllerGroupUltimate.text = "NA";
      } else {
        emit(
          state.copyWith(
            borrowerSubsidiary: customerInformation.borrowerSubsidiary,
          ),
        );
        controllerGroupImmediate
            .text = customerInformation.groupImmediateParent != null ||
                customerInformation.groupImmediateParent.toString() != "null"
            ? customerInformation.groupImmediateParent.toString()
            : "NA";
        controllerGroupUltimate.text =
            customerInformation.groupUltimateParent != null ||
                    customerInformation.groupUltimateParent.toString() != "null"
                ? customerInformation.groupUltimateParent.toString()
                : "NA";
      }

      if (customerInformation.legalEntityIdentifier == null) {
        customerInformation.legalEntityIdentifier = false;
        selectedLegalEntityIdentifier = radioButtonItems.firstWhere(
          (e) => e.id == ServerConstants.noRefId,
          orElse: () => radioButtonItems[0],
        );
        leiController.text = "NA";
      } else {
        emit(
          state.copyWith(
            legalEntityIdentifier: customerInformation.legalEntityIdentifier,
          ),
        );

        if (customerInformation.legalEntityIdentifier == false) {
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
    } catch (e) {
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
    } catch (e) {
      rethrow;
    }
  }

  void onLegalStatusPartnerSelected(Reference legalStatusPartners) {}

  // is Legal status == NP and Residency status == RE
  bool isLegalNpAndResidencyRE() {
    return false;
  }

  void onChangeBorrowingSubsidiary(Reference? selectedOption) {
    selectedOption == radioButtonItems[0]
        ? isBorrowingSubsidiary = false
        : isBorrowingSubsidiary = true;
    customerInformation.radioButtonItems = selectedOption;

    selectedBorroweSubsidiary = selectedOption;
    customerInformation.borrowerSubsidiary =
        (selectedOption?.id == ServerConstants.yesRefId);
    emit(
      state.copyWith(
        borrowerSubsidiary: selectedOption?.id == ServerConstants.yesRefId,
      ),
    );

    // if (!(selectedOption?.id == ServerConstants.yesRefId)) {
    //   controllerGroupImmediate.text = 'NA';
    //   controllerGroupUltimate.text = 'NA';
    // } else {
    //   controllerGroupImmediate.text =
    //       customerInformation.groupUltimateParent != null
    //           ? customerInformation.groupUltimateParent?.toString() ?? ''
    //           : '';
    //   controllerGroupUltimate.text =
    //       customerInformation.groupImmediateParent != null
    //           ? customerInformation.groupImmediateParent?.toString() ?? ''
    //           : '';
    // }

    if (selectedOption?.id == ServerConstants.noRefId) {
      controllerGroupImmediate.text = "NA";
      controllerGroupUltimate.text = "NA";
    } else {
      controllerGroupImmediate.text = "";
      // customerInformation.groupImmediateParent != null ||
      //         customerInformation.groupImmediateParent.toString() != 'null'
      //     ? customerInformation.groupImmediateParent.toString() != 'NA'
      //         ? customerInformation.groupImmediateParent.toString()
      //         : ""
      // : '';
      controllerGroupUltimate.text = "";
      // customerInformation.groupUltimateParent != null ||
      //         customerInformation.groupUltimateParent.toString() != 'null'
      //     ? customerInformation.groupUltimateParent.toString() != 'NA'
      //         ? customerInformation.groupUltimateParent.toString()
      //         : ""
      //     : '';
    }

    emit(state.copyWith(customerSelectedStatus: LoadingStatus.loaded));
  }

  void setEmiratesId(String? emiratesIdPartner) {
    customerInformation.emiratesIdPartner = emiratesIdPartner;
    emit(state.copyWith(customerSelectedStatus: LoadingStatus.loaded));
  }

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

      leiController.text =
          // customerInformation.leiNumber != null ||
          //         customerInformation.leiNumber.toString() != 'null'
          //     ? customerInformation.leiNumber.toString() != 'NA'
          //         ? customerInformation.leiNumber.toString()
          //         : ""
          //     :
          "";
    }

    emit(state.copyWith(customerSelectedStatus: LoadingStatus.loaded));
  }

  /// Called when a country-chip’s delete icon is tapped
  void onCountryChipDeleted(int index) {
    final list = customerInformation.countryOfRiskFundUtilization;
    if (list == null || index < 0 || index >= list.length) return;

    list.removeAt(index);

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Overwrite the entire Country selection (from onSelected) and emit.
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
        if (isDateValid == true) {
          throw "ccsys.customerInformation.dateAutitedEnterError".tr();
        }
        // if (isDateValidPassportExpiry == true) {
        //   throw "ccsys.customerInformation.passportExpiryEnterError".tr();
        // } //
        AlertManager().showFailureToast(
          "requestInformation.requestInformation.requiredFeild".tr(),
        );
        return;
      }

      formKey.currentState?.save();

      if (isDateValid == true) {
        throw "ccsys.customerInformation.dateAutitedEnterError".tr();
      }
      // if (isDateValidPassportExpiry == true) {
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
      if (shareHolderMessage != null) throw shareHolderMessage;

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
      //debugPrint('Payload: $payload');

      final String response =
          await repository.saveCustomerInformation(customerInformation);
      await getCustomerInformation();

      if (response == "common.success".tr()) {
        AlertManager().showSuccessToast("common.saveSuccess".tr());
        if (ifNavigate) {
          router.go(Routes.ccsysApproval);
        }
      } else {
        AlertManager().showFailureToast(response);
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    unawaited(deleteDraft());
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Validates "Date of audited FS"
  /// Rules:
  /// - Mandatory: must not be empty
  /// - Format: dd/MM/yyyy
  /// - Cannot be in the future (must be ≤ today)
  bool? isDateValid = false;
  bool? isDateValidPassportExpiry = false;
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

  // Reusable method to filter out 'NA'
  List<Reference> getFilteredOptions(List<Reference> options) {
    return options
        .where(
          (ref) => ref.name != "requestInformation.requestInformation.na".tr(),
        )
        .toList();
  }

  // Reusable method to get selected value with fallback => Product Type Logics
  Reference getSelectedReference({
    required List<Reference> options,
    required Reference? selectedValue,
    required bool? fallbackFlag,
  }) {
    final filtered = getFilteredOptions(options);

    if (selectedValue != null && filtered.contains(selectedValue)) {
      return selectedValue;
    }

    if (filtered.isEmpty) {
      return Reference(name: "requestInformation.requestInformation.no".tr());
    }

    final fallbackName = fallbackFlag == true
        ? "requestInformation.requestInformation.yes".tr()
        : "requestInformation.requestInformation.no".tr();

    return filtered.firstWhere(
      (ref) => ref.name == fallbackName,
      orElse: () => filtered.first,
    );
  }

  // ---------- lifecycle ----------
  void initializeControllers(List<PartnerShareholder> initial) {
    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loading));

    rows = List<PartnerShareholder>.from(initial);
    ctrls = rows.map((m) {
      final c = PartnerShareholderControllers()..attach(m);
      return c;
    }).toList();
    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  void disposeControllers() {
    for (final c in ctrls) {
      c.dispose();
    }
    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  // ---------- add/remove ----------
  void addRow() {
    // emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loading));

    final PartnerShareholder m = PartnerShareholder();
    final PartnerShareholderControllers c = PartnerShareholderControllers()
      ..attach(m);
    rows.add(m);
    ctrls.add(c);

    // Change list references
    rows = List<PartnerShareholder>.from(rows);
    ctrls = List<PartnerShareholderControllers>.from(ctrls);

    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  void removeRow(int index) {
    if (index < 0 || index >= rows.length) return;
    // emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loading));

    rows.removeAt(index);
    ctrls[index].dispose();
    ctrls.removeAt(index);

    rows = List<PartnerShareholder>.from(rows);
    ctrls = List<PartnerShareholderControllers>.from(ctrls);

    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  // ---------- enable/required helpers ----------
  Future<void> setResidency(int i, Reference v) async {
    // emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loading));

    rows[i].partnerShareholderResidence = v.reference1; // 'RE'/'NR'
    if (v.reference1 == "RE") {
      // rows[i].passportNumberPartnerShareholder = '';
      rows[i].passportNumberExpiryDatePartnerShareholder = null;
      ctrls[i].passport.text = "";
    } else if (v.reference1 == "NR") {
      rows[i].emiratesIdPartnerShareholder = "";
      rows[i].emiratesIdExpiryDatePartnerShareholder = null;
      // ctrls[i].emiratesId.text = '';
    }

    // CHANGE reference to ensure Equatable/Bloc sees a new list
    rows = List<PartnerShareholder>.from(rows);
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  Future<void> setType(int i, Reference v) async {
    // emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loading));

    rows[i].partnerShareholderType = v.name; // 'PR1'/'SH2'/'JA3'
    rows = List<PartnerShareholder>.from(rows);
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  Future<void> setLegalStatus(int i, Reference v) async {
    // emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loading));

    rows[i].legalStatusOfPartnerShareholder = v.reference1; // 'JP'/'NP'
    if (v.reference1 == "JP") {
      rows[i].nationalityPartnerShareholder = null;
      rows[i].emiratesIdPartnerShareholder = "";
      rows[i].emiratesIdExpiryDatePartnerShareholder = null;
      // ctrls[i].emiratesId.text = '';
      ctrls[i].netWorth.text = "";
    } else if (v.reference1 == "NP") {
      rows[i].tradeLicenseNumberPartnerShareholder = "";
      rows[i].placeIssueTradeLicenseNumberPartnerShareholder = null;
      rows[i].psLei = null;
      rows[i].leiNumberPartnerShareholder = "";
      ctrls[i].tradeLicense.text = "";
      ctrls[i].leiNumber.text = "";
      ctrls[i].netWorth.text = "0";
    }

    rows = List<PartnerShareholder>.from(rows);
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  Future<void> setNationality(int i, Reference v) async {
    // emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loading));

    rows[i].nationalityPartnerShareholder = v.name;
    rows = List<PartnerShareholder>.from(rows);
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  Future<void> setTradeLicensePlace(int i, Reference v) async {
    // emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loading));

    rows[i].placeIssueTradeLicenseNumberPartnerShareholder = v.name;
    rows = List<PartnerShareholder>.from(rows);
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  Future<void> setLeiOpt(int i, Reference v) async {
    // emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loading));

    // Prefer backend codes via id; still keep psLei as 'Y'/'N' for your model
    final isNo = (v.id == ServerConstants.noRefId);
    final isYes = (v.id == ServerConstants.yesRefId);

    rows[i].psLei = isYes
        ? "Y"
        : isNo
            ? "N"
            : "N";

    if (isNo) {
      rows[i].leiNumberPartnerShareholder = "";
      ctrls[i].leiNumber.text = "";
    }

    rows = List<PartnerShareholder>.from(rows);
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  Future<void> setGender(int i, Reference v) async {
    // emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loading));

    rows[i].gender = v.name;
    rows = List<PartnerShareholder>.from(rows);
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  Future<void> setEmiratesIdExpiry(int i, DateTime? d) async {
    // emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loading));

    rows[i].emiratesIdExpiryDatePartnerShareholder = d;
    rows = List<PartnerShareholder>.from(rows);
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  Future<void> setPassportExpiry(int i, DateTime? d) async {
    // emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loading));

    rows[i].passportNumberExpiryDatePartnerShareholder = d;
    rows = List<PartnerShareholder>.from(rows);
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

// In CustomerInformationViewModel
  Future<void> notifyRowChanged() async {
    rows = List<PartnerShareholder>.from(rows); // new list identity
    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  void onChangeTLNumber(String value, int index) {
    rows[index].tradeLicenseNumberPartnerShareholder = value;
    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  void onChangePassport(String value, int index) {
    if (value.isEmpty) {
      isDateValidPassportExpiry = false;
      rows[index].passportNumberExpiryDatePartnerShareholder = null;
      rows[index].passportNumberPartnerShareholder = null;
    }
    rows[index].passportNumberPartnerShareholder = value;
    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  void onChangeEmiratesId(String value, int index) {
    rows[index].emiratesIdPartnerShareholder = value;
    emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  void onChangeLEINumber(String value, int index) {
    rows[index].leiNumberPartnerShareholder = value;
    // emit(state.copyWith(partnerShareholderStatus: LoadingStatus.loaded));
  }

  bool _validIndex(int i) => i >= 0 && i < rows.length;
  PartnerShareholder _row(int i) => rows[i];

  bool _isNP(int i) =>
      _validIndex(i) &&
      _row(i).legalStatusOfPartnerShareholder == ServerConstants.legalStatusNP;
  bool _isJP(int i) =>
      _validIndex(i) &&
      _row(i).legalStatusOfPartnerShareholder == ServerConstants.legalStatusJP;
  bool _isRE(int i) =>
      _validIndex(i) &&
      _row(i).partnerShareholderResidence == ServerConstants.residenceRE;
  bool _isNR(int i) =>
      _validIndex(i) &&
      _row(i).partnerShareholderResidence == ServerConstants.residenceNR;

  bool isnetworkEditable(int i) {
    final bool valid = _validIndex(i);

    final bool np = _isNP(i);
    final bool result = valid && np;
    if (result) {
      rows[i].networthPartnerShareholderAed = "0";
    }
    return result;
  }

  bool eidEnabled(int i) {
    final bool valid = _validIndex(i);
    final bool re = _isRE(i);
    final bool jp = _isJP(i);
    final bool result = valid && !(re && jp);

    debugPrint(
      "[EID DEBUG] index=$i  valid=$valid  "
      "RE=$re  NP=$jp  ->  eidEnabled=$result",
    );

    return result;
  }

  bool eidExpiryEnabled(int i) =>
      _validIndex(i) &&
      (_row(i).emiratesIdPartnerShareholder?.trim().isNotEmpty ?? false);

  bool passportEnabled(int i) {
    final bool valid = _validIndex(i);
    final bool re = _isRE(i);
    final bool np = _isNP(i);

    final bool result = valid && !(re && np);

    // DEBUG PRINT
    debugPrint(
      "[PASSPORT-ENABLED] index=$i  valid=$valid  RE=$re  NP=$np  ->  $result",
    );

    return result;
  }

  bool passportExpiryEnabled(int i) =>
      _validIndex(i) &&
      (_row(i).passportNumberPartnerShareholder?.trim().isNotEmpty ?? false);

  bool nationalityRequired(int i) => _validIndex(i) && _isNP(i);

  bool tradeLicenseEnabled(int i) => _validIndex(i) && _isJP(i);

  bool tradeLicensePlaceEnabled(int i) =>
      _validIndex(i) &&
      (_row(i).tradeLicenseNumberPartnerShareholder?.trim().isNotEmpty ??
          false);

  bool leiVisible(int i) => _validIndex(i) && _isJP(i);

  bool leiNumberEnabled(int i) =>
      _validIndex(i) && _isJP(i) && _row(i).psLei == ServerConstants.psLeiYes;
  //&& (selectedLegalEntityIdentifier?.id == ServerConstants.yesRefId);
  //yesNoNaItems[0]; // JP and LEI-yes :)

// Example submit
  List<String> validateAll() {
    final allErrors = <String>[];
    for (var i = 0; i < rows.length; i++) {
      final errs = validateRow(i);
      allErrors.addAll(errs.map((e) => "Row ${i + 1}: $e"));
    }
    return allErrors;
  }

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

  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }
}

class PartnerShareholderControllers {
  final TextEditingController name = TextEditingController();
  final TextEditingController sharePercent = TextEditingController();
  final TextEditingController netWorth = TextEditingController();
  final TextEditingController emiratesId = TextEditingController();
  final TextEditingController passport = TextEditingController();
  final TextEditingController tradeLicense = TextEditingController();
  final TextEditingController leiNumber = TextEditingController();

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
