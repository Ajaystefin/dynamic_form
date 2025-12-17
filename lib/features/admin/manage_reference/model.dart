import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/reference_type.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/repositories/admin_repository.dart';

import 'state.dart';

class ManageReferenceViewModel extends Cubit<ManageReferenceState> {
  ManageReferenceViewModel()
      : super(ManageReferenceState(
          loaderStatus: LoadingStatus.loading,
        ));
  late AdminRepository repository;
  FocusNode formFocusNode = FocusNode();
  ReferenceType? selectedReferenceType;
  List<ReferenceType> allReferences = [];
  List<Reference> references = [];
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  int? referenceDataTypeID = 0;
  Reference? updateDataValues;

  /// Initializes the `ManageReferenceViewModel`.
  ///
  /// This method sets up the `AdminRepository` instance and triggers the
  /// loading of reference types required for the view model. It logs the
  /// initialization process and ensures that the necessary data is fetched
  /// before the UI is rendered.
  ///
  /// - Parameters:
  ///   - context: The BuildContext from the widget tree, used for localization or navigation if needed.
  void init(context) async {
    Globals.request = null;
    logger.i('initialising ManageReferenceViewModel');
    repository = AdminRepository.instance;

    await getReferenceTypes();
  }

  /// Fetches the list of reference types from the repository.
  ///
  /// This asynchronous method retrieves reference data using the `AdminRepository`.
  /// On successful fetch, it updates the `allReferences` list and emits a state
  /// with `LoadingStatus.loaded`. If an error occurs during the fetch, it logs
  /// the error and emits a state with `LoadingStatus.error`.
  ///
  /// Logs are generated to track the start and result of the operation.
  Future<void> getReferenceTypes() async {
    logger.i('getting reference data types');
    try {
      allReferences = await repository.getReferenceTypes();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      logger.e('Error getting reference data types: $e');
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

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

  Future<void> onReferenceDataSelected(ReferenceType selectedValue) async {
    try {
      emit(state.copyWith(referencesLoaderStatus: LoadingStatus.loading));
      selectedReferenceType = selectedValue;
      references = await repository.getReferenceData(selectedValue);
      emit(state.copyWith(referencesLoaderStatus: LoadingStatus.loaded));
    } catch (e) {
      logger.e('Error getting reference data types: $e');
      emit(state.copyWith(referencesLoaderStatus: LoadingStatus.error));
    }
  }

  void onSave() {
    router.go(Routes.adminRoleRight);
  }

  /// Returns the column names for the table based on the selected reference type.
  ///
  /// If the selected reference type is null, then the default column names are returned.
  /// Otherwise, the column names are generated based on the columnsInformation property of the selected reference type.
  /// The columnsInformation property is a string that contains the column names separated by a semicolon.
  /// The column names are assigned to the table columns starting from the 4th column (index 3).
  List<String> getColumnNames() {
    List<String> columnNames = [
      'admin.referenceDataManagement.referenceDataId'.tr(),
      'admin.referenceDataManagement.referenceDataName'.tr(),
      'admin.referenceDataManagement.referenceDataDescription'.tr(),
      'admin.referenceDataManagement.reference1'.tr(),
      'admin.referenceDataManagement.reference2'.tr(),
      'admin.referenceDataManagement.reference3'.tr(),
      'admin.referenceDataManagement.reference4'.tr(),
      'admin.referenceDataManagement.reference5'.tr(),
      'admin.referenceDataManagement.status'.tr(),
    ];

    final List<String>? additionalHeaders =
        selectedReferenceType?.columnsInformation?.split(";");

    if (additionalHeaders == null) return columnNames;

    for (int i = 0;
        i < additionalHeaders.length && i + 3 < columnNames.length;
        i++) {
      if (additionalHeaders[i].trim().isNotEmpty) {
        columnNames[i + 3] = additionalHeaders[i].trim();
      }
    }

    return columnNames;
  }
}
