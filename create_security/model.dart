// ignore_for_file: avoid_print

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

  List<Country> countries = [];

  Map<String, dynamic> dynamicFormDocument = {};

  String? selectedCurrencyCode; // e.g., "AED"
  bool showProposedSecurityAmount = false;
  bool disableFxRates = false;
  bool isEntityProvider = false;

  bool didPrefillCountryFromRim = false;

  TextEditingController proposedSecurityAmountController =
      TextEditingController();
  TextEditingController newProposedSecurityAmountController =
      TextEditingController();
  TextEditingController securityProviderRimNumberController =
      TextEditingController();
  TextEditingController securityProviderNameController =
      TextEditingController();

  PageMode pageMode = PageMode.na;

  bool get canEdit => (pageMode == PageMode.edit);

  String? countryOfIncorporation;
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

  bool iscmoRemarkReadOnly() {
    List<String> readOnlyRoles = ["DC", "DM", "CCU-M", "CCU-C"];
    return readOnlyRoles.contains(Globals.user?.currentRole?.code);
  }

  Future<void> getCurrencyRates(Reference? selectedCurrency) async {
    try {
      CurrencyRates currencyRates = await FacilitySecurityRepository.instance
          .getCurrencyRates(selectedCurrency);

      exchangeRate = currencyRates.rates[selectedCurrency?.name] ?? 0;

      // If user already entered an amount, calculate AED equivalent
      final amount = security.proposedSecurityAmount ?? 0;
      final convertedValue = amount * exchangeRate;

      // Format values
      final formatter = NumberFormat('#,###');
      final formattedAED = formatter.format(convertedValue.toInt());

      // Update AED controller
      newProposedSecurityAmountController.value = TextEditingValue(
        text: formattedAED,
        selection: TextSelection.collapsed(offset: formattedAED.length),
      );

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
      debugPrint(sections.toString());
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
      dynamicFormKey.currentState?.updateFieldValue('premiumAmount', {
        'fromCurrency': 'USD',
        'fromVal': 100,
        'aedEquivalent': 367.3
      }); // hermano, this is an example to manually update value in form. can be used for CL value update

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
      disableFxRates = !isAed;

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  void onCurrencyChanged(Reference? ref) {
    security.proposedSecurityAmtCurrency = ref;
    selectedCurrencyCode = (ref?.name ?? ref?.name)?.toUpperCase();

    bool isAed = selectedCurrencyCode == ServerConstants.aedCurrency;

    showProposedSecurityAmount = !isAed;
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
      final customerDetails =
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

        countryOfIncorporation = customerDetails?.residentCountry;
        print(countryOfIncorporation);
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
        // for (Section section in sections) {
        //   for (RowElement element in (section.rows ?? [])) {
        //     for (DynamicField field in element.fields ?? []) {
        //       if (field.key == 'datePicker') {
        //         field.defaultValue = customerDetails?.tlExpiryDate;
        //       }
        //       if (field.key == 'uaeAddress') {
        //         field.defaultValue = customerDetails?.primaryBusinessActivity;
        //       }
        //       if (field.key == 'gurantorsIdNumber') {
        //         // field.defaultValue = customerDetails?.;
        //       }
        //       if (field.key == 'gurantorsIDDocument') {
        //         // field.defaultValue = customerDetails?.;
        //       }
        //       if (field.key == 'nationalityOfGuarantor') {
        //         //  field.defaultValue = customerDetails?.;
        //       }
        //     }
        //   }
        // }

        // didPrefillCountryFromRim = security.countryIncorporation != null;
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

  Future<void> onDynamicFormFieldChange(String fieldKey, dynamic value) async {
    if (fieldKey == 'policyNumber') {
      final adjustedValue = value?.toString() ?? '';
      dynamicFormKey.currentState?.updateFieldValue(
        'policyNumber2',
        adjustedValue.trim(),
      );
    } else if (fieldKey == 'premiumAmount') {
      final adjustedValue = value['aedEquivalent']?.toString() ?? '';
      dynamicFormKey.currentState?.updateFieldValue(
        'mortgagedAmount',
        adjustedValue.trim(),
      );
      dynamicFormKey.currentState
          ?.setFieldVisibility('nameOfTheInsuranceCompany', false);
    } else if (fieldKey == 'typeOfInsurance') {
      Map<String, List<Reference>> referenceData = await ReferenceDataService()
          .getReferenceData([ReferenceDataKeys.accountType]);
      //convert this list to list of options
      List<Option> options = referenceData[ReferenceDataKeys.accountType]
              ?.map((e) =>
                  Option(key: e.id.toString(), pairValue: e.name, metaData: e))
              .toList() ??
          [];

      // update options in a dropdown
      dynamicFormKey.currentState?.updateDropdownOptions(
        'nameOfTheInsuranceCompany',
        options,
      );
    }
  }
}
