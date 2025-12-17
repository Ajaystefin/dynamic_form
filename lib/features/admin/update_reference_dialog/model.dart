import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/text_utils.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/admin/reference_type.dart';
import 'package:wcas_frontend/repositories/admin_repository.dart';
import 'state.dart';

class UpdateReferenceDialogViewModel extends Cubit<UpdateReferenceDialogState> {
  UpdateReferenceDialogViewModel()
      : super(UpdateReferenceDialogState(
            loaderStatus: LoadingStatus.loading,
            saveButtonStatus: LoadingStatus.loaded));
  late AdminRepository repository;
  FocusNode formFocusNode = FocusNode();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Reference reference = Reference();
  List<ReferenceType> allReferences = [];
  int? referenceDataTypeID = 0;

  ReferenceType? selectedReferenceType;
  List<String>? statusListValue;
  List<String> statusList = [
    Status.active.name.capitalizeFirstLetter(),
    Status.inactive.name.capitalizeFirstLetter(),
  ];

  /// Initializes the `UpdateReferenceDialogViewModel` with a given reference.
  ///
  /// This method sets the `AdminRepository` instance, populates the form fields
  /// using the provided [reference] by calling `onUpdateReferenceData`, and
  /// then loads the available reference types from the repository.
  ///
  /// Logs the initialization process for debugging purposes.
  ///
  /// - Parameters:
  ///   - reference: The [Reference] object used to pre-fill the form fields.
  Future<void> init(Reference reference, ReferenceType referenceType) async {
    logger.i('initialising UpdateReferenceDialogViewModel');
    repository = AdminRepository.instance;
    selectedReferenceType = referenceType;
    onUpdateReferenceData(reference);
    await getReferenceTypes();
  }

  /// Retrieves reference types from the repository and updates the state accordingly.
  ///
  /// This asynchronous method fetches reference data using the `AdminRepository`.
  /// On success, it populates the `allReferences` list and emits a state with
  /// `LoadingStatus.loaded`. If an error occurs, it logs the error and emits a
  /// state with `LoadingStatus.error`.
  ///
  /// Useful for populating dropdowns or selection fields in the UI.
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

  /// Handles the save action for reference data in the update dialog.
  ///
  /// This method validates the form using [formKey]. If the form is invalid,
  /// it emits a state with `saveButtonStatus` set to `LoadingStatus.loaded`.
  /// If valid, it saves the form data, updates the state to `LoadingStatus.loading`,
  /// and calls the repository to persist the reference data.
  ///
  /// Upon successful save, it logs the result, closes the dialog if the context
  /// is still mounted, and emits a state with `saveButtonStatus` set to `LoadingStatus.loaded`.
  /// If an error occurs during the save process, it shows a failure toast and
  /// resets the save button status.
  ///
  /// - Parameters:
  ///   - context: The [BuildContext] used to check widget mounting and close the dialog.
  Future<void> onSaveButtonClick(BuildContext context) async {
    // try {
    if (!(formKey.currentState!.validate())) {
      emit(state.copyWith(saveButtonStatus: LoadingStatus.loaded));
    } else {
      formKey.currentState?.save();
      emit(state.copyWith(saveButtonStatus: LoadingStatus.loading));

      String? result = await repository.saveReferenceDataInformation(
          selectedReferenceType?.id, reference);

      logger.i('Reference data save: $result');
      AlertManager().showSuccessToast("common.saveSuccess".tr());
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    }

    emit(state.copyWith(saveButtonStatus: LoadingStatus.loaded));
  }

  void onUpdateReferenceData(Reference referenceDataItem) {
    reference.id = referenceDataItem.id;
    reference.name = referenceDataItem.name ?? "";
    reference.description = referenceDataItem.description ?? "";
    reference.reference1 = referenceDataItem.reference1;
    reference.reference2 = referenceDataItem.reference2 ?? "";
    reference.reference3 = referenceDataItem.reference3 ?? "";
    reference.reference4 = referenceDataItem.reference4 ?? "";
    reference.reference5 = referenceDataItem.reference5 ?? "";

    reference.status = referenceDataItem.status?.toLowerCase();

    if (reference.status != null && reference.status!.isNotEmpty) {
      statusListValue = [reference.status!.capitalizeFirstLetter()];
    } else {
      statusListValue = [];
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  List<String> getColumnLabelNames() {
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
