import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/form_row.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/dashboard/home/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/home/aging_summary.dart";
import "package:wcas_frontend/models/home/documentation_summary.dart";
import "package:wcas_frontend/models/home/home.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/dashboard_repository.dart";

/// View model for dashboard home screen data, filters, graphs, and worklist.
class HomeViewModel extends SafeCubit<HomeState> {
  /// Creates a [HomeViewModel].
  HomeViewModel() : super(HomeState(loaderStatus: LoadingStatus.loading));

  /// Dashboard repository used for dashboard related API calls.
  late DashboardRepository repository;

  /// Approval repository used to load approval reference data.
  late ApprovalRepository approvalRepository;

  /// Admin repository used for admin related operations.
  late AdminRepository adminRepository;

  /// Auth repository used for logged-in user and role operations.
  late AuthRepository authRepository;

  // bool get canEdit => (pageMode == PageMode.edit);

  /// Indicates whether the quick links section is expanded.
  bool isQuickLinkClicked = false;

  /// Dashboard summary data.
  Summary? summaryData;

  /// Dashboard ageing summary data.
  AgingSummary? ageingSummary;

  /// Currently selected summary type.
  SummaryType? selectedSummary;

  /// Indicates whether an ageing filter is selected.
  bool isAgeingSelected = false;

  /// Currently selected ageing graph filter.
  DashboardAgeingType selectedGraphFilter = DashboardAgeingType.zeroToSevenDays;

  /// Worklist data returned from dashboard API.
  List<Request> worklistData = [];

  /// Documentation summary used by the bar graph.
  DocumentationSummary? barGraph;

  /// Currently visible graph type.
  VisibleGraphType visibleGraphType = VisibleGraphType.pie;

  /// Number of rows shown per page in the worklist table.
  int rowsPerPage = 5;

  /// Current page number of the worklist table.
  int workListPageNo = 0;

  /// Title displayed above the graph.
  String graphTitle = "Active Request";

  /// Selected bar graph legend helper.
  BarGraphHelper selectedBarGraphLegend = BarGraphHelper.na;

  /// Selected graph value.
  String? selectedGraphValue;

  /// Selected bar graph stage.
  String? barGraphStage;

  /// Selected bar graph credit approval type.
  String? barGraphCrApprovalType;

  /// Reference data used by the dashboard home screen.
  Map<String, List<Reference>> referenceData = {};

  /// Whether worklist rows should show business segment colors.
  bool showWorkListColors = false;

  /// Whether create request action should be shown.
  bool showCreateRequest = false;

  /// Selected documentation stage for bar graph filtering.
  DocumentationStage? docStage;

// Selected category (crApprovalDesc) label:

  /// Selected bar graph legend label.
  String? selectedBarGraphLegendLabel;

  // WorkList Table Filter

  /// Filtered worklist requests displayed in the table.
  List<Request?> filteredRequests = [];

  /// Request reference number filter value.
  String? reqRefNoFilter;

  /// Selected request type filters.
  List<Request> requestTypeFilter = [];

  /// Applicant RIM filter value.
  String? applicantRimFilter;

  /// Applicant name filter value.
  String? applicantNameFilter;

  /// Request status filter value.
  String?
      // We keep this for backward compatibility if needed, or replace.
      requestStatusFilter;

  /// Requested by filter value.
  String? requestByFilter;

  /// Received from filter value.
  String? receivedFromFilter;

  /// Selected request status list filters.
  List<String> requestStatusListFilter = [];

  /// Selected business segment list filters.
  List<String> businessSegmentListFilter = [];

  /// Whether assign user action column should be shown.
  bool showAssignUser = false;

  /// Selected assign-to detail for worklist actions.
  AssignToDetail? selectedAssignToDetail;

  /// Error text captured during failed API operations.
  String? errorText;

  /// Users available for role based assignment.
  List<User>? users;

  /// Users available for assigning a specific application.
  List<User>? userForAssigne;

  /// Currently selected assignee.
  User? selectedAssignee;

  /// Indicates whether this is the initial dashboard load.
  bool isInitialLoad = true;

  /// Names from CUSTOM_APPLICATION_TYPE reference data, including hardcoded
  /// exceptions.
  /// CCSYS is always treated as a current type even though it is not in
  /// CUSTOM_APPLICATION_TYPE.
  List<String> customApplicationTypeNames = ["CCSYS"];

  /// Fetches CUSTOM_APPLICATION_TYPE reference data and merges it into
  /// [customApplicationTypeNames].
  Future<void> _loadCustomApplicationTypes() async {
    try {
      final Map<String, List<Reference>> refData = await ReferenceDataService()
          .getReferenceData([ReferenceDataKeys.applicationTypeCustom]);
      final List<String> fetchedNames =
          (refData[ReferenceDataKeys.applicationTypeCustom] ?? [])
              .map((Reference ref) => ref.name?.trim() ?? "")
              .where((String name) => name.isNotEmpty)
              .toList();
      // Merge without duplicates
      customApplicationTypeNames =
          {...customApplicationTypeNames, ...fetchedNames}.toList();
    } on Object catch (_) {
      // Keep pre-defined names if fetch fails
    }
  }

