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
      await repository.saveSecurityDetails(security);
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
  }

  /// Toggles the CBD customer flag and emits a loaded state.
  void onPressedEditSecurityRimNo() {
    securityProviderCbdCustomer = !securityProviderCbdCustomer;
    emit(state.copyWith(securityTypeStatus: LoadingStatus.loaded));
  }

// // ---- Exact keys from your dynamic form ----
//   static const String commenceDate = 'musatahaCommenceDate';
//   static const String leaseEndDate = 'Lease/MusatahaEndDate';
//   static const String leaseKey = 'LeaseTerm';

// // ---- Tenor keys (replace if your actual keys differ) ----
//   static const String tenorValueKey = 'LeaseTenorValue';
//   static const String tenorUnitKey = 'LeaseTenorUnit';

// // Normalize unit to 'months' or 'years'
//   String _normalizeUnit(dynamic unitRaw) {
//     final u = (unitRaw ?? '').toString().trim().toLowerCase();
//     if (u == 'y' || u == 'year' || u == 'years') return 'years';
//     if (u == 'm' || u == 'month' || u == 'months') return 'months';
//     return u;
//   }

// // Read tenor value as int
//   int? _readInt(dynamic raw) {
//     if (raw == null) return null;
//     if (raw is num) return raw.toInt();
//     if (raw is String) return int.tryParse(raw);
//     return null;
//   }

// // Convert DateTime to dynamic form date map
//   Map<String, dynamic> _toDateMap(DateTime date) => {
//         'date': {'year': date.year, 'month': date.month, 'day': date.day},
//         'jsdate': date.toIso8601String(),
//         'formatted':
//             '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
//         'epoc': date.millisecondsSinceEpoch ~/ 1000,
//       };

// // Read DateTime from dynamicFormDocument
//   DateTime? _readDateFromDoc(Map<String, dynamic> doc, String key) {
//     final raw = doc[key];
//     if (raw == null) return null;
//     if (raw is Map<String, dynamic>) {
//       final iso = raw['jsdate'] as String?;
//       if (iso != null && iso.isNotEmpty) return DateTime.tryParse(iso);
//       final d = raw['date'] as Map<String, dynamic>?;
//       if (d != null) {
//         final y = d['year'] as int?;
//         final m = d['month'] as int?;
//         final day = d['day'] as int?;
//         if (y != null && m != null && day != null) return DateTime(y, m, day);
//       }
//     } else if (raw is String)
//       return DateTime.tryParse(raw);
//     else if (raw is int)
//       return DateTime.fromMillisecondsSinceEpoch(raw);
//     else if (raw is DateTime) return raw;
//     return null;
//   }

// // Add/subtract months safely
//   DateTime _addMonthsClamped(DateTime date, int monthsToAdd) {
//     final targetYear = date.year + ((date.month - 1 + monthsToAdd) ~/ 12);
//     final targetMonth = ((date.month - 1 + monthsToAdd) % 12) + 1;
//     final lastDay = DateTime(targetYear, targetMonth + 1, 0).day;
//     final targetDay = date.day.clamp(1, lastDay);
//     return DateTime(targetYear, targetMonth, targetDay);
//   }

// // Refresh LeaseTerm text
//   void _refreshLeaseTermVM() {
//     final start = _readDateFromDoc(dynamicFormDocument, commenceDate);
//     final end = _readDateFromDoc(dynamicFormDocument, leaseEndDate);

//     String term = '';
//     if (start != null && end != null && end.isAfter(start)) {
//       int months = (end.year - start.year) * 12 + (end.month - start.month);
//       final startPlusMonths = _addMonthsClamped(start, months);
//       if (end.isBefore(startPlusMonths)) months -= 1;
//       final aligned = _addMonthsClamped(start, months);
//       final days = end.difference(aligned).inDays;

//       final years = months ~/ 12;
//       final remMo = months % 12;
//       String p(int v, String u) => v > 0 ? '$v $u${v == 1 ? '' : 's'}' : '';
//       final parts = [
//         p(years, 'year'),
//         p(remMo, 'month'),
//         p(days, 'day'),
//       ].where((s) => s.isNotEmpty).toList();
//       term = parts.join(' ');
//     }

//     dynamicFormKey.currentState?.updateFieldValue(leaseKey, term);
//     dynamicFormDocument[leaseKey] = term;

//   }

// // Start + Tenor -> End
//   void _recomputeLeaseStartEndFromTenorVM() {
//     final start = _readDateFromDoc(dynamicFormDocument, commenceDate);
//     final int? tenorValue = _readInt(dynamicFormDocument[tenorValueKey]);
//     final String unit = _normalizeUnit(dynamicFormDocument[tenorUnitKey]);

