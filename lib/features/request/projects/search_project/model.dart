import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
// import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/projects/search_project/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/project/contract.dart";
import "package:wcas_frontend/models/request/project/project.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/project_repository.dart";

/// Search type options for project search.
enum SearchByOption {
  /// Search by project.
  project,

  /// Search by contract.
  contract,
}

/// View model for the Search Project screen.
class SearchProjectViewModel extends SafeCubit<SearchProjectState> {
  /// Creates a search project view model.
  SearchProjectViewModel()
      : super(SearchProjectState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for project related APIs.
  late ProjectRepository repository;

  /// Form key for search project form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // ReferenceDataService? _referenceDataService;

  /// Sets the reference data service.
  void referenceDataService(ReferenceDataService service) {
    // _referenceDataService = service;
  }

  /// Indicates whether the current page can be edited.
  bool get canEdit => pageMode == PageMode.edit;

  /// Current page mode.
  PageMode pageMode = PageMode.na;

  /// Reference data mapped by reference key.
  Map<String, List<Reference>> referenceData = {};

  /// Raw project/contract search reference items.
  List<Reference>? projectContractRefItems = [];

  /// Search criteria items displayed in dropdown.
  List<Reference>? searchCriteriaItems = [];

  /// Project search criteria reference items.
  List<Reference>? projectTypeRefItems = [];

  /// Contract search criteria reference items.
  List<Reference>? contractTypeRefItems = [];

  /// Project search result list.
  List<Project>? projects = [];

  /// Contract search result list.
  List<Project>? contracts = [];

  /// Filtered project result list.
  List<Project>? filteredProjects;

  /// Selected search-by option.
  SearchByOption selectedSearchByValue = SearchByOption.project;

  /// Filtered contract result list.
  List<Contract>? filteredContracts;

  /// Search-by radio options.
  List<SearchByOption> searchByItems = [
    SearchByOption.project,
    SearchByOption.contract,
  ];

  /// Selected search criteria value.
  Reference? searchCriteriaValue = Reference(name: "Select");

  /// Loading status for customer/RIM search field.
  LoadingStatus customerRimNoLoadingStatus = LoadingStatus.loaded;

  /// Search field text value.
  String? dropDownFeildText;

  /// Controller for the dynamic search field.
  TextEditingController controllerDropDownFeildText = TextEditingController();

  /// Initializes the view model by setting up the repository and loading
  /// reference data.
  Future<void> init(BuildContext context) async {
    logger.i("initialising SearchProjectViewModel");
    repository = ProjectRepository.instance;
    await AuthRepository.instance
        .updateRole(Globals.user!.currentRole!, request: Globals.request);
    await getReferenceData();
    pageMode = AuthRepository.getPageMode(RightConstants.searchProject);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Loads reference data for project and contract types and updates the
  /// relevant lists.
  /// If there is an error, shows a toast and rethrows the error.
  Future<void> getReferenceData() async {
    try {
      referenceData = await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.projectSearchCriteria,
      ]);
      projectContractRefItems =
          referenceData[ReferenceDataKeys.projectSearchCriteria] ?? [];

      // Filter by isActive and type
      final projectRows = projectContractRefItems?.where(
        (row) =>
            (row.isActive ?? false) &&
            (row.reference1 == ServerConstants.project),
      );

      final contractRows = projectContractRefItems?.where(
        (row) =>
            (row.isActive ?? false) &&
            (row.reference1 == ServerConstants.contract),
      );

      // Map rows to Reference objects
      projectTypeRefItems = projectRows?.map((row) {
        final description =
            row.reference2?.trim() ?? ""; //Dont change this Search API Keyword
        final name = row.name?.trim() ?? "";
        final ref1 = row.reference1?.trim() ?? "";
        final ref2 = row.reference2?.trim() ?? "";
        final ref3 = row.reference3?.trim() ?? "";
        final ref4 = row.reference4?.trim() ?? "";
        final ref5 = row.reference5?.trim() ?? "";
        return Reference(
          description: description,
          name: name,
          reference3: ref3,
          reference1: ref1,
          reference2: ref2,
          reference4: ref4,
          reference5: ref5,
        );
      }).toList();

      contractTypeRefItems = contractRows?.map((row) {
        final description =
            row.reference2?.trim() ?? ""; //Dont change this Search API Keyword
        final name = row.name?.trim() ?? "";
        final ref1 = row.reference1?.trim() ?? "";
        final ref2 = row.reference2?.trim() ?? "";
        final ref3 = row.reference3?.trim() ?? "";
        final ref4 = row.reference4?.trim() ?? "";
        final ref5 = row.reference5?.trim() ?? "";
        return Reference(
          description: description,
          name: name,
          reference3: ref3,
          reference1: ref1,
          reference2: ref2,
          reference4: ref4,
          reference5: ref5,
        );
      }).toList();

      searchCriteriaItems = projectTypeRefItems;
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      rethrow;
    }
  }

