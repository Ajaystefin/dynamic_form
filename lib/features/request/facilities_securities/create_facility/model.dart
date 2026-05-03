import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:wcas_frontend/core/components/dynamic_form/dynamic_form.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/grid_field.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/row_element.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/section.dart";
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
import "package:wcas_frontend/features/request/facilities_securities/create_facility/draft_handler.dart";
// import 'package:wcas_frontend/core/services/draft/draft_handler_base.dart';
// import 'draft_handler.dart';
import "package:wcas_frontend/features/request/facilities_securities/create_facility/state.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";
import "package:wcas_frontend/models/request/country.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/facility_security/borrower_facility.dart";
import "package:wcas_frontend/models/request/facility_security/exchange_rate.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";
import "package:wcas_frontend/models/request/facility_security/facility_condition_list.dart";
import "package:wcas_frontend/models/request/facility_security/facility_detail.dart";
import "package:wcas_frontend/models/request/facility_security/facility_summary_list.dart";
import "package:wcas_frontend/models/request/facility_security/limit_facilities.dart";
import "package:wcas_frontend/models/request/facility_security/limits_facilities_response.dart";
import "package:wcas_frontend/models/request/facility_security/project_list.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";
import "package:wcas_frontend/repositories/home_repository.dart";

class CreateFacilityViewModel extends SafeCubit<CreateFacilityState>
    with DraftMixin<CreateFacilityViewModel> {
  CreateFacilityViewModel()
      : super(CreateFacilityState(loaderStatus: LoadingStatus.loading));

  // --- DRAFT IDENTITY ---
  @override
  String get draftModuleKey => DraftModuleKeys.facilitiesAndSecurities;

  @override
  String get draftFormKey {
    if (!showCreateFacilityForm && existingFacilityId != null) {
      // Update flow — keyed by the specific existing facility
      return "${Routes.createFacility}_update_$existingFacilityId";
    }
    // Create flow — keyed by the facility description type selected
    final int? descId = getFacility.facilityDescription?.id;
    if (descId != null) {
      return "${Routes.createFacility}_create_desc_$descId";
    }
    return Routes.createFacility;
  }

  @override
  DraftHandler<CreateFacilityViewModel> get draftHandler =>
      CreateFacilityDraftHandler();

  /// Key for validating the main form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Repository for facility security-related operations.
  late FacilitySecurityRepository repository;

  /// Facility model being created or edited.
  Facility getFacility = Facility();

  bool presentOutStandingReadOnly = true;

  FacilityDetails facilityDetails = FacilityDetails();

  String? proposedCapRaw; // stores user's typed text (cleaned)
  bool proposedCapEdited = false; // true when user touches the cap field

  /// Key for validating the dynamic form section.
  GlobalKey<DynamicFormState> dynamicFormKey = GlobalKey<DynamicFormState>();

  /// Customer related operations Search take timer .
  final Map<String, Timer?> _customerSearchDebounceTimers = {};

  // Row-level error messages for the Group Borrower Limit Caps table
  final Map<int, String?> groupCapRowError = {};

  // Returns true if Group Level Cap dropdown is 'Yes'
  bool get isGroupCapRequired {
    return (getFacility.sharedLimit?.id == ServerConstants.optionYESid) ||
        ((getFacility.sharedLimit?.name ?? "").trim().toLowerCase() ==
            ServerConstants.yesText);
  }

  // Current cap value from ProposedCompanyCap (0 if null)
  int get groupCapValue => getFacility.proposedLimit ?? 0;

  /// Repository for Customer related operations.
  CustomerRepository customerRepository = CustomerRepository();

  /// List of form sections used in the dynamic form.
  List<Section> sections = [];
  List<Country>? countryList = [];
  bool? isMainLimit = false;
  List<String> limitTypeFacility = [
    ServerConstants.mainLimitLabel,
    ServerConstants.subLimitLabel,
  ];

  String? selectedCurrencyCode; // e.g., "AED"
  bool isApiError = false;

  /// Document data for the dynamic form.
  Map<String, dynamic> dynamicFormDocument = {};
  List<FeeRate> feeDefualtRate = [];
  List<Condition> standardCondition = [];
  List<Condition> nonStandardCondition = [];
  int initialNonStandardConditionCount = 0;
  List<Condition> contractingStandardCondition = [];
  List<FacilitySubTypes> facilitySubTypes = [];
  List<FacilityDetail> facilityDetail = [];
  List<Reference> commitmentAccountNumbers = [];
  List<LimitsResponse> limits = [];
  List<String> commitmentAccountNumberItems = [];
  List<Reference> benchmark = [];
  List<Reference> marginSign = [];
  num exchangeRate = 0;

  int? lastCreatedParentFacilityId;
  List<int> lastCreatedSubFacilityIds = [];

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
  List<Reference> limitGroups = [];
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

  final Map<int, int> groupCapsOriginalByRim = {};
  final Map<int, int> groupCapsPresentByRim = {};
  PageMode? pageMode;

  bool get canEdit =>
      pageMode == PageMode.edit; //&& Utils.canEditApplication();
  bool _allocationWarningShown = false;

  /// Determines whether the Purpose dropdown should be enabled.
  ///
  /// Business rules:
  /*- Always enabled for Project standby Limits and
   General limits disabled only for specific untill
  project name selcted */
  /// - Enabled when Project Finance = No
  /// - Enabled after a Project Name is selected
  bool get isPurposeEnabled {
    return limitGroup == ServerConstants.projectStandByLimitID ||
        isProjectFinanceNo ||
        (getFacility.projectName?.name?.trim().isNotEmpty ?? false);
  }

  bool get isProductTypeIslamic =>
      getFacility.selectedProductTypeValue?.id ==
      ServerConstants.productTypeIslamicID;
  bool get isFIFlow =>
      Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

  // Returns true when the Project Finance Related Activity is selected as "No"
  bool get isProjectFinanceNo {
    final name =
        (getFacility.selectedProjectFinanceRelatedActivityValue?.name ?? "")
            .trim()
            .toLowerCase();
    return name == ServerConstants.noText;
  }

  /// Computes the Project Name dropdown selection for UI purposes.
  ///
  /// Notes:
  /// - "General" is auto-selected when Project Finance = No
  /// - Suppressed for Project Specific / Standby groups
  /// - This does NOT mutate the model, only affects dropdown display
  List<Reference>? get projectNameSelectedForUi {
    final bool suppressGeneral =
        limitGroup == ServerConstants.projectStandByLimitID ||
            limitGroup == ServerConstants.projectSpecificLimitsID;

    if (isProjectFinanceNo) {
      if (getFacility.projectName != null) {
        return [getFacility.projectName!];
      }
      return suppressGeneral
          ? null
          : [Reference(name: ServerConstants.projectNameGeneral)];
    }
    return getFacility.projectName != null ? [getFacility.projectName!] : null;
  }

  bool showCreateFacilityForm = false;

  bool showNewProposedLimitAmount = false;
  bool showNewPresentLimitAmount = false;

  bool showNewPresentOutStandingLimit = false;
  bool showNewRevisedBankLimitProposedByFiAmount = false;
  bool showNewExcessOverMaxLimitAllowanceProposedByFiAmount = false;
  bool showNewCbdEquityTier325PercentAmount = false;
  bool showNewCounterpartyEquity5PercentAmount = false;
  bool showNewCounterpartyTotalAssets2PercentAmount = false;
  bool showNewRevisedBankLimitRecommendedByCreditAmount = false;
  bool showNewExcessOverMaxLimitAllowanceRecommendedByCreditAmount = false;
  bool showNewProposedByCCAmount = false;
  bool disableFxRates = false;
  List<FacilityCondition> conditionsStandard = [];
  List<FacilityCondition> conditionsNonStandard = [];
  List<FacilityCondition> contractingConditionsStandard = [];
  Reference? selectedProductType;
  int? rimNo;
  int? selectedRim;
  int? existingFacilityId;
  int? facilityMasterId;
  int? groupId;
  int? limitCapType;
  int? parentProposedLimit;
  String? parentControlliingNumber;
  TextEditingController limitTypeController = TextEditingController();
  TextEditingController limitDescriptionController = TextEditingController();
  // Controllers for the new Limit fields
  TextEditingController proposedLimitController = TextEditingController();
  TextEditingController newProposedLimitController = TextEditingController();
  TextEditingController presentLimitController = TextEditingController();
  TextEditingController newPresentLimitController = TextEditingController();
  TextEditingController presentOutstandingController = TextEditingController();
  TextEditingController newPresentOutStandingController =
      TextEditingController();

  TextEditingController excessOverMaxLimitAllowanceProposedByFiController =
      TextEditingController();
  TextEditingController newExcessOverMaxLimitAllowanceProposedByFiController =
      TextEditingController();
  TextEditingController cbdEquityTier325PercentController =
      TextEditingController();
  TextEditingController newCbdEquityTier325PercentController =
      TextEditingController();
  TextEditingController counterpartyEquity5PercentController =
      TextEditingController();
  TextEditingController newCounterpartyEquity5PercentController =
      TextEditingController();
  TextEditingController counterpartyTotalAssets2PercentController =
      TextEditingController();
  TextEditingController newCounterpartyTotalAssets2PercentController =
      TextEditingController();
  TextEditingController proposedByccController = TextEditingController();
  TextEditingController newProposedByccController = TextEditingController();
  TextEditingController
      excessOverMaxLimitAllowanceRecommendedByCreditController =
      TextEditingController();
  TextEditingController
      newExcessOverMaxLimitAllowanceRecommendedByCreditController =
      TextEditingController();

  int? selectedDescriptionId;
  String? mandatoryFeeTableRows;
  String? limitCategory;
  int? productType;
  bool isFeeRowMandatory = false;
  bool? subLimit;
  static const String _uaeName = "united arab emirates";
  static const Set<int> _pfDisabledGroups = {11312, 11313, 11314, 11315, 11317};
  static const Set<int> _pfForceYesGroups = {11315, 11317};

  String? get sustainabilityClassificationCsv {
    final List<Reference>? list = getFacility
        .sustainabilityClassification; // List<Reference>? (current type)
    if (list == null || list.isEmpty) return null;
    final List<String> ids = list
        .map((e) => e.id?.toString())
        .where((id) => id != null && id.trim().isNotEmpty)
        .map((id) => id!.trim())
        .toList();
    return ids.isEmpty ? null : ids.join(",");
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
          ?.map(
            (element) => Reference(
              name: element.customerName,
              id: element.customerRimNo,
            ),
          )
          .toList() ??
      [];

  List<Reference> projectNames = [];
  int? limitGroup;

  // Whether the radio should be enabled for the current limitGroup
  bool get isProjectFinanceActivityEnabled {
    final int? lg = limitGroup;
    return !(lg != null && _pfDisabledGroups.contains(lg));
  }

  bool isAnnualReview =
      Utils.checkApplicationType(ApplicationType.annualReview) ||
          (Globals.applicationDetails?.appTypeReferenceId ==
              ServerConstants.annualReview);

  // Find the "Yes"/"No" Reference from your options by name
  Reference _pfRefByName(String name) {
    final String target = name.trim().toLowerCase();
    return projectFinanceRelatedActivityOptions.firstWhere(
      (e) => (e.name ?? "").trim().toLowerCase() == target,
      orElse: () => Reference(name: name),
    );
  }

  final Map<int, SubLimitMeta> _subLimitMetaByIndex = {};

  SubLimitMeta _meta(int i) => _subLimitMetaByIndex[i] ??= SubLimitMeta();

  static const String _newAccLabel = ServerConstants.labelNew;

  int? _lastExceededToastValue; //proposed limit field error toast

  /// UI items for Commitment Account Number:
  /// - If no items from API -> ["NEW"]
  /// - If items exist -> items + "NEW" appended (unique; last)
  List<String> get commitmentAccountNumberItemsForUi {
    if (commitmentAccountNumberItems.isEmpty) {
      return [_newAccLabel];
    }
    final List<String> base = commitmentAccountNumberItems
        .where((s) => s.trim().toUpperCase() != _newAccLabel)
        .toList()
      ..add(_newAccLabel);
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
    final String acc = (apiAcc ?? "").trim();
    if (acc.isNotEmpty) return [acc];
    return null;
  }

  int get effectiveProposedLimit {
    final int? fromUser = getFacility.proposedLimit;
    if (fromUser != null) return fromUser;
    final int? fromApi =
        facilityDetail.isNotEmpty ? facilityDetail.first.proposedLimit : null;
    if (fromApi == null) return 0;
    return fromApi.toInt();
  }

// Default ref based on enable/disable rule
  Reference get projectFinanceDefaultRef =>
      _pfForceYesGroups.contains(limitGroup ?? -1)
          ? _pfRefByName("yes")
          : _pfRefByName("no");

  // Is the form currently creating a Sub-Limit?
  bool get isSubLimitMode => !(getFacility.isMainLimit ?? false);

  // Parent proposed limit (assumed to be in AED)
  int get parentLimitAED => parentProposedLimit ?? 0;

  // Maximum user input allowed in the currently selected currency,
  // derived from parent AED limit and the current exchange rate.
  // If currency is AED or exchangeRate unknown (0), use the AED value.
  int get maxInputInSelectedCurrency {
    final String code = (selectedCurrencyCode ?? "").toUpperCase();
    if (code == ServerConstants.aedCurrency || exchangeRate == 0) {
      return parentLimitAED;
    }
    return (parentLimitAED / exchangeRate).floor();
  }

  // Selected value for the radio (falling back to rule-based default)
  // When disabled, force the rule-based default (Yes for 11315/11317, No otherwise)
  Reference get projectFinanceSelectedOrDefault {
    if (!isProjectFinanceActivityEnabled) {
      return projectFinanceDefaultRef;
    }
    return getFacility.selectedProjectFinanceRelatedActivityValue ??
        projectFinanceDefaultRef;
  }

  List<Reference> selectedAccountTypes = [];

  String? get accountTypeCsvForSave {
    if (selectedAccountTypes.isNotEmpty) {
      final List<String> ids = selectedAccountTypes
          .map((r) => r.id?.toString())
          .where((s) => s != null && s.trim().isNotEmpty)
          .cast<String>()
          .toList();
      return ids.isEmpty ? null : ids.join(",");
    }
    final String? selectedId =
        getFacility.accountTypeValue?.id?.toString().trim();
    return (selectedId == null || selectedId.isEmpty) ? null : selectedId;
  }

  List<Reference> get propertySubTypesForSelectedType {
    final String? parentId = getFacility.propertyType?.id?.toString();
    if (parentId == null || parentId.isEmpty) return propertySubTypes;

    return propertySubTypes.where((sub) {
      final String? ref1 = sub.reference1?.trim();
      return ref1 != null && ref1 == parentId;
    }).toList();
  }

  bool isLimitCaps = false;
  List<Customer>? limitCapsCustomerList = [];
  num _numOr(num? value, num fallback) => value ?? fallback;
  bool _boolOr(bool? value, bool fallback) => value ?? fallback;

  // ---- Stable inputs for AllocateLimitDialogBox rows (survive re-mounts) ----
  final Map<int, TextEditingController> _allocationControllers = {};
  final Map<int, FocusNode> _allocationFocusNodes = {};

  int _borrowerKey(Reference b) {
    final int? id = b.id;
    if (id is int) return id;
    return (b.name ?? "").hashCode; // fallback when id isn't int
  }

  TextEditingController controllerForBorrower(Reference b) {
    final int k = _borrowerKey(b);
    return _allocationControllers.putIfAbsent(
      k,
      () => TextEditingController(text: b.description ?? ""),
    );
  }

  FocusNode focusNodeForBorrower(Reference b) {
    final int k = _borrowerKey(b);
    return _allocationFocusNodes.putIfAbsent(k, FocusNode.new);
  }

  // ---- Stable controllers for SubType Proposed Limit per row ----
  final Map<int, TextEditingController> _subtypeProposedControllers = {};
  TextEditingController proposedLimitControllerFor(int rowIndex) {
    return _subtypeProposedControllers.putIfAbsent(rowIndex, () {
      final NumberFormat fmt = NumberFormat("#,###");
      final int raw = (facilitySubTypes.length > rowIndex)
          ? (facilitySubTypes[rowIndex].proposedLimit ?? 0)
          : 0;
      return TextEditingController(text: raw > 0 ? fmt.format(raw) : "");
    });
  }

  // Add near your other toast gates
  bool _allocationToastVisible = false;

  //standby validation sublimit
  bool? isStanbySublimitValidation = false;
  // ---- Per-row exchange rate for subtypes ----
  final Map<int, num> _subtypeExchangeRates = {};
  num rateForSubType(int rowIndex) => _subtypeExchangeRates[rowIndex] ?? 0;

  // Key = index of facilitySubTypes row
  final Map<int, List<Reference>> subLimitBorrowersByIndex = {};
  final Map<int, List<Condition>> subLimitConditionsByIndex = {};

  bool get isProjectNameEnabled {
    final selectedName =
        (getFacility.selectedProjectFinanceRelatedActivityValue?.name ?? "")
            .trim()
            .toLowerCase();
    final bool isYes = selectedName == "yes";
    final bool isForceYesGroup = _pfForceYesGroups.contains(limitGroup ?? -1);
    return isYes || isForceYesGroup;
  }

  Map<String, List<Reference>> referenceData = {};
  int? limitCapsFromSummary; // value coming from Facilities Summary screen

  ///init method all api calls happen here and we get data from previous screen
  /// that is required here based on limit and limit type description
  Future<void> init(bool showCreateForm, {Facility? selectedFacility}) async {
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loading,
        navigateToCreateFacility: LoadingStatus.loading, // NEW
      ),
    );
    try {
      repository = FacilitySecurityRepository.instance;

      pageMode = AuthRepository.getPageMode(RightConstants.createFacility);
      await Future.wait([
        getReferenceDatas(),
        getUpdatedFacilityReference(),
      ]);

      getFacility = selectedFacility ?? Facility();
      showCreateFacilityForm = showCreateForm;
      isStanbySublimitValidation =
          getFacility.isStanbySublimitValidation ?? false;

      getColletralAndPromissory();

      subLimit = getFacility.isMainLimit ?? false;
      if (showCreateFacilityForm &&
          getFacility.sharedLimit == null &&
          sharedLimits.isNotEmpty) {
        getFacility.sharedLimit = sharedLimits.first;
      }
      productType = getFacility.selectedProductTypeValue?.id;
      existingFacilityId = getFacility.facilityId;
      facilityMasterId = getFacility.facilityMasterId;
      rimNo = getFacility.rimNo ?? selectedFacility?.rimNo;
      parentControlliingNumber = selectedFacility?.limitNumber;
      limitGroup = getFacility.limitGroup;
      //capture limitCapType passed from summary (corporate only; FI should keep
      //null)
      limitCapsFromSummary =
          selectedFacility?.limitCapType ?? getFacility.limitCapType;

      // Keep existing vars in sync (used by getFacilityDetails and other flows)
      if (!isFIFlow && limitCapsFromSummary != null) {
        limitCapType = limitCapsFromSummary; // existing VM var
        facilityDetails.limitCapType ??=
            limitCapsFromSummary; // preserve if already set later
      }

      selectedRim = selectedFacility?.rimNo ?? Globals.request?.customerRimNo;
      parentProposedLimit =
          selectedFacility?.proposedLimit ?? getFacility.proposedLimit;

      if (limitGroup == ServerConstants.projectSpecificLimitsID ||
          limitGroup == ServerConstants.projectStandByLimitID) {
        final String? ref3 = selectedFacility?.productCodeProject;

        if (ref3 != null && ref3.trim().isNotEmpty) {
          getFacility.productCodeProject = ref3.trim().toUpperCase();
        }
      }
      if (parentProposedLimit != null && parentProposedLimit! > 0) {
        getFacility.proposedLimit = parentProposedLimit;
      }

      if (showCreateFacilityForm) {
        limitDescriptionController.text =
            selectedFacility?.facilityDescription?.name ?? "";
      }
      limitCategory = selectedFacility?.facilitySummaryItem?.limitCategory ??
          selectedFacility?.facilityDescription?.reference2;
      // Fee Table will be mandatory for these product codes
      mandatoryFeeTableRows =
          selectedFacility?.facilityDescription?.reference3 ??
              selectedFacility
                  ?.limitGroupName; //TODO  need to fix this. pass object based
      String code = (mandatoryFeeTableRows ?? "").trim().toUpperCase();

      if (ServerConstants.mandatoryFeeProductCodes.contains(code)) {
        isFeeRowMandatory = true;
      }

      if (code == ServerConstants.productCodeClt) {
        isLimitCaps = true;
      }

      if (code == ServerConstants.productCodeIjrf) {
        final String target =
            ServerConstants.advanceTypeNonRevolving.toLowerCase();
        final Reference match = advanceTypes.firstWhere(
          (r) => (r.name ?? "").trim().toLowerCase() == target,
          orElse: () => Reference(
            id: ServerConstants.advanceTypeNonRevolvingId,
            name: ServerConstants.advanceTypeNonRevolving,
          ),
        );
        getFacility.advanceTypeValue = match;
      }

      if (limitGroup == ServerConstants.projectSpecificLimitsID ||
          limitGroup == ServerConstants.projectStandByLimitID) {
        // override code with productCode coming from reference3
        code = (getFacility.productCodeProject ?? "").trim().toUpperCase();
      }
      selectedDescriptionId = selectedFacility?.facilityDescription?.id;
      final bool isSubLimit = subLimit ?? false;
      limitTypeController.text = isSubLimit
          ? ServerConstants.mainLimitLabel
          : ServerConstants.subLimitLabel;
      ensureDefaultCountryOfRiskIfEmpty();
      enforceProjectFinanceRuleIfNeeded();
      await Future.wait([
        getCurrencyCodes(),
        getFacilitySubTypes(),
        getChildRimsForGroup(),
        getCountries(),
        getBorrowers(),
        getLimitsandFacilities(Globals.request?.customerRimNo ?? rimNo),
      ]);
      ////get facility details api .........for new or exsiting facility call this
      await getFacilityDetails(
        existingFacilityId,
        rimNo,
        facilityMasterId: facilityMasterId,
      );
      if (!showCreateFacilityForm) {
        // Load dynamic form configuration for update flow
        await getDynamicForm(getFacility.facilityDescription?.id);
        await getProjectList(limitGroup, selectedRim ?? rimNo);
      } else {
        await getDynamicForm(selectedDescriptionId);
        await getProjectList(limitGroup, selectedRim ?? rimNo);
      }
      // await setDynamicForm();

      if (getFacility.projectName != null) {
        final String sel =
            (getFacility.projectName!.name ?? "").trim().toLowerCase();
        final bool exists = projectNames
            .any((r) => (r.name ?? "").trim().toLowerCase() == sel);
        if (!exists) projectNames.insert(0, getFacility.projectName!);
      }
      applyInitialCurrencyVisibility();

      // ---- Seniority default (CREATE flow) ----
      // UI shows first item, but model remains null unless user changes
      // dropdown.
      // Set it once so payload doesn't send null.
      if (showCreateFacilityForm &&
          getFacility.seniorityValue == null &&
          seniorities.isNotEmpty) {
        getFacility.seniorityValue = seniorities.first;
      }

      // if (canEdit) {
      // registerDraftCallback();
      // await loadDraftIfAvailable();

      // Re-run dynamic form visibility using restored dynamicFormDocument
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   setDynamicForm();
      //   dynamicFormKey.currentState?.updateFields(dynamicFormDocument);
      // });
      // }
    } catch (_) {}
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        navigateToCreateFacility: LoadingStatus.loaded,
      ),
    );

    // Initialize Excess Amount currency(Dynamic field) after form loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      syncExcessAmountCurrency();
      final bool selectedYes = facilityDetail.isNotEmpty
          ? (facilityDetail.first.isCollateralDependent?.id ==
              ServerConstants.optionYESid)
          : _yesNoToBool(getFacility.selectedCollateralDepantantValue, false);

      // Make both fields visible + mandatory based on initial value
      dynamicFormKey.currentState?.setFieldVisibility("extentOfFinance", true);
      dynamicFormKey.currentState
          ?.setFieldVisibility("customerContribution", true);
      dynamicFormKey.currentState
          ?.setFieldMandatory("extentOfFinance", selectedYes);
      dynamicFormKey.currentState
          ?.setFieldMandatory("customerContribution", selectedYes);

      if (dynamicFormDocument.containsKey("acceptableInvoiceCurrencies")) {
        final value = dynamicFormDocument["acceptableInvoiceCurrencies"];
        bool hasOther = false;
        if (value is List) {
          hasOther = value.contains("Other");
        }
        dynamicFormKey.currentState
            ?.setFieldVisibility("specifyOthercurrency", hasOther);
      }
      setDynamicForm();
    });
  }

  /// Items for Facility Account Type dropdown filtered by
  /// facilityDescription.reference3.
  /// If reference3 is empty or no matches found, fall back to the full list.
  List<Reference> get accountTypesForUi {
    final String facilityCode =
        (getFacility.facilityDescription?.reference3 ?? "")
            .trim()
            .toUpperCase();

    final List<Reference> filtered = accountTypes.where((reference) {
      return reference.reference1?.toUpperCase() == facilityCode;
    }).toList();
    return filtered.isNotEmpty ? filtered : accountTypes;
  }

  Future<void> setDynamicForm() async {
    DynamicFormState? form;
    if (sections.isNotEmpty) {
      form = dynamicFormKey.currentState;
    }

    if (dynamicFormDocument.containsKey("repaymentTypeTawarrukPPC")) {
      if (dynamicFormDocument["repaymentTypeTawarrukPPC"] == "instalments") {
        form?.setFieldVisibility("instalments", true);
        form?.setFieldVisibility("bullet", false);
      } else if (dynamicFormDocument["repaymentTypeTawarrukPPC"] == "bullet") {
        form?.setFieldVisibility("instalments", false);
        form?.setFieldVisibility("bullet", true);
      }
    }

    if (dynamicFormDocument.containsKey("repaymentTypeTawarrukInvoice")) {
      if (dynamicFormDocument["repaymentTypeTawarrukInvoice"] ==
          "instalments") {
        form?.setFieldVisibility("instalments", true);
        form?.setFieldVisibility("bullet", false);
      } else if (dynamicFormDocument["repaymentTypeTawarrukInvoice"] ==
          "bullet") {
        form?.setFieldVisibility("instalments", false);
        form?.setFieldVisibility("bullet", true);
      }
    }

    if (dynamicFormDocument.containsKey("preShipment")) {
      form?.setFieldVisibility(
        "preShipmentAmount",
        dynamicFormDocument["preShipment"] == true,
      );
    }
    if (dynamicFormDocument.containsKey("postShipment")) {
      form?.setFieldVisibility(
        "postShipmentAmount",
        dynamicFormDocument["postShipment"] == true,
      );
    }

    // Overseas Shipment → overseasShipmentAmount
    if (dynamicFormDocument.containsKey("overseasShipment")) {
      form?.setFieldVisibility(
        "overseasShipmentAmount",
        dynamicFormDocument["overseasShipment"] == true,
      );
    }

    // Third Port Shipment → thirdPortShipmentAmount
    if (dynamicFormDocument.containsKey("thirdPortShipment")) {
      form?.setFieldVisibility(
        "thirdPortShipmentAmount",
        dynamicFormDocument["thirdPortShipment"] == true,
      );
    }

    // Local Delivery → localDeliveryAmount
    if (dynamicFormDocument.containsKey("localDelivery")) {
      form?.setFieldVisibility(
        "localDeliveryAmount",
        dynamicFormDocument["localDelivery"] == true,
      );
    }

    // Finance under LC → financeUnderLCAmount
    if (dynamicFormDocument.containsKey("financeUnderLC")) {
      form?.setFieldVisibility(
        "financeUnderLCAmount",
        dynamicFormDocument["financeUnderLC"] == true,
      );
    }

    // Finance against collection → financeAgainstCollectionAmount
    if (dynamicFormDocument.containsKey("financeAgainstCollection")) {
      form?.setFieldVisibility(
        "financeAgainstCollectionAmount",
        dynamicFormDocument["financeAgainstCollection"] == true,
      );
    }

    // Shipment by sea/Air → shipmentBySea/AirAmount
    if (dynamicFormDocument.containsKey("shipmentBySeaOrAir")) {
      form?.setFieldVisibility(
        "shipmentBySea/AirAmount",
        dynamicFormDocument["shipmentBySeaOrAir"] == true,
      );
    }

    // Shipment by Truck → shipmentByTruckAmount
    if (dynamicFormDocument.containsKey("shipmentByTruck")) {
      form?.setFieldVisibility(
        "shipmentByTruckAmount",
        dynamicFormDocument["shipmentByTruck"] == true,
      );
    }

    // Chartered Party/Bill of Lading → charteredBillLadingAmount
    if (dynamicFormDocument.containsKey("charterBillLading")) {
      form?.setFieldVisibility(
        "charteredBillLadingAmount",
        dynamicFormDocument["charterBillLading"] == true,
      );
    }

    //
    if (dynamicFormDocument.containsKey("rePaymentType")) {
      final rePaymentType = form?.getFieldValue("rePaymentType");
      if (rePaymentType == "installmentLoan") {
        form?.setFieldVisibility("interestGrid", true);
        form?.setFieldVisibility("principal", true);
        form?.setFieldVisibility("equated", false);
      } else if (rePaymentType == "equatedLoan") {
        form?.setFieldVisibility("equated", true);
        form?.setFieldVisibility("interestGrid", false);
        form?.setFieldVisibility("principal", false);
      }
    }

    // Master Promissory Note held →
    //   Use ONE of the following, depending on your form:

    // Variant A: it shows an Amount field
    if (dynamicFormDocument.containsKey("masterPromissoryNoteHeld")) {
      form?.setFieldVisibility(
        "masterPromissoryNoteHeldAmount",
        dynamicFormDocument["masterPromissoryNoteHeld"] == true,
      );
    }

    //
    if (dynamicFormDocument.containsKey("recourse")) {
      final recourse = form?.getFieldValue("recourse");
      if (recourse != null && recourse == "withoutRecourse") {
        form?.setFieldVisibility("creditInsuranceCompanyName", true);
        form?.setFieldVisibility("creditInsurancePolicyDetails", true);
      }
    }

    // Variant B: it shows a Number/ID field
    if (dynamicFormDocument.containsKey("masterPromissoryNoteHeld")) {
      form?.setFieldVisibility(
        "masterPromissoryNoteNumber",
        dynamicFormDocument["masterPromissoryNoteHeld"] == true,
      );
    }
    // Handle Guarantee Margin / LC Margin / AV Margin initial state (update flow)
    for (final String marginKey in [
      "guaranteeMargin",
      "lcMargin",
      "avMargin",
    ]) {
      if (dynamicFormDocument.containsKey(marginKey)) {
        final String? marginValue = dynamicFormDocument[marginKey];
        final bool hasValue = marginValue != null && marginValue.isNotEmpty;
        final bool isTimeDeposits = marginValue == "timeDeposits";

        // Margin Extent becomes mandatory when any margin value is selected
        form?.setFieldMandatory("marginExtent", hasValue);

        // Linked Account Number becomes mandatory only for Time Deposits
        form?.setFieldMandatory("linkedAccountNumber", isTimeDeposits);
        break; // Only process the first found margin key
      }
    }

    final bool selectedYes = facilityDetail.isNotEmpty
        ? (facilityDetail.first.isCollateralDependent?.id ==
            ServerConstants.optionYESid)
        : _yesNoToBool(getFacility.selectedCollateralDepantantValue, false);

    form?.setFieldVisibility("extentOfFinance", true);
    form?.setFieldVisibility("customerContribution", true);
    form?.setFieldMandatory("extentOfFinance", selectedYes);
    form?.setFieldMandatory("customerContribution", selectedYes);
  }

  void getColletralAndPromissory() {
    if (showCreateFacilityForm &&
        getFacility.selectedCollateralDepantantValue == null) {
      try {
        final noRef = collateralDepantantoptions.firstWhere(
          (e) => e.id == ServerConstants.optionNOid,
        );
        getFacility.selectedCollateralDepantantValue = noRef;
      } catch (_) {}
    }

    if (showCreateFacilityForm &&
        getFacility.selectedpromissoryNoteValue == null) {
      try {
        final noRef = promissoryNoteOptions.firstWhere(
          (e) => e.id == ServerConstants.optionNOid,
        );
        getFacility.selectedpromissoryNoteValue = noRef;
      } catch (_) {}
    }
  }

  ///get child rim list for rim dropdown group limit cap type limit uses
  Future<void> getChildRimsForGroup() async {
    try {
      if (Utils.isGroupApplication()) {
        limitCapsCustomerList =
            await CustomerRepository.instance.getChildRimsForGroup() ?? [];
      }
    } catch (e) {
      rethrow;
    }
  }

