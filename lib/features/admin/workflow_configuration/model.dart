import "package:easy_localization/easy_localization.dart";
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

/// View model for managing workflow configuration list data.
class WorkflowConfigViewModel extends SafeCubit<WorkflowConfigurationState> {
  /// Creates a [WorkflowConfigViewModel].
  WorkflowConfigViewModel({
    ReferenceDataService? referenceDataService,
  })  : _referenceDataService = referenceDataService ?? ReferenceDataService(),
        super(
          WorkflowConfigurationState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

  final ReferenceDataService _referenceDataService;

  /// Workflow configuration records displayed in the table.
  List<Reference> workflowConfigs = [];

  final Map<String, String> _appTypeCodeToName = {};
  final Map<String, List<_AppTypeItem>> _variantLookup = {};

  /// Initializes the view model and loads all data required by the table.
  Future<void> init() async {
    Globals.request = null;
    logger.i("initialising WorkflowConfigViewModel");
    await _loadAllReferenceData();
  }

  /// Loads all workflow configuration related reference data.
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
      workflowConfigs = List<Reference>.from(
        data[ReferenceDataKeys.customApplicationType] ?? [],
      );

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      logger.e("Error loading workflow config data: $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Clears cache and reloads the table data.
  Future<void> refreshTable() async {
    await _referenceDataService.clearCache(
      ReferenceDataKeys.customApplicationType,
    );
    await _loadAllReferenceData();
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

  /// Builds the variant lookup map keyed as "workflowName|segment|requestType".
  /// Each entry holds the list of [_AppTypeItem]s available for that
  /// combination.
  void _buildVariantLookup(List<Reference> refs) {
    _variantLookup.clear();
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

      final List<_AppTypeItem> items = rawCodes
          .split(",")
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .map((code) => _AppTypeItem(subTypeCode: code))
          .toList();

      _variantLookup
          .putIfAbsent("$workflowName|$segment|$requestType", () => [])
          .addAll(items);
    }
  }

  /// Resolves an APPLICATION_TYPE subtype code to its display name.
  /// e.g. "NW" → "NTB". Falls back to [code] if not found.
  String resolveAppTypeName(String code) =>
      _appTypeCodeToName[code.trim()] ?? code;

  /// Resolves the workflow type name for a given [config] row by matching
  /// its subtype code and segment against the variant lookup.
  String resolveWorkflowTypeName(Reference config) {
    final String subTypeCode = (config.reference1 ?? "").trim();
    if (subTypeCode.isEmpty) {
      return "";
    }

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

      if (requestTypeLabel != null) {
        final String reqCode = _requestTypeCodeFromLabel(requestTypeLabel);
        final bool requestMatches =
            parts[2].toUpperCase() == reqCode.toUpperCase() ||
                parts[2].toUpperCase() == requestTypeLabel.toUpperCase();
        if (!requestMatches) {
          continue;
        }
      }

      if (!entry.value.any((item) => item.subTypeCode == subTypeCode)) {
        continue;
      }
      return parts[0];
    }
    return "";
  }

  /// Converts a comma-separated segment code string to a readable label.
  /// e.g. "C,F" → "Corporate, FI"
  String formatCustomerSegment(String? segmentCode) {
    if (segmentCode == null || segmentCode.trim().isEmpty) {
      return "";
    }
    return _segmentLabelsFromCode(segmentCode).join(", ");
  }

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

  String? _requestTypeLabelFromCode(String? code) {
    return ServerConstants.requestTypeCodeToLabel[code?.toUpperCase()] ?? code;
  }

  String _requestTypeCodeFromLabel(String? label) {
    return ServerConstants.requestTypeLabelToCode[label] ??
        label?.toUpperCase() ??
        "";
  }

  /// Returns localized workflow configuration table column names.
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

  /// Handles save action for workflow configuration navigation.
  Future<void> onSave() async {
    try {
      router.go(Routes.home);
    } on Object catch (e) {
      logger.e("Error saving workflow config: $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }
}

class _AppTypeItem {
  const _AppTypeItem({required this.subTypeCode});

  final String subTypeCode;
}