//     if (start != null &&
//         tenorValue != null &&
//         tenorValue > 0 &&
//         unit.isNotEmpty) {
//       final int monthsToAdd = unit == 'years' ? tenorValue * 12 : tenorValue;
//       final DateTime end = _addMonthsClamped(start, monthsToAdd);
//       dynamicFormKey.currentState?.updateFieldValue(leaseEndDate, _toDateMap(end));
//       dynamicFormDocument[leaseEndDate] = _toDateMap(end);
//     }
//     _refreshLeaseTermVM();
//   }

// // End - Tenor -> Start
//   void _recomputeLeaseStartFromEndAndTenorVM() {
//     final end = _readDateFromDoc(dynamicFormDocument, leaseEndDate);
//     final int? tenorValue = _readInt(dynamicFormDocument[tenorValueKey]);
//     final String unit = _normalizeUnit(dynamicFormDocument[tenorUnitKey]);

//     if (end != null &&
//         tenorValue != null &&
//         tenorValue > 0 &&
//         unit.isNotEmpty) {
//       final int monthsToSub = unit == 'years' ? tenorValue * 12 : tenorValue;
//       final DateTime start = _addMonthsClamped(end, -monthsToSub);
//       dynamicFormKey.currentState
//           ?.updateFieldValue(commenceDate, _toDateMap(start));
//       dynamicFormDocument[commenceDate] = _toDateMap(start);
//     }
//     _refreshLeaseTermVM();
//   }

  Future<void> onDynamicFormFieldChange(String fieldKey, dynamic value) async {
    dynamicFormKey.currentState?.setFieldMandatory(
        'DiscountFactor%',
        security.securityType?.reference1 ==
            ServerConstants.tangibleSecurityReference);

    if (fieldKey == "loanToValue") {
      double parsedValue = double.tryParse((value ?? "0")) ?? 0;
      loanToValue = (parsedValue == 0 ? 1 : parsedValue / 100);

      final securityvalueadjustedtoLTV = (loanToValue ?? 1) *
          (currentMarketValue ?? security.proposedSecurityAmount ?? 1);

      dynamicFormKey.currentState?.updateFieldValue(
          "securityvalueadjustedtoLTV", securityvalueadjustedtoLTV);
    } else if (fieldKey == "currentMarketValue") {
      currentMarketValue = value['fromVal'];

      // ltv = ((dynamicFormKey.currentState?.getFieldValue("loanToValue")
      //         as Map<String, dynamic>?)?['fromVal'] as num?)
      //     ?.toDouble();
      final securityvalueadjustedtoLTV = (loanToValue ?? 1) *
          (currentMarketValue ?? security.proposedSecurityAmount ?? 1);
      dynamicFormKey.currentState?.updateFieldValue(
          "securityvalueadjustedtoLTV", securityvalueadjustedtoLTV);
    } else if (fieldKey == 'policyNumber') {
      // final adjustedValue = value?.toString() ?? '';
      // dynamicFormKey.currentState?.updateFieldValue(
      //   'policyNumber2',
      //   adjustedValue.trim(),
      // );
    } else if (fieldKey == "Pari-passu") {
      final paripasuvalue = value?.toString().trim().toLowerCase();
      isParipassu = (paripasuvalue == 'yes');
      dynamicFormKey.currentState
          ?.setFieldMandatory('mortgagedAmount', !isParipassu);
    } else if (fieldKey == 'premiumAmount') {
      final adjustedValue = value['aedEquivalent']?.toString() ?? '';
      dynamicFormKey.currentState?.updateFieldValue(
        'mortgagedAmount',
        adjustedValue.trim(),
      );
      dynamicFormKey.currentState
          ?.setFieldVisibility('nameOfTheInsuranceCompany', false);
    } else if (fieldKey == 'typeOfInsurance') {
      // approvedCounterpartyInTermsOfCreditInsurance
      if (value.key == "creditInsurance") {
        dynamicFormKey.currentState?.setFieldVisibility(
            'approvedCounterpartyInTermsOfCreditInsurance', true);
      } else {
        dynamicFormKey.currentState?.setFieldVisibility(
            'approvedCounterpartyInTermsOfCreditInsurance', false);
      }
    } else if (fieldKey == 'propertyType') {
      Map<String, List<Reference>> referenceData = await ReferenceDataService()
          .getReferenceData([ReferenceDataKeys.propertySubType]);
      //convert this list to list of options
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

      // update options in a dropdown
      dynamicFormKey.currentState?.updateDropdownOptions(
          'propertySubtype', options,
          clearSelection: true);
    }
    // else if (fieldKey == 'musatahaCommenceDate') {
    //   _recomputeLeaseStartEndFromTenorVM();
    // } else if (fieldKey == 'Lease/MusatahaEndDate') {
    //   _recomputeLeaseStartFromEndAndTenorVM();
    // } else if (fieldKey == 'LeaseTenorValue' || fieldKey == 'LeaseTenorUnit') {
    //   _recomputeLeaseStartEndFromTenorVM();
    // }
    else if (fieldKey == 'gurantorsIDDocument') {
      dynamicFormKey.currentState
          ?.setFieldVisibility('gurantorsIdNumber', true);
    } else if (fieldKey == 'gurantorsIdNumber') {
      // await onDynamicFormFieldChange('gurantorsIDDocument', customerDetails?.customerGroupId.toString());
      //   await onDynamicFormFieldChange('gurantorsIdNumber', customerDetails?.customerGroupId.toString());
      //   await onDynamicFormFieldChange('uaeAddress', "${customerDetails?.customerAddress1}  ${customerDetails?.customerAddress2}");
      //   await onDynamicFormFieldChange('localCountryAddress', "${customerDetails?.customerAddress1}  ${customerDetails?.customerAddress2}");
      //   await onDynamicFormFieldChange('nationalityOfGuarantor', customerDetails?.tLIssueCountry);
      //   await onDynamicFormFieldChange('gteeExpiryDate', customerDetails?.customerTlExpiryDate);
      final adjustedValue = customerDetails?.customerGroupId.toString();
      dynamicFormKey.currentState?.updateFieldValue(
        'gurantorsIdNumber',
        adjustedValue,
      );
    } else if (fieldKey == 'uaeAddress') {
      final adjustedValue =
          "${customerDetails?.customerAddress1}  ${customerDetails?.customerAddress2}";
      dynamicFormKey.currentState?.updateFieldValue(
        'uaeAddress',
        adjustedValue,
      );
      dynamicFormKey.currentState?.setFieldVisibility('uaeAddress', true);
    } else if (fieldKey == 'localCountryAddress') {
      final adjustedValue =
          "${customerDetails?.customerAddress1}  ${customerDetails?.customerAddress2}";
      dynamicFormKey.currentState?.updateFieldValue(
        'localCountryAddress',
        adjustedValue,
      );
    } else if (fieldKey == 'nationalityOfGuarantor') {
      final adjustedValue = value?.toString();
      final nat = adjustedValue;
      final bool isUAE =
          nat == 'AE' || nat == 'ARE' || nat == 'UNITED ARAB EMIRATES';

      dynamicFormKey.currentState
          ?.updateFieldValue('nationalityOfGuarantor', adjustedValue);
      dynamicFormKey.currentState?.updateFieldValue('resident', isUAE);
    } else if (fieldKey == 'gteeExpiryDate') {
      dynamicFormKey.currentState?.updateFieldValue('gteeExpiryDate', value);
      dynamicFormDocument['gteeExpiryDate'] = value;
    } else if (fieldKey == 'ratingConductedBy') {
      List<Option>? options = await filterExternalRatings(value);

      dynamicFormKey.currentState?.updateDropdownOptions(
          'externalRatingBank', options,
          clearSelection: true);
    } else if (fieldKey == 'ratingAgencyCorporateGurantee') {
      List<Option>? options = await filterExternalRatings(value);

      dynamicFormKey.currentState?.updateDropdownOptions(
          'externalRatingCorporate', options,
          clearSelection: true);
    } else if (fieldKey == 'ValuatorCategory') {
      if (value == "Other Non-Panel") {
        dynamicFormKey.currentState?.setFieldVisibility('ValuatorName', true);
        dynamicFormKey.currentState?.setFieldVisibility('evaluatorName', false);
      } else {
        dynamicFormKey.currentState?.setFieldVisibility('evaluatorName', true);
        dynamicFormKey.currentState?.setFieldVisibility('ValuatorName', false);
      }
      dynamicFormKey.currentState
          ?.setFieldVisibility('enterNonpanelValuatorName', false);
      dynamicFormKey.currentState?.clearDropdownSelection('ValuatorName');
    } else if (fieldKey == 'ValuatorName') {
      Reference selectedRefernce = value.metaData;
      if (selectedRefernce.id == 1087) {
        //Others option is selected
        dynamicFormKey.currentState
            ?.setFieldVisibility('enterNonpanelValuatorName', true);
      } else {
        dynamicFormKey.currentState
            ?.setFieldVisibility('enterNonpanelValuatorName', false);
      }
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