  /// Handles selecting or clearing a bar graph legend.
  void onClickBarGraphLegend(
    String barGraphHelper, {
    DocumentationStage? selectedDocStage,
  }) {
    docStage = selectedDocStage;
    isAgeingSelected = false;
    if (selectedBarGraphLegendLabel == barGraphHelper) {
      selectedBarGraphLegendLabel = null;
      barGraphCrApprovalType = null;
    } else {
      selectedBarGraphLegendLabel = barGraphHelper;
      barGraphCrApprovalType = barGraphHelper;
    }
    emit(state.copyWith(graphLoader: LoadingStatus.loaded));
    getWorklist();
  }

  /// Initializes the dashboard home view model.
  Future<void> init(BuildContext context) async {
    isInitialLoad = true;
    isAgeingSelected = false;
    repository = DashboardRepository.instance;
    approvalRepository = ApprovalRepository.instance;
    adminRepository = AdminRepository.instance;
    authRepository = AuthRepository.instance;
    await authRepository.updateRole(
      Globals.user!.currentRole!,
    );
    await approvalRepository.fetchReference(); // set global values
    await _loadCustomApplicationTypes();
    showCreateReq();
    // showAssignUser = Utils.checkRoles([UserRole.admin,
    // UserRole.businessAdmin]);
    showWorkListColors = Globals.user?.currentRole?.userRole ==
            UserRole.ccuMaker ||
        Globals.user?.currentRole?.userRole == UserRole.ccuChecker ||
        Globals.user?.currentRole?.userRole == UserRole.documentationChecker ||
        Globals.user?.currentRole?.userRole == UserRole.documentationMaker;
    await getSummary();
    await getAgeingSummary(selectedSummary ?? SummaryType.na);
    Globals.applicationDetails = ApplicationDetails(); // reset historical data
    // final Map<String, dynamic> updatedResult =
    //     await adminRepository.getUpdatedUserData();
    // await authRepository.updateLoggedinUserData(updatedResult);
  }

  /// Determines whether create request should be visible.
  void showCreateReq() {
    if (Utils.checkRoles([
      UserRole.relationshipOfficer,
      UserRole.relationshipManager,
      UserRole.creditAnalyst,
      UserRole.creditCordinator,
    ])) {
      showCreateRequest = true;
    }
  }

  /// Refreshes the summary and table data by re-fetching them from the
  /// repository.
  ///
  /// This asynchronous function performs the following:
  /// - Calls `getSummary()` to update the summary data and related UI state.
  /// - Calls `getTableData()` to refresh the table data and its associated
  /// state.
  Future<void> onClickRefresh() async {
    await getSummary(isRefresh: true);
    await getAgeingSummary(selectedSummary ?? SummaryType.na);
    emptyGraphSelection();
  }

  /// Handles selection of an ageing graph filter.
  Future<void> onSelectGraphFilter(DashboardAgeingType type) async {
    emit(state.copyWith(graphLoader: LoadingStatus.loading));
    emit(state.copyWith(tableLoader: LoadingStatus.loading));
    selectedGraphFilter = type;
    isAgeingSelected = true;
    if (visibleGraphType == VisibleGraphType.bar) {
      barGraph = await getDocumentationSummary();
      emptyGraphSelection();
    }
    emit(state.copyWith(graphLoader: LoadingStatus.loaded));
    await getWorklist();
  }

  /// Returns the table row background color for a business segment.
  Color? getTableColor(BusinessSegment? businessSegment) {
    if (!showWorkListColors) {
      return null;
    }
    switch (businessSegment) {
      case BusinessSegment.financialInstitution:
        return AppColors.institutional;
      case BusinessSegment.financialInstitutionCF:
        return AppColors.financialInstitutionCF;
      case BusinessSegment.corporate:
        return AppColors.corporate;
      case BusinessSegment.business:
        return AppColors.business;
      case BusinessSegment.baf:
        return AppColors.otherBusinessSegment;
      case BusinessSegment.personal:
        return AppColors.otherBusinessSegment;
      default:
        return AppColors.otherBusinessSegment;
    }
  }

  /// Returns the table text color for a business segment.
  Color getTableTextColor(BusinessSegment? businessSegment) {
    if (!showWorkListColors) {
      return AppColors.black;
    }

    // financialInstitution uses a light background, so it needs black text
    if (businessSegment == BusinessSegment.financialInstitution) {
      return AppColors.black;
    }

    // All other segments, including default, null, and na, use white text
    // to contrast with AppColors.otherBusinessSegment
    return AppColors.white;
  }

  /// Clears selected graph filters and bar graph selections.
  void emptyGraphSelection() {
    docStage = null;
    selectedGraphValue = null;
    barGraphStage = null;
    barGraphCrApprovalType = null;
    selectedBarGraphLegendLabel = null;
  }

