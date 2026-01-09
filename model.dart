import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
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
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/country.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/facility_security/borrower_facility.dart';
import 'package:wcas_frontend/models/request/facility_security/exchange_rate.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_condition_list.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_detail.dart';
import 'package:wcas_frontend/models/request/facility_security/limit_facilities.dart';
import 'package:wcas_frontend/models/request/facility_security/limits_facilities_response.dart';
import 'package:wcas_frontend/models/request/facility_security/project_list.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'package:wcas_frontend/repositories/customer_respository.dart';
import 'package:wcas_frontend/repositories/facility_security_repository.dart';
import 'state.dart';

class CreateFacilityViewModel extends Cubit<CreateFacilityState> {
  CreateFacilityViewModel()
      : super(CreateFacilityState(loaderStatus: LoadingStatus.loading));

  /// Key for validating the main form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Repository for facility security-related operations.
  late FacilitySecurityRepository repository;

  /// Facility model being created or edited.
  Facility facility = Facility();

  FacilityDetails facilityDetails = FacilityDetails();

  /// Request object containing application context.
  Request request = Request();

  /// Key for validating the dynamic form section.
  GlobalKey<DynamicFormState> dynamicFormKey = GlobalKey<DynamicFormState>();

  /// Customer related operations Search take timer .
  final Map<String, Timer?> _customerSearchDebounceTimers = {};

  /// Repository for Customer related operations.
  CustomerRepository customerRepository = CustomerRepository();

  /// List of form sections used in the dynamic form.
  List<Section> sections = [];
  List<Country>? countryList = [];
  bool? isMainLimit = false;
  List<String> limitTypeFacility = ["Main Limit", "Sub Limit"];

  String? selectedCurrencyCode; // e.g., "AED"
  bool isApiError = false;

  /// Document data for the dynamic form.
  Map<String, dynamic> dynamicFormDocument = {};
  List<FeeRate> feeDefualtRate = [];
  List<Condition> standardCondition = [];
  List<Condition> nonStandardCondition = [];
  List<FacilitySubTypes> facilitySubTypes = [];
  List<FacilityDetail> facilityDetail = [];
  List<Reference> commitmentAccountNumbers = [];
  List<LimitsResponse> limits = [];
  List<String> commitmentAccountNumberItems = [];
  List<Reference> benchmark = [];
  List<Reference> marginSign = [];
  num exchangeRate = 0;

  int? subTypeID;

  /// Reference data lists used for dropdowns and selections.
  List<Reference> currencyCodes = [];
  List<Reference> limitTypes = [];
  List<Reference> limitCapsType = [];

  List<Reference> regulatorySpecialisedLandingOptions = [];
  List<Reference> productTypeItems = [];
  List<Reference> promissoryNoteOptions = [];
  List<Reference> collateralDepantantoptions = [];
  List<Reference> projectFinanceRelatedActivityOptions = [];
  List<Reference> sharedLimits = [];
  List<Reference> sectors = [];
  List<Reference> sicCodes = [];

  List<Reference> facilityTypes = [];
  List<Reference> facilityDescriptions = [];
  List<Reference> facilityFeeTypes = [];
  List<Reference> facilityTypesFeeFrequency = [];

  List<Reference> accountTypes = [];
  List<Reference> advanceTypes = [];
  List<Reference> controllingLimitNumbers = [];

  List<Reference> propertySubTypes = [];
  List<Reference> propertyTypes = [];
  List<Reference> policyDeviations = [];
  List<Reference> purposes = [];
  List<Reference> emirates = [];
  List<Reference> regulatorySpecifications = [];
  List<Reference> seniorities = [];
  List<Reference> borrowersMap = [];
  List<Borrower> borrowers = [];
  List<Reference> borrowersByRimInTable = [];
  List<Reference> committedValues = [];
  List<Reference> sustanabilityClassifications = [];
  List<Reference> period = [];

  List<Reference> tenorDays = [
    Reference(name: "Days"),
    Reference(name: "Months")
  ];

  bool _allocationWarningShown = false;

  bool get isPropertyTypeEnabled {
    return (facility.purposeValue?.reference1 ?? '').trim().toUpperCase() ==
        'Y';
  }

  bool get isPurposeEnabled {
    return isProjectFinanceNo ||
        (facility.projectName?.name?.trim().isNotEmpty ?? false);
  }

  bool get isProductTypeIslamic =>
      facility.selectedProductTypeValue?.id ==
      ServerConstants.productTypeIslamicID;

// Returns true when the Project Finance Related Activity is selected as "No"
  bool get isProjectFinanceNo {
    final name =
        (facility.selectedProjectFinanceRelatedActivityValue?.name ?? '')
            .trim()
            .toLowerCase();
    return name == 'no';
  }

  List<Reference>? get projectNameSelectedForUi {
    if (isProjectFinanceNo) {
      return facility.projectName != null
          ? [facility.projectName!]
          : [Reference(name: 'General')];
    }
    return facility.projectName != null ? [facility.projectName!] : null;
  }

  bool get isEmiratesEnabled => facility.propertySubType != null;
  bool showCreateFacilityForm = false;
  TextEditingController newProposedFacilityAmountController =
      TextEditingController();

  List<bool> standardConditionsSelected = [];
  List<bool> nonStandardConditionsSelected = [];
  List<bool> actionsNonStandardAmendSelected = [];
  List<bool> actionsStandardAmendSelected = [];
  List<bool> isNewlyAddedNonStandardCondition = [];
  List<bool> actionsNonStandardWaiveOffSelected = [];
  List<bool> actionsStandardWaiveOffSelected = [];
  bool showProposedSecurityAmount = false;

  bool disableFxRates = false;
  List<FacilityCondition> conditions = [];
  Reference? selectedProductType;
  int? rimNo;
  int? selectedRim;
  int? existingFacilityId;
  int? parentProposedLimit;
  String? parentControlliingNumber;
  TextEditingController limitTypeController = TextEditingController();
  TextEditingController limitDescriptionController = TextEditingController();
  final TextEditingController proposedLimitController = TextEditingController();
  int? selectedDescriptionId;
  String? mandatoryFeeTableRows;
  String? limitCategory;
  bool isFeeRowMandatory = false;
  bool? subLimit;
  static const String _uaeName = 'united arab emirates';
  static const Set<int> _pfDisabledGroups = {11312, 11313, 11314};
  bool get canEdit => true;

  String? get sustainabilityClassificationCsv {
    final list = facility
        .sustainabilityClassification; // List<Reference>? (current type)
    if (list == null || list.isEmpty) return null;
    final ids = list
        .map((e) => e.id?.toString())
        .where((id) => id != null && id.trim().isNotEmpty)
        .map((id) => id!.trim())
        .toList();
    return ids.isEmpty ? null : ids.join(',');
  }

  List<String> facilityTypesUnderCustomerRim = [
    "facilities.facilitySummary.generalWorking".tr(),
    "facilities.facilitySummary.loans".tr(),
    "facilities.facilitySummary.pfeLimits".tr(),
    "facilities.facilitySummary.projectStandBy".tr(),
    "facilities.facilitySummary.projectSpecificLimit".tr(),
  ];

  /// List of borrowers derived from the current request's customers.
  List<Reference> borrowersByRim = Globals.request?.customers
          ?.map((element) =>
              Reference(name: element.customerName, id: element.customerRimNo))
          .toList() ??
      [];
  bool showFacilityFi = false;
  List<Reference> projectNames = [];
  int? limitGroup;

  // Whether the radio should be enabled for the current limitGroup
  bool get isProjectFinanceActivityEnabled {
    final lg = limitGroup; // set in init: limitGroup = facility.limitGroup;
    return !(lg != null && _pfDisabledGroups.contains(lg));
  }

  bool isAnnualReview =
      Utils.checkApplicationType(ApplicationType.annualReview);

  // Find the "Yes"/"No" Reference from your options by name
  Reference _pfRefByName(String name) {
    final target = name.trim().toLowerCase();
    return projectFinanceRelatedActivityOptions.firstWhere(
      (e) => (e.name ?? '').trim().toLowerCase() == target,
      orElse: () => Reference(name: name),
    );
  }

  static const String _newAccLabel = 'NEW';

  /// UI items for Commitment Account Number:
  /// - If no items from API -> ["NEW"]
  /// - If items exist -> items + "NEW" appended (unique; last)
  List<String> get commitmentAccountNumberItemsForUi {
    if (commitmentAccountNumberItems.isEmpty) {
      return [_newAccLabel];
    }
    final List<String> base = commitmentAccountNumberItems
        .where((s) => s.trim().toUpperCase() != _newAccLabel)
        .toList();
    base.add(_newAccLabel);
    return base;
  }

  /// Selected value for UI:
  /// - If original list is empty -> preselect "NEW"
  /// - If API provided a value -> preselect that value (update flow)
  /// - Otherwise (data exists but no API value) -> no preselection (null)
  List<String>? get commitmentAccSelectedForUi {
    if (commitmentAccountNumberItems.isEmpty) {
      return [_newAccLabel];
    }
    if (showCreateFacilityForm) return null;
    final String? apiAcc = facilityDetail.isNotEmpty
        ? facilityDetail.first.commitmentAccountNumber
        : null;
    final String acc = (apiAcc ?? '').trim();
    if (acc.isNotEmpty) return [acc];
    return null;
  }

