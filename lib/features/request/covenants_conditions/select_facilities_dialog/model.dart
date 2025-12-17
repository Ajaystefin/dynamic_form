import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';
import 'package:wcas_frontend/models/request/facility_security/security.dart';
import 'package:wcas_frontend/repositories/facility_security_repository.dart';
import 'state.dart';

enum Filter { rimNo, limitNumber, limitLabel, limitDescription }

class SelectFacilitiesDialogViewModel
    extends Cubit<SelectFacilitiesDialogState> {
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
  final int rowsPerPage = 5;

  // Selection model
  List<bool> checkboxes = [];
  bool isSelectAll = false;
  bool isFromSecuritySummary = false;

  // Filters
  List<Facility> filteredData = [];
  String? rimFilterCtrl;
  String? limitNumFilterCtrl;
  String? projFilterCtrl;
  String? descFilterCtrl;

  // Reference data
  List<Reference> yesNoNaOptions = [];
  Security? securityItem = Security();

  Reference? selectedAllFailitiesYesNo;

  //Initialize and load data
  Future<void> init(
    context, [
    List<Facility> selectedFacility = const [],
    bool isSecuritySummary = false,
    Security? securityItemindex,
  ]) async {
    logger.i('initialising SelectFacilitiesDialogViewModel');

    isFromSecuritySummary = isSecuritySummary;
    if (isFromSecuritySummary) {
      showCheckboxColumn = false;
    }
    securityItem = securityItemindex ?? Security();

    if (selectedFacility.isNotEmpty) {
      selectedFacilities = List<Facility>.from(selectedFacility);
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      await fetchYesNoNaReferenceData();

      facilities = await repository.getLinkageFacility();

      if (isFromSecuritySummary) {
        filteredData = facilities;
      } else {
        // Pre-filter to facilities linked to securityItem (if any)
        final List<String?> linkedLimitNumbers =
            securityItem?.facilityNoList ?? <String?>[];
        filteredData = facilities
            .where(
              (facility) => linkedLimitNumbers.contains(facility.limitNumber),
            )
            .toList();
        // Initialize checkbox model to match filteredData length (if needed by UI)
        checkboxes =
            List<bool>.filled(filteredData.length, false, growable: true);

        // Sync select-all state
        isSelectAll = filteredData.isNotEmpty &&
            selectedFacilities.length == filteredData.length;
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e, st) {
      logger.e('Failed to init SelectFacilitiesDialogViewModel',
          error: e, stackTrace: st);
      if (e.toString().isNotEmpty) {
        AlertManager().showFailureToast(e.toString());
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  Future<void> fetchYesNoNaReferenceData() async {
    try {
      final Map<String, List<Reference>> referenceData =
          await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.yesNoNa,
      ]);

      yesNoNaOptions = referenceData[ReferenceDataKeys.yesNoNa] ?? [];
    } catch (e) {
      // Preserve original behavior (rethrow), but log for visibility
      logger.e('fetchYesNoNaReferenceData error: $e');
      rethrow;
    }
  }

  /// Filters the list of facilities based on the provided [filter] and [value].
  /// After filtering, it updates the corresponding filtering control value and emits
  /// an updated state.
  void onFilter(Filter filter, {required String value}) {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    final String normalized = value.trim();

    filteredData = facilities.where((data) {
      switch (filter) {
        case Filter.rimNo:
          // Handles numeric and string safely; converts to string, case-insensitive
          final rim = (data.rimNo ?? '').toString();
          return rim.toUpperCase().contains(normalized.toUpperCase());

        case Filter.limitNumber:
          final limit = (data.limitNumber ?? '').toString();
          return limit.toUpperCase().contains(normalized.toUpperCase());

        case Filter.limitLabel:
          final label = (data.limitLabel ?? '');
          return label.toLowerCase().contains(normalized.toLowerCase());

        case Filter.limitDescription:
          final desc = (data.limitDescription ?? '');
          return desc.toLowerCase().contains(normalized.toLowerCase());
      }
    }).toList();

    // Update filter control values
    switch (filter) {
      case Filter.rimNo:
        rimFilterCtrl = value;
        break;
      case Filter.limitNumber:
        limitNumFilterCtrl = value;
        break;
      case Filter.limitLabel:
        projFilterCtrl = value;
        break;
      case Filter.limitDescription:
        descFilterCtrl = value;
        break;
    }
    if (!isFromSecuritySummary) {
      // Rebuild checkbox model to match filtered results
      checkboxes =
          List<bool>.filled(filteredData.length, false, growable: true);

      // Recalculate select-all state relative to filtered rows
      isSelectAll = filteredData.isNotEmpty &&
          selectedFacilities.length == filteredData.length;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

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
      // logger.i(securityItem?.toSaveFacilityLinkageJson());
      await repository.saveSecurityFacilityLinkage(securityItem);

      AlertManager().showSuccessToast(
          "covenantsConditions.selectFacilityDialog.savedSuccefully".tr());
      if (context.mounted) {
        Navigator.pop(context, selectedFacilities);
      }
    } catch (e) {
      //logger.e('saveSelectionAndCloseDialog error', error: e, stackTrace: st);
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Toggles the 'select all' state and updates all checkbox values accordingly.
  /// This method emits the new state so the UI rebuilds automatically.
  void toggleSelectAll(bool? selectedValue) {
    final bool newValue = selectedValue ?? false;
    isSelectAll = newValue;

    // Reset and apply select-all only to currently visible (filtered) rows
    selectedFacilities.clear();
    if (newValue) {
      selectedFacilities.addAll(filteredData);
      // Optionally reflect in checkbox model if used by the UI layer
      checkboxes = List<bool>.filled(filteredData.length, true, growable: true);
    } else {
      checkboxes =
          List<bool>.filled(filteredData.length, false, growable: true);
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the checkbox value for the facility at a given [index].
  /// Uses [emit] with a loaded state to trigger a rebuild of the UI.
  void updateCheckboxAtIndex(int index, bool newValue) {
    if (index < 0 || index >= filteredData.length) {
      logger.w('updateCheckboxAtIndex out of bounds: $index');
      return;
    }

    final facility = filteredData[index];

    // Update selection model
    if (newValue) {
      if (!selectedFacilities
          .any((f) => f.limitNumber == facility.limitNumber)) {
        selectedFacilities.add(facility);
      }
    } else {
      selectedFacilities
          .removeWhere((f) => f.limitNumber == facility.limitNumber);
    }

    // Reflect change in checkbox array (if used by UI)
    if (index < checkboxes.length) {
      checkboxes[index] = newValue;
    }

    // Update select-all checkbox state relative to filtered rows
    isSelectAll = filteredData.isNotEmpty &&
        selectedFacilities.length == filteredData.length;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateFacilityLinkageOption(Reference? selectedOption) {
    selectedAllFailitiesYesNo = selectedOption;

    // Hide checkbox column if YES is selected; keep hidden for Security Summary
    final bool isYes = (selectedOption?.id == ServerConstants.optionYESid) ||
        (selectedOption?.id == ServerConstants.yesRefId);

    showCheckboxColumn = !isYes;
    if (isFromSecuritySummary) {
      showCheckboxColumn = false;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  bool getCheckBoxValue(Facility? facilityData) {
    if (facilityData == null) return false;
    final String? key = facilityData.limitNumber;
    return selectedFacilities.any((facility) => facility.limitNumber == key);
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
    final String naText = 'requestInformation.requestInformation.na'.tr();
    return options.where((ref) => ref.name != naText).toList();
  }

  Reference getSelectedReference({
    required List<Reference> options,
    required Reference? selectedValue,
    required bool? fallbackFlag,
  }) {
    final filtered = getFilteredOptions(options);

    // If selectedValue is present within filtered, return it directly
    if (selectedValue != null &&
        filtered.any((ref) => ref.name == selectedValue.name)) {
      return selectedValue;
    }

    // If no filtered options, fallback to NO
    if (filtered.isEmpty) {
      return Reference(name: 'requestInformation.requestInformation.no'.tr());
    }

    // Fallback based on flag
    final fallbackName = (fallbackFlag == true)
        ? 'requestInformation.requestInformation.yes'.tr()
        : 'requestInformation.requestInformation.no'.tr();

    // Return matching or first
    return filtered.firstWhere(
      (ref) => ref.name == fallbackName,
      orElse: () => filtered.first,
    );
  }
}


// for save 
//  "responseData": {
//         "securityNo": "PGT1314",
//         "appRefNo": "202511APNIS027385",
//         "facilityNoList": [
//             "LCM0006"
//         ],
//         "facilitySecurityLinkId": 19839,
//         "allFacilitiesPresent": false
//     }

  // "appRefNo": "201902APNAR000052",
  //       "facilityNoList": ["GLB0004","GLB0005"],
  //       "allFacilitiesPresent": true,
  //       "securityNo": "PGT0003",
  //       "facilitySecurityLinkId": 74