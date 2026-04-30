import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
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
import "package:wcas_frontend/models/request/facility_security/exchange_rate.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";
import "package:wcas_frontend/models/request/facility_security/facility_detail.dart";
import "package:wcas_frontend/models/request/facility_security/facility_summary_list.dart";
import "package:wcas_frontend/models/request/facility_security/limits_facilities_response.dart";
import "package:wcas_frontend/models/request/facility_security/project_list.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";
import "package:wcas_frontend/repositories/home_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

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
  FacilitiesSummaryViewModel()
      : super(FacilitiesSummaryState(loaderStatus: LoadingStatus.loading));

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

  /// Repository used to load application details, currency codes, etc.
  RequestRepository repository = RequestRepository();

  /// Reference data loader for dropdown/config lists.
  ReferenceDataService referenceDataService = ReferenceDataService();

  /// Facility/Security backend repository for summary lists, save, delete, etc.
  FacilitySecurityRepository facilitySecurityRepository =
      FacilitySecurityRepository();

  /// Main form key for facility summary inputs.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Page privilege for this screen, resolved from access rights (Edit/View/NA).
  PageMode pageMode = PageMode.na;

  /// True if the user can edit this screen (based on rights/role).
  bool get canEdit => (pageMode == PageMode.edit);

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
  List<Facility> originalFacilities = [];

  /// Application details used to determine allowed product types, etc.
  ApplicationDetails? applicationDetails = ApplicationDetails();

  /// Create Facility context used when routing into create/edit facility screens.
  Facility facility = Facility();

  /// Facility detail list used by project header save builder (kept as-is).
  List<FacilityDetail> facilityDetail = [];
  FacilityDetails facilityDetails = FacilityDetails();

  /// Cached project list names for project groups.
  List<Reference> projectNames = [];
  Reference? selectedProjectRef;

  /// Controls radio enable/disable state (when both conventional+islamic exist).
  bool isProductTypeEnabled = false;

  /// Some flags (kept as-is).
  bool isNewRequest = false;
  bool isApiError = false;
  bool isExisitngAppRefNo = false;

  String? selectedReconAppReNumber;
  String? selectedLastApprovedAppRefNum;
  ApplicationDetails? selectedReconsiderations;
  Reference? selectedProductType;
  List<Reference> productTypeItems = [];

  // ──────────────────────────────────────────────────────────────────────────
  // Project header state (Standby/Specific groups)
  // ──────────────────────────────────────────────────────────────────────────

  /// Project Standby and Project Specific group ids (from ServerConstants).
  static const int groupStandBy = ServerConstants.projectStandByLimitID;
  static const int groupSpecific =
      ServerConstants.projectSpecificLimitsID; // 11315 [1](https://cbddxb-

  /// Cache key builder for per-(groupId,rimNo) header state.
  String groupRimKey(int groupId, int rimNo) => "$groupId-$rimNo";

  /// Header controllers per (groupId, rimNo).
  final Map<String, TextEditingController> psNameCtrls = {};
  final Map<String, TextEditingController> psProposedCtrls = {};
  final Map<String, TextEditingController> psStandbyNameCtrls = {};
  final Map<String, TextEditingController> psStandbyProposedCtrls = {};

  /// Header numeric inputs per (groupId, rimNo).
  final Map<String, num?> _projectExistingByKey = {};
  final Map<String, num?> _projectProposedByKey = {};

  /// Header currency per (groupId, rimNo).
  final Map<String, Reference?> headerCurrencyByKey = {};

  /// Header API snapshot caches (per groupId + rimNo).
  /// Used for dirty-check and update payload behavior.
  final Map<String, int?> _headerFacilityIdByKey = {};
  final Map<String, num?> _headerProposedApiByKey = {};
  final Map<String, String?> _headerCurrencyApiByKey = {};
  final Map<String, String?> _headerNameApiByKey = {};

  /// Project list fetch cache to avoid repeated API calls.
  final Set<String> _projectFetchKeys = {};

  /// Header validation visibility (group -> show errors).
  final Map<int, bool> _showHeaderErrors = {};

  /// Header inputs (legacy fields kept as-is).
  num? projectExistingLimitInput;
  num? projectProposedLimitInput;

  TextEditingController projectExistingCtrl = TextEditingController();
  TextEditingController projectProposedCtrl = TextEditingController();
  TextEditingController projectStandbyExistingCtrl = TextEditingController();
  TextEditingController projectStandbyProposedCtrl = TextEditingController();
  TextEditingController projectStandbyNameCtrl = TextEditingController();
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

  Reference? selectedLimitDetails;
  Reference? selectedSubLimitDetails;
  Timer? _tooltipDebounceTimer;

  /// List of available currency codes.
  List<Reference> countryCodes = [];
  List<Reference> spreadCommisions = [
    Reference(name: "+"),
    Reference(name: "-"),
  ];
  List<Reference> tenorDays = [
    Reference(name: "Days"),
    Reference(name: "Months"),
  ];

  final Map<String, String> _convertedTooltipByRow = {};
  final Map<String, int> _initialProposedByRow = {};
  final Map<String, String> _initialCurrencyByRow =
      {}; // NEW: snapshot of initial currency code

  /// List of sub-limit types.
  List<Reference> subLimitTypes = [];
  List<Reference> limitTypes = [];

  String previousValue = "facilities.facilitySummary.previuosValue".tr();

  // final Map<int, num?> _projectExistingLimitByGroup = {};
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
  Future<void> init(context) async {
    logger.i("initialising FacilitiesSummaryViewModel");
    pageMode = AuthRepository.getPageMode(RightConstants.facilitySummary);
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

  Future<void> getFacilitySummaryListFromLinakge() async {
    try {
      facilities =
          await FacilitySecurityRepository.instance.getLinkageFacility();
      originalFacilities = List.from(facilities);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
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
      preloadHeaderProposedLimitsFromApi();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
    } finally {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Saves edited facility rows for the current customer/group.
  ///
  /// Behavior:
  /// - Collects only rows marked `isEdited == true`.
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
      // Parent/controlling validation (row-level) for standby sublimits
      if (limitGroup == ServerConstants.projectStandByLimitID &&
          selectedRim != null) {
        final bool ok = _validateChildProposedNotExceedControlling(
          list,
          ServerConstants.projectStandByLimitID,
          selectedRim,
        );
        if (!ok) {
          emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
          return;
        }
      }
      if (limitGroup != ServerConstants.generalLimitGroupId &&
          limitGroup != ServerConstants.termLoanGroupId &&
          limitGroup != ServerConstants.pfeLimitGroupId) {
        if (limitGroup == ServerConstants.projectStandByLimitID) {
          if (!_validateAgainstGroupCap(list, groupStandBy, selectedRim)) {
            AlertManager().showFailureToast(
              "facilities.facilitySummary.exceedProjectStandbylimit".tr(),
            );
            emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
            return;
          }
        } else if (limitGroup == ServerConstants.projectSpecificLimitsID) {
          if (!_validateAgainstGroupCap(list, groupSpecific, selectedRim)) {
            AlertManager().showFailureToast(
              "facilities.facilitySummary.exceedProjectSpecificlimit".tr(),
            );
            emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
            return;
          }
        }
      }

      final List<FacilitySummaryNew> edited = _collectEditedFacilities(list);
      if (edited.isEmpty) {
        AlertManager().showWarningToast(
          "facilities.facilitySummary.nochChangeToSave".tr(),
        );
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }

      if ((_validateAgainstGroupCap(list, groupSpecific, selectedRim))) {
        await facilitySecurityRepository.saveFacilitySummaryListEdited(edited);
        AlertManager().showSuccessToast(
          "facilities.facilitySummary.savedSuccessfully".tr(),
        );

        await getFacilitySummaryListFromLinakge();
        await getFacilitySummaryListPerRim();

        _initialProposedByRow.clear();
        _initialCurrencyByRow.clear();

        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      }
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  //save limit caps call from dialog
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
    } catch (error) {
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

    emit(state.copyWith(tableLoaderStatus: LoadingStatus.loading));
    try {
      await facilitySecurityRepository.deleteFacilityDetails(
        facilityId: serialNumber,
      );
      await getFacilitySummaryListFromLinakge();
      await getFacilitySummaryListPerRim();
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    } finally {
      emit(state.copyWith(tableLoaderStatus: LoadingStatus.loaded));
    }
  }

  /// Validates that child sub-limit proposed ≤ parent/controlling limit proposed.
  /// Validates that child sub-limit proposed ≤ parent/ to Project Standby sublimits and respects controlling-limit hierarchy.
  /// Skips synthetic controlling limits (PSBL/PSPL) which represent header-based grouping.
  bool _validateChildProposedNotExceedControlling(
    FacilitySummaryList list,
    int groupId,
    int rimNo,
  ) {
    final String? headerLimitNo =
        headerLimitNumberForGroupAtRim(groupId, rimNo);
    final int headerCap = proposedLimitForGroup(groupId, rimNo: rimNo) ?? 0;

    final List<FacilitySummaryNew> facilitiesInGroupAtRim = [];

    for (final RimSummary rim in (list.rims ?? const <RimSummary>[])) {
      final int? rimFromName = extractRimId(rim.rimName);
      if (rimFromName != rimNo) continue;

      for (final RimGroup rimGroup in (rim.groups ?? const <RimGroup>[])) {
        for (final FacilityDis facilityDis
            in (rimGroup.facilityLimits ?? const <FacilityDis>[])) {
          final FacilitySummaryNew? facility = facilityDis.facility;
          if (facility == null) continue;
          if ((facility.limitGroup ?? -1) != groupId) continue;

          if (isExcludedFacility(facility)) continue;

          facilitiesInGroupAtRim.add(facility);
        }
      }
    }

    for (final FacilitySummaryNew childFacility in facilitiesInGroupAtRim) {
      final String controllingLimitNo =
          (childFacility.controllingLimitNo ?? "").trim();
      if (controllingLimitNo.isEmpty) continue;

      // Skip validation/toast when controlling limit is PSBL / PSPL
      final String controllingUpper = controllingLimitNo.toUpperCase();
      if (controllingUpper.contains("PSBL") ||
          controllingUpper.contains("PSPL")) {
        continue;
      }

      final int childProposed = (childFacility.proposedLimit ?? 0).toInt();

      int? parentCap;

      if (headerLimitNo != null &&
          controllingLimitNo.trim() == headerLimitNo.trim()) {
        parentCap = headerCap;
      } else {
        final FacilitySummaryNew? parentFacility =
            facilitiesInGroupAtRim.cast<FacilitySummaryNew?>().firstWhere(
                  (p) => (p?.limitNo ?? "").trim() == controllingLimitNo,
                  orElse: () => null,
                );

        parentCap = parentFacility?.proposedLimit?.toInt();
      }

      if (parentCap == null) continue;

      if (childProposed > parentCap) {
        AlertManager().showFailureToast(
          "facilities.facilitySummary.subLimitProposedLimitExceed".tr(),
        );
        return false;
      }
    }

    return true;
  }

  /// Validates that the sum of proposed limits does not exceed the group/header cap.
  ///
  /// For project groups:
  /// - Sum includes all detail rows (excluding header row and excluded facility
  /// rows).
  /// For non-project groups:
  /// - Sum includes only main limits (legacy behavior preserved)
  bool _validateAgainstGroupCap(
    FacilitySummaryList list,
    int groupId,
    int? rimNo,
  ) {
    final int? cap = proposedLimitForGroup(groupId, rimNo: rimNo!);
    final int total = _sumProposedForGroup(list, groupId);
    debugPrint(
      "Validating group $groupId at rim $rimNo: "
      "total proposed = $total, cap = $cap",
    );
    if (!_shouldValidateGroup(list, groupId)) return true;
    if (cap == null) {
      return false;
    }
    return total <= cap;
  }

  ///Sum of proposed limits for facilities that belong to a limit group
  int _sumProposedForGroup(
    FacilitySummaryList facilitySummaryList,
    int limitGroupId,
  ) {
    int totalProposed = 0;

    final bool isProjectGroup =
        (limitGroupId == ServerConstants.projectSpecificLimitsID ||
            limitGroupId == ServerConstants.projectStandByLimitID);

    final List<RimSummary> rimSummaries =
        facilitySummaryList.rims ?? const <RimSummary>[];
    for (final RimSummary rim in rimSummaries) {
      final List<RimGroup> groups = rim.groups ?? const <RimGroup>[];
      for (final RimGroup grp in groups) {
        final List<FacilityDis> disList =
            grp.facilityLimits ?? const <FacilityDis>[];
        for (final FacilityDis dis in disList) {
          final FacilitySummaryNew? f = dis.facility;
          if (f == null) continue;
          if ((f.limitGroup ?? -1) != limitGroupId) continue;

          // Skip header (order == '0') and any main-limit row
          final bool isHeader = (dis.order ?? "").trim() == "0";

          // Skip excluded rows (limit caps id 935, product code CLT)
          final String? ld = f.limitDescription?.toString();
          final String pc = (f.productCode ?? "").trim().toUpperCase();
          final bool isExcluded = (ld == "935") || (pc == "CLT");

          if (isHeader || isExcluded) continue;

          // Project groups: sum ALL detail rows (allocation rows are sublimits)
          if (isProjectGroup) {
            totalProposed += (f.proposedLimit ?? 0).toInt();
          } else {
            // Keep existing behavior for non-project groups
            totalProposed +=
                (f.isMainLimit ?? false) ? (f.proposedLimit ?? 0).toInt() : 0;
          }
        }
      }
    }
    return totalProposed;
  }

  bool _shouldValidateGroup(FacilitySummaryList list, int groupId) {
    final bool capEntered = _projectProposedLimitByGroup[groupId] != null;
    final int total = _sumProposedForGroup(list, groupId);
    return capEntered || total > 0;
  }

  // Project Specific
  TextEditingController psNameCtrl(int rimNo) => psNameCtrls.putIfAbsent(
        groupRimKey(groupSpecific, rimNo),
        TextEditingController.new,
      );
  TextEditingController psProposedCtrl(int rimNo) =>
      psProposedCtrls.putIfAbsent(
        groupRimKey(groupSpecific, rimNo),
        TextEditingController.new,
      );

  // Project Standby
  TextEditingController standbyNameCtrl(int rimNo) =>
      psStandbyNameCtrls.putIfAbsent(
        groupRimKey(groupStandBy, rimNo),
        TextEditingController.new,
      );
  TextEditingController standbyProposedCtrl(int rimNo) =>
      psStandbyProposedCtrls.putIfAbsent(
        groupRimKey(groupStandBy, rimNo),
        TextEditingController.new,
      );

  // Currency getter/setter
  Reference? headerCurrencyFor(int groupId, int rimNo) =>
      headerCurrencyByKey[groupRimKey(groupId, rimNo)];
  void setHeaderCurrencyFor(int groupId, int rimNo, Reference ref) {
    headerCurrencyByKey[groupRimKey(groupId, rimNo)] = ref;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  int? resolveRimNoFromApi() {
    final int? groupOwner = Globals.request?.groupOwner;
    if (groupOwner != null && groupOwner > 0) return groupOwner;

    final dynamic reqRim = Globals.request?.customerRimNo;
    final int? reqRimInt =
        (reqRim is num) ? reqRim.toInt() : int.tryParse("$reqRim");
    if (reqRimInt != null && reqRimInt > 0) return reqRimInt;

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

  bool isProjectHeaderLimitsEnteredForAtRim(int? groupId, int? rimNo) {
    if (groupId == null || rimNo == null) return false;
    final String key = groupRimKey(groupId, rimNo); // e.g., "11317-895044"
    return _projectProposedByKey[key] !=
        null; // value set by setProjectProposedLimitInput(..., rimNo: ...)
  }

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
    } catch (e) {
      logger.i("Error getApplicationDetails types: $e");
      isApiError = true;
      rethrow;
    }
  }

  void populateApplicationDetails(ApplicationDetails details) {
    applicationDetails = details;

    updateSelectedProductType(
      conventional: details.conventional,
      islamic: details.islamic,
    ); // use
  }

  void updateSelectedProductType({bool? conventional, bool? islamic}) {
    final bool conv =
        conventional ?? (applicationDetails?.conventional == true);
    final bool isl = islamic ?? (applicationDetails?.islamic == true);
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

  // Filters out 'NA' from the options
  List<Reference> getFilteredProductOptions() {
    return productTypeItems
        .where(
          (ref) => ref.name != "requestInformation.requestInformation.na".tr(),
        )
        .toList();
  }

  int? headerFacilityIdForGroupAtRim(int groupId, int rimNo) {
    return _headerFacilityIdByKey[groupRimKey(groupId, rimNo)];
  }

  /// Detect if header inputs differ from API snapshot
  bool isProjectHeaderDirtyAtRim(int groupId, int rimNo) {
    final key = groupRimKey(groupId, rimNo);

    final num? apiProposed = _headerProposedApiByKey[key];
    final num? currentProposed = _projectProposedByKey[key];

    final String apiCurrency =
        (_headerCurrencyApiByKey[key] ?? "AED").trim().toUpperCase();
    final String currentCurrency =
        (headerCurrencyFor(groupId, rimNo)?.name ?? "AED").trim().toUpperCase();

    final bool isStandby = groupId == groupStandBy;
    final String currentName =
        (isStandby ? standbyNameCtrl(rimNo).text : psNameCtrl(rimNo).text)
            .trim();
    final String apiName = (_headerNameApiByKey[key] ?? "").trim();

    // Proposed: compare only if both known
    final bool proposedChanged = (apiProposed != null &&
        currentProposed != null &&
        apiProposed != currentProposed);

    final bool currencyChanged = apiCurrency != currentCurrency;
    final bool nameChanged = apiName != currentName;

    return proposedChanged || currencyChanged || nameChanged;
  }

  void onProductTypeSelected(Reference selected) {
    // use check your function
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
      if (limitGroup != null &&
          rimNo != null &&
          _projectFetchKeys.contains(key)) {
        return;
      }

      final ProjectListResponse list =
          await facilitySecurityRepository.getProjectList(
        limitGroup: limitGroup, // NEW
        rimNo: rimNo,
      );

      projectNames =
          list.responseData.map((name) => Reference(name: name)).toList();

      if (limitGroup != null && rimNo != null) {
        _projectFetchKeys.add(key); // Mark as fetched
      }
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  void setProjectExistingLimitInput(
    String? value, {
    required int groupId,
    required int rimNo,
  }) {
    _projectExistingByKey[groupRimKey(groupId, rimNo)] =
        num.tryParse(value ?? "");
  }

  void setProjectProposedLimitInput(
    String? value, {
    required int groupId,
    required int rimNo,
  }) {
    _projectProposedByKey[groupRimKey(groupId, rimNo)] =
        num.tryParse(value ?? "");
    _projectProposedLimitByGroup[groupId] = num.tryParse(value ?? "");
  }

  bool isProjectHeaderLimitsEnteredFor(int? groupId) {
    if (groupId == null) return false;
    final num? proposedLimit = _projectProposedLimitByGroup[groupId];
    return proposedLimit != null;
  }

  void markProjectHeaderErrors(int? groupId) {
    if (groupId == null) return;
    _showHeaderErrors[groupId] = true;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void clearProjectHeaderErrors(int? groupId) {
    if (groupId == null) return;
    if (_showHeaderErrors.remove(groupId) != null) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
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
  String tooltipMessageFor(FacilitySummaryNew f) {
    final String key = _rowKey(f);
    _initialProposedByRow.putIfAbsent(
      key,
      () => (f.proposedLimit ?? 0).toInt(),
    );
    _initialCurrencyByRow.putIfAbsent(
      key,
      () => (f.currency ?? "").trim().toUpperCase(),
    );
    final String? converted = _convertedTooltipByRow[key];
    if (converted != null && converted.isNotEmpty) {
      return converted;
    }
    final int amountFromApi = _initialProposedByRow[key] ?? 0;
    final String codeFromApi = _initialCurrencyByRow[key] ?? "";
    return " $previousValue $amountFromApi $codeFromApi";
  }

  /// Updates the tooltip cache for currency conversion / previous value display.
  ///
  /// Debounced to avoid excessive API calls while user types.
  /// If currency is AED (or empty), tooltip shows previous snapshot only.
  /// Otherwise, converts live proposed amount to AED using exchange rate servic
  Future<void> updateConvertedTooltipFor(
    FacilitySummaryNew selectedPorposedLimit, {
    bool rebuild = false,
  }) async {
    _tooltipDebounceTimer?.cancel();
    _tooltipDebounceTimer = Timer(const Duration(milliseconds: 350), () async {
      try {
        final String key = _rowKey(selectedPorposedLimit);
        _initialProposedByRow.putIfAbsent(
          key,
          () => (selectedPorposedLimit.proposedLimit ?? 0).toInt(),
        );
        _initialCurrencyByRow.putIfAbsent(
          key,
          () => (selectedPorposedLimit.currency ?? "").trim().toUpperCase(),
        );

        final String code =
            (selectedPorposedLimit.currency ?? "").trim().toUpperCase();
        final int amountFromApi = _initialProposedByRow[key] ?? 0;
        final num amountLive = (selectedPorposedLimit.proposedLimit ?? 0);
        final NumberFormat formatter = NumberFormat("#,###");

        // If empty or AED, show snapshot + current code (no conversion needed)
        if (code.isEmpty || code == ServerConstants.aedCurrency) {
          final String msg =
              " $previousValue ${formatter.format(amountFromApi)} $code";
          _convertedTooltipByRow[key] = msg;

          if (rebuild && !isClosed) {
            emit(state.copyWith(loaderStatus: state.loaderStatus));
          }
          return;
        }

        // Otherwise, convert LIVE amount into AED using selected currency's
        // rate
        final Reference ref = Reference(name: code);
        final CurrencyRates currencyRates =
            await facilitySecurityRepository.getCurrencyRates(ref);
        final num rate = currencyRates.rates[code] ?? 0;
        final num converted = amountLive * rate;

        // Compose message: real-time converted AED + API snapshot as "Initial
        // Amount"
        final String msg =
            "AED Amount: ${formatter.format(converted.toInt())}, "
            " $previousValue ${formatter.format(amountFromApi)} $code";

        _convertedTooltipByRow[key] = msg;

        if (rebuild && !isClosed) {
          emit(state.copyWith(loaderStatus: state.loaderStatus));
        }
      } catch (e) {
        AlertManager().showFailureToast(e.toString());
      }
    });
  }

  // Called by FacilityProjectName.onSelected
  void onProjectNameSelected(List<Reference> selected) {
    if (selected.isNotEmpty) {
      selectedProjectRef = selected.first;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  int? proposedLimitForGroup(int groupId, {required int rimNo}) {
    final int proposedLimit =
        _projectProposedByKey[groupRimKey(groupId, rimNo)]?.toInt() ?? 0;
    return proposedLimit;
  }

// Apply the selected project to the facility row and refresh UI
  void applySelectedProjectTo(FacilitySummaryNew facility) {
    if (selectedProjectRef != null) {
      facility.projectName = selectedProjectRef!
          .name; // store as String for Text("${f.projectName}")
      facility.isEdited = true; // so save will pick it up
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
          if (f?.isEdited == true) {
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
      await facilitySecurityRepository.getCurrencyRates(selectedCurrency);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (error) {
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
    } catch (e) {
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
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  /// Returns the display name for a facility 'limitDescription' ID using
  /// facilityTypes.
  /// Fallback: if not found or null, returns the raw id as string or empty.
  Reference facilityTypeNameById(dynamic id) {
    if (id == null) return Reference(name: id.toString());
    final String target = id.toString().trim();
    final Reference matchedReference = facilityTypes.firstWhere(
      (r) => (r.id?.toString().trim() ?? "") == target,
      orElse: () => Reference(name: target),
    );

    return matchedReference;
  }

  //name for Limit Caps Type (e.g., 14493 -> "Project Standby Limits")
  String limitCapsTypeNameById(dynamic id) {
    if (id == null) return "";
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
      currencyCodes = await repository.getCurrencyCodes();
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

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

  Future<void> facilityTypeDescriptionsSelected(Reference selectedValue) async {
    facility.facilityDescription = selectedValue;
    emit(state.copyWith(tableLoaderStatus: LoadingStatus.loaded));
  }

  void selectSharedLimit(Reference selectedValue) {
    facility.sharedLimit = selectedValue;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void addSelectedSubLimitDetails(Reference selectedValue) {
    selectedSubLimitDetails = selectedValue;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // Put these helpers at the top of the build row scope (or in a utils file)
  Reference matchOrFirstByName(List<Reference> list, String? name) {
    if (list.isEmpty) return Reference(); // won't be used—just a guard
    if ((name ?? "").isEmpty) return list.first;
    final String lower = name!.trim().toLowerCase();
    return list.firstWhere(
      (r) => (r.name ?? "").trim().toLowerCase() == lower,
      orElse: () => currencyCodes.first,
    );
  }

  Reference matchOrFirstById(List<Reference> list, String? id) {
    if (list.isEmpty) return Reference();

    final String target = id.toString();
    return list.firstWhere(
      (r) => r.id?.toString() == target,
      orElse: () => benchmark.first,
    );
  }

  Reference matchOrFirstByRef1(List<Reference> list, String? ref1) {
    if (list.isEmpty) {
      return Reference(); // e.g., default to "+" if marginSign list
    }
    if ((ref1 ?? "").isEmpty) return list.first;
    final String lower = ref1!.trim().toLowerCase();
    return list.firstWhere(
      (r) => (r.reference1 ?? "").trim().toLowerCase() == lower,
      orElse: () => marginSign.first,
    );
  }

  // Change the return type to int? and use int.tryParse
  int? extractRimId(String? rimName) {
    if (rimName == null) return null;
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
            if (facility == null) continue;

            final int? gid = facility.limitGroup;
            final int? rimNo = facility.rimNo;
            if (gid == null || rimNo == null) continue;

            // Only for project groups OR you can keep for all
            if (gid != groupStandBy && gid != groupSpecific) continue;

            // Capture HEADER row only (order == '0') and skip excluded
            // facilities
            if ((dis.order ?? "").trim() == "0" &&
                !isExcludedFacility(facility)) {
              final String key = groupRimKey(gid, rimNo);

              // Existing behavior: ensure proposed is set for validation
              final int? apiProp = facility.proposedLimit;
              if (apiProp != null) {
                _projectProposedByKey.putIfAbsent(key, () => apiProp);
              }

              // NEW snapshots for dirty detection + update payload
              _headerFacilityIdByKey[key] = facility.facilityId;
              _headerProposedApiByKey[key] = facility.proposedLimit;
              _headerCurrencyApiByKey[key] =
                  (facility.currency ?? "AED").trim();
              _headerNameApiByKey[key] = (facility.projectName ?? "").trim();

              // also initialize header currency dropdown state (only if empty)
              if (headerCurrencyFor(gid, rimNo) == null) {
                final Reference ref = matchOrFirstByName(
                  currencyCodes,
                  (facility.currency ?? "AED"),
                );
                headerCurrencyByKey[key] = ref;
              }
            }
          }
        }
      }
    }
  }

  Reference matchPeriodByAny(List<Reference> list, String? unit) {
    if (list.isEmpty) return period.first;
    final target = normalizeTenorUnit(unit);

    // First: exact normalized name match
    for (final r in list) {
      final n = normalizeTenorUnit(r.name);
      if (n == target) return r;
    }

    // Next: try reference1 if it carries abbreviations like D/M/Y/OD
    for (final r in list) {
      final ref1 = normalizeTenorUnit(r.reference1);
      if (ref1 == target) return r;
    }

    // Next: try id if server sends an id and you mapped it to a name
    for (final r in list) {
      if ((r.id?.toString() ?? "").trim() == (unit ?? "").trim()) return r;
    }

    // Fallback to the first item
    return period.first;
  }

  String normalizeTenorUnit(String? raw) {
    if (raw == null) return "";
    final s = raw.trim().toLowerCase();

    // Collapse spaces/hyphens/underscores
    final compact = s.replaceAll(RegExp(r"[\s\-_]+"), "");

    // Accept many variants from API: names, abbreviations, single/plural
    if (compact == "d" || compact == "day" || compact == "days") return "Days";
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
    if (!isProjectGroup(groupId)) return;

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
  }) async {
    if (groupId == null) return false;

    // keep behavior identical to UI: only set product code for 11315/11317
    prepareProjectProductCode(groupId);

    return saveFacilityProject(
      false,
      rimNo,
      groupId,
      descSnapshot,
      facilityId: facilityId,
      limitCaptype: limitCaptype,
    );
  }

  ///for project standby and specific main limit creation call this api when new
  ///creating facility
  /// only for first time if no limit prrsent in table
  Future<bool> saveFacilityProject(
    bool navigateToHomePage,
    int? selectedRim,
    int? limitGroup,
    Reference? facilityDescription, {
    int? facilityId,
    int? limitCaptype,
  }) async {
    try {
      facility.appRefNo = Globals.request?.applicationRefNo;
      facility.rimNo = facility.rimNo;
      final LimitsFacilityResponse resp =
          await facilitySecurityRepository.saveFacilityProject(
        facilityDetails: _buildeFacilityProject(
          selectedRim,
          limitGroup,
          facilityDescription,
          facilityId: facilityId,
          limitCaptype: limitCaptype,
        ),
      );
      facility.limitNumber =
          resp.facilityDetails?.limitNo ?? facility.limitNumber;
      await getFacilitySummaryListPerRim();
      AlertManager().showSuccessToast(
        "facilities.facilitySummary.savedSuccessfully".tr(),
      );
      return true;
    } catch (message) {
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
  }) {
    final int selectedGroupId =
        _numOr(limitGroup, groupStandBy).toInt(); // default fallback to 11315

    final String appRef =
        _strOr(Globals.request?.applicationRefNo, ""); // “appRefNo”
    final int rim = _numOr(selectedRim, 987).toInt(); // “rimNo”
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
    final int presentOutstanding =
        int.tryParse(facility.presentOutstandingCCValue?.description ?? "") ??
            (facilityDetail.isNotEmpty
                ? (facilityDetail.first.presentOutstanding?.toInt() ?? 0)
                : 0);

    // Existing limit from header (group+rim)
    final int presentLimit =
        (_projectExistingByKey[groupRimKey(selectedGroupId, rim)]?.toInt()) ??
            (int.tryParse(facility.limitAmount?.description ?? "") ??
                (facilityDetail.isNotEmpty
                    ? (facilityDetail.first.presentLimit?.toInt() ?? 0)
                    : 0));

    // Currency from header dropdown (stored in facility.proposedLimitValue)
    final String currency =
        _strOr(facility.proposedLimitValue?.name, "AED"); // “currency”

    // Proposed limit from header (group+rim)
    final int proposedLimit =
        (_projectProposedByKey[groupRimKey(selectedGroupId, rim)]?.toInt()) ??
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
            if ((fac?.limitGroup ?? -1) != groupId) continue;

            final String? order = dis.order?.trim(); //s.no

            // Consider ONLY non-excluded rows as "data present"
            if (order == "0") {
              if (!isExcludedFacility(fac)) return false; // valid header exists
            } else if (order != null && order != "0") {
              if (!isExcludedFacility(fac)) return false; // valid detail exists
            }
          }
        }
      }
    }
    // No records for this group in API -> first time -> allow API call once
    return true;
  }

  int? limitCapTypeForGroup(int? groupId) {
    if (isFIFlow) return null;

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
    if (customerFacilities == null || groupId == null) return false;
    for (final FacilitySummaryList summary in customerFacilities!) {
      for (final RimSummary rim in summary.rims ?? const <RimSummary>[]) {
        for (final RimGroup grp in rim.groups ?? const <RimGroup>[]) {
          for (final FacilityDis dis
              in (grp.facilityLimits ?? const <FacilityDis>[])) {
            final FacilitySummaryNew? fac = dis.facility;
            if ((fac?.limitGroup ?? -1) != groupId) continue;
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
    if (customerFacilities == null || groupId == null) return null;
    for (final FacilitySummaryList summary in customerFacilities!) {
      for (final RimSummary rim in summary.rims ?? const <RimSummary>[]) {
        for (final RimGroup grp in rim.groups ?? const <RimGroup>[]) {
          for (final FacilityDis dis
              in (grp.facilityLimits ?? const <FacilityDis>[])) {
            final FacilitySummaryNew? fac = dis.facility;
            if ((fac?.limitGroup ?? -1) != groupId) continue;
            if (dis.order?.trim() == "0") {
              // Skip headers that are not real facilities (CLT / 935)
              if (isExcludedFacility(fac)) continue;
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
        if (rimFromName != rimNo) continue;

        for (final RimGroup grp in rim.groups ?? const <RimGroup>[]) {
          for (final FacilityDis dis
              in grp.facilityLimits ?? const <FacilityDis>[]) {
            final FacilitySummaryNew? fac = dis.facility;
            if ((fac?.limitGroup ?? -1) != groupId) continue;

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
        if (rimFromName != rimNo) continue;

        for (final RimGroup grp in rim.groups ?? const <RimGroup>[]) {
          for (final FacilityDis dis
              in grp.facilityLimits ?? const <FacilityDis>[]) {
            final FacilitySummaryNew? fac = dis.facility;
            if ((fac?.limitGroup ?? -1) != groupId) continue;

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

  /// Footer totals using the SAME rule used in your current tables:
  /// add totals only for rows where facility.isMainLimit == true.
  GroupAmounts computeGroupTotals(List<FacilityDis> disList) {
    int totalExisting = 0;
    int totalProposed = 0;
    int totalOutstanding = 0;

    for (final FacilityDis dis in disList) {
      final FacilitySummaryNew? facility = dis.facility;
      if (facility == null) continue;

      if (facility.isMainLimit == true) {
        totalExisting += (facility.presentLimit ?? 0).toInt();
        totalProposed += (facility.proposedLimit ?? 0).toInt();
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
    if (cln.isEmpty) return null;

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
    if (raw.isEmpty) return <Reference>[];

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
    if (customers.isEmpty) return;

    bool matchesCap(FacilitySummaryNew? facility) {
      if (facility == null) return false;
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
        barrierDismissible: true,
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

    if (rimNo == null || rimNo == 0 || !canEdit) return;

    router.go(
      Routes.createFacility,
      extra: CreateFacilityArgs(
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
    );
  }

  /// Finds the index of a RimGroup by groupName (case-insensitive).
  /// Returns null if not found.
  int? findGroupIndexByName(RimSummary? rim, String name) {
    if (rim == null) return null;
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
    if (groupId == null || rimNo == null) return;
    if (groupId != ServerConstants.projectSpecificLimitsID &&
        groupId != ServerConstants.projectStandByLimitID) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getProjectList(groupId, rimNo);
    });
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
    final String category = (limitCategory ?? "").trim().toUpperCase();
    if (category.isEmpty) return benchmark;

    final List<Reference> filtered = benchmark
        .where((r) => (r.reference2 ?? "").trim().toUpperCase() == category)
        .toList();

    return filtered.isNotEmpty ? filtered : benchmark;
  }

  /// Like `matchOrFirstById`, but safely falls back to `items.first` (so
  /// selected item always exists in dropdown).
  Reference matchOrFirstByIdInList(List<Reference> items, String? id) {
    if (items.isEmpty) return Reference();

    final String target = (id ?? "").toString();
    return items.firstWhere(
      (r) => r.id?.toString() == target,
      orElse: () => items.first,
    );
  }

  /// Helper to build a stable key for a row (use what’s available/unique)
  String _rowKey(FacilitySummaryNew f) =>
      '${f.facilityId ?? ''}-${f.limitNo ?? ''}';

  String _strOr(String? value, String fallback) {
    final String? val = value?.trim();
    return (val == null || val.isEmpty) ? fallback : val;
  }

  num _numOr(num? value, num fallback) => value ?? fallback;

  bool _boolOr(bool? value, bool fallback) => value ?? fallback;
}
