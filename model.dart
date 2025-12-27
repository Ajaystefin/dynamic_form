// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures

import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/dynamic_form/dynamic_form.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/section.dart';
import 'package:wcas_frontend/core/components/dynamic_form/utils/date_utils.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/country.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/facility_security/exchange_rate.dart';
import 'package:wcas_frontend/models/request/facility_security/security.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'package:wcas_frontend/repositories/auth_repository.dart';
import 'package:wcas_frontend/repositories/customer_respository.dart';
import 'package:wcas_frontend/repositories/facility_security_repository.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

/// A ViewModel class that manages the creation and configuration of security details
/// within the application. It handles form state, reference data retrieval,
/// user interactions, and saving of security information.
class CreateSecurityViewModel extends Cubit<CreateSecurityState> {
  CreateSecurityViewModel()
      : super(CreateSecurityState(loaderStatus: LoadingStatus.loading));

  /// Repository for handling request-related operations.
  RequestRepository repository = RequestRepository.instance;

  GlobalKey<DynamicFormState> dynamicFormKey = GlobalKey<DynamicFormState>();
  Request request = Request();
  Security security = Security();
  Customer? customerDetails = Customer();
  bool isCountrySecurityUAE = true;
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

  String? selectedCurrencyCode; // e.g., "AED"
  bool showProposedSecurityAmount = false;
  bool showPresentSecurityAmount = false;
  bool disableFxRates = false;
  bool isEntityProvider = false;
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

  /// Map to store debounce timers for grid customer searches
  /// Key format: "customerRimGrid@{rowIndex}"
  final Map<String, Timer?> _customerSearchDebounceTimers = {};

  PageMode pageMode = PageMode.na;

  bool get canEdit => (pageMode == PageMode.edit);

  String? countryOfIncorporation = "";
  String? guarantatorNationality = "";
  String? guarantatorIdDocumentType = "";
  String? guarantatorIdNumber = "";
  String? guarantatorUaeAddress = "";
  String? guarantatorExpiryDate = "";

  Country? preselectedCountry;

  /// Initializes the ViewModel by setting up repositories and loading reference data.
  Future<void> init(Security? selectedSecurity) async {
    logger.i('initialising CreateSecurityViewModel');

    request = Globals.request ?? Request();
    isApproved = selectedSecurity != null;
    pageMode = AuthRepository.getPageMode(RightConstants.createSecurity);
    if (selectedSecurity != null) {
      security = selectedSecurity;
      await getSecurity(selectedSecurity);
      await onPressContinueButton();
      emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
    } else {
      //   await getSecurity(selectedSecurity);
    }

    await getReferenceDatas();
  }

