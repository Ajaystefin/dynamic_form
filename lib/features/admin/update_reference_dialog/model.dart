import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
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

class UpdateReferenceDialogViewModel
    extends SafeCubit<UpdateReferenceDialogState>
    with DraftMixin<UpdateReferenceDialogViewModel> {
  UpdateReferenceDialogViewModel()
      : super(
          UpdateReferenceDialogState(
            loaderStatus: LoadingStatus.loading,
            saveButtonStatus: LoadingStatus.loaded,
          ),
        );
  late AdminRepository repository;
  FocusNode formFocusNode = FocusNode();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Reference reference = Reference();
  List<ReferenceType> allReferences = [];
  int? referenceDataTypeID = 0;

  ReferenceType? selectedReferenceType;

  List<TextInputFormatter> nameFormatters = [],
      descriptionFormatters = [],
      reference1Formatters = [],
      reference2Formatters = [],
      reference3Formatters = [],
      reference4Formatters = [],
      reference5Formatters = [];
  List<String>? statusListValue;
  List<String> statusList = [
    Status.active.name.capitalizeFirstLetter(),
    Status.inactive.name.capitalizeFirstLetter(),
  ];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController reference1Controller = TextEditingController();
  final TextEditingController reference2Controller = TextEditingController();
  final TextEditingController reference3Controller = TextEditingController();
  final TextEditingController reference4Controller = TextEditingController();
  final TextEditingController reference5Controller = TextEditingController();
// ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  bool _draftReady = false;
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

    _initializeFormatters();

    // 1. Apply API values
    onUpdateReferenceData(reference);

    // 2. Load supporting data
    await getReferenceTypes();

    // 3. Restore draft (overrides API if present)
    await loadDraftIfAvailable();

    syncControllersWithReference();
    // 5. Enable draft saving
    _draftReady = true;
    registerDraftCallback();

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onFieldChanged() {
    if (!_draftReady) return;

    emit(state.copyWith());

    // THIS IS THE MISSING LINE
    unawaited(Globals.onAutoSave?.call());
  }

  String? normalizeStatusForDropdown(String? rawStatus) {
    if (rawStatus == null || rawStatus.isEmpty) return null;
    return rawStatus.capitalizeFirstLetter();
  }

  void syncControllersWithReference() {
    nameController.text = reference.name ?? "";
    descriptionController.text = reference.description ?? "";
    reference1Controller.text = reference.reference1 ?? "";
    reference2Controller.text = reference.reference2 ?? "";
    reference3Controller.text = reference.reference3 ?? "";
    reference4Controller.text = reference.reference4 ?? "";
    reference5Controller.text = reference.reference5 ?? "";
  }

  /// Retrieves reference types from the repository and updates the state
  /// accordingly.
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
    } catch (e) {
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
      if (!(formKey.currentState!.validate())) {
        emit(state.copyWith(saveButtonStatus: LoadingStatus.loaded));
      } else {
        formKey.currentState?.save();
        emit(state.copyWith(saveButtonStatus: LoadingStatus.loading));

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
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
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

  void _initializeFormatters() {
    List<TextInputFormatter> limit(int length, String allowedPattern) {
      final normalized = normalizeAllowedRegex(
        allowedPattern,
        fallback: "[a-zA-Z0-9 ]*", // your default
      );

      RegExp regex;
      try {
        // dotAll + multiLine make patterns like [\s\S]* and ^...$ behave intuitively
        regex = RegExp(normalized, dotAll: true, multiLine: true);
      } catch (_) {
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
    final List<TextInputFormatter> defaultFormat = limit(0, defaultPattern);

    // Apply default to all fields first
    nameFormatters = defaultFormat;
    descriptionFormatters = defaultFormat;
    reference1Formatters = defaultFormat;
    reference2Formatters = defaultFormat;
    reference3Formatters = defaultFormat;
    reference4Formatters = defaultFormat;
    reference5Formatters = defaultFormat;

    switch (selectedReferenceType?.name) {
      case ReferenceDataKeys.securityType:
      case ReferenceDataKeys.documentTypes:
      case ReferenceDataKeys.tlIssuingAuthorityList:
      case ReferenceDataKeys.caSubSubSubTypes:
        nameFormatters = limit(50, "[a-zA-Z0-9 ]*");
        reference4Formatters = defaultFormat;
      case ReferenceDataKeys.sicCodeList:
        nameFormatters = limit(20, "[a-zA-Z0-9 ]*");
        descriptionFormatters = limit(50, "[a-zA-Z0-9 ]*");
      default:
        break;
    }
  }

  /// Normalizes a server-sent regex string so it can be used in Dart's RegExp.
  /// Handles:
  /// - r'...'/r"..." wrappers
  /// - plain quoted '...'/ "..." wrappers
  /// - double backslashes from JSON escaping
  /// - returns a safe fallback if empty or invalid
  String normalizeAllowedRegex(
    String? raw, {
    String fallback = "[a-zA-Z0-9 ]*",
  }) {
    if (raw == null) return fallback;

    String s = raw.trim();
    if (s.isEmpty) return fallback;

    // Remove Dart raw literal prefix with quotes: r'...' or r"..."
    if ((s.startsWith("r'") && s.endsWith("'")) ||
        (s.startsWith('r"') && s.endsWith('"'))) {
      s = s.substring(2, s.length - 1);
    }
    // Or remove plain quotes: '...' or "..."
    else if ((s.startsWith("'") && s.endsWith("'")) ||
        (s.startsWith('"') && s.endsWith('"'))) {
      s = s.substring(1, s.length - 1);
    }

    // Convert JSON-escaped backslashes \\ -> \  (important for \s, \d, etc.)
    s = s.replaceAll(r"\", "");

    // If it still ends up empty, use fallback
    if (s.trim().isEmpty) return fallback;

    return s;
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
    // Trigger one last draft save before disposal
    if (isDraftReady) {
      emit(state.copyWith());
    }
    unregisterDraftCallback();
    return super.close();
  }
}
