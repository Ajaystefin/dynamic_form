import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/draft_handler.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";

/// View model for creating and updating workflow configuration records.
class UpdateWorkflowConfigViewModel
    extends SafeCubit<UpdateWorkflowConfigurationState>
    with DraftMixin<UpdateWorkflowConfigViewModel> {
  /// Creates an [UpdateWorkflowConfigViewModel].
  UpdateWorkflowConfigViewModel({
    AdminRepository? adminRepository,
    ReferenceDataService? referenceDataService,
    AlertManager? alertManager,
    String Function(String key)? trFn,
    bool enableDraft = true,
  })  : _adminRepository = adminRepository,
        _referenceDataService = referenceDataService ?? ReferenceDataService(),
        _alertManager = alertManager ?? AlertManager(),
        _trFn = trFn ?? ((k) => k.tr()),
        _enableDraft = enableDraft,
        super(
          UpdateWorkflowConfigurationState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

  final AdminRepository? _adminRepository;
  final ReferenceDataService _referenceDataService;
  final AlertManager _alertManager;
  final String Function(String key) _trFn;
  final bool _enableDraft;

  /// Repository used for admin reference data operations.
  late AdminRepository repository;

  /// Form key used to validate and save the workflow configuration form.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Focus node used by the workflow configuration form.
  final FocusNode formFocusNode = FocusNode();

  int? _customAppTypeId;
  final Map<String, List<_AppTypeItem>> _variantLookup = {};
  final Map<String, String> _appTypeCodeToName = {};

  /// Available workflow type options.
  List<String> availableWorkflowTypes = [];

  /// Available customer segment options.
  List<String> availableSegments = [];

  /// Available category options for the selected workflow and segment.
  List<String> availableCategoryOptions = [];

  /// Available application type options.
  List<String> availableApplicationTypes = [];

  /// Indicates whether the category selection field should be shown.
  bool showCategorySelection = false;

  /// Indicates whether the application type dropdown should be shown.
  bool showApplicationTypeDropdown = false;

  /// Indicates whether the new application name field should be shown.
  bool showNewApplicationNameField = false;

  /// Currently selected workflow type.
  String? selectedWorkflowType;

  /// Currently selected customer segment.
  String? selectedCustomerSegment;

  /// Currently selected category.
  String? selectedCategory;

  /// Currently selected application type.
  String? selectedApplicationType;

  /// Name entered for the new custom application type.
  String newApplicationTypeName = "";

  /// Currently selected status.
  String selectedStatus = ServerConstants.active;

  /// Draft reference object used for autosave and save operations.
  late Reference draftReference;

  /// Indicates whether the view model is editing an existing configuration.
  bool isEditMode = false;

  /// Configuration currently being edited.
  Reference? editingConfig;

  bool _draftReady = false;

  /// Indicates whether draft functionality is ready.
  bool get isDraftReady => _draftReady;

  /// Draft module key used to identify the admin draft area.
  @override
  String get draftModuleKey => DraftModuleKeys.admin;

  /// Draft form key used to identify the workflow configuration draft.
  @override
  String get draftFormKey => "update_workflow_configuration";

  /// Draft handler used to save and restore workflow configuration drafts.
  @override
  DraftHandler<UpdateWorkflowConfigViewModel> get draftHandler =>
      UpdateWorkflowConfigDraftHandler();

  /// Reference type id for custom application type records.
  int? get customAppTypeId => _customAppTypeId;

  /// Handles changes in form fields and triggers autosave when available.
  void onFieldChanged() {
    emit(state.copyWith());

    if (!_enableDraft || !_draftReady) {
      return;
    }

    unawaited(Globals.onAutoSave?.call());
  }

  String _key(String workflow, String segment, String requestType) =>
      "$workflow|$segment|$requestType";

  List<String> _segmentLabelsFromCode(String? code) {
    if (code == null) {
      return [];
    }

    return code
        .split(",")
        .map((segment) => segment.trim())
        .map(
          (segment) => ServerConstants.segmentCodeToLabel[segment] ?? segment,
        )
        .toList();
  }

  String? _segmentCodeFromLabel(String? label) {
    return ServerConstants.segmentLabelToCode[label] ?? label;
  }

  String? _requestTypeLabelFromCode(String? code) {
    return ServerConstants.requestTypeCodeToLabel[code?.toUpperCase()] ?? code;
  }

  String _requestTypeCodeFromLabel(String? label) {
    return ServerConstants.requestTypeLabelToCode[label] ??
        label?.toUpperCase() ??
        "";
  }

  List<_AppTypeItem> _filteredAppTypeItems() {
    if (selectedWorkflowType == null || selectedCustomerSegment == null) {
      return [];
    }

    if (!showCategorySelection) {
      final String prefix =
          "${selectedWorkflowType!}|${selectedCustomerSegment!}|";
      return _variantLookup.entries
          .where((entry) => entry.key.startsWith(prefix))
          .expand((entry) => entry.value)
          .toList();
    }

    if (selectedCategory == null) {
      return [];
    }

    return _variantLookup[_key(
          selectedWorkflowType!,
          selectedCustomerSegment!,
          selectedCategory!,
        )] ??
        [];
  }

  String? _autoLockedCategory() {
    return availableCategoryOptions.length == 1
        ? availableCategoryOptions.first
        : null;
  }

  /// Initializes the view model, loads reference data, and restores draft data.
  Future<void> init(BuildContext context, Reference? config) async {
    Globals.request = null;
    logger.i("initialising UpdateWorkflowConfigViewModel");
    repository = _adminRepository ?? AdminRepository.instance;

    _initDraft();

    await _loadAllReferenceData();

    if (config != null) {
      onEditConfig(config);
    }

    if (_enableDraft && config == null) {
      await loadDraftIfAvailable();
      _draftReady = true;
      registerDraftCallback();
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void _initDraft() {
    draftReference = Reference(
      name: "",
      reference1: "",
      reference2: "",
      reference3: "",
      reference4: "",
      reference5: "N",
      isActive: true,
    );
  }

  Future<void> _loadAllReferenceData() async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));

      final Map<String, List<Reference>> data =
          await _referenceDataService.getReferenceData([
        ReferenceDataKeys.workflowVariants,
        ReferenceDataKeys.applicationType,
        ReferenceDataKeys.customApplicationType,
      ]);

      _buildAppTypeCodeMap(data[ReferenceDataKeys.applicationType] ?? []);
      _buildVariantLookup(data[ReferenceDataKeys.workflowVariants] ?? []);
      _customAppTypeId = _referenceDataService
          .referenceTypeIds[ReferenceDataKeys.customApplicationType];

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      logger.e("Error loading reference data: $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  void _buildAppTypeCodeMap(List<Reference> refs) {
    _appTypeCodeToName.clear();

    for (final Reference ref in refs) {
      final String code = ref.reference1?.trim() ?? "";
      final String name = ref.name?.trim() ?? "";

      if (code.isNotEmpty && name.isNotEmpty) {
        _appTypeCodeToName[code] = name;
      }
    }
  }

  void _buildVariantLookup(List<Reference> refs) {
    _variantLookup.clear();
    availableWorkflowTypes = [];

    for (final Reference ref in refs) {
      if (ref.isActive == false) {
        continue;
      }

      final String workflowName = ref.name?.trim() ?? "";
      final String segment = ref.reference1?.trim() ?? "";
      final String requestType = ref.reference2?.trim() ?? "";
      final String rawCodes = ref.reference3?.trim() ?? "";

      if (workflowName.isEmpty || segment.isEmpty) {
        continue;
      }

      if (!availableWorkflowTypes.contains(workflowName)) {
        availableWorkflowTypes.add(workflowName);
      }

      final List<_AppTypeItem> items = rawCodes
          .split(",")
          .map((code) => code.trim())
          .where((code) => code.isNotEmpty)
          .map(
            (code) => _AppTypeItem(
              displayName: _appTypeCodeToName[code] ?? code,
              subTypeCode: code,
            ),
          )
          .toList();

      _variantLookup
          .putIfAbsent(_key(workflowName, segment, requestType), () => [])
          .addAll(items);
    }
  }

  /// Handles workflow type selection changes.
  void onWorkflowTypeSelected(String? value) {
    selectedWorkflowType = value;
    selectedCustomerSegment = null;
    selectedCategory = null;
    selectedApplicationType = null;
    newApplicationTypeName = "";

    draftReference.reference1 = "";
    draftReference.reference2 = "";
    draftReference.reference3 = "";
    draftReference.name = "";

    availableSegments = value == null
        ? []
        : _variantLookup.keys
            .where((key) => key.startsWith("$value|"))
            .map((key) => key.split("|")[1])
            .toSet()
            .toList();

    availableCategoryOptions = [];
    availableApplicationTypes = [];
    showCategorySelection = false;
    showApplicationTypeDropdown = false;
    showNewApplicationNameField = false;

    onFieldChanged();
  }

  /// Handles customer segment selection changes.
  void onCustomerSegmentSelected(String? value) {
    selectedCustomerSegment = value;
    selectedCategory = null;
    selectedApplicationType = null;
    newApplicationTypeName = "";

    draftReference.reference2 = _segmentCodeFromLabel(value);
    draftReference.reference1 = "";
    draftReference.reference3 = "";
    draftReference.name = "";

    if (value == null || selectedWorkflowType == null) {
      availableCategoryOptions = [];
    } else {
      final String prefix = "${selectedWorkflowType!}|$value|";
      availableCategoryOptions = _variantLookup.keys
          .where((key) => key.startsWith(prefix))
          .map((key) => key.split("|")[2])
          .toSet()
          .toList();
    }

    showCategorySelection = availableCategoryOptions.length > 1;

    selectedCategory = _autoLockedCategory();
    if (selectedCategory != null) {
      draftReference.reference3 = _requestTypeCodeFromLabel(selectedCategory);
    }

    _refreshApplicationTypes();
    onFieldChanged();
  }

  /// Handles category selection changes.
  void onCategorySelected(String? value) {
    selectedCategory = value;
    selectedApplicationType = null;
    newApplicationTypeName = "";

    draftReference.reference3 = _requestTypeCodeFromLabel(value);
    draftReference.reference1 = "";
    draftReference.name = "";

    _refreshApplicationTypes();
    onFieldChanged();
  }

  /// Handles application type selection changes.
  void onApplicationTypeSelected(String? value) {
    selectedApplicationType = value;
    newApplicationTypeName = "";
    showNewApplicationNameField = value != null;

    final String subTypeCode = value == null
        ? ""
        : _filteredAppTypeItems()
                .where((item) => item.displayName == value)
                .firstOrNull
                ?.subTypeCode ??
            "";

    draftReference.reference1 = subTypeCode;
    draftReference.name = "";

    onFieldChanged();
  }

  /// Handles changes to the new application type name.
  void onNewApplicationTypeNameChanged(String value) {
    newApplicationTypeName = value;
    draftReference.name = value.trim();
    onFieldChanged();
  }

  /// Handles active or inactive status changes.
  void onStatusChanged(String? value) {
    selectedStatus = value ?? ServerConstants.active;
    draftReference.isActive = selectedStatus == ServerConstants.active;
    draftReference.status = selectedStatus;
    onFieldChanged();
  }

  void _refreshApplicationTypes() {
    final List<_AppTypeItem> items = _filteredAppTypeItems();
    availableApplicationTypes = items.map((item) => item.displayName).toList();
    showApplicationTypeDropdown = availableApplicationTypes.isNotEmpty;
  }

  /// Validates the new application type name field.
  String? validateNewApplicationTypeName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _trFn(
        "admin.workflowConfig.validation.newApplicationTypeNameRequired",
      );
    }

    if (value.trim().length > 100) {
      return _trFn(
        "admin.workflowConfig.validation.newApplicationTypeNameMaxLength",
      );
    }

    return null;
  }

  /// Loads an existing workflow configuration into edit mode.
  void onEditConfig(Reference config) {
    isEditMode = true;
    editingConfig = config;
    newApplicationTypeName = config.name ?? "";
    selectedStatus = (config.isActive ?? false)
        ? ServerConstants.active
        : ServerConstants.inactive;

    _restoreWorkflowSelections(config);

    draftReference = Reference(
      id: config.id,
      name: config.name,
      reference1: config.reference1,
      reference2: config.reference2,
      reference3: config.reference3,
      reference4: config.reference4,
      reference5: config.reference5 ?? "N",
      isActive: config.isActive,
      status: selectedStatus,
      typeId: config.typeId ?? _customAppTypeId,
    );

    onFieldChanged();
  }

  void _restoreWorkflowSelections(Reference config) {
    final String subTypeCode = config.reference1?.trim() ?? "";
    final List<String> segmentLabels =
        _segmentLabelsFromCode(config.reference2);
    final String? requestTypeLabel =
        _requestTypeLabelFromCode(config.reference3);

    for (final MapEntry<String, List<_AppTypeItem>> entry
        in _variantLookup.entries) {
      final List<String> parts = entry.key.split("|");
      if (parts.length != 3) {
        continue;
      }

      if (!segmentLabels.contains(parts[1])) {
        continue;
      }

      if (!entry.value.any((item) => item.subTypeCode == subTypeCode)) {
        continue;
      }

      selectedWorkflowType = parts[0];
      selectedCustomerSegment = parts[1];
      selectedCategory = requestTypeLabel;
      selectedApplicationType = _appTypeCodeToName[subTypeCode] ?? subTypeCode;

      availableSegments = _variantLookup.keys
          .where((key) => key.startsWith("${parts[0]}|"))
          .map((key) => key.split("|")[1])
          .toSet()
          .toList();

      final String prefix = "${parts[0]}|${parts[1]}|";
      availableCategoryOptions = _variantLookup.keys
          .where((key) => key.startsWith(prefix))
          .map((key) => key.split("|")[2])
          .toSet()
          .toList();

      showCategorySelection = availableCategoryOptions.length > 1;
      _refreshApplicationTypes();
      showNewApplicationNameField = selectedApplicationType != null;
      return;
    }

    selectedWorkflowType = null;
    selectedCustomerSegment = null;
    selectedCategory = null;
    selectedApplicationType = _appTypeCodeToName[subTypeCode] ?? subTypeCode;

    availableSegments = [];
    availableCategoryOptions = [];
    availableApplicationTypes = [];
    showCategorySelection = false;
    showApplicationTypeDropdown = false;
    showNewApplicationNameField = selectedApplicationType != null;
  }

  /// Saves the workflow configuration reference data.
  Future<void> onSave(BuildContext context) async {
    try {
      if (!formKey.currentState!.validate()) {
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }

      if (_customAppTypeId == null) {
        _alertManager.showFailureToast(
          _trFn("admin.workflowConfig.validation.missingReferenceTypeId"),
        );
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }

      formKey.currentState!.save();
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));

      draftReference.status = selectedStatus;
      draftReference.isActive = selectedStatus == ServerConstants.active;
      draftReference.typeId = _customAppTypeId;

      await repository.saveReferenceDataInformation(
        _customAppTypeId,
        draftReference,
      );

      if (_enableDraft) {
        unawaited(deleteDraft());
      }

      _alertManager.showSuccessToast(_trFn("common.saveSuccess"));

      _resetForm();

      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.loaded,
          tableLoaderStatus: LoadingStatus.loaded,
        ),
      );

      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    } on Object catch (e) {
      logger.e("Error saving: $e");
      _alertManager.showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  void _resetForm() {
    isEditMode = false;
    editingConfig = null;
    selectedWorkflowType = null;
    selectedCustomerSegment = null;
    selectedCategory = null;
    selectedApplicationType = null;
    newApplicationTypeName = "";
    selectedStatus = ServerConstants.active;

    availableSegments = [];
    availableCategoryOptions = [];
    availableApplicationTypes = [];

    showCategorySelection = false;
    showApplicationTypeDropdown = false;
    showNewApplicationNameField = false;

    formFocusNode.unfocus();
    formKey.currentState?.reset();

    _initDraft();
  }

  /// Closes the view model and unregisters draft callbacks.
  @override
  Future<void> close() {
    formFocusNode.dispose();

    if (_enableDraft && isDraftReady) {
      emit(state.copyWith());
      unregisterDraftCallback();
    }

    return super.close();
  }
}

class _AppTypeItem {
  const _AppTypeItem({
    required this.displayName,
    required this.subTypeCode,
  });

  final String displayName;
  final String subTypeCode;
}