  int get effectiveProposedLimit {
    final fromUser = facility.proposedLimit;
    if (fromUser != null) return fromUser;
    final fromApi =
        facilityDetail.isNotEmpty ? facilityDetail.first.proposedLimit : null;
    if (fromApi == null) return 0;
    return fromApi.toInt();
  }

// Default ref based on enable/disable rule
  Reference get projectFinanceDefaultRef => isProjectFinanceActivityEnabled
      ? _pfRefByName('yes')
      : _pfRefByName('no');

// Is the form currently creating a Sub-Limit?
  bool get isSubLimitMode => !(facility.isMainLimit ?? false);

// Parent proposed limit (assumed to be in AED)
  int get parentLimitAED => parentProposedLimit ?? 0;

// Maximum user input allowed in the currently selected currency,
// derived from parent AED limit and the current exchange rate.
// If currency is AED or exchangeRate unknown (0), use the AED value.
  int get maxInputInSelectedCurrency {
    final code = (selectedCurrencyCode ?? '').toUpperCase();
    if (code == ServerConstants.aedCurrency || exchangeRate == 0) {
      return parentLimitAED;
    }
    return (parentLimitAED / exchangeRate).floor();
  }

// Selected value for the radio (falling back to rule-based default)
  Reference get projectFinanceSelectedOrDefault {
    final sel = facility.selectedProjectFinanceRelatedActivityValue;
    if (sel == null) return projectFinanceDefaultRef;
    final isYes = ((sel.name ?? '').trim().toLowerCase() == 'yes');
    if (!isProjectFinanceActivityEnabled && isYes) {
      return _pfRefByName('no');
    }
    return sel;
  }

  List<Reference> get propertySubTypesForSelectedType {
    final parentId = facility.propertyType?.id?.toString();
    if (parentId == null || parentId.isEmpty) return propertySubTypes;

    return propertySubTypes.where((sub) {
      final ref1 = sub.reference1?.trim();
      return ref1 != null && ref1 == parentId;
    }).toList();
  }

  bool isLimitCaps = false;
  List<Customer>? limitCapsCustomerList = [];

