import "dart:async";
import "dart:convert";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/currency_rates_service.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/draft_handler.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/state.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/limit_caps_summary.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";
import "package:wcas_frontend/models/request/facility_security/facility_detail.dart";
import "package:wcas_frontend/models/request/facility_security/facility_summary_list.dart";
import "package:wcas_frontend/models/request/facility_security/limits_facilities_response.dart";
import "package:wcas_frontend/models/request/facility_security/project_list.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";
import "package:wcas_frontend/repositories/home_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// Columns that the Facility Summary tables can be filtered on.
///
/// Each value maps to the text the user actually sees in that column, so
/// lookup columns are matched against their resolved name rather than the
/// raw reference id.
enum FacilityFilterField {
  /// Filters rows by limit number.
  limitNo,

  /// Filters rows by controlling limit number.
  controllingLimitNo,

  /// Filters rows by the resolved limit description name.
  limitDescription,

  /// Filters rows by project name (project groups only).
  projectName,

  /// Filters rows by the resolved limit cap type name (Limit Caps only).
  limitCapType,
}

/// Facilities Summary ViewModel (Facilities/Limits module).
///
/// Powers the **Facility Summary** screen which displays facilities grouped by
/// **Limit Group**
/// (e.g., General Working Capital, Term Loans, PFE Limits, Project Standby
/// Limits, Project Specific Limits).
/// Each customer (RIM) is rendered as an accordion with these grouped sections.
///
/// Key responsibilities:
/// - Load facility summary data per RIM and supporting reference data for
/// dropdowns.
/// - Enforce role-based editability (PageMode: Edit/View/NA) for facility fields.
/// - Support Limit Caps action and related navigation/dialog flow (Corporate flow).
/// - Validate hierarchical limits (controlling limit logic, group caps for
/// project groups).
/// - Maintain tooltip cache for “previous value” and optional AED conversion.
class FacilitiesSummaryViewModel extends SafeCubit<FacilitiesSummaryState>
    with DraftMixin<FacilitiesSummaryViewModel> {
  /// Creates a facility summary view model with the initial loading state.
  FacilitiesSummaryViewModel()
      : super(
          FacilitiesSummaryState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------
  @override
  String get draftModuleKey => DraftModuleKeys.facilitiesAndSecurities;

  @override
  String get draftFormKey => Routes.facilitySummaryView;

  @override
  DraftHandler<FacilitiesSummaryViewModel> get draftHandler =>
      FacilitySummaryDraftHandler();

  // ---------------------------------------------------------------------------
  // Core services / repositories
  // --------------------------------------------------------------------

  /// Repository used to retrieve application-related data.
  RequestRepository repository = RequestRepository();

  /// Service used to load reference data for dropdowns and lookups.
  ReferenceDataService referenceDataService = ReferenceDataService();

  /// Repository used for facility and security summary operations.
  FacilitySecurityRepository facilitySecurityRepository =
      FacilitySecurityRepository();

  /// Global key for the facility summary form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Current page mode determined by user access rights.
  PageMode pageMode = PageMode.na;

  /// Returns whether the current user can edit the facility summary.
  bool get canEdit => pageMode == PageMode.edit;

  /// Non-null only when this screen was routed to from the Approval
  /// "Amend Facilities" action, in which case it's PageMode.edit.
  PageMode? amendPagemode;

  /// Indicates whether header information has already been saved.
  bool savedHeader = false;

  /// Financial Institution segment flow toggle (affects reference keys and
  /// behavior).
  bool get isFIFlow =>
      Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

  // ──────────────────────────────────────────────────────────────────────────
  // Reference Data (dropdowns / configuration)
  // ──────────────────────────────────────────────────────────────────────────

  /// Currency codes used in currency dropdowns.
  List<Reference> currencyCodes = [];

  /// Period/tenor units used for Tenor dropdown (Days/Months/Years/On Demand).
  List<Reference> period = [];

  /// Sustainability classification multi-select options.
  List<Reference> sustanabilityClassifications = [];

  /// Benchmarks/index dropdown values.
  List<Reference> benchmark = [];

  /// Margin sign (+/-) dropdown values.
  List<Reference> marginSign = [
    Reference(name: "+"),
    Reference(name: "-"),
  ];

  /// Limit group reference list used to build Facility Summary group sections.
  List<Reference> limitGroup = [];

  /// Facility types reference list (used to resolve limitDescription id ->
  /// display name).
  List<Reference> facilityTypes = [];

  /// Limit caps type list for caps UI (Corporate).
  List<Reference> limitCapsType = [];

  /// Product type radio options and selection (Conventional/Islamic/Both).
  List<Reference> productTypeOptions = [];

  /// Currently selected product type option.
  Reference? selectedProductTypeOption;

  /// Facility descriptions filtered by selected limit type.
  List<Reference> facilityDescriptions = [];

  /// Reference exclusion list used when building facilityDescriptions (keep
  /// logic unchanged).
  static const Set<String> _excludedLimitDescriptionIds = {
    "13871",
    "13872",
    "13873",
    "13874",
    "11577",
    "11578",
    "11579",
    "11580",
  };

  // ──────────────────────────────────────────────────────────────────────────
  // Facility Summary data (per RIM / group)
  // ──────────────────────────────────────────────────────────────────────────

  /// Facility summary list returned from API, grouped by customer RIM and group
  /// sections.
  List<FacilitySummaryList>? customerFacilities;

  /// Linkage facilities snapshot used by linkage-related logic.
  List<Facility> facilities = [];

  /// Original linkage facilities snapshot used for comparison and
  /// change tracking.
  List<Facility> originalFacilities = [];

  /// Application details used to determine allowed product types and
  /// other facility summary business rules.
  ApplicationDetails? applicationDetails = ApplicationDetails();

  /// Create Facility context used when navigating to create or edit
  /// facility screens.
  Facility facility = Facility();

  /// Facility detail list used by project header save processing.
  List<FacilityDetail> facilityDetail = [];

  /// Facility details response model used within the summary screen.
  FacilityDetails facilityDetails = FacilityDetails();

  /// Cached project names used for project-specific limit groups.
  List<Reference> projectNamesSpecific = [];

  /// Cached project names used for standby limit groups.
  List<Reference> projectNamesStandBy = [];

  /// Currently selected project reference.
  Reference? selectedProjectRef;

  /// Controls radio enable/disable state (when both conventional+islamic exist).
  bool isProductTypeEnabled = false;

  /// Flags used to track request and application state.
  bool isNewRequest = false;

  /// Indicates whether an API error has occurred.
  bool isApiError = false;

  /// Indicates whether an existing application reference number is selected.
  bool isExisitngAppRefNo = false;

  /// Selected reconsideration application reference number.
  String? selectedReconAppReNumber;

  /// Selected last approved application reference number.
  String? selectedLastApprovedAppRefNum;

  /// Selected reconsideration application details.
  ApplicationDetails? selectedReconsiderations;

  /// Currently selected product type.
  Reference? selectedProductType;

  /// Available product type options.
  List<Reference> productTypeItems = [];

  // ──────────────────────────────────────────────────────────────────────────
  // Project header state (Standby/Specific groups)
  // ──────────────────────────────────────────────────────────────────────────

  /// Project Standby and Project Specific limit group identifiers.
  static const int groupStandBy = ServerConstants.projectStandByLimitID;

  /// Project Specific limit group identifier.
  static const int groupSpecific = ServerConstants.projectSpecificLimitsID;

  /// Builds a cache key for header values using the limit group and RIM number.
  String groupRimKey(int groupId, int rimNo) => "$groupId-$rimNo";

  /// Project-specific project name controllers keyed by group and RIM.
  final Map<String, TextEditingController> psNameCtrls = {};

  /// Project-specific proposed limit controllers keyed by group and RIM.
  final Map<String, TextEditingController> psProposedCtrls = {};

  /// Project standby project name controllers keyed by group and RIM.
  final Map<String, TextEditingController> psStandbyNameCtrls = {};

  /// Project standby proposed limit controllers keyed by group and RIM.
  final Map<String, TextEditingController> psStandbyProposedCtrls = {};

  /// Header numeric inputs per (groupId, rimNo).
  final Map<String, num?> _projectExistingByKey = {};
  final Map<String, num?> _projectProposedByKey = {};

  /// Header currency per (groupId, rimNo).
  final Map<String, Reference?> headerCurrencyByKey = {};

  /// Header API snapshot caches (per groupId + rimNo).
  /// Used for dirty-check and update payload behavior.
  final Map<String, int?> _headerFacilityIdByKey = {};
  final Map<String, int?> _headerMasterFacilityIdByKey = {};
  final Map<String, num?> _headerProposedApiByKey = {};
  final Map<String, String?> _headerCurrencyApiByKey = {};
  final Map<String, String?> _headerNameApiByKey = {};

  /// Project list fetch cache to avoid repeated API calls.
  final Set<String> _projectFetchKeys = {};

  /// Header validation visibility (group -> show errors).
  final Map<int, bool> _showHeaderErrors = {};

  /// Legacy header input value for project existing limits.
  num? projectExistingLimitInput;

  /// Legacy header input value for project proposed limits.
  num? projectProposedLimitInput;

  /// Controller for the project existing limit header field.
  TextEditingController projectExistingCtrl = TextEditingController();

  /// Controller for the project proposed limit header field.
  TextEditingController projectProposedCtrl = TextEditingController();

  /// Controller for the project standby existing limit header field.
  TextEditingController projectStandbyExistingCtrl = TextEditingController();

  /// Controller for the project standby proposed limit header field.
  TextEditingController projectStandbyProposedCtrl = TextEditingController();

  /// Controller for the project standby name header field.
  TextEditingController projectStandbyNameCtrl = TextEditingController();

  /// Controller for the project-specific name header field.
  TextEditingController projectSpecificNameCtrl = TextEditingController();

  /// True if group is project group (Standby/Specific).
  bool isProjectGroup(int? groupId) =>
      groupId == groupSpecific || groupId == groupStandBy;

  /// Returns true only for groups that must enforce header proposed limits
  /// before creating sublimits.
  bool shouldRequireHeaderLimitsFor(int? groupId) =>
      groupId == groupStandBy || groupId == groupSpecific;

  /// Indicates whether project header validation messages should show for a
  /// group.
  bool shouldShowProjectHeaderErrors(int? groupId) =>
      groupId != null && (_showHeaderErrors[groupId] ?? false);

  /// Excludes non-facility rows (Limit Caps 935 / product CLT) from facility detail logic.
  bool isExcludedFacility(FacilitySummaryNew? facility) {
    final String? limitDescription = facility?.limitDescription?.toString();
    final String productCode =
        (facility?.productCode ?? "").trim().toUpperCase();
    return limitDescription == "935" || productCode == "CLT";
  }

  /// Selected limit description.
  Reference? selectedLimitDetails;

  /// Selected sub-limit description.
  Reference? selectedSubLimitDetails;

  /// List of available currency codes.
  List<Reference> countryCodes = [];

  /// Available spread/commission sign options.
  List<Reference> spreadCommisions = [
    Reference(name: "+"),
    Reference(name: "-"),
  ];

  /// Available tenor unit options.
  List<Reference> tenorDays = [
    Reference(name: "Days"),
    Reference(name: "Months"),
  ];

  /// Snapshot of initial proposed limit values by row.
  final Map<String, int> _initialProposedByRow = {};

  /// Snapshot of initial currency codes by row.
  final Map<String, String> _initialCurrencyByRow = {};

  /// List of available sub-limit types.
  List<Reference> subLimitTypes = [];

  /// List of available limit types.
  List<Reference> limitTypes = [];

  /// Localized label used to display previous values.
  String previousValue = "facilities.facilitySummary.previuosValue".tr();

  /// Cached project proposed limit values grouped by limit group.
  final Map<int, num?> _projectProposedLimitByGroup = {};

  /// Header inputs must be present to create facility from
  /// ProjectSpecificLimitTable.
  /// Treat only *empty* as invalid—"0" is a valid numeric value if your
  /// business allows it.
  bool get isProjectHeaderLimitsEntered =>
      projectExistingLimitInput != null && projectProposedLimitInput != null;

  // ──────────────────────────────────────────────────────────────────────────
  // Validation & Save orchestration
  // ──────────────────────────────────────────────────────────────────────────

  /// Initializes the Facility Summary screen state.
  ///
  /// Loads:
  /// - Facility linkage list (linkage snapshot)
  /// - Facility summary per RIM (grouped facilities)
  /// - Application details (product type flags)
  /// - Currency codes & reference data for dropdowns
  /// - Updated facility type reference list (includes newly added admin types)
  ///
  /// This aligns with the Facility Summary FSD requirement that data is shown
  /// grouped
  /// by limit group and governed by role-based editability.
  Future<void> init(
    BuildContext context, {
    PageMode? amendPagemode,
  }) async {
    logger.i("initialising FacilitiesSummaryViewModel");
    this.amendPagemode = amendPagemode;
    pageMode = amendPagemode ??
        AuthRepository.getPageMode(RightConstants.facilitySummary);

    // Can edit the RR type application if initialted by CA
    // final bool isInitiatedRR =
    //     Utils.checkRole(UserRole.creditAnalyst) && Globals.checkIsInitiated();
    // if (isInitiatedRR) {
    //   pageMode = PageMode.edit;
    // }
    await getFacilitySummaryListFromLinakge();
    await getFacilitySummaryListPerRim();
    await Future.wait([
      getApplicationDetails(),
      getCurrencyCodes(),
      getUpdatedFacilityReference(),
      getReferenceData(),
    ]);

    // Enable auto-save
    // registerDraftCallback();
    // await loadDraftIfAvailable();

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  @override
  Future<void> close() {
    //unregisterDraftCallback();
    return super.close();
  }

  /// Retrieves facility summary linkage data.
  ///
  /// Loads linked facilities, preserves the original facility snapshot
  /// for comparison and reset operations, and updates the view state.
  Future<void> getFacilitySummaryListFromLinakge() async {
    try {
      facilities =
          await FacilitySecurityRepository.instance.getLinkageFacility();

      originalFacilities = List.from(facilities);

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Fetches facility summary grouped by RIM and limit group.
  ///
  /// Also preloads project header values (order == '0') for project groups,
  /// so cap validations and header dirty-detection work correctly.
  Future<void> getFacilitySummaryListPerRim() async {
    try {
      customerFacilities =
          await facilitySecurityRepository.getFacilitySummaryList();

      // Rows have been replaced; a stale filter would look like missing data.
      clearFacilityFilters();
      preloadHeaderProposedLimitsFromApi();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (error) {
      AlertManager().showFailureToast(error.toString());
    } finally {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Saves edited facility rows for the current customer/group.
  ///
  /// Behavior:
  /// - Collects only rows marked `isEdited ?? false`.
  /// - Validates project group constraints before submit:
  ///   * Sub-limit proposed must not exceed controlling limit proposed.
  ///   * For project groups, validates total proposed does not exceed header/group cap.
  /// - Submits edited rows to backend and refreshes the facility summary list.
  ///
  /// Note:
  /// Totals/caps behavior follows Facility Summary rules for hierarchical limits and caps.
  Future<void> saveFacilitySummaryList(
    FacilitySummaryList list, {
    required int limitGroup,
    int? selectedRim,
  }) async {
    try {
      // ------------------------------------------------------------------
      //  Save/Update Project Header (order == "0") if user edited it
      // ------------------------------------------------------------------

      final bool isProjectGroup =
          limitGroup == ServerConstants.projectSpecificLimitsID ||
              limitGroup == ServerConstants.projectStandByLimitID;

      if (isProjectGroup && selectedRim != null) {
        final bool headerDirty =
            isProjectHeaderDirtyAtRim(limitGroup, selectedRim);

        if (headerDirty) {
          final int? headerFacilityId =
              headerFacilityIdForGroupAtRim(limitGroup, selectedRim);
          final int? facilityMasterID =
              headerMasterFacilityIdForGroupAtRim(limitGroup, selectedRim);
          // Use the facilityMasterId from the current facility context
          final bool isHeaderSaveSuccessful = await saveOrUpdateProjectHeader(
            rimNo: selectedRim,
            groupId: limitGroup,

            // descSnapshot is not used heavily for project groups in your builder,
            // but keep it as-is (minimal change).
            descSnapshot: facility.facilityDescription,
            facilityId: headerFacilityId,
            facilityMasterID: facilityMasterID,
            limitCaptype: limitCapTypeForGroup(limitGroup),
          );

          if (!isHeaderSaveSuccessful) {
            emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
            return;
          }
          savedHeader = true;
        }
      }

      final List<FacilitySummaryNew> edited = _collectEditedFacilities(list);
      if (edited.isEmpty) {
        if (savedHeader) {
          emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
          return;
        }

        AlertManager().showWarningToast(
          "facilities.facilitySummary.nochChangeToSave".tr(),
        );
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }
      await facilitySecurityRepository.saveFacilitySummaryListEdited(edited);

      AlertManager().showSuccessToast(
        "facilities.facilitySummary.savedSuccessfully".tr(),
      );

      await getFacilitySummaryListFromLinakge();
      await getFacilitySummaryListPerRim();

      _initialProposedByRow.clear();
      _initialCurrencyByRow.clear();

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  /// Saves edited limit cap records from the facility summary dialog.
  ///
  /// Validates that changes exist, persists edited limit cap data,
  /// refreshes the facility summary list, and resets cached initial
  /// values used for change tracking.
  Future<void> saveLimitCapsSummaryList(
    FacilitySummaryList list,
  ) async {
    try {
      final List<FacilitySummaryNew> edited = _collectEditedFacilities(list);
      if (edited.isEmpty) {
        AlertManager().showWarningToast(
          "facilities.facilitySummary.nochChangeToSave".tr(),
        );
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }

      await facilitySecurityRepository.saveFacilitySummaryListEdited(edited);
      AlertManager().showSuccessToast(
        "facilities.facilitySummary.savedSuccessfully".tr(),
      );
      await getFacilitySummaryListFromLinakge();

      _initialProposedByRow.clear();
      _initialCurrencyByRow.clear();
    } on Object catch (error) {
      AlertManager().showFailureToast(error.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Deletes facility details based on the provided serial number and type ID.
  /// Emits loading and loaded states for the table loader.
  Future<void> deleteFacilityDetails({int? serialNumber}) async {
    if (serialNumber == null) {
      AlertManager().showFailureToast(
        "facilities.facilitySummary.invalidFacility".tr(),
      );
      return;
    }

    // emit(state.copyWith(tableLoaderStatus: LoadingStatus.loading));
    try {
      await facilitySecurityRepository.deleteFacilityDetails(
        facilityId: serialNumber,
      );
      await getFacilitySummaryListFromLinakge();
      await getFacilitySummaryListPerRim();
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    } finally {
      emit(state.copyWith(tableLoaderStatus: LoadingStatus.loaded));
    }
  }

  /// Returns the project-specific name controller for the specified RIM.
  ///
  /// Creates and caches the controller if it does not already exist.
  TextEditingController psNameCtrl(int rimNo) => psNameCtrls.putIfAbsent(
        groupRimKey(groupSpecific, rimNo),
        TextEditingController.new,
      );

  /// Returns the project-specific proposed limit controller for the
  /// specified RIM.
  ///
  /// Creates and caches the controller if it does not already exist.
  TextEditingController psProposedCtrl(int rimNo) =>
      psProposedCtrls.putIfAbsent(
        groupRimKey(groupSpecific, rimNo),
        TextEditingController.new,
      );

  /// Returns the project standby name controller for the specified RIM.
  ///
  /// Creates and caches the controller if it does not already exist.
  TextEditingController standbyNameCtrl(int rimNo) =>
      psStandbyNameCtrls.putIfAbsent(
        groupRimKey(groupStandBy, rimNo),
        TextEditingController.new,
      );

  /// Returns the project standby proposed limit controller for the
  /// specified RIM.
  ///
  /// Creates and caches the controller if it does not already exist.
  TextEditingController standbyProposedCtrl(int rimNo) =>
      psStandbyProposedCtrls.putIfAbsent(
        groupRimKey(groupStandBy, rimNo),
        TextEditingController.new,
      );

  /// Returns the selected header currency for the specified limit group
  /// and RIM number.
  Reference? headerCurrencyFor(int groupId, int rimNo) =>
      headerCurrencyByKey[groupRimKey(groupId, rimNo)];

  /// Updates the header currency for the specified limit group and
  /// RIM number.
  void setHeaderCurrencyFor(
    int groupId,
    int rimNo,
    Reference ref,
  ) {
    headerCurrencyByKey[groupRimKey(groupId, rimNo)] = ref;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Resolves the active RIM number from the current request context.
  ///
  /// The value is determined in the following order:
  /// 1. Group owner RIM number.
  /// 2. Customer RIM number from the request.
  /// 3. RIM number from the loaded facility summary data.
  int? resolveRimNoFromApi() {
    final int? groupOwner = Globals.request?.groupOwner;
    if (groupOwner != null && groupOwner > 0) {
      return groupOwner;
    }

    final dynamic reqRim = Globals.request?.customerRimNo;
    final int? reqRimInt =
        (reqRim is num) ? reqRim.toInt() : int.tryParse("$reqRim");
    if (reqRimInt != null && reqRimInt > 0) {
      return reqRimInt;
    }

    final List<FacilitySummaryList> customers =
        customerFacilities ?? const <FacilitySummaryList>[];
    final RimSummary? rim =
        (customers.isNotEmpty && (customers.first.rims?.isNotEmpty ?? false))
            ? customers.first.rims!.first
            : null;

    return extractRimId(
      rim?.rimName,
    );
  }

  /// Returns whether project header limits have been entered for the
  /// specified limit group and RIM number.
  bool isProjectHeaderLimitsEnteredForAtRim(
    int? groupId,
    int? rimNo,
  ) {
    if (groupId == null || rimNo == null) {
      return false;
    }
    final String key = groupRimKey(groupId, rimNo); // e.g., "11317-895044"
    return _projectProposedByKey[key] !=
        null; // value set by setProjectProposedLimitInput(..., rimNo: ...)
  }

  /// Retrieves application details required by the facility summary
  /// screen.
  ///
  /// Loads either the last approved application or the current
  /// application details and updates the related selection state.
  Future<void> getApplicationDetails() async {
    try {
      if (isNewRequest) {
        applicationDetails = await repository.getLastApprovedApplication() ??
            ApplicationDetails();
        selectedLastApprovedAppRefNum = applicationDetails?.applicationRefNo;
      } else {
        applicationDetails = await repository.getApplicationDetails(); // use
        selectedLastApprovedAppRefNum =
            applicationDetails?.lastApprovedAppRefNum;
        isExisitngAppRefNo =
            applicationDetails?.applicationRefNo?.trim().isNotEmpty ?? false;
        Globals.request?.isCreateRequest = false;
        isNewRequest = Globals.request?.isCreateRequest ?? false;
      }

      populateApplicationDetails(applicationDetails ?? ApplicationDetails());
      if (applicationDetails?.reconAppReNumber != null) {
        selectedReconsiderations = ApplicationDetails(
          applicationRefNo: applicationDetails?.reconAppReNumber,
          reconAppReNumber: applicationDetails?.reconAppReNumber,
        );
        selectedReconAppReNumber = applicationDetails?.reconAppReNumber;
      }
    } on Object catch (e) {
      logger.i("Error getApplicationDetails types: $e");
      isApiError = true;
      rethrow;
    }
  }

  /// Populates application details and updates the selected product type
  /// based on the application configuration.
  void populateApplicationDetails(ApplicationDetails details) {
    applicationDetails = details;

    updateSelectedProductType(
      conventional: details.conventional,
      islamic: details.islamic,
    ); // use
  }

  /// Updates the selected product type based on conventional and Islamic
  /// product availability.
  ///
  /// Automatically selects the appropriate product type and updates the
  /// facility context.
  void updateSelectedProductType({
    bool? conventional,
    bool? islamic,
  }) {
    final bool conv =
        conventional ?? (applicationDetails?.conventional ?? false);
    final bool isl = islamic ?? (applicationDetails?.islamic ?? false);
    isProductTypeEnabled = conv && isl;
    Reference? selected;
    if (conv && !isl) {
      selected = matchOrFirstById(productTypeOptions, 11321.toString());
    } else if (!conv && isl) {
      selected = matchOrFirstById(productTypeOptions, 11322.toString());
    } else {
      selected =
          productTypeOptions.isNotEmpty ? productTypeOptions.first : null;
    }
    selectedProductTypeOption = selected;
    facility.selectedProductTypeValue = selected;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Returns available product type options excluding the
  /// "Not Applicable" option.
  List<Reference> getFilteredProductOptions() {
    return productTypeItems
        .where(
          (ref) => ref.name != "requestInformation.requestInformation.na".tr(),
        )
        .toList();
  }

  /// Returns the header facility identifier for the specified limit
  /// group and RIM number.
  int? headerFacilityIdForGroupAtRim(
    int groupId,
    int rimNo,
  ) {
    return _headerFacilityIdByKey[groupRimKey(groupId, rimNo)];
  }

  int? headerMasterFacilityIdForGroupAtRim(
    int groupId,
    int rimNo,
  ) {
    return _headerMasterFacilityIdByKey[groupRimKey(groupId, rimNo)];
  }

  /// Returns the header facility identifier for the specified limit
  /// group and RIM number.

  /// Detect if header inputs differ from API snapshot
  bool isProjectHeaderDirtyAtRim(int groupId, int rimNo) {
    final key = groupRimKey(groupId, rimNo);

    final num? apiProposed = _headerProposedApiByKey[key];
    final num? currentProposed = _projectProposedByKey[key];

    final String apiCurrency =
        (_headerCurrencyApiByKey[key] ?? ServerConstants.aedCurrency)
            .trim()
            .toUpperCase();
    final String currentCurrency =
        (headerCurrencyFor(groupId, rimNo)?.name ?? ServerConstants.aedCurrency)
            .trim()
            .toUpperCase();

    final bool isStandby = groupId == groupStandBy;
    final String currentName =
        (isStandby ? standbyNameCtrl(rimNo).text : psNameCtrl(rimNo).text)
            .trim();
    final String apiName = (_headerNameApiByKey[key] ?? "").trim();

    // Proposed: compare only if both known
    final bool proposedChanged = apiProposed != null &&
        currentProposed != null &&
        apiProposed != currentProposed;

    final bool currencyChanged = apiCurrency != currentCurrency;
    final bool nameChanged = apiName != currentName;

    return proposedChanged || currencyChanged || nameChanged;
  }

  /// Updates the selected product type and synchronizes the corresponding
  /// application product configuration.
  ///
  /// Sets the conventional and Islamic product flags based on the
  /// selected product type option.
  void onProductTypeSelected(Reference selected) {
    selectedProductType = selected;

    if (selected.reference1 == ServerConstants.productTypeConventional) {
      applicationDetails?.conventional = true;
      applicationDetails?.islamic = false;
    } else if (selected.reference1 == ServerConstants.productTypeIslamic) {
      applicationDetails?.islamic = true;
      applicationDetails?.conventional = false;
    } else if (selected.reference1 == ServerConstants.productTypeBoth) {
      applicationDetails?.conventional = true;
      applicationDetails?.islamic = true;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Retrieves project details from the `ProjectRepository` and extracts
  /// project names from the contract list.
  Future<void> getProjectList(int? limitGroup, int? rimNo) async {
    try {
      final String key = "${limitGroup ?? 0}-${rimNo ?? 0}";

      // need to call this function again if user allocated a project and save facilitytable. NO NEED TO RETURN funciton
      // if (limitGroup != null &&
      //     rimNo != null &&
      //     _projectFetchKeys.contains(key)) {
      //   return;
      // }

      final ProjectListResponse list =
          await facilitySecurityRepository.getProjectList(
        limitGroup: limitGroup, // NEW
        rimNo: rimNo,
      );

      // projectNames =
      //     list.responseData.map((name) => Reference(name: name)).toList();
      if (limitGroup == ServerConstants.projectStandByLimitID) {
        projectNamesStandBy =
            list.responseData.map((name) => Reference(name: name)).toList();
      } else {
        projectNamesSpecific =
            list.responseData.map((name) => Reference(name: name)).toList();
      }

      if (limitGroup != null && rimNo != null) {
        _projectFetchKeys.add(key); // Mark as fetched
      }
    } on Object catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  /// Stores the project existing limit value for the specified limit
  /// group and RIM number.
  void setProjectExistingLimitInput(
    String? value, {
    required int groupId,
    required int rimNo,
  }) {
    _projectExistingByKey[groupRimKey(groupId, rimNo)] =
        num.tryParse(value ?? "");
  }

  /// Stores the project proposed limit value for the specified limit
  /// group and RIM number.
  ///
  /// Also updates the cached proposed limit value maintained at the
  /// limit-group level.
  void setProjectProposedLimitInput(
    String? value, {
    required int groupId,
    required int rimNo,
  }) {
    _projectProposedByKey[groupRimKey(groupId, rimNo)] =
        num.tryParse(value ?? "");
    _projectProposedLimitByGroup[groupId] = num.tryParse(value ?? "");
  }

  /// Returns whether project header limits have been entered for the
  /// specified limit group.
  bool isProjectHeaderLimitsEnteredFor(int? groupId) {
    if (groupId == null) {
      return false;
    }
    final num? proposedLimit = _projectProposedLimitByGroup[groupId];
    return proposedLimit != null;
  }

  /// Marks the project header section as having validation errors for
  /// the specified limit group.
  void markProjectHeaderErrors(int? groupId) {
    if (groupId == null) {
      return;
    }
    _showHeaderErrors[groupId] = true;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Clears project header validation errors for the specified limit
  /// group.
  void clearProjectHeaderErrors(int? groupId) {
    if (groupId == null) {
      return;
    }
    if (_showHeaderErrors.remove(groupId) != null) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Converts the specified amount to its AED equivalent.
  ///
  /// Returns the original amount when the currency is AED or when
  /// exchange rate retrieval fails. The converted value is returned
  /// as a formatted string with thousands separators.
  Future<String> convertToAed({
    required String? amountStr,
    required String currencyCode,
    required FacilitySecurityRepository repository,
  }) async {
    final NumberFormat formatter = NumberFormat("#,###");

    final String code = currencyCode.trim().toUpperCase();

    // Clean & parse amount
    final int amount = int.tryParse(
          (amountStr ?? "0").replaceAll(",", "").trim(),
        ) ??
        0;

    // If AED → no conversion
    if (code.isEmpty || code == ServerConstants.aedCurrency) {
      return formatter.format(amount);
    }

    try {
      // Fetch rate from cache
      final Map<String, num> rates = await CurrencyRatesService().getRates();

      final num rate = rates[code] ?? 0;

      // Safe conversion
      final int converted = rate > 0 ? (amount * rate).toInt() : amount;

      return formatter.format(converted);
    } on Exception {
      // fallback if API fails
      return formatter.format(amount);
    }
  }

  /// Returns tooltip message showing the “previous value” snapshot for a row.
  ///
  /// This caches the initial proposed value and currency the first time a row
  /// is seen.
  /// Subsequent edits can display:
  /// - Previous value + currency
  /// - Optional conversion information to AED (computed in
  /// updateConvertedTooltipFor)

  /// Updates the tooltip cache for currency conversion / previous value display.
  ///
  /// Debounced to avoid excessive API calls while user types.
  /// If currency is AED (or empty), tooltip shows previous snapshot only.
  /// Otherwise, converts live proposed amount to AED using exchange rate servic

  // Called by FacilityProjectName.onSelected
  void onProjectNameSelected(List<Reference> selected) {
    if (selected.isNotEmpty) {
      selectedProjectRef = selected.first;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Returns the proposed limit value for the specified limit group
  /// and RIM number.
  int? proposedLimitForGroup(
    int groupId, {
    required int rimNo,
  }) {
    final int proposedLimit =
        _projectProposedByKey[groupRimKey(groupId, rimNo)]?.toInt() ?? 0;
    return proposedLimit;
  }

  /// Applies the currently selected project to the provided facility.
  ///
  /// Updates the facility project name, marks the facility as edited,
  /// and refreshes the UI state.
  void applySelectedProjectTo(FacilitySummaryNew facility) {
    if (selectedProjectRef != null) {
      facility
        ..projectName = selectedProjectRef?.name
        ..isEdited = true;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  List<FacilitySummaryNew> _collectEditedFacilities(FacilitySummaryList list) {
    final List<FacilitySummaryNew> edited = <FacilitySummaryNew>[];
    final List<RimSummary> rims = list.rims ?? const <RimSummary>[];

    for (final RimSummary rim in rims) {
      final List<RimGroup> groups = rim.groups ?? const <RimGroup>[];
      for (final RimGroup grp in groups) {
        final List<FacilityDis> disList =
            grp.facilityLimits ?? const <FacilityDis>[];
        for (final FacilityDis dis in disList) {
          final FacilitySummaryNew? f = dis.facility;
          if (f?.isEdited ?? false) {
            edited.add(f!);
          }
        }
      }
    }
    return edited;
  }

  /// Fetches the list of customer facilities from the
  /// FacilitySecurityRepository.
  Future<void> getCurrencyRates(Reference? selectedCurrency) async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      await CurrencyRatesService().getRates();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  /// used for geting the updated list with newly created Facility types
  Future<void> getUpdatedFacilityReference() async {
    final String facilityTypeKey = isFIFlow
        ? ReferenceDataKeys.fiFacilityTypes
        : ReferenceDataKeys.facilityTypes;

    try {
      final List<ReferenceType> getReferenceData =
          await HomeRepository.instance.getReferenceData([facilityTypeKey]);

      facilityTypes = getReferenceData[0].references ?? [];
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Retrieves reference data for facility types and advance types.
  /// Populates the `limitTypes` and `subLimitTypes` lists.
  Future<void> getReferenceData() async {
    try {
      final String limitGroupKey = isFIFlow
          ? ReferenceDataKeys.fiLimitGroup
          : ReferenceDataKeys.limitGroup;
      final String limitTypeKey = isFIFlow
          ? ReferenceDataKeys.fiLimitType
          : ReferenceDataKeys.limitType;
      final Map<String, List<Reference>> referenceData =
          await referenceDataService.getReferenceData([
        limitTypeKey,
        ReferenceDataKeys.productType,
        ReferenceDataKeys.sustanabilityClassification,
        ReferenceDataKeys.period,
        ReferenceDataKeys.marginSign,
        ReferenceDataKeys.benchMark,
        limitGroupKey,
        ReferenceDataKeys.limitCapsType,
      ]);
      limitCapsType = referenceData[ReferenceDataKeys.limitCapsType] ?? [];
      limitGroup = referenceData[limitGroupKey] ?? [];

      limitTypes = referenceData[limitTypeKey] ?? [];
      benchmark = referenceData[ReferenceDataKeys.benchMark] ?? [];
      marginSign = referenceData[ReferenceDataKeys.marginSign] ?? [];
      sustanabilityClassifications =
          referenceData[ReferenceDataKeys.sustanabilityClassification] ?? [];
      period = referenceData[ReferenceDataKeys.period] ?? [];
      productTypeOptions =
          (referenceData[ReferenceDataKeys.productType] ?? [Reference()])
              .where((data) => data.id != ServerConstants.optionBothId)
              .toList();
      updateSelectedProductType();
    } on Object catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  /// Returns the display name for a facility 'limitDescription' ID using
  /// facilityTypes.
  /// Fallback: if not found or null, returns the raw id as string or empty.
  Reference facilityTypeNameById(Object? id) {
    if (id == null) {
      return Reference(name: id.toString());
    }
    final String target = id.toString().trim();
    final Reference matchedReference = facilityTypes.firstWhere(
      (r) => (r.id?.toString().trim() ?? "") == target,
      orElse: () => Reference(name: target),
    );

    return matchedReference;
  }

  /// Returns the display name for the specified limit caps type.
  ///
  /// Resolves a limit caps type identifier to its corresponding
  /// reference name. If no matching reference is found, the original
  /// identifier value is returned.
  String limitCapsTypeNameById(Object? id) {
    if (id == null) {
      return "";
    }

    final String target = id.toString().trim();

    final Reference match = limitCapsType.firstWhere(
      (r) => (r.id?.toString().trim() ?? "") == target,
      orElse: () => Reference(name: ""),
    );

    final String name = (match.name ?? "").trim();

    return name.isNotEmpty ? name : target;
  }

  /// Fetches the list of currency codes from the repository.
  Future<void> getCurrencyCodes() async {
    try {
      currencyCodes = await CurrencyRatesService().getCurrencies();
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Updates the selected product type option.
  ///
  /// Clears dependent limit type and facility description selections
  /// when the product type changes.
  void changeProductTypeOptions(Reference selectedValue) {
    final bool hasChanged = selectedProductTypeOption?.id != selectedValue.id;
    selectedProductTypeOption = selectedValue;
    facility.selectedProductTypeValue = selectedValue;
    if (hasChanged) {
      facility.facilityTypeSelectedValue = null;
      facilityDescriptions.clear();
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Loads facility descriptions for the selected limit group.
  ///
  /// Filters facility descriptions based on the selected limit type
  /// and applies configured exclusion rules.
  void selectLimittedGroup(Reference selectedValue) {
    facility.facilityTypeSelectedValue = selectedValue;
    facilityDescriptions.clear();
    final String selectedLimitTypeName =
        (selectedValue.reference1 ?? "").trim().toLowerCase();

    facilityTypes.where((e) {
      // Match LIMIT_TYPE.reference1  <->  facilityTypes.reference4
      final String groupInDesc = (e.reference4 ?? "").trim().toLowerCase();
      final bool sameGroup = groupInDesc == selectedLimitTypeName;

      // keep your original exclusions
      final String? idStr = e.id?.toString();
      final bool notExcluded =
          idStr == null || !_excludedLimitDescriptionIds.contains(idStr);

      // keep explicit 935 exclusion
      final bool not935 = (e.id != 935);

      return sameGroup && notExcluded && not935;
    }).forEach(facilityDescriptions.add);

    emit(state.copyWith(tableLoaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selected facility description.
  Future<void> facilityTypeDescriptionsSelected(
    Reference selectedValue,
  ) async {
    facility.facilityDescription = selectedValue;
    emit(state.copyWith(tableLoaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selected shared limit option.
  void selectSharedLimit(Reference selectedValue) {
    facility.sharedLimit = selectedValue;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selected sub-limit description.
  void addSelectedSubLimitDetails(Reference selectedValue) {
    selectedSubLimitDetails = selectedValue;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Returns the first item whose name matches the provided value.
  ///
  /// Falls back to the first item in the list when no match is found
  /// or when the provided name is empty.
  Reference matchOrFirstByName(
    List<Reference> list,
    String? name,
  ) {
    if (list.isEmpty) {
      return Reference(); // won't be used—just a guard
    }
    if ((name ?? "").isEmpty) {
      return list.first;
    }
    final String lower = name!.trim().toLowerCase();
    return list.firstWhere(
      (r) => (r.name ?? "").trim().toLowerCase() == lower,
      orElse: () => currencyCodes.first,
    );
  }

  /// Returns the first item whose identifier matches the provided value.
  ///
  /// Falls back to the configured default item when no match is found.
  Reference matchOrFirstById(
    List<Reference> list,
    String? id,
  ) {
    if (list.isEmpty) {
      return Reference();
    }

    final String target = id.toString();
    return list.firstWhere(
      (r) => r.id?.toString() == target,
      orElse: () => benchmark.first,
    );
  }

  /// Returns all references whose identifiers exist in the provided
  /// list of identifiers.
  List<Reference> returnListItemsbasedOnID(
    List<Reference> list,
    List<String?> ids,
  ) {
    if (list.isEmpty) {
      return <Reference>[];
    }

    final List<String> targetIds = ids.whereType<String>().toList();
    return list.where((r) => targetIds.contains(r.id?.toString())).toList();
  }

  /// Returns the first item whose reference1 value matches the
  /// provided value.
  ///
  /// Falls back to the first item in the list when no match is found
  /// or when the provided value is empty.
  Reference matchOrFirstByRef1(
    List<Reference> list,
    String? ref1,
  ) {
    if (list.isEmpty) {
      return Reference(); // e.g., default to "+" if marginSign list
    }
    if ((ref1 ?? "").isEmpty) {
      return list.first;
    }
    final String lower = ref1!.trim().toLowerCase();
    return list.firstWhere(
      (r) => (r.reference1 ?? "").trim().toLowerCase() == lower,
      orElse: () => marginSign.first,
    );
  }

  /// Extracts the RIM number from the provided RIM display string.
  ///
  /// Supports values containing RIM numbers inside parentheses as well
  /// as strings containing standalone numeric values.
  ///
  /// Returns `null` when no valid RIM number can be identified.
  int? extractRimId(String? rimName) {
    if (rimName == null) {
      return null;
    }
    final Iterable<RegExpMatch> parenMatches =
        RegExp(r"\(\s*(\d+)\s*\)").allMatches(rimName);
    if (parenMatches.isNotEmpty) {
      final String? digits = parenMatches.last.group(1);
      return int.tryParse(digits ?? "");
    }
    final String? firstNumber = RegExp(r"\d+").firstMatch(rimName)?.group(0);
    return int.tryParse(firstNumber ?? "");
  }

  /// Preloads Project group header (“order == 0”) values from API into local
  /// caches.
  ///
  /// Why:
  /// - Project Standby/Specific use a header row as controlling cap (proposed limit + currency + name).
  /// - UI and routing decisions rely on this cached header state (dirty-check,
  /// cap validation).
  /// What it stores (per groupId + rimNo):
  /// - FacilityId of header row
  /// - Proposed limit from API
  /// - Currency from API
  /// - Project name from API
  /// - Initializes header currency dropdown when missing
  void preloadHeaderProposedLimitsFromApi() {
    final List<FacilitySummaryList> summaries =
        customerFacilities ?? const <FacilitySummaryList>[];

    for (final FacilitySummaryList summary in summaries) {
      for (final RimSummary rim in summary.rims ?? const <RimSummary>[]) {
        for (final RimGroup group in rim.groups ?? const <RimGroup>[]) {
          for (final FacilityDis dis
              in group.facilityLimits ?? const <FacilityDis>[]) {
            final FacilitySummaryNew? facility = dis.facility;
            if (facility == null) {
              continue;
            }

            final int? gid = facility.limitGroup;
            final int? rimNo = facility.rimNo;
            if (gid == null || rimNo == null) {
              continue;
            }

            // Only for project groups OR you can keep for all
            if (gid != groupStandBy && gid != groupSpecific) {
              continue;
            }

            // Capture HEADER row only (order == '0') and skip excluded
            // facilities
            if ((dis.order ?? "").trim() == "0" &&
                !isExcludedFacility(facility)) {
              final String key = groupRimKey(gid, rimNo);

              // Existing behavior: ensure proposed is set for validation
              // Use the AED-converted amount (not the raw proposedLimit,
              // which is in the header's own currency) since this cap flows
              // into new-facility prefills that are expected to be AED.
              final int? apiProp = facility.proposedLimitAED?.round();
              if (apiProp != null) {
                _projectProposedByKey.putIfAbsent(key, () => apiProp);
              }

              // NEW snapshots for dirty detection + update payload
              _headerFacilityIdByKey[key] = facility.facilityId;
              _headerMasterFacilityIdByKey[key] = facility.facilityMasterId;
              _headerProposedApiByKey[key] = facility.proposedLimitAED;
              _headerCurrencyApiByKey[key] =
                  (facility.currency ?? ServerConstants.aedCurrency).trim();
              _headerNameApiByKey[key] = (facility.projectName ?? "").trim();

              // also initialize header currency dropdown state (only if empty)
              if (headerCurrencyFor(gid, rimNo) == null) {
                final Reference ref = matchOrFirstByName(
                  currencyCodes,
                  facility.currency ?? ServerConstants.aedCurrency,
                );
                headerCurrencyByKey[key] = ref;
              }
            }
          }
        }
      }
    }
  }

  /// Returns the matching tenor unit reference for the provided value.
  ///
  /// Attempts to match by:
  /// - Reference name
  /// - Reference `reference1` value
  /// - Reference identifier
  ///
  /// Falls back to the first available tenor period option when no
  /// match is found.
  Reference matchPeriodByAny(
    List<Reference> list,
    String? unit,
  ) {
    if (list.isEmpty) {
      return period.first;
    }
    final target = normalizeTenorUnit(unit);

    // First: exact normalized name match
    for (final r in list) {
      final n = normalizeTenorUnit(r.name);
      if (n == target) {
        return r;
      }
    }

    // Next: try reference1 if it carries abbreviations like D/M/Y/OD
    for (final r in list) {
      final ref1 = normalizeTenorUnit(r.reference1);
      if (ref1 == target) {
        return r;
      }
    }

    // Next: try id if server sends an id and you mapped it to a name
    for (final r in list) {
      if ((r.id?.toString() ?? "").trim() == (unit ?? "").trim()) {
        return r;
      }
    }

    // Fallback to the first item
    return period.first;
  }

  /// Normalizes tenor unit values into a standard display format.
  ///
  /// Handles common API variations such as:
  /// - Day, Days, D
  /// - Month, Months, M
  /// - Year, Years, Y, Yr
  /// - On Demand variants
  ///
  /// Returns a normalized value suitable for comparison and display.
  String normalizeTenorUnit(String? raw) {
    if (raw == null) {
      return "";
    }
    final s = raw.trim().toLowerCase();

    // Collapse spaces/hyphens/underscores
    final compact = s.replaceAll(RegExp(r"[\s\-_]+"), "");

    // Accept many variants from API: names, abbreviations, single/plural
    if (compact == "d" || compact == "day" || compact == "days") {
      return "Days";
    }
    if (compact == "m" || compact == "month" || compact == "months") {
      return "Months";
    }
    if (compact == "y" ||
        compact == "yr" ||
        compact == "year" ||
        compact == "years") {
      return "Years";
    }

    if (compact == "ondemand" ||
        compact == "on_demand" ||
        compact == "on-demand") {
      return "On Demand";
    }

    // Fallback: title-case original string
    return raw.isEmpty ? "" : raw[0].toUpperCase() + raw.substring(1);
  }

  /// Sets facility.productCodeProject from limitGroup reference3 for project
  /// groups
  void prepareProjectProductCode(int? groupId) {
    if (!isProjectGroup(groupId)) {
      return;
    }

    final Reference lg = limitGroup.firstWhere(
      (r) => r.id == groupId,
      orElse: Reference.new,
    );

    facility.productCodeProject = (lg.reference3 ?? "").trim().toUpperCase();
  }

  /// Single entry-point used by UI for both create + update of header
  Future<bool> saveOrUpdateProjectHeader({
    required int? rimNo,
    required int? groupId,
    required Reference? descSnapshot,
    int? facilityId,
    int? limitCaptype,
    int? facilityMasterID,
  }) async {
    if (groupId == null) {
      return false;
    }

    // keep behavior identical to UI: only set product code for 11315/11317
    prepareProjectProductCode(groupId);

    return saveFacilityProject(
      navigateToHomePage: false,
      rimNo,
      groupId,
      descSnapshot,
      facilityId: facilityId,
      limitCaptype: limitCaptype,
      facilityMasterID: facilityMasterID,
    );
  }

  ///for project standby and specific main limit creation call this api when new
  ///creating facility
  /// only for first time if no limit prrsent in table
  Future<bool> saveFacilityProject(
    int? selectedRim,
    int? limitGroup,
    Reference? facilityDescription, {
    required bool navigateToHomePage,
    int? facilityId,
    int? limitCaptype,
    int? facilityMasterID,
  }) async {
    try {
      facility.appRefNo = Globals.request?.applicationRefNo;
      final LimitsFacilityResponse resp =
          await facilitySecurityRepository.saveFacilityProject(
        facilityDetails: _buildeFacilityProject(
          selectedRim,
          limitGroup,
          facilityDescription,
          facilityId: facilityId,
          limitCaptype: limitCaptype,
          facilityMasterID: facilityMasterID,
        ),
      );
      facility.limitNumber =
          resp.facilityDetails?.limitNo ?? facility.limitNumber;
      await getFacilitySummaryListFromLinakge();
      await getFacilitySummaryListPerRim();

      AlertManager().showSuccessToast(
        "facilities.facilitySummary.savedSuccessfully".tr(),
      );
      return true;
    } on Object catch (message) {
      AlertManager().showFailureToast(message.toString());
      return false;
    }
  }

  FacilityDetails _buildeFacilityProject(
    int? selectedRim,
    int? limitGroup,
    Reference? facilityDescription, {
    int? facilityId,
    int? limitCaptype,
    int? facilityMasterID,
  }) {
    final int selectedGroupId =
        _numOr(limitGroup, groupStandBy).toInt(); // default fallback to 11315

    final int rim = _numOr(selectedRim, 0).toInt();

    //  Resolve existing header limitNo from summary (UPDATE only)
    final String? existingLimitNo = (facilityId != null)
        ? headerLimitNumberForGroupAtRim(selectedGroupId, rim)
        : null;

    final String appRef =
        _strOr(Globals.request?.applicationRefNo, ""); // “appRefNo”
    final int grp = _numOr(Globals.request?.groupId, 0).toInt(); // “groupId”

    String? product;
    if (limitGroup == groupSpecific || limitGroup == groupStandBy) {
      product = facility.productCodeProject?.trim().toUpperCase();
    } else {
      product = facilityDescription?.reference3?.toString();
    }
    const String limitCategory = " ";
    const String islamic = ""; // “forIslamic”
    final num limitDesc = _numOr(
      (facility.facilityDescription?.id is num)
          ? (facility.facilityDescription?.id as num?)
          : num.tryParse(facility.facilityDescription?.id?.toString() ?? ""),
      25,
    ); // “limitDescription”
    final num presentOutstanding =
        int.tryParse(facility.presentOutstandingCCValue?.description ?? "") ??
            (facilityDetail.isNotEmpty
                ? (facilityDetail.first.presentOutstanding ?? 0)
                : 0);

    // Existing limit from header (group+rim)
    final int presentLimit =
        _projectExistingByKey[groupRimKey(selectedGroupId, rim)]?.toInt() ??
            (int.tryParse(facility.limitAmount?.description ?? "") ??
                (facilityDetail.isNotEmpty
                    ? (facilityDetail.first.presentLimit ?? 0)
                    : 0));

    // Currency from header dropdown (stored in headerCurrencyByKey via
    // setHeaderCurrencyFor; fall back to facility.proposedLimitValue for
    // backward-compat, then to "AED" as the final default).
    final String currency = _strOr(
      headerCurrencyFor(selectedGroupId, rim)?.name ??
          facility.proposedLimitValue?.name,
      ServerConstants.aedCurrency,
    ); // "currency"

    // Proposed limit from header (group+rim)
    final int proposedLimit =
        _projectProposedByKey[groupRimKey(selectedGroupId, rim)]?.toInt() ??
            _numOr(facility.proposedLimit, 0).toInt();

    // Project Name from header text field (use group-specific controller)
    final bool isStandby = (selectedGroupId == groupStandBy);
    final String projectName = _strOr(
      isStandby ? standbyNameCtrl(rim).text : psNameCtrl(rim).text,
      "",
    );

    final bool isMain = _boolOr(true, true); // “isMainLimit”
    final String groupName =
        _strOr(facilityDescription?.name, ""); // “limitGroupName”

    final int group = selectedGroupId; // “limitGroup”

    return FacilityDetails(
      facilityId: facilityId,
      facilityMasterId: facilityMasterID,
      limitNo: existingLimitNo,
      groupOwner: Globals.request?.groupOwner,
      rimNo: rim,
      groupId: grp,
      productCode: product,
      limitCategory: limitCategory,
      appRefNo: appRef,
      forIslamic: islamic,
      limitCapType: isFIFlow ? null : limitCaptype,
      limitDescription: limitDesc,
      presentOutstanding: presentOutstanding,
      currency: currency,
      isSharedLimit: false,
      presentLimit: presentLimit,
      proposedLimit: proposedLimit,
      proposedLimitAED: proposedLimit,
      projectName: projectName,
      isMainLimit: isMain,
      limitGroupName: groupName,
      limitGroup: group,
    );
  }

  /// Call the create-project API only when the target group has NO data at all:
  /// - NO header row (order == '0')
  /// - NO detail rows (order != '0')
  bool shouldCallProjectApiForGroup(int? groupId) {
    if (customerFacilities == null || groupId == null) {
      return true; // safest default
    }

    for (final FacilitySummaryList summary in customerFacilities!) {
      for (final RimSummary rim in summary.rims ?? const <RimSummary>[]) {
        for (final RimGroup grp in rim.groups ?? const <RimGroup>[]) {
          for (final FacilityDis dis
              in grp.facilityLimits ?? const <FacilityDis>[]) {
            final FacilitySummaryNew? fac = dis.facility;
            if ((fac?.limitGroup ?? -1) != groupId) {
              continue;
            }

            final String? order = dis.order?.trim(); //s.no

            // Consider ONLY non-excluded rows as "data present"
            if (order == "0") {
              if (!isExcludedFacility(fac)) {
                return false; // valid header exists
              }
            } else if (order != null && order != "0") {
              if (!isExcludedFacility(fac)) {
                return false; // valid detail exists
              }
            }
          }
        }
      }
    }
    // No records for this group in API -> first time -> allow API call once
    return true;
  }

  /// Returns the limit cap type identifier for the specified limit group.
  ///
  /// Maps project-related limit groups to their corresponding limit cap
  /// types. Returns `null` for Financial Institution flows.
  int? limitCapTypeForGroup(int? groupId) {
    if (isFIFlow) {
      return null;
    }

    if (groupId == ServerConstants.projectStandByLimitID) {
      return 14493; // Project Standby Limits
    }

    if (groupId == ServerConstants.projectSpecificLimitsID) {
      return 14494; // Project Specific Limits
    }

    return 14492;
  }

  /// True if API has any non-header rows (order != '0') for the group.
  bool hasDetailRowsForGroup(int? groupId) {
    if (customerFacilities == null || groupId == null) {
      return false;
    }
    for (final FacilitySummaryList summary in customerFacilities!) {
      for (final RimSummary rim in summary.rims ?? const <RimSummary>[]) {
        for (final RimGroup grp in rim.groups ?? const <RimGroup>[]) {
          for (final FacilityDis dis
              in (grp.facilityLimits ?? const <FacilityDis>[])) {
            final FacilitySummaryNew? fac = dis.facility;
            if ((fac?.limitGroup ?? -1) != groupId) {
              continue;
            }
            final String? ord = dis.order?.trim(); // detail exists
            // Count detail rows ONLY if they are real facilities
            if (ord != null && ord != "0" && !isExcludedFacility(fac)) {
              return true;
            }
            // if (ord != null && ord != '0') return true; // detail exists
          }
        }
      }
    }
    return false;
  }

  /// Returns the header (order == '0') controlling limit number for the group.
  /// Uses `facility.limitNo` from the API model.
  String? headerLimitNumberForGroup(int? groupId) {
    if (customerFacilities == null || groupId == null) {
      return null;
    }
    for (final FacilitySummaryList summary in customerFacilities!) {
      for (final RimSummary rim in summary.rims ?? const <RimSummary>[]) {
        for (final RimGroup grp in rim.groups ?? const <RimGroup>[]) {
          for (final FacilityDis dis
              in (grp.facilityLimits ?? const <FacilityDis>[])) {
            final FacilitySummaryNew? fac = dis.facility;
            if ((fac?.limitGroup ?? -1) != groupId) {
              continue;
            }
            if (dis.order?.trim() == "0") {
              // Skip headers that are not real facilities (CLT / 935)
              if (isExcludedFacility(fac)) {
                continue;
              }
              return fac?.limitNo; // prefer API header `limitNo`
            }
          }
        }
      }
    }
    return null;
  }

  /// Returns the header (order == '0') controlling limit number *for this rim
  /// and group*.
  String? headerLimitNumberForGroupAtRim(int? groupId, int? rimNo) {
    if (customerFacilities == null || groupId == null || rimNo == null) {
      return null;
    }
    for (final FacilitySummaryList summary in customerFacilities!) {
      for (final RimSummary rim in summary.rims ?? const <RimSummary>[]) {
        // Prefer a rimNo check if model exposes it on the facility; otherwise
        // fallback to extractRimId(rim.rimName)
        final int? rimFromName = extractRimId(rim.rimName);
        if (rimFromName != rimNo) {
          continue;
        }

        for (final RimGroup grp in rim.groups ?? const <RimGroup>[]) {
          for (final FacilityDis dis
              in grp.facilityLimits ?? const <FacilityDis>[]) {
            final FacilitySummaryNew? fac = dis.facility;
            if ((fac?.limitGroup ?? -1) != groupId) {
              continue;
            }

            // Only header row
            if ((dis.order ?? "").trim() == "0") {
              // Skip excluded headers (CLT/935)
              final String? ld = fac?.limitDescription?.toString();
              final String pc = (fac?.productCode ?? "").trim().toUpperCase();
              final bool isExcluded = (ld == "935") || (pc == "CLT");
              if (!isExcluded) {
                return fac?.limitNo;
              }
            }
          }
        }
      }
    }
    return null;
  }

  /// True if this rim/group has any *detail* rows (order != '0').
  bool hasDetailRowsForGroupAtRim(int? groupId, int? rimNo) {
    if (customerFacilities == null || groupId == null || rimNo == null) {
      return false;
    }
    for (final FacilitySummaryList summary in customerFacilities!) {
      for (final RimSummary rim in summary.rims ?? const <RimSummary>[]) {
        final int? rimFromName = extractRimId(rim.rimName);
        if (rimFromName != rimNo) {
          continue;
        }

        for (final RimGroup grp in rim.groups ?? const <RimGroup>[]) {
          for (final FacilityDis dis
              in grp.facilityLimits ?? const <FacilityDis>[]) {
            final FacilitySummaryNew? fac = dis.facility;
            if ((fac?.limitGroup ?? -1) != groupId) {
              continue;
            }

            final String? ord = dis.order?.trim();
            // Count detail rows ONLY if they are real facilities (not CLT/935)
            final String? ld = fac?.limitDescription?.toString();
            final String pc = (fac?.productCode ?? "").trim().toUpperCase();
            final bool isExcluded = (ld == "935") || (pc == "CLT");

            if (ord != null && ord != "0" && !isExcluded) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  /// Returns the first rim (matches current UI behavior everywhere).
  RimSummary? firstRimOfCustomer(FacilitySummaryList customer) {
    return (customer.rims?.isNotEmpty ?? false) ? customer.rims!.first : null;
  }

  /// Safe access to group by index.
  RimGroup? groupByIndex(RimSummary? rim, int? groupIndex) {
    final List<RimGroup> groups = rim?.groups ?? const <RimGroup>[];
    if (groupIndex == null || groupIndex < 0 || groupIndex >= groups.length) {
      return null;
    }
    return groups[groupIndex];
  }

  /// Prefer rimNo from API model; fallback to rimName parsing only if
  /// necessary.
  int? resolveRimNo(RimSummary? rim) {
    return rim?.rimNo ?? extractRimId(rim?.rimName);
  }

  /// Returns true if group contains at least one row after excluding Limit Caps
  /// and CLT rows.
  bool hasNonExcludedRows(RimGroup? group) {
    final List<FacilityDis> list =
        group?.facilityLimits ?? const <FacilityDis>[];
    return list.any((dis) => !isExcludedFacility(dis.facility));
  }

  /// Returns filtered and order-sorted facilities for a group.
  /// IMPORTANT: keeps the exact legacy filter:
  /// excludes Limit Caps (limitDescription == 935) and CLT product rows.
  /// This preserves the previous UI behavior and totals logic
  List<FacilityDis> filteredSortedDisList(RimGroup? group) {
    final List<FacilityDis> list =
        List<FacilityDis>.from(group?.facilityLimits ?? const <FacilityDis>[]);
    final List<FacilityDis> filtered = list
        .where(
          (dis) => dis.facility != null && !isExcludedFacility(dis.facility),
        )
        .toList()
      ..sort((a, b) => (a.order ?? "").compareTo(b.order ?? ""));
    return filtered;
  }

  // ---------------------------------------------------------------------------
  // Table column filters
  //
  // Each table on the screen filters independently, so filter values are held
  // per "scope key": group tables use [groupFilterKey], Limit Caps uses
  // [limitCapsFilterKey] because it spans every group of a RIM.
  // ---------------------------------------------------------------------------

  /// Active column filters, keyed by table scope then by column.
  final Map<String, Map<FacilityFilterField, String>> _facilityFilters = {};

  /// Scope key for the table of one limit group on one RIM.
  String groupFilterKey(int? groupId, int? rimNo) =>
      "group-${groupId ?? ''}-${rimNo ?? ''}";

  /// Scope key for the Limit Caps table, which spans all groups of a RIM.
  String limitCapsFilterKey(int? rimNo) => "limitCaps-${rimNo ?? ''}";

  /// Current filter text for [field] in the table identified by [scopeKey].
  String facilityFilterValue(String scopeKey, FacilityFilterField field) {
    return _facilityFilters[scopeKey]?[field] ?? "";
  }

  /// Applies (or clears, when [value] is blank) a column filter and refreshes.
  void onFacilityFilterChanged(
    String scopeKey,
    FacilityFilterField field,
    String value,
  ) {
    final String trimmed = value.trim();
    final Map<FacilityFilterField, String> filters =
        _facilityFilters.putIfAbsent(scopeKey, () => {});

    if (trimmed.isEmpty) {
      filters.remove(field);
    } else {
      filters[field] = trimmed;
    }

    if (filters.isEmpty) {
      _facilityFilters.remove(scopeKey);
    }

    emit(state.copyWith());
  }

  /// Stable representation of the active filters for [scopeKey].
  ///
  /// Tables that keep a stable widget key fold this into that key so the
  /// underlying table rebuilds when — and only when — the filters change.
  String facilityFilterSignature(String scopeKey) {
    final Map<FacilityFilterField, String> filters =
        _facilityFilters[scopeKey] ?? const {};
    if (filters.isEmpty) {
      return "";
    }

    final List<String> parts = FacilityFilterField.values
        .where(filters.containsKey)
        .map((field) => "${field.name}=${filters[field]}")
        .toList();

    return parts.join("&");
  }

  /// Clears the filters of one table, or of every table when [scopeKey] is
  /// omitted. Called on reload so stale filters cannot hide refreshed rows.
  void clearFacilityFilters([String? scopeKey]) {
    if (scopeKey == null) {
      _facilityFilters.clear();
    } else {
      _facilityFilters.remove(scopeKey);
    }
  }

  /// Narrows [rows] to those matching every active filter of [scopeKey].
  ///
  /// Matching is case-insensitive "contains" against the text shown in the
  /// column. Returns [rows] unchanged when no filter is active.
  List<FacilityDis> applyFacilityFilters(
    String scopeKey,
    List<FacilityDis> rows,
  ) {
    final Map<FacilityFilterField, String> filters =
        _facilityFilters[scopeKey] ?? const {};
    if (filters.isEmpty) {
      return rows;
    }

    return rows.where((dis) {
      final FacilitySummaryNew? facility = dis.facility;
      if (facility == null) {
        return false;
      }

      return filters.entries.every((entry) {
        final String cellValue =
            _facilityFieldValue(facility, entry.key).toLowerCase();
        return cellValue.contains(entry.value.toLowerCase());
      });
    }).toList();
  }

  /// Resolves the text displayed for [field] on [facility].
  String _facilityFieldValue(
    FacilitySummaryNew facility,
    FacilityFilterField field,
  ) {
    switch (field) {
      case FacilityFilterField.limitNo:
        return facility.limitNo ?? "";
      case FacilityFilterField.controllingLimitNo:
        return facility.controllingLimitNo ?? "";
      case FacilityFilterField.limitDescription:
        return facilityTypeNameById(facility.limitDescription).name ?? "";
      case FacilityFilterField.projectName:
        return facility.projectName ?? "";
      case FacilityFilterField.limitCapType:
        return limitCapsTypeNameById(facility.limitCapType);
    }
  }

  /// Footer totals using the SAME rule used in your current tables:
  /// add totals only for rows where facility.isMainLimit ?? false.
  GroupAmounts computeGroupTotals(List<FacilityDis> disList) {
    int totalExisting = 0;
    int totalProposed = 0;
    int totalOutstanding = 0;

    for (final FacilityDis dis in disList) {
      final FacilitySummaryNew? facility = dis.facility;
      if (facility == null) {
        continue;
      }

      if (facility.isMainLimit ?? false) {
        totalExisting += (facility.presentLimit ?? 0).toInt();
        totalProposed += facility.proposedLimit ?? 0;
        totalOutstanding += (facility.presentOutstanding ?? 0).toInt();
      }
    }

    return GroupAmounts(
      totalExistingLimit: totalExisting,
      totalProposedLimit: totalProposed,
      totalCurrentOutstanding: totalOutstanding,
    );
  }

  /// Resolves parent cap from controlling limit number within same list.
  /// Keeps current behavior used in tables.
  int? resolveParentCap(String? controllingLimitNo, List<FacilityDis> disList) {
    final String cln = (controllingLimitNo ?? "").trim();
    if (cln.isEmpty) {
      return null;
    }

    final FacilitySummaryNew? parent = disList
        .map((d) => d.facility)
        .whereType<FacilitySummaryNew>()
        .cast<FacilitySummaryNew?>()
        .firstWhere(
          (p) => (p?.limitNo ?? "").trim() == cln,
          orElse: () => null,
        );

    return parent?.proposedLimit;
  }

  /// Converts stored “11318, 11319” into References (same logic repeated now in
  /// tables).
  List<Reference> sustainabilityRefs(String? csv) {
    final String raw = (csv ?? "").trim();
    if (raw.isEmpty) {
      return <Reference>[];
    }

    final Set<String> ids =
        raw.split(",").map((s) => s.trim()).where((s) => s.isNotEmpty).toSet();

    return sustanabilityClassifications
        .where((r) => ids.contains(r.id?.toString()))
        .toList();
  }

  /// Handles the Facility Summary "Limit Caps" action.
  ///
  /// Corporate flow:
  /// - If any caps rows exist (limitDescription==935 OR productCode==CLT),
  ///   open the LimitCapsSummary dialog for the first matching customer/group.
  /// - Otherwise, route to Create Facility with Limit Caps prefilled.
  ///
  /// Note: This method preserves the existing detection logic and routing
  /// behavior.
  Future<void> handleLimitCapsPressed(BuildContext context) async {
    final List<FacilitySummaryList> customers =
        customerFacilities ?? const <FacilitySummaryList>[];
    if (customers.isEmpty) {
      return;
    }

    bool matchesCap(FacilitySummaryNew? facility) {
      if (facility == null) {
        return false;
      }
      final bool is935 = (facility.limitDescription?.toString() == "935");
      final bool isCLT =
          ((facility.productCode ?? "").trim().toUpperCase() == "CLT");
      return is935 || isCLT;
    }

    FacilitySummaryList? matchCustomer;
    int? matchGroupIndex;

    outer:
    for (final FacilitySummaryList cust in customers) {
      for (final RimSummary rim in (cust.rims ?? const <RimSummary>[])) {
        final List<RimGroup> groups = rim.groups ?? const <RimGroup>[];
        for (int gi = 0; gi < groups.length; gi++) {
          final RimGroup g = groups[gi];
          final List<FacilityDis> limits =
              g.facilityLimits ?? const <FacilityDis>[];
          if (limits.any((dis) => matchesCap(dis.facility))) {
            matchCustomer = cust;
            matchGroupIndex = gi;
            break outer;
          }
        }
      }
    }

    if (matchCustomer != null) {
      await DialogHelper.showCustomDialog(
        title: "facilities.facilitySummary.limitCaps".tr(),
        width: Scale.scaleHorizontally(650.w),
        content: BlocProvider.value(
          value: this,
          child: LimitCapsSummary(
            viewModel: this,
            customer: matchCustomer,
            groupIndex: matchGroupIndex ?? 0,
          ),
        ),
        context: context,
      );
      return;
    }

    // No caps exist -> create prefilled Limit Caps facility
    final Reference limitCapsRef = matchOrFirstById(
      facilityTypes,
      935.toString(),
    );

    final int? rimNo = Utils.isGroupApplication()
        ? Globals.request?.groupOwner
        : resolveRimNoFromApi();

    if (rimNo == null || rimNo == 0 || !canEdit) {
      return;
    }

    router.go(
      Routes.createFacility,
      extra: {
        "facilityArgs": CreateFacilityArgs(
          facility: Facility(
            facilityDescription: limitCapsRef,
            limitDescription: limitCapsRef.name,
            limitCode: limitCapsRef.id,
            limitGroup: ServerConstants.generalLimitGroupId,
            rimNo: rimNo,
            selectedProductTypeValue: facility.selectedProductTypeValue,
            isMainLimit: true,
          ),
          showCreateFacilityForm: true,
        ),
        "pageMode": amendPagemode,
      },
    );
  }

  /// Finds the index of a RimGroup by groupName (case-insensitive).
  /// Returns null if not found.
  int? findGroupIndexByName(RimSummary? rim, String name) {
    if (rim == null) {
      return null;
    }
    final List<RimGroup> groups = rim.groups ?? const <RimGroup>[];
    final int idx = groups.indexWhere(
      (g) =>
          (g.groupName ?? "").trim().toLowerCase() == name.trim().toLowerCase(),
    );
    return idx >= 0 ? idx : null;
  }

  /// Requests project list for a project group (11315/11317) safely after
  /// build.
  /// Uses internal cache keys so it won't refetch repeatedly.
  void scheduleProjectListFetchIfNeeded(int? groupId, int? rimNo) {
    if (groupId == null || rimNo == null) {
      return;
    }
    if (groupId != ServerConstants.projectSpecificLimitsID &&
        groupId != ServerConstants.projectStandByLimitID) {
      return;
    }

// postFrameCallback is not needed here because the method is already called after build in the UI

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    getProjectList(groupId, rimNo);
    // });
  }

  /// Returns benchmark/index items filtered by facility limit category (F or N).
  ///
  /// Benchmark reference data uses `reference2` to indicate which limit
  /// category the item applies to.
  /// - 'F' => Funded / financial-type
  /// - 'N' => Non-funded / commission-type
  ///
  /// If `limitCategory` is null/empty or filtering produces no results, returns the full benchmark list.
  List<Reference> benchmarkForLimitCategory(String? limitCategory) {
    final String category = (limitCategory ?? " ").trim().toUpperCase();
    if (category.isEmpty) {
      return benchmark;
    }

    final List<Reference> filtered = benchmark
        .where((r) => (r.reference2 ?? "").trim().toUpperCase() == category)
        .toList();

    return filtered.isNotEmpty ? filtered : benchmark;
  }

  /// Like `matchOrFirstById`, but safely falls back to `items.first` (so
  /// selected item always exists in dropdown).
  Reference matchOrFirstByIdInList(List<Reference> items, String? id) {
    if (items.isEmpty) {
      return Reference();
    }

    final String target = id ?? "";
    return items.firstWhere(
      (r) => r.id?.toString() == target,
      orElse: () => items.first,
    );
  }

  String _strOr(String? value, String fallback) {
    final String? val = value?.trim();
    return (val == null || val.isEmpty) ? fallback : val;
  }

  num _numOr(num? value, num fallback) => value ?? fallback;

  bool _boolOr(bool? value, bool fallback) => value ?? fallback;

  /// -------------------------------
  /// Row helpers summary table(general working capital,term loans,PFE limits)
  /// -------------------------------

  /// Returns whether the facility belongs to the funded limit category.
  bool isFundedRow(FacilitySummaryNew f) =>
      (f.limitCategory ?? "").trim().toUpperCase() == "F";

  /// Returns whether benchmark index selection is mandatory for the
  /// specified facility.
  bool requireIndexForRow(FacilitySummaryNew f) {
    return facilityTypeNameById(f.limitDescription).reference5 !=
            ServerConstants.newProductCode &&
        isFundedRow(f);
  }

  /// Returns the benchmark options applicable to the specified facility.
  List<Reference> benchmarkItemsForRow(FacilitySummaryNew f) =>
      benchmarkForLimitCategory(f.limitCategory);

  /// Returns the selected benchmark reference for the specified facility.
  ///
  /// Matches the facility index value against the available benchmark
  /// options and returns the corresponding selection, if available.
  Reference? selectedBenchmarkForRow(
    FacilitySummaryNew f,
    List<Reference> items,
  ) {
    final String selectedIndexId = (f.index ?? "").trim();
    if (selectedIndexId.isEmpty || items.isEmpty) {
      return null;
    }

    for (final Reference option in items) {
      final String optionId = (option.id?.toString() ?? "").trim();
      if (optionId == selectedIndexId) {
        return option;
      }
    }
    return null;
  }

// -------------------------------
// Row actions for facility sumary table inside CustomAccordian (General working capital,term loans,Pfe limits )
// -------------------------------

  /// Updates the selected currency for the row's **Proposed Limit** field.
  ///
  /// This method is triggered when the user changes the currency dropdown
  /// shown next to the Proposed Limit input.
  ///
  /// What it does:
  /// - Takes the first selected dropdown value (single-select behavior)
  /// - Stores its `name` into `facilitySummary.currency`
  /// - Marks the row as edited (`isEdited = true`)
  /// - Keeps the screen-level `facility.proposedLimitValue` in sync
  ///   with the row selection (existing behavior used elsewhere)
  /// - Refreshes the conversion tooltip because the displayed AED equivalent
  ///   may change when currency changes
  ///
  /// Why this matters:
  /// The tooltip for Proposed Limit can show:
  /// - the previous/original value
  /// - the current converted AED value
  ///
  /// If no currency is selected, this method exits without making changes.
  void onProposedCurrencySelected(
    FacilitySummaryNew facilitySummary,
    List<Reference> selectedCurrencies,
  ) {
    if (selectedCurrencies.isEmpty) {
      return;
    }

    final Reference selectedCurrency = selectedCurrencies.first;

    facilitySummary
      ..currency = selectedCurrency.name
      ..isEdited = true;

    facility.proposedLimitValue = selectedCurrency;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the numeric value of the row's **Proposed Limit** field.
  ///
  /// This method is called whenever the user types inside the Proposed Limit input.
  ///
  /// What it does:
  /// - Removes all non-digit characters from the entered text
  /// - Converts the cleaned value into an integer
  /// - Stores that value in:
  ///   - `facilitySummary.proposedLimit`
  ///   - `facilitySummary.proposedLimitAED`
  /// - Marks the row as edited
  /// - Refreshes the tooltip so converted values can be recalculated
  void onProposedLimitChanged(
    FacilitySummaryNew facilitySummary,
    String enteredValue,
  ) {
    final String numericOnlyValue =
        enteredValue.replaceAll(RegExp("[^0-9]"), "");

    facilitySummary
      ..proposedLimit =
          numericOnlyValue.isEmpty ? 0 : int.parse(numericOnlyValue)
      ..proposedLimitAED =
          numericOnlyValue.isEmpty ? 0 : int.tryParse(numericOnlyValue)
      ..isEdited = true;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the row's **Sustainability Classification** field.
  ///
  /// The UI allows multiple sustainability values to be selected.
  /// Each selected item has an `id`, and the backend expects those ids
  /// to be stored as a comma-separated string.
  /// What this method does:
  /// - Extracts valid ids from selected references
  /// - Converts them into a comma-separated string
  /// - Saves the string into `facilitySummary.sustainabilityClassification`
  /// - Marks the row as edi
  void onSustainabilitySelected(
    FacilitySummaryNew facilitySummary,
    List<Reference> selectedClassifications,
  ) {
    final List<String> selectedClassificationIds = selectedClassifications
        .map((reference) => reference.id?.toString())
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toList();

    facilitySummary
      ..sustainabilityClassification = selectedClassificationIds.join(", ")
      ..isEdited = true;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the **Tenor Unit** for the selected facility row.
  ///
  /// This method is called when the user selects a unit like:
  /// - Days
  /// - Months
  /// - Years
  ///
  /// What it does:
  /// - Takes the first selected dropdown item
  /// - Stores its `name` in `facilitySummary.tenorUnit`
  /// - Marks the row as edited
  ///
  /// If no selection exists, nothing is changed.
  void onTenorUnitSelected(
    FacilitySummaryNew facilitySummary,
    List<Reference> selectedTenorUnits,
  ) {
    if (selectedTenorUnits.isEmpty) {
      return;
    }
    final Reference selectedTenorUnit = selectedTenorUnits.first;

    facilitySummary
      ..tenorUnit = selectedTenorUnit.name
      ..isEdited = true;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the numeric **Tenor Value** for the selected facility row.
  ///
  /// This method is called whenever the user types into the tenor value textbox.
  ///
  /// What it does:
  /// - Extracts the first numeric sequence from the input
  /// - Converts that numeric portion into an integer
  /// - Saves it to `facilitySummary.tenorValue`
  /// - Marks the row as edited
  ///
  /// Example:
  /// - Input: `"30 Days"`
  /// - Stored value: `30`
  ///
  /// If no valid digits are found:
  /// - `tenorValue` becomes `null'
  void onTenorValueChanged(
    FacilitySummaryNew facilitySummary,
    String enteredValue,
  ) {
    final RegExpMatch? numericMatch = RegExp(r"\d+").firstMatch(enteredValue);

    facilitySummary
      ..tenorValue =
          numericMatch != null ? int.tryParse(numericMatch.group(0)!) : null
      ..isEdited = true;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selected **Benchmark / Index** for the row.
  /// This method is triggered when the user chooses a value from the
  /// Benchmark / Index dropdown.
  /// Important:
  /// The selected index is stored in more than one place
  /// 1. Top-level field:
  ///    - `facilitySummary.index`
  ///
  /// 2. Nested additional details JSON:
  ///    - `profitGrid[0].index`
  ///    - `lcCommission[0].indexLcLGCommision`
  ///    - `avCommission[0].indexLcLGCommision`
  ///    - `lgCommission[0].indexLcLGCommision`
  ///
  /// Why nested sync is required:
  /// If only `facilitySummary.index` is updated but nested JSON still contains
  /// the old value, the selected index may revert back during save or reload.
  /// What this method does:
  /// - Reads selected dropdown value
  /// - Stores the selected id/name as `facilitySummary.index`
  /// - Marks the row as edited
  /// - Updates nested `additionalDetailsParsed` structures if present
  /// - Re-encodes nested JSON back into `additionalDetailsContainer`
  ///   so save logic uses the latest value
  ///
  /// This is especially important for rows where the backend stores
  /// index/benchmark in commission blocks.
  void onBenchmarkSelected(
    FacilitySummaryNew facilitySummary,
    List<Reference> selectedBenchmarks,
  ) {
    if (selectedBenchmarks.isEmpty) {
      return;
    }

    final Reference selectedBenchmark = selectedBenchmarks.first;
    final String selectedBenchmarkId =
        (selectedBenchmark.id?.toString() ?? selectedBenchmark.name ?? "")
            .trim();

    facilitySummary
      ..index = selectedBenchmarkId
      ..isEdited = true;

    // ---------------------------------------------
    // Minimal sync so index does NOT revert to 15750
    // ---------------------------------------------
    final Map<String, dynamic>? parsedAdditionalDetails =
        facilitySummary.additionalDetailsParsed;

    if (parsedAdditionalDetails != null && selectedBenchmarkId.isNotEmpty) {
      // Update profitGrid[0].index if profitGrid exists
      final dynamic profitGridRows = parsedAdditionalDetails["profitGrid"];
      if (profitGridRows is List &&
          profitGridRows.isNotEmpty &&
          profitGridRows.first is Map) {
        final Map<String, dynamic> firstProfitGridRow =
            Map<String, dynamic>.from(profitGridRows.first as Map);
        firstProfitGridRow["index"] = selectedBenchmarkId;
        profitGridRows[0] = firstProfitGridRow;
        parsedAdditionalDetails["profitGrid"] = profitGridRows;
      }

      // Update the first available commission block index if it exists.
      for (final String commissionCollectionKey in const [
        "lcCommission",
        "avCommission",
        "lgCommission",
      ]) {
        final dynamic commissionRows =
            parsedAdditionalDetails[commissionCollectionKey];
        if (commissionRows is List &&
            commissionRows.isNotEmpty &&
            commissionRows.first is Map) {
          final Map<String, dynamic> firstCommissionRow =
              Map<String, dynamic>.from(commissionRows.first as Map);
          firstCommissionRow["indexLcLGCommision"] = selectedBenchmarkId;
          commissionRows[0] = firstCommissionRow;
          parsedAdditionalDetails[commissionCollectionKey] = commissionRows;
          break;
        }
      }
    }

    // Keep the wrapper container synchronized with the parsed JSON map.
    // This ensures _buildAdditionalDetailsForSave() starts with the latest
    // inner JSON string instead of stale data.
    final Map<String, dynamic>? additionalDetailsContainer =
        facilitySummary.additionalDetailsContainer;
    if (additionalDetailsContainer != null && parsedAdditionalDetails != null) {
      additionalDetailsContainer["additionalDetails"] =
          jsonEncode(parsedAdditionalDetails);
      facilitySummary.additionalDetailsContainer = additionalDetailsContainer;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selected **Margin Sign** for the row.
  ///
  /// Usually used for funded (`F`) rows where the user selects:
  /// - "+"
  /// - "-"
  ///
  /// What it does:
  /// - Stores selected sign in `facilitySummary.marginSign`
  /// - Marks the row as edited
  ///
  /// Note:
  /// The sign value is taken from `Reference.reference1`,
  /// not from `Reference.name`.
  void onMarginSignSelected(
    FacilitySummaryNew facilitySummary,
    List<Reference> selectedMarginSigns,
  ) {
    if (selectedMarginSigns.isEmpty) {
      return;
    }
    final Reference selectedMarginSign = selectedMarginSigns.first;

    facilitySummary
      ..marginSign = selectedMarginSign.reference1
      ..isEdited = true;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the numeric **Margin / Commission Value** for the row.
  ///
  /// This field is used differently depending on row type:
  /// - For `F` rows: it represents margin value
  /// - For `N` rows: it is used as commission value
  ///
  /// What this method does:
  /// - Extracts the first valid signed/decimal number from the input
  /// - Stores it into `facilitySummary.marginValue`
  /// - Marks the row as edited
  ///
  /// Supported input examples:
  /// - `"10"`
  /// - `"-2.5"`
  /// - `"+3.75"`
  ///
  /// If no valid number is found:
  /// - `marginValue` becomes `null`
  ///
  /// Note:
  /// This method only updates the row model.
  /// The actual save payload placement (profitGrid vs commission block)
  /// is handled later by save builder logic.
  void onMarginValueChanged(
    FacilitySummaryNew facilitySummary,
    String enteredValue,
  ) {
    final RegExpMatch? numericMatch =
        RegExp(r"[-+]?\d*\.?\d+").firstMatch(enteredValue);

    facilitySummary
      ..marginValue =
          numericMatch != null ? num.tryParse(numericMatch.group(0)!) : null
      ..isEdited = true;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Formats initial values for display in tooltips and comparison views.
  ///
  /// Combines each prefix and suffix pair into a single formatted value and
  /// returns them as a comma-separated string prefixed with
  /// `"Initial Value:"`.
  ///
  /// Returns an empty string when the input lists are null, empty, or do not
  /// contain valid values.
  String getFormattedInitialValue(
    List<String>? prefix,
    List<String>? suffix,
  ) {
    if (prefix == null || suffix == null || prefix.isEmpty || suffix.isEmpty) {
      return "";
    }

    final List<String> formattedValues = <String>[];

    for (int i = 0; i < prefix.length && i < suffix.length; i++) {
      final String value = suffix[i].trim();

      if (value.isNotEmpty) {
        formattedValues.add("${prefix[i]} $value");
      }

      if (formattedValues.isEmpty) {
        return "";
      }
    }

    return 'Initial Value: ${formattedValues.join(', ')}';
  }
}