  /// Handles changes to the selected search-by option and updates the search
  /// criteria accordingly.
  void onChangedSearchByValue(SearchByOption? value) {
    if (value == null) {
      return;
    }

    selectedSearchByValue = value;

    switch (selectedSearchByValue) {
      case SearchByOption.project:
        searchCriteriaItems = projectTypeRefItems;
      case SearchByOption.contract:
        searchCriteriaItems = contractTypeRefItems;
    }

    searchCriteriaValue = Reference(name: "Select");

    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        showCustomerTypeField: false,
        showDataTable: false,
      ),
    );
  }

// To get the localized string

  /// Returns localized label for search-by option.
  String getSearchByLabel(SearchByOption option) {
    switch (option) {
      case SearchByOption.project:
        return "project.searchProject.optionProject".tr();
      case SearchByOption.contract:
        return "project.searchProject.optionContract".tr();
    }
  }

  /// Updates the selected search criteria and shows the customer type field.
  void onSearchCriteriaSelected(Reference selected) {
    searchCriteriaValue = selected;
    dropDownFeildText = null;
    controllerDropDownFeildText.text = "";
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        showCustomerTypeField: true,
        showDataTable: false,
      ),
    );
    customerRimNoLoadingStatus = LoadingStatus.loaded;
  }

  /// Initiates a search for project details based on the customer RIM number.
  void onCustomerRimNoSearchPressed() {
    try {
      // Validate the form first
      final isValid = formKey.currentState?.validate() ?? false;

      if (!isValid) {
        AlertManager().showFailureToast("common.validation.emptyField".tr());
        return;
      }

      // Save the form to update customerRimNo
      formKey.currentState?.save();

      // Optional: double-check after save
      if (dropDownFeildText == null || dropDownFeildText!.trim().isEmpty) {
        AlertManager().showFailureToast("common.validation.emptyField".tr());
        return;
      }

      // Proceed if editable or valid
      if (!canEdit || isValid) {
        customerRimNoLoadingStatus = LoadingStatus.loading;
        //await getProjectDetailsData();
      }
    } on Object catch (e) {
      logger.e("Error during save: $e");
      AlertManager().showFailureToast("$e");
      customerRimNoLoadingStatus = LoadingStatus.error;
    }
  }

  /// Handles the submit button press by resetting relevant fields and UI state.
  Future<void> onSubmitPressed(BuildContext context) async {
    try {
      // Validate the form first
      final isValid = formKey.currentState?.validate() ?? false;

      if (!isValid) {
        AlertManager().showFailureToast(
          '${'project.searchProject.pleaseEnter'.tr()} '
          "${searchCriteriaValue?.name}",
        );
        return;
      }

      // Save the form to update customerRimNo
      formKey.currentState?.save();

      // Optional: double-check after save
      if (dropDownFeildText == null || dropDownFeildText!.trim().isEmpty) {
        AlertManager().showFailureToast(
          '${'project.searchProject.pleaseEnter'.tr()} '
          "${searchCriteriaValue?.name}",
        );
        return;
      }

      if (dropDownFeildText!.length < 4) {
        final selectedKeyName = searchCriteriaValue?.name ?? "";
        // } else {
        AlertManager().showFailureToast(
          "project.searchProject.enterCharLength".tr(
            namedArgs: {
              "projectCode": selectedKeyName,
            },
          ),
        );
        return;
      }

      // Proceed if editable or valid
      if (!canEdit || isValid) {
        emit(
          state.copyWith(
            loaderStatus: LoadingStatus.loaded,
            showCustomerTypeField: true,
            showDataTable: false,
          ),
        );
        customerRimNoLoadingStatus = LoadingStatus.loading;

        final selectedKey =
            searchCriteriaValue?.description; // API key from reference data.
        final value = dropDownFeildText;

        if (selectedSearchByValue == SearchByOption.project) {
          final payload =
              buildProjectSearchPayload(selectedKey: selectedKey, value: value);
          await getProjectDetailsData(payload: payload, isProject: true);
        } else {
          final payload =
              buildProjectSearchPayload(selectedKey: selectedKey, value: value);
          await getProjectDetailsData(payload: payload);
        }
      }
    } on Object catch (e) {
      logger.e("Error during save: $e");
      AlertManager().showFailureToast("$e");
      customerRimNoLoadingStatus = LoadingStatus.error;
      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.loaded,
          showCustomerTypeField: false,
          showDataTable: false,
        ),
      );
    }
  }

  /// Fetches project details from the repository and updates the UI state.
  Future<void> getProjectDetailsData({
    Map<String, dynamic>? payload,
    bool? isProject = false,
  }) async {
    try {
      // Clean payload if needed
      // final cleanedPayload = stripNulls(payload!);
      // if (cleanedPayload.isEmpty) {
      //   throw 'Please provide a value for the selected search key.';
      // }

      final result = await repository.getSearchProjectDetails(
        payload: payload,
        isProject: isProject,
      );

      if (isProject ?? false) {
        projects = result.projects;
      } else {
        contracts = result
            // If API returns contracts list, rename tuple to contracts
            .projects;
      }

      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.loaded,
          showDataTable: true,
        ),
      );
      customerRimNoLoadingStatus = LoadingStatus.loaded;
    } on Object catch (e) {
      logger.i(e.toString());
      AlertManager().showFailureToast(e.toString());
      customerRimNoLoadingStatus = LoadingStatus.error;
    }
  }

  /// Resets the form fields and UI state to their initial values.
  void onResetPressed(BuildContext context) {
    customerRimNoLoadingStatus = LoadingStatus.loaded;
    searchCriteriaValue = Reference(name: "Select");
    dropDownFeildText = null;
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        showCustomerTypeField: false,
        showDataTable: false,
      ),
    );
  }

  /// Navigates to the create project page after resetting the form.
  Future<void> onCreateProjectPressed(BuildContext context) async {
    Globals.request?.applicationRefNo = null;
    onResetPressed(context);
    //Router to next page

    router.go(Routes.createProject);
  }

  /// Navigates to the create project page after resetting the form.
  Future<void> onBackToRequestStausPressed(BuildContext context) async {
    onResetPressed(context);
    //Router to next page
    router.go(Routes.home);
  }

  /// Handles project view action from results table.
  void onPressedProjectView({Project? project}) {
    Globals.request?.applicationRefNo = null;
    //Router to next page
    router.go(Routes.editViewProject, extra: project);
  }

  /// Handles contract view action from results table.
  void onPressedContractView({Project? contract}) {
    Globals.request?.applicationRefNo = null;
    //Router to next page
    router.go(Routes.editViewProject, extra: contract);
  }

  /// Builds search payload using the selected key and value.
  Map<String, dynamic> buildProjectSearchPayload({
    required String? selectedKey, // 'projectCode', 'projectName', ...
    required String? value,
  }) {
    final v = (value ?? "").trim();
    final key = (selectedKey ?? "").trim();

    // If value is empty, send an empty payload (or handle upstream as invalid)
    if (v.isEmpty || key.isEmpty) {
      return const {};
    }

    // Only include the selected key
    return {key: v};
  }

  //The Business group users, namely RMB, TLB, RMB, CAM, SHB (Business Unit
  //Heads) should be able to create project.
  //Credit team user (Credit Coordinator, Credit Analyst, CC Proxy, BOD Proxy)
  //shall be able to view the projects but cannot edit.

  /// Checks whether current user has edit access roles.
  bool editAccessRolesCheck() {
    return Utils.checkRoles([
      UserRole.relationshipManager,
      UserRole.relationshipOfficer,
      UserRole.relationshipManagerBussiness,
      UserRole.teamLeaderBusiness,
      UserRole.commercialAreaManager,
      UserRole.segmentHeadBusiness,
    ]);
  }

  /// Checks whether current user has view-only access roles.
  bool viewAccessRolesCheck() {
    return Utils.checkRoles([
      UserRole.creditCordinator,
      UserRole.creditAnalyst,
      UserRole.creditCommitteeProxy,
      UserRole.boardDirectorProxy,
    ]);
  }
}
