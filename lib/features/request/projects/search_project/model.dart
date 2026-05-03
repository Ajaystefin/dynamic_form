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

enum SearchByOption { project, contract }

class SearchProjectViewModel extends SafeCubit<SearchProjectState> {
  SearchProjectViewModel()
      : super(SearchProjectState(loaderStatus: LoadingStatus.loading));
  late ProjectRepository repository;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // ReferenceDataService? _referenceDataService;

  set referenceDataService(ReferenceDataService service) {
    // _referenceDataService = service;
  }

  bool get canEdit => pageMode == PageMode.edit;
  PageMode pageMode = PageMode.na;

  Map<String, List<Reference>> referenceData = {};
  List<Reference>? projectContractRefItems = [];
  List<Reference>? searchCriteriaItems = [];
  List<Reference>? projectTypeRefItems = [];
  List<Reference>? contractTypeRefItems = [];
  List<Project>? projects = [];
  List<Project>? contracts = [];
  List<Project>? filteredProjects;
  SearchByOption selectedSearchByValue = SearchByOption.project;
  List<Contract>? filteredContracts;
  List<SearchByOption> searchByItems = [
    SearchByOption.project,
    SearchByOption.contract,
  ];

  Reference? searchCriteriaValue = Reference(name: "Select");

  LoadingStatus customerRimNoLoadingStatus = LoadingStatus.loaded;
  String? dropDownFeildText;
  TextEditingController controllerDropDownFeildText = TextEditingController();

  /// Initializes the view model by setting up the repository and loading
  /// reference data.
  Future<void> init(context) async {
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
            (row.isActive == true) &&
            (row.reference1 == ServerConstants.project),
      );

      final contractRows = projectContractRefItems?.where(
        (row) =>
            (row.isActive == true) &&
            (row.reference1 == ServerConstants.contract),
      );

      // Map rows to Reference objects
      projectTypeRefItems = projectRows?.map((row) {
        final description = row.reference2?.trim() ??
            ""; //Dont change this Search API Keyword
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
        final description = row.reference2?.trim() ??
            ""; //Dont change this Search API Keyword
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
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      rethrow;
    }
  }

  /// Handles changes to the selected search-by option and updates the search
  /// criteria accordingly.
  void onChangedSearchByValue(SearchByOption? value) {
    if (value == null) return;

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
    } catch (e) {
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
          await getProjectDetailsData(payload: payload, isProject: false);
        }
      }
    } catch (e) {
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
    } catch (e) {
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

  void onPressedProjectView({Project? project}) {
    Globals.request?.applicationRefNo = null;
    //Router to next page
    router.go(Routes.editViewProject, extra: project);
  }

  void onPressedContractView({Project? contract}) {
    Globals.request?.applicationRefNo = null;
    //Router to next page
    router.go(Routes.editViewProject, extra: contract);
  }

  Map<String, dynamic> buildProjectSearchPayload({
    required String? selectedKey, // 'projectCode', 'projectName', ...
    required String? value,
  }) {
    final v = (value ?? "").trim();
    final key = (selectedKey ?? "").trim();

    // If value is empty, send an empty payload (or handle upstream as invalid)
    if (v.isEmpty || key.isEmpty) return const {};

    // Only include the selected key
    return {key: v};
  }

  //The Business group users, namely RMB, TLB, RMB, CAM, SHB (Business Unit
  //Heads) should be able to create project.
  //Credit team user (Credit Coordinator, Credit Analyst, CC Proxy, BOD Proxy)
  //shall be able to view the projects but cannot edit.
  bool editAccessRolesCheck() {
    return (Utils.checkRoles([
      UserRole.relationshipManager,
      UserRole.relationshipOfficer,
      UserRole.relationshipManagerBussiness,
      UserRole.teamLeaderBusiness,
      UserRole.commercialAreaManager,
      UserRole.segmentHeadBusiness,
    ]))
        ? true
        : false;
  }

  bool viewAccessRolesCheck() {
    return (Utils.checkRoles([
      UserRole.creditCordinator,
      UserRole.creditAnalyst,
      UserRole.creditCommitteeProxy,
      UserRole.boardDirectorProxy,
    ]))
        ? true
        : false;
  }
}