  Future<void> getSecurity(Security? selectedSecurity) async {
    try {
      security = await repository.getSecurityDetails(
              selectedSecurity: selectedSecurity) ??
          Security();
      // security.securityType = null; //TODO causing error in dynamic form fetching

      securityProviderNameController.text = security.securityProvidedName ?? "";

      // Copy the flattened dynamicFormDocument to the ViewModel's document map
      if (security.dynamicFormDocument != null) {
        dynamicFormDocument = security.dynamicFormDocument!;
        dynamicFormKey.currentState?.setFieldVisibility('Pari-passu', false);
        dynamicFormKey.currentState
            ?.setFieldVisibility('KeymanInsuranceHolderName', false);
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  bool isCmoUpdate() {
    return Utils.checkRoles([
      UserRole.documentationChecker,
      UserRole.documentationMaker,
      UserRole.ccuMaker,
      UserRole.ccuChecker
    ]);
  }

  Future<void> getCurrencyRates(
      Reference? selectedCurrency, bool isPresentSecurityAmount,
      {double? proposedAmount}) async {
    try {
      final CurrencyRates currencyRates = await FacilitySecurityRepository
          .instance
          .getCurrencyRates(selectedCurrency);

      // Resolve the selected currency code/name safely
      final String selectedCode = selectedCurrency?.name ?? '';

      // Get exchange rate for the selected currency
      exchangeRate = currencyRates.rates[selectedCode] ?? 0;

      // Pick the correct amount based on the flag
      final double amount = isPresentSecurityAmount
          ? (security.presentSecurityAmount ?? 0)
          : (security.proposedSecurityAmount ?? 0);

      // Convert
      final double convertedValue = amount * exchangeRate;

      // Format values
      final formatter = NumberFormat('#,###');
      final String formattedAED = formatter.format(convertedValue.toInt());

      // Update the correct controller (present vs proposed)
      if (isPresentSecurityAmount) {
        newPresentSecurityAmountController.value = TextEditingValue(
          text: formattedAED,
          selection: TextSelection.collapsed(offset: formattedAED.length),
        );
      } else {
        newProposedSecurityAmountController.value = TextEditingValue(
          text: formattedAED,
          selection: TextSelection.collapsed(offset: formattedAED.length),
        );
      }

      dynamicFormKey.currentState?.updateFieldValue(
          "securityvalueadjustedtoLTV",
          (proposedAmount ?? 1) * (loanToValue ?? 1));
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onSelectCountryofSecurity(Country selectedCountry) {
    security.countryOfSecurity = selectedCountry.code;
    if (selectedCountry.code?.trim() != ServerConstants.uaeCountryCode) {
      isCountrySecurityUAE = false;
    } else {
      isCountrySecurityUAE = true;
    }
    emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
  }

  String securityProviderLabel({required bool isPresent}) {
    List<int> chargeTypeIds = [74, 83, 87, 89, 93, 99];
    bool isChargeType = chargeTypeIds.contains(security.securityType?.id);

    if (isPresent) {
      return isChargeType
          ? 'security.createSecurity.presentChargeAmount'.tr()
          : 'security.createSecurity.presentSecurityAmount'.tr();
    } else {
      return isChargeType
          ? 'security.createSecurity.proposedChargeAmount'.tr()
          : 'security.createSecurity.proposedSecurityAmount'.tr();
    }
  }

  String bankGuarantorFieldLabel() {
    List<int> guaranteeTypeIds = [76, 85];
    int? typeId = security.securityType?.id;

    return typeId == 79
        ? "security.createSecurity.bank".tr()
        : guaranteeTypeIds.contains(typeId)
            ? "security.createSecurity.guarantor".tr()
            : "security.createSecurity.securityProvider".tr();
  }

  bool get isSecurityProviderCbdCustomerNo =>
      security.selectedIsSecurityProviderCbdCustomerValue?.id ==
      ServerConstants.optionNOid;

  /// Fetches reference data for security types, statuses, and other options.
  /// Filters out "N/A" options and emits a loaded or error state.
  Future<void> getReferenceDatas() async {
    try {
      Map<String, List<Reference>> referenceData =
          await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.securityType,
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
      securityReferenceData =
          referenceData[ReferenceDataKeys.securityType] ?? [];
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
          .toList();
      economicZones = referenceData[ReferenceDataKeys.economicZones] ?? [];

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Handles selection of a security description, triggers loading of currency codes
  /// and dynamic form, and emits appropriate states.
  Future<void> securityTypeSelected(Reference? selectedValue) async {
    security.securityType = selectedValue;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateSecurityProviderAddress(String value) {
    security.securityProviderAddress = value;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> onPressContinueButton() async {
    try {
      /// set separete loader for drop downs
      emit(state.copyWith(securityTypeStatus: LoadingStatus.loading));
      await Future.wait([
        getCurrencyCodes(),
        getCountries(),
        getDynamicForm(),
      ]);
      loadDatasForDynamicForm();
      //TODO move all this logics into separete function in code cleaning
      dynamicFormKey.currentState?.setFieldVisibility('Pari-passu', false);
      dynamicFormKey.currentState
          ?.setFieldVisibility('KeymanInsuranceHolderName', false);
      dynamicFormKey.currentState?.setFieldEnabled('customerRimGrid', false);
      dynamicFormKey.currentState?.setFieldMandatory(
          'DiscountFactor%',
          security.securityType?.reference1 ==
              ServerConstants.tangibleSecurityReference);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
  }

  void loadDatasForDynamicForm() {
    Globals.dynamicFormCurrencyCodes = currencyCodes
        .map((ref) => Option(key: ref.id.toString(), pairValue: ref.name ?? ''))
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

      emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  void changeSecurityProviderCategory(Reference selectedCategory) {
    // Update the category name
    security.securityProviderCategory = selectedCategory.name;

    // Compare using constant ID instead of string
    bool isEntitySelected =
        selectedCategory.id == ServerConstants.securityProviderCategoryEntityId;

    // Update TL number requirement
    isEntityProvider = isEntitySelected;
    security.securityProviderEmiratesId = null;

    emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
  }

  // bool get isSecurityExpiryOpenEndedSelected {
  //   return security?.isSecurityExpiryOpenEnded?.id ==
  //       ServerConstants.optionYESid; // Replace with actual ID for "Yes"
  // }

  /// Saves the security details to the repository.
  /// Populates the security object with metadata and dynamic form data.
  Future<void> onSaveButtonPress(bool saveAndContinue) async {
    try {
      bool isDynamicFormValid = dynamicFormKey.currentState!.validate();
      bool isOtherFormValid = formKey.currentState!.validate();
      if (!isDynamicFormValid || !isOtherFormValid) {
        throw "security.createSecurity.requiredField".tr();
      }

      formKey.currentState?.save();

      dynamicFormKey.currentState!.save();

      security.dynamicFormDocument = dynamicFormDocument;
      //TODO instead of passing them like this pass them from representitive widgets
      security.presentSecurityAmount = double.tryParse(
          presentSecurityAmountController.text
              .replaceAll(RegExp(r'[,\s]'), ''));
      security.proposedSecurityAmount = double.tryParse(
          proposedSecurityAmountController.text
              .replaceAll(RegExp(r'[,\s]'), ''));

      await securityRepository.saveSecurityDetails(security, sections);

      AlertManager()
          .showSuccessToast("security.createSecurity.saveSuccess".tr());
      if (saveAndContinue) router.goNamed(Routes.securitySummaryView);
    } catch (e) {
      logger.e('Error in onSaveButtonPress: $e');
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Cancels the current operation
  void onCancelButtonPress() {
    router.go(Routes.home);
  }

  /// Updates the selected tangible security value and emits a loaded state.
  // void changeTangibleSecurityValue(Reference? value) {
  //   security.selectedTangibleSecurityValue = value;
  //   emit(state.copyWith(securityStatus: LoadingStatus.loaded));
  // }

  void changeCashCollateralValue(Reference? value) {
    security.selectedCashCollateralValue = value;
    emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
  }

  /// Updates the selected limit-controlling security value and emits a loaded state.
  void changeLimitControllingSecurityValue(Reference? value) {
    security.isLimitCtrlSecurity = value;
    emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
  }

  /// Updates the selected CBD customer value and toggles the internal flag.
  void changeSecurityProviderCbdCustomerValue(Reference? value) {
    security.selectedIsSecurityProviderCbdCustomerValue = value;
    securityProviderCbdCustomer = value?.id == ServerConstants.optionYESid;
    if (!securityProviderCbdCustomer) {
      dynamicFormKey.currentState
          ?.setFieldEnabled('leagalStrOfGuarantor', true);
      dynamicFormKey.currentState?.setFieldEnabled('gurantorsIDDocument', true);
      dynamicFormKey.currentState?.setFieldEnabled('gurantorsIdNumber', true);
      dynamicFormKey.currentState?.setFieldEnabled('uaeAddress', true);
      securityProviderRimNumberController.clear();
    } else {
      dynamicFormKey.currentState
          ?.setFieldEnabled('leagalStrOfGuarantor', false);
      dynamicFormKey.currentState
          ?.setFieldEnabled('gurantorsIDDocument', false);
      dynamicFormKey.currentState?.setFieldEnabled('gurantorsIdNumber', false);
      dynamicFormKey.currentState?.setFieldEnabled('uaeAddress', false);
      securityProviderNameController.clear();

      security.securityProvidedName = null;
    }
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

    for (Reference ref in securityReferenceData) {
      if (selectedGroup.reference4 == ref.reference4) {
        securityTypes.add(ref);
      }
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> getCurrencyCodes() async {
    try {
      currencyCodes = await repository.getCurrencyCodes();
      //sorting for make AED in first
      currencyCodes.sort(
        (a, b) =>
            (b.name?.toUpperCase() == ReferenceDataKeys.currencyAED ? 1 : 0) -
            (a.name?.toUpperCase() == ReferenceDataKeys.currencyAED ? 1 : 0),
      );
      Reference aed = currencyCodes.firstWhere(
        (r) => (r.name ?? r.name)?.toUpperCase() == ServerConstants.aedCurrency,
        orElse: () =>
            currencyCodes.isNotEmpty ? currencyCodes.first : Reference(),
      );
      security.proposedSecurityAmtCurrency ??= aed;
      selectedCurrencyCode = (security.proposedSecurityAmtCurrency?.name ??
              security.proposedSecurityAmtCurrency?.name)
          ?.toUpperCase();
      bool isAed = selectedCurrencyCode == ServerConstants.aedCurrency;
      showProposedSecurityAmount = !isAed;
      showPresentSecurityAmount = !isAed;
      disableFxRates = !isAed;

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
    final selectedCode = (ref?.name ?? '').toUpperCase();

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
        ..sort((a, b) => (a.description ?? '').compareTo(b.description ?? ''));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
      logger.i('Error fetching getCountries : $e');
    }
  }

  /// Searches for customer information using the provided RIM number.
  /// Emits a loaded state after retrieval.

  Future<void> searchByRim(String rim) async {
    try {
      security.securityProvidedRim = rim;
      customerDetails = await customerRepository.searchUserDetailsPartyInqOnly(
          rim, '', '', '');

      // No id to compare
      if (security.securityType?.id == ServerConstants.corporateGuaranteeId &&
          customerDetails?.partyIdType == ServerConstants.personal) {
        AlertManager().showFailureToast("riskRating.invalidCorporateRim".tr());
        return;
      }
      // No id to compare

      // if (security.securityType?.id == ServerConstants.personalGuaranteeId &&
      //     customerDetails?.partyIdType != ServerConstants.personal) {
      //   AlertManager().showFailureToast("riskRating.invalidPersonalRim".tr());
      //   return;
      // }

      if (customerDetails?.id == null) {
        didPrefillCountryFromRim = false;
        AlertManager().showFailureToast("riskRating.invalidRim".tr());
      } else {
        security.securityProvidedName =
            "${customerDetails?.firstName} ${customerDetails?.middleName} ${customerDetails?.lastName}";
        countryOfIncorporation = customerDetails?.tLIssueCountry;

        //  Trigger dependent logic via the same pipeline

        Country matchedCountry = countries.firstWhere((country) =>
            (country.description ?? '')
                .replaceAll(RegExp(r'\s+'), '')
                .toLowerCase() ==
            (countryOfIncorporation ?? '')
                .replaceAll(RegExp(r'\s+'), '')
                .toLowerCase());

        preselectedCountry = countries.firstWhere(
          (country) =>
              (country.description ?? '').trim().toLowerCase() ==
              (countryOfIncorporation ?? '').trim().toLowerCase(),
        );

        if (matchedCountry.description != null) {
          security.securityProvidedCountry = matchedCountry;
          preselectedCountry = matchedCountry;
          didPrefillCountryFromRim = true;

          emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
        } else {
          didPrefillCountryFromRim = false;
        }

        // Trigger UI update
        emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
        security.securityProvidedName =
            "${customerDetails?.firstName} ${customerDetails?.middleName} ${customerDetails?.lastName}";
        securityProviderNameController.text =
            security.securityProvidedName ?? '';
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));

    DynamicFormState? form = dynamicFormKey.currentState;
    if (form == null || customerDetails == null) return;
    print('customer Details:- ${customerDetails?.addressLine1}');
    final expiryDt = customerDetails?.customerTlExpiryDate;
    form.updateFieldValue('securityProvidedName',
        "${customerDetails?.firstName} ${customerDetails?.middleName} ${customerDetails?.lastName}");
    form.updateFieldValue(
      'gteeExpiryDate',
      expiryDt != null
          ? convertDateTimeToFormValue(DateTime.parse(expiryDt))
          : null,
    );
    print("expiryDt $expiryDt");
    form.updateFieldValue(
      'uaeAddress',
      '${customerDetails?.customerAddress1 ?? ''}\n'
          '${customerDetails?.customerAddress2 ?? ''}\n'
          '${customerDetails?.customerAddress3 ?? ''}\n'
          '${customerDetails?.city ?? ''}\n'
          '${customerDetails?.country ?? ''}',
    );
    form.updateFieldValue(
      'nationalityOfGuarantor',
      customerDetails?.tLIssueCountry ?? "",
    );
    Reference? document = customerDetails?.issuedIdent?.firstWhere(
        (doc) => ServerConstants.guarantorDocumentTypes.contains(doc.name),
        orElse: () => Reference());
    if (document?.name != null) {
      form.updateFieldValue(
        'gurantorsIdNumber',
        document?.description ?? '',
      );
      dynamicFormKey.currentState?.setDropdownDefaultSelection(
        'gurantorsIDDocument',
        Option(
          key: document?.description,
          pairValue: document?.name,
        ),
      );
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    if (value is String) {
      return DateTime.tryParse(value);
    }

    if (value is Map) {
      final jsDate = value['jsdate'];
      if (jsDate is String) {
        return DateTime.tryParse(jsDate);
      }
    }

    return null;
  }

  String _calculateLeaseTerm(DateTime start, DateTime end) {
    if (end.isBefore(start)) return '';

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

    return parts.join(' ');
  }

  /// Searches for customer details by RIM number in grid with debouncing
  ///
  /// This method is debounced to prevent excessive API calls while the user is typing.
  /// It waits 500ms after the last keystroke before making the API call.
  ///
  /// Parameters:
  /// - [rimValue]: The RIM number to search for
  /// - [rowIndex]: The grid row index where the search was triggered
  Future<void> _searchCustomerByRimInGrid(String rimValue, int rowIndex) async {
    if (rimValue.isEmpty) return;

    try {
      // Call searchUserDetailsForCL to get customer details
      Customer? customer = await customerRepository.searchUserDetailsForCL(
        rimValue,
        null,
        null,
        null,
      );

      if (customer != null) {
        // Populate the name field in the same row
        final nameKey = 'nameInApprovedCounterparty@$rowIndex';
        final customerName =
            customer.preferredName ?? customer.customerName ?? '';

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
    debugPrint('field change key $fieldKey, value $value');
    final form = dynamicFormKey.currentState;

    switch (fieldKey) {
      case "searchByName":
        if (value['value']) {
          dynamicFormKey.currentState
              ?.setFieldEnabled('customerRimGrid', true, index: value['index']);
        } else {
          dynamicFormKey.currentState?.setFieldEnabled('customerRimGrid', false,
              index: value['index']);
        }
        break;
      case 'customerRimGrid':
        // Extract RIM number and row index from the value
        final rimValue = value['value']?.toString() ?? '';
        final rowIndex = value['index'];
        final debounceKey = 'customerRimGrid@$rowIndex';

        // Cancel any existing timer for this field
        _customerSearchDebounceTimers[debounceKey]?.cancel();

        if (rimValue.isNotEmpty) {
          // Create a new debounced timer (500ms delay)
          _customerSearchDebounceTimers[debounceKey] = Timer(
            const Duration(milliseconds: 500),
            () => _searchCustomerByRimInGrid(rimValue, rowIndex),
          );
        }
        break;

      case "nameOfTheZone":
        Reference selectedRefernce = value.metaData;
        if (selectedRefernce.id == 15057) {
          //Others option is selected
          dynamicFormKey.currentState
              ?.setFieldVisibility('enterOtherNameOfZone', true);
        } else {
          dynamicFormKey.currentState
              ?.setFieldVisibility('enterOtherNameOfZone', false);
        }
        break;

      case "guarantorEntityId":
        List<String?> lst = value.toString().split("@");

        dynamicFormKey.currentState
            ?.updateFieldValue("internalModelRating", lst[0] ?? "");
        dynamicFormKey.currentState
            ?.updateFieldValue("internalModelRatingProposed", lst[1] ?? "");

        break;

      case ("loanToValue" || "ltv"):
        double parsedValue = double.tryParse((value ?? "0")) ?? 0;
        loanToValue = (parsedValue == 0 ? 1 : parsedValue / 100);
        double securityvalueadjustedtoLTV = (loanToValue ?? 1) *
            (currentMarketValue ?? security.proposedSecurityAmount ?? 1);
        dynamicFormKey.currentState?.updateFieldValue(
            "securityvalueadjustedtoLTV", securityvalueadjustedtoLTV);
        break;

      case "currentMarketValue":
        currentMarketValue = value['fromVal'] ?? 1;
        double securityvalueadjustedtoLTV2 = (loanToValue ?? 1) *
            (currentMarketValue ?? security.proposedSecurityAmount ?? 1);
        dynamicFormKey.currentState?.updateFieldValue(
            "securityvalueadjustedtoLTV", securityvalueadjustedtoLTV2);
        break;

      case 'policyNumber':
        // final adjustedValue = value?.toString() ?? '';
        // dynamicFormKey.currentState?.updateFieldValue(
        //   'policyNumber2',
        //   adjustedValue.trim(),
        // );
        break;

      case "Pari-passu":
        final paripasuvalue = value?.toString().trim().toLowerCase();
        isParipassu = (paripasuvalue == 'yes');
        dynamicFormKey.currentState
            ?.setFieldMandatory('mortgagedAmount', !isParipassu);
        break;

      case 'typeOfInsurance':
        if (value.key == "creditInsurance") {
          dynamicFormKey.currentState?.setFieldVisibility(
              'approvedCounterpartyInTermsOfCreditInsurance', true);
          dynamicFormKey.currentState?.setFieldVisibility('Pari-passu', false);
        } else {
          dynamicFormKey.currentState?.setFieldVisibility(
              'approvedCounterpartyInTermsOfCreditInsurance', false);
        }
        if (value.key == "lifeInsurance") {
          dynamicFormKey.currentState
              ?.setFieldVisibility('KeymanInsuranceHolderName', true);
          dynamicFormKey.currentState?.setFieldVisibility('Pari-passu', true);
        } else {
          dynamicFormKey.currentState
              ?.setFieldVisibility('KeymanInsuranceHolderName', false);
        }
        if (value.key == "assetInsurance") {
          dynamicFormKey.currentState?.setFieldVisibility('Pari-passu', true);
        }
        break;

      case 'typeOfExposure':
        final selected = value?.key ?? value;

        if (selected == 'proposedPercentage') {
          dynamicFormKey.currentState
              ?.setFieldVisibility('proposedPercentagePercent', true);
          dynamicFormKey.currentState
              ?.setFieldVisibility('amountOfExposure', false);

          debugPrint("vm typeofexposure ");
        } else if (selected == 'amountOfExposureCovered') {
          dynamicFormKey.currentState
              ?.setFieldVisibility('proposedPercentagePercent', false);
          dynamicFormKey.currentState
              ?.setFieldVisibility('amountOfExposure', true);
        }
        break;

      case 'musatahaCommenceDate':
      case 'Lease/MusatahaEndDate':
        final startRaw = form!.getFieldValue('musatahaCommenceDate');
        final endRaw = form.getFieldValue('Lease/MusatahaEndDate');

        final startDate = _parseDate(startRaw);
        final endDate = _parseDate(endRaw);

        if (startDate != null && endDate != null) {
          final leaseTerm = _calculateLeaseTerm(startDate, endDate);

          form.updateFieldValue(
            'LeaseTerm',
            leaseTerm,
          );
        } else {
          // Clear if one date missing
          form.updateFieldValue('LeaseTerm', '');
        }
        break;

      case 'propertyType':
        Map<String, List<Reference>> referenceData =
            await ReferenceDataService()
                .getReferenceData([ReferenceDataKeys.propertySubType]);
        List<Reference>? propertySubtypes =
            referenceData[ReferenceDataKeys.propertySubType];
        List<Reference>? filteredSubtypes =
            propertySubtypes?.where((Reference subType) {
          return subType.reference1 == value.metaData.id.toString();
        }).toList();

        List<Option>? options = filteredSubtypes
                ?.map((subType) => Option(
                    key: subType.id.toString(),
                    pairValue: subType.name,
                    metaData: subType))
                .toList() ??
            [];

        dynamicFormKey.currentState?.updateDropdownOptions(
            'propertySubtype', options,
            clearSelection: true);
        break;

      case 'gurantorsIDDocument':
        dynamicFormKey.currentState
            ?.setFieldVisibility('gurantorsIdNumber', true);
        break;

      case 'gurantorsIdNumber':
        final adjustedValue = customerDetails?.customerGroupId.toString();
        dynamicFormKey.currentState?.updateFieldValue(
          'gurantorsIdNumber',
          adjustedValue,
        );
        break;

      case 'uaeAddress':
        final adjustedValue =
            "${customerDetails?.customerAddress1}  ${customerDetails?.customerAddress2}";
        dynamicFormKey.currentState?.updateFieldValue(
          'uaeAddress',
          adjustedValue,
        );
        dynamicFormKey.currentState?.setFieldVisibility('uaeAddress', true);
        break;

      case 'localCountryAddress':
        final adjustedValue =
            "${customerDetails?.customerAddress1}  ${customerDetails?.customerAddress2}";
        dynamicFormKey.currentState?.updateFieldValue(
          'localCountryAddress',
          adjustedValue,
        );
        break;

      case 'nationalityOfGuarantor':
        String? nation = value?.toString();

        final bool isUAE = nation == 'AE' ||
            nation == 'ARE' ||
            nation == 'UNITED ARAB EMIRATES';

        dynamicFormKey.currentState?.updateFieldValue('resident', isUAE);
        break;

      case 'ratingConductedBy':
        List<Option>? options = await filterExternalRatings(value);

        dynamicFormKey.currentState?.updateDropdownOptions(
            'externalRatingBank', options,
            clearSelection: true);
        break;

      case 'ratingAgencyCorporateGurantee':
        List<Option>? options = await filterExternalRatings(value);

        dynamicFormKey.currentState?.updateDropdownOptions(
            'externalRatingCorporate', options,
            clearSelection: true);
        break;

      case 'ValuatorCategory':
        if (value == "Other Non-Panel") {
          dynamicFormKey.currentState?.setFieldVisibility('ValuatorName', true);
          dynamicFormKey.currentState
              ?.setFieldVisibility('evaluatorName', false);
        } else {
          dynamicFormKey.currentState
              ?.setFieldVisibility('evaluatorName', true);
          dynamicFormKey.currentState
              ?.setFieldVisibility('ValuatorName', false);
        }
        dynamicFormKey.currentState
            ?.setFieldVisibility('enterNonpanelValuatorName', false);
        dynamicFormKey.currentState?.clearDropdownSelection('ValuatorName');
        break;

      case 'ValuatorName':
        Reference selectedRefernce = value.metaData;
        if (selectedRefernce.id == 1087) {
          //Others option is selected
          dynamicFormKey.currentState
              ?.setFieldVisibility('enterNonpanelValuatorName', true);
        } else {
          dynamicFormKey.currentState
              ?.setFieldVisibility('enterNonpanelValuatorName', false);
        }
        break;

      case 'noOfUnits':
      case 'mvPerUnit':
        {
          final form = dynamicFormKey.currentState;

          final int? rowIndex = (value is Map) ? value['index'] as int? : null;

          final String unitsKey = 'noOfUnits@$rowIndex';
          final String priceKey = 'mvPerUnit@$rowIndex';
          final String totalKey = 'totalMv@$rowIndex';

          final dynamic unitsRaw = form?.getFieldValue(unitsKey);
          final dynamic priceRaw = form?.getFieldValue(priceKey);

          double parseNum(dynamic value) {
            if (value == null) return 0.0;
            if (value is num) return value.toDouble();
            if (value is String) {
              final cleaned = value.replaceAll(',', '').trim();
              return double.tryParse(cleaned) ?? 0.0;
            }
            return 0.0; // default fallback to avoid NaN
          }

          final double units = parseNum(unitsRaw);
          final double price = parseNum(priceRaw);
          final double total = units * price;

          form?.updateFieldValue(totalKey, total.toStringAsFixed(2));

          debugPrint('[$totalKey] units=$units, price=$price, total=$total');
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
    Map<String, List<Reference>> referenceData = await ReferenceDataService()
        .getReferenceData([ReferenceDataKeys.externalRatingAgencyValues]);
    //convert this list to list of options
    List<Reference>? agencyValues =
        referenceData[ReferenceDataKeys.externalRatingAgencyValues];
    List<Reference>? filteredValues = agencyValues?.where((Reference subType) {
      return subType.reference1 == selectedAgency.metaData.id.toString();
    }).toList();

    List<Option>? options = filteredValues
            ?.map((subType) => Option(
                key: subType.id.toString(),
                pairValue: subType.name,
                metaData: subType))
            .toList() ??
        [];
    return options;
  }
}
