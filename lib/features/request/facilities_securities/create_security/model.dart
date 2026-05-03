// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures

import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dynamic_form/dynamic_form.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/section.dart";
import "package:wcas_frontend/core/components/dynamic_form/utils/date_utils.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
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
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/draft_handler.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/country.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/facility_security/exchange_rate.dart";
import "package:wcas_frontend/models/request/facility_security/limit_facilities.dart";
import "package:wcas_frontend/models/request/facility_security/security.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// A ViewModel class that manages the creation and configuration of security
/// details
/// within the application. It handles form state, reference data retrieval,
/// user interactions, and saving of security information.
class CreateSecurityViewModel extends SafeCubit<CreateSecurityState>
    with DraftMixin<CreateSecurityViewModel> {
  CreateSecurityViewModel()
      : super(CreateSecurityState(loaderStatus: LoadingStatus.loading));

  // --- DRAFT IDENTITY ---
  @override
  String get draftModuleKey => DraftModuleKeys.facilitiesAndSecurities;
  @override
  String get draftFormKey {
    if (isUpdateFlow) {
      return "${Routes.createSecurity}_update_${security.securityId}";
    } else if (security.securityType?.id != null) {
      // Build security route key by type ID
      final String typeId = security.securityType!.id.toString();
      return "${Routes.createSecurity}_create_type_$typeId";
    }
    return Routes.createSecurity;
  }

  @override
  DraftHandler<CreateSecurityViewModel> get draftHandler =>
      CreateSecurityDraftHandler();
  // ----------------------

  /// Repository for handling request-related operations.
  RequestRepository repository = RequestRepository.instance;

  GlobalKey<DynamicFormState> dynamicFormKey = GlobalKey<DynamicFormState>();
  Request request = Request();
  Security security = Security(
    selectedIsSecurityProviderCbdCustomerValue: Reference(
      id: ServerConstants.optionYESid,
    ),
  );
  Customer? customerDetails = Customer();
  bool isCountrySecurityUAE = false;
  bool isApproved = false;

  /// Repository for handling facility security-related operations.
  FacilitySecurityRepository securityRepository =
      FacilitySecurityRepository.instance;

  CustomerRepository customerRepository = CustomerRepository();

  /// Global key for the main form used in the security creation screen.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Global key for the dynamic form section.

  List<Reference>? yesAndNo = [];
  List<Reference> securityReferenceData = [];
  List<Reference> securityBorrowerRole = [];
  bool securityProviderCbdCustomer = true;

  List<Reference> securityDeferredWaivedItems = [];

  List<Reference> emiratesItems = [];
  List<Reference> economicZones = [];

  List<Reference> securityLegalStatus = [];
  List<Reference> controllingLimitNumbers = [];
  List<Reference?> securityTypes = [];
  List<Reference?> bankNames = [];

  List<Reference> currencyCodes = [];

  List<Reference> securityHeldAsList = [];
  List<Reference> securityProvidedCategories = [];

  List<Reference> securityStatusList = [];

  List<Section> sections = [];

  num exchangeRate = 0;
  double? loanToValue;
  double? currentMarketValue;
  List<Country> countries = [];

  Map<String, dynamic> dynamicFormDocument = {};
  List<String> commitmentAccountNumbers = [];
  String? selectedCurrencyCode; // e.g., "AED"
  bool showProposedSecurityAmount = false;
  bool showPresentSecurityAmount = false;
  bool disableFxRates = false;
  bool isEntityProvider = false;
  bool isNaturalPersonProvider = false;
  bool isParipassu = true;
  bool didPrefillCountryFromRim = false;

  TextEditingController proposedSecurityAmountController =
      TextEditingController();
  TextEditingController newProposedSecurityAmountController =
      TextEditingController();
  TextEditingController presentSecurityAmountController =
      TextEditingController();
  TextEditingController newPresentSecurityAmountController =
      TextEditingController();
  TextEditingController securityProviderRimNumberController =
      TextEditingController();
  TextEditingController securityProviderNameController =
      TextEditingController();
  TextEditingController securityProviderTlNumberController =
      TextEditingController();
  TextEditingController securityProviderEmiratesIDController =
      TextEditingController();
  TextEditingController securityNumberController = TextEditingController();

  /// Map to store debounce timers for grid customer searches
  /// Key format: "customerRimGrid@{rowIndex}"
  final Map<String, Timer?> _customerSearchDebounceTimers = {};

  PageMode? pageMode;
  String? remark;
  String? cmoRemark;

  bool get canEdit =>
      pageMode == PageMode.edit; //&& Utils.canEditApplication();

  String? countryOfIncorporation = "";
  String? guarantatorNationality = "";
  String? guarantatorIdDocumentType = "";
  String? guarantatorIdNumber = "";
  String? guarantatorUaeAddress = "";
  String? guarantatorExpiryDate = "";

  Country? preselectedCountry;

  bool get isUpdateFlow =>
      security.securityId != null && security.securityId != 0;

  // RTE Controllers for FI Flow (initialized only if needed)
  UnifiedEditorController? remarksController;
  UnifiedEditorController? cmoRemarksController;
  final ScrollController scrollController = ScrollController();

  /// Initializes the ViewModel by setting up repositories and loading reference
  /// data.
  Future<void> init(
    Security? selectedSecurity, {
    PageMode? pageModeFromArgs,
  }) async {
    request = Globals.request ?? Request();
    isApproved = selectedSecurity != null;
    pageMode = pageModeFromArgs ??
        AuthRepository.getPageMode(RightConstants.createSecurity);

    // Initialize RTE controllers ONLY for FI flow
    if (isFIFlow) {
      remarksController = UnifiedEditorController();
      cmoRemarksController = UnifiedEditorController();
    }

    await getReferenceDatas();
    await getLimitsandFacilities(
      Globals.request?.groupOwner ?? Globals.request?.customerRimNo,
    );
    if (selectedSecurity != null) {
      //For Update/View Security Flow
      security = selectedSecurity;
      await getCountries();
      await getSecurity(selectedSecurity);

      if (canEdit) {
        registerDraftCallback();
        await loadDraftIfAvailable();
      }

      await loadDynamicForm();
      await initDynamicForm(selectedSecurity);
    } else {
      // Create flow: load countries early so the nationality dropdown
      // can match draft values when the form first renders.
      await getCountries();

      if (canEdit) {
        registerDraftCallback();
      }
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  ///api call for only when created new security for
  /// the security value provided for the previously approved limits should be
  /// displayed
  Future<void> getApprovedSecurity(Security? selectedSecurity) async {
    if (selectedSecurity?.securityId != null) return;
    try {
      final Security? approvedSecurity = await repository.getSecurityDetails(
        selectedSecurity: selectedSecurity,
        countries: countries,
      );

      //  Extract ONLY present security value from the response
      //    Depending on your Security.fromJson, this is mapped to
      // presentSecurityAmount.
      final double? approvedPresentSecurity =
          approvedSecurity?.presentSecurityAmount;

      if (approvedPresentSecurity != null && approvedPresentSecurity > 0) {
        security.presentSecurityAmount = approvedPresentSecurity.toDouble();
        final NumberFormat formatter = NumberFormat("#,###");
        final String presentTxt =
            formatter.format(approvedPresentSecurity.toInt());
        presentSecurityAmountController.value = TextEditingValue(
          text: presentTxt,
          selection: TextSelection.collapsed(offset: presentTxt.length),
        );
        await getCurrencyRates(security.presentSecurityAmtCurrency, true);
      }
    } catch (e) {
      AlertManager().showFailureToast("exp:$e");
    }
  }

  Future<void> getSecurity(Security? selectedSecurity) async {
    try {
      security = await repository.getSecurityDetails(
            selectedSecurity: selectedSecurity,
            countries: countries,
          ) ??
          Security();
      isEntityProvider =
          security.securityProviderCategory == ServerConstants.entity;
      isNaturalPersonProvider =
          security.securityProviderCategory == ServerConstants.naturalPerson;
      isCountrySecurityUAE =
          security.countryOfSecurity == ServerConstants.aedDescription;

      // Update RTE controllers with fetched text if applicable
      if (isFIFlow) {
        if (remarksController != null) {
          remarksController!.setText(security.remarks ?? "");
        }
        if (cmoRemarksController != null) {
          cmoRemarksController!.setText(security.cmoRemark ?? "");
        }
      }
      //TODO use better approach than assinging into controller text
      securityNumberController.text = security.securityNumber ?? "";
      securityProviderCbdCustomer =
          security.selectedIsSecurityProviderCbdCustomerValue?.id ==
              ServerConstants.optionYESid;
      preselectedCountry = security.securityProvidedCountry;
      // security.securityType = null; //TODO causing error in dynamic form fetching

      securityProviderNameController.text = security.securityProvidedName ?? "";
      await getCurrencyRates(
        security.proposedSecurityAmtCurrency,
        false,
        proposedAmount: security.proposedSecurityAmount,
      );
      if (security.dynamicFormDocument != null) {
        //Imp Note:below code for additional details is temporarily written here
        //to test, it will be needed to be moved to a method upon its desired
        //outcome

        dynamicFormDocument = security.dynamicFormDocument!;
      }
      getCMOremarks();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast("exp:$e");
    }
  }

  void getCMOremarks() {
    if (Utils.checkBusinessSegment(BusinessSegment.financialInstitution)) {
      remark = security.remarksFi ?? "";
      cmoRemark = security.cmoRemarksFi ?? "";
    } else {
      remark = security.remarks ?? "";
      cmoRemark = security.cmoRemark ?? "";
    }
  }

  bool isCmoUpdate() {
    return Utils.checkRoles([
      UserRole.documentationChecker,
      UserRole.documentationMaker,
      UserRole.ccuChecker,
      UserRole.ccuMaker,
    ]);
  }

  Future<void> setExternalRatingBank(
    DynamicFormState formState,
    Security? selectedSecurity,
  ) async {
    final int? selectedSecurityId = selectedSecurity?.securityType?.id;
    if (selectedSecurityId == 79) {
      final value = dynamicFormDocument["ratingConductedBy"];
      final Option? selOption = sections[0]
          .rows?[1]
          .fields?[0]
          .optionList
          ?.firstWhere((e) => e.key == value);
      if (selOption != null) {
        final List<Option> options = await filterExternalRatings(selOption);
        formState.updateDropdownOptions("externalRatingBank", options);
      }
    }
  }

  Future<void> getLimitsandFacilities(int? rimNo) async {
    try {
      String? normalize(String? value) {
        if (value == null) return null;
        final String trimmed = value.trim();
        return trimmed.isEmpty ? null : trimmed;
      }

      bool startsWith100or400(String s) {
        return s.startsWith(
              "${ServerConstants.commitmentAccountNumberStartWith100}",
            ) ||
            s.startsWith(
              "${ServerConstants.commitmentAccountNumberStartWith400}",
            );
      }

      final List<LimitsResponse> limits = await FacilitySecurityRepository
          .instance
          .getLimitsandFacilities(rimNo);

      // Build commitmentAccountNumberItems (unique, filtered, trimmed)
      commitmentAccountNumbers = limits
          .map((LimitsResponse e) => normalize(e.commitmentAccountNumber))
          .whereType<String>() // remove nulls after normalization
          .where(startsWith100or400)
          .toSet() // dedupe (order not guaranteed)
          .toList();

      // Build controllingLimitNumbers (unique while preserving order)
      final Set<String> seen = <String>{};
      controllingLimitNumbers = limits
          .map((LimitsResponse e) => normalize(e.controllingLimitNo))
          .whereType<String>()
          .where(startsWith100or400)
          .where(
            seen.add,
          ) // unique by value, preserves first occurrence order
          .map((String s) => Reference(name: s))
          .toList();
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  Future<void> initDynamicForm(Security? selectedSecurity) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final DynamicFormState formState = dynamicFormKey.currentState!;

      if (dynamicFormDocument.containsKey("typeOfInsurance")) {
        if (dynamicFormDocument["typeOfInsurance"] == "creditInsurance") {
          formState
            ..setFieldVisibility("Pari-passu", false)
            ..setFieldVisibility(
              "approvedCounterpartyInTermsOfCreditInsurance",
              true,
            );
        }
        if (dynamicFormDocument["typeOfInsurance"] == "lifeInsurance") {
          formState.setFieldVisibility("KeymanInsuranceHolderName", true);
        }
      }
      if (dynamicFormDocument.containsKey("Pari-passu")) {
        isParipassu =
            dynamicFormDocument["Pari-passu"].toString().toLowerCase() == "yes"
                ? true
                : false;
      }
      await Future.wait([
        setExternalRatingBank(formState, selectedSecurity),
      ]);

      final valuatorCategory = dynamicFormDocument["ValuatorCategory"];
      if (valuatorCategory != null) {
        if (valuatorCategory == "Other Non-Panel") {
          formState
            ..setFieldVisibility("ValuatorName", true)
            ..setFieldVisibility("evaluatorName", false);
        } else {
          formState
            ..setFieldVisibility("evaluatorName", true)
            ..setFieldVisibility("ValuatorName", false);
        }
        // formState.setFieldVisibility('enterNonpanelValuatorName', false);
        final valuatorName = dynamicFormDocument["ValuatorName"];
        if (valuatorName == "1087") {
          //Others option is selected
          formState.setFieldVisibility("enterNonpanelValuatorName", true);
        } else {
          formState.setFieldVisibility("enterNonpanelValuatorName", false);
        }
      }
      final nameOfTheZone = dynamicFormDocument["nameOfTheZone"];
      if (nameOfTheZone != null) {
        if (nameOfTheZone == "15057") {
          formState.setFieldVisibility("enterOtherNameOfZone", true);
        } else {
          formState.setFieldVisibility("enterOtherNameOfZone", false);
        }
      }
      // setting property type
      final propertyType = dynamicFormDocument["propertyType"];

      if (propertyType != null) {
        final Map<String, List<Reference>> referenceData =
            await ReferenceDataService()
                .getReferenceData([ReferenceDataKeys.propertySubType]);
        final List<Reference>? propertySubtypes =
            referenceData[ReferenceDataKeys.propertySubType];
        final List<Reference>? filteredSubtypes =
            propertySubtypes?.where((Reference subType) {
          return subType.reference1 == propertyType.toString();
        }).toList();

        final List<Option> options = filteredSubtypes
                ?.map(
                  (subType) => Option(
                    key: subType.id.toString(),
                    pairValue: subType.name,
                    metaData: subType,
                  ),
                )
                .toList() ??
            [];

        formState.updateDropdownOptions("propertySubtype", options);
      }
      //
      formState
        ..setFieldEnabled("customerRimGrid", false)
        ..setFieldMandatory(
          "DiscountFactor%",
          security.securityType?.reference1 ==
              ServerConstants.tangibleSecurityReference,
        );

// Logics for update key - securityvalueadjustedtoLTV in initial time

      final double? parsedValue = double.tryParse(
        dynamicFormDocument["loanToValue"] ??
            dynamicFormDocument["ltv"]?.toString() ??
            "0",
      );
      loanToValue = parsedValue != null ? parsedValue / 100 : 0;
      logger.i("Initial Loan to Value from dynamic form: $loanToValue");
      // dynamicFormKey.currentState?.updateFieldValue(
      //     "securityvalueadjustedtoLTV",
      //     ((ltv ?? 1 / 100) *
      //             (dynamicFormKey.currentState
      //                     ?.getFieldValue("currentMarketValue") ??
      //                 security.proposedSecurityAmount ??
      //                 1))
      //         .round());

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    });
  }

  Future<void> getCurrencyRates(
    Reference? selectedCurrency,
    bool isPresentSecurityAmount, {
    double? proposedAmount,
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
      final double amount = isPresentSecurityAmount
          ? (security.presentSecurityAmount ?? 0)
          : (security.proposedSecurityAmount ?? 0);

      // Convert
      final double convertedValue = amount * exchangeRate;

      // Format values
      final formatter = NumberFormat("#,###");
      final String formattedAED = formatter.format(convertedValue.toInt());

      // Update the correct controller (present vs proposed)
      if (isPresentSecurityAmount) {
        newPresentSecurityAmountController.value = TextEditingValue(
          text: formattedAED,
          selection: TextSelection.collapsed(offset: formattedAED.length),
        );
        security.aedPresentSecurity = convertedValue;
      } else {
        newProposedSecurityAmountController.value = TextEditingValue(
          text: formattedAED,
          selection: TextSelection.collapsed(offset: formattedAED.length),
        );
        security.aedProposedSecurity = convertedValue;
      }

      final double adjustedVal = (proposedAmount ?? 1) * (loanToValue ?? 1);
      final Map securityvalueadjustedtoLTV = {
        "fromCurrency": selectedCode,
        "fromVal": adjustedVal.round(),
        "aedEquivalent": (adjustedVal * exchangeRate).round(),
      };
      dynamicFormKey.currentState?.updateFieldValue(
        "securityvalueadjustedtoLTV",
        securityvalueadjustedtoLTV,
      );
      logger.i(securityvalueadjustedtoLTV);
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onSelectCountryofSecurity(Country selectedCountry) {
    security.countryOfSecurity = selectedCountry.description;
    if (selectedCountry.code?.trim() != ServerConstants.uaeCountryCode) {
      isCountrySecurityUAE = false;
    } else {
      isCountrySecurityUAE = true;
    }
    emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
  }

  String securityProviderLabel({required bool isPresent}) {
    final List<int> chargeTypeIds = [74, 83, 87, 89, 93, 99];
    final bool isChargeType = chargeTypeIds.contains(security.securityType?.id);

    if (isPresent) {
      return isChargeType
          ? "security.createSecurity.presentChargeAmount".tr()
          : "security.createSecurity.presentSecurityAmount".tr();
    } else {
      return isChargeType
          ? "security.createSecurity.proposedChargeAmount".tr()
          : "security.createSecurity.proposedSecurityAmount".tr();
    }
  }

  String bankGuarantorFieldLabel() {
    final List<int> guaranteeTypeIds = [76, 85];
    final int? typeId = security.securityType?.id;

    return typeId == 79
        ? "security.createSecurity.bank".tr()
        : guaranteeTypeIds.contains(typeId)
            ? "security.createSecurity.guarantor".tr()
            : "security.createSecurity.securityProvider".tr();
  }

  // bool get isLimitControllingSecurity =>
  //     security.isLimitCtrlSecurity?.id == ServerConstants.optionNOid;

  bool get isFIFlow =>
      Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

  bool get isGuaranteeType =>
      security.securityType?.id == ServerConstants.bankGuaranteeId ||
          security.securityType?.id == ServerConstants.corporateGuaranteeId ||
          security.securityType?.id == ServerConstants.personalGuaranteeId ||
          security.securityType?.id == ServerConstants.financialGuranteeID;

  /// Fetches reference data for security types, statuses, and other options.
  /// Filters out "N/A" options and emits a loaded or error state.
  Future<void> getReferenceDatas() async {
    try {
      final String securityTypeKey = isFIFlow
          ? ReferenceDataKeys.fiSecurityType
          : ReferenceDataKeys.securityType;

      final Map<String, List<Reference>> referenceData =
          await ReferenceDataService().getReferenceData([
        securityTypeKey,
        ReferenceDataKeys.securityStatus,
        ReferenceDataKeys.securityHeldAs,
        ReferenceDataKeys.yesNoNa,
        ReferenceDataKeys.bankList,
        ReferenceDataKeys.securityBorrowerRole,
        ReferenceDataKeys.securityDeferredWaived,
        ReferenceDataKeys.securityLegalStatus,
        ReferenceDataKeys.ownerType,
        ReferenceDataKeys.emiratesItems,
        ReferenceDataKeys.economicZones,
      ]);
      securityReferenceData = referenceData[securityTypeKey] ?? [];
      securityLegalStatus =
          referenceData[ReferenceDataKeys.securityLegalStatus] ?? [];
      securityBorrowerRole =
          referenceData[ReferenceDataKeys.securityBorrowerRole] ?? [];
      securityProvidedCategories =
          referenceData[ReferenceDataKeys.ownerType] ?? [];
      securityDeferredWaivedItems =
          referenceData[ReferenceDataKeys.securityDeferredWaived] ?? [];
      emiratesItems = referenceData[ReferenceDataKeys.emiratesItems] ?? [];
      securityHeldAsList =
          referenceData[ReferenceDataKeys.securityHeldAs] ?? [];
      bankNames = referenceData[ReferenceDataKeys.bankList] ?? [];
      securityStatusList =
          referenceData[ReferenceDataKeys.securityStatus] ?? [];
      yesAndNo = (referenceData[ReferenceDataKeys.yesNoNa] ?? [])
          .where((data) => data.id != ServerConstants.optionNAid)
          .toList()
        ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
      economicZones = referenceData[ReferenceDataKeys.economicZones] ?? [];
      //filter out security types where reference5 is "HIDE"
      securityReferenceData = securityReferenceData
          .where((data) => data.reference5 != ServerConstants.hide)
          .toList();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Handles selection of a security description, triggers loading of currency
  /// codes
  /// and dynamic form, and emits appropriate states.
  Future<void> securityTypeSelected(Reference? selectedValue) async {
    security.securityType = selectedValue;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateSecurityProviderAddress(String value) {
    security.securityProviderAddress = value;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> loadDynamicForm() async {
    try {
      /// set separete loader for drop downs
      emit(state.copyWith(securityTypeStatus: LoadingStatus.loading));
      await Future.wait([
        getCurrencyCodes(),
        if (countries.isEmpty) getCountries(),
        getDynamicForm(),
      ]);

      if (!isUpdateFlow) {
        await getApprovedSecurity(
          Security()
            ..securityType = security.securityType
            ..securityGroup = security.securityGroup
            ..securityProvidedRim = security.securityProvidedRim
            ..securityNumber = security.securityNumber
            ..securityMasterId = security.securityMasterId
            ..facilitySecurityMasterLinkId =
                security.facilitySecurityMasterLinkId,
        );
      }
      loadDatasForDynamicForm();

      if (canEdit && !isUpdateFlow) {
        await loadDraftIfAvailable();
        // Re-run dynamic form visibility logic using the restored
        // dynamicFormDocument.
        // Must be called after the draft is applied and before the final emit
        // so the form renders with the correct field visibility on first build.
        await initDynamicForm(null);
      }
      //TODO move all this logics into separete function in code cleaning
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
  }

  void loadDatasForDynamicForm() {
    Globals.dynamicFormCurrencyCodes = currencyCodes
        .map((ref) => Option(key: ref.id.toString(), pairValue: ref.name ?? ""))
        .toList();
    Globals.dynamicFormEconomicZones = economicZones
        .map((ref) => Option(key: ref.id.toString(), pairValue: ref.name))
        .toList();
  }

  /// Fetches the dynamic form sections for security creation.
  Future<void> getDynamicForm() async {
    try {
      sections = await securityRepository.getSecurityDynamicForm(
        typeID: ServerConstants.dynamicFormSecurityID,
        subTypeID: security.securityType?.id,
      );
      // Note: do NOT emit securityTypeStatus here.
      // loadDynamicForm() emits it at the very end, after the draft is applied,
      // ensuring the form only renders once model data is fully populated.
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  void changeSecurityProviderCategory(Reference? selectedCategory) {
    if (selectedCategory == null) {
      security.securityProviderCategory = null;
      security.securityProvidedCountry = null;
      security.securityProviderLegalStatus = null;
      security.securityProviderEmiratesId = null;
      isEntityProvider = false;
      isNaturalPersonProvider = false;
      securityProviderTlNumberController.clear();
      securityProviderEmiratesIDController.clear();
      emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
      return;
    }
    // Update the category name
    security.securityProviderCategory = selectedCategory.name;

    // Compare using constant ID instead of string

    isEntityProvider =
        selectedCategory.id == ServerConstants.securityProviderCategoryEntityId;
    isNaturalPersonProvider = selectedCategory.id ==
        ServerConstants.securityProviderCategoryNaturalPersonId;

    if (isEntityProvider) {
      security.securityProviderLegalStatus = Reference();
      isNaturalPersonProvider = false;
      security.securityProviderEmiratesId = null;
      securityProviderEmiratesIDController.clear();
    }

    if (isNaturalPersonProvider) {
      isEntityProvider = false;
      securityProviderTlNumberController.clear();
    }

    emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
  }

  // bool get isSecurityExpiryOpenEndedSelected {
  //   return security?.isSecurityExpiryOpenEnded?.id ==
  //       ServerConstants.optionYESid; // Replace with actual ID for "Yes"
  // }

  Future<void> onSaveButtonPress(
    bool saveAndContinue, {
    String? securityCode,
  }) async {
    try {
      final bool isDynamicFormValid = dynamicFormKey.currentState?.validate() ??
          true; //If there is no dynamic form, allow to save
      final bool isOtherFormValid = formKey.currentState!.validate();

      if (!isDynamicFormValid || !isOtherFormValid) {
        throw "security.createSecurity.requiredField".tr();
      }

      // Persist form fields
      formKey.currentState?.save();
      dynamicFormKey.currentState?.save();

      // Map form data back to model
      security.dynamicFormDocument = dynamicFormDocument;

      // Save RTE content for FI flow (controllers will be non-null only in FI
      // flow)
      if (isFIFlow) {
        security.remarks = await remarksController?.getText();
        security.cmoRemark = await cmoRemarksController?.getText();
      }

      // Clean numeric fields (remove commas/spaces) then parse
      security.presentSecurityAmount = double.tryParse(
        presentSecurityAmountController.text.replaceAll(RegExp(r"[,\s]"), ""),
      );
      security.proposedSecurityAmount = double.tryParse(
        proposedSecurityAmountController.text.replaceAll(RegExp(r"[,\s]"), ""),
      );

      // Sync from controller → model if controller already has a number
      final controllerNumber = securityNumberController.text.trim();
      if (controllerNumber.isNotEmpty) {
        security.securityNumber = controllerNumber;
      }

      security.isTangibleSecurity ??= (security.securityType?.reference1 ==
          ServerConstants.tangibleSecurityReference);
      security.isCashCollateral ??= (security.securityType?.reference2 ==
          ServerConstants.cashCollateralReference);

      Security? savedSecurity;

      if (saveAndContinue) {
        // Ensure we have a security number in the payload.
        final hasNumber =
            (security.securityNumber?.trim().isNotEmpty ?? false) ||
                controllerNumber.isNotEmpty;

        if (!hasNumber) {
          // First save to generate a number
          savedSecurity = await securityRepository.saveSecurityDetails(
            security,
            sections,
            securityCode,
          );

          final generatedNumber = savedSecurity?.securityNumber ?? "";
          securityNumberController.text = generatedNumber;
          if (generatedNumber.isNotEmpty) {
            security.securityNumber = generatedNumber;
          }
        }

        // At this point, model/controller should have the number.
        // Do a save that includes the number in the request.
        savedSecurity = await securityRepository.saveSecurityDetails(
          security,
          sections,
          securityCode,
        );

        // Keep controller and model in sync with any updated number from
        // backend
        final finalNumber = savedSecurity?.securityNumber ?? "";
        securityNumberController.text = finalNumber;
        if (finalNumber.isNotEmpty) {
          security.securityNumber = finalNumber;
        }

        emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
        AlertManager()
            .showSuccessToast("security.createSecurity.saveSuccess".tr());

        unawaited(
          deleteDraft(),
        ); // Fire-and-forget: removes temp draft from backend
        LayoutViewModel()
            .goToNextRoute(); // Navigate to next route based on user rights
      } else {
        // Simple Save (single call)
        savedSecurity = await securityRepository.saveSecurityDetails(
          security,
          sections,
          securityCode,
        );

        final newNumber = savedSecurity?.securityNumber ?? "";
        securityNumberController.text = newNumber;
        if (newNumber.isNotEmpty) {
          security.securityNumber = newNumber;
        }

        emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
        AlertManager()
            .showSuccessToast("security.createSecurity.saveSuccess".tr());
        unawaited(
          deleteDraft(),
        ); // Fire-and-forget: removes temp draft from backend
        // No navigation on simple Save
      }
    } catch (e) {
      logger.e("Error in onSaveButtonPress: $e");
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Cancels the current operation
  void onCancelButtonPress() {
    router.go(Routes.home);
  }

  void changeCashCollateralValue(Reference? value) {
    security.selectedCashCollateralValue = value;
    emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
  }

  void changeLimitControllingSecurityValue(Reference? value) {
    if (value == yesAndNo?.first) {
      security.isLimitCtrlSecurity = true;
    } else {
      security.isLimitCtrlSecurity = false;
    }
    emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
  }

  /// Updates the selected CBD customer value and toggles the internal flag.
  void changeSecurityProviderCbdCustomerValue(Reference? value) {
    security.selectedIsSecurityProviderCbdCustomerValue = value;
    securityProviderCbdCustomer = value?.id == ServerConstants.optionYESid;
    if (!securityProviderCbdCustomer) {
      dynamicFormKey.currentState
        ?..setFieldEnabled("leagalStrOfGuarantor", true)
        ..setFieldEnabled("gurantorsIDDocument", true)
        ..setFieldEnabled("gurantorsIdNumber", true)
        ..setFieldEnabled("uaeAddress", true);
      securityProviderRimNumberController
        ..clear()
        ..text = "";
      security.securityProvidedRim = null;
    } else {
      dynamicFormKey.currentState
        ?..setFieldEnabled("leagalStrOfGuarantor", false)
        ..setFieldEnabled("gurantorsIDDocument", false)
        ..setFieldEnabled("gurantorsIdNumber", false)
        ..setFieldEnabled("uaeAddress", false);
    }
    security.securityProvidedCountry = null;
    preselectedCountry = null;
    security.securityProvidedName = null;
    securityProviderNameController.clear();

    emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
  }

  /// Updates the selected open-ended expiry value and emits a loaded state.
  void changeSecurityExpiryOpenEndedValue(Reference? value) {
    if (value == yesAndNo?.first) {
      security.isSecurityExpiryOpenEnded = true;
    } else {
      security.isSecurityExpiryOpenEnded = false;
    }

    emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
  }

  void securityGroupSelected(Reference selectedGroup) {
    securityTypes = [];
    security.securityType = null; // Reset selected type
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    security.securityGroup = selectedGroup;

    if (selectedGroup.id == ServerConstants.fiOtherSecurityGroupId) {
      // Create a copy of the security group reference for security type
      security.securityType = Reference(
        id: selectedGroup.id,
        name: "", // Will be filled by user input
        description: selectedGroup.description,
        reference1: selectedGroup.reference1,
        reference2: selectedGroup.reference2,
        reference3: selectedGroup.reference3,
        reference4: selectedGroup.reference4,
        reference5: selectedGroup.reference5,
        isActive: selectedGroup.isActive == true,
      );
    } else {
      for (final Reference ref in securityReferenceData) {
        if (selectedGroup.reference4 == ref.reference4) {
          securityTypes.add(ref);
        }
      }
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onSecurityTypeTextChanged(String value) {
    if (security.securityType != null) {
      security.securityType!.name = value;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> getCurrencyCodes() async {
    try {
      currencyCodes = await repository.getCurrencyCodes();

      // Sort to make AED come first (stable, case-insensitive)
      currencyCodes.sort((a, b) {
        final aIsAed =
            (a.name ?? "").toUpperCase() == ServerConstants.aedCurrency;
        final bIsAed =
            (b.name ?? "").toUpperCase() == ServerConstants.aedCurrency;
        return (bIsAed ? 1 : 0) - (aIsAed ? 1 : 0);
      });

      // Resolve AED reference (fallback to first if list empty)
      final Reference aed = currencyCodes.firstWhere(
        (r) => (r.name ?? "").toUpperCase() == ServerConstants.aedCurrency,
        orElse: () => currencyCodes.isNotEmpty
            ? currencyCodes.first
            : Reference(name: ServerConstants.aedCurrency),
      );

      // Ensure a default for proposed currency (keeps your existing behavior)
      security.proposedSecurityAmtCurrency ??= aed;

      // (Optional) Ensure a default for present currency as well.
      // If you already set present elsewhere, you can skip this line:
      security.presentSecurityAmtCurrency ??= aed;

      // Compute currency codes per field
      final String proposedCode =
          (security.proposedSecurityAmtCurrency?.name ?? "").toUpperCase();
      final String presentCode =
          (security.presentSecurityAmtCurrency?.name ?? "").toUpperCase();

      // If you still need a single "currently selected" code, keep it for
      // proposed
      selectedCurrencyCode = proposedCode;

      // Independent flags per field
      final bool isProposedAed = proposedCode == ServerConstants.aedCurrency;
      final bool isPresentAed = presentCode == ServerConstants.aedCurrency;

      // UI flags (independent)
      showProposedSecurityAmount = !isProposedAed;
      showPresentSecurityAmount = !isPresentAed;

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  void onCurrencyChanged(Reference? ref, bool isPresentSecurityAmount) {
    // Update the correct currency field
    if (isPresentSecurityAmount) {
      security.presentSecurityAmtCurrency = ref;
    } else {
      security.proposedSecurityAmtCurrency = ref;
    }

    // If you still need a "currently selected" code, scope it per-field
    final selectedCode = (ref?.name ?? "").toUpperCase();

    final bool isAed = selectedCode == ServerConstants.aedCurrency;

    // Toggle the right flag per field
    if (isPresentSecurityAmount) {
      showPresentSecurityAmount = !isAed;
    } else {
      showProposedSecurityAmount = !isAed;
    }

    // If disableFxRates was intended to be global, keep it.
    // If it causes cross-field issues, consider splitting into two flags:
    // disablePresentFxRates / disableProposedFxRates
    disableFxRates = !isAed;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Retrieves a list of countries from the server and stores them in the
  /// [countries] property. If the retrieval fails, the loader status is set to
  /// [LoadingStatus.error].
  Future<void> getCountries() async {
    try {
      countries = (await customerRepository.getCountries() ?? [])
        ..sort((a, b) => (a.description ?? "").compareTo(b.description ?? ""));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
      logger.i("Error fetching getCountries : $e");
    }
  }

  /// Searches for customer information using the provided RIM number.
  /// Emits a loaded state after retrieval.

  Future<void> searchByRim(String rim) async {
    try {
      security.securityProvidedRim = rim;
      customerDetails = await customerRepository.searchUserDetailsPartyInqOnly(
        rim,
        "",
        "",
        "",
      );

      // No id to compare
      if (security.securityType?.id == ServerConstants.corporateGuaranteeId &&
          customerDetails?.partyIdType == ServerConstants.personal) {
        AlertManager().showFailureToast("riskRating.invalidCorporateRim".tr());
        return;
      }
      // No id to compare

      // if (security.securityType?.id == ServerConstants.personalGuaranteeId &&
      //     customerDetails?.partyIdType != ServerConstants.personal) {

      //   return;
      // }

      if (customerDetails?.id == null) {
        didPrefillCountryFromRim = false;
        AlertManager().showFailureToast("riskRating.invalidRim".tr());
      } else {
        security.securityProvidedName = "${customerDetails?.firstName} "
            "${customerDetails?.middleName} ${customerDetails?.lastName}";
        countryOfIncorporation = customerDetails?.tLIssueCountry;

        //  Trigger dependent logic via the same pipeline

        if (countryOfIncorporation != null &&
            countryOfIncorporation!.trim().isNotEmpty) {
          final Country matchedCountry = countries.firstWhere(
            (country) =>
                (country.description ?? "")
                    .replaceAll(RegExp(r"\s+"), "")
                    .toLowerCase() ==
                countryOfIncorporation!
                    .replaceAll(RegExp(r"\s+"), "")
                    .toLowerCase(),
            orElse: Country.new,
          );

          if (matchedCountry.description != null) {
            security.securityProvidedCountry = matchedCountry;
            preselectedCountry = matchedCountry;
            didPrefillCountryFromRim = true;

            emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
          } else {
            didPrefillCountryFromRim = false;
          }
        } else {
          didPrefillCountryFromRim = false;
        }

        // Trigger UI update
        emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
        security.securityProvidedName = "${customerDetails?.firstName} "
            "${customerDetails?.middleName} ${customerDetails?.lastName}";
        securityProviderNameController.text =
            security.securityProvidedName ?? "";
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));

    final DynamicFormState? form = dynamicFormKey.currentState;
    if (form == null || customerDetails == null) return;
    print("customer Details:- ${customerDetails?.addressLine1}");
    final expiryDt = customerDetails?.customerTlExpiryDate;
    form
      ..updateFieldValue(
        "securityProvidedName",
        "${customerDetails?.firstName} "
            "${customerDetails?.middleName} ${customerDetails?.lastName}",
      )
      ..updateFieldValue(
        "gteeExpiryDate",
        expiryDt != null
            ? convertDateTimeToFormValue(DateTime.parse(expiryDt))
            : null,
      )
      ..updateFieldValue(
        "uaeAddress",
        '${customerDetails?.customerAddress1 ?? ''}\n'
            '${customerDetails?.customerAddress2 ?? ''}\n'
            '${customerDetails?.customerAddress3 ?? ''}\n'
            '${customerDetails?.city ?? ''}\n'
            '${customerDetails?.country ?? ''}',
      )
      ..updateFieldValue(
        "nationalityOfGuarantor",
        customerDetails?.tLIssueCountry ?? "",
      );
    final Reference? document = customerDetails?.issuedIdent?.firstWhere(
      (doc) => ServerConstants.guarantorDocumentTypes.contains(doc.name),
      orElse: Reference.new,
    );
    if (document?.name != null) {
      form
        ..updateFieldValue(
          "gurantorsIdNumber",
          document?.description ?? "",
        )
        ..setDropdownDefaultSelection(
          "gurantorsIDDocument",
          Option(
            key: document?.name,
            pairValue: document?.name,
          ),
        );
    }
  }

  DateTime? parseDate(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    if (value is String) {
      return DateTime.tryParse(value);
    }

    if (value is Map) {
      final jsDate = value["jsdate"];
      if (jsDate is String) {
        return DateTime.tryParse(jsDate);
      }
    }

    return null;
  }

  String calculateLeaseTerm(DateTime start, DateTime end) {
    if (end.isBefore(start)) return "";

    int years = end.year - start.year;
    int months = end.month - start.month;
    int days = end.day - start.day;

    if (days < 0) {
      months -= 1;
      final prevMonth = DateTime(end.year, end.month, 0);
      days += prevMonth.day;
    }

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    final parts = <String>[];
    if (years > 0) parts.add('$years Year${years > 1 ? 's' : ''}');
    if (months > 0) parts.add('$months Month${months > 1 ? 's' : ''}');
    if (days > 0) parts.add('$days Day${days > 1 ? 's' : ''}');

    return parts.join(" ");
  }

  /// Searches for customer details by RIM number in grid with debouncing
  ///
  /// This method is debounced to prevent excessive API calls while the user is
  /// typing.
  /// It waits 500ms after the last keystroke before making the API call.
  ///
  /// Parameters:
  /// - [rimValue]: The RIM number to search for
  /// - [rowIndex]: The grid row index where the search was triggered
  Future<void> searchCustomerByRimInGrid(String rimValue, int rowIndex) async {
    if (rimValue.isEmpty) return;

    try {
      // Call searchUserDetailsForCL to get customer details
      final Customer? customer =
          await customerRepository.searchUserDetailsForCL(
        rimValue,
        null,
        null,
        null,
      );

      if (customer != null) {
        // Populate the name field in the same row
        final nameKey = "approvedCounterpartyInTermsOfCreditInsurance"
            ".nameInApprovedCounterparty@$rowIndex";
        final customerName =
            customer.preferredName ?? customer.customerName ?? "";

        dynamicFormKey.currentState?.updateFieldValue(
          nameKey,
          customerName,
        );

        // Update the document as well
        dynamicFormDocument[nameKey] = customerName;
      } else {
        AlertManager()
            .showFailureToast("Customer not found for RIM: $rimValue");
      }
    } catch (e) {
      AlertManager()
          .showFailureToast("Error fetching customer details: ${e.toString()}");
    }
  }

  Future<void> onDynamicFormFieldChange(String fieldKey, dynamic value) async {
    final form = dynamicFormKey.currentState;

    switch (fieldKey) {
      case "searchByName":
        // Extract grid name to use grid-qualified keys
        final String? gridName = value["gridName"];
        final int rowIndex = value["index"];
        final bool isChecked = value["value"] == true;

        if (gridName != null) {
          // Use grid-qualified field keys to ensure changes only affect
          // the specific grid where the checkbox was toggled
          final String rimKey = "$gridName.customerRimGrid";
          final String nameKey = "$gridName.nameInApprovedCounterparty";

          if (isChecked) {
            // Enable RIM field, disable name field
            dynamicFormKey.currentState
                ?.setFieldEnabled(rimKey, true, index: rowIndex);
            dynamicFormKey.currentState
                ?.setFieldEnabled(nameKey, false, index: rowIndex);
            // Clear the name field when switching to RIM search
            dynamicFormKey.currentState?.updateFieldValue(
              nameKey,
              {"index": rowIndex, "value": ""},
            );
          } else {
            // Disable RIM field, enable name field
            dynamicFormKey.currentState
                ?.setFieldEnabled(rimKey, false, index: rowIndex);
            dynamicFormKey.currentState
                ?.setFieldEnabled(nameKey, true, index: rowIndex);
            // Clear the RIM field when switching to name entry
            dynamicFormKey.currentState?.updateFieldValue(
              rimKey,
              {"index": rowIndex, "value": ""},
            );
          }
        }
      case "customerRimGrid":
        // Extract RIM number and row index from the value
        final rimValue = value["value"]?.toString() ?? "";
        final rowIndex = value["index"];
        final debounceKey = "customerRimGrid@$rowIndex";

        // Cancel any existing timer for this field
        _customerSearchDebounceTimers[debounceKey]?.cancel();

        if (rimValue.isNotEmpty) {
          // Create a new debounced timer (500ms delay)
          _customerSearchDebounceTimers[debounceKey] = Timer(
            const Duration(milliseconds: 500),
            () => searchCustomerByRimInGrid(rimValue, rowIndex),
          );
        }

      case "nameOfTheZone":
        final Reference selectedRefernce = value.metaData;
        if (selectedRefernce.id == 15057) {
          //Others option is selected
          dynamicFormKey.currentState
              ?.setFieldVisibility("enterOtherNameOfZone", true);
        } else {
          dynamicFormKey.currentState
              ?.setFieldVisibility("enterOtherNameOfZone", false);
        }

      case "guarantorEntityId":
        final List<String?> lst = value.toString().split("@");
        if (lst.length > 2) {
          dynamicFormKey.currentState
              ?.updateFieldValue("guarantorEntityId", lst[0] ?? "");
          dynamicFormKey.currentState
              ?.updateFieldValue("internalModelRating", lst[1] ?? "");
          dynamicFormKey.currentState
              ?.updateFieldValue("internalModelRatingProposed", lst[2] ?? "");
        }

      case ("loanToValue" || "ltv"):
        final double parsedValue = double.tryParse(value ?? "0") ?? 0;
        loanToValue = (parsedValue == 0 ? 1 : parsedValue / 100);
        final double securityvalueadjustedtoLTV = (loanToValue ?? 1) *
            (currentMarketValue ?? security.proposedSecurityAmount ?? 1);
        dynamicFormKey.currentState
            ?.updateFieldValue("securityvalueadjustedtoLTV", {
          "fromCurrency": null,
          "fromVal": securityvalueadjustedtoLTV.round(),
          "aedEquivalent": null,
        });

      case "currentMarketValue":
        currentMarketValue = value["fromVal"] ?? 1;
        final double securityvalueadjustedtoLTV2 = (loanToValue ?? 1) *
            (currentMarketValue ?? security.proposedSecurityAmount ?? 1);
        dynamicFormKey.currentState
            ?.updateFieldValue("securityvalueadjustedtoLTV", {
          "fromCurrency": security.presentSecurityAmtCurrency?.name,
          "fromVal": securityvalueadjustedtoLTV2.round(),
          "aedEquivalent": (securityvalueadjustedtoLTV2 * exchangeRate).round(),
        });

      case "policyNumber":
        // final adjustedValue = value?.toString() ?? '';
        // dynamicFormKey.currentState?.updateFieldValue(
        //   'policyNumber2',
        //   adjustedValue.trim(),
        // );
        break;

      case "Pari-passu":
        final paripasuvalue = value?.toString().trim().toLowerCase();
        isParipassu = (paripasuvalue == "yes");
        dynamicFormKey.currentState
            ?.setFieldMandatory("mortgagedAmount", !isParipassu);

      case "typeOfInsurance":
        if (value.key == "creditInsurance") {
          dynamicFormKey.currentState?.setFieldVisibility(
            "approvedCounterpartyInTermsOfCreditInsurance",
            true,
          );
          dynamicFormKey.currentState?.setFieldVisibility("Pari-passu", false);
        } else {
          dynamicFormKey.currentState?.setFieldVisibility(
            "approvedCounterpartyInTermsOfCreditInsurance",
            false,
          );
        }
        if (value.key == "lifeInsurance") {
          dynamicFormKey.currentState
              ?.setFieldVisibility("KeymanInsuranceHolderName", true);
          dynamicFormKey.currentState?.setFieldVisibility("Pari-passu", true);
        } else {
          dynamicFormKey.currentState
              ?.setFieldVisibility("KeymanInsuranceHolderName", false);
        }
        if (value.key == "assetInsurance") {
          dynamicFormKey.currentState?.setFieldVisibility("Pari-passu", true);
        }

      case "typeOfExposure":
        final selected = value?.key ?? value;

        if (selected == "proposedPercentage") {
          dynamicFormKey.currentState
              ?.setFieldVisibility("proposedPercentagePercent", true);
          dynamicFormKey.currentState
              ?.setFieldVisibility("amountOfExposure", false);
        } else if (selected == "amountOfExposureCovered") {
          dynamicFormKey.currentState
              ?.setFieldVisibility("proposedPercentagePercent", false);
          dynamicFormKey.currentState
              ?.setFieldVisibility("amountOfExposure", true);
        }

      case "musatahaCommenceDate":
      case "Lease/MusatahaEndDate":
        final startRaw = form!.getFieldValue("musatahaCommenceDate");
        final endRaw = form.getFieldValue("Lease/MusatahaEndDate");

        final startDate = parseDate(startRaw);
        final endDate = parseDate(endRaw);

        if (startDate != null && endDate != null) {
          final leaseTerm = calculateLeaseTerm(startDate, endDate);

          form.updateFieldValue(
            "LeaseTerm",
            leaseTerm,
          );
        } else {
          // Clear if one date missing
          form.updateFieldValue("LeaseTerm", "");
        }

      case "propertyType":
        final Map<String, List<Reference>> referenceData =
            await ReferenceDataService()
                .getReferenceData([ReferenceDataKeys.propertySubType]);
        final List<Reference>? propertySubtypes =
            referenceData[ReferenceDataKeys.propertySubType];
        final List<Reference>? filteredSubtypes =
            propertySubtypes?.where((Reference subType) {
          return subType.reference1 == value.metaData.id.toString();
        }).toList();

        final List<Option> options = filteredSubtypes
                ?.map(
                  (subType) => Option(
                    key: subType.id.toString(),
                    pairValue: subType.name,
                    metaData: subType,
                  ),
                )
                .toList() ??
            [];

        dynamicFormKey.currentState?.updateDropdownOptions(
          "propertySubtype",
          options,
          clearSelection: true,
        );

      case "gurantorsIDDocument":
        dynamicFormKey.currentState
            ?.setFieldVisibility("gurantorsIdNumber", true);

      case "gurantorsIdNumber":
        if (customerDetails?.customerGroupId != null) {
          final adjustedValue = customerDetails?.customerGroupId.toString();
          dynamicFormKey.currentState?.updateFieldValue(
            "gurantorsIdNumber",
            adjustedValue,
          );
        }

      case "uaeAddress":
        final adjustedValue = "${customerDetails?.customerAddress1}  "
            "${customerDetails?.customerAddress2}";
        dynamicFormKey.currentState?.updateFieldValue(
          "uaeAddress",
          adjustedValue,
        );
        dynamicFormKey.currentState?.setFieldVisibility("uaeAddress", true);

      case "localCountryAddress":
        final adjustedValue = "${customerDetails?.customerAddress1}  "
            "${customerDetails?.customerAddress2}";
        dynamicFormKey.currentState?.updateFieldValue(
          "localCountryAddress",
          adjustedValue,
        );

      case "nationalityOfGuarantor":
        final String? nation = value?.toString();

        final bool isUAE = nation == "AE" ||
            nation == "ARE" ||
            nation == "UNITED ARAB EMIRATES";

        dynamicFormKey.currentState?.updateFieldValue("resident", isUAE);

      case "ratingConductedBy":
        final List<Option> options = await filterExternalRatings(value);

        dynamicFormKey.currentState?.updateDropdownOptions(
          "externalRatingBank",
          options,
          clearSelection: true,
        );

      case "ratingAgencyCorporateGurantee":
        final List<Option> options = await filterExternalRatings(value);

        dynamicFormKey.currentState?.updateDropdownOptions(
          "externalRatingCorporate",
          options,
          clearSelection: true,
        );

      case "ValuatorCategory":
        if (value == "Other Non-Panel") {
          dynamicFormKey.currentState?.setFieldVisibility("ValuatorName", true);
          dynamicFormKey.currentState
              ?.setFieldVisibility("evaluatorName", false);
        } else {
          dynamicFormKey.currentState
              ?.setFieldVisibility("evaluatorName", true);
          dynamicFormKey.currentState
              ?.setFieldVisibility("ValuatorName", false);
        }
        dynamicFormKey.currentState
            ?.setFieldVisibility("enterNonpanelValuatorName", false);
        dynamicFormKey.currentState?.clearDropdownSelection("ValuatorName");

      case "ValuatorName":
        final Reference selectedRefernce = value.metaData;
        if (selectedRefernce.id == 1087) {
          //Others option is selected
          dynamicFormKey.currentState
              ?.setFieldVisibility("enterNonpanelValuatorName", true);
        } else {
          dynamicFormKey.currentState
              ?.setFieldVisibility("enterNonpanelValuatorName", false);
        }

      case "noOfUnits":
      case "mvPerUnit":
        {
          final form = dynamicFormKey.currentState;

          final int? rowIndex = (value is Map) ? value["index"] as int? : null;

          final String unitsKey = "noOfUnits@$rowIndex";
          final String priceKey = "mvPerUnit@$rowIndex";
          final String totalKey = "totalMv@$rowIndex";

          final dynamic unitsRaw = form?.getFieldValue(unitsKey);
          final dynamic priceRaw = form?.getFieldValue(priceKey);

          double parseNum(dynamic value) {
            if (value == null) return 0;
            if (value is num) return value.toDouble();
            if (value is String) {
              final cleaned = value.replaceAll(",", "").trim();
              return double.tryParse(cleaned) ?? 0.0;
            }
            return 0; // default fallback to avoid NaN
          }

          final double units = parseNum(unitsRaw);
          final double price = parseNum(priceRaw);
          final double total = units * price;

          form?.updateFieldValue(totalKey, total.toStringAsFixed(2));

          emit(state.copyWith());
          break;
        }

      default:
        // No specific handling for this field
        break;
    }

    emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
  }

  Future<List<Option>> filterExternalRatings(Option selectedAgency) async {
    final Map<String, List<Reference>> referenceData =
        await ReferenceDataService()
            .getReferenceData([ReferenceDataKeys.externalRatingAgencyValues]);
    //convert this list to list of options
    final List<Reference>? agencyValues =
        referenceData[ReferenceDataKeys.externalRatingAgencyValues];
    final List<Reference>? filteredValues =
        agencyValues?.where((Reference subType) {
      return subType.reference1 == selectedAgency.metaData.id.toString();
    }).toList();

    final List<Option> options = filteredValues
            ?.map(
              (subType) => Option(
                key: subType.id.toString(),
                pairValue: subType.name,
                metaData: subType,
              ),
            )
            .toList() ??
        [];
    return options;
  }

  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }
}
