import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/manage_reference/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";

/// View model responsible for managing reference data.
class ManageReferenceViewModel extends SafeCubit<ManageReferenceState> {
  /// Creates a [ManageReferenceViewModel].
  ManageReferenceViewModel()
      : super(
          ManageReferenceState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

  /// Repository used for managing reference data operations.
  late AdminRepository repository;

  /// Focus node for the form.
  FocusNode formFocusNode = FocusNode();

  /// Currently selected reference type.
  ReferenceType? selectedReferenceType;

  /// List of all available reference types.
  List<ReferenceType> allReferences = [];

  /// List of reference records for the selected type.
  List<Reference> references = [];

  /// Form key used for validation.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Selected reference data type identifier.
  int? referenceDataTypeID = 0;

  /// Reference data currently being updated.
  Reference? updateDataValues;

  List<String> status = [
    Status.active.name.capitalizeFirstLetter(),
    Status.inactive.name.capitalizeFirstLetter(),
  ];
  String? idFilter;
  String? nameFilter;
  String? descriptionFilter;
  String? ref1Filter;
  String? ref2Filter;
  String? ref3Filter;
  String? ref4Filter;
  String? ref5Filter;
  List<String> statusFilter = [];
  int rowsPerPage = 10;
  int currentPage = 0;

  /// Initializes the `ManageReferenceViewModel`.
  ///
  /// This method sets up the `AdminRepository` instance and triggers the
  /// loading of reference types required for the view model. It logs the
  /// initialization process and ensures that the necessary data is fetched
  /// before the UI is rendered.
  ///
  /// - Parameters:
  ///   - context: The BuildContext from the widget tree, used for localization
  /// or navigation if needed.
  Future<void> init(BuildContext? context) async {
    Globals.request = null;
    logger.i("initialising ManageReferenceViewModel");
    repository = AdminRepository.instance;

    await getReferenceTypes();
  }

  /// Fetches the list of reference types from the repository.
  ///
  /// This asynchronous method retrieves reference data using the
  /// `AdminRepository`.
  /// On successful fetch, it updates the `allReferences` list and emits a state
  /// with `LoadingStatus.loaded`. If an error occurs during the fetch, it logs
  /// the error and emits a state with `LoadingStatus.error`.
  ///
  /// Logs are generated to track the start and result of the operation.
  Future<void> getReferenceTypes() async {
    logger.i("getting reference data types");
    try {
      allReferences = await repository.getReferenceTypes();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      logger.e("Error getting reference data types: $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Updates the selected reference data item.
  void onUpdateReferenceData(Reference referenceDataItem) {
    updateDataValues = Reference(
      id: referenceDataItem.id,
      name: referenceDataItem.name,
      description: referenceDataItem.description,
      reference1: referenceDataItem.reference1,
      reference2: referenceDataItem.reference2,
      reference3: referenceDataItem.reference3,
      reference4: referenceDataItem.reference4,
      reference5: referenceDataItem.reference5,
      status: referenceDataItem.status == "1"
          ? Status.active.name
          : Status.inactive.name,
    );
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Loads references for the selected reference type.
  Future<void> onReferenceDataSelected(ReferenceType selectedValue) async {
    try {
      emit(state.copyWith(referencesLoaderStatus: LoadingStatus.loading));
      selectedReferenceType = selectedValue;
      references = await repository.getReferenceData(selectedValue);
      clearFilters();
      emit(state.copyWith(referencesLoaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      logger.e("Error getting reference data types: $e");
      emit(state.copyWith(referencesLoaderStatus: LoadingStatus.error));
    }
  }

  /// Navigates to the next screen.
  void onSave() {
    router.go(Routes.workflowConfiguration);
  }

  /// Returns the column names for the table based on the selected reference
  /// type.
  ///
  /// If the selected reference type is null, then the default column names are
  /// returned.
  /// Otherwise, the column names are generated based on the columnsInformation
  /// property of the selected reference type.
  /// The columnsInformation property is a string that contains the column names
  /// separated by a semicolon.
  /// The column names are assigned to the table columns starting from the 4th
  /// column (index 3).
  List<String> getColumnNames() {
    final List<String> columnNames = [
      "admin.referenceDataManagement.referenceDataId".tr(),
      "admin.referenceDataManagement.referenceDataName".tr(),
      "admin.referenceDataManagement.referenceDataDescription".tr(),
      "admin.referenceDataManagement.reference1".tr(),
      "admin.referenceDataManagement.reference2".tr(),
      "admin.referenceDataManagement.reference3".tr(),
      "admin.referenceDataManagement.reference4".tr(),
      "admin.referenceDataManagement.reference5".tr(),
      "admin.referenceDataManagement.status".tr(),
    ];

    final List<String>? additionalHeaders =
        selectedReferenceType?.columnsInformation?.split(";");

    if (additionalHeaders == null) {
      return columnNames;
    }

    for (int i = 0;
        i < additionalHeaders.length && i + 3 < columnNames.length;
        i++) {
      if (additionalHeaders[i].trim().isNotEmpty) {
        columnNames[i + 3] = additionalHeaders[i].trim();
      }
    }

    return columnNames;
  }

  List<Reference> get filteredReferences {
    return references.where((reference) {
      bool contains(String? filter, String? value) {
        final search = (filter ?? "").trim().toLowerCase();

        if (search.isEmpty) {
          return true;
        }

        return (value ?? "").toLowerCase().contains(search);
      }

      if (!contains(idFilter, reference.id?.toString())) {
        return false;
      }

      if (!contains(nameFilter, reference.name)) {
        return false;
      }

      if (!contains(descriptionFilter, reference.description)) {
        return false;
      }

      if (!contains(ref1Filter, reference.reference1)) {
        return false;
      }

      if (!contains(ref2Filter, reference.reference2)) {
        return false;
      }

      if (!contains(ref3Filter, reference.reference3)) {
        return false;
      }

      if (!contains(ref4Filter, reference.reference4)) {
        return false;
      }

      if (!contains(ref5Filter, reference.reference5)) {
        return false;
      }

      if (statusFilter.isNotEmpty &&
          !statusFilter.contains(
            (reference.status ?? Status.inactive.name).capitalizeFirstLetter(),
          )) {
        return false;
      }

      return true;
    }).toList();
  }

  void onIdFilterChanged(String value) {
    idFilter = value;
    currentPage = 0;
    emit(state.copyWith(referencesLoaderStatus: state.loaderStatus));
  }

  void onNameFilterChanged(String value) {
    nameFilter = value;
    currentPage = 0;
    emit(state.copyWith(referencesLoaderStatus: state.loaderStatus));
  }

  void onDescriptionFilterChanged(String value) {
    descriptionFilter = value;
    currentPage = 0;
    emit(state.copyWith(referencesLoaderStatus: state.loaderStatus));
  }

  void onReference1FilterChanged(String value) {
    ref1Filter = value;
    currentPage = 0;
    emit(state.copyWith(referencesLoaderStatus: state.loaderStatus));
  }

  void onReference2FilterChanged(String value) {
    ref2Filter = value;
    currentPage = 0;
    emit(state.copyWith(referencesLoaderStatus: state.loaderStatus));
  }

  void onReference3FilterChanged(String value) {
    ref3Filter = value;
    currentPage = 0;
    emit(state.copyWith(referencesLoaderStatus: state.loaderStatus));
  }

  void onReference4FilterChanged(String value) {
    ref4Filter = value;
    currentPage = 0;
    emit(state.copyWith(referencesLoaderStatus: state.loaderStatus));
  }

  void onReference5FilterChanged(String value) {
    ref5Filter = value;
    currentPage = 0;
    emit(state.copyWith(referencesLoaderStatus: state.loaderStatus));
  }

  void onStatusFilterChanged(List<String> value) {
    statusFilter = value;
    currentPage = 0;
    emit(state.copyWith(referencesLoaderStatus: state.loaderStatus));
  }

  void clearFilters() {
    idFilter = null;
    nameFilter = null;
    descriptionFilter = null;
    ref1Filter = null;
    ref2Filter = null;
    ref3Filter = null;
    ref4Filter = null;
    ref5Filter = null;
    statusFilter = [];
  }
}