  /// Handles tap events on the graph and updates the selected graph value.
  ///
  /// This asynchronous function performs the following:
  /// - Emits a `loading` status for the graph loader to indicate that the graph
  /// is being updated.
  /// - Sets the `selectedGraphValue` to the provided [text] value, representing
  /// the tapped graph element.
  /// - Emits a `loaded` status to indicate that the graph update is complete.
  ///
  /// Parameters:
  /// - [text]: A `String` representing the label or category of the tapped
  /// graph element.
  /// - [`value`]: An optional `int` representing the value associated with the
  /// tapped graph element.
  Future<void> onTapGraph({
    required String text,
    required DocumentationStage? selectedDocStage,
  }) async {
    emit(state.copyWith(graphLoader: LoadingStatus.loading));
    isAgeingSelected = false;
    docStage = selectedDocStage;
    selectedGraphValue = text;
    barGraphStage = text;
    barGraphCrApprovalType = null;
    selectedBarGraphLegendLabel = null;
    emit(state.copyWith(graphLoader: LoadingStatus.loaded));
    await getWorklist();
  }

  /// Fetches and updates the table data based on the provided filter and
  /// updates the UI state.
  ///
  /// This asynchronous function performs the following:
  /// - Emits a `loading` status for the table loader to indicate data retrieval
  /// is in progress unless [isRefresh] is true.
  /// - Calls `repository.getRequestDetailsWorkList()` to fetch draft table
  /// data.
  /// - Updates `draftTableData` with the fetched results, or an empty list if
  /// the result is `null`.
  /// - Emits a `loaded` status if data is present, otherwise emits an `error`
  /// status.
  /// - Assigns the fetched data to `filteredData` for further use or display.
  /// - Emits a final `loaded` status to confirm completion of the data update.
  Future<void> getWorklist({bool isRefresh = false}) async {
    try {
      await getUsersByRoles();

      if (isRefresh) {
        emit(state.copyWith(refreshLoader: true));
      } else {
        emit(state.copyWith(tableLoader: LoadingStatus.loading));
      }

      worklistData = (await repository.getWorkList(
            ageingType: selectedGraphFilter,
            summaryType: selectedSummary!,
            stage: barGraphStage,
            crApprovalType: barGraphCrApprovalType,
            isBarGraph: visibleGraphType == VisibleGraphType.bar,
            isInitialLoad: isInitialLoad,
            isAgeingSelected: isAgeingSelected,
          )) ??
          [];
      filteredRequests = worklistData;
      emit(
        state.copyWith(
          tableLoader: LoadingStatus.loaded,
          refreshLoader: false,
        ),
      );
      isInitialLoad = false;
    } on Object catch (e) {
      errorText = e.toString();
      emit(
        state.copyWith(
          tableLoader: LoadingStatus.error,
          refreshLoader: false,
        ),
      );
      isInitialLoad = false;
    }
  }