// used for geting the updated list with newly created Facility types
  Future<void> getUpdatedFacilityReference() async {
    final String facilityTypeKey = isFIFlow
        ? ReferenceDataKeys.fiFacilityTypes
        : ReferenceDataKeys.facilityTypes;

    try {
      final List<ReferenceType> getReferenceData =
          await HomeRepository.instance.getReferenceData([facilityTypeKey]);

      facilityDescriptions = getReferenceData[0].references ?? [];
      facilityTypes = getReferenceData[0].references ?? [];
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }

    debugPrint(facilityDescriptions.toString());
  }

  /// Loads reference data required for dropdowns and selections in the form.
  ///
  /// Fetches data from [ReferenceDataService] and populates the corresponding
  /// lists.
  /// Emits a loaded state once data is retrieved.
  Future<void> getReferenceDatas() async {
    try {
      final String limitGroupKey = isFIFlow
          ? ReferenceDataKeys.fiLimitGroup
          : ReferenceDataKeys.limitGroup;

      final String limitTypeKey = isFIFlow
          ? ReferenceDataKeys.fiLimitType
          : ReferenceDataKeys.limitType;

      referenceData = await ReferenceDataService().getReferenceData([
        limitTypeKey,
        limitGroupKey,
        ReferenceDataKeys.largeExposureLimit,
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
        ReferenceDataKeys.limitCapsType,
        ReferenceDataKeys.productType,
        ReferenceDataKeys.accountType,
        ReferenceDataKeys.policyDeviation,
        ReferenceDataKeys.sustanabilityClassification,
        ReferenceDataKeys.accountType,
        ReferenceDataKeys.facilityFeeTypes,
        ReferenceDataKeys.facilityTypesFeeFrequency,
        ReferenceDataKeys.period,
        ReferenceDataKeys.benchMark,
        ReferenceDataKeys.marginSign,
        ReferenceDataKeys.prupose,
      ]);
      period = referenceData[ReferenceDataKeys.period] ?? [];
      limitGroups = referenceData[limitGroupKey] ?? [];
      benchmark = referenceData[ReferenceDataKeys.benchMark] ?? [];
      marginSign = referenceData[ReferenceDataKeys.marginSign] ?? [];
      facilityTypesFeeFrequency =
          referenceData[ReferenceDataKeys.facilityTypesFeeFrequency] ?? [];
      facilityFeeTypes =
          referenceData[ReferenceDataKeys.facilityFeeTypes] ?? [];

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
      limitTypes = referenceData[limitTypeKey] ?? [];
      limitCapsType = referenceData[ReferenceDataKeys.limitCapsType] ?? [];
      seniorities = referenceData[ReferenceDataKeys.seniority] ?? [];
      sectors = referenceData[ReferenceDataKeys.sector] ?? [];
      sicCodes = referenceData[ReferenceDataKeys.sicCodeList] ?? [];
      purposes = referenceData[ReferenceDataKeys.prupose] ?? [];
      regulatorySpecifications = referenceData[
              ReferenceDataKeys.regulatorySpecialisedLendingFinanceType] ??
          [];

      //Policy Deivation
      final List<Reference> policyDeviationRef =
          referenceData[ReferenceDataKeys.policyDeviation] ?? [];
      if (Utils.checkBusinessSegment(BusinessSegment.financialInstitution)) {
        // FI context (include FI + generic)
        policyDeviations =
            filterPolicyDeviation(policyDeviationRef, isFI: true);
      } else {
        // Corporate context (exclude FI; include generic and others)
        policyDeviations =
            filterPolicyDeviation(policyDeviationRef, isFI: false);
        // Corporate strict (include ONLY Corporate + generic)
        //policyDeviations = filterPolicyDeviation(policyDeviation,isFI: false,
        //strictCorporate: true);
      }

      //filter out facility types where reference5 is "HIDE"
      facilityTypes = facilityTypes
          .where((data) => data.reference5 != ServerConstants.hide)
          .toList();
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Filters policy deviation references based on FI/Corporate context.
  ///
  /// isFI == true:
  ///   include: reference1 == "FI" OR generic (null / empty)
  ///
  /// isFI == false (Corporate):
  ///   include: generic and NOT "FI"
  ///   set [strictCorporate] = true to include ONLY "Corporate" + generic
  List<Reference> filterPolicyDeviation(
    List<Reference> items, {
    required bool isFI,
    bool strictCorporate = false,
  }) {
    String norm(String? value) => (value ?? "").trim().toLowerCase();
    return items.where((ref) {
      final String referenceData = norm(ref.reference1);
      if (isFI) {
        // FI view: "fi" or generic
        return referenceData.isEmpty ||
            referenceData == ServerConstants.policyDeviationFI; // 'fi';
      } else {
        if (strictCorporate) {
          // Corporate strict: "corporate" or generic
          return referenceData.isEmpty ||
              referenceData ==
                  ServerConstants.policyDeviationCorporate; //'corporate';
        } else {
          // Corporate default: include anything that is NOT "fi" plus generic
          return referenceData.isEmpty ||
              referenceData != ServerConstants.policyDeviationFI; // 'fi';
        }
      }
    }).toList();
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

      // If API returns no commitment accounts:
      // - Preselect "NEW" for UI and save
      // - Make Present Outstanding editable immediately
      if (commitmentAccountNumberItems.isEmpty) {
        getFacility.commitmentAccountNumber = Reference(name: _newAccLabel);
        presentOutStandingReadOnly = false;
      }

      final Set<String> seen = <String>{};
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

  Future<void> getFacilityDetails(
    int? existingFacilityId,
    int? rimNo, {
    int? groupId,
    int? limitCapType, // NEW
    int? facilityMasterId, // New param
  }) async {
    if (showCreateFacilityForm) {
      final Map<String, dynamic> result = await repository.getFacilityDetails(
        null,
        rimNo ?? Globals.request?.customerRimNo,
        groupId: Globals.request?.groupId ?? 0, // confirm if it's id or owner
        limitCapType: isFIFlow ? null : limitCapType ?? 14492, // NEW
        facilityMasterId: facilityMasterId,
      );

      facilityDetail = result["facilityDetails"] ?? [];
      final List<Condition> allConditions = result["conditions"] ?? [];
      if (allConditions.isNotEmpty) {
        standardCondition = allConditions.where((c) => c.isStandard).toList();
        nonStandardCondition =
            allConditions.where((c) => c.isNonStandard).toList();
        initialNonStandardConditionCount = nonStandardCondition.length;
      } else {
        await getFacilityConditionsList();
      }

      final List<dynamic> compRows = result["companyBorrowerList"] ?? const [];
      if (compRows.isNotEmpty) {
        //TODO need to optimise this part
        for (final dynamic row in compRows) {
          final Map<String, dynamic> id =
              row?["id"] as Map<String, dynamic>? ?? const {};
          final int? rim = (id["borrowerRimNo"] is int)
              ? id["borrowerRimNo"] as int
              : int.tryParse((id["borrowerRimNo"] ?? "").toString());
          if (rim == null) continue;
          final int original = (row["originalLimitAllocation"] ?? 0) as int;
          final int present = (row["presentLimitAllocation"] ?? 0) as int;
          final int amount = (row["limitAllocationAmount"] ?? 0) as int;
          final String? subNo = (row["subLimitNo"] as String?)?.trim();
          groupCapsOriginalByRim[rim] = original;
          groupCapsPresentByRim[rim] = present;

          final int idx = borrowersByRimInTable
              .indexWhere((r) => (r.id?.toString() ?? "") == rim.toString());
          final String amtStr = amount.toString();
          if (idx >= 0) {
            borrowersByRimInTable[idx].description = amtStr;
            if ((subNo ?? "").isNotEmpty) {
              borrowersByRimInTable[idx].reference1 = subNo;
            }
          } else {
            borrowersByRimInTable.add(
              Reference(
                id: rim,
                description: amtStr,
                reference1: subNo,
              ),
            );
          }
        }
      }
    }
    //existing facility send rimno not group Owner
    else {
      try {
        final Map<String, dynamic> result = await repository.getFacilityDetails(
          existingFacilityId,
          rimNo,
          groupId: Globals.request?.groupId,
          limitCapType: isFIFlow ? null : limitCapType ?? 14492,
          facilityMasterId: facilityMasterId,
        );
        facilityDetail = result["facilityDetails"] ?? [];
        feeDefualtRate = result["feeRates"] ?? [];

        final List<Condition> allConditions = result["conditions"] ?? [];
        if (allConditions.isNotEmpty) {
          standardCondition = allConditions.where((c) => c.isStandard).toList();
          nonStandardCondition =
              allConditions.where((c) => c.isNonStandard).toList();
          initialNonStandardConditionCount = nonStandardCondition.length;
        }

        // Parse and flatten additionalDetails for dynamic form
        if (facilityDetail.isNotEmpty) {
          dynamicFormDocument = facilityDetail.first.additionalDetails!;
          logger.i(dynamicFormDocument);
        }

        //if shared limit is yes then  borrowerList
        try {
          final Map<String, dynamic>? fbm = result["facilityBorrowerMap"];
          final List<dynamic> rows = fbm?["borrowerList"] ?? const [];

          borrowersByRimInTable.clear();

          for (final dynamic row in rows) {
            final Map<String, dynamic> idObj =
                (row?["id"] as Map<String, dynamic>?) ?? const {};
            final int? rim = (idObj["borrowerRimNo"] is int)
                ? idObj["borrowerRimNo"] as int
                : int.tryParse('${idObj['borrowerRimNo'] ?? ''}');
            if (rim == null) continue;

            final int amount = (row["limitAllocationAmount"] ?? 0) as int;
            final String? subLimitNo = (row["subLimitNo"] as String?)?.trim();
            final int idx = borrowersMap.indexWhere(
              (r) => (r.id?.toString() ?? "") == rim.toString(),
            );
            final Reference ref = (idx >= 0)
                ? borrowersMap[idx]
                : Reference(id: rim, name: rim.toString());

            ref
              ..name ??= rim.toString()
              ..description = amount.toString()
              ..reference1 = (subLimitNo?.isNotEmpty == true
                  ? subLimitNo
                  : ref.reference1);

            final int selIdx = borrowersByRimInTable.indexWhere(
              (r) => (r.id?.toString() ?? "") == rim.toString(),
            );
            if (selIdx >= 0) {
              borrowersByRimInTable[selIdx] = ref;
            } else {
              borrowersByRimInTable.add(ref);
            }
          }

          final bool isSharedYes = facilityDetail.isNotEmpty &&
              (facilityDetail.first.isSharedLimit ?? false);
          if (borrowersByRimInTable.isEmpty && isSharedYes) {
            final int? rimFromDetails = facilityDetail.first.rimNo;
            if (rimFromDetails != null) {
              final int idx = borrowersMap.indexWhere(
                (r) => (r.id?.toString() ?? "") == rimFromDetails.toString(),
              );
              final Reference ref = (idx >= 0)
                  ? borrowersMap[idx]
                  : Reference(
                      id: rimFromDetails,
                      name: rimFromDetails.toString(),
                    );
              if (idx < 0) borrowersMap.add(ref);
              ref.name ??= rimFromDetails.toString();

              ref.description ??= "0";

              borrowersByRimInTable.add(ref);
            }
          }
          emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        } catch (_) {}

        final List<dynamic> compRows =
            result["companyBorrowerList"] ?? const [];
        if (compRows.isNotEmpty) {
          for (final row in compRows) {
            final id = row?["id"] as Map<String, dynamic>? ?? const {};
            final int? rim = (id["borrowerRimNo"] is int)
                ? id["borrowerRimNo"] as int
                : int.tryParse((id["borrowerRimNo"] ?? "").toString());
            if (rim == null) continue;
            final int original = (row["originalLimitAllocation"] ?? 0) as int;
            final int present = (row["presentLimitAllocation"] ?? 0) as int;
            final int amount = (row["limitAllocationAmount"] ?? 0) as int;
            final String? subNo = (row["subLimitNo"] as String?)?.trim();
            groupCapsOriginalByRim[rim] = original;
            groupCapsPresentByRim[rim] = present;

            final int idx = borrowersByRimInTable
                .indexWhere((r) => (r.id?.toString() ?? "") == rim.toString());
            final String amtStr = amount.toString();
            if (idx >= 0) {
              borrowersByRimInTable[idx].description = amtStr;
              if ((subNo ?? "").isNotEmpty) {
                borrowersByRimInTable[idx].reference1 = subNo;
              }
            } else {
              borrowersByRimInTable.add(
                Reference(
                  // NEW
                  id: rim,
                  description: amtStr,
                  reference1: subNo, // NEW
                ),
              );
            }
          }
        }

        getExisitngFacilityData();
      } catch (e) {
        AlertManager().showFailureToast(e.toString());
      }
    }
  }

  void emitLimitCapsRefresh() {
    // Toggle to a different value first so BlocBuilder sees a new state
    groupCapRowError.clear();
    //  Clear ProposedCompanyCap when Group Level Cap == NO
    proposedCapRaw = null;
    proposedCapEdited = false;
    getFacility.proposedLimit = null; // or 0 if your API expects a number
    getFacility.proposedLimitAED = null; // keep AED mirror in sync
    emit(state.copyWith(navigateToCreateFacility: LoadingStatus.empty));

    emit(state.copyWith(navigateToCreateFacility: LoadingStatus.loaded));
  }

  /// Selected items for BorrowerRim multi-select in:
  ///   Group Application + SharedLimit == Yes
  /// If the table (borrowersByRimInTable) is still empty, fallback to the
  /// facility's RIM.
  /// Returns null for other flows, so other widgets remain unaffected.
  List<Reference>? get selectedBorrowersForUi {
    final bool isGroup = Utils.isGroupApplication();
    final bool isSharedYes =
        (getFacility.sharedLimit?.id == ServerConstants.optionYESid);
    if (!isGroup || !isSharedYes) return null;
    if (borrowersByRimInTable.isNotEmpty) return borrowersByRimInTable;
    final int? rim = getFacility.rimNo ?? selectedRim;
    if (rim == null) return null;
    final int idx = borrowersMap.indexWhere(
      (r) => (r.id?.toString() ?? "") == rim.toString(),
    );
    final Reference fallback = ((idx >= 0)
        ? borrowersMap[idx]
        : Reference(id: rim, name: rim.toString()))
      ..name ??= rim.toString();
    return [fallback];
  }

  // Read prefilled/typed amount for a given rim (as string)
  String getGroupCapsAllocationDisplay(int? rimNo) {
    if (rimNo == null) return "";
    final String rimStr = rimNo.toString();
    final Reference ref = borrowersByRimInTable.firstWhere(
      (r) => (r.id?.toString() ?? "") == rimStr,
      orElse: Reference.new,
    );
    return (ref.description ?? "").trim();
  }

  // True if the (raw) entered amount would exceed the parent limit after AED
  // conversion.
  bool exceedsParentLimit(int enteredRaw) {
    if (parentLimitAED <= 0) return false;

    final String code = (selectedCurrencyCode ?? "").toUpperCase();
    final int enteredInAED =
        (code == ServerConstants.aedCurrency || exchangeRate == 0)
            ? enteredRaw
            : (enteredRaw * exchangeRate).round();
    return enteredInAED > parentLimitAED;
  }

  // Compose-friendly validator you can call from the field
  String? validateProposedLimit(String? value) {
    final String cleaned = (value ?? "").replaceAll(",", "");
    final int entered = int.tryParse(cleaned) ?? 0;
    if (entered <= 0) return "Please enter a valid amount";
    if (isSubLimitMode && parentLimitAED > 0 && exceedsParentLimit(entered)) {
      return "Proposed limit cannot exceed parent limit ";
    }
    return null;
  }

  bool isCmoUpdate() {
    return Utils.checkRoles([
      UserRole.documentationChecker,
      UserRole.documentationMaker,
      UserRole.ccuChecker,
      UserRole.ccuMaker,
    ]);
  }

  bool isEditableForProposedByCC() {
    return Utils.checkRoles([
      UserRole.creditAnalyst,
      UserRole.creditCommitteeProxy,
      UserRole.boardDirectorProxy,
      UserRole.boardDirectorProxyApproval,
      UserRole.creditCommitteeProxyApprover,
    ]);
  }

  Future<void> setCommitmentAccNumber(String commitmentAccNumber) async {
    final String accNo = commitmentAccNumber.trim();
    getFacility.commitmentAccountNumber = Reference(name: accNo);
    presentOutStandingReadOnly = (accNo != _newAccLabel);
    getFacility.presentOutstandingAmount = 0;
    getFacility.presentOutstandingCCValue = currencyCodes.first;
    await Future.delayed(const Duration(seconds: 1));
    setControllingLimitByAccount(accNo);
  }

  void setControllingLimitByAccount(String? accNoRaw) {
    final String? accNo = accNoRaw?.trim();
    if (accNo == null || accNo.isEmpty) return;

    final LimitsResponse match = limits.firstWhere(
      (e) => (e.commitmentAccountNumber ?? "").trim() == accNo,
      orElse: () => const LimitsResponse(), // empty object if not found
    );
    final String? cln = match.controllingLimitNo?.trim();
    getFacility.controllingLimitNumber =
        (cln?.isNotEmpty ?? false) ? cln : null;

    if (cln?.isNotEmpty ?? false) {
      final bool exists = controllingLimitNumbers.any(
        (r) => (r.name ?? "").trim() == cln,
      );
      if (!exists) {
        controllingLimitNumbers.add(Reference(name: cln));
      }
    }

    final String? currency = match.limitCurrency?.trim();
    final num? past = match.pastDues;
    if ((currency?.isNotEmpty ?? false) || past != null) {
      final Reference ref = getFacility.pastDues ?? Reference();
      ref
        ..name = ServerConstants.aedCurrency
        ..description = past?.toString() ?? ref.description;
      getFacility.pastDues = ref;
    }
    final num? outstandingAmount = match.outstandingAmount;

    if ((currency?.isNotEmpty ?? false) || outstandingAmount != null) {
      final Reference ref =
          getFacility.presentOutstandingCCValue ?? Reference();
      if (currency?.isNotEmpty ?? false) {
        ref.name = currency; // e.g., "AED"
      }
      getFacility.presentOutstandingCCValue = ref;
      getFacility.presentOutstandingAmount = outstandingAmount?.toInt() ?? 0;
    }

    final num? limitAmount = match.limitAmount;
    if ((currency?.isNotEmpty ?? false) || past != null) {
      final Reference ref = getFacility.limitAmount ?? Reference();
      ref.description =
          limitAmount?.toString() ?? ref.description; // amount as string
      getFacility.limitAmount = ref;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> setCommitementAccountNumber(String? accNoRaw, int index) async {
    final String? accNo = accNoRaw?.trim();
    if (accNo == null || accNo.isEmpty) return;

    final LimitsResponse match = limits.firstWhere(
      (e) => (e.commitmentAccountNumber ?? "").trim() == accNo,
      orElse: () => const LimitsResponse(), // empty object if not found
    );
    final String? cln = match.controllingLimitNo?.trim();
    getFacility.controllingLimitNumber =
        (cln?.isNotEmpty ?? false) ? cln : null;

    if (cln?.isNotEmpty ?? false) {
      final bool exists = controllingLimitNumbers.any(
        (r) => (r.name ?? "").trim() == cln,
      );
      if (!exists) {
        controllingLimitNumbers.add(Reference(name: cln));
      }
    }

    facilitySubTypes[index].pastDues = int.tryParse(match.pastDues.toString());
    facilitySubTypes[index].currentOutstanding =
        int.tryParse(match.outstandingAmount.toString());
    facilitySubTypes[index].commitmentAccountNumber = accNo;
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // // Only trigger alert the first time the value exceeds the parent limit.
  // // Reset the flag when user goes back within the limit.
  // bool shouldShowProposedLimitExceedAlert(int enteredRaw) {
  //   final bool exceeds = exceedsParentLimit(enteredRaw);
  //   if (exceeds) {
  //     if (!_proposedLimitWarningShown) {
  //       _proposedLimitWarningShown = true;
  //       return true;
  //     }
  //     return false;
  //   } else {
  //     _proposedLimitWarningShown = false;
  //     return false;
  //   }
  // }

  bool shouldShowProposedLimitToastOnce(int enteredRaw) {
    if (!isSubLimitMode) return false;

    // We decide exceed here so we can also reset when user comes back under the
    // cap
    final bool exceeds = exceedsParentLimit(enteredRaw);

    if (!exceeds) {
      // reset so next time user exceeds again we can show toast
      _lastExceededToastValue = null;
      return false;
    }

    // If user is still exceeding, show toast again ONLY if value changed
    if (_lastExceededToastValue == enteredRaw) return false;

    _lastExceededToastValue = enteredRaw;
    return true;
  }
  // bool shouldShowProposedLimitToastOnce(int enteredRaw) {
  //   if (!isSubLimitMode) return false;
  //   final bool shouldWarn = shouldShowProposedLimitExceedAlert(enteredRaw);
  //   if (!shouldWarn) return false;
  //   if (_proposedLimitToastVisible) return false;
  //   _proposedLimitToastVisible = true;
  //   Future.delayed(const Duration(milliseconds: 1500), () {
  //     _proposedLimitToastVisible = false;
  //   });
  //   return true;
  // }

  /// Returns true exactly once while the allocation warning toast is visible.
  /// Prevents stacking multiple toasts on rapid blocked key presses.
  bool shouldShowAllocationToastOnce() {
    if (_allocationToastVisible) return false;
    _allocationToastVisible = true;
    Future.delayed(const Duration(milliseconds: 1500), () {
      _allocationToastVisible = false;
    });
    return true;
  }

  // Minimal helper: fetch summary and extract existing limitCapType set
  Future<Set<int>> _existingLimitCapTypesForCurrentRim() async {
    try {
      final List<FacilitySummaryList> lists =
          await repository.getFacilitySummaryList();

      // Prefer current rim; fall back to selectedRim / getFacility.rimNo
      final int? rimTarget = selectedRim ?? getFacility.rimNo ?? rimNo;
      if (rimTarget == null) return <int>{};

      final Set<int> result = <int>{};
      for (final FacilitySummaryList summary in lists) {
        for (final RimSummary rim in summary.rims ?? const <RimSummary>[]) {
          // Match the RIM we are working on
          final int? rimFromName =
              FacilitiesSummaryViewModel().extractRimId(rim.rimName);
          if (rimFromName != rimTarget) continue;

          for (final RimGroup grp in rim.groups ?? const <RimGroup>[]) {
            for (final FacilityDis dis
                in grp.facilityLimits ?? const <FacilityDis>[]) {
              final FacilitySummaryNew? f = dis.facility;
              if (f == null) continue;

              final bool isCap = (f.limitDescription?.toString() ==
                      ServerConstants.limitCapsDescriptionIdString) ||
                  ((f.productCode ?? "").trim().toUpperCase() ==
                      ServerConstants.productCodeClt);

              if (!isCap) continue;
              if (f.limitCapType == null) continue;

              // If editing an existing row, ignore this row’s own id
              if (getFacility.facilityId != null &&
                  f.facilityId == getFacility.facilityId) {
                continue;
              }
              final int? id = int.tryParse(f.limitCapType.toString());
              if (id != null) result.add(id);
            }
          }
        }
      }
      return result;
    } catch (_) {
      return <int>{}; // on error, don't block (or you can choose to block)
    }
  }

  void onProductTypeSelected(Reference selected) {
    selectedProductType = selected;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> facilityTypeDescriptionsSelected(Reference selectedValue) async {
    getFacility.facilityDescription = selectedValue;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  //get multiple borrowers in borrower field
  Future<void> getBorrowersMap() async {
    try {
      final BorrowersMap map = await repository.getBorrowersMap();
      borrowersMap = map.responseData.map((s) => Reference(name: s)).toList();
      if (borrowersByRimInTable.isNotEmpty) {
        final Set<String> names =
            borrowersMap.map((r) => (r.name ?? "").trim()).toSet();
        borrowersByRimInTable = borrowersByRimInTable
            .where((sel) => names.contains((sel.name ?? "").trim()))
            .toList();
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Fetch borrowers and populate the dropdown items (borrowersMap)
  /// showing only the Customer RIM No in the UI.
  Future<void> getBorrowers() async {
    try {
      borrowers = await repository.getBorrowers();
      borrowersMap = borrowers.map((b) {
        final int rim = b.customerRimNo;
        return Reference(
          id: rim,
          name: rim.toString(),
        );
      }).toList();
      if (borrowersByRimInTable.isNotEmpty) {
        final Set<String> validIds = borrowersMap
            .map((r) => r.id?.toString())
            .where((id) => id != null && id.trim().isNotEmpty)
            .cast<String>()
            .toSet();

        borrowersByRimInTable = borrowersByRimInTable
            .where((sel) => validIds.contains(sel.id?.toString()))
            .toList();
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  // Called by AllocateLimitDialogBox for a given sub-limit row
  // Each Reference: id = borrowerRimNo, description = allocation amount string
  void setSubLimitAllocations(int index, List<Reference> allocations) {
    subLimitBorrowersByIndex[index] = allocations;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // Called by ConditionsDialogBox for a given sub-limit row
  void setSubLimitConditions(int index, List<Condition> conditions) {
    subLimitConditionsByIndex[index] = conditions;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // Setters called by the table UI
  void setSubLimitCurrency(int index, String? code) {
    _meta(index).currency = (code ?? "").trim().isEmpty ? null : code!.trim();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void setSubLimitTenorUnit(int index, String? unit) {
    _meta(index).tenorUnit = (unit ?? "").trim().isEmpty ? null : unit!.trim();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void setSubLimitTenorValue(int index, int? value) {
    _meta(index).tenorValue = value;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void setSubLimitIndex(int index, String? idx) {
    _meta(index).index = (idx ?? "").trim().isEmpty ? null : idx!.trim();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void setSubLimitMarginSign(int index, String? sign) {
    _meta(index).marginSign = (sign ?? "").trim().isEmpty ? null : sign!.trim();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void setSubLimitMarginValue(int index, num? value) {
    _meta(index).marginValue = value;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  T? _safeAt<T>(List<T> list, int i) =>
      (i >= 0 && i < list.length) ? list[i] : null;
  List<Map<String, dynamic>> _buildFacilitySubLimitsForSave() {
    final List<Map<String, dynamic>> result = [];
    final int? baseFacilityId =
        int.tryParse(getFacility.facilityId?.toString() ?? "null");

    for (int i = 0; i < facilitySubTypes.length; i++) {
      final FacilitySubTypes sub = facilitySubTypes[i];
      if (sub.subTypeSelected != true) continue;

      final String subName = (sub.subType ?? "").trim().toLowerCase();
      final String familyRef3 =
          (getFacility.facilityDescription?.reference3 ?? "").trim();

      final Reference matchedType = facilityTypes.firstWhere(
        (ft) {
          final bool nameOk = ((ft.name ?? "").trim().toLowerCase() == subName);
          if (!nameOk) return false;
          // keep it robust if multiple names exist: also match the family code
          // when present
          if (familyRef3.isEmpty) return true;
          return (ft.reference5 ?? "").trim() == familyRef3;
        },
        orElse: Reference.new,
      );

      final dynamic id = matchedType.id ??
          getFacility.facilityDescription?.id; // fallback just in case
      final String? reference3 = (matchedType.reference3 ??
              getFacility.facilityDescription?.reference3)
          ?.trim();

      final Map<String, dynamic> subFacilityDetails = {
        "commitmentAccountNumber":
            (sub.commitmentAccountNumber ?? ServerConstants.labelNew),
        "presentOutstanding": sub.currentOutstanding ?? 0,
        "pastDues": sub.pastDues ?? 0,
        "presentLimit": sub.existingAmounts ?? 0,
        "proposedLimit": sub.proposedLimit ?? 0,
        "currency": sub.currency ?? ServerConstants.facilityAedCurrency,
        "tenorUnit": sub.tenorUnit ?? "Days",
        "tenorValue": sub.tenorValue,
        "index": sub.index ?? 13912,
        "marginSign": sub.marginSign ?? "+",
        "marginValue": sub.marginValue,
        "limitDescription": id, //from reference
        "productCode": reference3, //from reference
        // 'facilityId': lastCreatedSubFacilityIds

        "facilityId": (sub.facilityId /* nullable, if you have it */) ??
            _safeAt<int>(lastCreatedSubFacilityIds, i),
      };
      final List<Reference> allocs = subLimitBorrowersByIndex[i] ?? const [];
      final List<Map<String, dynamic>> borrowerList = allocs.map((ref) {
        return {
          "id": {
            "facilityId": baseFacilityId,
            "borrowerRimNo": ref.id,
          },
          if ((getFacility.limitNumber ?? "").isNotEmpty)
            "subLimitNo": getFacility.limitNumber,
          "limitAllocationAmount":
              int.tryParse((ref.description ?? "").replaceAll(",", "")) ?? 0,
        };
      }).toList();

      final Map<String, dynamic> subFacilityBorrowerMap = {
        "borrowerList": borrowerList,
      };

      final List<Condition> conds = subLimitConditionsByIndex[i] ?? const [];
      final List<Map<String, dynamic>> conditionsJson =
          conds.map((c) => c.toJson()).toList();

      result.add({
        "facilitySubLimits": {
          "facilityDetails": subFacilityDetails,
          "facilityBorrowerMap": subFacilityBorrowerMap,
          "conditions": conditionsJson,
        },
      });
    }

    return result;
  }

// Helper: read sub-limit ids safely
  List<int> _extractSubFacilityIdsFromResponse(dynamic resp) {
    final List<int> ids = <int>[];
    try {
      final dynamic subs = resp?.facilitySubLimits;
      if (subs is List) {
        for (final dynamic item in subs) {
          final dynamic sl = (item is Map)
              ? item["facilitySubLimits"]
              : item?.facilitySubLimits;
          final dynamic fd =
              (sl is Map) ? sl["facilityDetails"] : sl?.facilityDetails;
          final dynamic id = (fd is Map) ? fd["facilityId"] : fd?.facilityId;
          if (id is int) ids.add(id);
          if (id is String) {
            final int? parsed = int.tryParse(id);
            if (parsed != null) ids.add(parsed);
          }
        }
      }
    } catch (_) {/* ignore & return what we collected */}
    return ids;
  }

  double calculateLargeExposureLimitAmountValues(
    Map<String, List<Reference>> referenceData,
  ) {
    final List<dynamic> referenceRawList =
        referenceData[ReferenceDataKeys.largeExposureLimit] ?? [];

    final List<Reference> referenceList = referenceRawList.map((dynamic item) {
      if (item is Reference) return item;
      if (item is Map<String, dynamic>) return Reference.fromJson(item);
      throw Exception("Unexpected item type: ${item.runtimeType}");
    }).toList();

    if (referenceList.isEmpty) return 0;
    final Reference first = referenceList.first;
    // Be forgiving with formatting (e.g., "5,000" or "10%")
    final String amountRaw =
        (first.reference1 ?? "0").replaceAll(",", "").trim();
    final double amount = double.tryParse(amountRaw) ?? 0.0;
    return amount;
  }

  double calculateLargeExposureLimitPercentageValues(
    Map<String, List<Reference>> referenceData,
  ) {
    final List<dynamic> referenceRawList =
        referenceData[ReferenceDataKeys.largeExposureLimit] ?? [];

    final List<Reference> referenceList = referenceRawList.map((dynamic item) {
      if (item is Reference) return item;
      if (item is Map<String, dynamic>) return Reference.fromJson(item);
      throw Exception("Unexpected item type: ${item.runtimeType}");
    }).toList();

    if (referenceList.isEmpty) return 0;
    final Reference first = referenceList.first;
    // Be forgiving with formatting (e.g., "5,000" or "10%")
    final String percentRaw =
        (first.reference2 ?? "0").replaceAll("%", "").trim();
    final double percentage = double.tryParse(percentRaw) ?? 0.0;
    return percentage;
  }

  double calculateLargeExposureLimit(
    Map<String, List<Reference>> referenceData,
  ) {
    // Read the raw list for LARGE_EXPOSURE_LIMIT
    final List<dynamic> referenceRawList =
        referenceData[ReferenceDataKeys.largeExposureLimit] ?? [];

    // Normalize to List<Reference>
    final List<Reference> referenceList = referenceRawList.map((dynamic item) {
      if (item is Reference) return item;
      if (item is Map<String, dynamic>) return Reference.fromJson(item);
      throw Exception("Unexpected item type: ${item.runtimeType}");
    }).toList();

    // Always use the FIRST item and ignore IDs.
    // columnsInfo = "Amount;Percentage" → reference1=Amount,
    // reference2=Percentage
    // (as per the server contract you shared)
    if (referenceList.isEmpty) return 0;
    final Reference first = referenceList.first;

    // Be forgiving with formatting (e.g., "5,000" or "10%")
    final String amountRaw =
        (first.reference1 ?? "0").replaceAll(",", "").trim();
    final String percentRaw =
        (first.reference2 ?? "0").replaceAll("%", "").trim();

    final double amount = double.tryParse(amountRaw) ?? 0.0;
    final double percentage = double.tryParse(percentRaw) ?? 0.0;

    return (amount * percentage) / 100.0;
  }

  void updateBorrowerAllocationAmount(
    Reference borrower,
    String allocationAmount,
  ) {
    borrower.description = allocationAmount;
  }

  void applyInitialCurrencyVisibility() {
    if (facilityDetail.isEmpty) return;

    final detail = facilityDetail.first;

    final formatter = NumberFormat("#,###");

    void processCurrencyCovertedFieldField({
      required double? apiAmount,
      required Reference? apiCurrency,
      required void Function(double) assignAmount,
      required void Function(Reference) assignCurrency,
      required TextEditingController mainCtrl,
      required TextEditingController convertedCtrl,
      required void Function(bool) setVisibilityFlag,
      required CurrencyField currencyField,
    }) {
      final double? amount = apiAmount;
      final Reference? currency = apiCurrency;

      // 1) Set amount into facility model
      assignAmount(amount!);

      // 2) Set currency into facility model
      if (currency != null) {
        assignCurrency(currency);
      }

      // 3) Write the raw API amount into main text controller
      mainCtrl.text = formatter.format(amount);

      if (currency == null) return;

      final String code = currency.name?.trim().toUpperCase() ??
          ServerConstants.facilityAedCurrency;
      final bool isNonAED = code != ServerConstants.aedCurrency;

      // 4) Toggle new converted field visibility
      setVisibilityFlag(isNonAED);

      if (isNonAED) {
        // Initial conversion flow
        onCurrencyChanged(currency, currencyField);
        getCurrencyRates(currency, currencyField);
      } else {
        // Direct AED formatting
        convertedCtrl.text = formatter.format(amount);
      }
    }

    processCurrencyCovertedFieldField(
      apiAmount: getFacility.presentOutstandingAmount?.toDouble(),
      apiCurrency: getFacility.presentOutstandingCurrency,
      assignAmount: (v) => getFacility.presentOutstandingAmount = v.toInt(),
      assignCurrency: (c) => getFacility.presentOutstandingCurrency = c,
      mainCtrl: presentOutstandingController,
      convertedCtrl: newPresentOutStandingController,
      setVisibilityFlag: (v) => showNewPresentOutStandingLimit = v,
      currencyField: CurrencyField.presentOutstanding,
    );

    // ------------------------------------------------------
    // Process ALL FI currency fields
    // ------------------------------------------------------

    // 1. CBD Equity 3.25%
    processCurrencyCovertedFieldField(
      apiAmount: detail.cbdEquityTier325Percent,
      apiCurrency: detail.cbdEquityTier325PercentCurrency,
      assignAmount: (v) => getFacility.cbdEquityTier325Percent = v,
      assignCurrency: (c) => getFacility.cbdEquityTier325PercentCurrency = c,
      mainCtrl: cbdEquityTier325PercentController,
      convertedCtrl: newCbdEquityTier325PercentController,
      setVisibilityFlag: (v) => showNewCbdEquityTier325PercentAmount = v,
      currencyField: CurrencyField.cbdEquityTier325Percent,
    );

    // 2. Counterparty Equity 5%
    processCurrencyCovertedFieldField(
      apiAmount: detail.counterpartyEquity5Percent,
      apiCurrency: detail.counterpartyEquity5PercentCurrency,
      assignAmount: (v) => getFacility.counterpartyEquity5Percent = v,
      assignCurrency: (c) => getFacility.counterpartyEquity5PercentCurrency = c,
      mainCtrl: counterpartyEquity5PercentController,
      convertedCtrl: newCounterpartyEquity5PercentController,
      setVisibilityFlag: (v) => showNewCounterpartyEquity5PercentAmount = v,
      currencyField: CurrencyField.counterpartyEquity5Percent,
    );

    // 3. Counterparty Total Assets 2%
    processCurrencyCovertedFieldField(
      apiAmount: detail.counterpartyTotalAssets2Percent,
      apiCurrency: detail.counterpartyTotalAssets2PercentCurrency,
      assignAmount: (v) => getFacility.counterpartyTotalAssets2Percent = v,
      assignCurrency: (c) =>
          getFacility.counterpartyTotalAssets2PercentCurrency = c,
      mainCtrl: counterpartyTotalAssets2PercentController,
      convertedCtrl: newCounterpartyTotalAssets2PercentController,
      setVisibilityFlag: (v) =>
          showNewCounterpartyTotalAssets2PercentAmount = v,
      currencyField: CurrencyField.counterpartyTotalAssets2Percent,
    );

    // 4. Proposed Limit (FI flow case)
    processCurrencyCovertedFieldField(
      apiAmount: getFacility.proposedLimit?.toDouble(),
      apiCurrency: getFacility.proposedLimitValue ??
          Reference(name: getFacility.currency),
      assignAmount: (v) => getFacility.proposedLimit = v.toInt(),
      assignCurrency: (c) => getFacility.proposedLimitValue = c,
      mainCtrl: proposedLimitController,
      convertedCtrl: newProposedLimitController,
      setVisibilityFlag: (v) => showNewProposedLimitAmount = v,
      currencyField: CurrencyField.proposedLimit,
    );

    // 5. Present Limit (if used similarly)
    processCurrencyCovertedFieldField(
      apiAmount: detail.presentLimit?.toDouble(),
      apiCurrency: getFacility.presentLimitValue,
      assignAmount: (v) => getFacility.presentLimit = v.toInt(),
      assignCurrency: (c) => getFacility.presentLimitValue = c,
      mainCtrl: presentLimitController,
      convertedCtrl: newPresentLimitController,
      setVisibilityFlag: (v) => showNewPresentLimitAmount = v,
      currencyField: CurrencyField.presentLimit,
    );

    // 6. Revised Bank Limit Proposed By FI
    processCurrencyCovertedFieldField(
      apiAmount: getFacility.proposedLimit?.toDouble(),
      apiCurrency: getFacility.proposedLimitValue ??
          Reference(name: getFacility.currency),
      assignAmount: (v) => getFacility.proposedLimit = v.toInt(),
      assignCurrency: (c) => getFacility.proposedLimitValue = c,
      mainCtrl: proposedLimitController,
      convertedCtrl: newProposedLimitController,
      setVisibilityFlag: (v) => showNewRevisedBankLimitProposedByFiAmount = v,
      currencyField: CurrencyField.revisedBankLimitProposedByFi,
    );

    // 7. Revised Bank Limit Recommended By Credit
    processCurrencyCovertedFieldField(
      apiAmount: getFacility.proposedByCc,
      apiCurrency: Reference(name: getFacility.proposedByCcCurrency),
      assignAmount: (v) => getFacility.proposedByCc,
      assignCurrency: (c) => getFacility.proposedByCcCurrency = c.name,
      mainCtrl: proposedByccController,
      convertedCtrl: newProposedByccController,
      setVisibilityFlag: (v) =>
          showNewRevisedBankLimitRecommendedByCreditAmount = v,
      currencyField: CurrencyField.revisedBankLimitRecommendedByCredit,
    );

    // 8. Excess Over Max Limit (FI Proposed)
    processCurrencyCovertedFieldField(
      apiAmount: detail.excessOverMaxLimitAllowanceByFi,
      apiCurrency: detail.excessOverMaxLimitAllowanceCurrencyByFi,
      assignAmount: (v) => getFacility.excessOverMaxLimitAllowanceByFi = v,
      assignCurrency: (c) =>
          getFacility.excessOverMaxLimitAllowanceCurrencyByFi = c,
      mainCtrl: excessOverMaxLimitAllowanceProposedByFiController,
      convertedCtrl: newExcessOverMaxLimitAllowanceProposedByFiController,
      setVisibilityFlag: (v) =>
          showNewExcessOverMaxLimitAllowanceProposedByFiAmount = v,
      currencyField: CurrencyField.excessOverMaxLimitAllowanceProposedByFi,
    );

    // 9. Excess Over Max Limit (Credit Recommended)
    processCurrencyCovertedFieldField(
      apiAmount: detail.excessOverMaxLimitAllowanceByCredit,
      apiCurrency: detail.excessOverMaxLimitAllowanceCurrencyByCredit,
      assignAmount: (v) => getFacility.excessOverMaxLimitAllowanceByCredit = v,
      assignCurrency: (c) =>
          getFacility.excessOverMaxLimitAllowanceCurrencyByCredit = c,
      mainCtrl: excessOverMaxLimitAllowanceRecommendedByCreditController,
      convertedCtrl:
          newExcessOverMaxLimitAllowanceRecommendedByCreditController,
      setVisibilityFlag: (v) =>
          showNewExcessOverMaxLimitAllowanceRecommendedByCreditAmount = v,
      currencyField:
          CurrencyField.excessOverMaxLimitAllowanceRecommendedByCredit,
    );

    //10 ProposedBy CC
    processCurrencyCovertedFieldField(
      apiAmount: getFacility.proposedByCc,
      apiCurrency: Reference(name: getFacility.proposedByCcCurrency),
      assignAmount: (v) => getFacility.proposedByCc,
      assignCurrency: (c) => getFacility.proposedByCcCurrency = c.name,
      mainCtrl: proposedByccController,
      convertedCtrl: newProposedByccController,
      setVisibilityFlag: (v) => showNewProposedByCCAmount = v,
      currencyField: CurrencyField.proposedBycc,
    );

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> getCurrencyRates(
    Reference? selectedCurrency,
    CurrencyField currencyField,
  ) async {
    try {
      final CurrencyRates rates =
          await repository.getCurrencyRates(selectedCurrency);

      final num rate = rates.rates[selectedCurrency?.name] ?? 0;

      exchangeRate = rate;

      final NumberFormat formatter = NumberFormat("#,###");

      // 1️ Determine source amount (IMPORTANT FIX)
      num rawAmount;
      switch (currencyField) {
        case CurrencyField.revisedBankLimitProposedByFi:
          rawAmount = getFacility.proposedLimit ?? 0;

        case CurrencyField.proposedBycc:
          rawAmount = getFacility.proposedByCc ?? 0;

        case CurrencyField.revisedBankLimitRecommendedByCredit:
          rawAmount = getFacility.proposedByCc ?? 0;

        case CurrencyField.proposedLimit:
          rawAmount = getFacility.proposedLimit ?? 0;

        case CurrencyField.presentOutstanding:
          rawAmount = getFacility.presentOutstandingAmount ?? 0;

        default:
          rawAmount = _currencySourceAmount(currencyField);
      }

      final TextEditingController? ctrl = _currencyController(currencyField);

      if (ctrl == null) return;

      final String currencyCode = selectedCurrency?.name?.toUpperCase() ?? "";

      // 2️ AED selected → no conversion
      if (currencyCode == ServerConstants.aedCurrency) {
        final int aedValue = rawAmount.toInt();

        ctrl.value = TextEditingValue(
          text: formatter.format(aedValue),
          selection: TextSelection.collapsed(
            offset: formatter.format(aedValue).length,
          ),
        );
        return;
      }

      //  Non-AED conversion
      if (rate <= 0) return;

      final int converted = (rawAmount * rate).toInt();

      ctrl.value = TextEditingValue(
        text: formatter.format(converted),
        selection:
            TextSelection.collapsed(offset: formatter.format(converted).length),
      );
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  num _currencySourceAmount(CurrencyField field) {
    switch (field) {
      case CurrencyField.presentLimit:
        return getFacility.presentLimit ?? 0;

      case CurrencyField.cbdEquityTier325Percent:
        return getFacility.cbdEquityTier325Percent ?? 0;

      case CurrencyField.counterpartyEquity5Percent:
        return getFacility.counterpartyEquity5Percent ?? 0;

      case CurrencyField.counterpartyTotalAssets2Percent:
        return getFacility.counterpartyTotalAssets2Percent ?? 0;

      case CurrencyField.excessOverMaxLimitAllowanceProposedByFi:
        return getFacility.excessOverMaxLimitAllowanceByFi ?? 0;

      case CurrencyField.excessOverMaxLimitAllowanceRecommendedByCredit:
        return getFacility.excessOverMaxLimitAllowanceByCredit ?? 0;

      default:
        return 0;
    }
  }

  TextEditingController? _currencyController(CurrencyField field) {
    switch (field) {
      case CurrencyField.proposedLimit:
        return newProposedLimitController;

      case CurrencyField.presentOutstanding:
        return newPresentOutStandingController;

      case CurrencyField.presentLimit:
        return newPresentLimitController;

      case CurrencyField.cbdEquityTier325Percent:
        return newCbdEquityTier325PercentController;

      case CurrencyField.counterpartyEquity5Percent:
        return newCounterpartyEquity5PercentController;

      case CurrencyField.counterpartyTotalAssets2Percent:
        return newCounterpartyTotalAssets2PercentController;

      case CurrencyField.excessOverMaxLimitAllowanceProposedByFi:
        return newExcessOverMaxLimitAllowanceProposedByFiController;

      case CurrencyField.excessOverMaxLimitAllowanceRecommendedByCredit:
        return newExcessOverMaxLimitAllowanceRecommendedByCreditController;
      case CurrencyField.revisedBankLimitProposedByFi:
        return newProposedLimitController;
      case CurrencyField.revisedBankLimitRecommendedByCredit:
        return newProposedByccController;
      case CurrencyField.proposedBycc:
        return newProposedByccController;
    }
  }

// Fetch and store exchange rate for a specific row (without touching the global
// rate)
  Future<void> getSubTypeCurrencyRate(
    int rowIndex,
    Reference selectedCurrency,
  ) async {
    try {
      final CurrencyRates rates =
          await repository.getCurrencyRates(selectedCurrency);
      _subtypeExchangeRates[rowIndex] = rates.rates[selectedCurrency.name] ?? 0;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  void disposeProposedLimitControllers() {
    for (final TextEditingController c in _subtypeProposedControllers.values) {
      c.dispose();
    }
    _subtypeProposedControllers.clear();
  }

  //limit type field dropdown
  void setLimitTypeByLabel(String picked) {
    final bool isMain =
        picked.trim().toLowerCase() == "main limit".toLowerCase();
    subLimit = isMain;
    getFacility.isMainLimit = isMain;
    if (isMain) {
      getFacility.controllingLimitNumber = null;
    } else {
      getFacility.controllingLimitNumber ??= parentControlliingNumber;
    }
    limitTypeController.text = isMain ? "Main Limit" : "Sub Limit";
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // Called by the radio's onChanged
  void onProjectFinanceChanged(Reference value) {
    getFacility.selectedProjectFinanceRelatedActivityValue = value;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // Ensure the rule is applied once data (including options) is available
  void enforceProjectFinanceRuleIfNeeded() {
    if (!isProjectFinanceActivityEnabled) {
      getFacility.selectedProjectFinanceRelatedActivityValue =
          projectFinanceDefaultRef;
      return;
    }
    if (showCreateFacilityForm &&
        getFacility.selectedProjectFinanceRelatedActivityValue == null) {
      getFacility.selectedProjectFinanceRelatedActivityValue =
          projectFinanceDefaultRef;
      return;
    }
    getFacility.selectedProjectFinanceRelatedActivityValue ??=
        projectFinanceDefaultRef;
  }

  void onCurrencyChanged(Reference? ref, CurrencyField? currencyField) {
    selectedCurrencyCode = (ref?.name ?? "").toUpperCase();
    final bool isAed = selectedCurrencyCode == ServerConstants.aedCurrency;

    // Map each enum to its visibility setter, then call it
    final Map<CurrencyField, void Function(bool)> togglers =
        <CurrencyField, void Function(bool)>{
      CurrencyField.presentLimit: (v) => showNewPresentLimitAmount = v,
      CurrencyField.presentOutstanding: (v) =>
          showNewPresentOutStandingLimit = v,
      CurrencyField.proposedLimit: (v) => showNewProposedLimitAmount = v,
      CurrencyField.revisedBankLimitProposedByFi: (v) =>
          showNewRevisedBankLimitProposedByFiAmount = v,
      CurrencyField.excessOverMaxLimitAllowanceProposedByFi: (v) =>
          showNewExcessOverMaxLimitAllowanceProposedByFiAmount = v,
      CurrencyField.cbdEquityTier325Percent: (v) =>
          showNewCbdEquityTier325PercentAmount = v,
      CurrencyField.counterpartyEquity5Percent: (v) =>
          showNewCounterpartyEquity5PercentAmount = v,
      CurrencyField.counterpartyTotalAssets2Percent: (v) =>
          showNewCounterpartyTotalAssets2PercentAmount = v,
      CurrencyField.revisedBankLimitRecommendedByCredit: (v) =>
          showNewRevisedBankLimitRecommendedByCreditAmount = v,
      CurrencyField.excessOverMaxLimitAllowanceRecommendedByCredit: (v) =>
          showNewExcessOverMaxLimitAllowanceRecommendedByCreditAmount = v,
      CurrencyField.proposedBycc: (v) => showNewProposedByCCAmount = v,
    };

    // Apply the toggle for the current field (show when non-AED)
    togglers[currencyField]?.call(!isAed);

    // The rest remains the same
    disableFxRates = !isAed;
    syncExcessAmountCurrency();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Syncs Excess Amount currency and value with Proposed Limit.
  /// This ensures the Excess Amount field always uses the same currency
  /// and amount as the Proposed Limit field.
  void syncExcessAmountCurrency() {
    final DynamicFormState? form = dynamicFormKey.currentState;
    if (form == null) return;
    final String proposedCurrency = getFacility.proposedLimitValue?.name ??
        selectedCurrencyCode ??
        ServerConstants.aedCurrency;

    form.updateFieldValue("excessAmount", {
      "fromCurrency": proposedCurrency,
      "fromVal": null,
      "aedEquivalent": null,
    });
  }

  void changeBorrower(Borrower? selected) {
    if (selected == null) return;
    getFacility.rimNo = selected.customerRimNo;
    selectedRim = selected.customerRimNo; // keeps your existing fallback
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Fetches the dynamic form sections for facilities from the repository.
  /// Updates the `sections` variable with the retrieved data.
  /// Emits an error state if the fetch fails
  Future<void> getDynamicForm(int? selectedDescriptionId) async {
    if (!isFIFlow) {
      try {
        sections = await repository.getFacilitiesDynamicForm(
          typeID: ServerConstants.dynamicFormFacilityID,
          subTypeID: selectedDescriptionId,
          commitmentAccountNumbers: commitmentAccountNumberItemsForUi,
        );

        //filter Index refDataDropdown options using limitCategory
        _filterDynamicIndexOptionsByLimitCategory();
      } catch (e) {
        AlertManager().showFailureToast(e.toString());
      }
    }
  }

  void _filterDynamicIndexOptionsByLimitCategory() {
    final String cat = (limitCategory ?? "").trim().toUpperCase();
    if (cat.isEmpty) return;

    for (final section in sections) {
      for (final row in (section.rows ?? const <RowElement>[])) {
        for (final field in (row.fields ?? const <DynamicField>[])) {
          // Only grids/tables can contain profitGrid.index column
          if (field.controlType != FieldType.grid &&
              field.controlType != FieldType.table) {
            continue;
          }

          final cols = field.columnInfoList ?? const <DynamicGridField>[];
          for (final col in cols) {
            final df = col.dynamicField;

            // Target only the INDEX refDataDropdown inside grid column "index"
            final bool isIndexRefDropdown =
                df.controlType == FieldType.refDataDropdown &&
                    (df.operationKey ?? "").trim().toUpperCase() == "INDEX" &&
                    df.key == "index";

            if (!isIndexRefDropdown) continue;

            final original = df.optionList ?? const <Option>[];
            if (original.isEmpty) continue;

            // Filter by metaData.reference2 == limitCategory (F/N)
            final filtered = original.where((o) {
              final meta = o.metaData;
              if (meta is Reference) {
                final ref2 = (meta.reference2 ?? "").trim().toUpperCase();
                return ref2.isEmpty || ref2 == cat;
              }
              // If metaData missing, keep it (defensive)
              return true;
            }).toList();

            // Apply only if filtering produces something, else keep original
            if (filtered.isNotEmpty) {
              df.optionList = filtered;
            }
          }
        }
      }
    }
  }

  /// Fetch standard conditions for CREATE flow and map them to Condition
  /// objects
  Future<void> getFacilityConditionsList({bool isSubLimitTable = false}) async {
    try {
      conditionsStandard = await repository.getFacilityConditionsList(
        FacilityConditionsFilter(
          condition: "STANDARD_CONDITIONS",
          limitGroup: getLimitGroupName(getFacility.limitGroup).name?.trim(),
          limitDesc: getLimitCode(getFacility.limitCode).description?.trim(),
          limitCode: getLimitCode(getFacility.limitCode).reference3?.trim(),
          limitType: isSubLimitTable
              ? "Sub Limit"
              : (subLimit ?? false)
                  ? "Main Limit"
                  : "Sub Limit",
        ),
      );

      conditionsNonStandard = await repository.getFacilityConditionsList(
        FacilityConditionsFilter(
          condition: "NON-STANDARD_CONDITIONS",
          limitGroup: getLimitGroupName(getFacility.limitGroup).name?.trim(),
          limitDesc: getLimitCode(getFacility.limitCode).description?.trim(),
          limitCode: getLimitCode(getFacility.limitCode).reference3?.trim(),
          limitType: isSubLimitTable
              ? "Sub Limit"
              : (subLimit ?? false)
                  ? "Main Limit"
                  : "Sub Limit",
        ),
      );

      if (getFacility.limitGroup == ServerConstants.projectSpecificLimitsID ||
          getFacility.limitGroup == ServerConstants.projectStandByLimitID) {
        contractingConditionsStandard =
            await repository.getFacilityConditionsList(
          FacilityConditionsFilter(
            condition: "CONTRACTING-STANDARD_CONDITIONS",
            limitGroup: getLimitGroupName(getFacility.limitGroup).name?.trim(),
            limitDesc: getLimitCode(getFacility.limitCode).description?.trim(),
            limitCode: getLimitCode(getFacility.limitCode).reference3?.trim(),
            limitType: isSubLimitTable
                ? "Sub Limit"
                : (subLimit ?? false)
                    ? "Main Limit"
                    : "Sub Limit",
          ),
        );
        contractingStandardCondition = contractingConditionsStandard
            .map(_mapFacilityConditionToStandardCondition)
            .toList();
      }
      standardCondition = conditionsStandard
          .map(_mapFacilityConditionToStandardCondition)
          .toList();
      nonStandardCondition = conditionsNonStandard
          .map(_mapFacilityConditionToNonStandardCondition)
          .toList();
      initialNonStandardConditionCount = nonStandardCondition.length;
      // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  Reference getLimitGroupName(int? limitGroupId) {
    return limitGroups.firstWhere(
      (r) => (r.id) == limitGroupId,
      orElse: () => Reference(id: limitGroupId),
    );
  }

  Reference getLimitCapName(num? limitGroupId) {
    return limitCapsType.firstWhere(
      (r) => (r.id) == limitGroupId,
      orElse: () => Reference(id: int.tryParse(limitGroupId.toString())),
    );
  }

  Reference getLimitDescriptionID(String? limitDescription) {
    return facilityDescriptions.firstWhere(
      (r) => (r.name) == limitDescription,
      orElse: () => Reference(
        id: ServerConstants.facilityTypeOthersID,
      ),
    ); //TODO passing others - ID as fall back
  }

  Reference getLimitCode(int? limitCode) {
    return facilityDescriptions.firstWhere(
      (r) => (r.id) == limitCode,
      orElse: () => Reference(id: limitCode),
    );
  }

  Condition _mapFacilityConditionToStandardCondition(
    FacilityCondition facilityCondition,
  ) {
    return Condition(
      // For new create, there is no existing facility-condition row in DB
      facilityConditionId: null,

      rimNo: getFacility.rimNo,
      limitType: (subLimit ?? false)
          ? ServerConstants.facilityMainLimit
          : ServerConstants.facilitySubLimit,

      // Product code / "All"
      facilityType:
          selectedProductType?.name ?? ServerConstants.allFacilityProductType,

      conditionId: facilityCondition.referenceDataListId,

      description: facilityCondition.reference3?.trim(),

      // Create flow defaults: not amended, not waived
      isWaivedOff: false,
      isAmended: false,
      isSelected: true,
      conditionType: ConditionType.standard,
    );
  }

  bool canDeleteNonStandardCondition(int index) {
    final bool isApproved = (facilityMasterId ?? 0) > 0;
    if (!isApproved) return true;
    return index >= initialNonStandardConditionCount;
  }

  Condition _mapFacilityConditionToNonStandardCondition(
    FacilityCondition facilityCondition,
  ) {
    return Condition(
      // For new create, there is no existing facility-condition row in DB
      facilityConditionId: null,

      rimNo: getFacility.rimNo,
      limitType: (subLimit ?? false)
          ? ServerConstants.facilityMainLimit
          : ServerConstants.facilitySubLimit,

      // Product code / "All"
      facilityType:
          selectedProductType?.name ?? ServerConstants.allFacilityProductType,

      conditionId: facilityCondition.referenceDataListId,

      description: facilityCondition.reference3?.trim(),

      // Create flow defaults: not amended, not waived
      isWaivedOff: false,
      isAmended: false,
      isSelected: false,
      conditionType: ConditionType.nonStandard,
    );
  }

  Future<void> getProjectList(int? limitGroup, int? rimNo) async {
    try {
      final ProjectListResponse list = await repository.getProjectList(
        limitGroup: ServerConstants.projectStandByLimitID, // NEW
        rimNo: rimNo,
      );
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
        final bool aIsAed =
            (a.name ?? "").toUpperCase() == ServerConstants.aedCurrency;
        final bool bIsAed =
            (b.name ?? "").toUpperCase() == ServerConstants.aedCurrency;
        return (bIsAed ? 1 : 0) - (aIsAed ? 1 : 0);
      });
      final Reference aed = currencyCodes.firstWhere(
        (r) => (r.name ?? r.name)?.toUpperCase() == ServerConstants.aedCurrency,
        orElse: () =>
            currencyCodes.isNotEmpty ? currencyCodes.first : Reference(),
      );

      final String aedCode = aed.name ?? ServerConstants.aedCurrency;
      facilityDetails.currency ??= aedCode;
      selectedCurrencyCode = facilityDetails.currency
          // ?? security.proposedSecurityAmtCurrency?.name
          
          ?.toUpperCase();

      final bool isAed = selectedCurrencyCode == ServerConstants.aedCurrency;
      showNewProposedLimitAmount = !isAed;
      disableFxRates = !isAed;
      Globals.dynamicFormCurrencyCodes = currencyCodes
          .map(
            (ref) => Option(key: ref.id.toString(), pairValue: ref.name ?? ""),
          )
          .toList();
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  Future<void> getFacilitySubTypes() async {
    facilitySubTypes = facilityTypes
        .where((factyType) {
          final String? ref3 =
              getFacility.facilityDescription?.reference3?.trim();
          final String? ref5 = factyType.reference5?.trim();
          return ref3 != null &&
              ref3.isNotEmpty &&
              ref5 != null &&
              ref5.isNotEmpty &&
              ref5 == ref3;
        })
        .map(
          (factyType) => FacilitySubTypes(
            subType: factyType.name,
            subTypeSelected: false,
          ),
        )
        .toList();
  }

  Future<void> getCountries() async {
    try {
      countryList = await CustomerRepository.instance.getCountries();
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// limit caps ------------
  /// for single borrower credit application limit caps facility type
  Future<bool> saveSingleBorrowerLimitCaps(bool navigateToHomePage) async {
    try {
      if (state.isSaveLoading || state.isSaveAndContinueLoading) return false;
      emit(
        state.copyWith(
          isButtonLoading: false,
          isSaveLoading: !navigateToHomePage,
          isSaveAndContinueLoading: navigateToHomePage,
        ),
      );
      final bool isValid = formKey.currentState?.validate() ?? false;
      if (!isValid) {
        AlertManager().showFailureToast(
          "requestInformation.requestInformation.requiredFeild".tr(),
        );
        emit(
          state.copyWith(
            isButtonLoading: false,
            isSaveLoading: false,
            isSaveAndContinueLoading: false,
          ),
        );
        return false;
      }
      final Set<int> existing = await _existingLimitCapTypesForCurrentRim();
      final int capTypeAboutToSave =
          _numOr(facilityDetails.limitCapType, limitCapType ?? 14492).toInt();
      if (existing.contains(capTypeAboutToSave)) {
        AlertManager().showFailureToast(
          "This Limit Cap Type already exists for this RIM.",
        );

        emit(
          state.copyWith(
            isButtonLoading: false,
            isSaveLoading: false,
            isSaveAndContinueLoading: false,
          ),
        );

        return false;
      }
      formKey.currentState?.save();
      getFacility.appRefNo = Globals.request?.applicationRefNo;
      getFacility.rimNo = rimNo;
      getFacility.additionalDetails =
          isFIFlow ? null : dynamicFormDocument.toString();
      final LimitsFacilityResponse resp =
          await repository.saveFacilityDetailsNewSingleBorrower(
        facilityDetails: _buildSingleBorrowerSave(),
      );
      // --- switch to existing flow and hydrate details immediately ---
      showCreateFacilityForm = false;
      getFacility.facilityId = resp.facilityDetails!.facilityId! as int;
      existingFacilityId = getFacility.facilityId; // <--- add this
      getFacility.limitNumber =
          resp.facilityDetails?.limitNo ?? getFacility.limitNumber;

      // If we are staying on the page, fetch the freshly created facility’s
      // details
      if (!navigateToHomePage && existingFacilityId != null) {
        final num rim = resp.facilityDetails?.rimNo ??
            selectedRim ??
            getFacility.rimNo ??
            rimNo ??
            0;
        if (rim != 0) {
          await getFacilityDetails(
            existingFacilityId,
            rim.toInt(),
            facilityMasterId: facilityMasterId,
          );
        }
      }
      emit(
        state.copyWith(
          isButtonLoading: false,
          isSaveLoading: false,
          isSaveAndContinueLoading: false,
        ),
      );
      AlertManager().showSuccessToast("Saved successfully");
      // deleteDraft(); // Fire-and-forget: removes temp draft from backend
      if (navigateToHomePage) router.go(Routes.securitySummaryView);
      isApiError = false;
      return true;
    } catch (message) {
      isApiError = false;
      AlertManager().showFailureToast(message.toString());
      emit(
        state.copyWith(
          isButtonLoading: false,
          isSaveLoading: false,
          isSaveAndContinueLoading: false,
        ),
      );
      return false;
    }
  }

  @override
  Future<void> close() {
    // unregisterDraftCallback();
    return super.close();
  }

  FacilityDetails _buildSingleBorrowerSave() {
    final String appRef =
        _strOr(Globals.request?.applicationRefNo, ""); // “appRefNo”
    final int grp = _numOr(Globals.request?.groupId, 0).toInt(); // “groupId”
    const String product = ServerConstants.productCodeClt; // “productCode”

    final num limitDesc = _numOr(
      (getFacility.facilityDescription?.id is num)
          ? (getFacility.facilityDescription?.id as num?)
          : num.tryParse(getFacility.facilityDescription?.id?.toString() ?? ""),
      0,
    );
    final int presentOutstanding = int.tryParse(
          getFacility.presentOutstandingCCValue?.description ?? "",
        ) ??
        (facilityDetail.isNotEmpty
            ? (facilityDetail.first.presentOutstanding?.toInt() ?? 0)
            : 0);

    final String currency = _strOr(
      selectedCurrencyCode,
      ServerConstants.facilityAedCurrency,
    ); // “currency””

    final int proposedLimit = _numOr(
      getFacility.proposedLimit,
      int.tryParse(
            (getFacility.presentOutstandingCCValue?.description ?? "")
                .replaceAll(",", ""),
          ) ??
          (parentProposedLimit ?? 0),
    ).toInt(); // “proposedLimit”

    final num? proposedLimitAed = currency.toUpperCase() ==
            ServerConstants.facilityAedCurrency
        ? proposedLimit
        : (num.tryParse(newProposedLimitController.text.replaceAll(",", "")));

    final int proposedByCc =
        _numOr(facilityDetails.proposedByCc, 0).toInt(); // “proposedByCc”
    final String groupName = getLimitCapName(facilityDetails.limitCapType)
        .name!
        .trim(); // “limitGroupName”
    final int group = _numOr(limitGroup, 14507).toInt(); // “limitGroup”
    final int capType =
        _numOr(facilityDetails.limitCapType, 14492).toInt(); // “limitCapType”
    final bool isMain = _boolOr(subLimit, true); // “isMainLimit”
    return FacilityDetails(
      facilityId: existingFacilityId,
      rimNo: rimNo ?? Globals.request?.customerRimNo,
      groupId: grp,
      productCode: product,
      appRefNo: appRef,
      proposedLimitAED: proposedLimitAed,
      limitDescription: limitDesc,
      limitCategory: limitCategory?.trim().toUpperCase(), //"reference2": "N",
      presentOutstanding: presentOutstanding,
      currency: currency,
      isSharedLimit: _yesNoToBool(getFacility.sharedLimit, false),
      presentLimit: _numOr(
        getFacility.presentLimit,
        (facilityDetail.isNotEmpty
                ? facilityDetail.first.presentLimit?.toInt()
                : int.tryParse(getFacility.limitAmount?.description ?? "") ??
                    0) ??
            0,
      ),
      originalLimit: _numOr(
        getFacility.originalLimit,
        (facilityDetail.isNotEmpty
                ? facilityDetail.first.originalLimit?.toInt()
                : int.tryParse(getFacility.limitAmount?.description ?? "") ??
                    0) ??
            0,
      ),
      proposedLimit: proposedLimit,
      proposedByCc: proposedByCc,
      isMainLimit: isMain,
      limitGroupName: groupName,
      limitGroup: group,
      limitCapType: capType,
    );
  }

  /// limit caps----------------
  /// for Group borrower credit application limit caps facility type
  Future<bool> saveGroupBorrowerLimitCaps(bool navigateToHomePage) async {
    try {
      // Hard block duplicates before validations
      final Set<int> existing = await _existingLimitCapTypesForCurrentRim();
      final int capTypeAboutToSave =
          _numOr(facilityDetails.limitCapType, limitCapType ?? 14492).toInt();
      if (existing.contains(capTypeAboutToSave)) {
        AlertManager().showFailureToast(
          "This Limit Cap Type already exists for this RIM.",
        );
        return false;
      }

      if (state.isSaveLoading || state.isSaveAndContinueLoading) return false;

      emit(
        state.copyWith(
          isButtonLoading: true,
          isSaveLoading: !navigateToHomePage,
          isSaveAndContinueLoading: navigateToHomePage,
        ),
      );

      final int? capFromVm = getFacility.proposedLimit;
      final int? capFromApi = (facilityDetail.isNotEmpty)
          ? facilityDetail.first.proposedLimit?.toInt()
          : null;
      final int? effectiveCap = capFromVm ?? capFromApi;

      if (isGroupCapRequired) {
        final bool isCreate = showCreateFacilityForm; // your existing flag
        final bool userFieldEmpty = proposedCapEdited
            ? ((proposedCapRaw ?? "").trim().isEmpty)
            // untouched in CREATE = empty, untouched in UPDATE = allowed
            : isCreate;

        if (userFieldEmpty) {
          AlertManager().showFailureToast(
            "requestInformation.requestInformation.requiredFeild".tr(),
          );
          emit(
            state.copyWith(
              isButtonLoading: false,
              isSaveLoading: false,
              isSaveAndContinueLoading: false,
            ),
          );
          return false;
        }

        // Keep existing rule, but compare against the right cap:
        final int capForCheck = proposedCapEdited
            ? (int.tryParse(proposedCapRaw!) ?? 0)
            : (effectiveCap ?? 0);
        final bool hasViolation = borrowersByRimInTable.any((ref) {
          final entered =
              int.tryParse((ref.description ?? "").replaceAll(",", "")) ?? 0;
          return entered > capForCheck;
        });
        if (hasViolation) {
          AlertManager()
              .showFailureToast("Individual limit is exceeding group limit");
          emit(
            state.copyWith(
              isButtonLoading: false,
              isSaveLoading: false,
              isSaveAndContinueLoading: false,
            ),
          );
          return false;
        }
      }

      final bool isValid = formKey.currentState?.validate() ?? false;

      if (!isValid) {
        AlertManager().showFailureToast(
          "requestInformation.requestInformation.requiredFeild".tr(),
        );
        emit(
          state.copyWith(
            isButtonLoading: false,
            isSaveLoading: false,
            isSaveAndContinueLoading: false,
          ),
        );
        return false;
      }
      formKey.currentState?.save();
      getFacility.appRefNo = Globals.request?.applicationRefNo;
      getFacility.rimNo = getFacility.rimNo;
      getFacility.additionalDetails =
          isFIFlow ? null : dynamicFormDocument.toString();
      final LimitsFacilityResponse resp =
          await repository.saveFacilityDetailsNewGroupBorrower(
        facilityDetails: _buildSingleBorrowerSave(),
        facilityBorrowerMap: buildCompanyBorrowerMapForSave(),
      );
      // --- switch to existing flow and hydrate details immediately ---
      showCreateFacilityForm = false;
      getFacility.facilityId = resp.facilityDetails!.facilityId! as int;
      existingFacilityId = getFacility.facilityId; // <--- add this
      getFacility.limitNumber =
          resp.facilityDetails?.limitNo ?? getFacility.limitNumber;
      groupId = getFacility.groupId;
      limitCapType = getFacility.limitCapType;

      // If we are staying on the page, fetch the freshly created facility’s
      // details
      if (!navigateToHomePage && existingFacilityId != null) {
        final num rim = resp.facilityDetails?.rimNo ??
            selectedRim ??
            getFacility.rimNo ??
            rimNo ??
            0;
        if (rim != 0) {
          await getFacilityDetails(
            existingFacilityId,
            rim.toInt(),
            groupId: groupId,
            limitCapType: limitCapType,
            facilityMasterId: facilityMasterId,
          );
        }
      }
      emit(
        state.copyWith(
          isButtonLoading: false,
          isSaveLoading: false,
          isSaveAndContinueLoading: false,
        ),
      );
      AlertManager().showSuccessToast("Saved successfully");
      // deleteDraft(); // Fire-and-forget: removes temp draft from backend
      if (navigateToHomePage) router.go(Routes.securitySummaryView);
      isApiError = false;
      return true;
    } catch (message) {
      isApiError = false;
      AlertManager().showFailureToast(message.toString());
      emit(
        state.copyWith(
          isButtonLoading: false,
          isSaveLoading: false,
          isSaveAndContinueLoading: false,
        ),
      );
      return false;
    }
  }

  //payload limit caps at entity level  for group borrower case
  FacilityBorrowerMap buildCompanyBorrowerMapForSave() {
    final Map<String, String> enteredByRim = {
      for (final Reference ref in borrowersByRimInTable)
        (ref.id ?? "").toString(): (ref.description ?? "").trim(),
    };

    final List<Customer> customers = limitCapsCustomerList ?? const [];
    final List<Map<String, Object?>> companyBorrowerList = customers.map((c) {
      final String rimStr = (c.customerRimNo ?? "").toString();

      // Look up the row saved in borrowersByRimInTable to fetch subLimitNo if
      // any
      final Reference rowRef = borrowersByRimInTable.firstWhere(
        (r) => (r.id?.toString() ?? "") == rimStr,
        orElse: Reference.new,
      );

      final String subNo = (rowRef.reference1 ?? "").trim();
      final String cleaned =
          (enteredByRim[rimStr] ?? "").replaceAll(",", "").trim();
      final int? amount = cleaned.isEmpty ? 0 : int.tryParse(cleaned);

      final int? rimInt = int.tryParse(rimStr);
      final int? original =
          rimInt != null ? groupCapsOriginalByRim[rimInt] : null;
      final int? present =
          rimInt != null ? groupCapsPresentByRim[rimInt] : null;

      return {
        "id": {"facilityId": existingFacilityId, "borrowerRimNo": rimStr},
        if (subNo.isNotEmpty)
          "subLimitNo": subNo, //send only when you have it (update)
        "limitAllocationAmount": amount, // <-- null when not present/invalid
        "presentLimitAllocation": present, // <-- send null instead of 0
        "originalLimitAllocation": original, // <-- send null instead of 0
      };
    }).toList();

    return FacilityBorrowerMap(companyBorrowerList: companyBorrowerList);
  }

  ///facility limits---------------
  ///for all facilites expcept limit caps
  Future<bool> saveContinueOnPressed(bool navigateToHomePage) async {
    try {
      if (hasInvalidSubTypeProposedLimit()) {
        AlertManager().showFailureToast(
          "Sub-limit total cannot exceed Proposed Limit",
        );
        return false;
      }

      if (state.isSaveLoading || state.isSaveAndContinueLoading) return false;
      emit(
        state.copyWith(
          isButtonLoading: true,
          isSaveLoading: !navigateToHomePage,
          isSaveAndContinueLoading: navigateToHomePage,
        ),
      );

      final bool isValid = formKey.currentState?.validate() ?? false;
      final bool isDynamicFormValid = (isFIFlow || sections.isEmpty)
          ? true
          : dynamicFormKey.currentState?.validate() ?? false;
      if (!isValid || !isDynamicFormValid) {
        AlertManager().showFailureToast(
          "requestInformation.requestInformation.requiredFeild".tr(),
        );
        emit(
          state.copyWith(
            isButtonLoading: false,
            isSaveLoading: false,
            isSaveAndContinueLoading: false,
          ),
        );
        return false;
      }

      formKey.currentState?.save();
      dynamicFormKey.currentState?.save();
      getFacility.appRefNo = Globals.request?.applicationRefNo;
      getFacility.rimNo = getFacility.rimNo;

      getFacility.additionalDetails =
          isFIFlow ? null : dynamicFormDocument.toString();

      // Only send borrower map when Shared Limit == YES
      final bool isShared = _yesNoToBool(
        getFacility.sharedLimit,
        facilityDetail.isNotEmpty
            ? (facilityDetail.first.isSharedLimit ?? false)
            : false,
      );
      final FacilityBorrowerMap facilityBorrowerMap = isShared
          ? _buildFacilityBorrowerMapForSave()
          : const FacilityBorrowerMap(borrowerList: []);

      final LimitsFacilityResponse resp =
          await repository.saveFacilityDetailsNew(
        facilityDetails: _buildFacilityDetailsForSave(),
        facilityBorrowerMap: facilityBorrowerMap,
        defacultFeeRates: feeDefualtRate,
        sections: sections,
        condition: [...standardCondition, ...nonStandardCondition],
        facilitySubLimits: facilitySubTypes.isNotEmpty
            ? _buildFacilitySubLimitsForSave()
            : const [],
      );

      // --- switch to existing flow and hydrate details immediately ---
      showCreateFacilityForm = false;
      // collect any sub-limit ids
      lastCreatedSubFacilityIds = _extractSubFacilityIdsFromResponse(resp);
      getFacility.facilityId = resp.facilityDetails!.facilityId! as int;
      existingFacilityId = getFacility.facilityId; // <--- add this
      getFacility.limitNumber =
          resp.facilityDetails?.limitNo ?? getFacility.limitNumber;

      // If we are staying on the page, fetch the freshly created facility’s
      // details
      if (!navigateToHomePage && existingFacilityId != null) {
        final int rim = selectedRim ?? getFacility.rimNo ?? rimNo ?? 0;
        if (rim != 0) {
          await getFacilityDetails(
            existingFacilityId,
            rim,
            facilityMasterId: facilityMasterId,
          ); //TODO need to fix error in API call
        }
      }
      emit(
        state.copyWith(
          isButtonLoading: false,
          isSaveLoading: false,
          isSaveAndContinueLoading: false,
        ),
      );
      AlertManager().showSuccessToast("Saved successfully");
      // deleteDraft(); // Fire-and-forget: removes temp draft from backend
      if (navigateToHomePage) {
        router.go(Routes.securitySummaryView);
        facilitySubTypes.clear();
        conditionsStandard.clear();
        standardCondition.clear();
        nonStandardCondition.clear();
      }
      isApiError = false;
      return true;
    } catch (message) {
      isApiError = false;
      AlertManager().showFailureToast(message.toString());
      emit(
        state.copyWith(
          isButtonLoading: false,
          isSaveLoading: false,
          isSaveAndContinueLoading: false,
        ),
      );
      return false;
    }
  }

  FacilityDetails _buildFacilityDetailsForSave() {
    final String code = (mandatoryFeeTableRows ?? "").trim().toUpperCase();

    final bool hasPeriod =
        getFacility.limitAvailabilityPeriod?.trim().isNotEmpty ?? false;
    final String? limitAvailIso = hasPeriod
        ? null
        : getFacility.limitAvailabilityDate?.toUtc().toIso8601String();

    final bool shouldSendGeneralProject = isProjectFinanceNo &&
        !(getFacility.projectName?.name ?? "").trim().isNotEmpty &&
        projectNameSelectedForUi != null &&
        projectNameSelectedForUi!.isNotEmpty;

    final String projectName = shouldSendGeneralProject
        ? projectNameSelectedForUi!.first.name!
        : _strOr(getFacility.projectName?.name, "");

    final bool isProjectCodeAllowed =
        limitGroup == ServerConstants.projectSpecificLimitsID ||
            limitGroup == ServerConstants.projectStandByLimitID;

    final String? projectCode = isProjectCodeAllowed &&
            projectName.trim().isNotEmpty &&
            projectName != "General"
        ? _projectCodeFromName(projectName)
        : null;

    final double? aedValue =
        double.tryParse(newProposedLimitController.text.replaceAll(",", ""));

    final double? foreignValue =
        double.tryParse(proposedLimitController.text.replaceAll(",", ""));

    final double proposedLimitAED =
        (aedValue == null || aedValue == 0) ? (foreignValue ?? 0) : aedValue;

    return FacilityDetails(
      limitCapType: isFIFlow
          ? null
          : _numOr(limitCapsFromSummary ?? facilityDetails.limitCapType, 14492)
              .toInt(),
      limitAvailabilityDate: limitAvailIso,
      excessOverMaxLimitAllowanceByCc:
          getFacility.excessOverMaxLimitAllowanceByCredit,
      excessOverMaxLimitAllowanceCurrencyByCc:
          getFacility.excessOverMaxLimitAllowanceCurrencyByCredit?.name ??
              ServerConstants.aedCurrency,
      limitAvailabilityPeriod:
          hasPeriod ? getFacility.limitAvailabilityPeriod?.trim() : null,
      excessOverMaxLimitAllowance: getFacility.excessOverMaxLimitAllowanceByFi,
      tenorUnit: getFacility.tenorUnit?.name ?? period.first.name,
      tenorValue: getFacility.tenorValue,
      type: facilityDetail.isNotEmpty ? facilityDetail.first.type : null,
      facilitySecurityDetailId: facilityDetail.isNotEmpty
          ? facilityDetail.first.facilitySecurityDetailId
          : null,
      facilitySecurityId: facilityDetail.isNotEmpty
          ? facilityDetail.first.facilitySecurityId
          : null,
      excessOverMaxLimitAllowanceCurrency:
          getFacility.excessOverMaxLimitAllowanceCurrencyByFi?.name ??
              ServerConstants.aedCurrency,
      proposedByCc: getFacility.proposedByCc,
      proposedByCcCurrency:
          getFacility.proposedByCcCurrency ?? ServerConstants.aedCurrency,
      proposedByccAED:
          double.tryParse(newProposedByccController.text.replaceAll(",", "")) ??
              double.tryParse(proposedByccController.text.replaceAll(",", "")),
      cbdEquityTier325Percent: getFacility.cbdEquityTier325Percent,
      cbdEquityTier325PercentAED: double.tryParse(
            newCbdEquityTier325PercentController.text.replaceAll(",", ""),
          ) ??
          double.tryParse(
            cbdEquityTier325PercentController.text.replaceAll(",", ""),
          ),
      cbdEquityTier325PercentCurrency:
          getFacility.cbdEquityTier325PercentCurrency?.name ??
              ServerConstants.aedCurrency,
      counterpartyEquity5Percent: getFacility.counterpartyEquity5Percent,
      counterpartyEquity5PercentCurrency:
          getFacility.counterpartyEquity5PercentCurrency?.name ??
              ServerConstants.aedCurrency,
      counterpartyTotalAssets2Percent:
          getFacility.counterpartyTotalAssets2Percent,
      counterpartyTotalAssets2PercentCurrency:
          getFacility.counterpartyTotalAssets2PercentCurrency?.name ??
              ServerConstants.aedCurrency,
      isMainLimit: _boolOr(subLimit, true),
      controllingLimitNo: showCreateFacilityForm && subLimit!
          ? null
          : (!_boolOr(subLimit, true)
              ? (parentControlliingNumber?.isNotEmpty == true
                  ? parentControlliingNumber
                  : null)
              : null),
      facilityId: showCreateFacilityForm
          ? null
          : num.tryParse(getFacility.facilityId?.toString() ?? ""),
      limitNo: showCreateFacilityForm ? null : (facilityDetail.first.limitNo),
      limitCategory: limitCategory?.trim().toUpperCase(),
      isCommitted: _yesNoToBool(getFacility.committedValues, false),
      commitmentAccountNumber: getFacility.commitmentAccountNumber?.name ??
          getFacility.commitmentAccountNumber?.id?.toString() ??
          "NEW",
      rimNo: _numOr(getFacility.rimNo, selectedRim!),
      groupId: _numOr(Globals.request?.groupId, 0).toInt(),
      appRefNo: _strOr(Globals.request?.applicationRefNo, ""),
      productCode:
          _strOr(code, getFacility.facilityDescription?.reference3 ?? ""),
      limitDescription: _numOr(
        (getFacility.facilityDescription?.id is num)
            ? (getFacility.facilityDescription?.id as num?)
            : num.tryParse(
                getFacility.facilityDescription?.id?.toString() ?? "",
              ),
        getLimitDescriptionID(limitDescriptionController.text).id ?? 0,
      ),
      isDraft: false,
      facilityTitle: _strOr(getFacility.facilityTitle, ""),
      currency: _strOr(
        getFacility.proposedLimitValue?.name ??
            (facilityDetail.isNotEmpty
                ? facilityDetail.first.currency
                : null) ??
            ServerConstants.facilityAedCurrency,
        ServerConstants.facilityAedCurrency,
      ),
      forIslamic: _strOr(getFacility.selectedProductTypeValue?.name, ""),
      sustainabilityClassification: _strOr(sustainabilityClassificationCsv, ""),
      advanceType: getFacility.advanceTypeValue?.id,
      seniority: getFacility.seniorityValue?.id,
      sectorDescription: getFacility.sector?.id,
      presentOutstandingAED: double.tryParse(
            newPresentOutStandingController.text.replaceAll(",", ""),
          ) ??
          0,
      proposedLimit:
          _numOr(getFacility.proposedLimit, parentProposedLimit ?? 0),
      proposedLimitAED: proposedLimitAED,
      presentLimitAED: double.tryParse(
            newPresentLimitController.text.replaceAll(",", ""),
          ) ??
          double.tryParse(presentLimitController.text.replaceAll(",", "")) ??
          0,
      presentLimit: _numOr(
        getFacility.presentLimit,
        (facilityDetail.isNotEmpty
                ? facilityDetail.first.presentLimit?.toInt()
                : int.tryParse(getFacility.limitAmount?.description ?? "") ??
                    0) ??
            0, // <-- ensure non-null num
      ),
      originalLimit: _numOr(
        getFacility.originalLimit,
        (facilityDetail.isNotEmpty
                ? facilityDetail.first.originalLimit?.toInt()
                : int.tryParse(getFacility.limitAmount?.description ?? "") ??
                    0) ??
            0, // <-- ensure non-null num
      ),
      pastDues:
          _numOr(int.tryParse(getFacility.pastDues?.description ?? ""), 0),
      presentOutstanding: getFacility.presentOutstandingAmount,
      presentOutstandingCurrency: getFacility.presentOutstandingCurrency?.name,
      isProjectFinActivity: _yesNoToBool(
        getFacility.selectedProjectFinanceRelatedActivityValue,
        false,
      ),
      projectName: projectName,
      projectCode: projectCode,
      purpose: getFacility.purpose?.id,
      propertyType: getFacility.propertyType?.id,
      propertySubType: getFacility.propertySubType?.id,
      emirates: getFacility.emirates?.id,
      isRegulatorySpecialisedLending: _yesNoToBool(
        getFacility.selectedRegulatorySpecialisedLandingValue,
        false,
      ),
      regulatorySpecialisedLendingFinanceType:
          _numOr(getFacility.regulatorySpecification?.id, 263),
      countryOfRisk: _strOr(
        getFacility.selectedCountry?.description ?? getFacility.countryOfRisk,
        "Tunisia",
      ),
      sicCode: getFacility.sicCode?.id,
      isSharedLimit: _yesNoToBool(getFacility.sharedLimit, false),
      isCrossBoarderCorporateExposure:
          _boolOr(getFacility.isCrossBoarderExposure, false),
      accountType: _strOr(accountTypeCsvForSave, ""),
      promissoryNoteTaken:
          _numOr(getFacility.selectedpromissoryNoteValue?.id, 1905),
      isCollateralDependent: getFacility.selectedCollateralDepantantValue,
      limitGroupName:
          getLimitGroupName(getFacility.limitGroup).name ?? "".trim(),
      limitGroup: _numOr(limitGroup, ServerConstants.projectSpecificLimitsID),
      additionalDetails: isFIFlow ? null : dynamicFormDocument,
      policyDeviation: getFacility.policyDeviation,
      remarks: getFacility.remarks,
      index: getFacility.index,
      marginSign: getFacility.marginSign,
      marginValue: getFacility.marginValue,
      counterpartyEquity5PercentAED: double.tryParse(
            newCounterpartyEquity5PercentController.text.replaceAll(",", ""),
          ) ??
          double.tryParse(
            counterpartyEquity5PercentController.text.replaceAll(",", ""),
          ),
      excessOverMaxLimitAllowanceAED: double.tryParse(
            newExcessOverMaxLimitAllowanceProposedByFiController.text
                .replaceAll(",", ""),
          ) ??
          double.tryParse(
            excessOverMaxLimitAllowanceProposedByFiController.text
                .replaceAll(",", ""),
          ),
      counterpartyTotalAssets2PercentAED: double.tryParse(
            newCounterpartyTotalAssets2PercentController.text
                .replaceAll(",", ""),
          ) ??
          double.tryParse(
            counterpartyTotalAssets2PercentController.text.replaceAll(",", ""),
          ),
      excessOverMaxLimitAllowanceByCcAED: double.tryParse(
            newExcessOverMaxLimitAllowanceRecommendedByCreditController.text
                .replaceAll(",", ""),
          ) ??
          double.tryParse(
            excessOverMaxLimitAllowanceRecommendedByCreditController.text
                .replaceAll(",", ""),
          ),
    );
  }

  String? _projectCodeFromName(String? raw) {
    final String s = (raw ?? "").trim();
    if (s.isEmpty) return null;

    // Preferred pattern: "CODE - LABEL"
    final int sep = s.indexOf(" - ");
    if (sep > 0) {
      final String left = s.substring(0, sep).trim();
      return left.isEmpty ? null : left;
    }

    // Fallback: take the leading alphanumeric run (covers "202601PROJ000188")
    final RegExpMatch? m = RegExp("^([A-Za-z0-9]+)").firstMatch(s);
    final String? code = m?.group(1)?.trim();
    return (code == null || code.isEmpty) ? null : code;
  }

  FacilityBorrowerMap _buildFacilityBorrowerMapForSave() {
    final int? baseFacilityId =
        int.tryParse(getFacility.facilityId?.toString() ?? "");
    final String mainLimitNo = (getFacility.limitNumber ?? "").trim();
    final List<Map<String, Object>> borrowerList =
        borrowersByRimInTable.map((ref) {
      final String subNo = (ref.reference1 ?? "").trim();
      return {
        "id": {
          "facilityId": baseFacilityId,
          "borrowerRimNo": ref.id,
        },
        "limitAllocationAmount":
            int.tryParse((ref.description ?? "").replaceAll(",", "")) ?? 0,
        if (subNo.isNotEmpty) "subLimitNo": subNo,
        if (isSubLimitMode && mainLimitNo.isNotEmpty) "subLimitNo": mainLimitNo,
      };
    }).toList();
    return FacilityBorrowerMap(borrowerList: borrowerList);
  }

  String _strOr(String? value, String fallback) {
    final String? val = value?.trim();
    return (val == null || val.isEmpty) ? fallback : val;
  }

  bool _yesNoToBool(Reference? ref, bool fallback) {
    final String? name = ref?.name?.trim().toLowerCase();
    if (name == "yes") return true;
    if (name == "no") return false;
    return fallback;
  }

  void changeCommitted(Reference? selectedValue) {
    getFacility.committedValues = selectedValue;
    try {
      getFacility.isCommitted = _yesNoToBool(selectedValue, false);
    } catch (_) {}
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void cancelOnPressed() {
    router.go(Routes.facilitySummaryView);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Reference getIndexBenchMark(dynamic value) {
    Reference index;
    if (value["value"] is List) {
      final Option option = value["value"].first;
      index = benchmark.firstWhere((element) => element.name == option.value);
    } else {
      index = benchmark.firstWhere(
        (element) =>
            element.id ==
            (value["value"] is int
                ? value["value"] as int
                : int.tryParse(value["value"]?.toString() ?? "")),
      );
    }

    debugPrint(index.name);
    return index;
  }

  void changeRegulatorySpecialisedLanding(Reference? selecctedValue) {
    getFacility.selectedRegulatorySpecialisedLandingValue = selecctedValue;

    if (facilityDetail.isNotEmpty) {
      facilityDetail.first.isRegulatorySpecialisedLending = selecctedValue;
    }

    if (selecctedValue?.id == ServerConstants.optionNOid) {
      getFacility.regulatorySpecification = Reference();
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changePromissoryNote(Reference? selecctedValue) {
    getFacility.selectedpromissoryNoteValue = selecctedValue;
    if (facilityDetail.isNotEmpty) {
      facilityDetail.first.promissoryNoteTaken =
          selecctedValue?.id == ServerConstants.optionYESid;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeProjectFinanceRelatedActivity(Reference? selecctedValue) {
    getFacility.selectedProjectFinanceRelatedActivityValue = selecctedValue;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeCollateralDependant(Reference? selecctedValue) {
    getFacility.selectedCollateralDepantantValue = selecctedValue;
    if (facilityDetail.isNotEmpty) {
      facilityDetail.first.isCollateralDependent = selecctedValue;
    }
    final bool selectedYes = _yesNoToBool(selecctedValue, false);

    // Make both fields visible + mandatory when 'Yes'
    dynamicFormKey.currentState
        ?.setFieldVisibility("extentOfFinance", selectedYes);
    dynamicFormKey.currentState
        ?.setFieldVisibility("customerContribution", selectedYes);
    dynamicFormKey.currentState
        ?.setFieldMandatory("extentOfFinance", selectedYes);
    dynamicFormKey.currentState
        ?.setFieldMandatory("customerContribution", selectedYes);

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changProductType(Reference? selecctedValue) {
    getFacility.selectedProductTypeValue = selecctedValue;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeConditionsStandard(bool value) {
    getFacility.isConditionsStandard = value;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeCrossBoarderExposure(bool value) {
    getFacility.isCrossBoarderExposure = value;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void selectLimittedGroup(Reference selectedValue) {
    getFacility.facilityTypeSelectedValue = selectedValue;
    subTypeID = selectedValue.id;
    facilityTypes.map((e) {
      if (selectedValue.reference4 == e.reference4) {
        facilityDescriptions.add(e);
      }
    }).toList();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void selectSharedLimit(Reference selectedValue) {
    getFacility.sharedLimit = selectedValue;

    if ((selectedValue.id == ServerConstants.optionYESid) ||
        ((selectedValue.name ?? "").trim().toLowerCase() ==
            ServerConstants.yesText)) {
      groupCapRowError.clear();
      for (final Reference ref in borrowersByRimInTable) {
        final int entered =
            int.tryParse((ref.description ?? "").replaceAll(",", "")) ?? 0;
        if (entered > 0) {
          groupCapRowError[
                  ref.id is int ? ref.id! : int.tryParse("${ref.id}") ?? -1] =
              "Individual limit is exceeding group limit";
        }
      }
    } else {
      groupCapRowError.clear();
      //  Clear ProposedCompanyCap when Group Level Cap == NO
      proposedCapRaw = null;
      proposedCapEdited = false;
      getFacility.proposedLimit = null; // or 0 if your API expects a number
      getFacility.proposedLimitAED = null; // keep AED mirror in sync
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

// Validates and stores per-row allocation for Group Borrower Limit Caps.
// When "Group Level Cap" == Yes, row value must be <= ProposedCompanyCap.
  void setGroupCapsAllocation(int? rimNo, String? value) {
    if (rimNo == null) return;

    final String cleaned = (value ?? "").replaceAll(",", "").trim();
    final int entered = int.tryParse(cleaned) ?? 0;

    // Store the raw value first (no clamping now)
    final int idx = borrowersByRimInTable
        .indexWhere((r) => (r.id?.toString() ?? "") == rimNo.toString());
    if (idx >= 0) {
      borrowersByRimInTable[idx].description = cleaned;
    } else {
      borrowersByRimInTable.add(Reference(id: rimNo, description: cleaned));
    }

    // Row-level validation message (no AlertManager here)
    if (isGroupCapRequired && entered > groupCapValue) {
      groupCapRowError[rimNo] = "Individual limit is exceeding group limit";
    } else {
      groupCapRowError.remove(rimNo);
    }
  }

  void onPropertyTypeSelected(List<Reference> selected) {
    if (selected.isNotEmpty) {
      getFacility.propertyType = selected.first;
      final String? parentId = getFacility.propertyType?.id?.toString();
      final Reference? currentSub = getFacility.propertySubType;
      if (currentSub != null && (currentSub.reference1?.trim() != parentId)) {
        getFacility.propertySubType = null;
        getFacility.emirates = null;
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } else {
      getFacility.propertyType = null;
      getFacility.propertySubType = null;
      getFacility.emirates = null;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  // Called by FacilityProjectName.onSelected
  void onProjectNameSelected(List<Reference> selected) {
    if (selected.isNotEmpty) {
      getFacility.projectName = selected.first;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  // Keep property sub type selection logic here
  void onPropertySubTypeSelected(List<Reference> selected) {
    if (selected.isNotEmpty) {
      getFacility.propertySubType = selected.first;
      getFacility.emirates = null;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } else {
      getFacility.propertySubType = null;
      getFacility.emirates = null;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  void onPolicyDeviationSelected(List<Reference> selectedValue) {
    getFacility.policyDeviation = selectedValue;
    emit(
      state.copyWith(
        isPolicyDeviation: selectedValue.isNotEmpty,
        loaderStatus: LoadingStatus.loaded,
      ),
    );
  }

  void onPolicyChipDeleted(int index) {
    final List<Reference>? selectedPolicy = getFacility.policyDeviation;
    if (selectedPolicy == null || index < 0 || index >= selectedPolicy.length) {
      return;
    }

    selectedPolicy.removeAt(index);
    getFacility.policyDeviation = selectedPolicy;

    emit(
      state.copyWith(
        isPolicyDeviation: selectedPolicy.isNotEmpty,
        loaderStatus: LoadingStatus.loaded,
      ),
    );
  }

  void selectPurpose(Reference selectedValue) {
    getFacility.purpose = selectedValue;
    getFacility.purpose = selectedValue;
    final bool isY =
        (selectedValue.reference1 ?? "").trim().toUpperCase() == "Y";
    if (!isY) {
      getFacility.propertyType = null;
      getFacility.propertySubType = null;
      getFacility.emirates = null;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void selectLimitType(Reference selectedValue) {
    getFacility.limitTypeValue = selectedValue;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void addFeeAndDefualtRate() {
    feeDefualtRate.add(FeeRate());
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void addNonStandardCondition() {
    nonStandardCondition.add(
      Condition(
        conditionId: null,
        conditionType: ConditionType.nonStandard,
        facilityConditionId: null,
        facilityType:
            selectedProductType?.name ?? ServerConstants.allFacilityProductType,
        isAmended: false,
        isWaivedOff: false,
        isSelected: false,
        rimNo: getFacility.rimNo,
        limitType: (subLimit ?? false)
            ? ServerConstants.facilityMainLimit
            : ServerConstants.facilitySubLimit,
      ),
    );

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void removeNonStandardCondition(int index) {
    nonStandardCondition.removeAt(index);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeStandardConditionSelect(int index, bool value) {
    standardCondition[index].isSelected = value;

    if (value) {
      standardCondition[index].isAmended = false;
      standardCondition[index].isWaivedOff = false;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeContractingStandardConditionSelect(int index, bool value) {
    contractingStandardCondition[index].isSelected = value;

    if (value) {
      contractingStandardCondition[index].isAmended = false;
      contractingStandardCondition[index].isWaivedOff = false;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeAmendStandardConditionSelect(int index, bool value) {
    standardCondition[index].isAmended = value;

    if (value) {
      standardCondition[index].isWaivedOff = false;
      standardCondition[index].isSelected = false;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeAmendContractingStandardConditionSelect(int index, bool value) {
    contractingStandardCondition[index].isAmended = value;

    if (value) {
      contractingStandardCondition[index].isWaivedOff = false;
      contractingStandardCondition[index].isSelected = false;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeWaivedOffStandardConditionSelect(int index, bool value) {
    standardCondition[index].isWaivedOff = value;

    if (value) {
      standardCondition[index].isAmended = false;
      standardCondition[index].isSelected = false;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void selectWaivedOffContractingStandardCondition(
    int index,
    bool value,
  ) {
    contractingStandardCondition[index].isWaivedOff = value;

    if (value) {
      contractingStandardCondition[index].isAmended = false;
      contractingStandardCondition[index].isSelected = false;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeAmendNonStandardConditionSelect(int index, bool value) {
    nonStandardCondition[index].isAmended = value;

    if (value) {
      nonStandardCondition[index].isWaivedOff = false;
      nonStandardCondition[index].isSelected = false;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeWaivedOffNonStandardConditionSelect(int index, bool value) {
    nonStandardCondition[index].isWaivedOff = value;

    if (value) {
      nonStandardCondition[index].isAmended = false;
      nonStandardCondition[index].isSelected = false;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void changeNonStandardConditionSelect(int index, bool value) {
    nonStandardCondition[index].isSelected = value;
    if (value) {
      nonStandardCondition[index].isAmended = false;
      nonStandardCondition[index].isWaivedOff = false;
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
    getFacility.proposedLimit = int.tryParse(proposedLimit ?? "0");
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void compareAllocationAmount(String allocationAmount, Reference borrower) {
    final int proposedLimit = effectiveProposedLimit;
    borrower.description = allocationAmount;
    final int entered = int.tryParse(allocationAmount.replaceAll(",", "")) ?? 0;
    final int otherTotal = borrowersByRimInTable
        .where((b) => !identical(b, borrower))
        .map(
          (b) => int.tryParse((b.description ?? "").replaceAll(",", "")) ?? 0,
        )
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
    final String effective = (getFacility.selectedCountry?.description ??
            getFacility.countryOfRisk ??
            "")
        .trim()
        .toLowerCase();
    return effective == _uaeName;
  }

  void onCountryOfRiskSelected(Country picked) {
    getFacility.selectedCountry = picked;
    getFacility.countryOfRisk = picked.description;

    // If UAE, uncheck and emit
    if (isUAECountryOfRisk) {
      changeCrossBoarderExposure(false);
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void ensureDefaultCountryOfRiskIfEmpty() {
    final bool hasApi = getFacility.countryOfRisk != null &&
        getFacility.countryOfRisk!.trim().isNotEmpty;
    final bool hasSelected =
        getFacility.selectedCountry?.description?.trim().isNotEmpty ?? false;

    // If something is already set, just enforce the UAE rule and exit
    if (hasApi || hasSelected) {
      if (isUAECountryOfRisk) {
        changeCrossBoarderExposure(false);
      }
      return;
    }

    // Otherwise default to UAE from the loaded list
    final List<Country> list = countryList ?? [];
    final Country uae = list.firstWhere(
      (c) => (c.description ?? "").trim().toLowerCase() == _uaeName,
      orElse: () => Country(description: "United Arab Emirates"),
    );

    getFacility.selectedCountry = uae;
    getFacility.countryOfRisk = uae.description;

    // Disable (uncheck) cross-border exposure for UAE
    changeCrossBoarderExposure(false);
    // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void selectSector(Reference? selectedValue) {
    final int? prevSectorId = getFacility.sector?.id;
    final int? newSectorId = selectedValue?.id;
    getFacility.sector = selectedValue;
    if (prevSectorId != newSectorId) {
      getFacility.sicCode = null;
    }

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
    if (facilityDetail.isNotEmpty) {
      final String unit = (facilityDetail.first.tenorUnit ?? "").trim();
      if (unit.isNotEmpty) {
        // Match the Reference from `period` by name; fall back to a loose ref
        // if not found
        final Reference match = period.firstWhere(
          (r) => (r.name ?? "").trim().toLowerCase() == unit.toLowerCase(),
          orElse: () => Reference(name: unit),
        );
        getFacility.tenorUnit = match;
      }

      final String raw = (facilityDetail.first.tenorValue ?? "").trim();
      getFacility.tenorValue = int.tryParse(raw);
    }

    if (facilityDetail.isNotEmpty) {
      final String limitNo = facilityDetail.first.limitNo.trim();
      if (limitNo.isNotEmpty) {
        getFacility.limitNumber = limitNo;
      }

// --- Sustainability Classification hydration (Existing facility) ---
      if (sustanabilityClassifications.isNotEmpty) {
        final String raw = facilityDetail.first.sustainabilityClassification
            .toString()
            .trim();

        if (raw.isNotEmpty) {
          final Set<String> ids = raw
              .split(",")
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toSet();

          getFacility.sustainabilityClassification =
              sustanabilityClassifications
                  .where((r) => ids.contains(r.id?.toString()))
                  .toList();
        } else {
          getFacility.sustainabilityClassification = [];
        }
      }
    }

    if (facilityDetail.isNotEmpty) {
      final Reference? ref = facilityDetail
          .first.isCollateralDependent; // Reference(Yes/No) from API
      if (ref != null) {
        getFacility.selectedCollateralDepantantValue = ref;
      }
    }

    if (facilityDetail.isNotEmpty) {
      final bool? cross = facilityDetail.first.isCrossBoarderCorporateExposure;
      if (cross != null) {
        getFacility.isCrossBoarderExposure = cross;
      }
    }

    // --- Limit Availability (Period vs Date) from GET ---
    if (facilityDetail.isNotEmpty) {
      final num? cap =
          facilityDetail.first.limitCapType; // assumes the model exposes it
      if (cap != null) {
        facilityDetails.limitCapType = cap;
      }

      final String can = facilityDetail.first.commitmentAccountNumber.trim();
      if (can.isNotEmpty) {
        getFacility.commitmentAccountNumber = Reference(name: can);
        if (can == _newAccLabel) {
          presentOutStandingReadOnly = false;
        }
      }
    }

    if (facilityDetail.isNotEmpty) {
      final String apiLimitPeriod =
          facilityDetail.first.limitAvailabilityPeriod;
      final DateTime? apiLimitDate = facilityDetail.first.limitAvailabilityDate;

      if (apiLimitPeriod.trim().isNotEmpty) {
        // Prefer period: set period, clear date
        getFacility.limitAvailabilityPeriod = apiLimitPeriod.trim();
        getFacility.limitAvailabilityDate = null;
      } else if (apiLimitDate != null) {
        // Set date (UTC for consistency), clear period
        getFacility.limitAvailabilityDate = apiLimitDate.toUtc();
        getFacility.limitAvailabilityPeriod = null;
      } else {
        getFacility.limitAvailabilityPeriod = null;
        getFacility.limitAvailabilityDate = null;
      }
    }

    if (facilityDetail.isNotEmpty) {
      final String cln = facilityDetail.first.controllingLimitNo.trim();
      if (cln.isNotEmpty) {
        getFacility.controllingLimitNumber = cln;
        parentControlliingNumber = cln;
        final bool exists = controllingLimitNumbers.any(
          (r) => (r.name ?? "").trim() == cln,
        );
        if (!exists) {
          controllingLimitNumbers.add(Reference(name: cln));
        }
      }
    }

    if (facilityDetail.isNotEmpty) {
      final String code =
          (facilityDetail.first.productCode ?? "").trim().toUpperCase();
      isLimitCaps = (code ==
          ServerConstants.productCodeClt); // robust for "clt", " CLT ", etc.
    }

    if (facilityDetail.isNotEmpty) {
      final NumberFormat formatter = NumberFormat("#,###");
      final num? proposedLimitApiValue = facilityDetail.first.proposedLimit;
      getFacility.proposedLimit = (proposedLimitApiValue ?? 0).toInt();
      getFacility.proposedLimitValue =
          Reference(name: facilityDetail.first.currency);
      proposedLimitController.text =
          formatter.format(proposedLimitApiValue ?? 0).toString();

      getFacility.proposedByCc =
          (facilityDetail.first.proposedByCc ?? 0).toDouble();
      getFacility.proposedByCcCurrency =
          facilityDetail.first.proposedByCcCurrency;

      proposedByccController.text =
          (facilityDetail.first.proposedByCc ?? "").toString();
    }

    if (facilityDetail.isNotEmpty) {
      const String curr = ServerConstants
          .aedCurrency; // facilityDetail.first.currency; // TODO direct currency field is used for proposedLimit not PastDues
      final int? past = facilityDetail.first.pastDues;

      if (curr.isNotEmpty || past != null) {
        getFacility.pastDues = (getFacility.pastDues ?? Reference())
          ..name = curr
          ..description = past?.toString();
      }
    }

    if (facilityDetail.isNotEmpty) {
      if (facilityDetail.first.policyDeviation != null &&
          facilityDetail.first.policyDeviation!.isNotEmpty) {
        getFacility.policyDeviation =
            facilityDetail.first.policyDeviation!.map((enrichedRef) {
          return policyDeviations.firstWhere(
            (ref) => ref.name == enrichedRef.name,
            orElse: () => enrichedRef,
          );
        }).toList();
      }
    }
    if (facilityDetail.isNotEmpty && facilityDescriptions.isNotEmpty) {
      final Reference match = facilityDescriptions.firstWhere(
        (e) =>
            e.id?.toString() ==
            facilityDetail.first.limitDescription.toString(),
        orElse: () => Reference(name: ""),
      );
      getFacility.facilityDescription = match;
    }

    if (facilityDetail.isNotEmpty && advanceTypes.isNotEmpty) {
      final Reference advMatch = advanceTypes.firstWhere(
        (e) => e.id?.toString() == facilityDetail.first.advanceType.toString(),
        orElse: () => Reference(name: ""),
      );
      getFacility.advanceTypeValue = advMatch;
    }
    // NEW: parse accountType CSV/string into multi-select list
    if (facilityDetail.isNotEmpty) {
      final String raw = facilityDetail.first.accountType.trim();
      if (raw.isNotEmpty) {
        final Set<String> ids = raw
            .split(",")
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toSet();
        selectedAccountTypes =
            accountTypes.where((r) => ids.contains(r.id?.toString())).toList();
      } else {
        selectedAccountTypes = [];
      }
    }
    if (facilityDetail.isNotEmpty && seniorities.isNotEmpty) {
      final Reference advMatch = seniorities.firstWhere(
        (e) => e.id?.toString() == facilityDetail.first.seniority.toString(),
        orElse: () => Reference(name: ""),
      );
      getFacility.seniorityValue = advMatch;
    }

    if (facilityDetail.isNotEmpty && sicCodes.isNotEmpty) {
      final Reference advMatch = sicCodes.firstWhere(
        (e) => e.id?.toString() == facilityDetail.first.sicCode.toString(),
        orElse: () => Reference(name: ""),
      );
      getFacility.sicCode = advMatch;
    }

    if (facilityDetail.isNotEmpty && sectors.isNotEmpty) {
      final Reference advMatch = sectors.firstWhere(
        (e) =>
            e.id?.toString() ==
            facilityDetail.first.sectorDescription.toString(),
        orElse: () => Reference(name: ""),
      );
      getFacility.sector = advMatch;
    }

    if (facilityDetail.isNotEmpty && accountTypes.isNotEmpty) {
      final Reference advMatch = accountTypes.firstWhere(
        (e) => e.id?.toString() == facilityDetail.first.accountType.toString(),
        orElse: () => Reference(name: ""),
      );
      getFacility.accountTypeValue = advMatch;
    }

    if (facilityDetail.isNotEmpty && purposes.isNotEmpty) {
      final Reference advMatch = purposes.firstWhere(
        (e) => e.id?.toString() == facilityDetail.first.purpose.toString(),
        orElse: () => Reference(name: ""),
      );
      getFacility.purpose = advMatch;
    }
    if (facilityDetail.isNotEmpty && propertyTypes.isNotEmpty) {
      final Reference advMatch = propertyTypes.firstWhere(
        (e) => e.id?.toString() == facilityDetail.first.propertyType.toString(),
        orElse: () => Reference(name: ""),
      );
      getFacility.propertyType = advMatch;
    }

    if (facilityDetail.isNotEmpty && propertySubTypes.isNotEmpty) {
      final Reference advMatch = propertySubTypes.firstWhere(
        (e) =>
            e.id?.toString() == facilityDetail.first.propertySubType.toString(),
        orElse: () => Reference(name: ""),
      );
      getFacility.propertySubType = advMatch;
    }

    if (facilityDetail.isNotEmpty && emirates.isNotEmpty) {
      final Reference advMatch = emirates.firstWhere(
        (e) => e.id?.toString() == facilityDetail.first.emirates.toString(),
        orElse: () => Reference(name: ""),
      );
      getFacility.emirates = advMatch;
    }

    if (facilityDetail.isNotEmpty &&
        projectFinanceRelatedActivityOptions.isNotEmpty) {
      final bool? flag = facilityDetail.first.isProjectFinActivity;
      if (flag != null) {
        final Reference match = projectFinanceRelatedActivityOptions.firstWhere(
          (e) {
            final String name = (e.name ?? "").trim().toLowerCase();
            return flag
                ? name == ServerConstants.yesText
                : name == ServerConstants.noText;
          },
          orElse: () => Reference(name: ""),
        );

        getFacility.selectedProjectFinanceRelatedActivityValue = match;
      }
    }

    if (facilityDetail.isNotEmpty && promissoryNoteOptions.isNotEmpty) {
      final bool? flag = facilityDetail.first.promissoryNoteTaken;
      if (flag != null) {
        final Reference match = promissoryNoteOptions.firstWhere(
          (e) {
            return e.id ==
                (flag
                    ? ServerConstants.optionYESid
                    : ServerConstants.optionNOid);
          },
        );
        getFacility.selectedpromissoryNoteValue = match;
      }
    }

    if (facilityDetail.isNotEmpty && sharedLimits.isNotEmpty) {
      final bool? flag = facilityDetail.first.isSharedLimit;
      if (flag != null) {
        final Reference match = sharedLimits.firstWhere(
          (e) {
            final String name = (e.name ?? "").trim().toLowerCase();
            return flag
                ? name == ServerConstants.yesText
                : name == ServerConstants.noText;
          },
          orElse: () => Reference(name: ""),
        );

        getFacility.sharedLimit = match; // set the selected Reference
      }
    }

    if (facilityDetail.isNotEmpty) {
      final String apiProjectName = facilityDetail.first.projectName.trim();
      if (apiProjectName.isNotEmpty) {
        if (projectNames.isNotEmpty) {
          final Reference match = projectNames.firstWhere(
            (r) => (r.name ?? "").trim().toLowerCase() ==
                apiProjectName.toLowerCase(),
            orElse: () => Reference(name: apiProjectName),
          );
          getFacility.projectName = match;
        } else {
          getFacility.projectName = Reference(name: apiProjectName);
        }
      } else {
        getFacility.projectName = null;
      }
    }

    if (facilityDetail.isNotEmpty && committedValues.isNotEmpty) {
      final bool? flag =
          facilityDetail.first.isCommitted; // assumes API provides it
      if (flag != null) {
        final Reference match = committedValues.firstWhere(
          (e) {
            final String name = (e.name ?? "").trim().toLowerCase();
            return flag
                ? name == ServerConstants.yesText
                : name == ServerConstants.noText;
          },
          orElse: () => Reference(name: ""),
        );
        getFacility.committedValues = match;
      }
    }

    // --- Present Outstanding hydration (Existing facility reopen fix) ---
    if (facilityDetail.isNotEmpty) {
      final NumberFormat formatter = NumberFormat("#,###");
      final detail = facilityDetail.first;

      //Amount in selected currency (API)
      final int presentOutstandingAmnt =
          (detail.presentOutstanding ?? 0).toInt();
      getFacility.presentOutstandingAmount = presentOutstandingAmnt;
      presentOutstandingController.text = presentOutstandingAmnt > 0
          ? formatter.format(presentOutstandingAmnt)
          : "";

      // Currency for Present Outstanding (API)
      final String poCode =
          (detail.presentOutstandingCurrency ?? detail.currency)
              .trim()
              .toUpperCase();

      // Prefer the exact Reference instance from currencyCodes (so dropdown
      // highlights correctly)
      final Reference resolvedPoCurrency = currencyCodes.firstWhere(
        (r) => (r.name ?? "").trim().toUpperCase() == poCode,
        orElse: () => Reference(name: poCode),
      );
      getFacility.presentOutstandingCurrency = resolvedPoCurrency;

      // AED equivalent (API)
      final int poAed = (detail.presentOutstandingAED ?? 0).toInt();
      getFacility.presentOutstandingAED = poAed;

      // Show/hide AED converted field and set its value
      final bool isNonAed = poCode != ServerConstants.aedCurrency;
      showNewPresentOutStandingLimit = isNonAed;

      // if (isNonAed) {   // Commenting this for resolving bug in Presnet limit currency change
      //   // Use API AED value directly (do NOT recalc)
      //   newPresentOutStandingController.text = formatter.format(poAed);
      // } else {
      //   // Same currency = AED
      //   newPresentOutStandingController.text = presentOutstandingAmnt > 0
      //       ? formatter.format(presentOutstandingAmnt)
      //       : '';
      // }
    }

    // if (facilityDetail.isNotEmpty) {       // Commenting this for solve AED conversion issue in realtime.
    //   final detail = facilityDetail.first;
    //   final fmt = NumberFormat('#,###');

    //   // Proposed Limit amount (local)
    //   final int pl = (detail.proposedLimit ?? 0).toInt();
    //   getFacility.proposedLimit = pl;
    //   proposedLimitController.text = pl > 0 ? fmt.format(pl) : '';

    //   // Proposed currency (from API "currency")
    //   final String cur = (detail.currency).trim().toUpperCase();
    //   final Reference resolved = currencyCodes.firstWhere(
    //     (r) => (r.name ?? '').trim().toUpperCase() == cur,
    //     orElse: () => Reference(name: cur),
    //   );
    //   getFacility.proposedLimitValue = resolved;

    //   // ProposedLimitAED (API)
    //   final int plAed = (detail.proposedLimitAED ).toInt();
    //   getFacility.proposedLimitAED = plAed;

    //   // Show converted field + set it (use API, do not recalc)
    //   showNewProposedLimitAmount = cur != ServerConstants.aedCurrency;
    //   newProposedLimitController.text = fmt.format(plAed);
    // }

    if (facilityDetail.isNotEmpty) {
      final String? apiCountryRaw = facilityDetail.first.countryOfRisk?.trim();
      if ((apiCountryRaw ?? "").isNotEmpty) {
        getFacility.countryOfRisk = apiCountryRaw;
      }
    }

    final String? apiCountry = getFacility.countryOfRisk?.trim();
    if (apiCountry != null &&
        apiCountry.isNotEmpty &&
        (countryList?.isNotEmpty ?? false)) {
      final Country found = countryList!.firstWhere(
        (c) =>
            (c.description ?? "").trim().toLowerCase() ==
            apiCountry.toLowerCase(),
        orElse: () =>
            Country(description: apiCountry), // still show text if not in list
      );
      getFacility.selectedCountry = found;
    }
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
  /// - [gridName]: The name of the grid containing the field
  /// - [fieldToUpdate]: The field key to update with customer name (e.g.,
  /// 'customerName')
  Future<void> _searchCustomerByRimInGrid(
    String rimValue,
    int rowIndex,
    String gridName,
    String fieldToUpdate,
  ) async {
    if (rimValue.isEmpty || fieldToUpdate.isEmpty) return;

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
        // Populate the name field in the same row using grid-qualified key
        // Format: gridName.fieldKey@rowIndex
        final String nameKey = "$gridName.$fieldToUpdate@$rowIndex";
        final String customerName =
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
    final DynamicFormState? form = dynamicFormKey.currentState;

    switch (fieldKey) {
      case "repaymentTypeTawarrukPPC" || "repaymentTypeTawarrukInvoice":
        if (value.key == "instalments") {
          form?.setFieldVisibility("instalments", true);
          form?.setFieldVisibility("bullet", false);
        } else if (value.key == "bullet") {
          form?.setFieldVisibility("instalments", false);
          form?.setFieldVisibility("bullet", true);
        }
      case "shipmentBySeaOrAir":
        // If shipmentBySeaOrAir is true, show shipmentBySea/AirAmount field
        // If false, hide it
        final bool isChecked = value == true;
        form?.setFieldVisibility("shipmentBySea/AirAmount", isChecked);
      case "shipmentByTruck":
        // If shipmentByTruck is true, show shipmentByTruckAmount field
        // If false, hide it
        final bool isChecked = value == true;
        form?.setFieldVisibility("shipmentByTruckAmount", isChecked);
      case "charterBillLading":
        // If charterBillLading is true, show charteredBillLadingAmount field
        // If false, hide it
        final bool isChecked = value == true;
        form?.setFieldVisibility("charteredBillLadingAmount", isChecked);

      // Third Port Shipment → thirdPortShipmentAmount
      case "thirdPortShipment":
        form?.setFieldVisibility("thirdPortShipmentAmount", value == true);

      // Overseas Shipment → overseasShipmentAmount
      case "overseasShipment":
        form?.setFieldVisibility("overseasShipmentAmount", value == true);

      // Local Delivery → localDeliveryAmount
      case "localDelivery":
        form?.setFieldVisibility("localDeliveryAmount", value == true);

      // Finance under LC → financeUnderLCAmount
      case "financeUnderLC":
        form?.setFieldVisibility("financeUnderLCAmount", value == true);

      // Finance against collection → financeAgainstCollectionAmount
      case "financeAgainstCollection":
        form?.setFieldVisibility(
          "financeAgainstCollectionAmount",
          value == true,
        );

      // Master Promissory Note held →
      //   Use ONE of these depending on your UI:
      //   A) show amount field
      case "masterPromissoryNoteHeld":
        form?.setFieldVisibility(
          "masterPromissoryNoteHeldAmount",
          value == true,
        );
        //   B) or show a number/ID input instead:
        form?.setFieldVisibility("masterPromissoryNoteNumber", value == true);

      case "tenor":
        // "value" is the payload from the combo component: { <unit>:
        // <typedNumber> }
        // Fall back to explicit map keys if the widget sends {tenorUnit,
        // tenorValue}
        final String selUnit = (value is Map && value.containsKey("tenorUnit"))
            ? (value["tenorUnit"]?.toString() ?? "")
            : (value?.keys?.first?.toString() ?? "");
        final String selVal = (value is Map && value.containsKey("tenorValue"))
            ? (value["tenorValue"]?.toString() ?? "")
            : (value?.values?.first?.toString() ?? "");
        getFacility.tenorUnit = Reference(name: selUnit);
        getFacility.tenorValue = int.tryParse(selVal);
        // Always send the user's numeric input for On Demand as well.
        // (No special string override.)
        form?.updateFieldValue("tenor", {
          "tenorUnit": selUnit,
          "tenorValue": selVal, // <-- numeric string from the textbox
        });

      case ("lcMargin" || "avMargin" || "guaranteeMargin"):
        // When any value is selected in Guarantee Margin:
        // - Make Margin Extent field mandatory
        // When Time Deposits is selected:
        // - Make Linked Account Number field mandatory

        final bool hasValue = value != null &&
            (value is String ? value.isNotEmpty : value.key != null);
        final bool isTimeDeposits = value?.key == "timeDeposits";

        // Margin Extent becomes mandatory when any Guarantee Margin value is
        // selected
        form?.setFieldMandatory("marginExtent", hasValue);

        // Linked Account Number becomes mandatory only for Time Deposits
        form?.setFieldMandatory("linkedAccountNumber", isTimeDeposits);
      case "currency":
        // If "Others" is selected in Permitted Currency multiSelect, show
        // otherCurrency field
        // Otherwise, hide it
        bool hasOthers = false;
        if (value is List) {
          hasOthers = value.contains("Others");
        }
        form?.setFieldVisibility("otherCurrency", hasOthers);
      case "payofcurrency":
        // If "Others" is selected in Payoff Currency multiSelect, show
        // specifyofpayofcurrency field
        // Otherwise, hide it
        bool hasOthers = false;
        if (value is List) {
          hasOthers = value.contains("Others");
        }
        form?.setFieldVisibility("specifyofpayofcurrency", hasOthers);
      case "searchByName":
        // Extract grid name to use grid-qualified keys
        final String? gridName = value["gridName"];
        final int rowIndex = value["index"];
        final bool isChecked = value["value"] == true;

        if (gridName != null) {
          // Use grid-qualified field keys to ensure changes only affect
          // the specific grid where the checkbox was toggled
          final String rimKey = "$gridName.customerRimGrid";
          final String nameKey = "$gridName.customerName";

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
        // Extract RIM number, row index, and grid name from the value
        final rimValue = value["value"]?.toString() ?? "";
        final rowIndex = value["index"];
        final gridName = value["gridName"] as String?;
        final debounceKey = "customerRimGrid@$rowIndex";

        // Cancel any existing timer for this field
        _customerSearchDebounceTimers[debounceKey]?.cancel();

        if (rimValue.isNotEmpty && gridName != null) {
          // Create a new debounced timer (500ms delay)
          _customerSearchDebounceTimers[debounceKey] =
              Timer(const Duration(milliseconds: 500), () {
            // Determine the field to update based on grid name
            final String fieldToUpdate = switch (gridName) {
              "heldInTheNameOf" => "customerName",
              "depositHeldInTheNameOf" => "customerName",
              _ => "customerName", // Default fallback
            };

            _searchCustomerByRimInGrid(
              rimValue,
              rowIndex,
              gridName,
              fieldToUpdate,
            );
          });
        }

      case "preShipment":
        form?.setFieldVisibility("preShipmentAmount", value == true);

      case "postShipment":
        form?.setFieldVisibility("postShipmentAmount", value == true);
      case ("index" || "indexLcLGCommision"):
        final bool isClearingSelection = value == null ||
            (value is Map &&
                value["value"] is List &&
                (value["value"] as List).isEmpty);
        if (isClearingSelection) {
          getFacility.index = null;
        } else {
          getFacility.index = getIndexBenchMark(value).id.toString();
        }
      case "margin":
        getFacility.marginValue = value["value"]["tenorValue"];
        getFacility.marginSign = value["value"]["tenorUnit"];
      case "recourse":
        if (value.key == "withoutRecourse") {
          form?.setFieldVisibility("creditInsuranceCompanyName", true);
          form?.setFieldVisibility("creditInsurancePolicyDetails", true);
          form?.updateFieldValue("creditInsurancePolicyDetails", "NA");
        } else {
          form?.setFieldVisibility("creditInsuranceCompanyName", false);
          form?.setFieldVisibility("creditInsurancePolicyDetails", false);
        }

      case "rePaymentType":
        if (value.key == "installmentLoan") {
          form?.setFieldVisibility("equated", false);
          form?.setFieldVisibility("InstallmentloanOptions", true);
          form?.setFieldVisibility(
            "NoOfYearsTenor",
            true,
          ); //TODO remove this pactch up work
          form?.setFieldVisibility("NoOfInstallmentsPerYear", true);
        } else if (value.key == "equatedLoan") {
          form?.setFieldVisibility("equated", true);
          form?.setFieldVisibility("InstallmentloanOptions", false);

          form?.setFieldVisibility("NoOfYearsTenor", false);
          form?.setFieldVisibility("NoOfInstallmentsPerYear", false);
          form?.setFieldVisibility("interestGrid", false);
          form?.setFieldVisibility("principal", false);
        }

      case "InstallmentloanOptions":
        final String? installmentloanOption =
            value?.toString().trim().toLowerCase();
        final bool isStraightLine = (installmentloanOption == "straight line");

        if (isStraightLine) {
          form?.setFieldVisibility("NoOfYearsTenor", true);
          form?.setFieldVisibility("NoOfInstallmentsPerYear", true);
          form?.setFieldVisibility("interestGrid", false);
          form?.setFieldVisibility("principal", false);
        } else {
          form?.setFieldVisibility("interestGrid", true);
          form?.setFieldVisibility("principal", true);
          form?.setFieldVisibility("NoOfYearsTenor", false);
          form?.setFieldVisibility("NoOfInstallmentsPerYear", false);
        }

      case "acceptableInvoiceCurrencies":
        // If "Other" is selected in Acceptable Invoice Currencies multiSelect,
        // show specifyOthercurrency field
        // Otherwise, hide it
        bool hasOther = false;
        if (value is List) {
          hasOther = value.contains("Other");
        }
        form?.setFieldVisibility("specifyOthercurrency", hasOther);

      default:
        // No specific handling for this field
        break;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Returns a safe (non-zero) conversion rate for the given sub-type row.
  /// Falls back to 1 when rate is missing/zero so AED rows keep working.
  num _safeRateForSubType(int rowIndex) {
    final num rate = rateForSubType(rowIndex); // existing method
    return (rate > 0) ? rate : 1;
  }

  /// Computes the AED-equivalent total of all selected Sub-type Proposed
  /// Limits.
  /// If [overrideRowIndex] is provided, the row at that index will use
  /// [overrideLocalValue] (the in-flight typed value) instead of the model
  /// value.
  /// This is used both for validator and during onChanged so we always
  /// validate the "what the user sees" state.
  int totalSubTypeProposedInAED({
    int? overrideRowIndex,
    int? overrideLocalValue,
  }) {
    int totalAED = 0;

    for (int rowIndex = 0; rowIndex < facilitySubTypes.length; rowIndex++) {
      final sub = facilitySubTypes[rowIndex];
      if (!(sub.subTypeSelected ?? false)) continue;

      final bool isOverriddenRow =
          overrideRowIndex != null && overrideRowIndex == rowIndex;

      final int localAmount = isOverriddenRow
          ? (overrideLocalValue ?? (sub.proposedLimit ?? 0))
          : (sub.proposedLimit ?? 0);

      if (localAmount <= 0) continue;

      final num rate = _safeRateForSubType(rowIndex);
      totalAED += (localAmount * rate).toInt();
    }

    return totalAED;
  }

  /* ----------------------SUB LIMIT TABLE ---------------------------------- */
  /// Returns true if the AED-equivalent total (with the current row's local
  /// value)
  /// would exceed the parent/header Proposed Limit cap.
  bool exceedsParentCapWith({
    required int rowIndex,
    required int localValue,
  }) {
    final int capAED = effectiveProposedLimit; // header cap in AED
    if (capAED <= 0) return false;

    final int totalAED = totalSubTypeProposedInAED(
      overrideRowIndex: rowIndex,
      overrideLocalValue: localValue,
    );

    return totalAED > capAED;
  }

  /// Handles live typing for Sub-type Proposed Limit in a given row:
  /// - Parses and stores the user's local number (no clamping).
  /// - If selected and the aggregate exceeds the cap, shows a toast (once).
  /// - Emits a light state update so dependent UI (e.g., tooltips) can refresh.
  void onSubTypeProposedLimitChanged(int rowIndex, String rawText) {
    if (rowIndex < 0 || rowIndex >= facilitySubTypes.length) return;

    final String cleaned = rawText.replaceAll(",", "").trim();
    final int localValue = int.tryParse(cleaned) ?? 0;

    // Always store what user typed (no clamping).
    facilitySubTypes[rowIndex].proposedLimit = localValue;

    // If row not selected, nothing else to do.
    final bool isSelected = facilitySubTypes[rowIndex].subTypeSelected ?? false;
    if (!isSelected) {
      // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return;
    }

    // Show a toast if the aggregate exceeds cap. Do NOT change the input.
    if (exceedsParentCapWith(rowIndex: rowIndex, localValue: localValue)) {
      if (shouldShowAllocationToastOnce()) {
        // your existing gate
        AlertManager().showFailureToast(
          "Sub-limit total cannot exceed Proposed Limit",
        );
      }
    }

    // Nudge the UI to refresh (e.g., tooltip AED text).
    // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Validator for Sub-type Proposed Limit cell:
  /// - Skips when row is not selected.
  /// - Ensures non-empty.
  /// - Ensures AED-aggregated total (including this field's typed value)
  ///   does not exceed the header Proposed Limit.
  String? validateSubTypeProposedLimit(int rowIndex, String? rawText) {
    if (rowIndex < 0 || rowIndex >= facilitySubTypes.length) return null;

    final bool isSelected = facilitySubTypes[rowIndex].subTypeSelected ?? false;
    if (!isSelected) return null;

    final String cleaned = (rawText ?? "").replaceAll(",", "").trim();
    if (cleaned.isEmpty) return "common.validation.emptyField".tr();

    final int localValue = int.tryParse(cleaned) ?? 0;

    if (exceedsParentCapWith(rowIndex: rowIndex, localValue: localValue)) {
      return "Sub-limit total cannot exceed Proposed Limit";
    }
    return null;
  }

  /// Returns true if any selected Sub-type Proposed Limit
  /// (individually or in aggregate) exceeds the header Proposed Limit (AED).
  ///
  /// This is used as a SAVE-time guard before form validation,
  /// so we can show a business-rule toast instead of
  /// "please fill all required fields".
  bool hasInvalidSubTypeProposedLimit() {
    final int capAED = effectiveProposedLimit;
    if (capAED <= 0) return false;

    int totalAED = 0;

    for (int rowIndex = 0; rowIndex < facilitySubTypes.length; rowIndex++) {
      final sub = facilitySubTypes[rowIndex];
      if (!(sub.subTypeSelected ?? false)) continue;

      final int localAmount = sub.proposedLimit ?? 0;
      if (localAmount <= 0) continue;

      final num rate = rateForSubType(rowIndex);
      final num safeRate = (rate > 0) ? rate : 1;

      totalAED += (localAmount * safeRate).toInt();

      //  Optional fast-fail (covers single-row exceed too)
      if (totalAED > capAED) {
        return true;
      }
    }

    return totalAED > capAED;
  }
}
