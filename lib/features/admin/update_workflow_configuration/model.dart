import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";

class UpdateWorkflowConfigViewModel
    extends SafeCubit<UpdateWorkflowConfigurationState> {
  UpdateWorkflowConfigViewModel({
    AdminRepository? adminRepository,
    ReferenceDataService Function()? referenceDataServiceFactory,
    AlertManager? alertManager,
    String Function(String key)? trFn,
  })  : _adminRepository = adminRepository,
        _referenceDataServiceFactory =
            referenceDataServiceFactory ?? ReferenceDataService.new,
        _alertManager = alertManager ?? AlertManager(),
        _trFn = trFn ?? ((k) => k.tr()),
        super(
          UpdateWorkflowConfigurationState(
            loaderStatus: LoadingStatus.loading,
            tableLoaderStatus: LoadingStatus.loaded,
          ),
        );

  final AdminRepository? _adminRepository;
  final ReferenceDataService Function() _referenceDataServiceFactory;
  final AlertManager _alertManager;
  final String Function(String key) _trFn;

  late AdminRepository repository;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FocusNode formFocusNode = FocusNode();

  int? _customAppTypeId;
  final Map<String, List<_AppTypeItem>> _variantLookup = {};
  final Map<String, String> _appTypeCodeToName = {};

  // FIX point 3 (unused): removed workflowConfigs — dialog never shows the
  // table

  // FIX point 1 (lists not getters): these are now plain lists populated
  // in _buildVariantLookup and updated in each selection handler
  List<String> availableWorkflowTypes = [];
  List<String> availableSegments = [];
  List<String> availableCategoryOptions = [];
  List<String> availableApplicationTypes = [];

  // Visibility flags — updated alongside the lists above
  bool showCategorySelection = false;
  bool showApplicationTypeDropdown = false;
  bool showNewApplicationNameField = false;

  // Form state
  String? selectedWorkflowType;
  String? selectedCustomerSegment;
  String? selectedCategory;
  String? selectedApplicationType;
  String newApplicationTypeName = "";
  String selectedStatus = ServerConstants.active;

  // FIX point 2: _draft is created on init/editConfig and fields are set
  // via onSaved/onSelected handlers — onSave() no longer rebuilds it
  late Reference _draft;
  bool isEditMode = false;
  Reference? editingConfig;

  // ── private helpers ───────────────────────────────────────────────────────

  /// Builds the variant lookup map key: "workflowName|segment|requestType"
  String _key(String workflow, String segment, String requestType) =>
      "$workflow|$segment|$requestType";

  /// Converts short segment codes to display labels.
  /// e.g. "C,F" → ["Corporate", "FI"]
  List<String> _segmentLabelsFromCode(String? code) {
    if (code == null) return [];
    return code
        .split(",")
        .map((segment) => segment.trim())
        .map(
          (segment) => ServerConstants.segmentCodeToLabel[segment] ?? segment,
        )
        .toList();
  }

  /// Converts a segment display label to its short API code.
  /// e.g. "Corporate" → "C", "FI" → "F"
  String? _segmentCodeFromLabel(String? label) {
    return ServerConstants.segmentLabelToCode[label] ?? label;
  }

  /// Converts a request type code to its UI label.
  /// e.g. "FULL" → "Full CA", "MEMO" → "Memo"
  String? _requestTypeLabelFromCode(String? code) {
    return ServerConstants.requestTypeCodeToLabel[code?.toUpperCase()] ?? code;
  }

  /// Converts a UI request type label back to its API code.
  /// e.g. "Full CA" → "FULL", "Memo" → "MEMO"
  String _requestTypeCodeFromLabel(String? label) {
    return ServerConstants.requestTypeLabelToCode[label] ??
        label?.toUpperCase() ??
        "";
  }

  /// Returns the filtered [_AppTypeItem] list for the currently selected
  /// workflow type, segment and category combination.
  List<_AppTypeItem> _filteredAppTypeItems() {
    if (selectedWorkflowType == null || selectedCustomerSegment == null) {
      return [];
    }
    if (!showCategorySelection) {
      final String prefix =
          "${selectedWorkflowType!}|${selectedCustomerSegment!}|";
      return _variantLookup.entries
          .where((e) => e.key.startsWith(prefix))
          .expand((e) => e.value)
          .toList();
    }
    if (selectedCategory == null) return [];
    return _variantLookup[_key(
          selectedWorkflowType!,
          selectedCustomerSegment!,
          selectedCategory!,
        )] ??
        [];
  }

  /// Returns the single category option when only one exists, else null.
  String? _autoLockedCategory() {
    return availableCategoryOptions.length == 1
        ? availableCategoryOptions.first
        : null;
  }

  // ── init ──────────────────────────────────────────────────────────────────

  /// Initializes the repository, creates a blank draft, loads all reference
  /// data, then pre-populates the form if [config] is provided (edit mode).
  Future<void> init(BuildContext context, Reference? config) async {
    Globals.request = null;
    logger.i("initialising UpdateWorkflowConfigViewModel");
    repository = _adminRepository ?? AdminRepository.instance;
    // FIX point 2: draft created on init, not on save
    _initDraft();
    await _loadAllReferenceData();
    if (config != null) {
      onEditConfig(config);
    }
  }

  /// Creates a blank [Reference] draft that will be filled incrementally
  /// via onSelected/onSaved handlers as the user interacts with the form.
  void _initDraft() {
    _draft = Reference(
      name: "",
      reference1: "",
      reference2: "",
      reference3: "",
      reference4: "",
      reference5: "N",
      isActive: true,
    );
  }

  // ── data loading ──────────────────────────────────────────────────────────

  /// Fetches workflowVariants, applicationType and customApplicationType
  /// from [ReferenceDataService] and builds internal lookup structures.
  Future<void> _loadAllReferenceData() async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      final ReferenceDataService svc = _referenceDataServiceFactory();
      final Map<String, List<Reference>> data = await svc.getReferenceData([
        ReferenceDataKeys.workflowVariants,
        ReferenceDataKeys.applicationType,
        ReferenceDataKeys.customApplicationType,
      ]);
      _buildAppTypeCodeMap(data[ReferenceDataKeys.applicationType] ?? []);
      _buildVariantLookup(data[ReferenceDataKeys.workflowVariants] ?? []);
      _customAppTypeId =
          svc.referenceTypeIds[ReferenceDataKeys.customApplicationType];
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      logger.e("Error loading reference data: $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Builds a code→name map from APPLICATION_TYPE reference list.
  /// e.g. { "NW": "NTB", "RR": "Risk Rating" }
  void _buildAppTypeCodeMap(List<Reference> refs) {
    _appTypeCodeToName.clear();
    for (final Reference ref in refs) {
      final String code = ref.reference1?.trim() ?? "";
      final String name = ref.name?.trim() ?? "";
      if (code.isNotEmpty && name.isNotEmpty) _appTypeCodeToName[code] = name;
    }
  }

  /// Builds the variant lookup map and populates [availableWorkflowTypes].
  /// Called once after reference data loads — no loops in getters.
  void _buildVariantLookup(List<Reference> refs) {
    _variantLookup.clear();
    availableWorkflowTypes = [];
    for (final Reference ref in refs) {
      if (ref.isActive == false) continue;
      final String workflowName = ref.name?.trim() ?? "";
      final String segment = ref.reference1?.trim() ?? "";
      final String requestType = ref.reference2?.trim() ?? "";
      final String rawCodes = ref.reference3?.trim() ?? "";
      if (workflowName.isEmpty || segment.isEmpty) continue;
      if (!availableWorkflowTypes.contains(workflowName)) {
        availableWorkflowTypes.add(workflowName);
      }
      final List<_AppTypeItem> items = rawCodes
          .split(",")
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
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

  // ── selection handlers ────────────────────────────────────────────────────

  /// Called when the user selects a workflow type.
  /// Resets all downstream selections and repopulates [availableSegments].
  void onWorkflowTypeSelected(String? value) {
    selectedWorkflowType = value;
    selectedCustomerSegment = null;
    selectedCategory = null;
    selectedApplicationType = null;
    newApplicationTypeName = "";
    _draft.reference3 = "";

    // FIX point 1: populate list here, not in getter
    availableSegments = value == null
        ? []
        : _variantLookup.keys
            .where((k) => k.startsWith("$value|"))
            .map((k) => k.split("|")[1])
            .toSet()
            .toList();

    availableCategoryOptions = [];
    availableApplicationTypes = [];
    showCategorySelection = false;
    showApplicationTypeDropdown = false;
    showNewApplicationNameField = false;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Called when the user selects a customer segment.
  /// Repopulates [availableCategoryOptions] and auto-locks if only one exists.
  /// Sets [_draft.reference2] via onSelected — not rebuilt on save.
  void onCustomerSegmentSelected(String? value) {
    selectedCustomerSegment = value;
    selectedApplicationType = null;
    newApplicationTypeName = "";

    // FIX point 2: set draft field via onSelected handler
    _draft.reference2 = _segmentCodeFromLabel(value);

    // FIX point 1: populate list here, not in getter
    if (value == null || selectedWorkflowType == null) {
      availableCategoryOptions = [];
    } else {
      final String prefix = "${selectedWorkflowType!}|$value|";
      availableCategoryOptions = _variantLookup.keys
          .where((k) => k.startsWith(prefix))
          .map((k) => k.split("|")[2])
          .toSet()
          .toList();
    }

    showCategorySelection = availableCategoryOptions.length > 1;

    // Auto-lock category if only one option exists
    selectedCategory = _autoLockedCategory();
    if (selectedCategory != null) {
      // FIX point 2: set draft field immediately when auto-locked
      _draft.reference3 = _requestTypeCodeFromLabel(selectedCategory);
    }

    _refreshApplicationTypes();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Called when the user selects a request type / category.
  /// Repopulates [availableApplicationTypes].
  /// Sets [_draft.reference3] via onSelected — not rebuilt on save.
  void onCategorySelected(String? value) {
    selectedCategory = value;
    selectedApplicationType = null;
    newApplicationTypeName = "";

    // FIX point 2: set draft field via onSelected handler
    _draft.reference3 = _requestTypeCodeFromLabel(value);

    _refreshApplicationTypes();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Called when the user selects an application type.
  /// Sets [_draft.reference1] via onSelected — not rebuilt on save.
  void onApplicationTypeSelected(String? value) {
    selectedApplicationType = value;
    newApplicationTypeName = "";
    showNewApplicationNameField = value != null;

    // FIX point 2: set draft field via onSelected handler
    final String subTypeCode = value == null
        ? ""
        : _filteredAppTypeItems()
                .where((e) => e.displayName == value)
                .firstOrNull
                ?.subTypeCode ??
            "";
    _draft.reference1 = subTypeCode;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Called on every keystroke in the new application name text field.
  /// Sets [_draft.name] incrementally — not rebuilt on save.
  void onNewApplicationTypeNameChanged(String value) {
    newApplicationTypeName = value;
    // FIX point 2: set draft field via onChanged handler
    _draft.name = value.trim();
  }

  /// Called when the user changes the status dropdown.
  /// Sets [_draft.isActive] via onSelected — not rebuilt on save.
  void onStatusChanged(String? value) {
    selectedStatus = value ?? ServerConstants.active;
    // FIX point 2: set draft field via onSelected handler
    _draft.isActive = selectedStatus == ServerConstants.active;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Repopulates [availableApplicationTypes] and [showApplicationTypeDropdown]
  /// based on the current workflow type, segment and category selection.
  void _refreshApplicationTypes() {
    final List<_AppTypeItem> items = _filteredAppTypeItems();
    availableApplicationTypes = items.map((e) => e.displayName).toList();
    showApplicationTypeDropdown = availableApplicationTypes.isNotEmpty;
  }

  // ── validation ────────────────────────────────────────────────────────────

  /// Validates the new application type name field.
  /// Returns an error string if invalid, null if valid.
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

  // ── edit handler ──────────────────────────────────────────────────────────

  /// Pre-populates all form state and [_draft] from an existing [config] row.
  /// Also restores the cascade dropdown selections via
  /// [_restoreWorkflowSelections].
  void onEditConfig(Reference config) {
    isEditMode = true;
    editingConfig = config;
    newApplicationTypeName = config.name ?? "";
    selectedStatus = (config.isActive == true)
        ? ServerConstants.active
        : ServerConstants.inactive;

    _restoreWorkflowSelections(config);

    // FIX point 2: draft created here on edit, pre-filled from config
    _draft = Reference(
      id: config.id,
      name: config.name,
      reference1: config.reference1,
      reference2: config.reference2,
      reference3: config.reference3,
      reference4: config.reference4,
      reference5: config.reference5 ?? "N",
      isActive: config.isActive,
      typeId: config.typeId ?? _customAppTypeId,
    );

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Restores the workflow type, segment, category and application type
  /// dropdown selections from a saved [config] row using the variant lookup.
  void _restoreWorkflowSelections(Reference config) {
    final String subTypeCode = config.reference1?.trim() ?? "";
    final List<String> segmentLabels =
        _segmentLabelsFromCode(config.reference2);
    final String? requestTypeLabel =
        _requestTypeLabelFromCode(config.reference3);

    for (final MapEntry<String, List<_AppTypeItem>> entry
        in _variantLookup.entries) {
      final List<String> parts = entry.key.split("|");
      if (parts.length != 3) continue;
      if (!segmentLabels.contains(parts[1])) continue;
      if (!entry.value.any((item) => item.subTypeCode == subTypeCode)) continue;

      selectedWorkflowType = parts[0];
      selectedCustomerSegment = parts[1];
      selectedCategory = requestTypeLabel;
      selectedApplicationType = _appTypeCodeToName[subTypeCode] ?? subTypeCode;

      // Restore all dependent lists so dropdowns render correctly
      availableSegments = _variantLookup.keys
          .where((k) => k.startsWith("${parts[0]}|"))
          .map((k) => k.split("|")[1])
          .toSet()
          .toList();

      final String prefix = "${parts[0]}|${parts[1]}|";
      availableCategoryOptions = _variantLookup.keys
          .where((k) => k.startsWith(prefix))
          .map((k) => k.split("|")[2])
          .toSet()
          .toList();

      showCategorySelection = availableCategoryOptions.length > 1;
      _refreshApplicationTypes();
      showNewApplicationNameField = selectedApplicationType != null;
      return;
    }

    // Fallback: subtype code not found in any variant
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

  // ── save ──────────────────────────────────────────────────────────────────

  /// Validates the form, then saves [_draft] to the repository.
  /// FIX point 2: [_draft] fields are already set by handlers — no reassignment
  /// here.
  /// Pops the dialog with true on success so the table VM can refresh.
  Future<void> onSave(BuildContext context) async {
    try {
      if (!formKey.currentState!.validate()) {
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }
      formKey.currentState!.save();
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));

      // FIX point 2: _draft fields already set via handlers — only set
      // typeId and status here as they are not user-interaction driven
      _draft.status = selectedStatus;
      _draft.typeId = _customAppTypeId;

      await repository.saveReferenceDataInformation(_customAppTypeId, _draft);
      _alertManager.showSuccessToast(_trFn("common.saveSuccess"));

      _resetForm();

      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.loaded,
          tableLoaderStatus: LoadingStatus.loaded,
        ),
      );

      if (context.mounted) Navigator.of(context).pop(true);
    } catch (e) {
      logger.e("Error saving: $e");
      _alertManager.showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Resets all form state and re-initializes the blank draft.
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
    formKey.currentState?.reset();
    _initDraft();
  }
}

class _AppTypeItem {
  const _AppTypeItem({required this.displayName, required this.subTypeCode});
  final String displayName;
  final String subTypeCode;
}
