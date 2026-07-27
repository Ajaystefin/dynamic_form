import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/draft_handler.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";

/// View model for managing the update reference dialog.
class UpdateReferenceDialogViewModel
    extends SafeCubit<UpdateReferenceDialogState>
    with DraftMixin<UpdateReferenceDialogViewModel> {
  /// Creates an [UpdateReferenceDialogViewModel].
  UpdateReferenceDialogViewModel()
      : super(
          UpdateReferenceDialogState(
            loaderStatus: LoadingStatus.loading,
            saveButtonStatus: LoadingStatus.loaded,
          ),
        );

  /// Repository used for reference data operations.
  late AdminRepository repository;

  /// Focus node for the dialog form.
  FocusNode formFocusNode = FocusNode();

  /// Form key used for validation.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Current reference being edited.
  Reference reference = Reference();

  /// Available reference types.
  List<ReferenceType> allReferences = [];

  /// Selected reference data type identifier.
  int? referenceDataTypeID = 0;

  /// Currently selected reference type.
  ReferenceType? selectedReferenceType;

  /// Input formatters for name field.
  List<TextInputFormatter> nameFormatters = [];

  /// Input formatters for description field.
  List<TextInputFormatter> descriptionFormatters = [];

  /// Input formatters for reference1 field.
  List<TextInputFormatter> reference1Formatters = [];

  /// Input formatters for reference2 field.
  List<TextInputFormatter> reference2Formatters = [];

  /// Input formatters for reference3 field.
  List<TextInputFormatter> reference3Formatters = [];

  /// Input formatters for reference4 field.
  List<TextInputFormatter> reference4Formatters = [];

  /// Input formatters for reference5 field.
  List<TextInputFormatter> reference5Formatters = [];

  /// Selected status value for dropdown display.
  List<String>? statusListValue;

  /// Available status values.
  List<String> statusList = [
    Status.active.name.capitalizeFirstLetter(),
    Status.inactive.name.capitalizeFirstLetter(),
  ];

  /// Controller for name field.
  final TextEditingController nameController = TextEditingController();

  /// Controller for description field.
  final TextEditingController descriptionController = TextEditingController();

  /// Controller for reference1 field.
  final TextEditingController reference1Controller = TextEditingController();

  /// Controller for reference2 field.
  final TextEditingController reference2Controller = TextEditingController();

  /// Controller for reference3 field.
  final TextEditingController reference3Controller = TextEditingController();

  /// Controller for reference4 field.
  final TextEditingController reference4Controller = TextEditingController();

  /// Controller for reference5 field.
  final TextEditingController reference5Controller = TextEditingController();

  /// Returns whether the selected reference type is Holiday Master.
  bool get hasHolidayMasterReferenceId => selectedReferenceType?.id == 2484;

  /// Stores the original status received from API so that locked records
  /// cannot be changed by draft restoration or before save.
  String? _originalStatus;

  /// Returns `true` when the status dropdown must be disabled.
  ///
  /// Status is read-only only when:
  /// - the selected reference type is ESG section heading
  /// - and the current reference id belongs to the locked ESG ids
  bool get isReferenceStatusDisabled {
    final bool isEsgSectionType = selectedReferenceType?.id ==
            ServerConstants.esgSectionReferenceTypeId &&
        (selectedReferenceType?.name?.trim().toUpperCase() ==
            ServerConstants.esgSectionReferenceTypeName);

    final bool isLockedReference = reference.id != null &&
        ServerConstants.esgSectionLockedReferenceIds.contains(reference.id);

    return isEsgSectionType && isLockedReference;
  }

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  bool _draftReady = false;

  /// Indicates whether draft functionality is ready.
  bool get isDraftReady => _draftReady;

  @override
  String get draftModuleKey => DraftModuleKeys.admin;

  @override
  String get draftFormKey => Routes.manageReference;

  @override
  DraftHandler<UpdateReferenceDialogViewModel> get draftHandler =>
      UpdateReferenceDialogDraftHandler();

  // ---------------------------------------------------------------------------

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
    logger.i("initialising UpdateReferenceDialogViewModel");

    repository = AdminRepository.instance;
    selectedReferenceType = referenceType;

    initializeFormatters();

    // 1. Apply API values
    onUpdateReferenceData(reference);

    // 2. Load supporting data
    await getReferenceTypes();

    // 3. Restore draft (overrides API if present)
    await loadDraftIfAvailable();

    // for locked ESG rows do not allow draft to override status
    restoreOriginalStatusIfLocked();

    syncControllersWithReference();

    // 5. Enable draft saving
    _draftReady = true;
    registerDraftCallback();

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles form field changes and triggers auto-save.
  void onFieldChanged() {
    if (!_draftReady) {
      return;
    }

    emit(state.copyWith());

    unawaited(Globals.onAutoSave?.call());
  }

  /// Converts a raw status value into dropdown display format.
  String? normalizeStatusForDropdown(String? rawStatus) {
    if (rawStatus == null || rawStatus.isEmpty) {
      return null;
    }
    return rawStatus.capitalizeFirstLetter();
  }

  /// Synchronizes controller values with the current reference.
  void syncControllersWithReference() {
    nameController.text = reference.name ?? "";
    descriptionController.text = reference.description ?? "";
    reference1Controller.text = reference.reference1 ?? "";
    reference2Controller.text = reference.reference2 ?? "";
    reference3Controller.text = reference.reference3 ?? "";
    reference4Controller.text = reference.reference4 ?? "";
    reference5Controller.text = reference.reference5 ?? "";
  }

  /// Retrieves reference types from the repository and updates the state.
  ///
  /// This asynchronous method fetches reference data using the
  /// `AdminRepository`.
  /// On success, it populates the `allReferences` list and emits a state with
  /// `LoadingStatus.loaded`. If an error occurs, it logs the error and emits a
  /// state with `LoadingStatus.error`.
  ///
  /// Useful for populating dropdowns or selection fields in the UI.
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

  /// Handles the save action for reference data in the update dialog.
  ///
  /// This method validates the form using [formKey]. If the form is invalid,
  /// it emits a state with `saveButtonStatus` set to `LoadingStatus.loaded`.
  /// If valid, it saves the form data, updates the state to
  /// `LoadingStatus.loading`,
  /// and calls the repository to persist the reference data.
  ///
  /// Upon successful save, it logs the result, closes the dialog if the context
  /// is still mounted, and emits a state with `saveButtonStatus` set to
  /// `LoadingStatus.loaded`.
  /// If an error occurs during the save process, it shows a failure toast and
  /// resets the save button status.
  ///
  /// - Parameters:
  ///   - context: The [BuildContext] used to check widget mounting and close
  /// the dialog.
  Future<void> onSaveButtonClick(BuildContext context) async {
    try {
      if (!formKey.currentState!.validate()) {
        emit(state.copyWith(saveButtonStatus: LoadingStatus.loaded));
      } else {
        formKey.currentState?.save();
        emit(state.copyWith(saveButtonStatus: LoadingStatus.loading));
        restoreOriginalStatusIfLocked();

        final String? result = await repository.saveReferenceDataInformation(
          selectedReferenceType?.id,
          reference,
        );

        unawaited(deleteDraft());

        logger.i("Reference data save: $result");
        AlertManager().showSuccessToast("common.saveSuccess".tr());

        if (context.mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }

    emit(state.copyWith(saveButtonStatus: LoadingStatus.loaded));
  }

  /// Updates the reference model using API data.
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

    _originalStatus = reference.status;

    if (reference.status != null && reference.status!.isNotEmpty) {
      statusListValue = [reference.status!.capitalizeFirstLetter()];
    } else {
      statusListValue = [];
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Returns localized column label names for the selected reference type.
  List<String> getColumnLabelNames() {
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

  /// Initializes all input formatters based on the selected reference type.
  void initializeFormatters() {
    List<TextInputFormatter> limit(int length, String allowedPattern) {
      final normalized = normalizeAllowedRegex(
        allowedPattern,
      );

      RegExp regex;
      try {
        // dotAll + multiLine make patterns like [\s\S]* and ^...$ behave intuitively
        regex = RegExp(normalized, dotAll: true, multiLine: true);
      } on Object catch (_) {
        // Fallback if server pattern is malformed
        regex = RegExp("[a-zA-Z0-9 ]*", dotAll: true, multiLine: true);
      }

      return [
        if (length > 0) LengthLimitingTextInputFormatter(length),
        FilteringTextInputFormatter.allow(regex),
      ];
    }

    final String defaultPattern =
        selectedReferenceType?.allowedRegex ?? "[a-zA-Z0-9 ]*";

    final List<TextInputFormatter> defaultFormat = limit(
      0,
      defaultPattern,
    );

    final List<TextInputFormatter> financialYearFormatters = [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(4),
    ];

    final List<TextInputFormatter> holidayDateFormatters = [
      FilteringTextInputFormatter.allow(RegExp("[0-9/]")),
      LengthLimitingTextInputFormatter(10),
      DateInputFormatter(),
    ];

    // Apply defaults first
    nameFormatters = defaultFormat;
    descriptionFormatters = defaultFormat;
    reference1Formatters = hasHolidayMasterReferenceId
        ? [...financialYearFormatters]
        : defaultFormat;
    reference2Formatters = hasHolidayMasterReferenceId
        ? [...holidayDateFormatters]
        : defaultFormat;
    reference3Formatters = defaultFormat;
    reference4Formatters = defaultFormat;
    reference5Formatters = defaultFormat;

    // Then override where needed
    switch (selectedReferenceType?.name) {
      case ReferenceDataKeys.securityType:
      case ReferenceDataKeys.documentTypes:
      case ReferenceDataKeys.tlIssuingAuthorityList:
      case ReferenceDataKeys.caSubSubSubTypes:
      case ReferenceDataKeys.conditionAction:
      case ReferenceDataKeys.conditionStatus:
        nameFormatters = limit(50, defaultPattern);
        reference4Formatters = limit(50, defaultPattern);

      case ReferenceDataKeys.sicCodeList:
        nameFormatters = limit(20, defaultPattern);
        descriptionFormatters = limit(50, defaultPattern);

      case ReferenceDataKeys.recommendationList:
        nameFormatters = limit(50, defaultPattern);

      default:
        break;
    }

    reference1Formatters = [
      if (hasHolidayMasterReferenceId)
        ...financialYearFormatters
      else
        ...reference1Formatters,
    ];

    reference2Formatters = [
      if (hasHolidayMasterReferenceId)
        ...holidayDateFormatters
      else
        ...reference2Formatters,
    ];
  }

  /// Normalizes a server-sent regex string so it can be used in Dart's RegExp.
  ///
  /// Handles:
  /// - r'...'/r"..."
  /// - quoted strings
  /// - malformed or empty values
  String normalizeAllowedRegex(
    String? raw, {
    String fallback = "[a-zA-Z0-9 ]*",
  }) {
    if (raw == null) {
      return fallback;
    }

    String s = raw.trim();

    if (s.isEmpty) {
      return fallback;
    }

    if ((s.startsWith("r'") && s.endsWith("'")) ||
        (s.startsWith('r"') && s.endsWith('"'))) {
      s = s.substring(2, s.length - 1);
    } else if ((s.startsWith("'") && s.endsWith("'")) ||
        (s.startsWith('"') && s.endsWith('"'))) {
      s = s.substring(1, s.length - 1);
    }

    if (s.contains(r"\")) {
      return fallback;
    }

    if (s.trim().isEmpty) {
      return fallback;
    }

    return s;
  }

  /// Restores the original API status for locked ESG records.
  ///
  /// This prevents status changes from:
  /// - draft restoration
  /// - accidental programmatic mutation
  /// - save-time inconsistencies
  void restoreOriginalStatusIfLocked() {
    if (!isReferenceStatusDisabled) {
      return;
    }

    reference.status = _originalStatus;

    if (_originalStatus != null && _originalStatus!.isNotEmpty) {
      statusListValue = [_originalStatus!.capitalizeFirstLetter()];
    } else {
      statusListValue = [];
    }
  }

  @override
  Future<void> close() {
    nameController.dispose();
    descriptionController.dispose();
    reference1Controller.dispose();
    reference2Controller.dispose();
    reference3Controller.dispose();
    reference4Controller.dispose();
    reference5Controller.dispose();

    if (isDraftReady) {
      emit(state.copyWith());
    }

    unregisterDraftCallback();
    return super.close();
  }
}
