//import 'package:easy_localization/easy_localization.dart';
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/dashboard_repository.dart";

class AdvancedSearchViewModel extends SafeCubit<AdvancedSearchState> {
  AdvancedSearchViewModel()
      : super(AdvancedSearchState(loaderStatus: LoadingStatus.loading));
  DashboardRepository repository = DashboardRepository();

  /// init function
  Future<void> init(context) async {
    logger.i("initialising AdvancedSearchViewModel");
    await loadReferenceData();

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Names from CUSTOM_APPLICATION_TYPE reference data, including hardcoded
  /// exceptions.
  /// CCSYS is always treated as a current type even though it is not in
  /// CUSTOM_APPLICATION_TYPE.
  List<String> customApplicationTypeNames = ["CCSYS"];

  String? applicationRefNo;
  String? customerRimNo;
  String? groupId;

  List<Reference>? selectedRegions;
  List<Reference>? selectedSegments;
  Reference? selectedRequestStatus;
  Reference? selectedSearchCriteria;
  List<Request> selectedFilterTypeData = [];
  List<Reference>? selectedRoles;
  List<Role> users = [];
  List<User> userModels = [];
  List<User> userList = [];
  User? selectedUserName;
  User? selectedRM;
  List<Request> workList = [];
  List<Request> filteredWorkList = [];

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Map<String, List<Reference>> referenceData = {};

  String? reqRefNoFilter;

  Reference? requestTypeFilter;

  String? applicantRimFilter;

  String? applicantNameFilter;

  /// Submits the form and resets the loader status to [LoadingStatus.loaded].
  /// If the form is not valid, it emits a new [AdvancedSearchState] with the
  /// loader status set to [LoadingStatus.loaded].
  ///
  /// This is called when the submit button is pressed.

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

  Future<void> onSubmitButtonPress() async {
    try {
      if (!(formKey.currentState?.validate() ?? false)) {
        AlertManager()
            .showFailureToast("dashboard.advancedSearch.requiredFeild".tr());
        return;
      }
      String selectedStatus = "";
      if (selectedRequestStatus?.name == "In Progress") {
        selectedStatus = "inProgress";
      } else if (selectedRequestStatus?.name == "Completed") {
        selectedStatus = "completed";
      } else {
        selectedStatus = "all";
      }
      workList = await repository.getWorklistSearchCriteria(
        rmName: selectedRM?.id,
        key: selectedStatus,
        applicationRefNo: applicationRefNo,
        customerRim: customerRimNo,
        groupId: groupId,
        pendingUser: selectedUserName?.id,
        pendingWith: (selectedRoles != null && selectedRoles!.isNotEmpty)
            ? selectedRoles!.map((e) => e.reference2).join(",")
            : null,
        segment: (selectedSegments?.isNotEmpty ?? false)
            ? selectedSegments!.map((e) => e.name).join(",")
            : null,
        region: (selectedRegions?.isNotEmpty ?? false)
            ? selectedRegions!.map((e) => e.name).join(",")
            : null,
      );

      filteredWorkList = workList;
      emit(state.copyWith(tableloader: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(tableloader: LoadingStatus.error));
      AlertManager().showFailureToast("Error: ${e.toString()}");
    }
  }

  /// Resets all the search criteria to null and emits a new
  /// [AdvancedSearchState] with the loader status set to
  /// [LoadingStatus.loaded].
  ///
  /// This is called when the reset button is pressed.
  void onResetButtonPress() {
    selectedRM = null;
    selectedRoles = [];
    selectedFilterTypeData = [];
    formKey.currentState?.reset();
    applicationRefNo = null;
    customerRimNo = null;
    groupId = null;
    selectedRegions = null;
    selectedSegments = null;
    setRequestStatusValue();
    workList = [];
    filteredWorkList = [];
    selectedSearchCriteria = null;
    emit(state.copyWith(tableloader: LoadingStatus.empty));
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

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
  void onFilter({
    required String value,
    required FilterType filterType,
    List<Request> selectedTypes = const [],
  }) {
    emit(state.copyWith(tableloader: LoadingStatus.loading));

    // Store filters
    switch (filterType) {
      case FilterType.referenceNumber:
        reqRefNoFilter = value;

      case FilterType.applicantRim:
        applicantRimFilter = value;

      case FilterType.applicantName:
        applicantNameFilter = value;

      case FilterType.referenceType:
      case FilterType.applicationType:
        selectedFilterTypeData = selectedTypes;
      default:
        break;
    }

    // No filters -> return full list
    final noFilters = (reqRefNoFilter?.isEmpty ?? true) &&
        (applicantRimFilter?.isEmpty ?? true) &&
        (applicantNameFilter?.isEmpty ?? true) &&
        selectedFilterTypeData.isEmpty;

    if (noFilters) {
      filteredWorkList = List.from(workList);
      emit(state.copyWith(tableloader: LoadingStatus.loaded));
      return;
    }

    filteredWorkList = workList.where((data) {
      // Reference Number
      if (reqRefNoFilter?.isNotEmpty == true &&
          !(data.applicationRefNo ?? "")
              .toLowerCase()
              .contains(reqRefNoFilter!.toLowerCase())) {
        return false;
      }

      // Applicant RIM
      if (applicantRimFilter?.isNotEmpty == true &&
          !(data.customerRimNo?.toString() ?? "")
              .contains(applicantRimFilter!)) {
        return false;
      }

      // Applicant Name
      if (applicantNameFilter?.isNotEmpty == true &&
          !(data.customerName ?? "")
              .toLowerCase()
              .contains(applicantNameFilter!.toLowerCase())) {
        return false;
      }

      // Request / Application Type (IMPORTANT FIX)
      if (selectedFilterTypeData.isNotEmpty) {
        final bool matchesHistorical = selectedFilterTypeData.any(
          (selected) =>
              selected.reqRefType?.name ==
              "dashboard.home.historicalApplicationTypes".tr(),
        );

        final String dataName = (data.reqRefType?.name ?? "").trim();
        final bool isHistoricalData = dataName.isNotEmpty &&
            !customApplicationTypeNames.contains(dataName);

        final bool matchesCustom = selectedFilterTypeData.any(
          (selected) =>
              selected.reqRefType?.name !=
                  "dashboard.home.historicalApplicationTypes".tr() &&
              data.reqRefType?.name == selected.reqRefType?.name,
        );

        if (!(matchesHistorical && isHistoricalData) && !matchesCustom) {
          return false;
        }
      }

      return true;
    }).toList();

    logger.i("Filtered rows: ${filteredWorkList.length}");
    emit(state.copyWith(tableloader: LoadingStatus.loaded));
  }

  /// Loads reference data for search criteria, segment types, region list,
  /// advance request types, and role types. Populates the [referenceData] map
  /// with the fetched data. If an error occurs during the fetching process,
  /// it updates the loader status to [LoadingStatus.error].

  Future<void> loadReferenceData() async {
    try {
      referenceData = await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.searchCriteria,
        ReferenceDataKeys.segmentType,
        ReferenceDataKeys.regionList,
        ReferenceDataKeys.advanceRequestType,
        ReferenceDataKeys.roleType,
        ReferenceDataKeys.applicationType,
        ReferenceDataKeys.transactionType,
        ReferenceDataKeys.applicationTypeCustom,
      ]);

      final List<String> fetchedNames =
          (referenceData[ReferenceDataKeys.applicationTypeCustom] ?? [])
              .map((Reference ref) => ref.name?.trim() ?? "")
              .where((String name) => name.isNotEmpty)
              .toList();
      customApplicationTypeNames =
          {...customApplicationTypeNames, ...fetchedNames}.toList();

      setRequestStatusValue();
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// to set the default value for the requested status field
  void setRequestStatusValue() {
    referenceData[ReferenceDataKeys.advanceRequestType]?.forEach(
      (element) {
        if (ServerConstants.advancedRequestTypeId == element.id) {
          selectedRequestStatus = element;
        }
      },
    );
    logger.i(selectedRequestStatus?.name);
    // emit(state.copyWith(tableloader: LoadingStatus.loaded));
  }

  /// Returns a list of role codes from the reference data.
  /// The list is retrieved by calling [getRoleList] and mapping it to a list
  /// of strings.
  List<String> getRoleCodes() {
    return getRoleList()!.map((e) => e.reference3!).toList();
  }

  /// Retrieves the user list from the database, and updates the state with it.
  ///
  /// If there is an error, it sets the loader status to [LoadingStatus.error].
  ///
  /// This function is called when the view is first loaded.

  Future<void> getUserList(List<Reference> roleData) async {
    try {
      emit(state.copyWith(fieldLoader: true));

      // This already gives you List<User>
      userList.clear();
      final List<User> users = await repository.getUserByRole(
        roleData
            .map((e) => e.reference3)
            .where((ref) => ref != null && ref.isNotEmpty)
            .cast<String>() // Ensures type safety
            .toList(),
      );

      // Remove duplicates by userId
      userList = {for (final user in users) user.id: user}.values.toList();

      emit(
        state.copyWith(
          fieldLoader: false,
          loaderStatus: LoadingStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          fieldLoader: false,
          loaderStatus: LoadingStatus.error,
        ),
      );
      AlertManager().showFailureToast("Error fetching users: $e");
    }
  }

  /// Returns a list of roles, excluding the following:
  /// - ADM (Administrator)
  /// - INQUSR (Inquiry User)
  /// - LMT (Limited User)
  List<Reference>? getRoleList() {
    List<Reference>? roleData = referenceData[ReferenceDataKeys.roleType];
    roleData = roleData
        ?.where(
          (element) => ((element.id != ServerConstants.admId) &&
              (element.id != ServerConstants.inqusrId) &&
              (element.id != ServerConstants.lmtId)),
        )
        .toList();
    return roleData;
  }

  /// Returns a list of users who are assigned the Role Manager (RM) role.
  ///
  /// This function iterates over the list of users and checks if each user has
  /// the RM role. If a user has the RM role, their users are added to the
  /// [rmUsers] list. The function returns the [rmUsers] list, or an empty list
  /// if no users have the RM role.
  void getRmUsers() {}

  /// Called when a search criteria is selected.
  ///
  /// Stores the selected search criteria in the state and sets the loader
  /// status to [LoadingStatus.loaded].

  Future<void> onSearchCriteriaSelected(Reference data) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    selectedSearchCriteria = data;

    if (selectedSearchCriteria?.id == ServerConstants.rmNameId) {
      final rmRole = Reference(reference3: "RM-WCAS");
      await getUserList([rmRole]);
    }
    // Call filtering logic only for RM Name or Pending With Role ID
    if (selectedSearchCriteria?.id == ServerConstants.rmNameId ||
        selectedSearchCriteria?.id == ServerConstants.pendingWithId) {
      await getFilteredUsersById(selectedSearchCriteria!.id!);
    }
  }

  Future<void> getFilteredUsersById(int filterId) async {
    try {
      if (filterId == ServerConstants.rmNameId) {
        // Show only RM users
        userModels = userList
            .where((user) => user.currentRole!.id == ServerConstants.rmId)
            .toList();
      } else if (filterId == ServerConstants.pendingWithId) {
        // Show users for selected roles
        userModels.clear();
        if (selectedRoles != null && selectedRoles!.isNotEmpty) {
          for (final ref in selectedRoles!) {
            final matchingUser = users.firstWhere(
              (user) => user.roleId == ref.id,
              orElse: Role.new,
            );
            if (matchingUser.users != null) {
              matchingUser.users?.forEach((user) {
                user.currentRole = matchingUser;
              });
              userModels.addAll(matchingUser.users!);
            }
          }
        }
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Called when a role is selected.
  ///
  /// Stores the selected role in the state and calls [getMappedUsers] to fetch
  /// the list of users assigned to the selected role.
  ///
  /// This is called when the user selects a role from the dropdown list.

  Future<void> onRoleSelected(List<Reference> data) async {
    selectedRoles = data;
    await getUserList(selectedRoles!);

    // getMappedUsers();
  }

  /// Fetches the list of users assigned to the selected roles.
  ///
  /// Called when a role is selected. This function iterates over the list of
  /// selected roles and fetches the list of users assigned to each role. The
  /// lists of users are then added to the [userModels] list. If no roles are
  /// selected, the [userModels] list is cleared. Finally, the state is updated
  /// with the loader status set to [LoadingStatus.loaded].

  void getMappedUsers() {
    selectedUserName = null;
    if (selectedRoles != null && selectedRoles!.isNotEmpty) {
      for (final ref in selectedRoles!) {
        final matchingUser = users.firstWhere(
          (user) => user.roleId == ref.id,
          orElse: Role.new, // fallback to avoid exception
        );

        // Check if userDetails is non-null before adding
        if (matchingUser.users != null) {
          matchingUser.users?.map((user) {
            user.currentRole = matchingUser;
          }).toList();
          userModels.addAll(matchingUser.users!);
        }
      }
    } else {
      userModels = [];
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Returns true if the selected search criteria is Application Reference
  /// Number.

  bool showApplicationRefIdField() =>
      selectedSearchCriteria?.id ==
      ServerConstants.applicationReferenceNumberId;

  /// Returns true if the selected search criteria is Customer RIM Number.

  bool showCustomerRimNoField() =>
      selectedSearchCriteria?.id == ServerConstants.customerRIMNumberId;

  /// Returns true if the selected search criteria is Group ID.

  bool showGroupIdField() =>
      selectedSearchCriteria?.id == ServerConstants.groupId;

  /// Returns true if the selected search criteria is By Segment or Region.
  ///
  /// This checks whether the currently selected search criteria matches the
  /// ID associated with searching by Segment or Region.

  bool showRegionField() =>
      selectedSearchCriteria?.id == ServerConstants.bySegmentOrRegionId;

  /// Returns true if the selected search criteria is Role ID.
  ///
  /// This checks whether the currently selected search criteria matches the
  /// ID associated with searching by Role ID.
  bool showRoleIdField() =>
      selectedSearchCriteria?.id == ServerConstants.pendingWithId;

  /// Returns true if the selected search criteria is RM Name.
  ///
  /// This checks whether the currently selected search criteria matches the
  /// ID associated with searching by RM Name.
  bool showRmNameField() =>
      selectedSearchCriteria?.id == ServerConstants.rmNameId;

  /// Called when a user name is selected from the dropdown list.
  ///
  /// Updates the [selectedUserName] with the selected user name.
  void onUserNameSelected(User data) {
    selectedUserName = data;
  }

  /// Called when an RM name is selected from the dropdown list.
  ///
  /// Updates the [selectedRM] with the selected RM name.
  void onRMNameSelected(User data) {
    selectedRM = data;
    getRmUsers();
  }

  /// Returns the list of search criteria based on the user's role.
  ///
  /// If the user's role is RM or RO, the list of search criteria is filtered
  /// to exclude the search criteria for RM Name and Role ID.
  /// Otherwise, the list of search criteria is returned as is.
  ///
  List<Reference> getCriteriaList() {
    if (Globals.user?.currentRole?.id == ServerConstants.rmId ||
        Globals.user?.currentRole?.id == ServerConstants.roId) {
      return (referenceData[ReferenceDataKeys.searchCriteria] ?? [])
          .where(
            (ref) =>
                ref.id != ServerConstants.rmNameId &&
                ref.id != ServerConstants.pendingWithId,
          )
          .toList();
    }
    return referenceData[ReferenceDataKeys.searchCriteria] ?? [];
  }

  /// on Region chip deletion button pressed
  void onRegionChipDeleted(int index) {
    selectedRegions?.removeAt(index);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// on segment chip deletion button pressed
  void onSegmentChipDeleted(int index) {
    selectedSegments?.removeAt(index);

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

// on role chip deletion button clicked
  void onRoleChipDeleted(int index) {
    selectedRoles?.removeAt(index);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  String? getRequestStatusNameById(String? id) {
    if (id == null) {
      return "";
    }
    final int? parsedId = int.tryParse(id);
    if (parsedId == null) {
      return id;
    }
    final entry = ServerConstants.requestStatusId.entries.firstWhere(
      (element) => element.value == parsedId,
    );
    return ServerConstants.requestStatusTitle[entry.key];
  }
}