  ///init method all api calls happen here and we get data from previous screen
  /// that is required here based on limit and limit type description
  Future<void> init(bool showCreateForm, {Facility? selectedFacility}) async {
    emit(state.copyWith(
      loaderStatus: LoadingStatus.loading,
      navigateToCreateFacility: LoadingStatus.loading, // NEW
    ));

    repository = FacilitySecurityRepository.instance;
    request = Globals.request ?? Request();
    showFacilityFi =
        Utils.checkBusinessSegment(BusinessSegment.financialInstitution);
    await getReferenceDatas();

    facility = selectedFacility ?? Facility();
    showCreateFacilityForm = showCreateForm;

    subLimit = facility.isMainLimit ?? false;
    if (showCreateFacilityForm &&
        facility.sharedLimit == null &&
        sharedLimits.isNotEmpty) {
      facility.sharedLimit = sharedLimits.first;
    }

    existingFacilityId = facility.facilityId ?? 43;
    rimNo = facility.rimNo ?? selectedFacility?.rimNo;
    parentControlliingNumber = selectedFacility?.limitNumber;
    limitGroup = facility.limitGroup;
    selectedRim = selectedFacility?.rimNo;
    parentProposedLimit =
        selectedFacility?.proposedLimit ?? facility.proposedLimit;

    if (parentProposedLimit != null && parentProposedLimit! > 0) {
      facility.proposedLimit = parentProposedLimit;
      facility.proposedLimitAED = parentProposedLimit; // keeps VM in sync
    }

    if (showCreateFacilityForm) {
      limitDescriptionController.text =
          selectedFacility?.facilityDescription!.name ?? "";
    }
    limitCategory = selectedFacility?.facilityDescription?.reference2;
    // Fee Table will be mandatory for these product codes
    mandatoryFeeTableRows = selectedFacility?.facilityDescription?.reference3;
    String code = (mandatoryFeeTableRows ?? '').trim().toUpperCase();
    if (code == 'LCM' || code == 'LST' || code == 'S-SCF' || code == 'B-SCF') {
      isFeeRowMandatory = true;
    }
    if (code == "CLT") {
      isLimitCaps = true;
    }
    selectedDescriptionId = selectedFacility?.facilityDescription?.id;
    final bool isSubLimit = subLimit ?? false;
    if (isSubLimit) {
      limitTypeController.text = "Main Limit";
    } else {
      limitTypeController.text = "Sub Limit";
    }
    ensureDefaultCountryOfRiskIfEmpty();
    enforceProjectFinanceRuleIfNeeded();
    await Future.wait([
      getCurrencyCodes(),
      getFacilitySubTypes(),
      getChildRimsForGroup(),
      getCountries(),
      getBorrowers(),
      getBorrowersMap(),
      getFacilityConditionsList(),
      getLimitsandFacilities(
          Globals.request?.groupOwner ?? Globals.request?.customerRimNo)
    ]);

    if (!showCreateFacilityForm) {
      await getFacilityDetails(existingFacilityId!, rimNo!);
      // Load dynamic form configuration for update flow
      await getDynamicForm(facility.facilityDescription?.id);
      await getProjectList(existingFacilityId);
    } else {
      await getDynamicForm(selectedDescriptionId);
      await getProjectList(null);
    }
    await setDynamicForm();
    emit(state.copyWith(
      loaderStatus: LoadingStatus.loaded,
      navigateToCreateFacility: LoadingStatus.loaded,
    ));

    // Initialize Excess Amount currency(Dynamic field) after form loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      syncExcessAmountCurrency();
    });
  }

  Future<void> setDynamicForm() async {
    DynamicFormState? form = dynamicFormKey.currentState;

    if (dynamicFormDocument.containsKey("repaymentTypeTawarrukPPC")) {
      if (dynamicFormDocument['repaymentTypeTawarrukPPC'] == "instalments") {
        form?.setFieldVisibility('instalments', true);
        form?.setFieldVisibility('bullet', false);
      } else if (dynamicFormDocument['repaymentTypeTawarrukPPC'] == "bullet") {
        form?.setFieldVisibility('instalments', false);
        form?.setFieldVisibility('bullet', true);
      }
    }

    if (dynamicFormDocument.containsKey("repaymentTypeTawarrukInvoice")) {
      if (dynamicFormDocument['repaymentTypeTawarrukInvoice'] ==
          "instalments") {
        form?.setFieldVisibility('instalments', true);
        form?.setFieldVisibility('bullet', false);
      } else if (dynamicFormDocument['repaymentTypeTawarrukInvoice'] ==
          "bullet") {
        form?.setFieldVisibility('instalments', false);
        form?.setFieldVisibility('bullet', true);
      }
    }

    if (dynamicFormDocument.containsKey('preShipment')) {
      form?.setFieldVisibility(
        'preShipmentAmount',
        dynamicFormDocument['preShipment'] == true,
      );
    }
    if (dynamicFormDocument.containsKey('postShipment')) {
      form?.setFieldVisibility(
        'postShipmentAmount',
        dynamicFormDocument['postShipment'] == true,
      );
    }
    if (dynamicFormDocument.containsKey('financeUnderLC')) {
      form?.setFieldVisibility(
        'financeUnderLCAmount',
        dynamicFormDocument['financeUnderLC'] == true,
      );
    }

    if (dynamicFormDocument.containsKey('financeAgainstCollection')) {
      form?.setFieldVisibility(
        'financeAgainstCollectionAmount',
        dynamicFormDocument['financeAgainstCollection'] == true,
      );
    }

// Overseas Shipment → overseasShipmentAmount
    if (dynamicFormDocument.containsKey('overseasShipment')) {
      form?.setFieldVisibility(
        'overseasShipmentAmount',
        dynamicFormDocument['overseasShipment'] == true,
      );
    }

    // Third Port Shipment → thirdPortShipmentAmount
    if (dynamicFormDocument.containsKey('thirdPortShipment')) {
      form?.setFieldVisibility(
        'thirdPortShipmentAmount',
        dynamicFormDocument['thirdPortShipment'] == true,
      );
    }

    // Local Delivery → localDeliveryAmount
    if (dynamicFormDocument.containsKey('localDelivery')) {
      form?.setFieldVisibility(
        'localDeliveryAmount',
        dynamicFormDocument['localDelivery'] == true,
      );
    }

    // Finance under LC → financeUnderLCAmount
    if (dynamicFormDocument.containsKey('financeUnderLC')) {
      form?.setFieldVisibility(
        'financeUnderLCAmount',
        dynamicFormDocument['financeUnderLC'] == true,
      );
    }

    // Finance against collection → financeAgainstCollectionAmount
    if (dynamicFormDocument.containsKey('financeAgainstCollection')) {
      form?.setFieldVisibility(
        'financeAgainstCollectionAmount',
        dynamicFormDocument['financeAgainstCollection'] == true,
      );
    }

    // Shipment by sea/Air → shipmentBySea/AirAmount
    if (dynamicFormDocument.containsKey('shipmentBySeaOrAir')) {
      form?.setFieldVisibility(
        'shipmentBySea/AirAmount',
        dynamicFormDocument['shipmentBySeaOrAir'] == true,
      );
    }

    // Shipment by Truck → shipmentByTruckAmount
    if (dynamicFormDocument.containsKey('shipmentByTruck')) {
      form?.setFieldVisibility(
        'shipmentByTruckAmount',
        dynamicFormDocument['shipmentByTruck'] == true,
      );
    }

    // Chartered Party/Bill of Lading → charteredBillLadingAmount
    if (dynamicFormDocument.containsKey('charterBillLading')) {
      form?.setFieldVisibility(
        'charteredBillLadingAmount',
        dynamicFormDocument['charterBillLading'] == true,
      );
    }

    // Master Promissory Note held →
    //   Use ONE of the following, depending on your form:

    // Variant A: it shows an Amount field
    if (dynamicFormDocument.containsKey('masterPromissoryNoteHeld')) {
      form?.setFieldVisibility(
        'masterPromissoryNoteHeldAmount',
        dynamicFormDocument['masterPromissoryNoteHeld'] == true,
      );
    }

    // Variant B: it shows a Number/ID field
    if (dynamicFormDocument.containsKey('masterPromissoryNoteHeld')) {
      form?.setFieldVisibility(
        'masterPromissoryNoteNumber',
        dynamicFormDocument['masterPromissoryNoteHeld'] == true,
      );
    }

    //
    bool selectedYes =
        _yesNoToBool(facility.selectedCollateralDepantantValue, false);
    form?.setFieldVisibility('extentOfFinance', selectedYes);
  }

  ///get child rim list for rim dropdown
  Future<void> getChildRimsForGroup() async {
    try {
      if (Utils.isGroupOwnerApplication()) {
        limitCapsCustomerList =
            (await CustomerRepository.instance.getChildRimsForGroup() ?? []);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Loads reference data required for dropdowns and selections in the form.
  ///
  /// Fetches data from [ReferenceDataService] and populates the corresponding lists.
  /// Emits a loaded state once data is retrieved.
  Future<void> getReferenceDatas() async {
    try {
      Map<String, List<Reference>> referenceData =
          await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.facilityTypes,
        ReferenceDataKeys.yesNoNa,
        ReferenceDataKeys.emirates,
        ReferenceDataKeys.seniority,
        ReferenceDataKeys.sector,
        ReferenceDataKeys.propertyType,
        ReferenceDataKeys.propertySubType,
        ReferenceDataKeys.sicCodeList,
        ReferenceDataKeys.advancePurposeCode,
        ReferenceDataKeys.advanceType,
        ReferenceDataKeys.regulatorySpecialisedLendingFinanceType,
        ReferenceDataKeys.limitType,
        ReferenceDataKeys.limitCapsType,
        ReferenceDataKeys.productType,
        ReferenceDataKeys.accountType,
        ReferenceDataKeys.policyDeviation,
        ReferenceDataKeys.sustanabilityClassification,
        ReferenceDataKeys.accountType,
        ReferenceDataKeys.facilityTypes,
        ReferenceDataKeys.facilityFeeTypes,
        ReferenceDataKeys.facilityTypesFeeFrequency,
        ReferenceDataKeys.period,
        ReferenceDataKeys.benchMark,
        ReferenceDataKeys.marginSign,
        ReferenceDataKeys.prupose
      ]);
      period = referenceData[ReferenceDataKeys.period] ?? [];
      benchmark = referenceData[ReferenceDataKeys.benchMark] ?? [];
      marginSign = referenceData[ReferenceDataKeys.marginSign] ?? [];
      facilityTypesFeeFrequency =
          referenceData[ReferenceDataKeys.facilityTypesFeeFrequency] ?? [];
      facilityFeeTypes =
          referenceData[ReferenceDataKeys.facilityFeeTypes] ?? [];
      facilityDescriptions =
          referenceData[ReferenceDataKeys.facilityTypes] ?? [];
      committedValues = (referenceData[ReferenceDataKeys.yesNoNa] ?? [])
          .where((data) => data.id != ServerConstants.optionNAid)
          .toList();
      propertySubTypes = referenceData[ReferenceDataKeys.propertySubType] ?? [];
      propertyTypes = referenceData[ReferenceDataKeys.propertyType] ?? [];
      sharedLimits = (referenceData[ReferenceDataKeys.yesNoNa] ?? [])
          .where((data) => data.id != ServerConstants.optionNAid)
          .toList()
        ..sort((a, b) {
          if (a.id == ServerConstants.optionNOid) return -1;
          if (b.id == ServerConstants.optionNOid) return 1;
          return 0;
        });
      accountTypes = referenceData[ReferenceDataKeys.accountType] ?? [];
      facilityTypes = referenceData[ReferenceDataKeys.facilityTypes] ?? [];
      emirates = referenceData[ReferenceDataKeys.emirates] ?? [];
      advanceTypes = referenceData[ReferenceDataKeys.advanceType] ?? [];
      productTypeItems =
          (referenceData[ReferenceDataKeys.productType] ?? [Reference()])
              .where((data) => data.id != ServerConstants.optionBothId)
              .toList();
      sustanabilityClassifications =
          referenceData[ReferenceDataKeys.sustanabilityClassification] ?? [];
      regulatorySpecialisedLandingOptions =
          (referenceData[ReferenceDataKeys.yesNoNa] ?? [])
              .where((data) => data.id != ServerConstants.optionNAid)
              .toList();
      promissoryNoteOptions = (referenceData[ReferenceDataKeys.yesNoNa] ?? [])
          .where((data) => data.id != ServerConstants.optionNAid)
          .toList();
      collateralDepantantoptions =
          (referenceData[ReferenceDataKeys.yesNoNa] ?? [])
              .where((data) => data.id != ServerConstants.optionNAid)
              .toList();
      projectFinanceRelatedActivityOptions =
          (referenceData[ReferenceDataKeys.yesNoNa] ?? [])
              .where((data) => data.id != ServerConstants.optionNAid)
              .toList();
      limitTypes = referenceData[ReferenceDataKeys.limitType] ?? [];
      limitCapsType = referenceData[ReferenceDataKeys.limitCapsType] ?? [];
      seniorities = referenceData[ReferenceDataKeys.seniority] ?? [];
      sectors = referenceData[ReferenceDataKeys.sector] ?? [];
      sicCodes = referenceData[ReferenceDataKeys.sicCodeList] ?? [];
      purposes = referenceData[ReferenceDataKeys.prupose] ?? [];
      regulatorySpecifications = referenceData[
              ReferenceDataKeys.regulatorySpecialisedLendingFinanceType] ??
          [];
      policyDeviations = referenceData[ReferenceDataKeys.policyDeviation] ?? [];
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  Future<void> getLimitsandFacilities(int? rimNo) async {
    try {
      limits = await repository.getLimitsandFacilities(rimNo);
      commitmentAccountNumberItems = limits
          .map((e) => e.commitmentAccountNumber)
          .whereType<String>() // remove nulls
          .map((s) => s.trim()) // remove leading/trailing spaces
          .where((s) => s.isNotEmpty) // remove empty strings
          .toSet() // remove duplicates
          .toList();

      final seen = <String>{};
      controllingLimitNumbers = limits
          .map((e) => e.controllingLimitNo)
          .whereType<String>()
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty && seen.add(s)) // unique by string value
          .map((s) => Reference(name: s))
          .toList();
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  Future<void> getFacilityDetails(int existingFacilityId, int rimNo) async {
    try {
      var result =
          await repository.getFacilityDetails(existingFacilityId, rimNo);
      facilityDetail = result["facilityDetails"] ?? [];
      feeDefualtRate = result["feeRates"] ?? [];

      List<Condition> allConditions = result["conditions"] ?? [];

      standardCondition = allConditions.where((c) => c.isStandard).toList();
      nonStandardCondition =
          allConditions.where((c) => c.isNonStandard).toList();

      initializeConditions(
          standardCondition.length, nonStandardCondition.length);

      // Parse and flatten additionalDetails for dynamic form
      if (facilityDetail.isNotEmpty) {
        dynamicFormDocument = facilityDetail.first.additionalDetails!;
        logger.i(dynamicFormDocument);
      }

      getExisitngFacilityData();
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  // True if the (raw) entered amount would exceed the parent limit after AED conversion.
  bool exceedsParentLimit(int enteredRaw) {
    final code = (selectedCurrencyCode ?? '').toUpperCase();
    final int enteredInAED =
        (code == ServerConstants.aedCurrency || exchangeRate == 0)
            ? enteredRaw
            : (enteredRaw * exchangeRate).round();
    return enteredInAED > parentLimitAED;
  }

  // Compose-friendly validator you can call from the field
  String? validateProposedLimit(String? value) {
    final cleaned = (value ?? '').replaceAll(',', '');
    final int entered = int.tryParse(cleaned) ?? 0;
    if (entered <= 0) return 'Please enter a valid amount';
    if (isSubLimitMode && exceedsParentLimit(entered)) {
      final nf = NumberFormat('#,###');
      final maxAEDStr = nf.format(parentLimitAED);
      return 'Proposed limit cannot exceed parent limit ($maxAEDStr AED)';
    }
    return null;
  }

  void setControllingLimitByAccount(String? accNoRaw) {
    final accNo = accNoRaw?.trim();
    if (accNo == null || accNo.isEmpty) return;

    final match = limits.firstWhere(
      (e) => (e.commitmentAccountNumber ?? '').trim() == accNo,
      orElse: () => const LimitsResponse(), // empty object if not found
    );
    final cln = match.controllingLimitNo?.trim();
    facility.controllingLimitNumber = (cln?.isNotEmpty ?? false) ? cln : null;

    if ((cln?.isNotEmpty ?? false)) {
      final exists = controllingLimitNumbers.any(
        (r) => (r.name ?? '').trim() == cln,
      );
      if (!exists) {
        controllingLimitNumbers.add(Reference(name: cln));
      }
    }

    final currency = match.limitCurrency?.trim();
    final past = match.pastDues;
    if ((currency?.isNotEmpty ?? false) || past != null) {
      final ref = facility.pastDues ?? Reference();
      ref.name = currency ?? ref.name; // currency code (e.g., "AED")
      ref.description = past?.toString() ?? ref.description; // amount as string
      facility.pastDues = ref;
    }
    final outstandingAmount = match.outstandingAmount;
    if ((currency?.isNotEmpty ?? false) || past != null) {
      final ref = facility.outstandingAmount ?? Reference();
      ref.description =
          outstandingAmount?.toString() ?? ref.description; // amount as string
      facility.outstandingAmount = ref;
    }
    final limitAmount = match.limitAmount;
    if ((currency?.isNotEmpty ?? false) || past != null) {
      final ref = facility.limitAmount ?? Reference();
      ref.description =
          limitAmount?.toString() ?? ref.description; // amount as string
      facility.limitAmount = ref;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> setCommitementAccountNumber(String? accNoRaw, int index) async {
    String? accNo = accNoRaw?.trim();
    if (accNo == null || accNo.isEmpty) return;

    LimitsResponse match = limits.firstWhere(
      (e) => (e.commitmentAccountNumber ?? '').trim() == accNo,
      orElse: () => const LimitsResponse(), // empty object if not found
    );
    String? cln = match.controllingLimitNo?.trim();
    facility.controllingLimitNumber = (cln?.isNotEmpty ?? false) ? cln : null;

    if ((cln?.isNotEmpty ?? false)) {
      bool exists = controllingLimitNumbers.any(
        (r) => (r.name ?? '').trim() == cln,
      );
      if (!exists) {
        controllingLimitNumbers.add(Reference(name: cln));
      }
    }

    // String? currency = match.limitCurrency?.trim();

    facilitySubTypes[index].pastDues = int.tryParse(match.pastDues.toString());
    facilitySubTypes[index].currentOutstanding =
        int.tryParse(match.outstandingAmount.toString());
    facilitySubTypes[index].existingAmounts =
        int.tryParse(match.limitAmount.toString());
    facilitySubTypes[index].commitmentAccountNumber = accNo;
    await Future.delayed(const Duration(milliseconds: 1000));
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

// model.dart (CreateFacilityViewModel) — add a guard flag
  bool _proposedLimitWarningShown = false;

// Only trigger alert the first time the value exceeds the parent limit.
// Reset the flag when user goes back within the limit.
  bool shouldShowProposedLimitExceedAlert(int enteredRaw) {
    final bool exceeds =
        exceedsParentLimit(enteredRaw); // you already have this
    if (exceeds) {
      if (!_proposedLimitWarningShown) {
        _proposedLimitWarningShown = true;
        return true; // <-- tell UI to show alert ONCE
      }
      return false; // already shown; don't spam
    } else {
      _proposedLimitWarningShown =
          false; // back under cap; allow next exceed to warn again
      return false;
    }
  }

  void onProductTypeSelected(Reference selected) {
    selectedProductType = selected;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> facilityTypeDescriptionsSelected(Reference selectedValue) async {
    facility.facilityDescription = selectedValue;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  //get multiple borrowers in borrower field
  Future<void> getBorrowersMap() async {
    try {
      final BorrowersMap map = await repository.getBorrowersMap();
      borrowersMap = (map.responseData).map((s) => Reference(name: s)).toList();
      if (borrowersByRimInTable.isNotEmpty) {
        final names = borrowersMap.map((r) => (r.name ?? '').trim()).toSet();
        borrowersByRimInTable = borrowersByRimInTable
            .where((sel) => names.contains((sel.name ?? '').trim()))
            .toList();
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  //borrower field data to get borrower rim
  Future<void> getBorrowers() async {
    try {
      borrowers = await repository.getBorrowers();
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  //getExchange rate of currency accoriding the selected country
  Future<void> getCurrencyRates(Reference? selectedCurrency) async {
    try {
      CurrencyRates currencyRates = await FacilitySecurityRepository.instance
          .getCurrencyRates(selectedCurrency);

      exchangeRate = currencyRates.rates[selectedCurrency?.name] ?? 0;
      final amount = facility.proposedLimit ?? 0;
      final convertedValue = amount * exchangeRate;
      final formatter = NumberFormat('#,###');
      final formattedAED = formatter.format(convertedValue.toInt());
      newProposedFacilityAmountController.value = TextEditingValue(
        text: formattedAED,
        selection: TextSelection.collapsed(offset: formattedAED.length),
      );
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  //limit type field dropdown
  void setLimitTypeByLabel(String picked) {
    bool isMain = picked.trim().toLowerCase() == 'main limit'.toLowerCase();
    subLimit = isMain;
    facility.isMainLimit = isMain;
    if (isMain) {
      facility.controllingLimitNumber = null;
    } else {
      facility.controllingLimitNumber ??= parentControlliingNumber;
    }
    limitTypeController.text = isMain ? 'Main Limit' : 'Sub Limit';
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // Called by the radio's onChanged
  void onProjectFinanceChanged(Reference value) {
    facility.selectedProjectFinanceRelatedActivityValue = value;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // Ensure the rule is applied once data (including options) is available
  void enforceProjectFinanceRuleIfNeeded() {
    if (!isProjectFinanceActivityEnabled) {
      facility.selectedProjectFinanceRelatedActivityValue = _pfRefByName('no');
    } else {
      facility.selectedProjectFinanceRelatedActivityValue ??=
          _pfRefByName('yes');
    }
  }

  void onCurrencyChanged(Reference? ref) {
    selectedCurrencyCode = (ref?.name ?? ref?.name)?.toUpperCase();
    bool isAed = selectedCurrencyCode == ServerConstants.aedCurrency;
    showProposedSecurityAmount = !isAed;
    showProposedSecurityAmount = !isAed;
    disableFxRates = !isAed;
    syncExcessAmountCurrency();
    _proposedLimitWarningShown = false;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Syncs Excess Amount currency and value with Proposed Limit.
  /// This ensures the Excess Amount field always uses the same currency
  /// and amount as the Proposed Limit field.
  void syncExcessAmountCurrency() {
    DynamicFormState? form = dynamicFormKey.currentState;
    if (form == null) return;
    String proposedCurrency = facility.proposedLimitValue?.name ??
        selectedCurrencyCode ??
        ServerConstants.aedCurrency;

    form.updateFieldValue('excessAmount', {
      'fromCurrency': proposedCurrency,
      'fromVal': null,
      'aedEquivalent': null,
    });
  }

  void changeBorrower(Borrower? selected) {
    if (selected == null) return;
    facility.rimNo = selected.customerRimNo; // used by save
    selectedRim = selected.customerRimNo; // keeps your existing fallback
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Fetches the dynamic form sections for facilities from the repository.
  /// Updates the `sections` variable with the retrieved data.
  /// Emits an error state if the fetch fails
  Future<void> getDynamicForm(int? selectedDescriptionId) async {
    try {
      sections = await repository.getFacilitiesDynamicForm(
          typeID: ServerConstants.dynamicFormFacilityID,
          subTypeID: selectedDescriptionId);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  Future<void> getFacilityConditionsList() async {
    try {
      conditions = await repository.getFacilityConditionsList(
        const FacilityConditionsFilter(
          condition: 'CONTRACTING-STANDARD_CONDITIONS',
          limitGroup: 'Project Standby Limit',
          limitDesc: 'NA',
          limitCode: 'All',
          limitType: 'Main limit',
        ),
      );
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Retrieves project details from the `ProjectRepository` and extracts
  /// project names from the contract list.
  Future<void> getProjectList(int? existingFacilityId) async {
    try {
      ProjectListResponse list =
          await repository.getProjectList(existingFacilityId);
      projectNames =
          list.responseData.map((name) => Reference(name: name)).toList();
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  Future<void> getCurrencyCodes() async {
    try {
      currencyCodes = await repository.getcurrencyCode();
      currencyCodes.sort((a, b) {
        bool aIsAed =
            (a.name ?? '').toUpperCase() == ServerConstants.aedCurrency;
        bool bIsAed =
            (b.name ?? '').toUpperCase() == ServerConstants.aedCurrency;
        return (bIsAed ? 1 : 0) - (aIsAed ? 1 : 0);
      });
      Reference aed = currencyCodes.firstWhere(
        (r) => (r.name ?? r.name)?.toUpperCase() == ServerConstants.aedCurrency,
        orElse: () =>
            currencyCodes.isNotEmpty ? currencyCodes.first : Reference(),
      );

      final String aedCode = aed.name ?? ServerConstants.aedCurrency;
      facilityDetails.currency ??= aedCode;
      selectedCurrencyCode = (facilityDetails.currency
          // ?? security.proposedSecurityAmtCurrency?.name
          )
          ?.toUpperCase();

      bool isAed = selectedCurrencyCode == ServerConstants.aedCurrency;
      showProposedSecurityAmount = !isAed;
      disableFxRates = !isAed;
      Globals.dynamicFormCurrencyCodes = currencyCodes
          .map((ref) =>
              Option(key: ref.id.toString(), pairValue: ref.name ?? ''))
          .toList();
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  Future<void> getFacilitySubTypes() async {
    facilitySubTypes = facilityTypes
        .where((factyType) {
          String? ref3 = facility.facilityDescription?.reference3?.trim();
          String? ref5 = factyType.reference5?.trim();
          return ref3 != null &&
              ref3.isNotEmpty &&
              ref5 != null &&
              ref5.isNotEmpty &&
              ref5 == ref3;
        })
        .map((factyType) => FacilitySubTypes(
              subType: factyType.name,
              subTypeSelected: false,
            ))
        .toList();
  }

  Future<void> getCountries() async {
    try {
      countryList = await CustomerRepository.instance.getCountries();
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  //for single borrower credit application limit caps facility type
  Future<bool> saveSingleBorrowerLimitCaps(bool navigateToHomePage) async {
    try {
      emit(state.copyWith(isButtonLoading: true));
      final isValid = formKey.currentState?.validate() ?? false;
      if (!isValid) {
        AlertManager().showFailureToast(
            "requestInformation.requestInformation.requiredFeild".tr());
        emit(state.copyWith(isButtonLoading: false));
        return false;
      }
      formKey.currentState?.save();
      facility.appRefNo = Globals.request?.applicationRefNo;
      facility.rimNo = facility.rimNo;
      facility.additionalDetails = dynamicFormDocument.toString();
      final LimitsFacilityResponse resp =
          await repository.saveFacilityDetailsNewSingleBorrower(
        facilityDetails: _buildSingleBorrowerSave(),
      );
      facility.limitNumber =
          resp.facilityDetails?.limitNo ?? facility.limitNumber;
      emit(state.copyWith(isButtonLoading: false));
      AlertManager().showSuccessToast('Saved successfully');
      router.go(Routes.facilitySummaryView);
      isApiError = false;
      return true;
    } catch (message) {
      isApiError = false;
      AlertManager().showFailureToast(message.toString());
      emit(state.copyWith(isButtonLoading: false));
      return false;
    }
  }

  FacilityDetails _buildSingleBorrowerSave() {
    final String appRef = _strOr(
        Globals.request?.applicationRefNo, "202512FULLNW000625"); // “appRefNo”
    final int rim =
        _numOr(facility.rimNo, selectedRim ?? 1263989).toInt(); // “rimNo”
    final int grp = _numOr(Globals.request?.groupId, 0).toInt(); // “groupId”
    const String product = "CLT"; // “productCode”
    const String islamic = "Yes"; // “forIslamic”
    final num limitDesc = _numOr(
      (facility.facilityDescription?.id is num)
          ? (facility.facilityDescription?.id as num?)
          : num.tryParse(facility.facilityDescription?.id?.toString() ?? ''),
      25,
    ); // “limitDescription”
    final int presentOutstanding =
        int.tryParse(facility.outstandingAmount?.description ?? "") ??
            (facilityDetail.isNotEmpty
                ? (facilityDetail.first.presentOutstanding?.toInt() ?? 0)
                : 1333);
    final int presentLimit =
        int.tryParse(facility.limitAmount?.description ?? "") ??
            (facilityDetail.isNotEmpty
                ? (facilityDetail.first.presentLimit?.toInt() ?? 0)
                : 1111);
    final String currency = _strOr(selectedCurrencyCode, "USD"); // “currency””
    final int proposedLimit =
        _numOr(facility.proposedLimit, 1123).toInt(); // “proposedLimit”
    final int proposedByCc =
        _numOr(facilityDetails.proposedByCc, 2332).toInt(); // “proposedByCc”
    final bool isMain = _boolOr(subLimit, true); // “isMainLimit”
    final String groupName = _strOr(
        "A - ABC Road Project", "A - ABC Road Project"); // “limitGroupName”
    final int group = _numOr(limitGroup, 14507).toInt(); // “limitGroup”
    final int capType =
        _numOr(facilityDetails.limitCapType, 14494).toInt(); // “limitCapType”

    return FacilityDetails(
      rimNo: rim,
      groupId: grp,
      productCode: product,
      appRefNo: appRef,
      forIslamic: islamic,
      limitDescription: limitDesc,
      limitCategory:
          (limitCategory ?? '').trim().toUpperCase(), //"reference2": "N",
      presentOutstanding: presentOutstanding,
      currency: currency,
      isSharedLimit: false,
      presentLimit: presentLimit,
      proposedLimit: proposedLimit,
      proposedByCc: proposedByCc,
      isMainLimit: isMain,
      limitGroupName: groupName,
      limitGroup: group,
      limitCapType: capType,
    );
  }

  //for Group borrower credit application limit caps facility type
  Future<bool> saveGroupBorrowerLimitCaps(bool navigateToHomePage) async {
    try {
      emit(state.copyWith(isButtonLoading: true));
      bool isValid = formKey.currentState?.validate() ?? false;
      if (!isValid) {
        AlertManager().showFailureToast(
            "requestInformation.requestInformation.requiredFeild".tr());
        emit(state.copyWith(isButtonLoading: false));
        return false;
      }
      formKey.currentState?.save();
      facility.appRefNo = Globals.request?.applicationRefNo;
      facility.rimNo = facility.rimNo;
      facility.additionalDetails = dynamicFormDocument.toString();
      final LimitsFacilityResponse resp =
          await repository.saveFacilityDetailsNewGroupBorrower(
        facilityDetails:
            _buildSingleBorrowerSave(), // make it set the same fields as single, but with proper groupId
        facilityBorrowerMap:
            _buildCompanyBorrowerMapForSave(), // NEW: builds companyBorrowerList shape
      );
      facility.limitNumber =
          resp.facilityDetails?.limitNo ?? facility.limitNumber;
      emit(state.copyWith(isButtonLoading: false));
      AlertManager().showSuccessToast('Saved successfully');
      router.go(Routes.facilitySummaryView);
      isApiError = false;
      return true;
    } catch (message) {
      isApiError = false;
      AlertManager().showFailureToast(message.toString());
      emit(state.copyWith(isButtonLoading: false));
      return false;
    }
  }

  FacilityBorrowerMap _buildCompanyBorrowerMapForSave() {
    List<Map<String, Object>> companyBorrowerList =
        borrowersByRimInTable.map((ref) {
      return {
        'id': {
          'borrowerRimNo':
              (ref.id ?? '').toString(), // ensure string per your sample
        },
        'limitAllocationAmount': int.tryParse(ref.description ?? '') ?? 0,
        'presentLimitAllocation': 0, // set from your VM if needed
        'originalLimitAllocation': 0, // set from your VM if needed
      };
    }).toList();

    return FacilityBorrowerMap(companyBorrowerList: companyBorrowerList);
  }

  //for limits expcept credit application limit caps facility type
  Future<bool> saveContinueOnPressed(bool navigateToHomePage) async {
    try {
      emit(state.copyWith(isButtonLoading: true));
      bool isValid = formKey.currentState?.validate() ?? false;
      if (!isValid) {
        AlertManager().showFailureToast(
            "requestInformation.requestInformation.requiredFeild".tr());
        emit(state.copyWith(isButtonLoading: false));
        return false;
      }
      formKey.currentState?.save();
      facility.appRefNo = Globals.request?.applicationRefNo;
      facility.rimNo = facility.rimNo;
      facility.additionalDetails = dynamicFormDocument.toString();
      final LimitsFacilityResponse resp =
          await repository.saveFacilityDetailsNew(
        facilityDetails: _buildFacilityDetailsForSave(),
        facilityBorrowerMap: _buildFacilityBorrowerMapForSave(),
        defacultFeeRates: feeDefualtRate,
        sections: sections,
      );
      facility.limitNumber =
          resp.facilityDetails?.limitNo ?? facility.limitNumber;
      emit(state.copyWith(isButtonLoading: false));
      facilitySubTypes.clear();
      AlertManager().showSuccessToast('Saved successfully');
      router.go(Routes.facilitySummaryView);
      isApiError = false;
      return true;
    } catch (message) {
      isApiError = false;
      AlertManager().showFailureToast(message.toString());
      emit(state.copyWith(isButtonLoading: false));
      return false;
    }
  }

  FacilityDetails _buildFacilityDetailsForSave() {
    String code = (mandatoryFeeTableRows ?? '').trim().toUpperCase();

    final bool hasPeriod =
        (facility.limitAvailabilityPeriod?.trim().isNotEmpty ?? false);

    final String? limitAvailIso = hasPeriod
        ? null
        : facility.limitAvailabilityDate?.toUtc().toIso8601String();

    return FacilityDetails(
      isMainLimit: _boolOr(subLimit, true),
      controllingLimitNo: showCreateFacilityForm && subLimit!
          ? null
          : (!_boolOr(subLimit, true)
              ? (parentControlliingNumber?.isNotEmpty == true
                  ? parentControlliingNumber // already a String?
                  : null)
              : null),
      facilityId: showCreateFacilityForm
          ? null
          : num.tryParse(facility.facilityId?.toString() ?? '43') ?? 43,
      limitNo: showCreateFacilityForm ? null : (facilityDetail.first.limitNo),
      limitCategory:
          (limitCategory ?? '').trim().toUpperCase(), //"reference2": "N",
      isCommitted: _yesNoToBool(facility.committedValues, false),
      commitmentAccountNumber:
          (facility.commitmentAccountNumber?.id?.toString() ??
              facility.commitmentAccountNumber?.name ??
              "1002295820"),
      rimNo: _numOr(facility.rimNo, selectedRim!),
      groupId: _numOr(Globals.request?.groupId, 66),
      appRefNo: _strOr(Globals.request?.applicationRefNo, ""),
      productCode: _strOr(code, 'ODAS'),
      limitDescription: _numOr(
        (facility.facilityDescription?.id is num)
            ? (facility.facilityDescription?.id as num?)
            : num.tryParse(facility.facilityDescription?.id?.toString() ?? ''),
        25,
      ),
      facilityTitle: _strOr(facility.facilityTitle, ''),
      currency: _strOr("AED", 'AED'),
      forIslamic: _strOr(facility.selectedProductTypeValue?.name, 'Yes'),
      sustainabilityClassification:
          _strOr(sustainabilityClassificationCsv, '11318, 11319'),
      advanceType: _numOr(facility.advanceTypeValue?.id, 232),
      seniority: _numOr(facility.seniorityValue?.id, 232),
      sectorDescription: _numOr(facility.sector?.id, 356),
      proposedLimit: _numOr(facility.proposedLimit, 1123),
      proposedLimitAED: _numOr(facility.proposedLimitAED, 1123),
      presentLimit:
          _numOr(int.tryParse(facility.limitAmount?.description ?? ''), 0),
      originalLimit:
          _numOr(int.tryParse(facility.limitAmount?.description ?? ''), 0),
      pastDues: _numOr(int.tryParse(facility.pastDues?.description ?? ''), 0),
      presentOutstanding: _numOr(
          int.tryParse(facility.outstandingAmount?.description ?? ''), 0),

      limitAvailabilityDate: limitAvailIso, // <-- String? (ISO)
      limitAvailabilityPeriod:
          hasPeriod ? facility.limitAvailabilityPeriod?.trim() : null,

      isProjectFinActivity: _yesNoToBool(
          facility.selectedProjectFinanceRelatedActivityValue, false),
      projectName: _strOr(
          facility.projectName?.name, 'PRJ001 - New Construction Project'),
      purpose: _numOr(facility.purposeValue?.id, 11353),
      propertyType: _numOr(facility.propertyType?.id, 1832),
      propertySubType: _numOr(facility.propertySubType?.id, 1819),
      emirates: _numOr(facility.emirates?.id, 11370),
      isRegulatorySpecialisedLending: _yesNoToBool(
          facility.selectedRegulatorySpecialisedLandingValue, false),
      regulatorySpecialisedLendingFinanceType:
          _numOr(facility.selectedRegulatorySpecialisedLandingValue?.id, 263),
      countryOfRisk: _strOr(
          facility.selectedCountry?.description ?? facility.countryOfRisk,
          'Tunisia'),
      sicCode: _numOr(facility.sicCode?.id, 361),
      isSharedLimit: _yesNoToBool(facility.sharedLimit, false),
      isCrossBoarderCorporateExposure:
          _boolOr(facility.isCrossBoarderExposure, false),
      accountType:
          _strOr(facility.accountTypeValue?.id?.toString(), '1644,1645'),
      promissoryNoteTaken:
          _numOr(facility.selectedpromissoryNoteValue?.id, 112),
      isCollateralDependent:
          _yesNoToBool(facility.selectedCollateralDepantantValue, false),
      limitGroupName: _strOr("A - ABC Road Project", 'A - ABC Road Project'),
      limitGroup: _numOr(limitGroup, 11315),
      limitCapType: _numOr(14494, 14494),
      additionalDetails: dynamicFormDocument,
    );
  }

  FacilityBorrowerMap _buildFacilityBorrowerMapForSave() {
    final baseFacilityId =
        int.tryParse(facility.facilityId?.toString() ?? '43') ?? 32800;
    final borrowerList = borrowersByRimInTable.map((ref) {
      return {
        'id': {
          'facilityId': baseFacilityId,
          'borrowerRimNo': ref.id,
        },
        'limitAllocationAmount': int.tryParse(ref.description ?? '') ?? 0,
        if ((facility.limitNumber ?? '').isNotEmpty)
          'subLimitNo': facility.limitNumber,
      };
    }).toList();
    return FacilityBorrowerMap(borrowerList: borrowerList);
  }

  String _strOr(String? value, String fallback) {
    final v = value?.trim();
    return (v == null || v.isEmpty) ? fallback : v;
  }

  num _numOr(num? value, num fallback) => value ?? fallback;

  bool _boolOr(bool? value, bool fallback) => value ?? fallback;

  bool _yesNoToBool(Reference? ref, bool fallback) {
    final name = ref?.name?.trim().toLowerCase();
    if (name == 'yes') return true;
    if (name == 'no') return false;
    return fallback;
  }

  void changeCommitted(Reference? selectedValue) {
    facility.committedValues = selectedValue;
    try {
      facility.isCommitted = _yesNoToBool(selectedValue, false);
    } catch (_) {}
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void cancelOnPressed() {
    router.go(Routes.home);
  }

  void changeRegulatorySpecialisedLanding(Reference? selecctedValue) {
    facility.selectedRegulatorySpecialisedLandingValue = selecctedValue;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changePromissoryNote(Reference? selecctedValue) {
    facility.selectedpromissoryNoteValue = selecctedValue;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeProjectFinanceRelatedActivity(Reference? selecctedValue) {
    facility.selectedProjectFinanceRelatedActivityValue = selecctedValue;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeCollateralDependant(Reference? selecctedValue) {
    facility.selectedCollateralDepantantValue = selecctedValue;
    bool selectedYes = _yesNoToBool(selecctedValue, false);
    //extentOfFinance
    dynamicFormKey.currentState
        ?.setFieldMandatory('extentOfFinance', selectedYes);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changProductType(Reference? selecctedValue) {
    facility.selectedProductTypeValue = selecctedValue;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeConditionsStandard(bool value) {
    facility.isConditionsStandard = value;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeCrossBoarderExposure(bool value) {
    facility.isCrossBoarderExposure = value;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void selectLimittedGroup(Reference selectedValue) {
    facility.facilityTypeSelectedValue = selectedValue;
    subTypeID = selectedValue.id;
    facilityTypes.map((e) {
      if (selectedValue.reference4 == e.reference4) {
        facilityDescriptions.add(e);
      }
    }).toList();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void selectSharedLimit(Reference selectedValue) {
    facility.sharedLimit = selectedValue;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onPropertyTypeSelected(List<Reference> selected) {
    if (selected.isNotEmpty) {
      facility.propertyType = selected.first;
      String? parentId = facility.propertyType?.id?.toString();
      Reference? currentSub = facility.propertySubType;
      if (currentSub != null && (currentSub.reference1?.trim() != parentId)) {
        facility.propertySubType = null;
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  // Called by FacilityProjectName.onSelected
  void onProjectNameSelected(List<Reference> selected) {
    if (selected.isNotEmpty) {
      facility.projectName = selected.first;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  // Keep property sub type selection logic here
  void onPropertySubTypeSelected(List<Reference> selected) {
    if (selected.isNotEmpty) {
      facility.propertySubType = selected.first;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  void onPolicyDeviationSelected(List<Reference> selectedValue) {
    facility.policyDeviation = selectedValue;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void selectPurpose(Reference selectedValue) {
    facility.purposeValue = selectedValue;
    facility.purpose = selectedValue;
    bool isY = (selectedValue.reference1 ?? '').trim().toUpperCase() == 'Y';
    if (!isY) {
      facility.propertyType = null;
      facility.propertySubType = null;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void selectLimitType(Reference selectedValue) {
    facility.limitTypeValue = selectedValue;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void addFeeAndDefualtRate() {
    feeDefualtRate.add(FeeRate());
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void addNonStandardCondition() {
    nonStandardCondition.add(Condition());
    nonStandardConditionsSelected.add(false);
    actionsNonStandardAmendSelected.add(false);
    actionsNonStandardWaiveOffSelected.add(false);
    isNewlyAddedNonStandardCondition.add(true); // for newly added condition
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void initializeConditions(int stdcount, int nonStdCount) {
    standardConditionsSelected = List<bool>.generate(stdcount, (_) => true);
    actionsStandardAmendSelected = List<bool>.generate(
        stdcount, (i) => standardCondition[i].isAmended ?? false);
    actionsStandardWaiveOffSelected = List<bool>.generate(
        stdcount, (i) => standardCondition[i].isWaivedOff ?? false);

    // Non-standard conditions
    nonStandardConditionsSelected =
        List<bool>.generate(nonStdCount, (_) => true);
    actionsNonStandardAmendSelected = List<bool>.generate(
        nonStdCount, (i) => nonStandardCondition[i].isAmended ?? false);
    actionsNonStandardWaiveOffSelected = List<bool>.generate(
        nonStdCount, (i) => nonStandardCondition[i].isWaivedOff ?? false);
    isNewlyAddedNonStandardCondition =
        List<bool>.generate(nonStdCount, (_) => false);
  }

  void changeStandardConditionSelect(int index, bool value) {
    standardConditionsSelected[index] = value;
    if (value) {
      actionsStandardAmendSelected[index] = false;
      actionsStandardWaiveOffSelected[index] = false;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeAmendStandardConditionSelect(int index, bool value) {
    actionsStandardAmendSelected[index] = value;
    if (value) {
      standardConditionsSelected[index] = false;
      actionsStandardWaiveOffSelected[index] = false;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeWaivedOffStandardConditionSelect(int index, bool value) {
    actionsStandardWaiveOffSelected[index] = value;
    if (value) {
      actionsStandardAmendSelected[index] = false;
      standardConditionsSelected[index] = false;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeAmendNonStandardConditionSelect(int index, bool value) {
    actionsNonStandardAmendSelected[index] = value;
    if (value) {
      nonStandardConditionsSelected[index] = false;
      actionsNonStandardWaiveOffSelected[index] = false;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeWaivedOffNonStandardConditionSelect(int index, bool value) {
    actionsNonStandardWaiveOffSelected[index] = value;
    if (value) {
      nonStandardConditionsSelected[index] = false;
      actionsNonStandardAmendSelected[index] = false;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeNonStandardConditionSelect(int index, bool value) {
    nonStandardConditionsSelected[index] = value;
    if (value) {
      actionsNonStandardAmendSelected[index] = false;
      actionsNonStandardWaiveOffSelected[index] = false;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onBorrowerChipDeleted(int index) {
    borrowersByRimInTable.removeAt(index);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void addBorrowertoTable(List<Reference> selectedBorrowersByRims) {
    borrowersByRimInTable = selectedBorrowersByRims;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void addProposedLimit(String? proposedLimit) {
    facility.proposedLimit = int.tryParse(proposedLimit ?? "0");
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void compareAllocationAmount(String allocationAmount, Reference borrower) {
    final int proposedLimit = effectiveProposedLimit;
    borrower.description = allocationAmount;
    final int entered = int.tryParse(allocationAmount.replaceAll(',', '')) ?? 0;
    final int otherTotal = borrowersByRimInTable
        .where((b) => !identical(b, borrower))
        .map(
            (b) => int.tryParse((b.description ?? '').replaceAll(',', '')) ?? 0)
        .fold(0, (sum, x) => sum + x);

    final int newTotal = otherTotal + entered;
    final bool exceedsSingle = entered > proposedLimit;
    final bool exceedsTotal = newTotal > proposedLimit;

    if (exceedsSingle || exceedsTotal) {
      if (!_allocationWarningShown) {
        _allocationWarningShown = true;
        AlertManager().showWarningToast(
          "facilities.createFacility.allocationAmountErrorText".tr(),
        );
      }
      borrower.description = null; // revert invalid entry
    } else {
      _allocationWarningShown = false;
    }
  }

  bool get isUAECountryOfRisk {
    final effective =
        (facility.selectedCountry?.description ?? facility.countryOfRisk ?? '')
            .trim()
            .toLowerCase();
    return effective == _uaeName;
  }

  void onCountryOfRiskSelected(Country picked) {
    facility.selectedCountry = picked;
    facility.countryOfRisk = picked.description;

    // If UAE, uncheck and emit
    if (isUAECountryOfRisk) {
      changeCrossBoarderExposure(false);
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void ensureDefaultCountryOfRiskIfEmpty() {
    final hasApi = (facility.countryOfRisk != null &&
        facility.countryOfRisk!.trim().isNotEmpty);
    final hasSelected =
        (facility.selectedCountry?.description?.trim().isNotEmpty ?? false);

    // If something is already set, just enforce the UAE rule and exit
    if (hasApi || hasSelected) {
      if (isUAECountryOfRisk) {
        changeCrossBoarderExposure(false);
      }
      // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return;
    }

    // Otherwise default to UAE from the loaded list
    final List<Country> list = countryList ?? [];
    final Country uae = list.firstWhere(
      (c) => (c.description ?? '').trim().toLowerCase() == _uaeName,
      orElse: () => Country(description: 'United Arab Emirates'),
    );

    facility.selectedCountry = uae;
    facility.countryOfRisk = uae.description;

    // Disable (uncheck) cross-border exposure for UAE
    changeCrossBoarderExposure(false);
    // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void selectSector(Reference? selectedValue) {
    facility.sector = selectedValue;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void deleteFeeDetails({int? feeID}) {
    try {
      AlertManager().showSuccessToast("Selected Fee Deleted");
    } catch (e) {
      debugPrint(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeSubtypes(bool subTypeSelected, FacilitySubTypes facilitySubType) {
    facilitySubType.subTypeSelected = subTypeSelected;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  ///get data from api based on facility id with
  /// existing facilities inside summary list
  void getExisitngFacilityData() {
    // --- Limit Availability (Period vs Date) from GET ---
    if (facilityDetail.isNotEmpty) {
      final String apiLimitPeriod =
          facilityDetail.first.limitAvailabilityPeriod;
      final DateTime? apiLimitDate = facilityDetail.first.limitAvailabilityDate;

      if ((apiLimitPeriod.trim().isNotEmpty)) {
        // Prefer period: set period, clear date
        facility.limitAvailabilityPeriod = apiLimitPeriod.trim();
        facility.limitAvailabilityDate = null;
      } else if (apiLimitDate != null) {
        // Set date (UTC for consistency), clear period
        facility.limitAvailabilityDate = apiLimitDate.toUtc();
        facility.limitAvailabilityPeriod = null;
      } else {
        facility.limitAvailabilityPeriod = null;
        facility.limitAvailabilityDate = null;
      }
    }

    if (facilityDetail.isNotEmpty) {
      final String code =
          (facilityDetail.first.productCode ?? '').trim().toUpperCase();
      isLimitCaps = (code == 'CLT'); // robust for "clt", " CLT ", etc.
    }

    if (facilityDetail.isNotEmpty) {
      final num? apiValue = facilityDetail.first.proposedLimit;
      facility.proposedLimit = (apiValue ?? 0).toInt();
      proposedLimitController.text = (apiValue ?? 0).toString();
    }

    if (facilityDetail.isNotEmpty) {
      final curr = facilityDetail.first.currency;
      final past = facilityDetail.first.pastDues;

      if ((curr).isNotEmpty || past != null) {
        final ref = facility.pastDues ?? Reference();
        ref.name = curr;
        ref.description = past?.toString();
        facility.pastDues = ref;
      }
    }

    if (facilityDetail.isNotEmpty) {
      if (facilityDetail.first.policyDeviation != null) {
        facility.policyDeviation = facilityDetail.first.policyDeviation;
      }
    }

    if (facilityDetail.isNotEmpty && facilityDescriptions.isNotEmpty) {
      final match = facilityDescriptions.firstWhere(
        (e) =>
            e.id?.toString() ==
            facilityDetail.first.limitDescription.toString(),
        orElse: () => Reference(name: ''),
      );
      facility.facilityDescription = match;
    }

    if (facilityDetail.isNotEmpty && advanceTypes.isNotEmpty) {
      final advMatch = advanceTypes.firstWhere(
        (e) => e.id?.toString() == facilityDetail.first.advanceType.toString(),
        orElse: () => Reference(name: ''),
      );
      facility.advanceTypeValue = advMatch;
    }
    if (facilityDetail.isNotEmpty && seniorities.isNotEmpty) {
      final advMatch = seniorities.firstWhere(
        (e) => e.id?.toString() == facilityDetail.first.seniority.toString(),
        orElse: () => Reference(name: ''),
      );
      facility.seniorityValue = advMatch;
    }

    if (facilityDetail.isNotEmpty && sicCodes.isNotEmpty) {
      final advMatch = sicCodes.firstWhere(
        (e) => e.id?.toString() == facilityDetail.first.sicCode.toString(),
        orElse: () => Reference(name: ''),
      );
      facility.sicCode = advMatch;
    }

    if (facilityDetail.isNotEmpty && sectors.isNotEmpty) {
      final advMatch = sectors.firstWhere(
        (e) =>
            e.id?.toString() ==
            facilityDetail.first.sectorDescription.toString(),
        orElse: () => Reference(name: ''),
      );
      facility.sector = advMatch;
    }

    if (facilityDetail.isNotEmpty && accountTypes.isNotEmpty) {
      final advMatch = accountTypes.firstWhere(
        (e) => e.id?.toString() == facilityDetail.first.accountType.toString(),
        orElse: () => Reference(name: ''),
      );
      facility.accountTypeValue = advMatch;
    }

    if (facilityDetail.isNotEmpty && purposes.isNotEmpty) {
      final advMatch = purposes.firstWhere(
        (e) => e.id?.toString() == facilityDetail.first.purpose.toString(),
        orElse: () => Reference(name: ''),
      );
      facility.purpose = advMatch;
    }

    if (facilityDetail.isNotEmpty && emirates.isNotEmpty) {
      final advMatch = emirates.firstWhere(
        (e) => e.id?.toString() == facilityDetail.first.emirates.toString(),
        orElse: () => Reference(name: ''),
      );
      facility.emirates = advMatch;
    }

    if (facilityDetail.isNotEmpty &&
        projectFinanceRelatedActivityOptions.isNotEmpty) {
      final bool? flag = facilityDetail.first.isProjectFinActivity;
      if (flag != null) {
        final Reference match = projectFinanceRelatedActivityOptions.firstWhere(
          (e) {
            final name = (e.name ?? '').trim().toLowerCase();
            return flag ? name == 'yes' : name == 'no';
          },
          orElse: () => Reference(name: ''),
        );

        facility.selectedProjectFinanceRelatedActivityValue = match;
      }
    }

    if (facilityDetail.isNotEmpty && sharedLimits.isNotEmpty) {
      final bool? flag = facilityDetail.first.isSharedLimit;
      if (flag != null) {
        final match = sharedLimits.firstWhere(
          (e) {
            final name = (e.name ?? '').trim().toLowerCase();
            return flag ? name == 'yes' : name == 'no';
          },
          orElse: () => Reference(name: ''),
        );

        facility.sharedLimit = match; // set the selected Reference
      }
    }

    if (facilityDetail.isNotEmpty && projectNames.isNotEmpty) {
      final String apiProjectName = facilityDetail.first.projectName.trim();
      if (apiProjectName.isNotEmpty) {
        final Reference match = projectNames.firstWhere(
          (r) =>
              (r.name ?? '').trim().toLowerCase() ==
              apiProjectName.toLowerCase(),
          orElse: () => Reference(
              name:
                  apiProjectName), // if not found in list, still show the API text
        );
        facility.projectName = match;
      } else {
        facility.projectName = null; // keep empty if API has no value
      }
    }

    if (facilityDetail.isNotEmpty && committedValues.isNotEmpty) {
      final bool? flag =
          facilityDetail.first.isCommitted; // assumes API provides it
      if (flag != null) {
        final Reference match = committedValues.firstWhere(
          (e) {
            final name = (e.name ?? '').trim().toLowerCase();
            return flag ? name == 'yes' : name == 'no';
          },
          orElse: () => Reference(name: ''),
        );
        facility.committedValues = match;
      }
    }

    final apiCountry = facility.countryOfRisk?.trim();
    if (apiCountry != null &&
        apiCountry.isNotEmpty &&
        (countryList?.isNotEmpty ?? false)) {
      final found = countryList!.firstWhere(
        (c) =>
            (c.description ?? '').trim().toLowerCase() ==
            apiCountry.toLowerCase(),
        orElse: () =>
            Country(description: apiCountry), // still show text if not in list
      );
      facility.selectedCountry = found;
    }

    emit(state.copyWith(
      loaderStatus: LoadingStatus.loaded,
      navigateToCreateFacility: LoadingStatus.loaded,
    ));
  }

  /// Searches for customer details by RIM number in grid with debouncing
  ///
  /// This method is debounced to prevent excessive API calls while the user is typing.
  /// It waits 500ms after the last keystroke before making the API call.
  ///
  /// Parameters:
  /// - [rimValue]: The RIM number to search for
  /// - [rowIndex]: The grid row index where the search was triggered
  Future<void> _searchCustomerByRimInGrid(
      String rimValue, int rowIndex, String gridName) async {
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
        final nameKey = '$gridName@$rowIndex';
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
    DynamicFormState? form = dynamicFormKey.currentState;

    switch (fieldKey) {
      case 'repaymentTypeTawarrukPPC' || 'repaymentTypeTawarrukInvoice':
        if (value.key == "instalments") {
          form?.setFieldVisibility('instalments', true);
          form?.setFieldVisibility('bullet', false);
        } else if (value.key == "bullet") {
          form?.setFieldVisibility('instalments', false);
          form?.setFieldVisibility('bullet', true);
        }
      case "shipmentBySeaOrAir":
        // If shipmentBySeaOrAir is true, show shipmentBySea/AirAmount field
        // If false, hide it
        bool isChecked = value == true;
        form?.setFieldVisibility('shipmentBySea/AirAmount', isChecked);
        break;
      case "shipmentByTruck":
        // If shipmentByTruck is true, show shipmentByTruckAmount field
        // If false, hide it
        bool isChecked = value == true;
        form?.setFieldVisibility('shipmentByTruckAmount', isChecked);
        break;
      case "charterBillLading":
        // If charterBillLading is true, show charteredBillLadingAmount field
        // If false, hide it
        bool isChecked = value == true;
        form?.setFieldVisibility('charteredBillLadingAmount', isChecked);
        break;

      case "shipmentBySeaOrAir":
        form?.setFieldVisibility('shipmentBySea/AirAmount', value == true);
        break;

      // Shipment by Truck → shipmentByTruckAmount
      case "shipmentByTruck":
        form?.setFieldVisibility('shipmentByTruckAmount', value == true);
        break;

      // Chartered Party/Bill of Lading → charteredBillLadingAmount
      case "charterBillLading":
        form?.setFieldVisibility('charteredBillLadingAmount', value == true);
        break;

      // Third Port Shipment → thirdPortShipmentAmount
      case "thirdPortShipment":
        form?.setFieldVisibility('thirdPortShipmentAmount', value == true);
        break;

      // Overseas Shipment → overseasShipmentAmount
      case 'overseasShipment':
        form?.setFieldVisibility('overseasShipmentAmount', value == true);
        break;

      // Local Delivery → localDeliveryAmount
      case 'localDelivery':
        form?.setFieldVisibility('localDeliveryAmount', value == true);
        break;

      // Finance under LC → financeUnderLCAmount
      case 'financeUnderLC':
        form?.setFieldVisibility('financeUnderLCAmount', value == true);
        break;

      // Finance against collection → financeAgainstCollectionAmount
      case 'financeAgainstCollection':
        form?.setFieldVisibility(
            'financeAgainstCollectionAmount', value == true);
        break;

      // Master Promissory Note held →
      //   Use ONE of these depending on your UI:
      //   A) show amount field
      case 'masterPromissoryNoteHeld':
        form?.setFieldVisibility(
            'masterPromissoryNoteHeldAmount', value == true);
        //   B) or show a number/ID input instead:
        form?.setFieldVisibility('masterPromissoryNoteNumber', value == true);
        break;

      case ("lcMargin" || "avMargin"):
        // If lcMargin is "timeDeposits" (Time Deposits), show linkedAccountNumber field
        // Otherwise, hide it
        bool isTimeDeposit = value.key == "timeDeposits";
        form?.setFieldVisibility('linkedAccountNumber', isTimeDeposit);
        break;
      case "currency":
        // If "Others" is selected in Permitted Currency multiSelect, show otherCurrency field
        // Otherwise, hide it
        bool hasOthers = false;
        if (value is List) {
          hasOthers = value.contains("Others");
        }
        form?.setFieldVisibility('otherCurrency', hasOthers);
        break;
      case "payofcurrency":
        // If "Others" is selected in Payoff Currency multiSelect, show specifyofpayofcurrency field
        // Otherwise, hide it
        bool hasOthers = false;
        if (value is List) {
          hasOthers = value.contains("Others");
        }
        form?.setFieldVisibility('specifyofpayofcurrency', hasOthers);
        break;

      case "searchByName":
        if (value['value']) {
          dynamicFormKey.currentState
              ?.setFieldEnabled('customerRimGrid', true, index: value['index']);
          dynamicFormKey.currentState
              ?.setFieldEnabled('customerName', false, index: value['index']);
        } else {
          dynamicFormKey.currentState?.setFieldEnabled('customerRimGrid', false,
              index: value['index']);
          dynamicFormKey.currentState
              ?.setFieldEnabled('customerName', true, index: value['index']);
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
          _customerSearchDebounceTimers[debounceKey] =
              Timer(const Duration(milliseconds: 500), () {
            String fieldToUpdate = switch (value['gridName'] as String?) {
              'heldInTheNameOf' => 'customerName',
              'depositHeldInTheNameOf' => 'customerName',
              _ => '',
            };

            _searchCustomerByRimInGrid(rimValue, rowIndex, fieldToUpdate);
          });
        }
        break;

      case 'preShipment':
        form?.setFieldVisibility('preShipmentAmount', value == true);
        break;

      case 'postShipment':
        form?.setFieldVisibility('postShipmentAmount', value == true);
        break;

      case 'financeUnderLC':
        form?.setFieldVisibility('financeUnderLCAmount', value == true);
        break;

      case 'financeAgainstCollection':
        form?.setFieldVisibility(
            'financeAgainstCollectionAmount', value == true);
        break;

      case 'overseasShipment':
        form?.setFieldVisibility('overseasShipmentAmount', value == true);
        break;

      case 'localDelivery':
        form?.setFieldVisibility('localDeliveryAmount', value == true);
        break;

      default:
        // No specific handling for this field
        break;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}
