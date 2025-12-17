import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/form_row.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/home/aging_summary.dart';
import 'package:wcas_frontend/models/home/documentation_summary.dart';
import 'package:wcas_frontend/models/home/home.dart';
import 'package:wcas_frontend/models/login/user.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'package:wcas_frontend/repositories/dashboard_repository.dart';
import 'state.dart';

class HomeViewModel extends Cubit<HomeState> {
  HomeViewModel() : super(HomeState(loaderStatus: LoadingStatus.loading));
  late DashboardRepository repository;

  // bool get canEdit => (pageMode == PageMode.edit);
  bool isQuickLinkClicked = false;
  Summary? summaryData;
  AgingSummary? ageingSummary;
  SummaryType? selectedSummary;
  DashboardAgeingType selectedGraphFilter = DashboardAgeingType.zeroToSevenDays;
  List<Request> worklistData = [];
  DocumentationSummary? barGraph;
  VisibleGraphType visibleGraphType = VisibleGraphType.pie;
  int rowsPerPage = 5;
  int workListPageNo = 0;
  String graphTitle = "Active Request";
  BarGraphHelper selectedBarGraphLegend = BarGraphHelper.na;
  String? selectedGraphValue;
  Map<String, List<Reference>> referenceData = {};
  bool showWorkListColors = false;
  bool showCreateRequest = false;

  // WorkList Table Filter
  List<Request?> filteredRequests = [];
  String? reqRefNoFilter;
  List<Request> requestTypeFilter = [];
  String? applicantRimFilter;
  String? applicantNameFilter;
  String? requestStatusFilter;

  String? errorText;
  List<String> wcasRoleByUser = [];
  List<User> users = [];
  List<String> roles = [];
  String assignTo = "";

  void onClickBarGraphLegend(BarGraphHelper barGraphHelper) {
    if (selectedBarGraphLegend == barGraphHelper) {
      selectedBarGraphLegend = BarGraphHelper.na;
    } else {
      selectedBarGraphLegend = barGraphHelper;
    }
    emit(state.copyWith(graphLoader: LoadingStatus.loaded));
  }

  void init(BuildContext context) async {
    repository = DashboardRepository.instance;
    showCreateReq();
    showWorkListColors = Globals.user?.currentRole?.userRole ==
            UserRole.ccuMaker ||
        Globals.user?.currentRole?.userRole == UserRole.ccuChecker ||
        Globals.user?.currentRole?.userRole == UserRole.documentationChecker ||
        Globals.user?.currentRole?.userRole == UserRole.documentationMaker;
    await getSummary();
    selectedSummary = Utils.checkRoles([UserRole.admin, UserRole.inquiryUser])
        ? SummaryType.team
        : SummaryType.me;
    await getAgeingSummary(selectedSummary ?? SummaryType.na);
    // await getWorklist();
    getUsersByRoles();
  }

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

  /// Refreshes the summary and table data by re-fetching them from the repository.
  ///
  /// This asynchronous function performs the following:
  /// - Calls `getSummary()` to update the summary data and related UI state.
  /// - Calls `getTableData()` to refresh the table data and its associated state.
  Future<void> onClickRefresh() async {
    await getSummary(isRefresh: true);
    await getAgeingSummary(selectedSummary ?? SummaryType.na);
    // await getWorklist(isRefresh: true);
  }

