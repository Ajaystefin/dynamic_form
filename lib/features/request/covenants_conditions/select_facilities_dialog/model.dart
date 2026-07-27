import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";
import "package:wcas_frontend/models/request/facility_security/security.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";

/// Filter types used in the select facilities table.
enum Filter {
  /// RIM number filter.
  rimNo,

  /// Limit number filter.
  limitNumber,

  /// Limit label/project name filter.
  limitLabel,

  /// Limit description filter.
  limitDescription,
}

/// View model for the Select Facilities dialog.
class SelectFacilitiesDialogViewModel
    extends SafeCubit<SelectFacilitiesDialogState> {
  /// Creates a Select Facilities dialog view model.
  SelectFacilitiesDialogViewModel()
      : super(
          const SelectFacilitiesDialogState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

  // Repositories & Services

  /// Facility security repository instance.
  final FacilitySecurityRepository repository = FacilitySecurityRepository();

  // UI flags

  /// Indicates whether the checkbox column should be displayed.
  bool showCheckboxColumn = true;

  // Data

  /// All facilities returned for linkage.
  List<Facility> facilities = [];

  /// Facilities selected in the dialog.
  List<Facility> selectedFacilities = [];

  // Paging

  /// Current table page.
  int page = 0;

  /// Number of rows displayed per page.
  int rowsPerPage = 7;

  // Selection model

  /// Checkbox state list aligned with [filteredData].
  List<bool> checkboxes = [];

  /// Indicates whether all visible rows are selected.
  bool isSelectAll = false;

  /// Indicates whether dialog was opened from Security Summary.
  bool isFromSecuritySummary = false;

  /// Indicates whether dialog was opened from Facility Security Linkage.
  bool isFromLinakage = false;

  // Filters

  /// Facilities after current filters are applied.
  List<Facility> filteredData = [];

  /// RIM filter current value.
  String? rimFilterCtrl;

  /// Limit number filter current value.
  String? limitNumFilterCtrl;

  /// Project/limit label filter current value.
  String? projFilterCtrl;

  /// Limit description filter current value.
  String? descFilterCtrl;

  // Reference data

  /// Yes/No/NA reference options.
  List<Reference> yesNoNaOptions = [];

  /// Security item used for linkage.
  Security? securityItem = Security();

  /// Facility type reference options.
  List<Reference> facilityTypeOptions = [];

  /// Selected all facilities Yes/No option.
  Reference? selectedAllFailitiesYesNo;

  /// Indicates whether dialog was opened from covenant flow.
  bool isFromCovenant = false;

  /// When true, the dialog renders a Securities list linked to a specific facility limit number.
  ///
  /// Triggered from Facility Summary "Linked Securities" icon, passing `linkedLimitNo`.
  /// This is a read-only display mode
  bool isLinkedSecuritiesMode = false;

  /// Facility limit number used to filter linked securities (e.g., "ODA0003").
  String? linkedLimitNo;

  /// All securities returned by security summary API for the application.
  List<Security> securitySummaryList = [];

  /// Securities filtered to those linked to `linkedLimitNo` (or allFacilities=true).
  List<Security> linkedSecuritiesForLimit = [];

  /// Normalizes any value used in selection keys and comparisons.
  ///
  /// - Converts to `String`
  /// - Trims whitespace
  /// - Uppercases (case-insensitive comparisons)
  String _normalizeValue(Object? value) {
    return value?.toString().trim().toUpperCase() ?? "";
  }

  /// Security type reference options.
  List<Reference> securityTypeOptions = [];

  /// Returns a stable, *row-unique* identifier for a Facility row shown in the
  /// Facilities–Securities Linkage selection grid.
  ///
  /// Why this exists:
  /// - The linkage grid can contain the same **Limit No** under different **RIM
  /// No**
  ///   (e.g. ODA0001 for two borrowers), so using Limit No alone causes
  ///   unintended multi-row selection.
  ///
  /// Key strategy (highest priority first):
  /// 1) If `facilitySummaryId` exists, use it as the unique identity.
  /// 2) Else if `limitNumber` comes as `rimNo|limitNo|limitCode`, keep the FULL
  /// value.
  /// 3) Else fallback to `rimNo|limitNo` composite.
  ///
  /// This key is only for UI selection tracking (checkbox state).
  String _facilitySelectionKey(Facility facility) {
    // final int? facilitySummaryId = facility.facilitySummaryId;
    // if (facilitySummaryId != null && facilitySummaryId > 0) {
    //   return "FACILITY_SUMMARY_ID:$facilitySummaryId";
    // }

    final String normalizedLimitNumber = _normalizeValue(facility.limitNumber);
    if (normalizedLimitNumber.isEmpty) {
      return "";
    }

    if (normalizedLimitNumber.contains("|")) {
      // Preserve compound key: rimNo|limitNo|limitCode
      return normalizedLimitNumber;
    }

    final String normalizedRimNo = _normalizeValue(facility.rimNo);
    if (normalizedRimNo.isNotEmpty) {
      return "$normalizedRimNo|$normalizedLimitNumber";
    }

    return normalizedLimitNumber;
  }

  /// Previously linked entries (from security summary)
  late final Set<String> linkedLimitNumbers;

  /// Authoritative selected set (normalized limitNumber keys)
  final Set<String> selectedIds = <String>{};

  // === Standardized error messages (match your spec) ===

  /// Error shown when non-cash collateral cannot link all non LC/LG facilities.
  String kErrNonCashAllNonLcLg =
      "covenantsConditions.selectFacilityDialog.facilities_non_cash".tr();

  //'Facilities cannot be linked with non-cash collateral security';

  /// Error shown when non-cash collateral has any non LC/LG selected facility.
  String kErrNonCashHasAnyNonLcLg =
      "covenantsConditions.selectFacilityDialog.facilities_non_cash_other_than"
          .tr();

  //'Facilities other than LC/LG cannot be linked with non-cash collateral security';

  /// Page mode for the dialog.
  PageMode pageMode = PageMode.na;

  /// Indicates whether the dialog can be edited.
  bool get canEdit => pageMode == PageMode.edit;

  /// Indicates whether the current flow is FI flow.
  bool get isFIFlow =>
      Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

  /// Initializes the Select Facilities dialog for different entry points.
  ///
  /// Entry points supported:
  /// - `isSecuritySummary`: read-only mode (checkbox hidden).
  /// - `linkedLimitNo`: when provided along with `isSecuritySummary=true`,
  /// - `isLinakage`: facility-security linkage flow (editable selection + save).
  /// - Facilities–Securities Linkage (editable selection + validations)
  /// - Covenants flow (returns selected facilities + allFacilities option)
  ///
  /// The grid fields are aligned to the linkage UI: **RIM No**, **Limit No**,
  /// **Limit Description**, etc.
  Future<void> init(
    BuildContext? context,
    List<Facility> selectedFacility,
    Security? securityItemindex,
    PageMode? overridePageMode,
    Reference? preselectedAllFacilities, {
    bool isSecuritySummary = false,
    bool isLinakage = false,
    bool isCovenant = false,
    String? linkedLimitNo,
  }) async {
    logger.i("initialising SelectFacilitiesDialogViewModel");
    pageMode = overridePageMode ??
        AuthRepository.getPageMode(RightConstants.facilitySecurityLinkage);

    isFromSecuritySummary = isSecuritySummary;
    isFromLinakage = isLinakage;
    isFromCovenant = isCovenant;

    this.linkedLimitNo = linkedLimitNo;
    isLinkedSecuritiesMode = isFromSecuritySummary &&
        (linkedLimitNo != null && linkedLimitNo.trim().isNotEmpty);

    if (isFromSecuritySummary) {
      showCheckboxColumn = false;
    }

    securityItem = securityItemindex ?? Security();

    if (selectedFacility.isNotEmpty) {
      selectedFacilities = List<Facility>.from(selectedFacility);
    }

    if (preselectedAllFacilities != null) {
      selectedAllFailitiesYesNo = preselectedAllFacilities;
    }

    // For Covenants: if YES was previously picked, hide the checkbox column now
    if (isFromCovenant) {
      final bool wasYes =
          (selectedAllFailitiesYesNo?.id == ServerConstants.optionYESid) ||
              (selectedAllFailitiesYesNo?.id == ServerConstants.yesRefId);
      showCheckboxColumn = !wasYes;
      if (isFromSecuritySummary) {
        showCheckboxColumn = false; // keep existing rule
      }
    }

    // For Linkage: if allFacilities=true was previously saved (API response),
    // hide the checkbox column on open — mirrors the covenant rule above.
    // Scoped strictly to isFromLinakage; does not affect any other flow.
    if (isFromLinakage && (securityItem?.allFacilities ?? false)) {
      showCheckboxColumn = false;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      await fetchYesNoNaReferenceData();
      // ───────────────────────────────────────────────────────────────────────
      // Linked Securities mode (Facility Summary → Linked Securities)
      // ───────────────────────────────────────────────────────────────────────
      if (isLinkedSecuritiesMode) {
        securitySummaryList = await repository.getSecuritySummaryList();
        linkedSecuritiesForLimit = _filterLinkedSecuritiesForLimit(
          securitySummaryList: securitySummaryList,
          limitNumberTarget: linkedLimitNo!.trim(),
        );

        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }
      facilities = await repository.getLinkageFacility();
      if (isFromSecuritySummary) {
        // Summary mode: show everything and emit once.
        // sets filteredData = facilities, rebuilds mirrors, emits
        showAllFacilities();
        return; // optional: stop here; summary mode is complete
      } else {
        // --- Non-summary mode ---
        // Always show all facilities initially (Always Filter with except
        // 935 limit caps,PSBL and PSPL).
        if (facilities.isNotEmpty) {
          filteredData = facilities.where((f) {
            // 1) Exclude Limit Caps (935)
            if (f.limitCode == ServerConstants.facilityLinkageLimitCaps) {
              return false;
            }

            // 2) Exclude Project header product codes (PSBL/PSPL)
            final String pc = (f.productCode ?? "").trim().toUpperCase();
            if (pc == ServerConstants.productCodePsbl ||
                pc == ServerConstants.productCodePspl) {
              return false;
            }

            return true;
          }).toList();
        }

        if (securityItem?.facilityNoList != null &&
            (securityItem?.facilityNoList ?? []).isNotEmpty) {
          _seedSelectionFromFacilityNoList(
            securityItem?.selectedFacilityNoList ?? const <Facility?>[],
          );
        }

        // Covenant-only preselect (checkboxes + radio) ———
        if (isFromCovenant) {
          //  Seed radio
          if (preselectedAllFacilities != null) {
            selectedAllFailitiesYesNo = preselectedAllFacilities;
          }
          // seed selected IDs from incoming facilities (by limitNumber)
          if (selectedFacilities.isNotEmpty) {
            selectedIds.addAll(
              selectedFacilities
                  .map(_facilitySelectionKey)
                  .where((k) => k.isNotEmpty),
            );
          }
        }

        _rebuildCheckboxesFromSelection();
        _recalcSelectAll();
        _rebuildSelectedFacilities();
        _emitRefresh();
      }
    } on Object catch (e, st) {
      logger.e(
        "Failed to init SelectFacilitiesDialogViewModel",
        error: e,
        stackTrace: st,
      );
      if (e.toString().isNotEmpty) {
        AlertManager().showFailureToast(e.toString());
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Filters security summary list to securities linked to the given facility limit number.
  ///
  /// Linkage rules:
  /// - If `security.allFacilities == true` → treat as linked for all facilities.
  /// - Else match against `security.facilityNoList` (List String?) containing the target limit no.
  List<Security> _filterLinkedSecuritiesForLimit({
    required List<Security> securitySummaryList,
    required String limitNumberTarget,
  }) {
    final String normalizedTarget = limitNumberTarget.trim().toUpperCase();

    bool isSecurityLinkedToTarget(Security security) {
      // if security linked to all facilities
      final bool isLinkedToAllFacilities = security.allFacilities ?? false;
      if (isLinkedToAllFacilities) {
        return true;
      }

      final dynamic raw = security.facilityNoList;

      // facilityNoList may come as String OR List depending on backend serialization
      if (raw == null) {
        return false;
      }

      if (raw is String) {
        final String txt = raw.trim();
        if (txt.isEmpty) {
          return false;
        }
        final Set<String> parts = txt
            .split(RegExp(r"[,\|]"))
            .map((e) => e.trim().toUpperCase())
            .where((e) => e.isNotEmpty)
            .toSet();
        return parts.contains(normalizedTarget);
      }

      if (raw is List) {
        final Set<String> parts = raw
            .whereType<String>()
            .map((e) => e.trim().toUpperCase())
            .where((e) => e.isNotEmpty)
            .toSet();
        return parts.contains(normalizedTarget);
      }
      return raw.toString().toUpperCase().contains(normalizedTarget);
    }

    return securitySummaryList.where(isSecurityLinkedToTarget).toList();
  }

  /// Returns security type reference name by security code.
  String securityTypeReferenceNameByCode(String? code) {
    final String normalized = (code ?? "").trim().toUpperCase();
    if (normalized.isEmpty) {
      return "";
    }

    final Reference matched = securityTypeOptions.firstWhere(
      (e) => (e.reference3 ?? "").trim().toUpperCase() == normalized,
      orElse: Reference.new,
    );
    return matched.name ?? normalized;
  }

  /// Seeds the selected checkbox set from backend-saved facility identifiers.
  ///
  /// Backend may persist:
  /// - Plain **Limit No** (e.g. `ODA0001`)
  /// - Compound `rimNo|limitNo|limitCode`
  /// - Or a unique ID-style key (if later enhanced)
  ///
  /// Because **Limit No** can repeat across different **RIM No**, this method
  /// maps
  /// saved Limit No(s) to all matching visible facility rows to keep backward
  /// compatibility.
  void _seedSelectionFromFacilityNoList(
    List<Facility?> selectedFacilityNoList,
  ) {
    if (selectedFacilityNoList.isEmpty) {
      return;
    }

    // Map: PLAIN_LIMIT_NO -> [UI_SELECTION_KEY, ...]
    final Map<String, List<String>> limitNoToSelectionKeys =
        <String, List<String>>{};

    for (final Facility facility in facilities) {
      final String normalizedLimitNumber =
          _normalizeValue(facility.limitNumber);

      final String plainLimitNo = (normalizedLimitNumber.contains("|") &&
              normalizedLimitNumber.split("|").length >= 2)
          ? normalizedLimitNumber.split("|")[1]
          : normalizedLimitNumber;

      if (plainLimitNo.isEmpty) {
        continue;
      }

      limitNoToSelectionKeys.putIfAbsent(plainLimitNo, () => <String>[]);
      limitNoToSelectionKeys[plainLimitNo]!
          .add(_facilitySelectionKey(facility));
    }

    for (final Facility? rawSavedValue in selectedFacilityNoList) {
      final String normalizedSavedValue =
          "${_normalizeValue(rawSavedValue?.rimNo)}|${_normalizeValue(rawSavedValue?.limitNumber)}";

      if (normalizedSavedValue.isEmpty) {
        continue;
      }

      // If backend already returns compound keys or ID-based keys, trust them.
      final bool looksLikeCompoundKey = normalizedSavedValue.contains("|");
      final bool looksLikeIdKey =
          normalizedSavedValue.startsWith("FACILITY_SUMMARY_ID:");

      if (looksLikeCompoundKey || looksLikeIdKey) {
        selectedIds.add(normalizedSavedValue);
        continue;
      }

      // Legacy: treat saved value as plain Limit No.
      final List<String>? matchingKeys =
          limitNoToSelectionKeys[normalizedSavedValue];
      if (matchingKeys != null && matchingKeys.isNotEmpty) {
        selectedIds.addAll(matchingKeys);
      }
    }
  }

  /// Show ALL facilities and rebuild UI mirrors from the authoritative
  /// selection (selectedIds).
  void showAllFacilities() {
    // 1) Reset the visible dataset
    // (Always Filter with except 935 limit caps,PSBL and PSPL)
    if (facilities.isNotEmpty) {
      filteredData = facilities.where((f) {
        if (f.limitCode == ServerConstants.facilityLinkageLimitCaps) {
          return false;
        }
        final String pc = (f.productCode ?? "").trim().toUpperCase();
        if (pc == ServerConstants.productCodePsbl ||
            pc == ServerConstants.productCodePspl) {
          return false;
        }
        return true;
      }).toList();
    }
    // 2) Rebuild mirrors (checkboxes, select-all, selectedFacilities)
    _rebuildCheckboxesFromSelection();
    _recalcSelectAll();
    _rebuildSelectedFacilities();
    // 3) Emit so Bloc/Flutter rebuild the UI
    _emitRefresh(); // keep using your standard emitter
  }

  /// Fetches Yes/No/NA, facility type, and security type reference data.
  Future<void> fetchYesNoNaReferenceData() async {
    try {
      final String facilityTypeKey = isFIFlow
          ? ReferenceDataKeys.fiFacilityTypes
          : ReferenceDataKeys.facilityTypes;

      final String securityTypeKey = isFIFlow
          ? ReferenceDataKeys.fiSecurityType
          : ReferenceDataKeys.securityType;

      final Map<String, List<Reference>> referenceData =
          await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.yesNoNa,
        facilityTypeKey,
        securityTypeKey,
      ]);

      yesNoNaOptions = referenceData[ReferenceDataKeys.yesNoNa] ?? [];
      facilityTypeOptions = referenceData[facilityTypeKey] ?? [];
      securityTypeOptions = referenceData[securityTypeKey] ?? [];
    } on Object catch (e) {
      // Preserve original behavior (rethrow), but log for visibility
      logger.e("fetchYesNoNaReferenceData error: $e");
      rethrow;
    }
  }

  /// Converts a value to int when possible.
  int? toIntOrNull(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }

  // Normalizer used only when caseInsensitive=true

  /// Normalizes string values for case-insensitive comparison.
  String norm(String? value) => (value ?? "").toLowerCase().trim();

  // --- Filtering ---

  /// Applies a filter to the facilities table.
  void onFilter(
    Filter filter, {
    required String value,
  }) {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      final String normalizedInput = value.trim();

      filteredData = facilities.where((data) {
        switch (filter) {
          case Filter.rimNo:
            {
              final String rim = _normalizeValue(data.rimNo);
              return rim.contains(_normalizeValue(normalizedInput));
            }

          case Filter.limitNumber:
            {
              final String limit = _normalizeValue(data.limitNumber);
              return limit.contains(_normalizeValue(normalizedInput));
            }

          case Filter.limitLabel:
            {
              final String label = (data.limitLabel ?? "").toLowerCase().trim();
              return label.contains(normalizedInput.toLowerCase());
            }

          case Filter.limitDescription:
            {
              final String desc =
                  (data.limitDescription ?? "").toLowerCase().trim();

              final int id = toIntOrNull(data.limitCode) ?? -1;

              final Reference matched = facilityTypeOptions.firstWhere(
                (e) => e.id == id,
                orElse: () => Reference(id: -1, name: "--"),
              );

              final String candidateRaw = matched.name!.trim();
              final String candidate = candidateRaw.toLowerCase().trim();

              final String keyword = normalizedInput.toLowerCase();

              final bool typeOk =
                  keyword.isEmpty || candidate.contains(keyword);

              if (id == -1 || candidateRaw == "--") {
                return desc.contains(keyword);
              }

              return typeOk; // candidate.contains(keyword); // desc.contains(normalizedInput.toLowerCase());
            }
        }
      }).toList();

      filteredData = filteredData.where((f) {
        if (f.limitCode == ServerConstants.facilityLinkageLimitCaps) {
          return false;
        }
        final String pc = (f.productCode ?? "").trim().toUpperCase();
        return pc != ServerConstants.productCodePsbl &&
            pc != ServerConstants.productCodePspl;
      }).toList();
      // Update filter control values (kept as-is)
      switch (filter) {
        case Filter.rimNo:
          rimFilterCtrl = value;
        case Filter.limitNumber:
          limitNumFilterCtrl = value;
        case Filter.limitLabel:
          projFilterCtrl = value;
        case Filter.limitDescription:
          descFilterCtrl = value;
      }

      // Always rebuild checkbox model from authoritative selection set After
      // filteredData is updated:
      _rebuildCheckboxesFromSelection();
      _recalcSelectAll();
      _rebuildSelectedFacilities();
      _emitRefresh();
    } on Object catch (e, st) {
      // Optional: emit failure state if you have one
      // emit(state.copyWith(loaderStatus: LoadingStatus.error));
      logger.i("onFilter error: $e\n$st");
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  // --- Radio button YES/NO for "link all facilities?" ---

  /// Updates whether all facilities should be linked.
  void updateFacilityLinkageOption(
    Reference? selectedOption, {
    bool clearSelected = true,
  }) {
    try {
      selectedAllFailitiesYesNo = selectedOption;

      final bool isYes = (selectedOption?.id == ServerConstants.optionYESid) ||
          (selectedOption?.id == ServerConstants.yesRefId);

      showCheckboxColumn = !isYes;
      if (isFromSecuritySummary) {
        showCheckboxColumn = false;
      }

      // IMPORTANT FIX
      if (isYes) {
        final Set<String> visibleKeys = filteredData
            .map(_facilitySelectionKey)
            .where((facility) => facility.isNotEmpty)
            .toSet();
        selectedIds
          ..clear()
          ..addAll(visibleKeys);
      } else if (clearSelected) {
        selectedIds.clear(); //  mandatory
      }
      _rebuildCheckboxesFromSelection();
      _recalcSelectAll();
      _rebuildSelectedFacilities();

      emit(
        state.copyWith(loaderStatus: LoadingStatus.loaded),
      ); // keep your emit
    } on Object {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  // --- Select All toggle ---

  /// Toggles select all for visible facilities.
  void toggleSelectAll({bool? selectedValue}) {
    final bool newValue = selectedValue ?? false;
    isSelectAll = newValue;

    final Set<String> visibleKeys =
        filteredData.map(_facilitySelectionKey).toSet();

    if (newValue) {
      selectedIds.addAll(visibleKeys);
    } else {
      selectedIds.removeAll(visibleKeys);
    }

    _rebuildCheckboxesFromSelection();
    _recalcSelectAll();
    _rebuildSelectedFacilities();
    _emitRefresh();
  }

  // --- Per-row checkbox toggle with ID-only LC/LG validation ---

  /// Updates one checkbox row by index.
  void updateCheckboxAtIndex(int index, {required bool newValue}) {
    if (index < 0 || index >= filteredData.length) {
      return;
    }

    final String key = _facilitySelectionKey(filteredData[index]);
    if (key.isEmpty) {
      return;
    }

    newValue ? selectedIds.add(key) : selectedIds.remove(key);

    _rebuildCheckboxesFromSelection();
    _recalcSelectAll();
    _rebuildSelectedFacilities();
    _emitRefresh();
  }

  void _rebuildSelectedFacilities() {
    // Keep selectedFacilities consistent if other layers depend on it
    selectedFacilities
      ..clear()
      ..addAll(
        facilities.where(
          (facility) => selectedIds.contains(_facilitySelectionKey(facility)),
        ),
      );
  }

  void _recalcSelectAll() {
    // Select-all is true when every visible row is selected
    if (filteredData.isEmpty) {
      isSelectAll = false;
      return;
    }
    isSelectAll = filteredData.every(
      (facility) => selectedIds.contains(_facilitySelectionKey(facility)),
    );
  }

  void _rebuildCheckboxesFromSelection() {
    // Build checkboxes to mirror filteredData and reflect selection membership
    final int len = filteredData.length;
    if (len == 0) {
      checkboxes = <bool>[];
      return;
    }

    // Regenerate with exact length = filteredData.length
    checkboxes = List<bool>.generate(
      len,
      (i) {
        final String facilityKey =
            "${_normalizeValue(filteredData[i].rimNo)}|${_normalizeValue(filteredData[i].limitNumber)}"
                .trim();

        return selectedIds.contains(facilityKey);
        // return selectedIds.contains(_facilitySelectionKey(facilities[i]));
      },

      growable: false, // fixed-size to match visible rows
    );
  }

  /// Build a map CODE -> ID from the master list once (e.g., on screen init).
  Map<String, int> buildCodeToIdMap(List<Reference> facilityTypeOptions) {
    final Map<String, int> map = {};
    for (final Reference reference in facilityTypeOptions) {
      final String code = (reference.reference3 ?? "").trim().toUpperCase();
      final int? id = reference.id;
      if (code.isNotEmpty && id != null) {
        map[code] = id;
      }
    }
    return map;
  }

  /// Attempts to derive ID from facility code using the code->id map.
  /// Adjust `facility` field for the code (reference3/limitGroup/etc.).
  int? facilityTypeIdFromCode(Facility f, Map<String, int> codeToId) {
    final String code =
        (f.limitDescription ?? f.limitGroup ?? f.limitCode ?? "")
            .toString()
            .trim()
            .toUpperCase();
    if (code.isEmpty) {
      return null;
    }
    return codeToId[code];
  }

  /// Returns whether the facility is LC or LG using reference options.
  bool isLgOrLcByOptions(Facility f, Map<String, int> codeToId) {
    final int? refId = facilityTypeIdFromCode(f, codeToId);
    if (refId == null) {
      return false;
    }
    return ServerConstants.kLcIds.contains(refId) ||
        ServerConstants.kLgIds.contains(refId);
  }

  /// Returns `null` for PASS; otherwise returns the error string.
  ///
  /// Business rules enforced:
  /// - Cash collateral → ALWAYS PASS
  /// - Non-cash + YES (link all):
  ///     • Only LC/LG → PASS
  ///     • Only non-LC/LG → ERROR (All non LC/LG)
  ///     • Mixed LC/LG + non-LC/LG → ERROR (Other than LC/LG)
  /// - Non-cash + NO (link selected):
  ///     • Any non-LC/LG selected → ERROR
  ///     • Only LC/LG selected → PASS
  String? validateLinking({
    required bool linkAllYes,
    required bool isCashCollateral,
    required List<Facility> filteredData,
    required Set<String> selectedCheckboxIds,
    required Map<String, int> codeToId, // <— add this
  }) {
    // --------------------------------------------------
    // Rule 1: Cash collateral → no validation
    // --------------------------------------------------
    if (isCashCollateral) {
      return null;
    }

    if (isFIFlow) {
      return null;
    }

    if (Utils.checkApplicationType(ApplicationType.oneOffLimit)) {
      int lcLgCount = 0;
      int nonLcLgCount = 0;

      // Build lookup: key -> Facility
      final Map<String, Facility> byKey = {
        for (final Facility facility in filteredData)
          _facilitySelectionKey(facility): facility,
      };

      // --------------------------------------------------
      // Classify selected facilities
      // --------------------------------------------------
      for (final String key in selectedCheckboxIds) {
        final Facility? facility = byKey[key];
        if (facility == null) {
          continue;
        }

        final int? limitTypeId = int.tryParse(facility.limitCode.toString());

        final bool isLcLg = limitTypeId != null &&
            (ServerConstants.kLcIds.contains(limitTypeId) ||
                ServerConstants.kLgIds.contains(limitTypeId));

        if (isLcLg) {
          lcLgCount++;
        } else {
          nonLcLgCount++;
        }
      }

      // --------------------------------------------------
      // Rule 2: YES (link all facilities)
      // --------------------------------------------------
      if (linkAllYes) {
        // Only LC / LG
        if (lcLgCount > 0 && nonLcLgCount == 0) {
          return null;
        }

        // Only non LC / LG
        if (nonLcLgCount > 0 && lcLgCount == 0) {
          return kErrNonCashAllNonLcLg;
        }

        // Mixed LC / LG + others
        return kErrNonCashHasAnyNonLcLg;
      }

      // --------------------------------------------------
      // Rule 3: NO (link selected facilities)
      // --------------------------------------------------
      // Any non LC / LG selected → error
      if (nonLcLgCount > 0) {
        return kErrNonCashHasAnyNonLcLg;
      }
    }

    // Only LC / LG selected
    return null;
  }

  /// Call this in Save button onPressed. Returns error or null.
  /// Show alert if error != null; otherwise proceed to save.
  // Close dialog & return selected facility dialog list

  /// Saves selected facilities and closes the dialog.
  Future<void> saveSelectionAndCloseDialog(BuildContext context) async {
    try {
      // Build updated securityItem safely
      // If the user explicitly clicked the radio, use their selection.
      // If they never touched it (selectedAllFailitiesYesNo is null), fall back
      // to the value already persisted on the security item — this prevents the
      // second-open bug where a pre-selected YES is silently overwritten as false.
      final bool allFacilitiesSelectedExplicitly =
          selectedAllFailitiesYesNo != null
              ? (selectedAllFailitiesYesNo!.id == ServerConstants.yesRefId ||
                  selectedAllFailitiesYesNo!.id == ServerConstants.optionYESid)
              : (securityItem?.allFacilities ?? false);

      securityItem
        ?..appRefNo = Globals.request?.applicationRefNo
        ..facilitySecurityLinkId = securityItem?.facilitySecurityLinkId
        ..securityNumber = securityItem?.securityNumber
        ..allFacilities = allFacilitiesSelectedExplicitly
        ..facilityNoList = selectedFacilities
            .where((facility) => facility.limitNumber != null)
            .map((facility) => facility.limitNumber!)
            .toList()
        ..selectedFacilitiesByRim = selectedFacilities
            .where((facility) => facility.limitNumber != null)
            .map(
              (facility) => "${facility.limitNumber!}_${facility.rimNo}",
            )
            .toList();

      if (isFromLinakage) {
        // Build once (cache it) on screen load, not every save:
        final Map<String, int> codeToId = buildCodeToIdMap(facilityTypeOptions);

        final bool isYes =
            (selectedAllFailitiesYesNo?.id == ServerConstants.optionYESid) ||
                (selectedAllFailitiesYesNo?.id == ServerConstants.yesRefId);
        final bool isCash =
            securityItem?.isCashCollateral ?? false; // default true

        final String? error = validateLinking(
          linkAllYes: isYes,
          isCashCollateral: isCash,
          filteredData: filteredData,
          selectedCheckboxIds: selectedIds,
          codeToId: codeToId, // pass the map
        );

        if (error != null) {
          showAlert(error);
          return;
        }

        //logger.i(securityItem?.toSaveFacilityLinkageJson());
        await repository.saveSecurityFacilityLinkage(securityItem);
        AlertManager().showSuccessToast(
          "covenantsConditions.selectFacilityDialog.savedSuccefully".tr(),
        );
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      } else {
        for (final Facility facility in selectedFacilities) {
          final int? id = toIntOrNull(facility.limitCode);
          facility.limitDescription = limitDescriptionReferenceName(
            options: facilityTypeOptions,
            id: id,
          );
        }
        if (context.mounted) {
          if (isFromCovenant) {
            // Return BOTH (Covenant-only)
            Navigator.pop(context, {
              "selectedFacilities": selectedFacilities,
              "allFacilitiesOption": selectedAllFailitiesYesNo,
            });
          } else {
            // Keep old behavior for every other caller
            Navigator.pop(context, selectedFacilities);
          }
        }
      }
    } on Object catch (e) {
      if (e.toString().isNotEmpty) {
        showAlert(e.toString());
      }
    }
  }

  // Reusable method to Validator

  /// Validates radio/dropdown selection against allowed options.
  String? validateSelection(
    String? value,
    List<Reference> options,
    String errorKey,
  ) {
    final trimmedValue = value?.trim();
    final isValid = options.any((ref) => ref.name == trimmedValue);
    return isValid ? null : errorKey.tr();
  }

  // Reusable method to filter out 'NA'

  /// Returns options excluding N/A.
  List<Reference> getFilteredOptions(List<Reference> options) {
    final String naText = "requestInformation.requestInformation.na".tr();
    return options.where((ref) => ref.name != naText).toList();
  }

  // Reusable method

  /// Returns selected reference from selected value or fallback flag.
  Reference getSelectedReference({
    required List<Reference> options,
    required Reference? selectedValue,
    required bool? fallbackFlag,
  }) {
    final List<Reference> filtered = getFilteredOptions(options);

    if (selectedValue != null) {
      final int? selectedId = selectedValue.id;
      if (selectedId != null) {
        final int indexById = filtered.indexWhere((r) => r.id == selectedId);
        if (indexById != -1) {
          return filtered[indexById];
        }
      }
      final String normalizedSelectedName =
          (selectedValue.name ?? "").trim().toLowerCase();
      final int indexByName = filtered.indexWhere(
        (r) => (r.name ?? "").trim().toLowerCase() == normalizedSelectedName,
      );
      if (indexByName != -1) {
        return filtered[indexByName];
      }
    }

    // If no filtered options, fallback to NO
    if (filtered.isEmpty) {
      return Reference(name: "requestInformation.requestInformation.no".tr());
    }

    // Fallback based on flag
    final String fallbackName = (fallbackFlag ?? false)
        ? "requestInformation.requestInformation.yes".tr()
        : "requestInformation.requestInformation.no".tr();

    final Reference fallb = filtered.firstWhere(
      (ref) => ref.name == fallbackName,
      orElse: Reference.new,
    );

    /// Set clearSelected: false as it does not clears the [selectedIds]
    /// to have the selected checkboxes if `No` option is fetch initially
    updateFacilityLinkageOption(fallb, clearSelected: false);

    // Return matching or first
    return fallb;
  }

  // Reusable method

  /// Returns limit description reference name.
  String limitDescriptionReferenceName({
    required List<Reference> options,
    List<Reference>? refs,
    int? id,
  }) {
    // Case 1: List<Reference> -> names
    if (refs != null) {
      if (refs.isEmpty) {
        return "--";
      }
      return refs
          .map(
            (ref) =>
                options
                    .firstWhere(
                      (e) => e.id == ref.id,
                      orElse: () =>
                          Reference(id: 0, name: "--", reference4: "--"),
                    )
                    .name ??
                "--",
          )
          .join(", ");
    }
    // Case 2: Single id -> name
    if (id != null) {
      return options
              .firstWhere(
                (e) => e.id == id,
                orElse: () => Reference(id: 0, name: "--"),
              )
              .name ??
          "--";
    }
    // Fallback
    return "--";
  }

  void _emitRefresh() {
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Shows failure alert and resets loading state.
  void showAlert(String errorMessage) {
    AlertManager().showFailureToast(errorMessage);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Navigates to the facility details screen for the selected limit number.
  void onPressedLimitNo({required Facility facilityItem}) {
    router.go(
      Routes.createFacility,
      extra: {
        "facilityArgs": CreateFacilityArgs(
          facilityId: facilityItem.facilityId,
          facility: Facility(
            facilityDescription: facilityItem.facilityDescription,
            limitDescription: facilityItem.facilityDescription?.name,
            facilityId: facilityItem.facilityId,
            rimNo: facilityItem.rimNo,
            limitCode: facilityItem.limitCode,
            selectedProductTypeValue: facilityItem.selectedProductTypeValue,
            limitGroup: facilityItem.limitGroup,
            isMainLimit: facilityItem.isMainLimit,
          ),
          showCreateFacilityForm: false,
        ),
      },
    );
  }
}
