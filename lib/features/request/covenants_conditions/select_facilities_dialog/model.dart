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

enum Filter { rimNo, limitNumber, limitLabel, limitDescription }

class SelectFacilitiesDialogViewModel
    extends SafeCubit<SelectFacilitiesDialogState> {
  SelectFacilitiesDialogViewModel()
      : super(SelectFacilitiesDialogState(loaderStatus: LoadingStatus.loading));

  // Repositories & Services
  final FacilitySecurityRepository repository = FacilitySecurityRepository();

  // UI flags
  bool showCheckboxColumn = true;

  // Data
  List<Facility> facilities = [];
  List<Facility> selectedFacilities = [];

  // Paging
  int page = 0;
  int rowsPerPage = 7;

  // Selection model
  List<bool> checkboxes = [];
  bool isSelectAll = false;
  bool isFromSecuritySummary = false;
  bool isFromLinakage = false;

  // Filters
  List<Facility> filteredData = [];

  String? rimFilterCtrl;
  String? limitNumFilterCtrl;
  String? projFilterCtrl;
  String? descFilterCtrl;

  // Reference data
  List<Reference> yesNoNaOptions = [];
  Security? securityItem = Security();
  List<Reference> facilityTypeOptions = [];
  Reference? selectedAllFailitiesYesNo;
  bool isFromCovenant = false;

  // // Helpers & model assumptions (adjust to your context)
  // String _normalize(Object? value) =>
  //     value?.toString().trim().toUpperCase() ?? '';

  /// Normalizes any value used in selection keys and comparisons.
  ///
  /// - Converts to `String`
  /// - Trims whitespace
  /// - Uppercases (case-insensitive comparisons)
  String _normalizeValue(Object? value) {
    return value?.toString().trim().toUpperCase() ?? "";
  }

  /// Extracts a consistent key from a Facility for use in [selectedIds].
  ///
  /// The [getLinkageFacility] API returns [limitNumber] in a compound format:
  ///   "rimNo|limitNo|limitCode"  (e.g. "1023563|ODA0002|16")
  ///
  /// The backend's [facilityNoList] (returned after save) stores only the
  /// plain limitNo (e.g. "ODA0002"). Extracting index [1] when pipes are
  /// present makes both sides produce the same key, fixing pre-selection.
  ///
  /// For facilities where [limitNumber] is already a plain string (no pipe),
  /// it is returned as-is after normalization.
  // String _facilityKey(Facility facility) {
  //   final String raw = _normalize(facility.facilitySummaryId);
  //   if (raw.contains('|')) {
  //     final List<String> parts = raw.split('|');
  //     // Compound format: rimNo | limitNo | limitCode — extract limitNo (index 1)
  //     return parts.length >= 2 ? parts[1] : raw;
  //   }
  //   return raw;
  // }

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
    final int? facilitySummaryId = facility.facilitySummaryId;
    if (facilitySummaryId != null && facilitySummaryId > 0) {
      return "FACILITY_SUMMARY_ID:$facilitySummaryId";
    }

    final String normalizedLimitNumber = _normalizeValue(facility.limitNumber);
    if (normalizedLimitNumber.isEmpty) return "";

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
  String kErrNonCashAllNonLcLg =
      "covenantsConditions.selectFacilityDialog.facilities_non_cash".tr();
  //'Facilities cannot be linked with non-cash collateral security';
  String kErrNonCashHasAnyNonLcLg =
      "covenantsConditions.selectFacilityDialog.facilities_non_cash_other_than"
          .tr();
  //'Facilities other than LC/LG cannot be linked with non-cash collateral security';

  PageMode pageMode = PageMode.na;
  bool get canEdit => pageMode == PageMode.edit;
  bool get isFIFlow =>
      Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

  /// Initializes the Select Facilities dialog for different entry points.
  ///
  /// Entry points supported:
  /// - Security Summary (read-only selection UI)
  /// - Facilities–Securities Linkage (editable selection + validations)
  /// - Covenants flow (returns selected facilities + allFacilities option)
  ///
  /// The grid fields are aligned to the linkage UI: **RIM No**, **Limit No**,
  /// **Limit Description**, etc.
  Future<void> init(
    context, [
    List<Facility> selectedFacility = const [],
    bool isSecuritySummary = false,
    Security? securityItemindex,
    bool isLinakage = false,
    overridePageMode,
    preselectedAllFacilities,
    bool isCovenant = false,
  ]) async {
    logger.i("initialising SelectFacilitiesDialogViewModel");
    pageMode = overridePageMode ??
        AuthRepository.getPageMode(RightConstants.facilitySecurityLinkage);

    isFromSecuritySummary = isSecuritySummary;
    isFromLinakage = isLinakage;
    isFromCovenant = isCovenant;
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
    if (isFromLinakage && (securityItem?.allFacilities == true)) {
      showCheckboxColumn = false;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      await fetchYesNoNaReferenceData();
      facilities = await repository.getLinkageFacility();

      if (isFromSecuritySummary) {
        // Summary mode: show everything and emit once.
        // sets filteredData = facilities, rebuilds mirrors, emits
        showAllFacilities();
        return; // optional: stop here; summary mode is complete
      } else {
        // --- Non-summary mode ---
        // 1) Always show all facilities initially (Always Filter with except
        // 935 limit caps).
        if (facilities.isNotEmpty) {
          filteredData = facilities
              .where(
                (f) => f.limitCode != ServerConstants.facilityLinkageLimitCaps,
              )
              .toList();
        }

        if (securityItem?.facilityNoList != null &&
            (securityItem?.facilityNoList ?? []).isNotEmpty) {
          _seedSelectionFromFacilityNoList(
            securityItem?.facilityNoList ?? const <String>[],
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
    } catch (e, st) {
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
  void _seedSelectionFromFacilityNoList(List<String?> facilityNoList) {
    if (facilityNoList.isEmpty) return;

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

      if (plainLimitNo.isEmpty) continue;

      limitNoToSelectionKeys.putIfAbsent(plainLimitNo, () => <String>[]);
      limitNoToSelectionKeys[plainLimitNo]!
          .add(_facilitySelectionKey(facility));
    }

    for (final String? rawSavedValue in facilityNoList) {
      final String normalizedSavedValue = _normalizeValue(rawSavedValue);
      if (normalizedSavedValue.isEmpty) continue;

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
    // (Always Filter with except 935 limit caps)
    if (facilities.isNotEmpty) {
      filteredData = facilities
          .where((f) => f.limitCode != ServerConstants.facilityLinkageLimitCaps)
          .toList();
    }
    // 2) Rebuild mirrors (checkboxes, select-all, selectedFacilities)
    _rebuildCheckboxesFromSelection();
    _recalcSelectAll();
    _rebuildSelectedFacilities();
    // 3) Emit so Bloc/Flutter rebuild the UI
    _emitRefresh(); // keep using your standard emitter
  }

  Future<void> fetchYesNoNaReferenceData() async {
    try {
      final String facilityTypeKey = isFIFlow
          ? ReferenceDataKeys.fiFacilityTypes
          : ReferenceDataKeys.facilityTypes;

      final Map<String, List<Reference>> referenceData =
          await ReferenceDataService()
              .getReferenceData([ReferenceDataKeys.yesNoNa, facilityTypeKey]);

      yesNoNaOptions = referenceData[ReferenceDataKeys.yesNoNa] ?? [];
      facilityTypeOptions = referenceData[facilityTypeKey] ?? [];
    } catch (e) {
      // Preserve original behavior (rethrow), but log for visibility
      logger.e("fetchYesNoNaReferenceData error: $e");
      rethrow;
    }
  }

  int? toIntOrNull(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

// Normalizer used only when caseInsensitive=true
  String norm(String? value) => (value ?? "").toLowerCase().trim();

  // --- Filtering ---

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
                  keyword.isEmpty ? true : candidate.contains(keyword);

              if (id == -1 || candidateRaw == "--") {
                return desc.contains(keyword);
              }

              return typeOk; // candidate.contains(keyword); // desc.contains(normalizedInput.toLowerCase());
            }
        }
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
    } catch (e, st) {
      // Optional: emit failure state if you have one
      // emit(state.copyWith(loaderStatus: LoadingStatus.error));
      debugPrint("onFilter error: $e\n$st");
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

// --- Radio button YES/NO for "link all facilities?" ---
  void updateFacilityLinkageOption(Reference? selectedOption) {
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
      } else {
        selectedIds.clear(); //  mandatory
      }
      _rebuildCheckboxesFromSelection();
      _recalcSelectAll();
      _rebuildSelectedFacilities();

      emit(
        state.copyWith(loaderStatus: LoadingStatus.loaded),
      ); // keep your emit
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

// --- Select All toggle ---
  void toggleSelectAll(bool? selectedValue) {
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
  void updateCheckboxAtIndex(int index, bool newValue) {
    if (index < 0 || index >= filteredData.length) return;

    final String key = _facilitySelectionKey(filteredData[index]);
    if (key.isEmpty) return;

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
      (i) => selectedIds.contains(_facilitySelectionKey(filteredData[i])),
      growable: false, // fixed-size to match visible rows
    );
  }

  // === ID-only LC/LG detector (uses limitDescriptionId or limitDescription or limitCode) ===
  // bool _isLcLgById(Facility f) {
  //   final int? refId = int.tryParse(f.limitCode.toString());
  //   // field names from your model
  //   if (refId == null) return false;
  //   return ServerConstants.kLcIds.contains(refId) ||
  // ServerConstants.kLgIds.contains(refId);
  // }

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
    if (code.isEmpty) return null;
    return codeToId[code];
  }

  bool isLgOrLcByOptions(Facility f, Map<String, int> codeToId) {
    final int? refId = facilityTypeIdFromCode(f, codeToId);
    if (refId == null) return false;
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
    if (isCashCollateral) return null;

    if (isFIFlow) return null;

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
        if (facility == null) continue;

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
  Future<void> saveSelectionAndCloseDialog(BuildContext context) async {
    try {
      // Build updated securityItem safely
      final bool allFacilitiesSelectedExplicitly =
          (selectedAllFailitiesYesNo?.id == ServerConstants.yesRefId) ||
              (selectedAllFailitiesYesNo?.id == ServerConstants.optionYESid);

      securityItem
        ?..appRefNo = Globals.request?.applicationRefNo
        ..facilitySecurityLinkId = securityItem?.facilitySecurityLinkId
        ..securityNumber = securityItem?.securityNumber
        ..allFacilities = allFacilitiesSelectedExplicitly
        ..facilityNoList = selectedFacilities
            .where((facility) => facility.limitNumber != null)
            .map((facility) => facility.limitNumber!)
            .toList();

      if (isFromLinakage) {
        // Build once (cache it) on screen load, not every save:
        final Map<String, int> codeToId = buildCodeToIdMap(facilityTypeOptions);

        final bool isYes =
            (selectedAllFailitiesYesNo?.id == ServerConstants.optionYESid) ||
                (selectedAllFailitiesYesNo?.id == ServerConstants.yesRefId);
        final bool isCash =
            (securityItem?.isCashCollateral == true); // default true

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
    } catch (e) {
      if (e.toString().isNotEmpty) {
        showAlert(e.toString());
      }
    }
  }

  // Reusable method to Validator
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
  List<Reference> getFilteredOptions(List<Reference> options) {
    final String naText = "requestInformation.requestInformation.na".tr();
    return options.where((ref) => ref.name != naText).toList();
  }

  // Reusable method
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
        if (indexById != -1) return filtered[indexById];
      }
      final String normalizedSelectedName =
          (selectedValue.name ?? "").trim().toLowerCase();
      final int indexByName = filtered.indexWhere(
        (r) => (r.name ?? "").trim().toLowerCase() == normalizedSelectedName,
      );
      if (indexByName != -1) return filtered[indexByName];
    }

    // If no filtered options, fallback to NO
    if (filtered.isEmpty) {
      return Reference(name: "requestInformation.requestInformation.no".tr());
    }

    // Fallback based on flag
    final String fallbackName = (fallbackFlag == true)
        ? "requestInformation.requestInformation.yes".tr()
        : "requestInformation.requestInformation.no".tr();

    // Return matching or first
    return filtered.firstWhere(
      (ref) => ref.name == fallbackName,
      orElse: () => filtered.first,
    );
  }

  // Reusable method
  String limitDescriptionReferenceName({
    required List<Reference> options,
    List<Reference>? refs,
    int? id,
  }) {
    // Case 1: List<Reference> -> names
    if (refs != null) {
      if (refs.isEmpty) return "--";
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

  void showAlert(String errorMessage) {
    AlertManager().showFailureToast(errorMessage);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onPressedLimitNo({required Facility facilityItem}) {
    router.go(
      Routes.createFacility,
      extra: CreateFacilityArgs(
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
    );
  }
}