  Future<void> onSelectGraphFilter(DashboardAgeingType type) async {
    emit(state.copyWith(graphLoader: LoadingStatus.loading));
    selectedGraphFilter = type;
    await getWorklist();
    emit(state.copyWith(graphLoader: LoadingStatus.loaded));
  }

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
        return null;
    }
  }

  /// Handles tap events on the graph and updates the selected graph value.
  ///
  /// This asynchronous function performs the following:
  /// - Emits a `loading` status for the graph loader to indicate that the graph is being updated.
  /// - Sets the `selectedGraphValue` to the provided [text] value, representing the tapped graph element.
  /// - Emits a `loaded` status to indicate that the graph update is complete.
  ///
  /// Parameters:
  /// - [text]: A `String` representing the label or category of the tapped graph element.
  /// - [value]: An optional `int` representing the value associated with the tapped graph element.
  Future<void> onTapGraph({
    required String text,
  }) async {
    emit(state.copyWith(graphLoader: LoadingStatus.loading));
    selectedGraphValue = text;
    emit(state.copyWith(graphLoader: LoadingStatus.loaded));
  }

  /// Fetches and updates the table data based on the provided filter and updates the UI state.
  ///
  /// This asynchronous function performs the following:
  /// - Emits a `loading` status for the table loader to indicate data retrieval is in progress unless [isRefresh] is true.
  /// - Calls `repository.getRequestDetailsWorkList()` to fetch draft table data.
  /// - Updates `draftTableData` with the fetched results, or an empty list if the result is `null`.
  /// - Emits a `loaded` status if data is present, otherwise emits an `error` status.
  /// - Assigns the fetched data to `filteredData` for further use or display.
  /// - Emits a final `loaded` status to confirm completion of the data update.
  Future<void> getWorklist({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        emit(state.copyWith(refreshLoader: true));
      } else {
        emit(state.copyWith(tableLoader: LoadingStatus.loading));
      }

      worklistData = (await repository.getWorkList(
              ageingType: selectedGraphFilter,
              summaryType: selectedSummary!)) ??
          [];
      filteredRequests = worklistData;
      if (Utils.checkRoles([UserRole.admin, UserRole.businessAdmin])) {
        await fetchUserWcasRole();
      }
      emit(state.copyWith(
          tableLoader: LoadingStatus.loaded, refreshLoader: false));
    } catch (e) {
      errorText = e.toString();
      emit(state.copyWith(
          loaderStatus: LoadingStatus.error, refreshLoader: false));
    }
  }

  /// Fetches summary data from the repository and updates the UI state accordingly.
  ///
  /// This asynchronous function performs the following:
  /// - Emits a `loading` status to indicate the start of the data fetch unless [isRefresh] is true.
  /// - Retrieves summary data via `repository.getSummary()` and assigns it to `summaryData`.
  /// - Determines the `selectedSummary` based on whether there are pending items assigned to the user.
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
    } catch (e) {
      errorText = e.toString();
      emit(state.copyWith(
          loaderStatus: LoadingStatus.error, refreshLoader: false));
    }
  }

  // Pie and Bar Graph
  Future<void> getAgeingSummary(SummaryType type) async {
    try {
      emit(state.copyWith(graphLoader: LoadingStatus.loading));
      selectedGraphFilter = DashboardAgeingType.zeroToSevenDays;
      selectedSummary = type;

      if (selectedSummary == SummaryType.documentation ||
          selectedSummary == SummaryType.creditcontrol) {
        visibleGraphType = VisibleGraphType.bar;
        barGraph = await getDocumentationSummary();
        graphTitle = "Documentation Status";
      } else {
        visibleGraphType = VisibleGraphType.pie;
        ageingSummary = await repository.getDashboardAgeingCount(type);
        graphTitle = "Active Request";
      }
      await getWorklist();

      emit(state.copyWith(
          graphLoader: LoadingStatus.loaded,
          tableLoader: LoadingStatus.loaded,
          loaderStatus: LoadingStatus.loaded,
          refreshLoader: false));
    } catch (e) {
      throw e.toString();
    }
  }

  Future<DocumentationSummary?> getDocumentationSummary() async {
    try {
      DocumentationSummary? documentationSummary =
          await repository.getDocumentationSummary(
              ageing: selectedGraphFilter, type: selectedSummary);
      return documentationSummary;
    } catch (e) {
      throw e.toString();
    }
  }

  /// Filters the closed request data based on the provided [value].
  /// Filters the closed request data based on the provided [value].
  ///
  /// This method checks if the [value] is contained in any of the following fields:
  /// - Application Reference Number
  /// - Application Type Name
  /// - Customer RIM Number
  /// - Customer Name
  /// - Request Status
  ///
  /// If a match is found, the corresponding filter variable is updated and the
  /// item is included in the filtered list. After filtering, the state is updated
  /// with [LoadingStatus.empty] to indicate that the table should refresh
  Future<void> onFilter(
      {required String value,
      List<Request>? selectedTypes,
      required FilterType filterType}) async {
    requestTypeFilter = [];
    filteredRequests = worklistData.where((data) {
      bool refNoMatch = false;
      bool typeMatch = false;
      bool rimMatch = false;
      bool nameMatch = false;
      if (filterType == FilterType.applicantName) {
        nameMatch = (data.customerName ?? "").contains(value);
        applicantNameFilter = value;
      } else if (filterType == FilterType.referenceType) {
        for (Request? selectedType in (selectedTypes ?? [])) {
          if (data.applicationType?.name ==
              selectedType?.applicationType?.name) {
            requestTypeFilter.add(selectedType!);
            typeMatch = true;
          }
        }
      } else if (filterType == FilterType.applicantRim) {
        rimMatch = (data.customerRimNo?.toString() ?? "").contains(value);
        applicantRimFilter = value;
      } else if (filterType == FilterType.referenceNumber) {
        refNoMatch = (data.applicationRefNo ?? "").contains(value);
        reqRefNoFilter = value;
      }

      return refNoMatch || typeMatch || rimMatch || nameMatch;
    }).toList();
    if (filterType == FilterType.referenceType) {
      if (selectedTypes == [] || (selectedTypes ?? []).isEmpty) {
        requestTypeFilter = [];
        filteredRequests = worklistData;
      }
    }
    emit(state.copyWith(tableLoader: LoadingStatus.loaded));
  }

  void clearFilter() {
    requestTypeFilter = [];
    onFilter(
        value: "", filterType: FilterType.referenceType, selectedTypes: []);
  }

  String getSummaryText(SummaryType type) {
    SummaryType summaryType = summaryTypeStringMap.entries
        .firstWhere(
          (summary) => summary.key == type,
          orElse: () => const MapEntry(SummaryType.na, ''),
        )
        .key;
    return summaryTypeMap[summaryType] ?? "";
  }

  SummaryType getSummaryType(String text) {
    return summaryTypeStringMap.entries
        .firstWhere(
          (summary) => summary.value == text,
          orElse: () => const MapEntry(SummaryType.na, ''),
        )
        .key;
  }

  final Map<SummaryType, String> summaryTypeStringMap = {
    SummaryType.me: "dashboard.home.filter.me".tr(),
    SummaryType.business: "dashboard.home.filter.business".tr(),
    SummaryType.credit: "dashboard.home.filter.credit".tr(),
    SummaryType.documentation: "dashboard.home.filter.documentation".tr(),
    SummaryType.team: "dashboard.home.filter.team".tr(),
    SummaryType.approvingauthority:
        "dashboard.home.filter.approvingAuthority".tr(),
    SummaryType.creditcontrol: "dashboard.home.filter.creditControl".tr(),
    SummaryType.requests: "dashboard.home.filter.requests".tr(),
    SummaryType.pool: "dashboard.home.filter.pool".tr(),
    SummaryType.documentationrequest:
        "dashboard.home.filter.documentation".tr(),
    SummaryType.relationshipOfficer:
        "dashboard.home.filter.relationshipOfficer".tr(),
    SummaryType.relationshipManager:
        "dashboard.home.filter.relationshipManager".tr(),
    SummaryType.creditAnalyst: "dashboard.home.filter.creditAnalyst".tr(),
    SummaryType.unitHead: "dashboard.home.filter.unitHead".tr(),
  };

  Map<ApplicationFilterType, String> applicationTypes = {
    ApplicationFilterType.applicationOverdue:
        "dashboard.home.applicationOverdue".tr(),
    ApplicationFilterType.dueForReview: "dashboard.home.dueforReview".tr(),
    ApplicationFilterType.recentApplication:
        "dashboard.home.myRecentApplications".tr(),
    ApplicationFilterType.applicationSegment:
        "dashboard.home.applicationwithinSegment".tr()
  };

  Future<void> openApplication(Request request, int? index) async {
    try {
      emit(state.copyWith(appRefIndex: index));
      await repository.openApplication(request);
      emit(state.copyWith(appRefIndex: -1));
    } catch (e) {
      emit(state.copyWith(appRefIndex: -1));
      AlertManager().showFailureToast(e.toString());
    }
  }

  void onActionClicked(BuildContext context) {
    DialogHelper.showCustomDialog(
      title: "dashboard.home.assignTo".tr(),
      width: 400.w,
      content: BoxLayout(
        child: FormRow(
          children: [
            LabelWidget(
                label: "dashboard.home.assignTo".tr(),
                child: CustomDropdown(
                    isSearchable: true,
                    items: users.map((user) => user.id ?? '').toList(),
                    onSelected: (value) {})),
            const SizedBox(),
          ],
        ),
      ),
      actions: [
        CustomButton(
            label: "dashboard.home.assign".tr(),
            onPressed: () async {
              await assignToUser();
            })
      ],
      context: context,
    );
  }

  Future<void> downloadSpreadSmart() async {
    try {
      await repository.downloadFile(ServerConstants.spreadSmartManual);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  Future<void> downloadUserManual() async {
    try {
      await repository.downloadFile(ServerConstants.wcasManual);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  Future<void> fetchUserWcasRole() async {
    try {
      final Map<String, List<Reference>> referenceData =
          await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.roleType,
      ]);

      final List<Reference> roleTypes =
          referenceData[ReferenceDataKeys.roleType] ?? [];

      final reference1Filter = Globals.user!.currentRole!.code;
      wcasRoleByUser = roleTypes
          .where((item) => item.reference1?.trim() == reference1Filter)
          .map((item) => item.reference3 ?? '')
          .where((ref3) => ref3.isNotEmpty)
          .toList();

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  // Future<void> fetchRolesByUser(int userId, String userName) async {
  //   // emit(state.copyWith(loaderStatus: LoadingStatus.loading));
  //   roles = await repository.getRolesByUser(userId, userName);
  //   emit(state.copyWith(tableLoader: LoadingStatus.loaded));
  // }

  Future<void> getUsersByRoles() async {
    // emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      users = await repository.getUsersByRoles([]);

      emit(state.copyWith(
        tableLoader: LoadingStatus.loaded,
      ));
    } catch (e) {
      //"Cannot emit new states after calling close"
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(tableLoader: LoadingStatus.error));
    }
  }

  Future<void> assignToUser() async {
    // emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      if (assignTo.isEmpty) {
        throw Exception("No user selected for assignment.");
      }

      await repository.assignUserToApplication(assignedTo: assignTo);

      AlertManager().showSuccessToast("User assigned successfully.");

      emit(state.copyWith(tableLoader: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(tableLoader: LoadingStatus.error));
    }
  }
}
