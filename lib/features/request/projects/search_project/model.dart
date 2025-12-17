import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/project/contract.dart';
import 'package:wcas_frontend/models/request/project/project.dart';
import 'package:wcas_frontend/repositories/auth_repository.dart';
import 'package:wcas_frontend/repositories/project_repository.dart';

import 'state.dart';

enum SearchByOption { project, contract }

class SearchProjectViewModel extends Cubit<SearchProjectState> {
  SearchProjectViewModel()
      : super(SearchProjectState(loaderStatus: LoadingStatus.loading));
  late ProjectRepository repository;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  ReferenceDataService? _referenceDataService;
  bool get canEdit => (pageMode == PageMode.edit);

  set referenceDataService(ReferenceDataService service) {
    _referenceDataService = service;
  }

  PageMode pageMode = PageMode.na;

  List<Reference>? searchCriteriaItems = [];
  List<Reference>? projectTypeRefItems = [];
  List<Reference>? contractTypeRefItems = [];
  List<Project>? projects = [];
  List<Contract>? contracts = [];
  List<Project>? filteredProjects;
  SearchByOption selectedSearchByValue = SearchByOption.project;
  List<Contract>? filteredContracts;
  List<SearchByOption> searchByItems = [
    SearchByOption.project,
    SearchByOption.contract,
  ];

  Reference? searchCriteriaValue = Reference(name: 'Select');

  LoadingStatus customerRimNoLoadingStatus = LoadingStatus.loaded;
  String? customerRimNo;

  /// Initializes the view model by setting up the repository and loading reference data.
  Future<void> init(context) async {
    logger.i('initialising SearchProjectViewModel');
    repository = ProjectRepository.instance;
    pageMode = AuthRepository.getPageMode(RightConstants.searchProject);
    await getReferenceData();
  }

