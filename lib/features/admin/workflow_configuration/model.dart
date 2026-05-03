import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/workflow_configuration/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";

class WorkflowConfigViewModel extends SafeCubit<WorkflowConfigurationState> {
  WorkflowConfigViewModel({
    AdminRepository? adminRepository,
    ReferenceDataService Function()? referenceDataServiceFactory,
  })  : _adminRepository = adminRepository,
        _referenceDataServiceFactory =
            referenceDataServiceFactory ?? ReferenceDataService.new,
        super(
          WorkflowConfigurationState(
            loaderStatus: LoadingStatus.loading,
            tableLoaderStatus: LoadingStatus.loaded,
          ),
        );

  final AdminRepository? _adminRepository;
  final ReferenceDataService Function() _referenceDataServiceFactory;

  late AdminRepository repository;

  // FIX point 3: removed unused formKey and formFocusNode — table VM has no
  // form

  List<Reference> workflowConfigs = [];

  final Map<String, String> _appTypeCodeToName = {};
  final Map<String, List<_AppTypeItem>> _variantLookup = {};

  // ── init ──────────────────────────────────────────────────────────────────

  /// Initializes the repository and loads all reference data needed for the
  /// table.
  Future<void> init(BuildContext context) async {
    Globals.request = null;
    logger.i("initialising WorkflowConfigViewModel");
    repository = _adminRepository ?? AdminRepository.instance;
    await _loadAllReferenceData();
  }

  // ── data loading ──────────────────────────────────────────────────────────

  /// Loads workflowVariants, applicationType and customApplicationType
  /// from [ReferenceDataService], then builds internal lookup maps
  /// and populates [workflowConfigs] for the table.
  Future<void> _loadAllReferenceData() async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));

      final ReferenceDataService svc = _referenceDataServiceFactory();

      // FIX point 3 (unused): clearCache called here so refreshTable always
      // fetches fresh data after a dialog save.
      await svc.clearCache(ReferenceDataKeys.customApplicationType);

      final Map<String, List<Reference>> data = await svc.getReferenceData([
        ReferenceDataKeys.workflowVariants,
        ReferenceDataKeys.applicationType,
        ReferenceDataKeys.customApplicationType,
      ]);

      _buildAppTypeCodeMap(data[ReferenceDataKeys.applicationType] ?? []);
      _buildVariantLookup(data[ReferenceDataKeys.workflowVariants] ?? []);
      workflowConfigs = List<Reference>.from(
        data[ReferenceDataKeys.customApplicationType] ?? [],
      );

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      logger.e("Error loading workflow config data: $e");
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

  /// Builds the variant lookup map keyed as "workflowName|segment|requestType".
  /// Each entry holds the list of [_AppTypeItem]s available for that
  /// combination.
  void _buildVariantLookup(List<Reference> refs) {
    _variantLookup.clear();
    for (final Reference ref in refs) {
      if (ref.isActive == false) continue;
      final String workflowName = ref.name?.trim() ?? "";
      final String segment = ref.reference1?.trim() ?? "";
      final String requestType = ref.reference2?.trim() ?? "";
      final String rawCodes = ref.reference3?.trim() ?? "";
      if (workflowName.isEmpty || segment.isEmpty) continue;
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
          .putIfAbsent("$workflowName|$segment|$requestType", () => [])
          .addAll(items);
    }
  }

  // ── table refresh ─────────────────────────────────────────────────────────

  /// Clears cache and reloads all reference data to reflect latest saved
  /// changes.
  Future<void> refreshTable() async {
    await _loadAllReferenceData();
  }

  // ── display helpers used by the table ────────────────────────────────────

  /// Resolves an APPLICATION_TYPE subtype code to its display name.
  /// e.g. "NW" → "NTB". Falls back to [code] if not found.
  String resolveAppTypeName(String code) =>
      _appTypeCodeToName[code.trim()] ?? code;

  /// Resolves the workflow type name for a given [config] row by matching
  /// its subtype code and segment against the variant lookup.
  String resolveWorkflowTypeName(Reference config) {
    final String subTypeCode = (config.reference1 ?? "").trim();
    if (subTypeCode.isEmpty) return "";
    final List<String> segmentLabels =
        _segmentLabelsFromCode(config.reference2);
    final String? requestTypeLabel =
        _requestTypeLabelFromCode(config.reference3);

    for (final MapEntry<String, List<_AppTypeItem>> entry
        in _variantLookup.entries) {
      final List<String> parts = entry.key.split("|");
      if (parts.length != 3) continue;
      if (!segmentLabels.contains(parts[1])) continue;
      if (requestTypeLabel != null) {
        final String reqCode = _requestTypeCodeFromLabel(requestTypeLabel);
        final bool requestMatches =
            parts[2].toUpperCase() == reqCode.toUpperCase() ||
                parts[2].toUpperCase() == requestTypeLabel.toUpperCase();
        if (!requestMatches) continue;
      }
      if (!entry.value.any(
        (item) => item.subTypeCode == subTypeCode,
      )) {
        continue;
      }
      return parts[0];
    }
    return "";
  }

  /// Converts a comma-separated segment code string to a readable label.
  /// e.g. "C,F" → "Corporate, FI"
  String formatCustomerSegment(String? segmentCode) {
    if (segmentCode == null || segmentCode.trim().isEmpty) return "";
    return _segmentLabelsFromCode(segmentCode).join(", ");
  }

  // ── private converters ────────────────────────────────────────────────────

  /// Converts short segment codes to display labels.
  /// e.g. ["C", "F"] → ["Corporate", "FI"]
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

  // ── table column names ────────────────────────────────────────────────────

  /// Returns the translated column header names for the workflow config table.
  List<String> getColumnNames() {
    return [
      "admin.workflowConfig.table.id".tr(),
      "admin.workflowConfig.table.workflowType".tr(),
      "admin.workflowConfig.table.customerSegment".tr(),
      "admin.workflowConfig.table.requestType".tr(),
      "admin.workflowConfig.table.existingApplicationType".tr(),
      "admin.workflowConfig.table.newApplicationTypeName".tr(),
      "admin.workflowConfig.table.status".tr(),
    ];
  }

  /// Navigates to the Role Right admin screen.
  void onContinue() {
    router.go(Routes.adminRoleRight);
  }
}

class _AppTypeItem {
  const _AppTypeItem({required this.displayName, required this.subTypeCode});
  final String displayName;
  final String subTypeCode;
}
