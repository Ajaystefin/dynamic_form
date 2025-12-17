//import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/login/role.dart';
import 'package:wcas_frontend/models/login/user.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'package:wcas_frontend/repositories/dashboard_repository.dart';

import 'state.dart';

class AdvancedSearchViewModel extends Cubit<AdvancedSearchState> {
  AdvancedSearchViewModel()
      : super(AdvancedSearchState(loaderStatus: LoadingStatus.loading));
  DashboardRepository repository = DashboardRepository();

  /// init function
  Future<void> init(context) async {
    logger.i('initialising AdvancedSearchViewModel');
    await loadReferenceData();

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

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

  Future<void> onSubmitButtonPress() async {
    try {
      workList = await repository.getWorklistSearchCriteria(
        rmName: selectedRM?.id!,
        key: selectedRequestStatus!.name!,
        applicationRefNo: applicationRefNo,
        customerRim: customerRimNo,
        groupId: groupId,
        pendingUser: selectedUserName?.userName,
        pendingWith: (selectedRoles != null && selectedRoles!.isNotEmpty)
            ? selectedRoles!.map((e) => e.reference2).join(',')
            : null,
        segment: (selectedSegments?.isNotEmpty ?? false)
            ? selectedSegments!.map((e) => e.reference1).join(',')
            : null,
        region: (selectedRegions?.isNotEmpty ?? false)
            ? selectedRegions!.map((e) => e.reference1).join(',')
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
  /// [AdvancedSearchState] with the loader status set to [LoadingStatus.loaded].
  ///
  /// This is called when the reset button is pressed.
  void onResetButtonPress() {
    selectedRM = null;
    selectedRoles = [];

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
  void onFilter({
    required String value,
    required FilterType filterType,
    List<Request> selectedTypes = const [],
  }) {
    emit(state.copyWith(tableloader: LoadingStatus.loading));

    if (filterType == FilterType.referenceNumber) {
      reqRefNoFilter = value;
    }
    if (filterType == FilterType.applicantRim) {
      applicantRimFilter = value;
    }
    if (filterType == FilterType.applicantName) {
      applicantNameFilter = value;
    }
    if (filterType == FilterType.referenceType) {
      selectedFilterTypeData = selectedTypes;
    }
    filteredWorkList = [];
    if ((reqRefNoFilter == null || reqRefNoFilter!.isEmpty) &&
        (applicantRimFilter == null || applicantRimFilter!.isEmpty) &&
        (applicantNameFilter == null || applicantNameFilter!.isEmpty) &&
        selectedFilterTypeData.isEmpty) {
      filteredWorkList = workList;
      emit(state.copyWith(tableloader: LoadingStatus.loaded));
      return;
    }
    logger.i(applicantNameFilter);
    workList.map((data) {
      if ((reqRefNoFilter != null && reqRefNoFilter!.isNotEmpty) &&
          (data.applicationRefNo ?? "").contains(reqRefNoFilter!)) {
        filteredWorkList.add(data);
      }
      if ((applicantRimFilter != null && applicantRimFilter!.isNotEmpty) &&
          (data.customerRimNo?.toString() ?? "")
              .contains(applicantRimFilter!)) {
        filteredWorkList.add(data);
      }
      if ((applicantNameFilter != null && applicantNameFilter!.isNotEmpty) &&
          (data.customerName ?? "").contains(applicantNameFilter!)) {
        filteredWorkList.add(data);
      }
      if (selectedTypes.isNotEmpty) {
        for (Request? selectedType in (selectedTypes)) {
          if (data.applicationType?.name ==
              selectedType?.applicationType?.name) {
            filteredWorkList.add(data);
          }
        }
      }
    }).toList();
    logger.i(filteredWorkList.length);
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
        ReferenceDataKeys.transactionType
      ]);
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
      // This already gives you List<User>
      userList.clear();
      final users = await repository.getUserByRole(roleData
          .map((e) => e.reference3)
          .where((ref) => ref != null && ref.isNotEmpty)
          .cast<String>() // Ensures type safety
          .toList());

      // Remove duplicates by userId
      final uniqueUsers =
          {for (var user in users) user.id: user}.values.toList();

      userList = uniqueUsers;

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
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
  /// Stores the selected search criteria in the state and sets the loader status to [LoadingStatus.loaded].

  void onSearchCriteriaSelected(Reference data) {
    selectedSearchCriteria = data;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

    if (selectedSearchCriteria?.id == ServerConstants.rmNameId) {
      final rmRole = Reference(reference3: "RM-WCAS");

      getUserList([rmRole]);
    }
    // Call filtering logic only for RM Name or Pending With Role ID
    if (selectedSearchCriteria?.id == ServerConstants.rmNameId ||
        selectedSearchCriteria?.id == ServerConstants.pendingWithId) {
      getFilteredUsersById(selectedSearchCriteria!.id!);
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
          for (var ref in selectedRoles!) {
            final matchingUser = users.firstWhere(
              (user) => user.roleId == ref.id,
              orElse: () => Role(),
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

  void onRoleSelected(List<Reference> data) {
    selectedRoles = data;
    getUserList(selectedRoles!);

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
      for (var ref in selectedRoles!) {
        final matchingUser = users.firstWhere(
          (user) => user.roleId == ref.id,
          orElse: () => Role(), // fallback to avoid exception
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

  /// Returns true if the selected search criteria is Application Reference Number.

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
          .where((ref) =>
              ref.id != ServerConstants.rmNameId &&
              ref.id != ServerConstants.pendingWithId)
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

  String? getRequestStatusNameById(int id) {
    final entry = ServerConstants.requestStatusId.entries.firstWhere(
      (element) => element.value == id,
    );
    return entry.key.name;
  }
}