  /// Fetches project details from the repository and updates the UI state.
  Future<void> getProjectDetailsData() async {
    try {
      final result = await repository.getSearchProjectDetails();
      projects = result.projects;
      contracts = result.contracts;
      emit(state.copyWith(
          loaderStatus: LoadingStatus.loaded, showDataTable: true));
      customerRimNoLoadingStatus = LoadingStatus.loaded;
    } catch (e) {
      logger.i(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Loads reference data for project and contract types and updates the relevant lists.
  /// If there is an error, shows a toast and rethrows the error.
  Future<void> getReferenceData() async {
    try {
      Map<String, List<Reference>> referenceData =
          await (_referenceDataService ?? ReferenceDataService())
              .getReferenceData([
        ReferenceDataKeys.projectType,
        ReferenceDataKeys.contractType
      ]);
      projectTypeRefItems = referenceData[ReferenceDataKeys.projectType];
      contractTypeRefItems = referenceData[ReferenceDataKeys.contractType];
      searchCriteriaItems = projectTypeRefItems;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      AlertManager().showFailureToast('reference.errorFetching'.tr());
      rethrow;
    }
  }

  void filterResultsByCriteria() {
    if (searchCriteriaValue == null ||
        searchCriteriaValue!.name == 'Select' ||
        customerRimNo == null ||
        customerRimNo!.isEmpty) {
      filteredProjects = projects;
      emit(state.copyWith(showDataTable: true));
      return;
    }

    filteredProjects = projects?.where((project) {
      switch (searchCriteriaValue!.name?.toLowerCase()) {
        case 'project name':
          return project.name
                  ?.toLowerCase()
                  .contains(customerRimNo!.toLowerCase()) ??
              false;
        case 'project ultimate owner name':
          return project.ultimateOwner
                  ?.toLowerCase()
                  .contains(customerRimNo!.toLowerCase()) ??
              false;
        case 'project owner entity name':
          return project.ownerEntity
                  ?.toLowerCase()
                  .contains(customerRimNo!.toLowerCase()) ??
              false;
        default:
          return true;
      }
    }).toList();

    emit(state.copyWith(showDataTable: true));
  }

  /// Handles changes to the selected search-by option and updates the search criteria accordingly.
  void onChangedSearchByValue(SearchByOption? value) {
    if (value == null) return;

    selectedSearchByValue = value;

    switch (selectedSearchByValue) {
      case SearchByOption.project:
        searchCriteriaItems = projectTypeRefItems;
        break;
      case SearchByOption.contract:
        searchCriteriaItems = contractTypeRefItems;
        break;
    }

    searchCriteriaValue = Reference(name: 'Select');

    emit(state.copyWith(
      loaderStatus: LoadingStatus.loaded,
      showCustomerTypeField: false,
      showDataTable: false,
    ));
  }

// To get the localized string
  String getSearchByLabel(SearchByOption option) {
    switch (option) {
      case SearchByOption.project:
        return 'project.searchProject.optionProject'.tr();
      case SearchByOption.contract:
        return 'project.searchProject.optionContract'.tr();
    }
  }

  /// Updates the selected search criteria and shows the customer type field.
  void onSearchCriteriaSelected(Reference selected) {
    searchCriteriaValue = selected;
    emit(state.copyWith(showCustomerTypeField: true));
  }

  /// Handles the submit button press by resetting relevant fields and UI state.
  Future<void> onSubmitPressed(BuildContext context) async {
    try {
      // Validate the form first
      final isValid = formKey.currentState?.validate() ?? false;

      if (!isValid) {
        AlertManager().showFailureToast(
            '${'project.searchProject.pleaseEnter'.tr()} ${searchCriteriaValue?.name}');
        return;
      }

      // Save the form to update customerRimNo
      formKey.currentState?.save();

      // Optional: double-check after save
      if (customerRimNo == null || customerRimNo!.trim().isEmpty) {
        AlertManager().showFailureToast(
            '${'project.searchProject.pleaseEnter'.tr()} ${searchCriteriaValue?.name}');
        return;
      }

      // Proceed if editable or valid
      if (!canEdit || isValid) {
        customerRimNoLoadingStatus = LoadingStatus.loading;
        await getProjectDetailsData();

        await getProjectDetailsData();
        filterResultsByCriteria(); // ✅ Apply filtering

        // customerRimNoLoadingStatus = LoadingStatus.loaded;
        // searchCriteriaValue = Reference(name: 'Select');
        // customerRimNo = null;

        // emit(state.copyWith(
        //   loaderStatus: LoadingStatus.loaded,
        //   showCustomerTypeField: false,
        //   showDataTable: false,
        // ));
      }
    } catch (e) {
      logger.e('Error during save: $e');
      AlertManager().showFailureToast('$e');
      customerRimNoLoadingStatus = LoadingStatus.error;
      emit(state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        showCustomerTypeField: false,
        showDataTable: false,
      ));
    }
  }

  /// Resets the form fields and UI state to their initial values.
  Future<void> onResetPressed(BuildContext context) async {
    customerRimNoLoadingStatus = LoadingStatus.loaded;
    searchCriteriaValue = Reference(name: 'Select');
    customerRimNo = null;
    emit(state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        showCustomerTypeField: false,
        showDataTable: false));
  }

  /// Initiates a search for project details based on the customer RIM number.
  void onCustomerRimNoSearchPressed() async {
    try {
      // Validate the form first
      final isValid = formKey.currentState?.validate() ?? false;

      if (!isValid) {
        AlertManager().showFailureToast('common.validation.emptyField'.tr());
        return;
      }

      // Save the form to update customerRimNo
      formKey.currentState?.save();

      // Optional: double-check after save
      if (customerRimNo == null || customerRimNo!.trim().isEmpty) {
        AlertManager().showFailureToast('common.validation.emptyField'.tr());
        return;
      }

      // Proceed if editable or valid
      if (!canEdit || isValid) {
        customerRimNoLoadingStatus = LoadingStatus.loading;
        await getProjectDetailsData();
      }
    } catch (e) {
      logger.e('Error during save: $e');
      AlertManager().showFailureToast('$e');
      customerRimNoLoadingStatus = LoadingStatus.error;
    }
  }

  /// Navigates to the create project page after resetting the form.
  Future<void> onCreateProjectPressed(BuildContext context) async {
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

  void onPressedProjectView() {
    //Router to next page

  router.go(Routes.createProject);
  }

  void onPressedContractView() {
    //Router to next page

  router.go(Routes.editViewProject);
  }
}