  /// Fetches summary data from the repository and updates the UI state
  /// accordingly.
  ///
  /// This asynchronous function performs the following:
  /// - Emits a `loading` status to indicate the start of the data fetch unless
  /// [isRefresh] is true.
  /// - Retrieves summary data via `repository.getSummary()` and assigns it to
  /// `summaryData`.
  /// - Determines the `selectedSummary` based on whether there are pending
  /// items assigned to the user.
  /// - Updates the `filterLabel` with the selected summary value.
  /// - Emits a `loaded` status upon successful data retrieval and processing.
  /// - Emits an `error` status if an exception occurs during the fetch.
  Future<void> getSummary({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        emit(state.copyWith(refreshLoader: true));
      } else {
        emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      }
      summaryData = await repository.getSummary();
      final Map<int, AssignToDetail?>? firstValidMap =
          summaryData?.firstValidMap();
      selectedSummary = typeForMap(summaryData, firstValidMap);
    } on Object catch (e) {
      errorText = e.toString();
      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.error,
          refreshLoader: false,
        ),
      );
    }
  }

  /// Returns the first key from a summary count map.
  int? firstKeyForSummaryCount(Map<int, AssignToDetail?>? map) {
    if (map == null || map.isEmpty) {
      return null;
    }
    // Map preserves insertion order in Dart; .keys.first is the first inserted
    // key.
    return map.keys.first;
  }

  // Pie and Bar Graph
  /// Loads ageing summary or documentation graph data for the selected summary type.
  Future<void> getAgeingSummary(SummaryType type) async {
    try {
      emit(state.copyWith(graphLoader: LoadingStatus.loading));
      emit(state.copyWith(tableLoader: LoadingStatus.loading));
      selectedGraphFilter = DashboardAgeingType.zeroToSevenDays;
      isAgeingSelected = false;
      selectedGraphValue = null;
      barGraphStage = null;
      barGraphCrApprovalType = null;
      selectedBarGraphLegendLabel = null;
      selectedSummary = type;

      users = [];

      if (selectedSummary == SummaryType.documentation ||
          selectedSummary == SummaryType.creditcontrol) {
        visibleGraphType = VisibleGraphType.bar;

        barGraph = await getDocumentationSummary();
        graphTitle = "Documentation Status";
      } else {
        //DC , DM. CCU-M, CCU-C -> bar
        if (Utils.checkRoles([
          UserRole.documentationChecker,
          UserRole.documentationMaker,
          UserRole.ccuMaker,
          UserRole.ccuChecker,
        ])) {
          visibleGraphType = VisibleGraphType.bar;

          barGraph = await getDocumentationSummary();
          graphTitle = "Documentation Status";
        } else {
          visibleGraphType = VisibleGraphType.pie;
          ageingSummary = await repository.getDashboardAgeingCount(type);
          graphTitle = "Active Request";
        }
      }
      emit(state.copyWith(graphLoader: LoadingStatus.loaded));
      await getWorklist();
      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.loaded,
          refreshLoader: false,
        ),
      );
    } on Object catch (e) {
      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.loaded,
          graphLoader: LoadingStatus.error,
          tableLoader: LoadingStatus.error,
        ),
      );
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Fetches documentation summary data used by the bar graph.
  Future<DocumentationSummary?> getDocumentationSummary() async {
    try {
      final DocumentationSummary? documentationSummary =
          await repository.getDocumentationSummary(
        ageing: selectedGraphFilter,
        type: selectedSummary,
        isAgeingSelected: isAgeingSelected,
      );
      return documentationSummary;
    } on Object catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Filters the closed request data based on the provided [value].
  /// Filters the closed request data based on the provided [value].
  ///
  /// This method checks if the [value] is contained in any of the following
  /// fields:
  /// - Application Reference Number
  /// - Application Type Name
  /// - Customer RIM Number
  /// - Customer Name
  /// - Request Status
  ///
  /// If a match is found, the corresponding filter variable is updated and the
  /// item is included in the filtered list. After filtering, the state is
  /// updated
  /// with [LoadingStatus.empty] to indicate that the table should refresh
  Future<void> onFilter({
    required String value,
    required FilterType filterType,
    List<Request>? selectedTypes,
  }) async {
    requestTypeFilter = [];
    filteredRequests = worklistData.where((data) {
      bool refNoMatch = false;
      bool typeMatch = false;
      bool rimMatch = false;
      bool nameMatch = false;
      if (filterType == FilterType.applicantName) {
        applicantRimFilter = null;
        requestStatusListFilter = [];
        reqRefNoFilter = null;
        requestByFilter = null;
        businessSegmentListFilter = [];
        receivedFromFilter = null;
        nameMatch = (data.customerName ?? "")
            .toLowerCase()
            .contains(value.toLowerCase());
        applicantNameFilter = value;
      } else if (filterType == FilterType.referenceType) {
        applicantNameFilter = null;
        applicantRimFilter = null;
        requestStatusListFilter = [];
        reqRefNoFilter = null;
        requestByFilter = null;
        businessSegmentListFilter = [];
        receivedFromFilter = null;
        for (final Request? selectedType in (selectedTypes ?? [])) {
          final String? selectedName = selectedType?.applicationType?.name;
          if (selectedName ==
              "dashboard.home.historicalApplicationTypes".tr()) {
            final String? dataName = data.applicationType?.name?.trim();
            if (dataName != null &&
                dataName.isNotEmpty &&
                !customApplicationTypeNames.contains(dataName)) {
              requestTypeFilter.add(selectedType!);
              typeMatch = true;
            }
          } else {
            if (data.applicationType?.name == selectedName) {
              requestTypeFilter.add(selectedType!);
              typeMatch = true;
            }
          }
        }
      } else if (filterType == FilterType.applicantRim) {
        applicantNameFilter = null;
        requestStatusListFilter = [];
        reqRefNoFilter = null;
        requestByFilter = null;
        businessSegmentListFilter = [];
        receivedFromFilter = null;
        rimMatch = (data.customerRimNo?.toString() ?? "").contains(value);
        applicantRimFilter = value;
      } else if (filterType == FilterType.referenceNumber) {
        applicantNameFilter = null;
        applicantRimFilter = null;
        requestStatusListFilter = [];
        requestByFilter = null;
        businessSegmentListFilter = [];
        receivedFromFilter = null;
        refNoMatch = (data.applicationRefNo ?? "")
            .toLowerCase()
            .contains(value.toLowerCase());
        reqRefNoFilter = value;
      } else if (filterType == FilterType.requestBy) {
        applicantNameFilter = null;
        applicantRimFilter = null;
        reqRefNoFilter = null;
        requestStatusListFilter = [];
        businessSegmentListFilter = [];
        receivedFromFilter = null;
        requestByFilter = value;
        final bool byMatch = (data.requestedBy ?? "")
            .toLowerCase()
            .contains(value.toLowerCase());
        return byMatch;
      } else if (filterType == FilterType.requestStatus) {
        applicantNameFilter = null;
        applicantRimFilter = null;
        reqRefNoFilter = null;
        requestByFilter = null;
        businessSegmentListFilter = [];
        receivedFromFilter = null;
        if (selectedTypes == null || selectedTypes.isEmpty) {
          return true; // Show all if none selected
        }
        return selectedTypes
            .any((statusReq) => data.status == statusReq.status);
      } else if (filterType == FilterType.businessSegment) {
        applicantNameFilter = null;
        applicantRimFilter = null;
        reqRefNoFilter = null;
        requestStatusListFilter = [];
        requestByFilter = null;
        receivedFromFilter = null;
        if (selectedTypes == null || selectedTypes.isEmpty) {
          return true; // Show all if none selected
        }
        return selectedTypes.any(
          (segReq) =>
              data.businessSegment?.name == segReq.businessSegment?.name,
        );
      } else if (filterType == FilterType.receivedFrom) {
        applicantNameFilter = null;
        applicantRimFilter = null;
        reqRefNoFilter = null;
        requestStatusListFilter = [];
        requestByFilter = null;
        businessSegmentListFilter = [];
        receivedFromFilter = value;
        final bool byMatch = (data.receivedFrom ?? "")
            .toLowerCase()
            .contains(value.toLowerCase());
        return byMatch;
      }

      return refNoMatch || typeMatch || rimMatch || nameMatch;
    }).toList();
    if (filterType == FilterType.referenceType) {
      if (selectedTypes == null || selectedTypes.isEmpty) {
        requestTypeFilter = [];
        filteredRequests = worklistData;
      }
    } else if (filterType == FilterType.requestStatus) {
      if (selectedTypes == null || selectedTypes.isEmpty) {
        requestStatusListFilter = [];
        filteredRequests = worklistData;
      } else {
        requestStatusListFilter =
            selectedTypes.map((e) => e.status ?? "").toList();
      }
    } else if (filterType == FilterType.businessSegment) {
      if (selectedTypes == null || selectedTypes.isEmpty) {
        businessSegmentListFilter = [];
        filteredRequests = worklistData;
      } else {
        businessSegmentListFilter =
            selectedTypes.map((e) => e.businessSegment?.name ?? "").toList();
      }
    }
    emit(state.copyWith(tableLoader: LoadingStatus.loaded));
  }

  /// Returns display text for a summary type.
  String getSummaryText(SummaryType type) {
    final SummaryType summaryType = summaryTypeStringMap.entries
        .firstWhere(
          (summary) => summary.key == type,
          orElse: () => const MapEntry(SummaryType.na, ""),
        )
        .key;
    return summaryTypeMap[summaryType] ?? "";
  }

  /// Returns summary type matching the given display text.
  SummaryType getSummaryType(String text) {
    return summaryTypeStringMap.entries
        .firstWhere(
          (summary) => summary.value == text,
          orElse: () => const MapEntry(SummaryType.na, ""),
        )
        .key;
  }

  /// Mapping between summary types and translated labels.
  final Map<SummaryType, String> summaryTypeStringMap = {
    SummaryType.me: "dashboard.home.filter.me".tr(),
    SummaryType.business: "dashboard.home.filter.business".tr(),
    SummaryType.credit: "dashboard.home.filter.credit".tr(),
    SummaryType.documentation: "dashboard.home.filter.documentation".tr(),
    SummaryType.team: "dashboard.home.filter.team".tr(),
    SummaryType.approvingauthority:
        "dashboard.home.filter.approvingAuthority".tr(),
    SummaryType.creditcontrol: "dashboard.home.filter.creditControl".tr(),
    SummaryType.creditcontrolCCSYS:
        "dashboard.home.filter.creditControl-CCSYS".tr(),
    SummaryType.requests: "dashboard.home.filter.requests".tr(),
    SummaryType.pool: "dashboard.home.filter.pool".tr(),
    SummaryType.documentationrequest:
        "dashboard.home.filter.documentation".tr(),
    SummaryType.ro: "dashboard.home.filter.relationshipOfficer".tr(),
    SummaryType.rm: "dashboard.home.filter.relationshipManager".tr(),
    SummaryType.dc: "dashboard.home.filter.DC".tr(),
    SummaryType.unitHead: "dashboard.home.filter.unitHead".tr(),
    SummaryType.cam: "dashboard.home.filter.cam".tr(),
    SummaryType.tlb: "dashboard.home.filter.tlb".tr(),
    SummaryType.shb: "dashboard.home.filter.shb".tr(),
    SummaryType.rmb: "dashboard.home.filter.rmb".tr(),
    SummaryType.creditCordinator: "dashboard.home.filter.creditCordinator".tr(),
    SummaryType.ccood: "dashboard.home.filter.creditCordinator".tr(),
    SummaryType.ca: "dashboard.home.filter.creditAnalyst".tr(),
    SummaryType.tld1: "dashboard.home.filter.tl-d1".tr(),
    SummaryType.shld: "dashboard.home.filter.sh-d".tr(),
    SummaryType.shlc: "dashboard.home.filter.sh-c".tr(),
    SummaryType.shlb1: "dashboard.home.filter.sh-b1".tr(),
    SummaryType.shlb: "dashboard.home.filter.sh-b".tr(),
    SummaryType.ccuMaker: "dashboard.home.filter.ccuMaker".tr(),
    SummaryType.ccProxy: "dashboard.home.filter.ccProxy".tr(),
    SummaryType.ccProxyApprover: "dashboard.home.filter.ccProxyApprover".tr(),
    SummaryType.bdProxy: "dashboard.home.filter.bdProxy".tr(),
    SummaryType.pendingWithRelationShipTeam: "Relationship Team",
    SummaryType.pendingWithBusinessTeam: "Business Team",
  };

  /// Mapping between application filter types and translated labels.
  Map<ApplicationFilterType, String> applicationTypes = {
    ApplicationFilterType.applicationOverdue:
        "dashboard.home.applicationOverdue".tr(),
    ApplicationFilterType.dueForReview: "dashboard.home.dueforReview".tr(),
    ApplicationFilterType.recentApplication:
        "dashboard.home.myRecentApplications".tr(),
    ApplicationFilterType.applicationSegment:
        "dashboard.home.applicationwithinSegment".tr(),
  };

  /// Opens the selected request application.
  Future<void> openApplication(Request request, int? index) async {
    try {
      emit(state.copyWith(appRefIndex: index));
      await repository.openApplication(request);
      emit(state.copyWith(appRefIndex: -1));
    } on Object catch (e) {
      emit(state.copyWith(appRefIndex: -1));
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Handles assign action click for a worklist item.
  Future<void> onActionClicked(
    BuildContext context,
    String? appRefNo,
    AssignToDetail? assgnToDetail,
  ) async {
    if (assgnToDetail?.userAction == ServerConstants.assignToMeActionDM ||
        assgnToDetail?.userAction == ServerConstants.assignToMeActionCA) {
      await assignToUser(appRefNo);
      await onClickRefresh();
    } else {
      await getUsersForAssigne(appRefNo);
      if (!context.mounted) {
        return;
      }
      await DialogHelper.showCustomDialog(
        title: "dashboard.home.assignTo".tr(),
        width: 400.w,
        content: BoxLayout(
          child: FormRow(
            children: [
              LabelWidget(
                label: "dashboard.home.assignTo".tr(),
                child: CustomDropdown<User?>(
                  isSearchable: true,
                  showClearIcon: false,
                  itemBuilder: (context, item, {isDisabled, isSelected}) =>
                      dropdownItemBuildWidget(
                    "${item?.name} - ${item?.selectedRole}",
                  ),
                  items: userForAssigne,
                  selectedItems:
                      selectedAssignee == null ? [] : [selectedAssignee],
                  dropdownBuilder: (context, item) => item == null
                      ? const SizedBox()
                      : dropdownBuilderWidget(
                          text: "${item.name} - ${item.selectedRole}",
                        ),
                  filterFn: (User? item, String filter) {
                    return (item?.name ?? item?.selectedRole ?? "")
                        .toLowerCase()
                        .contains(filter.toLowerCase());
                  },
                  onSelected: (value) {
                    selectedAssignee = value[0];
                  },
                ),
              ),
              const SizedBox(),
            ],
          ),
        ),
        actions: [
          CustomButton(
            label: "dashboard.home.assign".tr(),
            onPressed: () async {
              await assignToUser(appRefNo);
              if (context.mounted) {
                Navigator.of(context).pop(true);
                await onClickRefresh();
              }
            },
          ),
        ],
        context: context,
      );
    }
  }

  /// Downloads the Spread Smart manual.
  Future<void> downloadSpreadSmart() async {
    try {
      await repository.downloadFile(EnvConfig.spreadSmartManual);
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Downloads the WCAS user manual.
  Future<void> downloadUserManual() async {
    try {
      await repository.downloadFile(EnvConfig.wcasManual);
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Fetches users based on roles available for the selected summary.
  Future<void> getUsersByRoles() async {
    final String? bpmRoleStr = summaryFirstStringForType();

    if (bpmRoleStr == null) {
      users = [];
      showAssignUser = false;
      return;
    }

    showAssignUser = true;
    final List<String> convertedresData = bpmRoleStr.split(",");

    final List<int?> roleIds = convertedresData.map(int.parse).toList();
    final Set<int?> wanted = roleIds.toSet();
    final List<Map<String, int>> bpmRolesMap = Globals.superBpmRolesId;

    final List<String> roles = bpmRolesMap
        .expand(
          (Map<String, int> bpmRole) => bpmRole.entries,
        ) // turn each map into key/value entries
        .where((MapEntry<String, int> roleA) => wanted.contains(roleA.value))
        .map((MapEntry<String, int> roleB) => roleB.key)
        .toList();

    final List<String> ogRoles = [];

    for (final String role in roles) {
      if (!ogRoles.contains(role)) {
        ogRoles.add(role);
      }
    }

    if (ogRoles.isNotEmpty) {
      users = await repository.getUsersByRoles(ogRoles);
    } else {
      users = [];
    }
  }

  /// Fetches users available for assigning the given application.
  Future<void> getUsersForAssigne(String? apprefNo) async {
    final String? bpmRoleStr = summaryFirstStringForType();

    if (bpmRoleStr == null) {
      userForAssigne = [];
      showAssignUser = false;
      return;
    }

    showAssignUser = true;
    final List<String> convertedresData = bpmRoleStr.split(",");

    final List<int?> roleIds = convertedresData.map(int.parse).toList();
    final Set<int?> wanted = roleIds.toSet();
    final List<Map<String, int>> bpmRolesMap = Globals.superBpmRolesId;

    final List<String> roles = bpmRolesMap
        .expand(
          (Map<String, int> bpmRole) => bpmRole.entries,
        ) // turn each map into key/value entries
        .where((MapEntry<String, int> roleA) => wanted.contains(roleA.value))
        .map((MapEntry<String, int> roleB) => roleB.key)
        .toList();

    final List<String> ogRoles = [];

    for (final String role in roles) {
      if (!ogRoles.contains(role)) {
        ogRoles.add(role);
      }
    }

    if (ogRoles.isNotEmpty) {
      userForAssigne = await repository.getUsersForAssigne(ogRoles, apprefNo);
    } else {
      userForAssigne = [];
    }
  }

  /// Assigns the selected user to the given application.
  Future<void> assignToUser(String? apprefNo) async {
    try {
      if (selectedAssignee == null &&
          selectedAssignToDetail?.userAction !=
              ServerConstants.assignToMeActionCA &&
          selectedAssignToDetail?.userAction !=
              ServerConstants.assignToMeActionDM) {
        throw ApiException("No user selected for assignment.");
      }

      await repository.assignUserToApplication(
        assignedTo: selectedAssignee?.id,
        appRefNo: apprefNo,
        assignedRole: selectedAssignee?.selectedRoleName,
        assignedRoleId: selectedAssignee?.selectedRoleId,
        assignedRoleName: selectedAssignee?.selectedRoleName,
        assignToDetail: selectedAssignToDetail,
      );

      AlertManager().showSuccessToast(
        "Application ${apprefNo ?? ''} has been assigned "
        "to ${selectedAssignee?.name ?? Globals.user?.name} successfully",
      );
      selectedAssignee = null;

      emit(state.copyWith(tableLoader: LoadingStatus.loaded));
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      selectedAssignee = null;
    }
  }

  /// Returns the first non-empty String value for the given SummaryType,
  /// or null if the corresponding map is null/empty or has no non-empty values.
  String? summaryFirstStringForType() {
    final Map<int, AssignToDetail?>? summaryTypeMap =
        mapForType(summaryData, selectedSummary);
    selectedAssignToDetail = summaryTypeMap?.values.first;
    if (summaryTypeMap == null || summaryTypeMap.isEmpty) {
      return null;
    }

    // Return the first non-empty string value (preserves insertion order)
    for (final AssignToDetail? assignToDetail in summaryTypeMap.values) {
      final String? role = assignToDetail?.assingToRoles?.trim();
      if (role != null && role.isNotEmpty) {
        return role;
      }
    }
    return null;
  }

  /// Returns the summary type matching the provided summary map.
  SummaryType? typeForMap(Summary? summary, Map<int, AssignToDetail?>? map) {
    if (summary == null || map == null) {
      return SummaryType.na;
    }

    // Pending buckets
    if (identical(map, summary.pendingWithMe)) {
      return SummaryType.me;
    }
    if (identical(map, summary.pendingWithBusiness)) {
      return SummaryType.business;
    }
    if (identical(map, summary.pendingWithCredit)) {
      return SummaryType.credit;
    }
    if (identical(map, summary.pendingWithDocumentation)) {
      return SummaryType.documentation;
    }
    if (identical(map, summary.pendingWithTeam)) {
      return SummaryType.team;
    }
    if (identical(map, summary.pendingWithApprovingAuthority)) {
      return SummaryType.approvingauthority;
    }
    if (identical(map, summary.pendingWithCreditControl)) {
      return SummaryType.creditcontrol;
    }
    if (identical(map, summary.pendingWithCreditControlCCSYS)) {
      return SummaryType.creditcontrol;
    }
    if (identical(map, summary.pendingWithPool)) {
      return SummaryType.pool;
    }
    if (identical(map, summary.returnedToCA)) {
      return SummaryType.creditCordinator;
    }

    // “Requests”
    if (identical(map, summary.recommentedRequest)) {
      return SummaryType.requests;
    }
    if (identical(map, summary.requestToRecommended)) {
      return SummaryType.requests;
    }

    // “Returned to …” buckets
    if (identical(map, summary.returnedRequestDocumentation)) {
      return SummaryType.documentationrequest;
    }
    if (identical(map, summary.returnedToRO)) {
      return SummaryType.ro;
    }
    if (identical(map, summary.returnedToRM)) {
      return SummaryType.rm;
    }
    if (identical(map, summary.returnedToCA)) {
      return SummaryType.ca;
    }
    if (identical(map, summary.returnedToCAM)) {
      return SummaryType.cam;
    }
    if (identical(map, summary.returnedToTLB)) {
      return SummaryType.tlb;
    }
    if (identical(map, summary.returnedToSHB)) {
      return SummaryType.shb;
    }
    if (identical(map, summary.returnedToRMB)) {
      return SummaryType.rmb;
    }
    if (identical(map, summary.returnedToCCUM)) {
      return SummaryType.ccuMaker;
    }
    if (identical(map, summary.returnedToTLD1)) {
      return SummaryType.tld1;
    }
    if (identical(map, summary.returnedToSHD)) {
      return SummaryType.shld;
    }
    if (identical(map, summary.returnedToSHC)) {
      return SummaryType.shlc;
    }
    if (identical(map, summary.returnedToSHB1)) {
      return SummaryType.shlb1;
    }
    if (identical(map, summary.returnedToSHBHyphen)) {
      return SummaryType.shlb;
    }
    if (identical(map, summary.returnedToCCP)) {
      return SummaryType.ccProxy;
    }
    if (identical(map, summary.returnedToCCPA)) {
      return SummaryType.ccProxyApprover;
    }
    if (identical(map, summary.returnedToBDP)) {
      return SummaryType.bdProxy;
    }
    if (identical(map, summary.returnedToCCUM)) {
      return SummaryType.unitHead;
    }

    if (identical(map, summary.pendingWithBusinessTeam)) {
      return SummaryType.pendingWithBusinessTeam;
    }
    if (identical(map, summary.pendingWithRelationShipTeam)) {
      return SummaryType.pendingWithRelationShipTeam;
    }

    // No match
    return null;
  }

  /// pick the correct Map<>? from Summary for this enum.
  Map<int, AssignToDetail?>? mapForType(
    Summary? summary,
    SummaryType? summaryType,
  ) {
    if (summary == null) {
      return null;
    }
    switch (summaryType) {
      // Pending buckets
      case SummaryType.me:
        return summary.pendingWithMe;
      case SummaryType.business:
        return summary.pendingWithBusiness;
      case SummaryType.credit:
        return summary.pendingWithCredit;
      case SummaryType.documentation:
        return summary.pendingWithDocumentation;
      case SummaryType.team:
        return summary.pendingWithTeam;
      case SummaryType.approvingauthority:
        return summary.pendingWithApprovingAuthority;
      case SummaryType.creditcontrol:
        return summary.pendingWithCreditControl;
      case SummaryType.creditcontrolCCSYS:
        return summary.pendingWithCreditControlCCSYS;
      case SummaryType.pool:
        return summary.pendingWithPool;
      case SummaryType.creditCordinator:
        return summary.returnedToCA;

      // // “Requests” (recommended)
      case SummaryType.requests:
        return summary.recommentedRequest;
      // “Returned to …” buckets
      case SummaryType.documentationrequest:
        return summary.returnedRequestDocumentation;
      case SummaryType.ro:
        return summary.returnedToRO;
      case SummaryType.rm:
        return summary.returnedToRM;
      case SummaryType.ca:
        return summary.returnedToCA;
      case SummaryType.cam:
        return summary.returnedToCAM;
      case SummaryType.tlb:
        return summary.returnedToTLB;
      case SummaryType.shb:
        return summary.returnedToSHB;
      case SummaryType.rmb:
        return summary.returnedToRMB;
      case SummaryType.ccuMaker:
        return summary.returnedToCCUM;
      case SummaryType.tld1:
        return summary.returnedToTLD1;
      case SummaryType.shld:
        return summary.returnedToSHD; // "SH-D"
      case SummaryType.shlc:
        return summary.returnedToSHC; // "SH-c"
      case SummaryType.shlb1:
        return summary.returnedToSHB1; // "SH-B1"
      case SummaryType.shlb:
        return summary.returnedToSHBHyphen; // "SH-B"
      case SummaryType.ccProxy:
        return summary.returnedToCCP;
      case SummaryType.ccProxyApprover:
        return summary.returnedToCCPA;
      case SummaryType.bdProxy:
        return summary.returnedToBDP;
      case SummaryType.unitHead:
        return summary.returnedToCCUM;
      case SummaryType.pendingWithBusinessTeam:
        return summary.pendingWithBusinessTeam;
      case SummaryType.pendingWithRelationShipTeam:
        return summary.pendingWithRelationShipTeam;
      default:
        return null;
    }
  }
}
