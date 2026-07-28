import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/foundation.dart";
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
import "package:wcas_frontend/core/utils/rate_debouncer.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/screen_access_conditions.dart";
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

/// A view model responsible for managing security creation, editing,
/// validation, and persistence.
///
/// Handles:
/// - Security form state management
/// - Reference data retrieval
/// - User interactions and field updates
/// - Dynamic UI behavior and validation
/// - Security save and update operations
/// - Draft management and restoration
class CreateSecurityViewModel extends SafeCubit<CreateSecurityState>
    with DraftMixin<CreateSecurityViewModel> {
  /// Creates a security view model with the initial loading state.
  CreateSecurityViewModel()
      : super(
          CreateSecurityState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

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

  /// Key used to manage and access the dynamic form state.
  GlobalKey<DynamicFormState> dynamicFormKey = GlobalKey<DynamicFormState>();

  /// Request associated with the current security operation.
  Request request = Request();

  /// Security model being created or edited.
  Security security = Security(
    selectedIsSecurityProviderCbdCustomerValue: Reference(
      id: ServerConstants.optionYESid,
    ),
  );

  /// Customer details associated with the security.
  Customer? customerDetails = Customer();

  /// Indicates whether the country of security is the UAE.
  bool isCountrySecurityUAE = false;

  /// Indicates whether the current security has been approved.
  bool isApproved = false;

  /// Repository for handling facility security-related operations.
  FacilitySecurityRepository securityRepository =
      FacilitySecurityRepository.instance;

  /// Repository for retrieving customer-related information.
  CustomerRepository customerRepository = CustomerRepository();

  /// Global key for the main form used in the security creation screen.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Available Yes/No options used throughout the screen.
  List<Reference>? yesAndNo = [];

  /// Available security reference data.
  List<Reference> securityReferenceData = [];

  /// Available borrower role options.
  List<Reference> securityBorrowerRole = [];

  /// Indicates whether the security provider is a CBD customer.
  bool securityProviderCbdCustomer = true;

  /// Available deferred or waived-by options.
  List<Reference> securityDeferredWaivedItems = [];

  /// Available emirate options.
  List<Reference> emiratesItems = [];

  /// Available economic zone options.
  List<Reference> economicZones = [];

  /// Available legal status options for security providers.
  List<Reference> securityLegalStatus = [];

  /// Available controlling limit number options.
  List<Reference> controllingLimitNumbers = [];

  /// Available security type options.
  List<Reference?> securityTypes = [];

  /// Available bank name options.
  List<Reference?> bankNames = [];

  /// Available currency code options.
  List<Reference> currencyCodes = [];

  /// Available security held-as options.
  List<Reference> securityHeldAsList = [];

  /// Available security provider category options.
  List<Reference> securityProvidedCategories = [];

  /// Available security status options.
  List<Reference> securityStatusList = [];

  /// Dynamic form sections used to render security-specific fields.
  List<Section> sections = [];

  /// Exchange rate used for currency conversion calculations.
  num exchangeRate = 0;

  /// Rate debouncers, keyed by which security amount they serve
  /// (`true` = present, `false` = proposed). Created on first use.
  final Map<bool, RateDebouncer> _rateDebouncers = <bool, RateDebouncer>{};

  RateDebouncer _rateDebouncerFor({required bool isPresentSecurityAmount}) =>
      _rateDebouncers.putIfAbsent(isPresentSecurityAmount, RateDebouncer.new);

  /// Whether a rate fetch for the present or proposed security amount is
  /// pending or in flight.
  ///
  /// Passed to `ConvertedAmountField.isLoadingListenable` so the AED field can
  /// show a spinner.
  ValueListenable<bool> rateLoadingFor({
    required bool isPresentSecurityAmount,
  }) =>
      _rateDebouncerFor(isPresentSecurityAmount: isPresentSecurityAmount)
          .isLoading;

  /// Loan-to-value ratio associated with the security.
  double? loanToValue;

  /// Current market value of the security.
  double? currentMarketValue;

  /// Available country options.
  List<Country> countries = [];

  /// Dynamic form data captured for the selected security type.
  Map<String, dynamic> dynamicFormDocument = {};

  /// Available commitment account numbers.
  List<String> commitmentAccountNumbers = [];

  /// Selected currency code.
  ///
  /// Example: `AED`.
  String? selectedCurrencyCode;

  /// Indicates whether the converted proposed security amount field is shown.
  bool showProposedSecurityAmount = false;

  /// Indicates whether the converted present security amount field is shown.
  bool showPresentSecurityAmount = false;

  /// Indicates whether foreign exchange rate fields are disabled.
  bool disableFxRates = false;

  /// Indicates whether the security provider is an entity.
  bool isEntityProvider = false;

  /// Indicates whether the security provider is a natural person.
  bool isNaturalPersonProvider = false;

  /// Indicates whether the security is pari passu.
  bool isParipassu = true;

  /// Indicates whether the country was prefilled from the selected RIM.
  bool didPrefillCountryFromRim = false;

  /// Controller for the proposed security amount field.
  TextEditingController proposedSecurityAmountController =
      TextEditingController();

  /// Controller for the converted proposed security amount field.
  TextEditingController newProposedSecurityAmountController =
      TextEditingController();

  /// Controller for the present security amount field.
  TextEditingController presentSecurityAmountController =
      TextEditingController();

  /// Controller for the converted present security amount field.
  TextEditingController newPresentSecurityAmountController =
      TextEditingController();

  /// Controller for the security provider RIM number field.
  TextEditingController securityProviderRimNumberController =
      TextEditingController();

  /// Controller for the security provider name field.
  TextEditingController securityProviderNameController =
      TextEditingController();

  /// Controller for the security provider TL number field.
  TextEditingController securityProviderTlNumberController =
      TextEditingController();

  /// Controller for the security provider Emirates ID field.
  TextEditingController securityProviderEmiratesIDController =
      TextEditingController();

  /// Controller for the security number field.
  TextEditingController securityNumberController = TextEditingController();

  /// Stores debounce timers used for grid customer searches.
  ///
  /// Key format: `customerRimGrid@{rowIndex}`.
  final Map<String, Timer?> _customerSearchDebounceTimers = {};

  /// Current page mode of the security screen.
  PageMode? pageMode;

  /// Security remarks entered by the user.
  String? remark;

  /// CMO remarks associated with the security.
  String? cmoRemark;

  /// Returns whether the current page is in edit mode.
  bool get canEdit => pageMode == PageMode.edit;

  /// Security provider country of incorporation.
  String? countryOfIncorporation = "";

  /// Security provider nationality.
  String? guarantatorNationality = "";

  /// Security provider identification document type.
  String? guarantatorIdDocumentType = "";

  /// Security provider identification document number.
  String? guarantatorIdNumber = "";

  /// Security provider UAE address.
  String? guarantatorUaeAddress = "";

  /// Security provider identification document expiry date.
  String? guarantatorExpiryDate = "";

  /// Preselected country used to initialize country-related fields.
  Country? preselectedCountry;

  /// Returns whether the current screen is in update mode.
  ///
  /// A security is considered to be in update mode when it has a
  /// valid security identifier.
  bool get isUpdateFlow =>
      security.securityId != null && security.securityId != 0;

  /// Rich text editor controller for security remarks.
  ///
  /// Initialized only when required for FI flow.
  UnifiedEditorController? remarksController;

  /// Rich text editor controller for CMO remarks.
  ///
  /// Initialized only when required for FI flow.
  UnifiedEditorController? cmoRemarksController;

  /// Scroll controller used for the create security screen.
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
    if (selectedSecurity != null && selectedSecurity.securityId != null) {
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

      // Default countryOfSecurity to UAE for new security creation.
      final uaeCountry = countries.firstWhere(
        (c) => c.code?.trim() == ServerConstants.uaeCountryCode,
        orElse: Country.new,
      );
      if (uaeCountry.description != null) {
        security.countryOfSecurity = uaeCountry.description;
        isCountrySecurityUAE = true;
      }

      if (canEdit) {
        registerDraftCallback();
      }
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  ///api call for only when created new security for
  /// the security value provided for the previously approved limits should be
  /// displayed

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
      securityNumberController.text = security.securityNumber ?? "";
      securityProviderCbdCustomer =
          security.selectedIsSecurityProviderCbdCustomerValue?.id ==
              ServerConstants.optionYESid;
      preselectedCountry = security.securityProvidedCountry;
      // security.securityType = null;
      securityProviderNameController.text = security.securityProvidedName ?? "";
      await applyInitialSecurityCurrency();
      if (security.dynamicFormDocument != null) {
        //Imp Note:below code for additional details is temporarily written here
        //to test, it will be needed to be moved to a method upon its desired
        //outcome

        dynamicFormDocument = security.dynamicFormDocument!;
      }
      getCMOremarks();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      AlertManager().showFailureToast("exp:$e");
    }
  }

  /// Initializes the remarks and CMO remarks values based on the
  /// current business segment.
  void getCMOremarks() {
    if (Utils.checkBusinessSegment(BusinessSegment.financialInstitution)) {
      remark = security.remarksFi ?? "";
      cmoRemark = security.cmoRemarksFi ?? "";
    } else {
      remark = security.remarks ?? "";
      cmoRemark = security.cmoRemark ?? "";
    }
  }

  /// Returns whether the current user can update CMO-related information.
  ///
  /// The user must have a documentation role and be assigned to the
  /// current request.
  bool isCmoUpdate() {
    final bool hasCmoRole = Utils.checkRoles([
      UserRole.documentationChecker,
      UserRole.documentationMaker,
    ]);

    return hasCmoRole && ScreenAccessConditions.isAssignedToCurrentUser();
  }

  /// Re-populates a dependent external-rating dropdown (e.g.
  /// `externalRatingBank`, `externalRatingCorporate`) when editing/loading a
  /// security whose agency-selector field (e.g. `ratingConductedBy`,
  /// `ratingAgencyCorporateGurantee`) already has a saved value.
  ///
  /// On a fresh form the dependent dropdown is filled live via
  /// `onDynamicFormFieldChange`, but that callback never fires on load, so an
  /// existing saved agency selection would otherwise leave the dependent
  /// dropdown with no options.
  Future<void> setExternalRatingByAgency(
    DynamicFormState formState,
    Security? selectedSecurity, {
    required int securityTypeId,
    required String agencyFieldKey,
    required String targetFieldKey,
  }) async {
    if (selectedSecurity?.securityType?.id != securityTypeId) {
      return;
    }
    final value = dynamicFormDocument[agencyFieldKey];
    if (value == null) {
      return;
    }
    final selOption = Option(
      key: value.toString(),
      pairValue: value.toString(),
      metaData: Reference(id: int.tryParse(value.toString())),
    );
    final List<Option> options = await filterExternalRatings(selOption);
    formState.updateDropdownOptions(targetFieldKey, options);
  }

  Future<void> getLimitsandFacilities(int? rimNo) async {
    try {
      bool startsWith100or400(String s) {
        return s.startsWith(
              "${ServerConstants.commitmentAccountNumberStartWith100}",
            ) ||
            s.startsWith(
              "${ServerConstants.commitmentAccountNumberStartWith400}",
            );
      }

      final List<LimitsResponse> limits =
          await securityRepository.getLimitsandFacilities(rimNo);
      String? normalize(String? value) {
        if (value == null) {
          return null;
        }
        final String trimmed = value.trim();
        return trimmed.isEmpty ? null : trimmed;
      }

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
    } on Object catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  /// Initializes dynamic form behavior for the selected security.
  ///
  /// Applies initial field visibility, enablement, dropdown values,
  /// and security-specific business rules after the form has been
  /// rendered.
  Future<void> initDynamicForm(Security? selectedSecurity) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final DynamicFormState? formState = dynamicFormKey.currentState;
      if (formState == null) {
        return;
      }

      if (dynamicFormDocument.containsKey("typeOfInsurance")) {
        if (dynamicFormDocument["typeOfInsurance"] == "creditInsurance") {
          formState
            ..setFieldVisibility("Pari-passu", isVisible: false)
            ..setFieldVisibility(
              "approvedCounterpartyInTermsOfCreditInsurance",
              isVisible: true,
            );
        }
        if (dynamicFormDocument["typeOfInsurance"] == "lifeInsurance") {
          formState.setFieldVisibility(
            "KeymanInsuranceHolderName",
            isVisible: true,
          );
        }
      }
      if (dynamicFormDocument.containsKey("Pari-passu")) {
        isParipassu =
            dynamicFormDocument["Pari-passu"].toString().toLowerCase() == "yes";
      }
      await Future.wait([
        setExternalRatingByAgency(
          formState,
          selectedSecurity,
          securityTypeId: ServerConstants.bankGuaranteeId,
          agencyFieldKey: "ratingConductedBy",
          targetFieldKey: "externalRatingBank",
        ),
        setExternalRatingByAgency(
          formState,
          selectedSecurity,
          securityTypeId: ServerConstants.corporateGuaranteeId,
          agencyFieldKey: "ratingAgencyCorporateGurantee",
          targetFieldKey: "externalRatingCorporate",
        ),
      ]);

      final valuatorCategory = dynamicFormDocument["ValuatorCategory"];
      if (valuatorCategory != null) {
        if (valuatorCategory == "Other Non-Panel") {
          formState
            ..setFieldVisibility("ValuatorName", isVisible: true)
            ..setFieldVisibility("evaluatorName", isVisible: false);
        } else {
          formState
            ..setFieldVisibility("evaluatorName", isVisible: true)
            ..setFieldVisibility("ValuatorName", isVisible: false);
        }
        // formState.setFieldVisibility('enterNonpanelValuatorName',
        //isEnabled: false);
        final valuatorName = dynamicFormDocument["ValuatorName"];
        if (valuatorName == "1087") {
          //Others option is selected
          formState.setFieldVisibility(
            "enterNonpanelValuatorName",
            isVisible: true,
          );
        } else {
          formState.setFieldVisibility(
            "enterNonpanelValuatorName",
            isVisible: false,
          );
        }
      }
      final nameOfTheZone = dynamicFormDocument["nameOfTheZone"];
      if (nameOfTheZone != null) {
        if (nameOfTheZone == "15057") {
          formState.setFieldVisibility("enterOtherNameOfZone", isVisible: true);
        } else {
          formState.setFieldVisibility(
            "enterOtherNameOfZone",
            isVisible: false,
          );
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
        ..setFieldEnabled("customerRimGrid", isEnabled: false)
        ..setFieldMandatory(
          "DiscountFactor%",
          isMandatory: security.securityType?.reference1 ==
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

  /// Debounced entry point for [getCurrencyRates].
  ///
  /// Every keystroke in an amount field triggers a rate lookup; this collapses
  /// a burst of them into one call 300 ms after the last, drives the AED
  /// field's spinner via [rateLoadingFor], and discards a response that a later
  /// trigger has already superseded.
  Future<void> getCurrencyRatesDebounced(
    Reference? selectedCurrency, {
    required bool isPresentSecurityAmount,
    double? proposedAmount,
  }) {
    return _rateDebouncerFor(isPresentSecurityAmount: isPresentSecurityAmount)
        .run(
      (int requestId) => _fetchAndApplyRates(
        selectedCurrency,
        isPresentSecurityAmount: isPresentSecurityAmount,
        proposedAmount: proposedAmount,
        requestId: requestId,
      ),
    );
  }

  /// Seeds the AED fields from the values the get-security response already
  /// carries, instead of recomputing them live on load.
  ///
  /// A fresh conversion can disagree with the AED amount the backend saved, so
  /// the stored `aedPresentSecurity` / `aedProposedSecurity` win on load. The
  /// live path takes over as soon as the user edits an amount or a currency.
  ///
  /// The rate fetch itself is **not** skipped: [getCurrencyRates] also pushes
  /// `securityvalueadjustedtoLTV` into the dynamic form, and that payload's
  /// `aedEquivalent` needs the rate. Only the controller writes are replaced.
  Future<void> applyInitialSecurityCurrency() async {
    final formatter = NumberFormat("#,###");

    final double? storedPresent = security.aedPresentSecurity;
    final double? storedProposed = security.aedProposedSecurity;

    await getCurrencyRates(
      security.proposedSecurityAmtCurrency,
      isPresentSecurityAmount: false,
      proposedAmount: security.proposedSecurityAmount,
    );

    if (storedPresent != null && storedPresent > 0) {
      newPresentSecurityAmountController.text =
          formatter.format(storedPresent.round());
      security.aedPresentSecurity = storedPresent;
    }

    if (storedProposed != null && storedProposed > 0) {
      newProposedSecurityAmountController.text =
          formatter.format(storedProposed.round());
      security.aedProposedSecurity = storedProposed;
    }
  }

  /// Retrieves exchange rates and updates AED-equivalent security values.
  ///
  /// Converts the selected security amount using the current exchange
  /// rate, updates the corresponding AED amount fields, and recalculates
  /// security values adjusted by loan-to-value ratios.
  ///
  /// Undebounced. UI callbacks should use [getCurrencyRatesDebounced]; this
  /// remains for load-time and programmatic use, and its signature is
  /// deliberately unchanged — test doubles override it.
  Future<void> getCurrencyRates(
    Reference? selectedCurrency, {
    required bool isPresentSecurityAmount,
    double? proposedAmount,
  }) {
    return _fetchAndApplyRates(
      selectedCurrency,
      isPresentSecurityAmount: isPresentSecurityAmount,
      proposedAmount: proposedAmount,
    );
  }

  /// The body of [getCurrencyRates], plus the staleness guard the debounced
  /// path needs.
  ///
  /// When [requestId] is supplied, the result is discarded if a newer request
  /// for the same amount field has been scheduled in the meantime, so a slow
  /// response for a currency the user has moved on from cannot overwrite the
  /// current value.
  Future<void> _fetchAndApplyRates(
    Reference? selectedCurrency, {
    required bool isPresentSecurityAmount,
    double? proposedAmount,
    int? requestId,
  }) async {
    bool isCurrent() =>
        requestId == null ||
        (_rateDebouncers[isPresentSecurityAmount]?.isCurrent(requestId) ??
            true);

    try {
      final CurrencyRates currencyRates =
          await securityRepository.getCurrencyRates(selectedCurrency);

      if (!isCurrent()) {
        return;
      }

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

      // Format values. Rounded, not truncated: a converted 7.6 must show as 8.
      final formatter = NumberFormat("#,###");
      final String formattedAED = formatter.format(convertedValue.round());

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
      final Map<String, dynamic> securityvalueadjustedtoLTV = {
        "fromCurrency": selectedCode,
        "fromVal": adjustedVal.round(),
        "aedEquivalent": (adjustedVal * exchangeRate).round(),
      };
      _updateLTVSecurityValue(securityvalueadjustedtoLTV);
      logger.i(securityvalueadjustedtoLTV);
    } on Object catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void _updateLTVSecurityValue(Map<String, dynamic> payload) {
    dynamicFormKey.currentState
        ?.updateFieldValue("securityvalueadjustedtoLTV", payload);
    dynamicFormKey.currentState
        ?.updateFieldValue("proposedSecurityValueForLTV", payload);
  }

  /// Updates the selected country of security.
  ///
  /// Also determines whether the selected country is the UAE and updates
  /// the corresponding UI state.
  void onSelectCountryofSecurity(Country selectedCountry) {
    security.countryOfSecurity = selectedCountry.description;

    if (selectedCountry.code?.trim() != ServerConstants.uaeCountryCode) {
      isCountrySecurityUAE = false;
    } else {
      isCountrySecurityUAE = true;
    }

    emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
  }

  /// Returns the appropriate security amount label based on the selected
  /// security type.
  ///
  /// For charge-type securities, charge amount labels are returned.
  /// For all other security types, security amount labels are returned.
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

  /// Returns the appropriate label for the bank, guarantor, or security
  /// provider field based on the selected security type.
  String bankGuarantorFieldLabel() {
    final int? typeId = security.securityType?.id;

    if (typeId == ServerConstants.securityTypeId[SecurityType.bankGuarantee]) {
      return "security.createSecurity.bank".tr();
    }

    final List<int?> guaranteeTypeIds = [
      ServerConstants.securityTypeId[SecurityType.personalGuarantee],
      ServerConstants.securityTypeId[SecurityType.corporateGuarantee],
    ];

    if (guaranteeTypeIds.contains(typeId)) {
      return "security.createSecurity.guarantor".tr();
    }

    return "security.createSecurity.securityProvider".tr();
  }

  // bool get isLimitControllingSecurity =>
  //     security.isLimitCtrlSecurity?.id == ServerConstants.optionNOid;

  /// Returns whether the current request belongs to the
  /// Financial Institution business segment.
  bool get isFIFlow =>
      Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

  /// Returns whether the selected security type is a guarantee type.
  ///
  /// Supported guarantee types include:
  /// - Bank Guarantee
  /// - Corporate Guarantee
  /// - Personal Guarantee
  /// - Financial Guarantee
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
    } on Object {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Handles selection of a security description, triggers loading of currency
  /// codes
  /// and dynamic form, and emits appropriate states.
  void securityTypeSelected(Reference? selectedValue) {
    security.securityType = selectedValue;
    security.isCashCollateral = (security.securityType?.reference2 ==
        ServerConstants.cashCollateralReference);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the security provider address.
  ///
  /// Refreshes the view state after the address is modified.
  void updateSecurityProviderAddress(String value) {
    security.securityProviderAddress = value;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Loads dynamic form data and supporting reference information.
  ///
  /// Retrieves required reference data, initializes dynamic form values,
  /// restores draft data when applicable, and applies dynamic form
  /// visibility rules.
  Future<void> loadDynamicForm() async {
    try {
      /// set separete loader for drop downs
      emit(state.copyWith(securityTypeStatus: LoadingStatus.loading));
      await Future.wait([
        getCurrencyCodes(),
        if (countries.isEmpty) getCountries(),
        getDynamicForm(),
      ]);

      loadDatasForDynamicForm();

      if (canEdit && !isUpdateFlow) {
        await loadDraftIfAvailable();
        // Re-run dynamic form visibility logic using the restored
        // dynamicFormDocument.
        // Must be called after the draft is applied and before the final emit
        // so the form renders with the correct field visibility on first build.
        await initDynamicForm(null);
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
  }

  /// Loads reference data required by the dynamic form.
  ///
  /// Populates global currency and economic zone option lists used by
  /// dynamic form controls.
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
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Updates the security provider category and applies related business rules.
  ///
  /// Resets or clears provider-specific information based on whether the
  /// selected category represents an entity or a natural person.
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

  /// Saves security details and optionally continues to the next step.
  ///
  /// Validates all form sections, persists dynamic form data, synchronizes
  /// model values, saves security information, and handles draft or final
  /// submission workflows based on the value of [saveAndContinue].
  Future<void> onSaveButtonPress({
    required bool saveAndContinue,
    String? securityCode,
  }) async {
    try {
      final bool isDynamicFormValid = dynamicFormKey.currentState?.validate() ??
          true; //If there is no dynamic form, allow to save
      final bool isOtherFormValid = formKey.currentState!.validate();

      if (!isDynamicFormValid || !isOtherFormValid) {
        // throw Exception(
        //   "security.createSecurity.requiredField".tr(),
        // );
        AlertManager()
            .showFailureToast("security.createSecurity.requiredField".tr());
        return;
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
        security.isDraft = true;
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
        } else {
          // At this point, model/controller should have the number.
          // Do a save that includes the number in the request.
          savedSecurity = await securityRepository.saveSecurityDetails(
            security,
            sections,
            securityCode,
          );
        }

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
        security.isDraft = false;
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
    } on Object catch (e) {
      logger.e("Error in onSaveButtonPress: $e");
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Cancels the current operation
  void onCancelButtonPress() {
    router.go(Routes.home);
  }

  /// Updates the selected cash collateral value.
  ///
  /// Refreshes the view state after the selection changes.
  void changeCashCollateralValue(Reference? value) {
    security.selectedCashCollateralValue = value;
    emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
  }

  /// Updates the limit controlling security flag based on the selected value.
  ///
  /// When the selected option is "Yes", the security is marked as a
  /// limit controlling security; otherwise, it is marked as not
  /// limit controlling.
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
        ?..setFieldEnabled("leagalStrOfGuarantor", isEnabled: true)
        ..setFieldEnabled("gurantorsIDDocument", isEnabled: true)
        ..setFieldEnabled("gurantorsIdNumber", isEnabled: true)
        ..setFieldEnabled("uaeAddress", isEnabled: true);
      securityProviderRimNumberController
        ..clear()
        ..text = "";
      security.securityProvidedRim = null;
    } else {
      dynamicFormKey.currentState
        ?..setFieldEnabled("leagalStrOfGuarantor", isEnabled: false)
        ..setFieldEnabled("gurantorsIDDocument", isEnabled: false)
        ..setFieldEnabled("gurantorsIdNumber", isEnabled: false)
        ..setFieldEnabled("uaeAddress", isEnabled: false);
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

  /// Updates the selected security group and loads the corresponding
  /// security type options.
  ///
  /// For the "Other Security" group, a placeholder security type is
  /// created to allow user-defined input. For other groups, matching
  /// security types are loaded from the reference data.
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
        isActive: selectedGroup.isActive ?? false,
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

  /// Updates the name of the selected security type.
  ///
  /// Used when the selected security type allows free-text entry.
  void onSecurityTypeTextChanged(String value) {
    if (security.securityType != null) {
      security.securityType!.name = value;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Retrieves available currency codes and initializes currency-related
  /// defaults.
  ///
  /// Ensures AED is prioritized, sets default currency selections,
  /// updates currency-dependent visibility flags, and refreshes the UI.
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
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Handles currency selection changes for security amount fields.
  ///
  /// Updates the selected currency, controls the visibility of AED
  /// equivalent amount fields, and refreshes currency-dependent UI state.
  void onCurrencyChanged(
    Reference? ref, {
    required bool isPresentSecurityAmount,
  }) {
    // Update the correct currency field
    if (isPresentSecurityAmount) {
      security.presentSecurityAmtCurrency = ref;
    } else {
      security.proposedSecurityAmtCurrency = ref;
    }

    final selectedCode = (ref?.name ?? "").toUpperCase();
    final bool isAed = selectedCode == ServerConstants.aedCurrency;

    // Toggle the appropriate AED equivalent amount field visibility.
    if (isPresentSecurityAmount) {
      showPresentSecurityAmount = !isAed;
    } else {
      showProposedSecurityAmount = !isAed;
    }

    // Update FX rate availability based on the selected currency.
    disableFxRates = !isAed;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Retrieves a list of countries from the server and stores them in the
  /// [countries] property. If the retrieval fails, the loader status is set to
  /// [LoadingStatus.error].
  Future<void> getCountries() async {
    try {
      countries = (await CustomerRepository.instance.getCountries() ?? [])
        ..sort(
          (Country firstCountry, Country secondCountry) =>
              (firstCountry.description ?? "")
                  .compareTo(secondCountry.description ?? ""),
        );
    } on Object catch (e) {
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
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));

    final DynamicFormState? form = dynamicFormKey.currentState;
    if (form == null || customerDetails == null) {
      return;
    }
    logger.i("customer Details:- ${customerDetails?.addressLine1}");
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

  /// Converts the provided value into a [DateTime] instance.
  ///
  /// Supports:
  /// - [DateTime] values
  /// - ISO date strings
  /// - Dynamic form date maps containing a `jsdate` value
  ///
  /// Returns `null` when the value cannot be parsed.
  DateTime? parseDate(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

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

  /// Calculates the lease term between two dates.
  ///
  /// Returns the duration formatted as a combination of years,
  /// months, and days. Returns an empty string when the end date
  /// is earlier than the start date.
  String calculateLeaseTerm(DateTime start, DateTime end) {
    if (end.isBefore(start)) {
      return "";
    }

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
    if (years > 0) {
      parts.add('$years Year${years > 1 ? 's' : ''}');
    }
    if (months > 0) {
      parts.add('$months Month${months > 1 ? 's' : ''}');
    }
    if (days > 0) {
      parts.add('$days Day${days > 1 ? 's' : ''}');
    }

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
    if (rimValue.isEmpty) {
      return;
    }

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
    } on Object catch (e) {
      AlertManager().showFailureToast("Error fetching customer details: $e");
    }
  }

  /// Handles changes to dynamic form fields.
  ///
  /// Applies field-specific business rules, updates field visibility,
  /// manages dependent values, performs lookups, and synchronizes
  /// dynamic form data with the security model.
  Future<void> onDynamicFormFieldChange(
    String fieldKey,
    Object? value,
  ) async {
    final form = dynamicFormKey.currentState;

    switch (fieldKey) {
      case "searchByName":
        if (value is! Map<String, dynamic>) {
          return;
        }
        // Extract grid name to use grid-qualified keys
        final String? gridName = value["gridName"];
        final int rowIndex = value["index"];
        final bool isChecked = value["value"] ?? false;

        if (gridName != null) {
          // Use grid-qualified field keys to ensure changes only affect
          // the specific grid where the checkbox was toggled
          final String rimKey = "$gridName.customerRimGrid";
          final String nameKey = "$gridName.nameInApprovedCounterparty";

          if (isChecked) {
            // Enable RIM field, disable name field
            dynamicFormKey.currentState
                ?.setFieldEnabled(rimKey, isEnabled: true, index: rowIndex);
            dynamicFormKey.currentState
                ?.setFieldEnabled(nameKey, isEnabled: false, index: rowIndex);
            // Clear the name field when switching to RIM search
            dynamicFormKey.currentState?.updateFieldValue(
              nameKey,
              {"index": rowIndex, "value": ""},
            );
          } else {
            // Disable RIM field, enable name field
            dynamicFormKey.currentState
                ?.setFieldEnabled(rimKey, isEnabled: false, index: rowIndex);
            dynamicFormKey.currentState
                ?.setFieldEnabled(nameKey, isEnabled: true, index: rowIndex);
            // Clear the RIM field when switching to name entry
            dynamicFormKey.currentState?.updateFieldValue(
              rimKey,
              {"index": rowIndex, "value": ""},
            );
          }
        }
      case "customerRimGrid":
        if (value is! Map<String, dynamic>) {
          return;
        }
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
        if (value is! Option) {
          return;
        }
        final Reference selectedRefernce = value.metaData;
        if (selectedRefernce.id == 15057) {
          //Others option is selected
          dynamicFormKey.currentState
              ?.setFieldVisibility("enterOtherNameOfZone", isVisible: true);
        } else {
          dynamicFormKey.currentState
              ?.setFieldVisibility("enterOtherNameOfZone", isVisible: false);
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
        final double parsedValue =
            double.tryParse(value?.toString() ?? "0") ?? 0;
        loanToValue = (parsedValue == 0 ? 1 : parsedValue / 100);
        final double securityvalueadjustedtoLTV = (loanToValue ?? 1) *
            (currentMarketValue ?? security.proposedSecurityAmount ?? 1);
        _updateLTVSecurityValue({
          "fromCurrency": security.presentSecurityAmtCurrency?.name,
          "fromVal": securityvalueadjustedtoLTV.round(),
          "aedEquivalent": securityvalueadjustedtoLTV.round(),
        });

      case "currentMarketValue":
        if (value is! Map<String, dynamic>) {
          return;
        }
        currentMarketValue = value["fromVal"] ?? 1;
        final double securityvalueadjustedtoLTV2 = (loanToValue ?? 1) *
            (currentMarketValue ?? security.proposedSecurityAmount ?? 1);
        _updateLTVSecurityValue({
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
            ?.setFieldMandatory("mortgagedAmount", isMandatory: !isParipassu);

      case "typeOfInsurance":
        if (value is! Option) {
          return;
        }
        if (value.key == "creditInsurance") {
          dynamicFormKey.currentState?.setFieldVisibility(
            "approvedCounterpartyInTermsOfCreditInsurance",
            isVisible: true,
          );
          dynamicFormKey.currentState
              ?.setFieldVisibility("Pari-passu", isVisible: false);
        } else {
          dynamicFormKey.currentState?.setFieldVisibility(
            "approvedCounterpartyInTermsOfCreditInsurance",
            isVisible: false,
          );
        }
        if (value.key == "lifeInsurance") {
          dynamicFormKey.currentState?.setFieldVisibility(
            "KeymanInsuranceHolderName",
            isVisible: true,
          );
          dynamicFormKey.currentState
              ?.setFieldVisibility("Pari-passu", isVisible: true);
        } else {
          dynamicFormKey.currentState?.setFieldVisibility(
            "KeymanInsuranceHolderName",
            isVisible: false,
          );
        }
        if (value.key == "assetInsurance") {
          dynamicFormKey.currentState
              ?.setFieldVisibility("Pari-passu", isVisible: true);
        }

      case "typeOfExposure":
        if (value is! Option) {
          return;
        }
        final selected = value.key ?? value;

        if (selected == "proposedPercentage") {
          dynamicFormKey.currentState?.setFieldVisibility(
            "proposedPercentagePercent",
            isVisible: true,
          );
          dynamicFormKey.currentState
              ?.setFieldVisibility("amountOfExposure", isVisible: false);
        } else if (selected == "amountOfExposureCovered") {
          dynamicFormKey.currentState?.setFieldVisibility(
            "proposedPercentagePercent",
            isVisible: false,
          );
          dynamicFormKey.currentState
              ?.setFieldVisibility("amountOfExposure", isVisible: true);
        }

      case "musatahaCommenceDate":
      case "Lease/MusatahaEndDate":
        if (form == null) {
          break;
        }
        final startRaw = form.getFieldValue("musatahaCommenceDate");
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
        if (value is! Option) {
          return;
        }
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
            ?.setFieldVisibility("gurantorsIdNumber", isVisible: true);

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
        dynamicFormKey.currentState
            ?.setFieldVisibility("uaeAddress", isVisible: true);

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
        if (value is! Option) {
          return;
        }
        final List<Option> options = await filterExternalRatings(value);

        dynamicFormKey.currentState?.updateDropdownOptions(
          "externalRatingBank",
          options,
          clearSelection: true,
        );

      case "ratingAgencyCorporateGurantee":
        if (value is! Option) {
          return;
        }
        final List<Option> options = await filterExternalRatings(value);

        dynamicFormKey.currentState?.updateDropdownOptions(
          "externalRatingCorporate",
          options,
          clearSelection: true,
        );

      case "ValuatorCategory":
        if (value == "Other Non-Panel") {
          dynamicFormKey.currentState
              ?.setFieldVisibility("ValuatorName", isVisible: true);
          dynamicFormKey.currentState
              ?.setFieldVisibility("evaluatorName", isVisible: false);
        } else {
          dynamicFormKey.currentState
              ?.setFieldVisibility("evaluatorName", isVisible: true);
          dynamicFormKey.currentState
              ?.setFieldVisibility("ValuatorName", isVisible: false);
        }
        dynamicFormKey.currentState
            ?.setFieldVisibility("enterNonpanelValuatorName", isVisible: false);
        dynamicFormKey.currentState?.clearDropdownSelection("ValuatorName");

      case "ValuatorName":
        if (value is! Option) {
          return;
        }
        final Reference selectedRefernce = value.metaData;
        if (selectedRefernce.id == 1087) {
          //Others option is selected
          dynamicFormKey.currentState?.setFieldVisibility(
            "enterNonpanelValuatorName",
            isVisible: true,
          );
        } else {
          dynamicFormKey.currentState?.setFieldVisibility(
            "enterNonpanelValuatorName",
            isVisible: false,
          );
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

          double parseNum(value) {
            if (value == null) {
              return 0;
            }
            if (value is num) {
              return value.toDouble();
            }
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

  /// Filters external rating values based on the selected rating agency.
  ///
  /// Returns the matching rating options that can be displayed in
  /// the corresponding dynamic form dropdown.
  Future<List<Option>> filterExternalRatings(
    Option selectedAgency,
  ) async {
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
    for (final RateDebouncer debouncer in _rateDebouncers.values) {
      debouncer.dispose();
    }
    _rateDebouncers.clear();
    return super.close();
  }
}
