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
import "package:wcas_frontend/core/utils/screen_access_conditions.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/draft_handler.dart";
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

/// View model responsible for managing create facility data,
/// state transitions, and business operations.
class CreateFacilityViewModel extends SafeCubit<CreateFacilityState>
    with DraftMixin<CreateFacilityViewModel> {
  /// Creates a create facility view model with the initial loading state.
  CreateFacilityViewModel()
      : super(
          const CreateFacilityState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

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

  /// Indicates whether the present outstanding field is read-only.
  bool presentOutStandingReadOnly = true;

  /// Returns whether the current request was created through manual entry.
  ///
  /// Used to determine field editability and validation behavior.
  bool get isManualEntry {
    logger.i("manualEntry: ${Globals.request?.applicationSubType}");
    return Globals.request?.applicationSubType == ServerConstants.manualEntry;
  }

  /// Facility details associated with the current facility.
  FacilityDetails facilityDetails = FacilityDetails();

  /// Stores the raw proposed cap value entered by the user.
  ///
  /// Preserves the user's typed input before formatting or conversion.
  String? proposedCapRaw;

  /// Indicates whether the proposed cap field has been modified by the user.
  ///
  /// Set to `true` when the user updates the proposed cap value.
  bool proposedCapEdited = false;

  /// Key for validating the dynamic form section.
  GlobalKey<DynamicFormState> dynamicFormKey = GlobalKey<DynamicFormState>();

  /// Customer related operations Search take timer .
  final Map<String, Timer?> _customerSearchDebounceTimers = {};

  /// Row-level validation error messages for the Group Borrower Limit Caps table.
  ///
  /// The key represents the borrower RIM number and the value contains the
  /// corresponding validation error message, if any.
  final Map<int, String?> groupCapRowError = {};

  /// Returns whether the Group Level Cap selection requires cap allocation.
  ///
  /// A group cap is required when the Shared Limit option is set to "Yes".
  bool get isGroupCapRequired {
    return (getFacility.sharedLimit?.id == ServerConstants.optionYESid) ||
        ((getFacility.sharedLimit?.name ?? "").trim().toLowerCase() ==
            ServerConstants.yesText);
  }

  /// Returns the current proposed group cap value.
  ///
  /// Defaults to `0` when no proposed limit is available.
  int get groupCapValue => getFacility.proposedLimit ?? 0;

  /// Repository for Customer related operations.
  CustomerRepository customerRepository = CustomerRepository();

  /// List of form sections used in the dynamic form.
  List<Section> sections = [];

  /// Available countries for country-based selections.
  List<Country>? countryList = [];

  /// Indicates whether the current facility is a main limit.
  bool? isMainLimit = false;

  /// Supported facility limit types.
  List<String> limitTypeFacility = [
    ServerConstants.mainLimitLabel,
    ServerConstants.subLimitLabel,
  ];

  /// Selected currency code.
  ///
  /// Example: `AED`.
  String? selectedCurrencyCode;

  /// Indicates whether an API error has occurred.
  bool isApiError = false;

  /// Document data used to populate the dynamic form.
  Map<String, dynamic> dynamicFormDocument = {};

  /// Collection of fee default rate entries.
  List<FeeRate> feeDefualtRate = [];

  /// Collection of standard conditions.
  List<Condition> standardCondition = [];

  /// Collection of contracting standard conditions.
  List<Condition> contractingStandardCondition = [];

  /// Collection of non-standard conditions.
  List<Condition> nonStandardCondition = [];

  /// Collection of standard conditions for the sub-limit table.
  List<Condition> subLimitTableStandardCondition = [];

  /// Collection of contracting standard conditions for the sub-limit table.
  List<Condition> subLimitTableContractingStandardCondition = [];

  /// Collection of non-standard conditions for the sub-limit table.
  List<Condition> subLimitTableNonStandardCondition = [];

  /// Available facility subtypes.
  List<FacilitySubTypes> facilitySubTypes = [];

  /// Facility detail records associated with the current facility.
  List<FacilityDetail> facilityDetail = [];

  /// Available commitment account number references.
  List<Reference> commitmentAccountNumbers = [];

  /// Available limit records.
  List<LimitsResponse> limits = [];

  /// List of commitment account number values used in the UI.
  List<String> commitmentAccountNumberItems = [];

  /// Available benchmark references.
  List<Reference> benchmark = [];

  /// Available margin sign references.
  List<Reference> marginSign = [];

  /// Exchange rate used for currency conversions.
  num exchangeRate = 0;

  /// Identifier of the last created parent facility.
  int? lastCreatedParentFacilityId;

  /// Identifiers of the last created sub-facilities.
  List<int> lastCreatedSubFacilityIds = [];

  /// Selected facility subtype identifier.
  int? subTypeID;

  /// Reference data collections used for dropdowns and selection controls.
  List<Reference> currencyCodes = [];

  /// Available limit type options.
  List<Reference> limitTypes = [];

  /// Available limit cap type options.
  List<Reference> limitCapsType = [];

  /// Available regulatory specialised lending options.
  List<Reference> regulatorySpecialisedLandingOptions = [];

  /// Available product type options.
  List<Reference> productTypeItems = [];

  /// Available promissory note options.
  List<Reference> promissoryNoteOptions = [];

  /// Available collateral dependant options.
  List<Reference> collateralDepantantoptions = [];

  /// Available project finance related activity options.
  List<Reference> projectFinanceRelatedActivityOptions = [];

  /// Available shared limit options.
  List<Reference> sharedLimits = [];

  /// Available sector options.
  List<Reference> sectors = [];

  /// Available SIC code options.
  List<Reference> sicCodes = [];

  /// Available facility type options.
  List<Reference> facilityTypes = [];

  /// Available facility description options.
  List<Reference> facilityDescriptions = [];

  /// Available facility fee type options.
  List<Reference> facilityFeeTypes = [];

  /// Available facility fee frequency options.
  List<Reference> facilityTypesFeeFrequency = [];

  /// Available account type options.
  List<Reference> accountTypes = [];

  /// Available advance type options.
  List<Reference> advanceTypes = [];

  /// Available controlling limit number options.
  List<Reference> controllingLimitNumbers = [];

  /// Available property subtype options.
  List<Reference> propertySubTypes = [];

  /// Available property type options.
  List<Reference> propertyTypes = [];

  /// Available limit group options.
  List<Reference> limitGroups = [];

  /// Available policy deviation options.
  List<Reference> policyDeviations = [];

  /// Available facility purpose options.
  List<Reference> purposes = [];

  /// Available emirate options.
  List<Reference> emirates = [];

  /// Available regulatory specification options.
  List<Reference> regulatorySpecifications = [];

  /// Available seniority options.
  List<Reference> seniorities = [];

  /// Available borrower references used for selection controls.
  List<Reference> borrowersMap = [];

  /// Collection of borrower records.
  List<Borrower> borrowers = [];

  /// Borrowers currently displayed in the borrower allocation table.
  List<Reference> borrowersByRimInTable = [];

  /// Available committed value options.
  List<Reference> committedValues = [];

  /// Available sustainability classification options.
  List<Reference> sustanabilityClassifications = [];

  /// Available period options.
  List<Reference> period = [];

  /// Maps borrower RIM numbers to their original group cap values.
  final Map<int, int> groupCapsOriginalByRim = {};

  /// Maps borrower RIM numbers to their present group cap values.
  final Map<int, int> groupCapsPresentByRim = {};

  /// Current page mode of the create facility screen.
  PageMode? pageMode;

  /// Indicates whether sub-limit validation is enabled.
  bool? isSublimitValidation;

  /// Returns whether the current page is in edit mode.
  bool get canEdit => pageMode == PageMode.edit;

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

  /// Returns whether the selected country of risk is the UAE.
  bool get isUAECountryOfRisk {
    final String effective = (getFacility.selectedCountry?.description ??
            getFacility.countryOfRisk ??
            "")
        .trim()
        .toLowerCase();
    return effective == _uaeName;
  }

  /// Returns whether the selected product type is Islamic.
  bool get isProductTypeIslamic =>
      getFacility.selectedProductTypeValue?.id ==
      ServerConstants.productTypeIslamicID;

  /// Returns whether the current workflow is for a financial institution.
  bool get isFIFlow =>
      Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

  /// Applies SIC code field validation rules based on the selected limit group.
  ///
  /// The SIC code field is mandatory for all limit groups except Sovereign.
  void applySicCodeRules() {
    final bool isSovereign =
        ServerConstants.sovergianGroup == getFacility.limitGroup;

    dynamicFormKey.currentState?.setFieldMandatory(
      "sicCode",
      isMandatory: !isSovereign,
    );
  }

  /// Returns true when the Project Finance Related Activity is selected as "No"
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

  /// Indicates whether the create facility form is displayed.
  bool showCreateFacilityForm = false;

  /// Indicates whether the proposed limit amount field is displayed.
  bool showNewProposedLimitAmount = false;

  /// Indicates whether the present limit amount field is displayed.
  bool showNewPresentLimitAmount = false;

  /// Indicates whether the present outstanding amount field is displayed.
  bool showNewPresentOutStandingLimit = false;

  /// Indicates whether the revised bank limit proposed by FI amount field is displayed.
  bool showNewRevisedBankLimitProposedByFiAmount = false;

  /// Indicates whether the excess over maximum limit allowance proposed by FI amount field is displayed.
  bool showNewExcessOverMaxLimitAllowanceProposedByFiAmount = false;

  /// Indicates whether the CBD equity tier 3.25 percent amount field is displayed.
  bool showNewCbdEquityTier325PercentAmount = false;

  /// Indicates whether the counterparty equity 5 percent amount field is displayed.
  bool showNewCounterpartyEquity5PercentAmount = false;

  /// Indicates whether the counterparty total assets 2 percent amount field is displayed.
  bool showNewCounterpartyTotalAssets2PercentAmount = false;

  /// Indicates whether the revised bank limit recommended by credit amount field is displayed.
  bool showNewRevisedBankLimitRecommendedByCreditAmount = false;

  /// Indicates whether the excess over maximum limit allowance recommended by credit amount field is displayed.
  bool showNewExcessOverMaxLimitAllowanceRecommendedByCreditAmount = false;

  /// Indicates whether the proposed by currency amount field is displayed.
  bool showNewProposedByCCAmount = false;

  /// Indicates whether foreign exchange rate fields are disabled.
  bool disableFxRates = false;

  /// Collection of standard facility conditions.
  List<FacilityCondition> conditionsStandard = [];

  /// Collection of non-standard facility conditions.
  List<FacilityCondition> conditionsNonStandard = [];

  /// Collection of contracting standard facility conditions.
  List<FacilityCondition> contractingConditionsStandard = [];

  /// Currently selected product type.
  Reference? selectedProductType;

  /// Current borrower RIM number.
  int? rimNo;

  /// Selected borrower RIM number.
  int? selectedRim;

  /// Identifier of the existing facility.
  int? existingFacilityId;

  /// Identifier of the facility master record.
  int? facilityMasterId;

  /// Identifier of the associated group.
  int? groupId;

  /// Selected limit cap type identifier.
  int? limitCapType;

  /// Parent facility proposed limit value.
  int? parentProposedLimit;

  /// Parent controlling limit number.
  String? parentControlliingNumber;

  /// Controller for the limit type field.
  TextEditingController limitTypeController = TextEditingController();

  /// Controller for the limit description field.
  TextEditingController limitDescriptionController = TextEditingController();

  /// Controllers for limit-related amount fields.

  /// Controller for the proposed limit amount field.
  TextEditingController proposedLimitController = TextEditingController();

  /// Controller for the formatted proposed limit amount field.
  TextEditingController newProposedLimitController = TextEditingController();

  /// Controller for the present limit amount field.
  TextEditingController presentLimitController = TextEditingController();

  /// Controller for the formatted present limit amount field.
  TextEditingController newPresentLimitController = TextEditingController();

  /// Controller for the present outstanding amount field.
  TextEditingController presentOutstandingController = TextEditingController();

  /// Controller for the formatted present outstanding amount field.
  TextEditingController newPresentOutStandingController =
      TextEditingController();

  /// Controller for the excess over maximum limit allowance proposed by FI field.
  TextEditingController excessOverMaxLimitAllowanceProposedByFiController =
      TextEditingController();

  /// Controller for the formatted excess over maximum limit allowance
  /// proposed by FI field.
  TextEditingController newExcessOverMaxLimitAllowanceProposedByFiController =
      TextEditingController();

  /// Controller for the CBD equity tier 3.25 percent field.
  TextEditingController cbdEquityTier325PercentController =
      TextEditingController();

  /// Controller for the formatted CBD equity tier 3.25 percent field.
  TextEditingController newCbdEquityTier325PercentController =
      TextEditingController();

  /// Controller for the counterparty equity 5 percent field.
  TextEditingController counterpartyEquity5PercentController =
      TextEditingController();

  /// Controller for the formatted counterparty equity 5 percent field.
  TextEditingController newCounterpartyEquity5PercentController =
      TextEditingController();

  /// Controller for the counterparty total assets 2 percent field.
  TextEditingController counterpartyTotalAssets2PercentController =
      TextEditingController();

  /// Controller for the formatted counterparty total assets 2 percent field.
  TextEditingController newCounterpartyTotalAssets2PercentController =
      TextEditingController();

  /// Controller for the proposed-by currency amount field.
  TextEditingController proposedByccController = TextEditingController();

  /// Controller for the formatted proposed-by currency amount field.
  TextEditingController newProposedByccController = TextEditingController();

  /// Controller for the excess over maximum limit allowance recommended
  /// by credit field.
  TextEditingController
      excessOverMaxLimitAllowanceRecommendedByCreditController =
      TextEditingController();

  /// Controller for the formatted excess over maximum limit allowance
  /// recommended by credit field.
  TextEditingController
      newExcessOverMaxLimitAllowanceRecommendedByCreditController =
      TextEditingController();

  /// Identifier of the selected facility description.
  int? selectedDescriptionId;

  /// Number of mandatory rows required in the fee table.
  String? mandatoryFeeTableRows;

  /// Selected limit category.
  String? limitCategory;

  /// Identifier of the selected product type.
  int? productType;

  /// Indicates whether at least one fee row is mandatory.
  bool isFeeRowMandatory = false;

  /// Indicates whether the facility is a sub-limit.
  bool? subLimit;

  static const String _uaeName = "united arab emirates";
  static const Set<int> _pfDisabledGroups = {11312, 11313, 11314, 11315, 11317};
  static const Set<int> _pfForceYesGroups = {11315, 11317};

  /// Returns the sustainability classification identifiers as a
  /// comma-separated string.
  ///
  /// Returns `null` when no sustainability classifications are selected.
  String? get sustainabilityClassificationCsv {
    final List<Reference>? list = getFacility.sustainabilityClassification;

    if (list == null || list.isEmpty) {
      return null;
    }

    final List<String> ids = list
        .map((e) => e.id?.toString())
        .where((id) => id != null && id.trim().isNotEmpty)
        .map((id) => id!.trim())
        .toList();

    return ids.isEmpty ? null : ids.join(",");
  }

  /// Facility types available under the selected customer RIM.
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

  /// Available project name options.
  List<Reference> projectNames = [];

  /// Identifier of the selected limit group.
  int? limitGroup;

  /// Returns whether the project finance related activity option is enabled
  /// for the selected limit group.
  ///
  /// The option is disabled for limit groups defined in
  /// [_pfDisabledGroups].
  bool get isProjectFinanceActivityEnabled {
    final int? lg = limitGroup;
    return !(lg != null && _pfDisabledGroups.contains(lg));
  }

  /// Indicates whether the current application is an annual review.
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
    if (isFIFlow && getFacility.commitmentAccountNumber?.name != _newAccLabel) {
      presentOutStandingReadOnly =
          false; // presentOutstanding field will be always read only except in FI flow and commitment account number is not "NEW"
    }
    if (commitmentAccountNumberItems.isEmpty) {
      return facilityDetail.isNotEmpty
          ? [facilityDetail.first.commitmentAccountNumber]
          : [_newAccLabel];
    }
    if (showCreateFacilityForm) {
      return null;
    }
    final String? apiAcc = facilityDetail.isNotEmpty
        ? facilityDetail.first.commitmentAccountNumber
        : null;
    final String acc = (apiAcc ?? "").trim();
    if (acc.isNotEmpty) {
      return [acc];
    }
    return null;
  }

  /// Stores borrower RIMs with invalid allocation values.
  ///   - Blocking form submission
  ///   - Highlighting validation issues
  ///
  /// Cleared automatically when:
  ///   - User corrects allocation amoun
  final Set<int> _invalidAllocationRims = <int>{};

  /// Returns the default project finance reference based on the selected
  /// limit group.
  ///
  /// Returns "Yes" for limit groups listed in [_pfForceYesGroups];
  /// otherwise returns "No".
  Reference get projectFinanceDefaultRef =>
      _pfForceYesGroups.contains(limitGroup ?? -1)
          ? _pfRefByName("yes")
          : _pfRefByName("no");

  /// Returns whether the current form is in sub-limit mode.
  ///
  /// A facility is considered a sub-limit when it is not marked as a
  /// main limit.
  bool get isSubLimitMode => !(getFacility.isMainLimit ?? false);

  /// Returns the parent proposed limit amount in AED.
  ///
  /// Defaults to `0` when the parent proposed limit is not available.
  int get parentLimitAED => parentProposedLimit ?? 0;

  /// Returns the maximum amount that can be entered in the selected currency.
  ///
  /// The value is derived from the parent limit in AED and the current
  /// exchange rate. When the selected currency is AED or the exchange
  /// rate is unavailable, the AED value is returned directly.
  int get maxInputInSelectedCurrency {
    final String code = (selectedCurrencyCode ?? "").toUpperCase();

    if (code == ServerConstants.aedCurrency || exchangeRate == 0) {
      return parentLimitAED;
    }

    return (parentLimitAED / exchangeRate).floor();
  }

  /// Returns the selected project finance activity value.
  ///
  /// When the project finance activity option is disabled, a rule-based
  /// default value is returned. For enabled scenarios, the selected value
  /// is returned, falling back to the default when no selection exists.
  Reference get projectFinanceSelectedOrDefault {
    if (!isProjectFinanceActivityEnabled) {
      return projectFinanceDefaultRef;
    }
    return getFacility.selectedProjectFinanceRelatedActivityValue ??
        projectFinanceDefaultRef;
  }

  /// Selected account type values.
  List<Reference> selectedAccountTypes = [];

  /// Returns the selected account type identifiers as a comma-separated string.
  ///
  /// When multiple account types are selected, all identifiers are included.
  /// If no multi-select values exist, the single selected account type is used.
  /// Returns `null` when no account type has been selected.
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

  /// Returns property subtypes associated with the selected property type.
  ///
  /// When no property type is selected, all available property subtypes
  /// are returned.
  List<Reference> get propertySubTypesForSelectedType {
    final String? parentId = getFacility.propertyType?.id?.toString();

    if (parentId == null || parentId.isEmpty) {
      return propertySubTypes;
    }

    return propertySubTypes.where((sub) {
      final String? ref1 = sub.reference1?.trim();
      return ref1 != null && ref1 == parentId;
    }).toList();
  }

  /// Indicates whether limit cap functionality is enabled.
  bool isLimitCaps = false;

  /// Customers available for limit cap allocation.
  List<Customer>? limitCapsCustomerList = [];

  num _numOr(num? value, num fallback) => value ?? fallback;
  bool _boolOr(bool? value, bool fallback) => value ?? fallback;

  // ---- Stable inputs for AllocateLimitDialogBox rows (survive re-mounts) ----
  final Map<int, TextEditingController> _allocationControllers = {};
  final Map<int, FocusNode> _allocationFocusNodes = {};

  int _borrowerKey(Reference b) {
    final int? id = b.id;
    if (id is int) {
      return id;
    }
    return (b.name ?? "").hashCode; // fallback when id isn't int
  }

  /// Returns the text controller associated with the specified borrower.
  ///
  /// Creates and stores a new controller when one does not already exist.
  TextEditingController controllerForBorrower(Reference b) {
    final int k = _borrowerKey(b);
    return _allocationControllers.putIfAbsent(
      k,
      () => TextEditingController(text: b.description ?? ""),
    );
  }

  /// Returns the focus node associated with the specified borrower.
  ///
  /// Creates and stores a new focus node when one does not already exist.
  FocusNode focusNodeForBorrower(Reference b) {
    final int k = _borrowerKey(b);
    return _allocationFocusNodes.putIfAbsent(k, FocusNode.new);
  }

  /// Controllers used to manage subtype proposed limit values by row index.
  final Map<int, TextEditingController> _subtypeProposedControllers = {};

  /// Returns the proposed limit controller for the specified subtype row.
  ///
  /// Creates a controller and initializes it with the current proposed limit
  /// value when one does not already exist.
  TextEditingController proposedLimitControllerFor(int rowIndex) {
    return _subtypeProposedControllers.putIfAbsent(rowIndex, () {
      final NumberFormat fmt = NumberFormat("#,###");
      final int raw = (facilitySubTypes.length > rowIndex)
          ? (facilitySubTypes[rowIndex].proposedLimit ?? 0)
          : 0;

      return TextEditingController(
        text: raw > 0 ? fmt.format(raw) : "",
      );
    });
  }

  /// Indicates whether the allocation validation toast is currently visible.
  ///
  /// Used to prevent duplicate validation messages from being displayed.
  bool _allocationToastVisible = false;

  /// Indicates whether standby sub-limit validation is enabled.
  bool? isStanbySublimitValidation = false;

  /// Stores exchange rates for subtype rows keyed by row index.
  final Map<int, num> _subtypeExchangeRates = {};

  /// Returns the exchange rate associated with the specified subtype row.
  ///
  /// Returns `0` when no exchange rate is available.
  num rateForSubType(int rowIndex) => _subtypeExchangeRates[rowIndex] ?? 0;

  /// Selected borrowers for each facility subtype row.
  ///
  /// The key represents the facility subtype row index.
  final Map<int, List<Reference>> subLimitBorrowersByIndex = {};

  /// Conditions associated with each facility subtype row.
  ///
  /// The key represents the facility subtype row index.
  final Map<int, List<Condition>> subLimitConditionsByIndex = {};

  /// Returns whether the project name field should be enabled.
  ///
  /// The project name is enabled when the selected project finance
  /// related activity is "Yes" or when the selected limit group
  /// requires project finance activity by default.
  bool get isProjectNameEnabled {
    final selectedName =
        (getFacility.selectedProjectFinanceRelatedActivityValue?.name ?? "")
            .trim()
            .toLowerCase();

    final bool isYes = selectedName == "yes";
    final bool isForceYesGroup = _pfForceYesGroups.contains(limitGroup ?? -1);

    return isYes || isForceYesGroup;
  }

  /// Reference data collections grouped by category name.
  Map<String, List<Reference>> referenceData = {};

  /// Limit cap value received from the Facilities Summary screen.
  int? limitCapsFromSummary;

  /// Initial page index for the contracting conditions table.
  int initialPageContractingConditions = 0;

  /// Initial page index for the standard conditions table.
  int initialPageStandardConditions = 0;

  /// Initial page index for the non-standard conditions table.
  int initialPageNonStandardConditions = 0;

  /// Initial page index for the sub-limit contracting conditions table.
  int subLimitTableInitialPageContractingConditions = 0;

  /// Initial page index for the sub-limit standard conditions table.
  int subLimitTableInitialPageStandardConditions = 0;

  /// Initial page index for the sub-limit non-standard conditions table.
  int subLimitTableInitialPageNonStandardConditions = 0;

  /// Returns the effective Proposed Limit to be used for validation.
  ///
  /// ------------------ PRIORITY ORDER ------------------
  /// 1. getFacility.proposedLimit (explicit user input)
  /// 2. proposedLimitController (live UI value)
  /// 3. facilityDetail.first.proposedLimit (API fallback)
  /// 4. Defaults to 0 if none available
  ///
  /// ------------------ USAGE ------------------
  /// Used for:
  ///   - Allocation validation
  ///   - Save-time validation
  ///
  /// ------------------ NOTE ------------------
  /// This method ensures correct behavior across:
  /// - New facility creation (no API data)
  /// - Edit mode
  /// - Sub-limit flows (PSPL / PSBL / general)
  int get effectiveProposedLimit {
    final int? fromUser = getFacility.proposedLimit;

    if (fromUser != null && fromUser > 0) {
      return fromUser;
    }

    final int controllerValue =
        int.tryParse(proposedLimitController.text.replaceAll(",", "")) ?? 0;

    if (controllerValue > 0) {
      return controllerValue;
    }

    final int? fromApi =
        facilityDetail.isNotEmpty ? facilityDetail.first.proposedLimit : null;

    return fromApi ?? 0;
  }

  ///init method all api calls happen here and we get data from previous screen
  /// that is required here based on limit and limit type description
  Future<void> init({
    required bool showCreateForm,
    Facility? selectedFacility,
    PageMode? pageModeFromArgs,
    bool? sublimitValidation,
  }) async {
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loading,
        navigateToCreateFacility: LoadingStatus.loading,
      ),
    );
    try {
      isSublimitValidation = sublimitValidation ?? false;
      repository = FacilitySecurityRepository.instance;

      pageMode = pageModeFromArgs ??
          AuthRepository.getPageMode(RightConstants.createFacility);
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
      parentProposedLimit = selectedFacility?.proposedLimit ??
          getFacility.proposedLimit ??
          getFacility.totalProposedLimit;

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
              selectedFacility?.limitGroupName;
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
      applySicCodeRules();

      // await setDynamicForm();

      if (getFacility.projectName != null) {
        final String sel =
            (getFacility.projectName!.name ?? "").trim().toLowerCase();
        final bool exists =
            projectNames.any((r) => (r.name ?? "").trim().toLowerCase() == sel);
        if (!exists) {
          projectNames.insert(0, getFacility.projectName!);
        }
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
    } on Object catch (_) {}
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
      dynamicFormKey.currentState
          ?.setFieldVisibility("extentOfFinance", isVisible: true);
      dynamicFormKey.currentState
          ?.setFieldVisibility("customerContribution", isVisible: true);
      dynamicFormKey.currentState
          ?.setFieldMandatory("extentOfFinance", isMandatory: selectedYes);
      dynamicFormKey.currentState
          ?.setFieldMandatory("customerContribution", isMandatory: selectedYes);

      if (dynamicFormDocument.containsKey("acceptableInvoiceCurrencies")) {
        final value = dynamicFormDocument["acceptableInvoiceCurrencies"];
        bool hasOther = false;
        if (value is List) {
          hasOther = value.contains("Other");
        }
        dynamicFormKey.currentState
            ?.setFieldVisibility("specifyOthercurrency", isVisible: hasOther);
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

  /// Configures dynamic form field visibility, enablement, and validation rules
  /// based on the current form data and facility configuration.
  ///
  /// Applies conditional behavior for:
  /// - Repayment type selection
  /// - Shipment and finance options
  /// - Installment loan configurations
  /// - Promissory note settings
  /// - Margin-related fields
  /// - LG period settings
  /// - Commission and benchmark values
  /// - Collateral-dependent fields
  ///
  /// This method is typically invoked when loading or refreshing the
  /// dynamic form state.
  Future<void> setDynamicForm() async {
    DynamicFormState? form;
    if (sections.isNotEmpty) {
      form = dynamicFormKey.currentState;
    }

    if (dynamicFormDocument.containsKey("repaymentTypeTawarrukPPC")) {
      if (dynamicFormDocument["repaymentTypeTawarrukPPC"] == "instalments") {
        form?.setFieldVisibility("instalments", isVisible: true);
        form?.setFieldVisibility("bullet", isVisible: false);
      } else if (dynamicFormDocument["repaymentTypeTawarrukPPC"] == "bullet") {
        form?.setFieldVisibility("instalments", isVisible: false);
        form?.setFieldVisibility("bullet", isVisible: true);
      }
    }

    if (dynamicFormDocument.containsKey("repaymentTypeTawarrukInvoice")) {
      if (dynamicFormDocument["repaymentTypeTawarrukInvoice"] ==
          "instalments") {
        form?.setFieldVisibility("instalments", isVisible: true);
        form?.setFieldVisibility("bullet", isVisible: false);
      } else if (dynamicFormDocument["repaymentTypeTawarrukInvoice"] ==
          "bullet") {
        form?.setFieldVisibility("instalments", isVisible: false);
        form?.setFieldVisibility("bullet", isVisible: true);
      }
    }

    if (dynamicFormDocument.containsKey("preShipment")) {
      form?.setFieldVisibility(
        "preShipmentAmount",
        isVisible: dynamicFormDocument["preShipment"] ?? false,
      );
    }
    if (dynamicFormDocument.containsKey("postShipment")) {
      form?.setFieldVisibility(
        "postShipmentAmount",
        isVisible: dynamicFormDocument["postShipment"] ?? false,
      );
    }

    // Overseas Shipment → overseasShipmentAmount
    if (dynamicFormDocument.containsKey("overseasShipment")) {
      form?.setFieldVisibility(
        "overseasShipmentAmount",
        isVisible: dynamicFormDocument["overseasShipment"] ?? false,
      );
    }

    // Third Port Shipment → thirdPortShipmentAmount
    if (dynamicFormDocument.containsKey("thirdPortShipment")) {
      form?.setFieldVisibility(
        "thirdPortShipmentAmount",
        isVisible: dynamicFormDocument["thirdPortShipment"] ?? false,
      );
    }

    // Local Delivery → localDeliveryAmount
    if (dynamicFormDocument.containsKey("localDelivery")) {
      form?.setFieldVisibility(
        "localDeliveryAmount",
        isVisible: dynamicFormDocument["localDelivery"] ?? false,
      );
    }

    // Finance under LC → financeUnderLCAmount
    if (dynamicFormDocument.containsKey("financeUnderLC")) {
      form?.setFieldVisibility(
        "financeUnderLCAmount",
        isVisible: dynamicFormDocument["financeUnderLC"] ?? false,
      );
    }

    // Finance against collection → financeAgainstCollectionAmount
    if (dynamicFormDocument.containsKey("financeAgainstCollection")) {
      form?.setFieldVisibility(
        "financeAgainstCollectionAmount",
        isVisible: dynamicFormDocument["financeAgainstCollection"] ?? false,
      );
    }

    // Shipment by sea/Air → shipmentBySea/AirAmount
    if (dynamicFormDocument.containsKey("shipmentBySeaOrAir")) {
      form?.setFieldVisibility(
        "shipmentBySea/AirAmount",
        isVisible: dynamicFormDocument["shipmentBySeaOrAir"] ?? false,
      );
    }

    // Shipment by Truck → shipmentByTruckAmount
    if (dynamicFormDocument.containsKey("shipmentByTruck")) {
      form?.setFieldVisibility(
        "shipmentByTruckAmount",
        isVisible: dynamicFormDocument["shipmentByTruck"] ?? false,
      );
    }

    // Chartered Party/Bill of Lading → charteredBillLadingAmount
    if (dynamicFormDocument.containsKey("charterBillLading")) {
      form?.setFieldVisibility(
        "charteredBillLadingAmount",
        isVisible: dynamicFormDocument["charterBillLading"] ?? false,
      );
    }

    //
    if (dynamicFormDocument.containsKey("rePaymentType")) {
      final rePaymentType = form?.getFieldValue("rePaymentType");
      if (rePaymentType == "installmentLoan") {
        form?.setFieldVisibility("interestGrid", isVisible: false);
        form?.setFieldVisibility("principal", isVisible: false);
        form?.setFieldVisibility("equated", isVisible: false);
        form?.setFieldVisibility("InstallmentloanOptions", isVisible: true);
        form?.setFieldVisibility(
          "NoOfYearsTenor",
          isVisible: true,
        );
        form?.setFieldVisibility("NoOfInstallmentsPerYear", isVisible: true);
        form?.setFieldVisibility("equated", isVisible: false);
      } else if (rePaymentType == "equatedLoan") {
        form?.setFieldVisibility("equated", isVisible: true);
        form?.setFieldVisibility("interestGrid", isVisible: false);
        form?.setFieldVisibility("principal", isVisible: false);
      }
    }
    // REAPPLY option-based visibility when reopening existing facility
    final dynamic opt = dynamicFormDocument["InstallmentloanOptions"] ??
        form?.getFieldValue("InstallmentloanOptions");

    final String norm = (opt?.toString() ?? "")
        .trim()
        .toLowerCase()
        .replaceAll("_", "")
        .replaceAll(" ", "");

    final bool isStraightLine =
        norm == "straightline" || norm == "straight"; // defensive

    if (isStraightLine) {
      form?.setFieldVisibility("NoOfYearsTenor", isVisible: true);
      form?.setFieldVisibility("NoOfInstallmentsPerYear", isVisible: true);
      form?.setFieldVisibility("interestGrid", isVisible: false);
      form?.setFieldVisibility("principal", isVisible: false);
    } else if (norm == "sculpted") {
      form?.setFieldVisibility("interestGrid", isVisible: true);
      form?.setFieldVisibility("principal", isVisible: true);
      form?.setFieldVisibility("NoOfYearsTenor", isVisible: false);
      form?.setFieldVisibility("NoOfInstallmentsPerYear", isVisible: false);
    }

    // Master Promissory Note held →
    //   Use ONE of the following, depending on your form:

    // Variant A: it shows an Amount field
    if (dynamicFormDocument.containsKey("masterPromissoryNoteHeld")) {
      form?.setFieldVisibility(
        "masterPromissoryNoteHeldAmount",
        isVisible: dynamicFormDocument["masterPromissoryNoteHeld"] ?? false,
      );
    }

    //
    if (dynamicFormDocument.containsKey("recourse")) {
      final recourse = form?.getFieldValue("recourse");
      if (recourse != null && recourse == "withoutRecourse") {
        form?.setFieldVisibility("creditInsuranceCompanyName", isVisible: true);
        form?.setFieldVisibility(
          "creditInsurancePolicyDetails",
          isVisible: true,
        );
      }
    }

    // Variant B: it shows a Number/ID field
    if (dynamicFormDocument.containsKey("masterPromissoryNoteHeld")) {
      form?.setFieldVisibility(
        "masterPromissoryNoteNumber",
        isVisible: dynamicFormDocument["masterPromissoryNoteHeld"] ?? false,
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
        form?.setFieldMandatory("marginExtent", isMandatory: hasValue);

        // Linked Account Number becomes mandatory only for Time Deposits
        form?.setFieldMandatory(
          "linkedAccountNumber",
          isMandatory: isTimeDeposits,
        );
        break; // Only process the first found margin key
      }
    }

    if (dynamicFormDocument.containsKey("lgPeriodType")) {
      final value = dynamicFormDocument["lgPeriodType"];

      if ((value.toString().trim()) == "openEnded") {
        form?.updateFieldValue(
          "lgPeriodMonths",
          null,
        );
        form?.setFieldEnabled("lgPeriodMonths", isEnabled: false);
        form?.setFieldMandatory("lgPeriodMonths", isMandatory: false);
      } else {
        form?.setFieldEnabled("lgPeriodMonths", isEnabled: true);
        form?.setFieldMandatory("lgPeriodMonths", isMandatory: true);
      }
    }

    if (dynamicFormDocument.containsKey("lgCommission.gridCommission@0") ||
        dynamicFormDocument.containsKey("lcCommission.gridCommission@0") ||
        dynamicFormDocument.containsKey("avCommission.gridCommission@0")) {
      final value = dynamicFormDocument["lgCommission.gridCommission@0"] ||
          dynamicFormDocument["lcCommission.gridCommission@0"] ||
          dynamicFormDocument["avCommission.gridCommission@0"];

      getFacility.marginValue = value.toString();
    }

    if (dynamicFormDocument.containsKey("transactionCommission")) {
      final value = dynamicFormDocument["transactionCommission"];
      if (value is Map) {
        getFacility.marginValue = value["fromVal"]?.toString();
      }
    }

    if (dynamicFormDocument.containsKey("lcCommission.indexLcLGCommision@0") ||
        dynamicFormDocument.containsKey("index")) {
      final value = dynamicFormDocument["lcCommission.indexLcLGCommision@0"] ??
          dynamicFormDocument["index"];

      final bool isClearingSelection = value == null ||
          (value is Map &&
              value["value"] is List &&
              (value["value"] as List).isEmpty);
      if (isClearingSelection) {
        getFacility.index = null;
      } else {
        getFacility.index = getIndexBenchMark(
          {
            "value": [
              Option(
                pairValue: value,
                key: value,
              ),
            ],
          },
        )?.id.toString();
      }
    }
    final bool selectedYes = facilityDetail.isNotEmpty
        ? (facilityDetail.first.isCollateralDependent?.id ==
            ServerConstants.optionYESid)
        : _yesNoToBool(getFacility.selectedCollateralDepantantValue, false);

    form?.setFieldVisibility("extentOfFinance", isVisible: true);
    form?.setFieldVisibility("customerContribution", isVisible: true);
    form?.setFieldMandatory("extentOfFinance", isMandatory: selectedYes);
    form?.setFieldMandatory("customerContribution", isMandatory: selectedYes);
  }

  /// Initializes default values for collateral dependency and promissory note
  /// selections when creating a new facility.
  ///
  /// If no value has been selected, the corresponding "No" option is assigned
  /// as the default value.
  void getColletralAndPromissory() {
    if (showCreateFacilityForm &&
        getFacility.selectedCollateralDepantantValue == null) {
      try {
        final noRef = collateralDepantantoptions.firstWhere(
          (e) => e.id == ServerConstants.optionNOid,
        );
        getFacility.selectedCollateralDepantantValue = noRef;
      } on Object catch (_) {}
    }

    if (showCreateFacilityForm &&
        getFacility.selectedpromissoryNoteValue == null) {
      try {
        final noRef = promissoryNoteOptions.firstWhere(
          (e) => e.id == ServerConstants.optionNOid,
        );
        getFacility.selectedpromissoryNoteValue = noRef;
      } on Object catch (_) {}
    }
  }

  ///get child rim list for rim dropdown group limit cap type limit uses
  Future<void> getChildRimsForGroup() async {
    try {
      if (Utils.isGroupApplication()) {
        limitCapsCustomerList =
            await CustomerRepository.instance.getChildRimsForGroup() ?? [];
      }
    } on Object {
      rethrow;
    }
  }

  /// Refreshes facility type reference data and updates the available
  /// facility type and description lists.
  ///
  /// This is typically used after creating a new facility type to ensure
  /// the latest reference data is available in the form.
  Future<void> getUpdatedFacilityReference() async {
    final String facilityTypeKey = isFIFlow
        ? ReferenceDataKeys.fiFacilityTypes
        : ReferenceDataKeys.facilityTypes;

    try {
      final List<ReferenceType> getReferenceData =
          await HomeRepository.instance.getReferenceData([facilityTypeKey]);

      facilityDescriptions = getReferenceData[0].references ?? [];
      facilityTypes = getReferenceData[0].references ?? [];
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }

    logger.i(facilityDescriptions.toString());
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

      if (committedValues.isNotEmpty && getFacility.committedValues == null) {
        final noOption = committedValues.firstWhere(
          (e) => e.id == ServerConstants.optionNOid,
          orElse: () => committedValues.first,
        );

        getFacility.committedValues =
            committedValues.firstWhere((e) => e.id == noOption.id);
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

      propertySubTypes = referenceData[ReferenceDataKeys.propertySubType] ?? [];
      propertyTypes = referenceData[ReferenceDataKeys.propertyType] ?? [];
      sharedLimits = (referenceData[ReferenceDataKeys.yesNoNa] ?? [])
          .where((data) => data.id != ServerConstants.optionNAid)
          .toList()
        ..sort((a, b) {
          if (a.id == ServerConstants.optionNOid) {
            return -1;
          }
          if (b.id == ServerConstants.optionNOid) {
            return 1;
          }
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
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Filters policy deviation references based on FI/Corporate context.
  ///
  /// isFI ?? false:
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

  /// Retrieves limits and facility information for the specified borrower.
  ///
  /// Updates commitment account numbers, controlling limit numbers, and
  /// related facility data used during facility creation and editing.
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
        getFacility.presentOutstandingAmount = 0;
        getFacility.presentOutstandingAED = 0;
        presentOutStandingReadOnly =
            true; // as per new requirement from business team in bug - 1274178 , if seleted new the presnetOutStanding will be read only and setted as zero
      }

      final Set<String> seen = <String>{};
      controllingLimitNumbers = limits
          .map((e) => e.controllingLimitNo)
          .whereType<String>()
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty && seen.add(s)) // unique by string value
          .map((s) => Reference(name: s))
          .toList();
    } on Object catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  /// Loads facility details and associated reference data.
  ///
  /// Retrieves:
  /// - Facility details
  /// - Fee rates
  /// - Facility sub-limits
  /// - Facility conditions
  /// - Borrower mappings
  /// - Company borrower allocations
  ///
  /// For new facility creation, only facility conditions are initialized.
  Future<void> getFacilityDetails(
    int? existingFacilityId,
    int? rimNo, {
    int? groupId,
    int? limitCapType, // NEW
    int? facilityMasterId, // New param
  }) async {
//* as per the discussion and Mail confirmation from kamal and jessy on 20-May-2026 , removing the getfacilityDetails API call for new facility creation as it is not required
    if (showCreateFacilityForm) {
      await getFacilityConditionsList();
      return;
    }
    // if (showCreateFacilityForm) {
    //   final Map<String, dynamic> result = await repository.getFacilityDetails(
    //     null,
    //     rimNo ?? Globals.request?.customerRimNo,
    //     groupId: Globals.request?.groupId ?? 0, // confirm if it's id or owner
    //     limitCapType: isFIFlow ? null : limitCapType ?? 14492, // NEW
    //     facilityMasterId: facilityMasterId,
    //   );

    //   facilityDetail = result["facilityDetails"] ?? [];
    //   final List<Condition> allConditions = result["conditions"] ?? [];
    //   if (allConditions.isNotEmpty) {
    //     standardCondition = allConditions.where((c) => c.isStandard).toList();
    //     nonStandardCondition =
    //         allConditions.where((c) => c.isNonStandard).toList();
    //     contractingStandardCondition =
    //         allConditions.where((c) => c.isContractingStandard).toList();

    //     initialNonStandardConditionCount = nonStandardCondition.length;
    //   } else {
    //     await getFacilityConditionsList();
    //   }

    //   final List<dynamic> compRows = result["companyBorrowerList"] ?? const [];
    //   if (compRows.isNotEmpty) {
    //     for (final dynamic row in compRows) {
    //       final Map<String, dynamic> id =
    //           row?["id"] as Map<String, dynamic>? ?? const {};
    //       final int? rim = (id["borrowerRimNo"] is int)
    //           ? id["borrowerRimNo"] as int
    //           : int.tryParse((id["borrowerRimNo"] ?? "").toString());
    //       if (rim == null) {
    //         continue;
    //       }
    //       final int original = (row["originalLimitAllocation"] ?? 0) as int;
    //       final int present = (row["presentLimitAllocation"] ?? 0) as int;
    //       final int amount = (row["limitAllocationAmount"] ?? 0) as int;
    //       final String? subNo = (row["subLimitNo"] as String?)?.trim();
    //       groupCapsOriginalByRim[rim] = original;
    //       groupCapsPresentByRim[rim] = present;

    //       final int idx = borrowersByRimInTable
    //           .indexWhere((r) => (r.id?.toString() ?? "") == rim.toString());
    //       final String amtStr = amount.toString();
    //       if (idx >= 0) {
    //         borrowersByRimInTable[idx].description = amtStr;
    //         if ((subNo ?? "").isNotEmpty) {
    //           borrowersByRimInTable[idx].reference1 = subNo;
    //         }
    //       } else {
    //         borrowersByRimInTable.add(
    //           Reference(
    //             id: rim,
    //             description: amtStr,
    //             reference1: subNo,
    //           ),
    //         );
    //       }
    //     }
    //   }
    // }
    // //existing facility send rimno not group Owner
    // else

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
      facilitySubTypes =
          parseFacilitySubTypes(result["facilitySubLimits"] ?? []);
      final List<Condition> allConditions = result["conditions"] ?? [];
      if (allConditions.isNotEmpty) {
        standardCondition = allConditions.where((c) => c.isStandard).toList();
        nonStandardCondition =
            allConditions.where((c) => c.isNonStandard).toList();
        contractingStandardCondition =
            allConditions.where((c) => c.isContractingStandard).toList();
      }

      // Parse and flatten additionalDetails for dynamic form
      if (facilityDetail.isNotEmpty) {
        dynamicFormDocument = facilityDetail.first.additionalDetails!;
        getFacility.index ??= _readProfitGridIndexFromDocument();
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
          if (rim == null) {
            continue;
          }

          final int amount = (row["limitAllocationAmount"] ?? 0) as int;
          final String? subLimitNo = (row["subLimitNo"] as String?)?.trim();
          final int idx = borrowersMap.indexWhere(
            (r) => (r.id?.toString() ?? "") == rim.toString(),
          );
          final Reference ref = (idx >= 0)
              ? borrowersMap[idx]
              : Reference(id: rim, name: _borrowerDisplayByRim(rim));

          ref
            ..name ??= rim.toString()
            ..description = amount.toString()
            ..reference1 =
                (subLimitNo?.isNotEmpty ?? false ? subLimitNo : ref.reference1);

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
            if (idx < 0) {
              borrowersMap.add(ref);
            }
            ref.name ??= rimFromDetails.toString();

            ref.description ??= "0";

            borrowersByRimInTable.add(ref);
          }
        }
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      } on Object catch (_) {}

      final List<dynamic> compRows = result["companyBorrowerList"] ?? const [];
      if (compRows.isNotEmpty) {
        for (final row in compRows) {
          final id = row?["id"] as Map<String, dynamic>? ?? const {};
          final int? rim = (id["borrowerRimNo"] is int)
              ? id["borrowerRimNo"] as int
              : int.tryParse((id["borrowerRimNo"] ?? "").toString());
          if (rim == null) {
            continue;
          }
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

      String accNo;

      if (facilityDetail.isNotEmpty) {
        accNo = facilityDetail.first.commitmentAccountNumber.trim();

        if (accNo.isNotEmpty) {
          setControllingLimitByAccount(accNo);
        }
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Converts facility sub-limit response data into a list of
  /// [FacilitySubTypes] objects.
  List<FacilitySubTypes> parseFacilitySubTypes(List<dynamic>? data) {
    if (data == null || data.isEmpty) {
      return [];
    }

    return data
        .map<FacilitySubTypes?>((item) {
          final details = item["facilitySubLimits"]?["facilityDetails"];
          if (details == null) {
            return null;
          }

          return FacilitySubTypes(
            facilityId: details["facilityId"],
            subType: facilityTypes
                .firstWhere(
                  (type) =>
                      type.id ==
                      int.tryParse(details["limitDescription"].toString()),
                  orElse: Reference.new,
                )
                .name,
            proposedLimit: details["proposedLimit"],
            currency: details["currency"],
            subTypeSelected: details["subTypeSelected"] ?? false,
            pastDues: details["pastDues"],
            commitmentAccountNumber: details["commitmentAccountNumber"],
            currentOutstanding: details["presentOutstanding"],
            existingAmounts: details["existingAmounts"],
            tenorUnit: details["tenorUnit"],
            tenorValue: int.tryParse(details["tenorValue"] ?? "0"),
            tenor: details["tenor"],
            index: details["index"],
            marginSign: details["marginSign"],
            marginValue: details["marginValue"],
            alreadyExistingSubType: true,
          );
        })
        .whereType<FacilitySubTypes>()
        .toList();
  }

  /// Refreshes limit cap data and resets related allocation values.
  ///
  /// Clears validation errors and resets proposed limit cap information
  /// before triggering a UI refresh.
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
    if (!isGroup || !isSharedYes) {
      return null;
    }
    if (borrowersByRimInTable.isNotEmpty) {
      return borrowersByRimInTable;
    }
    final int? rim = getFacility.rimNo ?? selectedRim;
    if (rim == null) {
      return null;
    }
    final int idx = borrowersMap.indexWhere(
      (r) => (r.id?.toString() ?? "") == rim.toString(),
    );
    final Reference fallback = ((idx >= 0)
        ? borrowersMap[idx]
        : Reference(id: rim, name: _borrowerDisplayByRim(rim)))
      ..name ??= _borrowerDisplayByRim(rim);
    return [fallback];
  }

  /// Returns whether the current user can perform CMO updates.
  ///
  /// The user must have one of the supported CMO roles and be assigned
  /// to the current request.
  bool isCmoUpdate() {
    final bool hasCmoRole = Utils.checkRoles([
      UserRole.documentationChecker,
      UserRole.documentationMaker,
      UserRole.ccuChecker,
      UserRole.ccuMaker,
    ]);
    return hasCmoRole && ScreenAccessConditions.isAssignedToCurrentUser();
  }

  /// Returns whether the Proposed By Currency field is editable.
  ///
  /// The user must have one of the supported approval roles and be
  /// assigned to the current request.
  bool isEditableForProposedByCC() {
    final bool hasRole = Utils.checkRoles([
      UserRole.creditAnalyst,
      UserRole.creditCommitteeProxy,
      UserRole.boardDirectorProxy,
      UserRole.boardDirectorProxyApproval,
      UserRole.creditCommitteeProxyApprover,
    ]);
    return hasRole && ScreenAccessConditions.isAssignedToCurrentUser();
  }

  /// Sets the selected commitment account number and updates related
  /// facility values.
  ///
  /// Updates:
  /// - Present outstanding amount
  /// - Controlling limit number
  /// - Past dues information
  /// - Field editability rules
  Future<void> setCommitmentAccNumber(String commitmentAccNumber) async {
    final String accNo = commitmentAccNumber.trim();
    getFacility.commitmentAccountNumber = Reference(name: accNo);

    // Reset values first on every selection change
    getFacility.pastDues = Reference(
      name: ServerConstants.aedCurrency,
      description: "0",
    );

    //  If NEW → force Present Outstanding = 0
    if (accNo == ServerConstants.labelNew) {
      getFacility.presentOutstandingAmount = 0;

      // Clear UI controllers
      presentOutstandingController.text = "0";
      newPresentOutStandingController.text = "0";

      // Make field Editable if required by business

      presentOutStandingReadOnly = true;
    } else if (isFIFlow && accNo != ServerConstants.labelNew) {
      presentOutStandingReadOnly =
          false; // presentOutstanding field will be always read only except in FI flow and commitment account number is not "NEW"
    }

    // await Future.delayed(const Duration(milliseconds: 200));
    setControllingLimitByAccount(accNo);

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates facility values based on the selected commitment account.
  ///
  /// Populates:
  /// - Controlling limit number
  /// - Past dues
  /// - Outstanding amount
  /// - Limit amount
  /// - Currency information
  void setControllingLimitByAccount(String? accNoRaw) {
    final NumberFormat formatter = NumberFormat("#,###");
    final String? accNo = accNoRaw?.trim();
    if (accNo == null || accNo.isEmpty) {
      return;
    }

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

    // if ((currency?.isNotEmpty ?? false) || past != null) {
    //   final Reference ref = getFacility.pastDues ?? Reference();
    //   ref
    //     ..name = ServerConstants.aedCurrency
    //     ..description = past?.toString() ?? ref.description;
    //   getFacility.pastDues = ref;
    // }

    // Always update/clear Past Dues explicitly
    getFacility.pastDues = Reference(
      name: currency ?? ServerConstants.aedCurrency,
      description: past?.toString() ?? "0",
    );

    final num? outstandingAmount = match.outstandingAmount;

    if ((currency?.isNotEmpty ?? false) || outstandingAmount != null) {
      final Reference ref =
          getFacility.presentOutstandingCCValue ?? Reference();
      if (currency?.isNotEmpty ?? false) {
        ref.name = currency; // e.g., "AED"
      }
      getFacility.presentOutstandingCCValue = ref;
      getFacility.presentOutstandingCurrency = ref;

      getFacility.presentOutstandingAmount = outstandingAmount?.round() ?? 0;
      presentOutstandingController.text =
          formatter.format(getFacility.presentOutstandingAmount);
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

  /// Updates sub-limit values for the selected commitment account.
  ///
  /// Populates:
  /// - Past dues
  /// - Current outstanding amount
  /// - Commitment account number
  ///
  /// The delay is used to ensure UI updates are completed before
  /// emitting the loaded state.
  Future<void> setCommitementAccountNumber(
    String? accNoRaw,
    int index,
  ) async {
    final String? accNo = accNoRaw?.trim();
    if (accNo == null || accNo.isEmpty) {
      return;
    }

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
    await Future.delayed(
      const Duration(milliseconds: 400),
    ); //  to ensure UI updates before emitting loaded state. without this delay it casuing UAT bug 1301680

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Validates the borrower allocation amount against the Proposed Limit cap.
  ///
  /// This method is triggered whenever the user updates the allocation
  /// amount in the Limit Allocation table.
  ///
  /// ------------------ BEHAVIOR ------------------
  /// Uses the following priority to determine the cap:
  ///   1. getFacility.proposedLimit (user-entered value)
  ///   2. proposedLimitController (live typed value)
  ///   3. Falls back to 0 (no validation enforced)
  ///
  /// Applies ONLY individual allocation validation:
  ///   - Each borrower allocation must be <= Proposed Limit
  ///   - No aggregation or total sum validation is performed here
  ///
  /// If validation fails:
  ///   - Marks the borrower RIM as invalid
  ///   - Shows warning toast (rate-limited via shouldShowAllocationToastOnce)
  ///
  /// If validation passes:
  ///   - Removes borrower from invalid allocation set
  ///
  /// ------------------ IMPORTANT NOTES ------------------
  ///  Validation is skipped if Proposed Limit is not yet entered (cap == 0)
  ///  This ensures no false validation during new facility creation
  ///
  /// @param allocationAmount User-entered amount (string with commas)
  /// @param borrower Reference object representing borrower row
  void compareAllocationAmount(String allocationAmount, Reference borrower) {
    borrower.description = allocationAmount;

    final int cap = getFacility.proposedLimitAED ??
        int.tryParse(newProposedLimitController.text.replaceAll(",", "")) ??
        int.tryParse(proposedLimitController.text.replaceAll(",", "")) ??
        0;
    final int entered = int.tryParse(allocationAmount.replaceAll(",", "")) ?? 0;

    final bool exceedsSingle = entered > cap;
    final int? rimKey = _rimKeyOf(borrower);

    if (exceedsSingle) {
      if (rimKey != null) {
        _invalidAllocationRims.add(rimKey);
      }

      // toast only once (existing gate)
      if (shouldShowAllocationToastOnce()) {
        AlertManager().showWarningToast(
          "facilities.createFacility.allocationAmountErrorText".tr(),
        );
      }
    } else {
      if (rimKey != null) {
        _invalidAllocationRims.remove(rimKey);
      }
    }
  }

  /// Controls duplicate toast display for Proposed Limit validation.
  ///
  /// ------------------ PURPOSE ------------------
  /// Prevents repeated toast messages when user continuously types
  /// values above the allowed cap.
  ///
  /// ------------------ BEHAVIOR ------------------
  ///  Shows toast ONLY if:
  ///   - Current value exceeds cap
  ///   - Last shown value is different
  ///
  /// Resets when:
  ///   - User types a value within valid range
  ///
  /// ------------------ RETURN ------------------
  /// true  -> show toast
  /// false -> suppress duplicate toast
  bool shouldShowProposedLimitToastOnce(int enteredRaw) {
    if (!isSubLimitMode) {
      return false;
    }

    // We decide exceed here so we can also reset when user comes back under the
    // cap
    final bool exceeds = exceedsParentLimit(enteredRaw);

    if (!exceeds) {
      // reset so next time user exceeds again we can show toast
      _lastExceededToastValue = null;
      return false;
    }

    // If user is still exceeding, show toast again ONLY if value changed
    if (_lastExceededToastValue == enteredRaw) {
      return false;
    }

    _lastExceededToastValue = enteredRaw;
    return true;
  }

  /// Returns true exactly once while the allocation warning toast is visible.
  /// Prevents stacking multiple toasts on rapid blocked key presses.
  bool shouldShowAllocationToastOnce() {
    if (_allocationToastVisible) {
      return false;
    }
    _allocationToastVisible = true;
    Future.delayed(const Duration(milliseconds: 1500), () {
      _allocationToastVisible = false;
    });
    return true;
  }

  /// Returns the current limit allocation amount for the specified borrower.
  ///
  /// The value is retrieved from the borrower allocation table and returned
  /// as a string for display in the UI.
  String getGroupCapsAllocationDisplay(int? rimNo) {
    if (rimNo == null) {
      return "";
    }
    final String rimStr = rimNo.toString();
    final Reference ref = borrowersByRimInTable.firstWhere(
      (r) => (r.id?.toString() ?? "") == rimStr,
      orElse: Reference.new,
    );
    return (ref.description ?? "").trim();
  }

  /// Returns whether the entered amount exceeds the parent limit.
  ///
  /// When the selected currency is not AED, the entered amount is converted
  /// to AED using the current exchange rate before comparison.
  bool exceedsParentLimit(int enteredRaw) {
    if (parentLimitAED <= 0) {
      return false;
    }

    final String code = (selectedCurrencyCode ?? "").toUpperCase();
    final int enteredInAED =
        (code == ServerConstants.aedCurrency || exchangeRate == 0)
            ? enteredRaw
            : (enteredRaw * exchangeRate).round();
    return enteredInAED > parentLimitAED;
  }

  /// Validates the proposed limit amount.
  ///
  /// Ensures that:
  /// - A valid positive amount is entered.
  /// - The amount does not exceed the parent limit when creating a sub-limit.
  String? validateProposedLimit(String? value) {
    final String cleaned = (value ?? "").replaceAll(",", "");
    final int entered = int.tryParse(cleaned) ?? 0;
    if (entered <= 0) {
      return "Please enter a valid amount";
    }
    if (isSubLimitMode && parentLimitAED > 0 && exceedsParentLimit(entered)) {
      return "Proposed limit cannot exceed parent limit ";
    }
    return null;
  }

  //fetch summary and extract existing limitCapType set
  Future<Set<int>> _existingLimitCapTypesForCurrentRim() async {
    try {
      final List<FacilitySummaryList> lists =
          await repository.getFacilitySummaryList();

      // Prefer current rim; fall back to selectedRim / getFacility.rimNo
      final int? rimTarget = selectedRim ?? getFacility.rimNo ?? rimNo;
      if (rimTarget == null) {
        return <int>{};
      }

      final Set<int> result = <int>{};
      for (final FacilitySummaryList summary in lists) {
        for (final RimSummary rim in summary.rims ?? const <RimSummary>[]) {
          // Match the RIM we are working on
          final int? rimFromName =
              FacilitiesSummaryViewModel().extractRimId(rim.rimName);
          if (rimFromName != rimTarget) {
            continue;
          }

          for (final RimGroup grp in rim.groups ?? const <RimGroup>[]) {
            for (final FacilityDis dis
                in grp.facilityLimits ?? const <FacilityDis>[]) {
              final FacilitySummaryNew? f = dis.facility;
              if (f == null) {
                continue;
              }

              final bool isCap = (f.limitDescription?.toString() ==
                      ServerConstants.limitCapsDescriptionIdString) ||
                  ((f.productCode ?? "").trim().toUpperCase() ==
                      ServerConstants.productCodeClt);

              if (!isCap) {
                continue;
              }
              if (f.limitCapType == null) {
                continue;
              }

              // If editing an existing row, ignore this row’s own id
              if (getFacility.facilityId != null &&
                  f.facilityId == getFacility.facilityId) {
                continue;
              }
              final int? id = int.tryParse(f.limitCapType.toString());
              if (id != null) {
                result.add(id);
              }
            }
          }
        }
      }
      return result;
    } on Object catch (_) {
      return <int>{}; // on error, don't block (or you can choose to block)
    }
  }

  /// Updates the selected product type and refreshes the view state.
  void onProductTypeSelected(Reference selected) {
    selectedProductType = selected;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selected facility description.
  ///
  /// Refreshes the view state after the selection is changed.
  Future<void> facilityTypeDescriptionsSelected(
    Reference selectedValue,
  ) async {
    getFacility.facilityDescription = selectedValue;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Retrieves the list of available borrowers and maps them to references.
  ///
  /// Any previously selected borrowers that no longer exist in the
  /// retrieved data are removed from the current selection.
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
    } on Object catch (e) {
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
        final String customerName = (b.preferredName ?? "").trim();

        return Reference(
          id: rim,
          name:
              customerName.isNotEmpty ? "$customerName ($rim)" : rim.toString(),
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
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  String _borrowerDisplayByRim(int rim) {
    final match = borrowers.where((b) => b.customerRimNo == rim);
    if (match.isNotEmpty) {
      final b = match.first;
      final name = (b.preferredName ?? "").trim();
      return name.isNotEmpty ? "$name ($rim)" : rim.toString();
    }
    return rim.toString();
  }

  /// Stores borrower allocations for the specified sub-limit row.
  ///
  /// Each [Reference] represents a borrower allocation where:
  /// - `id` contains the borrower RIM number.
  /// - `description` contains the allocated amount.
  void setSubLimitAllocations(int index, List<Reference> allocations) {
    subLimitBorrowersByIndex[index] = allocations;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Stores conditions for the specified sub-limit row.
  void setSubLimitConditions(int index, List<Condition> conditions) {
    subLimitConditionsByIndex[index] = conditions;
  }

  /// Updates the currency for the specified sub-limit row.
  void setSubLimitCurrency(int index, String? code) {
    _meta(index).currency = (code ?? "").trim().isEmpty ? null : code!.trim();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the tenor unit for the specified sub-limit row.
  void setSubLimitTenorUnit(int index, String? unit) {
    _meta(index).tenorUnit = (unit ?? "").trim().isEmpty ? null : unit!.trim();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the tenor value for the specified sub-limit row.
  void setSubLimitTenorValue(int index, int? value) {
    _meta(index).tenorValue = value;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the benchmark index for the specified sub-limit row.
  void setSubLimitIndex(int index, String? idx) {
    _meta(index).index = (idx ?? "").trim().isEmpty ? null : idx!.trim();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the margin sign for the specified sub-limit row.
  void setSubLimitMarginSign(int index, String? sign) {
    _meta(index).marginSign = (sign ?? "").trim().isEmpty ? null : sign!.trim();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the margin value for the specified sub-limit row.
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
      if (sub.subTypeSelected != true) {
        continue;
      }

      final String subName = (sub.subType ?? "").trim().toLowerCase();
      final String familyRef3 =
          (getFacility.facilityDescription?.reference3 ?? "").trim();

      final Reference matchedType = facilityTypes.firstWhere(
        (ft) {
          final bool nameOk = ((ft.name ?? "").trim().toLowerCase() == subName);
          if (!nameOk) {
            return false;
          }
          // keep it robust if multiple names exist: also match the family code
          // when present
          if (familyRef3.isEmpty) {
            return true;
          }
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
        "proposedLimitAED": sub.proposedLimit ?? 0,
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
  List<int> _extractSubFacilityIdsFromResponse(resp) {
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
          if (id is int) {
            ids.add(id);
          }
          if (id is String) {
            final int? parsed = int.tryParse(id);
            if (parsed != null) {
              ids.add(parsed);
            }
          }
        }
      }
    } on Object catch (_) {/* ignore & return what we collected */}
    return ids;
  }

  /// Returns the configured large exposure limit amount.
  ///
  /// The amount is read from the first large exposure limit reference entry.
  double calculateLargeExposureLimitAmountValues(
    Map<String, List<Reference>> referenceData,
  ) {
    final List<dynamic> referenceRawList =
        referenceData[ReferenceDataKeys.largeExposureLimit] ?? [];

    final List<Reference> referenceList = referenceRawList.map((item) {
      if (item is Reference) {
        return item;
      }
      if (item is Map<String, dynamic>) {
        return Reference.fromJson(item);
      }
      throw Exception("Unexpected item type: ${item.runtimeType}");
    }).toList();

    if (referenceList.isEmpty) {
      return 0;
    }
    final Reference first = referenceList.first;
    // Be forgiving with formatting (e.g., "5,000" or "10%")
    final String amountRaw =
        (first.reference1 ?? "0").replaceAll(",", "").trim();
    final double amount = double.tryParse(amountRaw) ?? 0.0;
    return amount;
  }

  /// Returns the configured large exposure limit percentage.
  ///
  /// The percentage is read from the first large exposure limit reference entry.
  double calculateLargeExposureLimitPercentageValues(
    Map<String, List<Reference>> referenceData,
  ) {
    final List<dynamic> referenceRawList =
        referenceData[ReferenceDataKeys.largeExposureLimit] ?? [];

    final List<Reference> referenceList = referenceRawList.map((item) {
      if (item is Reference) {
        return item;
      }
      if (item is Map<String, dynamic>) {
        return Reference.fromJson(item);
      }
      throw Exception("Unexpected item type: ${item.runtimeType}");
    }).toList();

    if (referenceList.isEmpty) {
      return 0;
    }
    final Reference first = referenceList.first;
    // Be forgiving with formatting (e.g., "5,000" or "10%")
    final String percentRaw =
        (first.reference2 ?? "0").replaceAll("%", "").trim();
    final double percentage = double.tryParse(percentRaw) ?? 0.0;
    return percentage;
  }

  /// Calculates the large exposure limit value.
  ///
  /// The calculation is based on:
  /// `Amount × Percentage / 100`.
  double calculateLargeExposureLimit(
    Map<String, List<Reference>> referenceData,
  ) {
    // Read the raw list for LARGE_EXPOSURE_LIMIT
    final List<dynamic> referenceRawList =
        referenceData[ReferenceDataKeys.largeExposureLimit] ?? [];

    // Normalize to List<Reference>
    final List<Reference> referenceList = referenceRawList.map((item) {
      if (item is Reference) {
        return item;
      }
      if (item is Map<String, dynamic>) {
        return Reference.fromJson(item);
      }
      throw Exception("Unexpected item type: ${item.runtimeType}");
    }).toList();

    // Always use the FIRST item and ignore IDs.
    // columnsInfo = "Amount;Percentage" → reference1=Amount,
    // reference2=Percentage
    // (as per the server contract you shared)
    if (referenceList.isEmpty) {
      return 0;
    }
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

  /// Updates the allocation amount for the specified borrower.
  void updateBorrowerAllocationAmount(
    Reference borrower,
    String allocationAmount,
  ) {
    borrower.description = allocationAmount;
  }

  /// Initializes currency-dependent fields and related visibility settings.
  ///
  /// Populates currency values, converted amounts, and UI visibility flags
  /// using data loaded from facility details.
  void applyInitialCurrencyVisibility() {
    if (facilityDetail.isEmpty) {
      return;
    }

    final detail = facilityDetail.first;

    final formatter = NumberFormat("#,###");

    void processCurrencyCovertedFieldField({
      required double? apiAmount,
      required Reference? apiCurrency,
      required void Function(double) assignAmount,
      required void Function(Reference) assignCurrency,
      required TextEditingController mainCtrl,
      required TextEditingController convertedCtrl,
      required void Function({bool value}) setVisibilityFlag,
      required CurrencyField currencyField,
    }) {
      final double amount =
          (apiAmount == null || apiAmount.isNaN) ? 0 : apiAmount;

      final Reference? currency = apiCurrency;

      // 1) Set amount into facility model
      assignAmount(amount);

      // 2) Set currency into facility model
      if (currency != null) {
        assignCurrency(currency);
      }

      // 3) Write the raw API amount into main text controller
      mainCtrl.text = formatter.format(amount);

      if (currency == null) {
        return;
      }

      final String code = currency.name?.trim().toUpperCase() ??
          ServerConstants.facilityAedCurrency;
      final bool isNonAED = code != ServerConstants.aedCurrency;

      // 4) Toggle new converted field visibility
      setVisibilityFlag(value: isNonAED);

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
      setVisibilityFlag: ({bool? value}) =>
          showNewPresentOutStandingLimit = value ?? false,
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
      setVisibilityFlag: ({bool? value}) =>
          showNewCbdEquityTier325PercentAmount = value ?? false,
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
      setVisibilityFlag: ({bool? value}) =>
          showNewCounterpartyEquity5PercentAmount = value ?? false,
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
      setVisibilityFlag: ({bool? value}) =>
          showNewCounterpartyTotalAssets2PercentAmount = value ?? false,
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
      setVisibilityFlag: ({bool? value}) =>
          showNewProposedLimitAmount = value ?? false,
      currencyField: CurrencyField.proposedLimit,
    );

    // 5. Present Limit (if used similarly)
    processCurrencyCovertedFieldField(
      apiAmount: detail.presentLimitAED?.toDouble(),
      apiCurrency: getFacility.presentLimitValue,
      assignAmount: (v) => getFacility.presentLimit = v.toInt(),
      assignCurrency: (c) => getFacility.presentLimitValue = c,
      mainCtrl: presentLimitController,
      convertedCtrl: newPresentLimitController,
      setVisibilityFlag: ({bool? value}) =>
          showNewPresentLimitAmount = value ?? false,
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
      setVisibilityFlag: ({bool? value}) =>
          showNewRevisedBankLimitProposedByFiAmount = value ?? false,
      currencyField: CurrencyField.revisedBankLimitProposedByFi,
    );

    // 7. Revised Bank Limit Recommended By Credit
    processCurrencyCovertedFieldField(
      apiAmount: getFacility.proposedByCc,
      apiCurrency: Reference(name: getFacility.proposedByCcCurrency),
      assignAmount: (v) => getFacility.proposedByCc =
          v, //on save click value retained issue resolved
      assignCurrency: (c) => getFacility.proposedByCcCurrency = c.name,
      mainCtrl: proposedByccController,
      convertedCtrl: newProposedByccController,
      setVisibilityFlag: ({bool? value}) =>
          showNewRevisedBankLimitRecommendedByCreditAmount = value ?? false,
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
      setVisibilityFlag: ({bool? value}) =>
          showNewExcessOverMaxLimitAllowanceProposedByFiAmount = value ?? false,
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
      setVisibilityFlag: ({bool? value}) =>
          showNewExcessOverMaxLimitAllowanceRecommendedByCreditAmount =
              value ?? false,
      currencyField:
          CurrencyField.excessOverMaxLimitAllowanceRecommendedByCredit,
    );

    //10 ProposedBy CC
    processCurrencyCovertedFieldField(
      apiAmount: getFacility.proposedByCc,
      apiCurrency: Reference(name: getFacility.proposedByCcCurrency),
      assignAmount: (v) => getFacility.proposedByCc = v,
      assignCurrency: (c) => getFacility.proposedByCcCurrency = c.name,
      mainCtrl: proposedByccController,
      convertedCtrl: newProposedByccController,
      setVisibilityFlag: ({bool? value}) =>
          showNewProposedByCCAmount = value ?? false,
      currencyField: CurrencyField.proposedBycc,
    );

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Retrieves currency exchange rates and updates converted amount fields.
  ///
  /// For non-AED currencies, the entered amount is converted using the
  /// latest exchange rate. AED values are displayed without conversion.
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

      if (ctrl == null) {
        return;
      }

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
      if (rate <= 0) {
        return;
      }

      final int converted = (rawAmount * rate).round();

      ctrl.value = TextEditingValue(
        text: formatter.format(converted),
        selection:
            TextSelection.collapsed(offset: formatter.format(converted).length),
      );
    } on Object catch (error) {
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

  /// Retrieves and stores the exchange rate for the specified subtype row.
  ///
  /// The exchange rate is maintained per row and does not affect the
  /// global exchange rate used elsewhere in the form.
  Future<void> getSubTypeCurrencyRate(
    int rowIndex,
    Reference selectedCurrency,
  ) async {
    try {
      final CurrencyRates rates =
          await repository.getCurrencyRates(selectedCurrency);
      _subtypeExchangeRates[rowIndex] = rates.rates[selectedCurrency.name] ?? 0;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Disposes all subtype proposed limit controllers and clears
  /// the controller cache.
  void disposeProposedLimitControllers() {
    for (final TextEditingController c in _subtypeProposedControllers.values) {
      c.dispose();
    }
    _subtypeProposedControllers.clear();
  }

  /// Updates the limit type based on the selected label.
  ///
  /// Sets the facility as either a main limit or sub-limit and updates
  /// the controlling limit number accordingly.
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

  /// Updates the selected project finance related activity value.
  void onProjectFinanceChanged(Reference value) {
    getFacility.selectedProjectFinanceRelatedActivityValue = value;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Ensures project finance selection rules are applied.
  ///
  /// When project finance activity is disabled, the rule-based default
  /// value is enforced. For new facilities, a default value is assigned
  /// when no selection exists.
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

  /// Handles currency selection changes and updates related UI state.
  ///
  /// Controls:
  /// - Currency conversion field visibility
  /// - FX rate enablement
  /// - Currency-dependent amount synchronization
  void onCurrencyChanged(
    Reference? ref,
    CurrencyField? currencyField,
  ) {
    selectedCurrencyCode = (ref?.name ?? "").toUpperCase();
    final bool isAed = selectedCurrencyCode == ServerConstants.aedCurrency;

    // Map each enum to its visibility setter, then call it
    final Map<CurrencyField, void Function({bool value})> togglers =
        <CurrencyField, void Function({bool value})>{
      CurrencyField.presentLimit: ({bool? value}) =>
          showNewPresentLimitAmount = value ?? false,
      CurrencyField.presentOutstanding: ({bool? value}) =>
          showNewPresentOutStandingLimit = value ?? false,
      CurrencyField.proposedLimit: ({bool? value}) =>
          showNewProposedLimitAmount = value ?? false,
      CurrencyField.revisedBankLimitProposedByFi: ({bool? value}) =>
          showNewRevisedBankLimitProposedByFiAmount = value ?? false,
      CurrencyField.excessOverMaxLimitAllowanceProposedByFi: ({bool? value}) =>
          showNewExcessOverMaxLimitAllowanceProposedByFiAmount = value ?? false,
      CurrencyField.cbdEquityTier325Percent: ({bool? value}) =>
          showNewCbdEquityTier325PercentAmount = value ?? false,
      CurrencyField.counterpartyEquity5Percent: ({bool? value}) =>
          showNewCounterpartyEquity5PercentAmount = value ?? false,
      CurrencyField.counterpartyTotalAssets2Percent: ({bool? value}) =>
          showNewCounterpartyTotalAssets2PercentAmount = value ?? false,
      CurrencyField.revisedBankLimitRecommendedByCredit: ({bool? value}) =>
          showNewRevisedBankLimitRecommendedByCreditAmount = value ?? false,
      CurrencyField.excessOverMaxLimitAllowanceRecommendedByCredit: ({
        bool? value,
      }) =>
          showNewExcessOverMaxLimitAllowanceRecommendedByCreditAmount =
              value ?? false,
      CurrencyField.proposedBycc: ({bool? value}) =>
          showNewProposedByCCAmount = value ?? false,
    };

    // Apply the toggle for the current field (show when non-AED)
    togglers[currencyField]?.call(value: !isAed);

    // The rest remains the same
    disableFxRates = !isAed;
    syncExcessAmountCurrency();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Syncs Excess Amount currency and preserves any existing value.
  ///
  /// Why:
  /// - During update flow, dynamicFormDocument already contains excessAmount
  ///   (fromVal + aedEquivalent).
  /// - The previous implementation overwrote the map and set aedEquivalent=null,
  ///   causing value loss in update payload.
  ///
  /// Behavior:
  /// - Keeps existing fromVal/aedEquivalent when available.
  /// - Ensures aedEquivalent is not null for AED (defaults to fromVal).
  void syncExcessAmountCurrency() {
    final DynamicFormState? form = dynamicFormKey.currentState;
    if (form == null) {
      return;
    }

    final String proposedCurrency = getFacility.proposedLimitValue?.name ??
        selectedCurrencyCode ??
        ServerConstants.aedCurrency;

    // Prefer existing value from dynamicFormDocument, otherwise from form state.
    final dynamic existingFromDoc = dynamicFormDocument["excessAmount"];
    final dynamic existingFromForm = form.getFieldValue("excessAmount");

    Map<String, dynamic>? existing;
    if (existingFromDoc is Map) {
      existing = Map<String, dynamic>.from(existingFromDoc);
    } else if (existingFromForm is Map) {
      existing = Map<String, dynamic>.from(existingFromForm);
    }

    final dynamic fromVal = existing?["fromVal"];
    dynamic aedEquivalent = existing?["aedEquivalent"];

    // If AED and aedEquivalent missing but fromVal exists, keep it consistent.
    if (proposedCurrency.trim().toUpperCase() == ServerConstants.aedCurrency &&
        aedEquivalent == null &&
        fromVal != null) {
      aedEquivalent = fromVal;
    }

    form.updateFieldValue("excessAmount", {
      "fromCurrency": proposedCurrency,
      "fromVal": fromVal,
      "aedEquivalent": aedEquivalent,
    });

    // Keep document in sync so save uses the same values
    dynamicFormDocument["excessAmount"] = {
      "fromCurrency": proposedCurrency,
      "fromVal": fromVal,
      "aedEquivalent": aedEquivalent,
    };
  }

  /// Updates the selected borrower for the facility.
  ///
  /// Stores the selected borrower's RIM number in the facility model
  /// and refreshes the view state.
  void changeBorrower(Borrower? selected) {
    if (selected == null) {
      return;
    }

    getFacility.rimNo = selected.customerRimNo;
    selectedRim = selected.customerRimNo;

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
      } on Object catch (e) {
        AlertManager().showFailureToast(e.toString());
      }
    }
  }

  void _filterDynamicIndexOptionsByLimitCategory() {
    final String cat = (limitCategory ?? "").trim().toUpperCase();
    if (cat.isEmpty) {
      return;
    }

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

            if (!isIndexRefDropdown) {
              continue;
            }

            final original = df.optionList ?? const <Option>[];
            if (original.isEmpty) {
              continue;
            }

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
  Future<void> getFacilityConditionsList({
    bool isSubLimitTable = false,
    String? limitCode,
  }) async {
    try {
      conditionsStandard = await repository.getFacilityConditionsList(
        FacilityConditionsFilter(
          condition: "STANDARD_CONDITIONS",
          limitGroup: getLimitGroupName(getFacility.limitGroup).name?.trim(),
          limitDesc: getLimitCode(getFacility.limitCode).description?.trim(),
          limitCode: limitCode ??
              getLimitCode(getFacility.limitCode).reference3?.trim(),
          limitType: isSubLimitTable
              ? "Sub Limit"
              : (subLimit ?? false)
                  ? "Main Limit"
                  : "Sub Limit",
        ),
      );
      final List<Condition> mappedStandardConditions = conditionsStandard
          .map(
            (condition) => _mapFacilityCondition(
              condition,
              conditionType: ConditionType.standard,
              isSelected: true,
            ),
          )
          .toList();

      if (isSubLimitTable) {
        subLimitTableStandardCondition = mappedStandardConditions;
      } else {
        standardCondition = mappedStandardConditions;
      }

      conditionsNonStandard = await repository.getFacilityConditionsList(
        FacilityConditionsFilter(
          condition: "NON-STANDARD_CONDITIONS",
          limitGroup: getLimitGroupName(getFacility.limitGroup).name?.trim(),
          limitDesc: getLimitCode(getFacility.limitCode).description?.trim(),
          limitCode: limitCode ??
              getLimitCode(getFacility.limitCode).reference3?.trim(),
          limitType: isSubLimitTable
              ? "Sub Limit"
              : (subLimit ?? false)
                  ? "Main Limit"
                  : "Sub Limit",
        ),
      );
      final List<Condition> mappedNonStandardCondition = conditionsNonStandard
          .map(
            (condition) => _mapFacilityCondition(
              condition,
              conditionType: ConditionType.nonStandard,
              isSelected: false,
            ),
          )
          .toList();
      if (isSubLimitTable) {
        subLimitTableNonStandardCondition = mappedNonStandardCondition;
      } else {
        nonStandardCondition = mappedNonStandardCondition;
      }
      // Specific condition table for projectstandby and project specific group
      if (getFacility.limitGroup == ServerConstants.projectSpecificLimitsID ||
          getFacility.limitGroup == ServerConstants.projectStandByLimitID) {
        contractingConditionsStandard =
            await repository.getFacilityConditionsList(
          FacilityConditionsFilter(
            condition: "CONTRACTING-STANDARD_CONDITIONS",
            limitGroup: getLimitGroupName(getFacility.limitGroup).name?.trim(),
            limitDesc: getLimitCode(getFacility.limitCode).description?.trim(),
            limitCode: limitCode ??
                getLimitCode(getFacility.limitCode).reference3?.trim(),
            limitType: isSubLimitTable
                ? "Sub Limit"
                : (subLimit ?? false)
                    ? "Main Limit"
                    : "Sub Limit",
          ),
        );
        final List<Condition> mappedContractingStandardCondition =
            contractingConditionsStandard
                .map(
                  (condition) => _mapFacilityCondition(
                    condition,
                    conditionType: ConditionType.contractingStandard,
                    isSelected: true,
                  ),
                )
                .toList();

        if (isSubLimitTable) {
          subLimitTableContractingStandardCondition =
              mappedContractingStandardCondition;
        } else {
          contractingStandardCondition = mappedContractingStandardCondition;
        }
      }

      // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Returns the limit group reference for the specified identifier.
  ///
  /// Returns a fallback reference containing the provided identifier when
  /// no matching limit group is found.
  Reference getLimitGroupName(int? limitGroupId) {
    return limitGroups.firstWhere(
      (r) => (r.id) == limitGroupId,
      orElse: () => Reference(id: limitGroupId),
    );
  }

  /// Returns the limit cap type reference for the specified identifier.
  ///
  /// Returns a fallback reference containing the provided identifier when
  /// no matching limit cap type is found.
  Reference getLimitCapName(num? limitGroupId) {
    return limitCapsType.firstWhere(
      (r) => (r.id) == limitGroupId,
      orElse: () => Reference(id: int.tryParse(limitGroupId.toString())),
    );
  }

  /// Returns the facility description reference matching the provided name.
  ///
  /// Returns the "Others" facility type reference when no match is found.
  Reference getLimitDescriptionID(String? limitDescription) {
    return facilityDescriptions.firstWhere(
      (r) => (r.name) == limitDescription,
      orElse: () => Reference(
        id: ServerConstants.facilityTypeOthersID,
      ),
    );
  }

  /// Returns the facility description reference for the specified limit code.
  ///
  /// Returns a fallback reference containing the provided code when
  /// no matching facility description is found.
  Reference getLimitCode(int? limitCode) {
    return facilityDescriptions.firstWhere(
      (r) => (r.id) == limitCode,
      orElse: () => Reference(id: limitCode),
    );
  }

  Condition _mapFacilityCondition(
    FacilityCondition facilityCondition, {
    required ConditionType conditionType,
    required bool isSelected,
  }) {
    return Condition(
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
      conditionType: conditionType,
    );
  }

  /// Returns whether the specified non-standard condition can be modified.
  ///
  /// A condition can be modified only when the page is in edit mode and the
  /// condition has not yet been approved.
  bool isConditionNotApproved(int index) =>
      canEdit && (nonStandardCondition[index].facilityMasterId ?? 0) <= 0;

  bool isConditionAbleToAmendWaivedOff(int index) =>
      canEdit && (nonStandardCondition[index].facilityMasterId ?? 0) > 0;

  /// Retrieves the list of projects available for the specified limit group
  /// and borrower.
  ///
  /// The returned project names are converted into reference items for use
  /// in selection controls.
  Future<void> getProjectList(int? limitGroup, int? rimNo) async {
    try {
      final ProjectListResponse list = await repository.getProjectList(
        // limitGroup: ServerConstants.projectStandByLimitID, // NEW
        limitGroup: limitGroup,
        rimNo: rimNo,
      );
      projectNames =
          list.responseData.map((name) => Reference(name: name)).toList();
    } on Object catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  /// Retrieves available currency codes and initializes currency-related
  /// settings.
  ///
  /// Ensures AED is prioritized, updates currency selection state, and
  /// prepares currency options for the dynamic form.
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
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Loads facility subtypes associated with the selected facility
  /// description.
  ///
  /// The resulting subtype list is used to populate facility subtype
  /// selections and sub-limit configurations.
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
            limitCode: factyType.reference3,
          ),
        )
        .toList();
  }

  /// Retrieves and sorts the list of available countries.
  ///
  /// Countries are ordered alphabetically by description for display
  /// in country selection controls.
  Future<void> getCountries() async {
    try {
      countryList = (await CustomerRepository.instance.getCountries() ?? [])
        ..sort(
          (Country firstCountry, Country secondCountry) =>
              (firstCountry.description ?? "")
                  .compareTo(secondCountry.description ?? ""),
        );
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// limit caps ------------
  /// for single borrower credit application limit caps facility type
  Future<bool> saveSingleBorrowerLimitCaps({
    required bool navigateToHomePage,
  }) async {
    try {
      if (state.isSaveLoading || state.isSaveAndContinueLoading) {
        return false;
      }
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
      if (navigateToHomePage) {
        router.go(Routes.securitySummaryView);
      }
      isApiError = false;
      return true;
    } on Object catch (message) {
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
            ? (facilityDetail.first.presentOutstanding ?? 0)
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
      limitNo: showCreateFacilityForm ? null : (facilityDetail.first.limitNo),
      limitCategory: " ", // need to pass space string for limit caps
      presentOutstanding: presentOutstanding,
      presentOutstandingAED: presentOutstanding,
      currency: currency,
      isSharedLimit: _yesNoToBool(getFacility.sharedLimit, false),
      presentLimit: _numOr(
        getFacility.presentLimit,
        (facilityDetail.isNotEmpty
                ? facilityDetail.first.presentLimit
                : int.tryParse(
                      getFacility.presentLimitValue?.description ?? "",
                    ) ??
                    0) ??
            0,
      ),
      originalLimit: _numOr(
        getFacility.originalLimit,
        (facilityDetail.isNotEmpty
                ? facilityDetail.first.originalLimit
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
  Future<bool> saveGroupBorrowerLimitCaps({
    required bool navigateToHomePage,
  }) async {
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

      if (state.isSaveLoading || state.isSaveAndContinueLoading) {
        return false;
      }

      emit(
        state.copyWith(
          isButtonLoading: true,
          isSaveLoading: !navigateToHomePage,
          isSaveAndContinueLoading: navigateToHomePage,
        ),
      );

      final int? capFromVm = getFacility.proposedLimit;
      final int? capFromApi = (facilityDetail.isNotEmpty)
          ? facilityDetail.first.proposedLimit
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
      //getFacility.rimNo = getFacility.rimNo;
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
      if (navigateToHomePage) {
        router.go(Routes.securitySummaryView);
      }
      isApiError = false;
      return true;
    } on Object catch (message) {
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

  /// Builds the company borrower allocation payload for group borrower limit caps.
  ///
  /// Creates a [FacilityBorrowerMap] containing borrower allocation details,
  /// including original, present, and proposed allocation amounts. When
  /// available, sub-limit numbers are also included in the payload.
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

  /// Saves facility details (non-Limit-Caps flow) and optionally navigates away
  ///
  /// ### What this does
  /// 1. Blocks save if Sub-limit Proposed totals exceed header Proposed Limit.
  /// 2. Validates borrower allocation amounts against the Proposed Limit:
  ///    - If any borrower allocation exceeds the cap OR if we have any invalid
  ///      tracked allocations (`_invalidAllocationRims`), saving is blocked.
  /// 3. Runs Form + Dynamic Form validations.
  /// 4. Builds the payload and calls the save API.
  ///
  /// 5. Switches the screen into "existing facility/update" mode after save,
  ///    and optionally reloads fresh details when staying on the page.
  /// Parameter:
  /// - [navigateToHomePage] When true, navigates to summary view after saving.
  ///   When false, remains on the page and refreshes facility details.
  ///
  /// Returns:
  /// - `true` when save succeeds.
  /// - `false` when validation fails or an exception occurs
  Future<bool> saveContinueOnPressed({required bool navigateToHomePage}) async {
    try {
      if (hasInvalidSubTypeProposedLimit()) {
        AlertManager().showFailureToast(
          "facilities.createFacility.subLimitExceed".tr(),
        );
        return false;
      }

      final int proposedLimitCap = effectiveProposedLimit;

      final bool anyExceedsSingle = borrowersByRimInTable.any((b) {
        final int enteredAllocation =
            int.tryParse((b.description ?? "").replaceAll(",", "")) ?? 0;
        return enteredAllocation > proposedLimitCap;
      });

      if (_invalidAllocationRims.isNotEmpty || anyExceedsSingle) {
        AlertManager().showFailureToast(
          "facilities.createFacility.allocationAmountErrorText".tr(),
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

      if (state.isSaveLoading || state.isSaveAndContinueLoading) {
        return false;
      }
      emit(
        state.copyWith(
          isButtonLoading: true,
          isSaveLoading: !navigateToHomePage,
          isSaveAndContinueLoading: navigateToHomePage,
        ),
      );

      final bool isValid = formKey.currentState?.validate() ?? false;
      final bool isDynamicFormValid = isFIFlow ||
          sections.isEmpty ||
          (dynamicFormKey.currentState?.validate() ?? false);

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
      //getFacility.rimNo = getFacility.rimNo;

      getFacility.additionalDetails =
          isFIFlow ? null : dynamicFormDocument.toString();

      // Only send borrower map when Shared Limit == YES
      final bool isShared = _yesNoToBool(
        getFacility.sharedLimit,
        facilityDetail.isNotEmpty &&
            (facilityDetail.first.isSharedLimit ?? false),
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
        condition: [
          ...standardCondition,
          ...nonStandardCondition,
          ...contractingStandardCondition,
        ],
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
        facilitySubTypes.clear();
        conditionsStandard.clear();
        standardCondition.clear();
        nonStandardCondition.clear();
        final int rim = selectedRim ?? getFacility.rimNo ?? rimNo ?? 0;
        if (rim != 0) {
          await getFacilityDetails(
            existingFacilityId,
            rim,
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
      if (navigateToHomePage) {
        router.go(Routes.securitySummaryView);
        facilitySubTypes.clear();
        conditionsStandard.clear();
        standardCondition.clear();
        nonStandardCondition.clear();
      }
      isApiError = false;
      return true;
    } on Object catch (message) {
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

    double? safeParseAED(String newVal, String oldVal) {
      final String newClean = newVal.replaceAll(",", "").trim();
      final String oldClean = oldVal.replaceAll(",", "").trim();

      return double.tryParse(newClean.isNotEmpty ? newClean : oldClean) ??
          double.tryParse(oldClean);
    }

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
      proposedByccAED: switch (safeParseAED(
        newProposedByccController.text,
        proposedByccController.text,
      )) {
        null || 0 => getFacility.proposedByCc,
        final value => value,
      },
      cbdEquityTier325Percent: getFacility.cbdEquityTier325Percent,
      cbdEquityTier325PercentAED: safeParseAED(
        newCbdEquityTier325PercentController.text,
        cbdEquityTier325PercentController.text,
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
              ? (parentControlliingNumber?.isNotEmpty ?? false
                  ? parentControlliingNumber
                  : null)
              : null),
      facilityId: showCreateFacilityForm
          ? null
          : num.tryParse(getFacility.facilityId?.toString() ?? ""),
      limitNo: showCreateFacilityForm ? null : (facilityDetail.first.limitNo),
      limitCategory: limitCategory?.trim().toUpperCase() ??
          (facilityDetail.first.limitCategory),
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
      presentOutstandingAED: getFacility
          .presentOutstandingAmount, // since it's readonly we can pass directly
      //  safeParseAED(newPresentOutStandingController.text, "") ?? 0,
      proposedLimit:
          _numOr(getFacility.proposedLimit, parentProposedLimit ?? 0),
      proposedLimitAED: proposedLimitAED,
      presentLimitAED: safeParseAED(
        newPresentLimitController.text,
        presentLimitController.text,
      ),
      presentLimit: _numOr(
        getFacility.presentLimit,
        (facilityDetail.isNotEmpty
                ? facilityDetail.first.presentLimit
                : int.tryParse(
                      getFacility.presentLimitValue?.description ?? "",
                    ) ??
                    0) ??
            0,
      ),
      originalLimit: _numOr(
        getFacility.originalLimit,
        (facilityDetail.isNotEmpty
                ? facilityDetail.first.originalLimit
                : int.tryParse(getFacility.limitAmount?.description ?? "") ??
                    0) ??
            0,
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
      marginSign: getFacility.marginSign?[0].toUpperCase(),
      marginValue: getFacility.marginValue,
      counterpartyEquity5PercentAED: safeParseAED(
        newCounterpartyEquity5PercentController.text,
        getFacility.counterpartyEquity5Percent.toString(),
      ),
      excessOverMaxLimitAllowanceAED: safeParseAED(
        newExcessOverMaxLimitAllowanceProposedByFiController.text,
        excessOverMaxLimitAllowanceProposedByFiController.text,
      ),
      counterpartyTotalAssets2PercentAED: safeParseAED(
        newCounterpartyTotalAssets2PercentController.text,
        getFacility.counterpartyTotalAssets2Percent.toString(),
      ),
      excessOverMaxLimitAllowanceByCcAED: safeParseAED(
        newExcessOverMaxLimitAllowanceRecommendedByCreditController.text,
        excessOverMaxLimitAllowanceRecommendedByCreditController.text,
      ),
      facilityMasterId: facilityMasterId,
    );
  }

  String? _projectCodeFromName(String? raw) {
    final String s = (raw ?? "").trim();
    if (s.isEmpty) {
      return null;
    }

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
    if (name == "yes") {
      return true;
    }
    if (name == "no") {
      return false;
    }
    return fallback;
  }

  /// Updates the committed status of the facility.
  ///
  /// Sets the selected committed value and updates the corresponding
  /// boolean flag in the facility model.
  void changeCommitted(Reference? selectedValue) {
    getFacility.committedValues = selectedValue;
    try {
      getFacility.isCommitted = _yesNoToBool(selectedValue, false);
    } on Object catch (_) {}
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Cancels the current operation and navigates back to the
  /// facility summary view.
  void cancelOnPressed() {
    router.go(Routes.facilitySummaryView);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Returns the benchmark reference associated with the provided value.
  ///
  /// Supports benchmark values represented as either a selected option
  /// list or a benchmark identifier. Returns `null` when the input
  /// cannot be resolved to a benchmark reference.
  Reference? getIndexBenchMark(Object? value) {
    if (value is! Map<String, dynamic>) {
      return null;
    }

    Reference index;
    if (value["value"] is List) {
      final Option option = value["value"].first;
      index = benchmark.firstWhere(
        (element) =>
            element.name?.replaceAll(" ", "").toLowerCase() ==
            option.value?.toString().replaceAll(" ", "").toLowerCase(),
        orElse: () {
          logger.i("${value}benchMark_unavailable");
          return Reference(
              // id: 15748, // this is ID of fixedCommision. failing on it's case due to spelling mismatch. informed Jessy for update on June-15-2026. once it up we can remove this hardcode value
              );
        },
      );
      logger.i(index.name);
    } else {
      index = benchmark.firstWhere(
        (element) =>
            element.id ==
            (value["value"] is int
                ? value["value"] as int
                : int.tryParse(value["value"]?.toString() ?? "")),
      );
    }

    logger.i(index.name);
    return index;
  }

  /// Updates the selected regulatory specialised lending value.
  ///
  /// Clears the regulatory specification when the selected value is "No"
  /// and synchronizes the value with the facility details model.
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

  /// Updates the selected promissory note value.
  ///
  /// Synchronizes the selection with the facility details model.
  void changePromissoryNote(Reference? selecctedValue) {
    getFacility.selectedpromissoryNoteValue = selecctedValue;
    if (facilityDetail.isNotEmpty) {
      facilityDetail.first.promissoryNoteTaken =
          selecctedValue?.id == ServerConstants.optionYESid;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selected project finance related activity.
  void changeProjectFinanceRelatedActivity(Reference? selecctedValue) {
    getFacility.selectedProjectFinanceRelatedActivityValue = selecctedValue;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the collateral dependant selection.
  ///
  /// Controls the visibility and mandatory state of the
  /// "Extent of Finance" and "Customer Contribution" fields
  /// based on the selected value.
  void changeCollateralDependant(Reference? selecctedValue) {
    getFacility.selectedCollateralDepantantValue = selecctedValue;
    if (facilityDetail.isNotEmpty) {
      facilityDetail.first.isCollateralDependent = selecctedValue;
    }
    final bool selectedYes = _yesNoToBool(selecctedValue, false);

    // Make both fields visible + mandatory when 'Yes'
    dynamicFormKey.currentState
        ?.setFieldVisibility("extentOfFinance", isVisible: selectedYes);
    dynamicFormKey.currentState
        ?.setFieldVisibility("customerContribution", isVisible: selectedYes);
    dynamicFormKey.currentState
        ?.setFieldMandatory("extentOfFinance", isMandatory: selectedYes);
    dynamicFormKey.currentState
        ?.setFieldMandatory("customerContribution", isMandatory: selectedYes);

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selected product type value.
  void changProductType(Reference? selecctedValue) {
    getFacility.selectedProductTypeValue = selecctedValue;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the facility conditions standard flag.
  void changeConditionsStandard({required bool value}) {
    getFacility.isConditionsStandard = value;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the cross-border exposure flag.
  void changeCrossBoarderExposure({required bool value}) {
    getFacility.isCrossBoarderExposure = value;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selected limit group.
  ///
  /// Loads the associated facility descriptions based on the
  /// selected limit group and refreshes the view state.
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

  /// Updates the shared limit selection.
  ///
  /// When shared limit is enabled, borrower allocation amounts are
  /// validated against the group limit. When disabled, group cap
  /// allocations and related validation data are cleared.
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

  /// Validates and stores the borrower allocation amount for group borrower
  /// limit caps.
  ///
  /// When group-level cap allocation is required, the entered allocation
  /// amount must not exceed the proposed group cap value. Validation errors
  /// are stored at the row level for display in the UI.
  void setGroupCapsAllocation(int? rimNo, String? value) {
    if (rimNo == null) {
      return;
    }

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

  /// Updates the selected property type.
  ///
  /// Clears the current property subtype and emirate selections when they are
  /// no longer valid for the selected property type.
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

  /// Updates the selected project name.
  void onProjectNameSelected(List<Reference> selected) {
    if (selected.isNotEmpty) {
      getFacility.projectName = selected.first;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Updates the selected property subtype.
  ///
  /// Resets the emirate selection whenever the property subtype changes.
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

  /// Updates the selected policy deviation values.
  ///
  /// Also updates the policy deviation indicator used by the UI.
  void onPolicyDeviationSelected(List<Reference> selectedValue) {
    getFacility.policyDeviation = selectedValue;

    emit(
      state.copyWith(
        isPolicyDeviation: selectedValue.isNotEmpty,
        loaderStatus: LoadingStatus.loaded,
      ),
    );
  }

  /// Removes a selected policy deviation by index.
  ///
  /// Updates the policy deviation indicator after removal.
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

  /// Updates the selected facility purpose.
  ///
  /// Resets property-related selections when the selected purpose does not
  /// require property information.
  void selectPurpose(Reference selectedValue) {
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

  /// Updates the selected limit type.
  void selectLimitType(Reference selectedValue) {
    getFacility.limitTypeValue = selectedValue;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Adds a new fee default rate entry.
  void addFeeAndDefualtRate() {
    feeDefualtRate.add(FeeRate());
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Adds a new non-standard condition to the sub-limit condition list.
  void addNonStandardToSubLimitList() {
    subLimitTableNonStandardCondition.add(
      Condition(
        conditionType: ConditionType.nonStandard,
        facilityType:
            selectedProductType?.name ?? ServerConstants.allFacilityProductType,
        isAmended: false,
        isWaivedOff: false,
        isSelected: true,
        rimNo: getFacility.rimNo,
        limitType: (subLimit ?? false)
            ? ServerConstants.facilityMainLimit
            : ServerConstants.facilitySubLimit,
        isShowAsTextField: true,
      ),
    );

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Adds a new non-standard condition.
  ///
  /// Updates pagination to display the newly added condition on the
  /// appropriate table page.
  void addNonStandardCondition() {
    nonStandardCondition.add(
      Condition(
        conditionType: ConditionType.nonStandard,
        facilityType:
            selectedProductType?.name ?? ServerConstants.allFacilityProductType,
        isAmended: false,
        isWaivedOff: false,
        isSelected: true,
        rimNo: getFacility.rimNo,
        limitType: (subLimit ?? false)
            ? ServerConstants.facilityMainLimit
            : ServerConstants.facilitySubLimit,
        isShowAsTextField: true,
      ),
    );

    // Pagination logic after add new item
    const int rowsPerPage = 5;
    final int totalItems = nonStandardCondition.length;

    if (totalItems > rowsPerPage) {
      // Calculate last page index (0-based)
      initialPageNonStandardConditions =
          ((totalItems - 1) / rowsPerPage).floor();
    } else {
      initialPageNonStandardConditions = 0;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Removes a non-standard condition.
  ///
  /// If a facility condition identifier is provided, the corresponding
  /// condition is also removed from the backend.
  Future<void> removeNonStandardCondition(
    int index, {
    @required int? facilityConditionID,
  }) async {
    nonStandardCondition.removeAt(index);
    await repository.deleteFacilityCondition(facilityConditionID);

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selection state of a standard condition.
  ///
  /// Selecting a condition clears any amend or waive-off flags.
  void changeStandardConditionSelect(
    int index, {
    required bool value,
  }) {
    standardCondition[index].isSelected = value;

    if (value) {
      standardCondition[index].isAmended = false;
      standardCondition[index].isWaivedOff = false;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selection state of a contracting standard condition.
  ///
  /// Selecting a condition clears any amend or waive-off flags.
  void changeContractingStandardConditionSelect(
    int index, {
    required bool value,
  }) {
    contractingStandardCondition[index].isSelected = value;

    if (value) {
      contractingStandardCondition[index].isAmended = false;
      contractingStandardCondition[index].isWaivedOff = false;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the amend status of a standard condition.
  ///
  /// Selecting amend clears the selected and waive-off states.
  void changeAmendStandardConditionSelect(
    int index, {
    required bool value,
  }) {
    standardCondition[index].isAmended = value;

    if (value) {
      standardCondition[index].isWaivedOff = false;
      standardCondition[index].isSelected = false;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the amend status of a contracting standard condition.
  ///
  /// Selecting amend clears the selected and waive-off states.
  void changeAmendContractingStandardConditionSelect(
    int index, {
    required bool value,
  }) {
    contractingStandardCondition[index].isAmended = value;

    if (value) {
      contractingStandardCondition[index].isWaivedOff = false;
      contractingStandardCondition[index].isSelected = false;
    }
    emit(state.copyWith());
    // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the waive-off status of a standard condition.
  ///
  /// Selecting waive-off clears the selected and amend states.
  void changeWaivedOffStandardConditionSelect(
    int index, {
    required bool value,
  }) {
    standardCondition[index].isWaivedOff = value;

    if (value) {
      standardCondition[index].isAmended = false;
      standardCondition[index].isSelected = false;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the waive-off status of a contracting standard condition.
  ///
  /// Selecting waive-off clears the selected and amend states.
  void selectWaivedOffContractingStandardCondition(
    int index, {
    required bool value,
  }) {
    contractingStandardCondition[index].isWaivedOff = value;

    if (value) {
      contractingStandardCondition[index].isAmended = false;
      contractingStandardCondition[index].isSelected = false;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the amend status of a non-standard condition.
  ///
  /// Selecting amend clears the selected and waive-off states and hides
  /// the editable text field.
  void changeAmendNonStandardConditionSelect(
    int index, {
    required bool value,
  }) {
    nonStandardCondition[index].isAmended = value;

    if (value) {
      nonStandardCondition[index].isWaivedOff = false;
      nonStandardCondition[index].isSelected = false;
      nonStandardCondition[index].isShowAsTextField = false;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the waive-off status of a non-standard condition.
  ///
  /// Selecting waive-off clears the selected and amend states.
  void changeWaivedOffNonStandardConditionSelect(
    int index, {
    required bool value,
  }) {
    nonStandardCondition[index].isWaivedOff = value;

    if (value) {
      nonStandardCondition[index].isAmended = false;
      nonStandardCondition[index].isSelected = false;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selection state of a non-standard condition.
  ///
  /// Selecting a condition clears any amend or waive-off flags.
  void changeNonStandardConditionSelect(
    int index, {
    required bool value,
  }) {
    nonStandardCondition[index].isSelected = value;
    if (value) {
      nonStandardCondition[index].isAmended = false;
      nonStandardCondition[index].isWaivedOff = false;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Removes a borrower from the allocation table.
  void onBorrowerChipDeleted(int index) {
    borrowersByRimInTable.removeAt(index);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the `borrowersByRimInTable` list based on the latest multi-select
  /// dropdown selection.
  /// This method:
  /// 1. Builds a lookup of existing borrower rows by RIM key.
  /// 2. Rebuilds the table list from the new selection while preserving
  ///     existing allocation values where possible.
  /// 3. Removes invalid allocation markers for borrowers that are no longer
  ///    selected.
  /// 4. Emits state changes to refresh the UI.
  ///
  /// Parameter:
  /// - [selectedBorrowersByRims]: The current set of borrower References
  ///  selected in the multi-select dropdown
  void addBorrowertoTable(List<Reference> selectedBorrowersByRims) {
    // index existing rows by rim key to preserve allocation amounts
    // final Map<int, Reference> existingByRim = {};

    final Map<int, Reference> existingBorrowerByRimKey = <int, Reference>{};

    for (final Reference existingBorrowerRow in borrowersByRimInTable) {
      final int? rimKey = _rimKeyOf(existingBorrowerRow);
      if (rimKey != null) {
        existingBorrowerByRimKey[rimKey] = existingBorrowerRow;
      }
    }

    // rebuild list but preserve allocation(description) + reference1 if already
    borrowersByRimInTable = selectedBorrowersByRims.map((selectedRef) {
      final int? selectedRimKey = _rimKeyOf(selectedRef);
      final Reference? existingRow = (selectedRimKey != null)
          ? existingBorrowerByRimKey[selectedRimKey]
          : null;

      return Reference(
        id: selectedRef.id,
        name: selectedRef.name,
        description: existingRow?.description ?? selectedRef.description,
        reference1: existingRow?.reference1 ?? selectedRef.reference1,
      );
    }).toList();

    // Keep invalid markers only for active selected RIMs
    final Set<int> selectedRimKeys =
        borrowersByRimInTable.map(_rimKeyOf).whereType<int>().toSet();
    _invalidAllocationRims.removeWhere((rim) => !selectedRimKeys.contains(rim));

    // force UI rebuild (you already do this)
    emit(state.copyWith(navigateToCreateFacility: LoadingStatus.empty));
    emit(state.copyWith(navigateToCreateFacility: LoadingStatus.loaded));
  }

  /// Updates the proposed limit value.
  void addProposedLimit(String? proposedLimit) {
    getFacility.proposedLimit = int.tryParse(proposedLimit ?? "0");
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selected country of risk.
  ///
  /// When the selected country is the UAE, cross-border exposure is
  /// automatically disabled.
  void onCountryOfRiskSelected(Country picked) {
    getFacility.selectedCountry = picked;
    getFacility.countryOfRisk = picked.description;

    // If UAE, uncheck and emit
    if (isUAECountryOfRisk) {
      changeCrossBoarderExposure(value: false);
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Ensures a default country of risk is selected.
  ///
  /// If no country has been provided, the country of risk defaults to
  /// the United Arab Emirates and cross-border exposure is disabled.
  void ensureDefaultCountryOfRiskIfEmpty() {
    final bool hasApi = getFacility.countryOfRisk != null &&
        getFacility.countryOfRisk!.trim().isNotEmpty;
    final bool hasSelected =
        getFacility.selectedCountry?.description?.trim().isNotEmpty ?? false;

    // If something is already set, just enforce the UAE rule and exit
    if (hasApi || hasSelected) {
      if (isUAECountryOfRisk) {
        changeCrossBoarderExposure(value: false);
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
    changeCrossBoarderExposure(value: false);
    // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selected sector.
  ///
  /// Clears the SIC code when the selected sector changes.
  void selectSector(Reference? selectedValue) {
    final int? prevSectorId = getFacility.sector?.id;
    final int? newSectorId = selectedValue?.id;
    getFacility.sector = selectedValue;
    if (prevSectorId != newSectorId) {
      getFacility.sicCode = null;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Removes fee details and refreshes the view state.
  void deleteFeeDetails({int? feeID}) {
    try {
      AlertManager().showSuccessToast("Selected Fee Deleted");
    } on Object catch (e) {
      logger.i(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selection state of a facility subtype.
  void changeSubtypes(
    FacilitySubTypes facilitySubType, {
    required bool subTypeSelected,
    required bool alreadyExistingSubType,
  }) {
    facilitySubType
      ..subTypeSelected = subTypeSelected
      ..alreadyExistingSubType = alreadyExistingSubType;
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
      final String limitNo = facilityDetail.first.limitCategory.trim();
      if (limitNo.isNotEmpty) {
        getFacility.limitNumber = limitNo;
      }

      // --- Sustainability Classification hydration (Existing facility) ---
      if (sustanabilityClassifications.isNotEmpty) {
        final String raw =
            facilityDetail.first.sustainabilityClassification.trim();

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

      final String limitCategory = facilityDetail.first.limitCategory.trim();
      if (limitCategory.isNotEmpty) {
        getFacility.limitCategory = limitCategory;
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
          getFacility.presentOutstandingAmount = 0;
          presentOutStandingReadOnly =
              true; // if "NEW ACCOUNT", make Present Outstanding read-only (since it should be 0 or N/A)
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
          formatter.format(proposedLimitApiValue ?? 0);

      getFacility.proposedByCc =
          (facilityDetail.first.proposedByCc ?? 0).toDouble();
      getFacility.proposedByCcCurrency =
          facilityDetail.first.proposedByCcCurrency;

      proposedByccController.text =
          (facilityDetail.first.proposedByCc ?? "").toString();
    }

    if (facilityDetail.isNotEmpty) {
      const String curr =
          ServerConstants.aedCurrency; // facilityDetail.first.currency;
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
        (e) => e.id?.toString() == facilityDetail.first.sectorDescription,
        orElse: () => Reference(name: ""),
      );
      getFacility.sector = advMatch;
    }

    if (facilityDetail.isNotEmpty && accountTypes.isNotEmpty) {
      final Reference advMatch = accountTypes.firstWhere(
        (e) => e.id?.toString() == facilityDetail.first.accountType,
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
            (r) =>
                (r.name ?? "").trim().toLowerCase() ==
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
      final int presentOutstandingAmnt = (detail.presentOutstanding ?? 0) == 0
          ? (detail.presentOutstandingAED?.toInt() ?? 0)
          : (detail.presentOutstanding ?? 0);

      getFacility.presentOutstandingAmount = presentOutstandingAmnt;
      presentOutstandingController.text = (presentOutstandingAmnt > 0 &&
              getFacility.commitmentAccountNumber?.name != _newAccLabel)
          ? formatter.format(presentOutstandingAmnt)
          : "0";

      // Currency for Present Outstanding (API)
      final String poCode =
          (detail.presentOutstandingCurrency ?? ServerConstants.aedCurrency)
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
    }

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
    if (rimValue.isEmpty || fieldToUpdate.isEmpty) {
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
    } on Object catch (e) {
      AlertManager().showFailureToast("Error fetching customer details: $e");
    }
  }

  /// Handles dynamic form field change events.
  ///
  /// Updates dynamic form visibility, mandatory state, field values,
  /// and facility-related data based on the modified field.
  ///
  /// This method contains field-specific business rules for:
  /// - Dynamic field visibility
  /// - Validation and mandatory field configuration
  /// - Currency and commission handling
  /// - Tenor and repayment settings
  /// - Customer search and lookup operations
  /// - Margin and benchmark configuration
  /// - Project, shipment, and promissory note options
  Future<void> onDynamicFormFieldChange(
    String fieldKey,
    Object? value,
  ) async {
    final DynamicFormState? form = dynamicFormKey.currentState;

    switch (fieldKey) {
      case "gridCommission":
        {
          if (value is Map) {
            getFacility.marginValue = value["value"]?.toString();
          }
        }

      case "transactionCommission":
        if (value is Map) {
          getFacility.marginValue = value["fromVal"]?.toString();
        }
      case "repaymentTypeTawarrukPPC" || "repaymentTypeTawarrukInvoice":
        if (value is! Option) {
          break;
        }
        if (value.key == "instalments") {
          form?.setFieldVisibility("instalments", isVisible: true);
          form?.setFieldVisibility("bullet", isVisible: false);
        } else if (value.key == "bullet") {
          form?.setFieldVisibility("instalments", isVisible: false);
          form?.setFieldVisibility("bullet", isVisible: true);
        }
      case "shipmentBySeaOrAir":
        // If shipmentBySeaOrAir is true, show shipmentBySea/AirAmount field
        // If false, hide it
        final bool isChecked = value == true;
        form?.setFieldVisibility(
          "shipmentBySea/AirAmount",
          isVisible: isChecked,
        );
      case "shipmentByTruck":
        // If shipmentByTruck is true, show shipmentByTruckAmount field
        // If false, hide it
        final bool isChecked = value == true;
        form?.setFieldVisibility("shipmentByTruckAmount", isVisible: isChecked);
      case "charterBillLading":
        // If charterBillLading is true, show charteredBillLadingAmount field
        // If false, hide it
        final bool isChecked = value == true;
        form?.setFieldVisibility(
          "charteredBillLadingAmount",
          isVisible: isChecked,
        );

      // Third Port Shipment → thirdPortShipmentAmount
      case "thirdPortShipment":
        form?.setFieldVisibility(
          "thirdPortShipmentAmount",
          isVisible: value == true,
        );

      // Overseas Shipment → overseasShipmentAmount
      case "overseasShipment":
        form?.setFieldVisibility(
          "overseasShipmentAmount",
          isVisible: value == true,
        );

      // Local Delivery → localDeliveryAmount
      case "localDelivery":
        form?.setFieldVisibility(
          "localDeliveryAmount",
          isVisible: value == true,
        );

      // Finance under LC → financeUnderLCAmount
      case "financeUnderLC":
        form?.setFieldVisibility(
          "financeUnderLCAmount",
          isVisible: value == true,
        );

      // Finance against collection → financeAgainstCollectionAmount
      case "financeAgainstCollection":
        form?.setFieldVisibility(
          "financeAgainstCollectionAmount",
          isVisible: value == true,
        );

      // Master Promissory Note held →
      //   Use ONE of these depending on your UI:
      //   A) show amount field
      case "masterPromissoryNoteHeld":
        form?.setFieldVisibility(
          "masterPromissoryNoteHeldAmount",
          isVisible: value == true,
        );
        //   B) or show a number/ID input instead:
        form?.setFieldVisibility(
          "masterPromissoryNoteNumber",
          isVisible: value == true,
        );

      case "NoOfYearsTenor":
      case "depositTenor":
      case "maximumTenor":
      case "maximumTenorSuppliersCreditPeriod":
      case "tenor":
      case "tenorForwardPeriod":
      case "tenorOfEachPPC":
      case "tenorUsance":
      case "tenorofeachInvoice":
      case "tenorofeachPPCtaharuq":
      case "totalTenor":
      case "usanceTenor":
        if (value is! Map<String, dynamic>) {
          break;
        }
        // "value" is the payload from the combo component: { <unit>:
        // <typedNumber> }
        // Fall back to explicit map keys if the widget sends {tenorUnit,
        // tenorValue}
        final String selUnit = (value.containsKey("tenorUnit"))
            ? (value["tenorUnit"]?.toString() ?? "")
            : (value.keys.first);
        final String selVal = (value.containsKey("tenorValue"))
            ? (value["tenorValue"]?.toString() ?? "")
            : (value.values.first?.toString() ?? "");
        getFacility.tenorUnit = Reference(name: selUnit);
        getFacility.tenorValue = int.tryParse(selVal);
        // Always send the user's numeric input for On Demand as well.
        // (No special string override.)
        form?.updateFieldValue(fieldKey, {
          "tenorUnit": selUnit,
          "tenorValue": selVal, // <-- numeric string from the textbox
        });

      case ("lcMargin" || "avMargin" || "guaranteeMargin"):
        // When any value is selected in Guarantee Margin:
        // - Make Margin Extent field mandatory
        // When Time Deposits is selected:
        // - Make Linked Account Number field mandatory
        if (value is! Option) {
          break;
        }
        // final bool hasValue = value != null &&
        //     (value is String ? value.isNotEmpty : value.key != null);
        final bool hasValue = value.key != null;
        final bool isTimeDeposits = value.key == "timeDeposits";

        // Margin Extent becomes mandatory when any Guarantee Margin value is
        // selected
        form?.setFieldMandatory("marginExtent", isMandatory: hasValue);
        getFacility.marginValue = value.toString();
        // Linked Account Number becomes mandatory only for Time Deposits
        form?.setFieldMandatory(
          "linkedAccountNumber",
          isMandatory: isTimeDeposits,
        );
      case "currency":
        // If "Others" is selected in Permitted Currency multiSelect, show
        // otherCurrency field
        // Otherwise, hide it
        bool hasOthers = false;
        if (value is List) {
          hasOthers = value.contains("Others");
        }
        form?.setFieldVisibility("otherCurrency", isVisible: hasOthers);
      case "payofcurrency":
        // If "Others" is selected in Payoff Currency multiSelect, show
        // specifyofpayofcurrency field
        // Otherwise, hide it
        bool hasOthers = false;
        if (value is List) {
          hasOthers = value.contains("Others");
        }
        form?.setFieldVisibility(
          "specifyofpayofcurrency",
          isVisible: hasOthers,
        );
      case "searchByName":
        if (value is! Map<String, dynamic>) {
          break;
        }
        // Extract grid name to use grid-qualified keys
        final String? gridName = value["gridName"];
        final int rowIndex = value["index"];
        final bool isChecked = value["value"] ?? false;

        if (gridName != null) {
          // Use grid-qualified field keys to ensure changes only affect
          // the specific grid where the checkbox was toggled
          final String rimKey = "$gridName.customerRimGrid";
          final String nameKey = "$gridName.customerName";

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
          break;
        }
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
        form?.setFieldVisibility(
          "preShipmentAmount",
          isVisible: value == true,
        );

      case "postShipment":
        form?.setFieldVisibility(
          "postShipmentAmount",
          isVisible: value == true,
        );
      case ("index" || "indexLcLGCommision"):
        final bool isClearingSelection = value == null ||
            (value is Map &&
                value["value"] is List &&
                (value["value"] as List).isEmpty);
        if (isClearingSelection) {
          getFacility.index = null;
        } else {
          getFacility.index = getIndexBenchMark(value)?.id.toString();
        }
      case "margin":
        if (value is! Map<String, dynamic>) {
          break;
        }
        if (value["value"] is! Map<String, dynamic>) {
          break;
        }
        getFacility.marginValue = value["value"]["tenorValue"];
        getFacility.marginSign = value["value"]["tenorUnit"];
      case "recourse":
        if (value is! Option) {
          break;
        }
        if (value.key == "withoutRecourse") {
          form?.setFieldVisibility(
            "creditInsuranceCompanyName",
            isVisible: true,
          );
          form?.setFieldVisibility(
            "creditInsurancePolicyDetails",
            isVisible: true,
          );
          form?.updateFieldValue("creditInsurancePolicyDetails", "NA");
        } else {
          form?.setFieldVisibility(
            "creditInsuranceCompanyName",
            isVisible: false,
          );
          form?.setFieldVisibility(
            "creditInsurancePolicyDetails",
            isVisible: false,
          );
        }

      case "rePaymentType":
        if (value is! Option) {
          break;
        }
        if (value.key == "installmentLoan") {
          form?.setFieldVisibility("equated", isVisible: false);
          form?.setFieldVisibility("InstallmentloanOptions", isVisible: true);
          form?.setFieldVisibility(
            "NoOfYearsTenor",
            isVisible: true,
          );
          form?.setFieldVisibility("NoOfInstallmentsPerYear", isVisible: true);
        } else if (value.key == "equatedLoan") {
          form?.setFieldVisibility("equated", isVisible: true);
          form?.setFieldVisibility("InstallmentloanOptions", isVisible: false);

          form?.setFieldVisibility("NoOfYearsTenor", isVisible: false);
          form?.setFieldVisibility("NoOfInstallmentsPerYear", isVisible: false);
          form?.setFieldVisibility("interestGrid", isVisible: false);
          form?.setFieldVisibility("principal", isVisible: false);
        }

      case "InstallmentloanOptions":
        final String? installmentloanOption =
            value?.toString().trim().toLowerCase();
        final bool isStraightLine = (installmentloanOption == "straight line");

        if (isStraightLine) {
          form?.setFieldVisibility("NoOfYearsTenor", isVisible: true);
          form?.setFieldVisibility("NoOfInstallmentsPerYear", isVisible: true);
          form?.setFieldVisibility("interestGrid", isVisible: false);
          form?.setFieldVisibility("principal", isVisible: false);
        } else {
          form?.setFieldVisibility("interestGrid", isVisible: true);
          form?.setFieldVisibility("principal", isVisible: true);
          form?.setFieldVisibility("NoOfYearsTenor", isVisible: false);
          form?.setFieldVisibility("NoOfInstallmentsPerYear", isVisible: false);
        }

      case "acceptableInvoiceCurrencies":
        // If "Other" is selected in Acceptable Invoice Currencies multiSelect,
        // show specifyOthercurrency field
        // Otherwise, hide it
        bool hasOther = false;
        if (value is List) {
          hasOther = value.contains("Other");
        }
        form?.setFieldVisibility("specifyOthercurrency", isVisible: hasOther);

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
      if (!(sub.subTypeSelected ?? false)) {
        continue;
      }

      final bool isOverriddenRow =
          overrideRowIndex != null && overrideRowIndex == rowIndex;

      final int localAmount = isOverriddenRow
          ? (overrideLocalValue ?? (sub.proposedLimit ?? 0))
          : (sub.proposedLimit ?? 0);

      if (localAmount <= 0) {
        continue;
      }

      final num rate = _safeRateForSubType(rowIndex);
      totalAED += (localAmount * rate).toInt();
    }

    return totalAED;
  }

  /* ----------------------SUB LIMIT TABLE(FacilitySubTypeTable class) ---------------------------------- */

  /// Header Proposed Limit cap expressed in AED.
  /// Why this exists:
  /// - Sub-limit rows can be entered in different currencies.
  /// - Validation is performed using AED-equivalent values to ensure a consistent
  ///   comparison between a sub-limit row and the header Proposed Limit.
  /// How the cap is resolved:
  /// - If header currency is non-AED, we prefer the already-converted AED value
  ///   from `newProposedLimitController` (UI conversion).
  /// - If UI AED value is empty, fall back to the API AED field (`proposedLimitAED`).
  /// - If header currency is AED, use `effectiveProposedLimit` as-is.
  /// Returns:
  /// - Header Proposed Limit cap in AED (0 if not available).
  int get headerProposedLimitCapAED {
    // If header currency is non-AED, prefer the converted AED controller value.
    final String headerCode = (getFacility.proposedLimitValue?.name ??
            selectedCurrencyCode ??
            ServerConstants.aedCurrency)
        .trim()
        .toUpperCase();

    if (headerCode != ServerConstants.aedCurrency) {
      final int aedFromUi =
          int.tryParse(newProposedLimitController.text.replaceAll(",", "")) ??
              0;
      if (aedFromUi > 0) {
        return aedFromUi;
      }

      final int aedFromApi = (facilityDetail.isNotEmpty)
          ? ((facilityDetail.first.proposedLimitAED ?? 0).toInt())
          : 0;
      if (aedFromApi > 0) {
        return aedFromApi;
      }
    }

    // AED header (or fallback)
    return effectiveProposedLimit;
  }

  /// Returns true if the given row’s Proposed Limit (converted to AED) exceeds
  /// the header Proposed Limit cap (AED).
  /// Important:
  /// - This is **row-level** validation only.
  /// - No aggregation/summing across multiple rows is performed here.
  /// Parameters:
  /// - rowIndex: Row index for resolving the row currency conversion rate.
  /// - localValue: The user-entered proposed limit for that row (in row currency).
  /// Returns:
  /// - true if rowAED > headerCapAED
  /// - false otherwise (including when capAED <= 0).
  bool exceedsParentCapWith({
    required int rowIndex,
    required int localValue,
  }) {
    final int capAED = headerProposedLimitCapAED;
    if (capAED <= 0) {
      return false;
    }

    // Convert this row to AED (safeRate=1 for AED or unknown)
    final num rate = _safeRateForSubType(rowIndex);
    final int rowAED = (localValue * rate).toInt();

    return rowAED > capAED;
  }

  /// Handles live typing for a Sub-type Proposed Limit cell (per row).
  /// Behavior:
  /// - Parses and stores the user’s numeric input into the row model (no clamping).
  /// - If the row is selected and this row’s AED-equivalent value exceeds the
  ///   header Proposed Limit cap, shows a toast (guarded to avoid spamming).
  /// - Does not modify the user’s typed input (no auto-correction).
  /// Notes:
  /// - This is **row-level** enforcement (no aggregation).
  /// - Use this for real-time feedback while typing.
  void onSubTypeProposedLimitChanged(int rowIndex, String rawText) {
    if (rowIndex < 0 || rowIndex >= facilitySubTypes.length) {
      return;
    }

    final String cleaned = rawText.replaceAll(",", "").trim();
    final int localValue = int.tryParse(cleaned) ?? 0;

    // Always store what user typed (no clamping).
    facilitySubTypes[rowIndex].proposedLimit = localValue;

    // If row not selected, nothing else to do.
    final bool isSelected = facilitySubTypes[rowIndex].subTypeSelected ?? false;
    if (!isSelected) {
      return;
    }

    // Show a toast if the aggregate exceeds cap. Do NOT change the input.
    if (exceedsParentCapWith(rowIndex: rowIndex, localValue: localValue)) {
      if (shouldShowAllocationToastOnce()) {
        // your existing gate
        AlertManager().showFailureToast(
          "Sub-limit Proposed Limit cannot exceed header Proposed Limit",
        );
      }
    }

    // Nudge the UI to refresh (e.g., tooltip AED text).
    // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Validator for Sub-type Proposed Limit cell (per row).
  /// Rules:
  /// - If row is not selected, validation is skipped (returns null).
  /// - Field must not be empty when selected.
  /// - Row Proposed Limit (AED-equivalent) must not exceed the header Proposed
  ///   Limit cap (AED).
  /// Notes:
  /// - This is **row-level** validation (no aggregation).
  /// Returns:
  /// - Localized required-field message if empty.
  /// - Business-rule message if row exceeds header cap.
  /// - null if valid.
  String? validateSubTypeProposedLimit(int rowIndex, String? rawText) {
    if (rowIndex < 0 || rowIndex >= facilitySubTypes.length) {
      return null;
    }

    final bool isSelected = facilitySubTypes[rowIndex].subTypeSelected ?? false;
    if (!isSelected) {
      return null;
    }

    final String cleaned = (rawText ?? "").replaceAll(",", "").trim();
    if (cleaned.isEmpty) {
      return "common.validation.emptyField".tr();
    }

    final int localValue = int.tryParse(cleaned) ?? 0;

    if (exceedsParentCapWith(rowIndex: rowIndex, localValue: localValue)) {
      return "Sub-limit Proposed Limit cannot exceed header Proposed Limit";
    }
    return null;
  }

  /// Save-time guard for Sub-limit Proposed Limit validation.
  /// Returns true when:
  /// - Any selected row has a Proposed Limit which, after conversion to AED,
  ///   exceeds the header Proposed Limit cap (AED).
  /// Why this exists:
  /// - It blocks Save early with a business-rule message instead of letting the
  ///   form fail later with generic required-field errors.
  /// Notes:
  /// - This checks rows individually (**no aggregation**).
  bool hasInvalidSubTypeProposedLimit() {
    final int capAED = headerProposedLimitCapAED;
    if (capAED <= 0) {
      return false;
    }

    for (int rowIndex = 0; rowIndex < facilitySubTypes.length; rowIndex++) {
      final sub = facilitySubTypes[rowIndex];
      if (!(sub.subTypeSelected ?? false)) {
        continue;
      }

      final int localAmount = sub.proposedLimit ?? 0;
      if (localAmount <= 0) {
        continue;
      }

      final num rate = _safeRateForSubType(rowIndex);
      final int rowAED = (localAmount * rate).toInt();

      if (rowAED > capAED) {
        return true;
      }
    }

    return false;
  }

  /// Attempts to resolve the selected "Index" value for `profitGrid`
  /// from the dynamic form document.
  /// Why this exists:
  /// - `profitGrid` is a grid/table-style dynamic form section.
  /// - When saving/restoring dynamic form data, grid keys can be flattened into
  ///   multiple formats depending on the UI control and serializer.
  /// - This method checks several known key patterns safely.
  /// Resolution order:
  /// 1) Prefer the fully-qualified first-row key: `profitGrid.index@0`
  /// 2) Scan all keys that start with `profitGrid.index@` (any row)
  /// 3) Fallback to legacy/non-qualified keys: `index@0` or `index`
  /// Returns:
  /// - The resolved index value as String if found, otherwise null.
  String? _readProfitGridIndexFromDocument() {
    // Prefer fully-qualified grid key format
    final dynamic firstRowIndexValue =
        dynamicFormDocument["profitGrid.index@0"];
    if (firstRowIndexValue != null &&
        firstRowIndexValue.toString().trim().isNotEmpty) {
      return firstRowIndexValue.toString().trim();
    }

    //scan any row index
    for (final MapEntry<String, dynamic> entry in dynamicFormDocument.entries) {
      final String key = entry.key;
      if (key.startsWith("profitGrid.index@")) {
        final dynamic rowIndexValue = entry.value;
        if (rowIndexValue != null &&
            rowIndexValue.toString().trim().isNotEmpty) {
          return rowIndexValue.toString().trim();
        }
      }
    }

    // in case UI uses non-qualified keys (less safe)
    final dynamic legacyIndexValue =
        dynamicFormDocument["index@0"] ?? dynamicFormDocument["index"];
    if (legacyIndexValue != null &&
        legacyIndexValue.toString().trim().isNotEmpty) {
      return legacyIndexValue.toString().trim();
    }

    return null;
  }

  /// Extracts a stable integer RIM key from a [Reference].
  /// Falls back to parsing [`name`] if [`id`] is missing.
  int? _rimKeyOf(Reference borrower) {
    final dynamic id = borrower.id;
    if (id is int) {
      return id;
    }
    if (id != null) {
      return int.tryParse(id.toString());
    }

    final String name = (borrower.name ?? "").trim();
    return int.tryParse(name);
  }

  /// Returns benchmark items filtered by the current create-facility
  /// `limitCategory`.
  ///
  /// Business rule:
  /// - `reference2 == "F"` -> funded benchmarks
  /// - `reference2 == "N"` -> non-funded benchmarks
  ///
  /// Why this exists:
  /// The create-facility screen already receives `limitCategory` from the
  /// previous screen and uses it to filter dynamic-form INDEX options.
  /// This method applies the same rule to the Sub Type table's Benchmark field
  /// so UI behavior stays consistent.
  ///
  /// Fallback behavior:
  /// - If `limitCategory` is empty/null, return the full benchmark list.
  /// - If filtering produces no items, also return the full benchmark list.
  List<Reference> benchmarkItemsForCurrentLimitCategory() {
    final String category = (limitCategory ?? "").trim().toUpperCase();

    if (category.isEmpty) {
      return benchmark;
    }

    final List<Reference> filteredItems = benchmark.where((reference) {
      final String referenceCategory =
          (reference.reference2 ?? "").trim().toUpperCase();
      return referenceCategory == category;
    }).toList();

    return filteredItems.isNotEmpty ? filteredItems : benchmark;
  }

  /// Returns the final benchmark items to display for one subtype row.
  ///
  /// Normal behavior:
  /// - Uses benchmark items filtered by the current facility `limitCategory`
  ///
  /// Fallback behavior:
  /// - If the subtype row already has a saved `index` which is not present in
  ///   the filtered list, this method injects that saved item from the full
  ///   benchmark master list into the display list.
  ///
  /// Why fallback is important:
  /// Some existing/saved data may contain an index value that belongs to the
  /// opposite category (for example an `F` benchmark stored on an `N` row).
  /// Without fallback, the dropdown would look blank even though data exists.
  ///
  /// This method does not change any saved value. It only prepares UI display.
  List<Reference> subTypeBenchmarkItemsForUi(int rowIndex) {
    if (rowIndex < 0 || rowIndex >= facilitySubTypes.length) {
      return const <Reference>[];
    }

    final List<Reference> filteredItems =
        benchmarkItemsForCurrentLimitCategory();

    final String selectedIndexId =
        (facilitySubTypes[rowIndex].index ?? "").trim();

    if (selectedIndexId.isEmpty) {
      return filteredItems;
    }

    final bool existsInFiltered = filteredItems.any(
      (reference) => (reference.id?.toString() ?? "").trim() == selectedIndexId,
    );

    if (existsInFiltered) {
      return filteredItems;
    }

    final List<Reference> displayItems = List<Reference>.from(filteredItems);

    for (final Reference benchmarkOption in benchmark) {
      final String benchmarkOptionId =
          (benchmarkOption.id?.toString() ?? "").trim();

      if (benchmarkOptionId == selectedIndexId) {
        final bool alreadyPresent = displayItems.any(
          (item) => (item.id?.toString() ?? "").trim() == selectedIndexId,
        );

        if (!alreadyPresent) {
          displayItems.insert(0, benchmarkOption);
        }
        break;
      }
    }

    return displayItems;
  }

  /// Returns the currently selected benchmark item for one subtype row.
  ///
  /// This method resolves the selected item from the final UI display list
  /// returned by `subTypeBenchmarkItemsForUi(...)`.
  ///
  /// Returns:
  /// - matching `Reference` if current row index exists in the display list
  /// - `null` if the row has no saved benchmark value
  Reference? selectedSubTypeBenchmarkForUi(int rowIndex) {
    if (rowIndex < 0 || rowIndex >= facilitySubTypes.length) {
      return null;
    }

    final String selectedIndexId =
        (facilitySubTypes[rowIndex].index ?? "").trim();

    if (selectedIndexId.isEmpty) {
      return null;
    }

    final List<Reference> displayItems = subTypeBenchmarkItemsForUi(rowIndex);

    for (final Reference benchmarkOption in displayItems) {
      final String benchmarkOptionId =
          (benchmarkOption.id?.toString() ?? "").trim();

      if (benchmarkOptionId == selectedIndexId) {
        return benchmarkOption;
      }
    }

    return null;
  }
}
