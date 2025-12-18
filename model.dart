// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/dynamic_form/dynamic_form.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/section.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
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
  late RequestRepository repository;

  GlobalKey<DynamicFormState> dynamicFormKey = GlobalKey<DynamicFormState>();
  Request request = Request();
  Security security = Security();
  Customer? customerDetails = Customer();
  bool isCountrySecurityUAE = true;
  bool isApproved = false;

  /// Repository for handling facility security-related operations.
  late FacilitySecurityRepository securityRepository;

  /// Global key for the main form used in the security creation screen.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Global key for the dynamic form section.

  List<Reference>? yesAndNo = [];
  List<Reference> securityReferenceData = [];
  List<Reference> securityBorrowerRole = [];
  bool securityProviderCbdCustomer = false;

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
    repository = RequestRepository.instance;
    securityRepository = FacilitySecurityRepository.instance;
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

  Future<void> getSecurity(Security? security) async {
    try {
      security = await repository.getSecurityDetails(security: security);
      security?.securityType = null;

      securityProviderNameController.text =
          security?.securityProvidedName ?? "";
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

  bool iscmoRemarkReadOnly() {
    //TODO:if logic is same as above, merge both methods
    return Utils.checkRoles([
      UserRole.documentationChecker,
      UserRole.documentationMaker,
      UserRole.ccuMaker,
      UserRole.ccuChecker
    ]);
  }

  Future<void> getCurrencyRates(
      Reference? selectedCurrency, bool isPresentSecurityAmount) async {
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

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  void onSelectCountryofSecurity(Country selectedCountry) {
    security.countryOfSecurity = selectedCountry;
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
      if (!isDynamicFormValid && !isOtherFormValid) {
        return;
      }

      formKey.currentState?.save();

      dynamicFormKey.currentState!.save();

      security.dynamicFormDocument = dynamicFormDocument;
      print(security.securityExpireDate);
      await securityRepository.saveSecurityDetails(security);

      AlertManager()
          .showSuccessToast("security.createSecurity.saveSuccess".tr());
      if (saveAndContinue) LayoutViewModel().goToNextRoute();
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
    (value?.id == yesAndNo?.first.id)
        ? securityProviderCbdCustomer = false
        : securityProviderCbdCustomer = true;
    if (securityProviderCbdCustomer) {
      securityProviderRimNumberController.clear();
    } else {
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
      countries = (await CustomerRepository().getCountries() ?? [])
        ..sort((a, b) => (a.description ?? '').compareTo(b.description ?? ''));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
      logger.i('Error fetching getCountries : $e');
    }
  }

  void _prefillDynamicFormFromCustomer() {
    final form = dynamicFormKey.currentState;
    if (form == null || customerDetails == null) return;
    print('customer Details:- ${customerDetails?.addressLine1}');
    final expiryDt = customerDetails?.customerTlExpiryDate;
    form.updateFieldValue(
      'securityProvidedName',
      customerDetails?.preferredName ?? customerDetails?.customerName,
    );
    form.updateFieldValue(
      'gteeExpiryDate',
      expiryDt != null ? DateTime.parse(expiryDt) : null,
    );
    print("expiryDt $expiryDt");
    form.updateFieldValue(
      'uaeAddress',
      '${customerDetails?.customerAddress1 ?? ''} '
              '${customerDetails?.customerAddress2 ?? ''}'
          .trim(),
    );

    form.updateFieldValue(
      'gurantorsIdNumber',
      customerDetails?.customerGroupId?.toString(),
    );
  }

  /// Searches for customer information using the provided RIM number.
  /// Emits a loaded state after retrieval.

  Future<void> searchByRim(String rim) async {
    try {
      security.securityProvidedRim = rim;
      customerDetails =
          await CustomerRepository().searchUserDetails(rim, '', '', '');

      // No id to compare
      if (security.securityType?.id == ServerConstants.corporateGuaranteeId &&
          customerDetails?.partyIdType == ServerConstants.personal) {
        AlertManager().showFailureToast("riskRating.invalidCorporateRim".tr());
        return;
      }
      // No id to compare

      if (security.securityType?.id == ServerConstants.personalGuaranteeId &&
          customerDetails?.partyIdType != ServerConstants.personal) {
        AlertManager().showFailureToast("riskRating.invalidPersonalRim".tr());
        return;
      }

      if (customerDetails?.id == null) {
        didPrefillCountryFromRim = false;
        AlertManager().showFailureToast("riskRating.invalidRim".tr());
      } else {
        security.securityProvidedName = customerDetails?.preferredName;
        countryOfIncorporation = customerDetails?.tLIssueCountry;

        //  Trigger dependent logic via the same pipeline

        Country matchedCountry = countries.firstWhere((country) =>
            (country.code ?? '').replaceAll(RegExp(r'\s+'), '').toLowerCase() ==
            (countryOfIncorporation ?? '')
                .replaceAll(RegExp(r'\s+'), '')
                .toLowerCase());

        preselectedCountry = countries.firstWhere(
          (country) =>
              (country.code ?? '').trim().toLowerCase() ==
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
            customerDetails?.preferredName ?? customerDetails?.customerName;
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final form = dynamicFormKey.currentState;
        print('Form STATE => $form');
        form?.updateFieldValue('gurantorsIdNumber', 'asd');
      });

      _prefillDynamicFormFromCustomer();
    });
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

  int? _extractRowIndex(String key) {
    if (!key.contains('@')) return null;
    return int.tryParse(key.split('@').last);
  }

  void recalculateGridTotal(String changedKey) {
    final form = dynamicFormKey.currentState;
    if (form == null) return;
    final rowIndex = _extractRowIndex(changedKey);
    if (rowIndex == null) return;

    final unitsKey = 'noOfUnits@$rowIndex';
    final priceKey = 'mvPerUnit@$rowIndex';
    final totalKey = 'totalMv@$rowIndex';

    final unitsRaw = form.getFieldValue(unitsKey);
    final priceRaw = form.getFieldValue(priceKey);
    print('units key $unitsKey => $unitsRaw');
    print('price key $priceKey => $priceRaw');

    double? units =
        double.tryParse(unitsRaw.toString().replaceAll(',', '')) ?? 0.0;
    double? price = priceRaw is Map
        ? double.tryParse(priceRaw['aedEquivalent'].toString()) ?? 0
        : double.tryParse(priceRaw.toString()) ?? 0;

    final total = units * price;

    print('recalc:$totalKey = $total ');

    form.updateFieldValue(totalKey, total.toStringAsFixed(2));
    print('State totalMv@0:${form.getFieldValue('totalMv@0')}');

    emit(state.copyWith());
  }

  Future<void> onDynamicFormFieldChange(String fieldKey, dynamic value) async {
    debugPrint('field change key $fieldKey, value $value');
    final form = dynamicFormKey.currentState;
    dynamicFormKey.currentState?.setFieldMandatory(
        'DiscountFactor%',
        security.securityType?.reference1 ==
            ServerConstants.tangibleSecurityReference);

    switch (fieldKey) {
      case "searchByName": // for demo, remove this later
        dynamicFormKey.currentState
            ?.setFieldVisibility('customerRimGrid', false);
        dynamicFormKey.currentState
            ?.updateFieldValue('nameInApprovedCounterparty@1', "aj");

        dynamicFormKey.currentState
            ?.updateFieldValue('amountInApprovedCounterparty@1', 125);
        break;
      case "nameOfTheZone":
        dynamicFormKey.currentState?.setFieldVisibility(
            'enterOtherNameOfZone', value.value == "14972");
        break;

      case "guarantorEntityId":
        List<String> lst = value.toString().split("@");
        if (lst.length > 2) {
          dynamicFormKey.currentState
              ?.updateFieldValue("internalModelRating", lst[0]);
          dynamicFormKey.currentState
              ?.updateFieldValue("internalModelRatingProposed", lst[1]);
        }
        break;

      case "loanToValue":
        double parsedValue = double.tryParse((value ?? "0")) ?? 0;
        loanToValue = (parsedValue == 0 ? 1 : parsedValue / 100);

        final securityvalueadjustedtoLTV = (loanToValue ?? 1) *
            (currentMarketValue ?? security.proposedSecurityAmount ?? 1);

        dynamicFormKey.currentState?.updateFieldValue(
            "securityvalueadjustedtoLTV", securityvalueadjustedtoLTV);
        break;

      case "currentMarketValue":
        currentMarketValue = value['fromVal'];

        final securityvalueadjustedtoLTV2 = (loanToValue ?? 1) *
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

      case 'premiumAmount':
        final adjustedValue = value['aedEquivalent']?.toString() ?? '';
        dynamicFormKey.currentState?.updateFieldValue(
          'mortgagedAmount',
          adjustedValue.trim(),
        );
        dynamicFormKey.currentState
            ?.setFieldVisibility('nameOfTheInsuranceCompany', false);
        break;

      case 'typeOfInsurance':
        if (value.key == "creditInsurance") {
          dynamicFormKey.currentState?.setFieldVisibility(
              'approvedCounterpartyInTermsOfCreditInsurance', true);
        } else {
          dynamicFormKey.currentState?.setFieldVisibility(
              'approvedCounterpartyInTermsOfCreditInsurance', false);
        }
        if (value.key == "lifeInsurance") {
          dynamicFormKey.currentState
              ?.setFieldVisibility('KeymanInsuranceHolderName', true);
        } else {
          dynamicFormKey.currentState
              ?.setFieldVisibility('KeymanInsuranceHolderName', false);
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
        final adjustedValue = value?.toString();
        final nat = adjustedValue;
        final bool isUAE =
            nat == 'AE' || nat == 'ARE' || nat == 'UNITED ARAB EMIRATES';

        dynamicFormKey.currentState
            ?.updateFieldValue('nationalityOfGuarantor', adjustedValue);
        dynamicFormKey.currentState?.updateFieldValue('resident', isUAE);
        break;

      case 'gteeExpiryDate':
        dynamicFormKey.currentState?.updateFieldValue('gteeExpiryDate', value);
        dynamicFormDocument['gteeExpiryDate'] = value;
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
        // Handle grid field calculations for noOfUnits and mvPerUnit
        recalculateGridTotal(fieldKey);
        break;

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
