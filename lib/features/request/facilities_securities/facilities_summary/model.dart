import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary_list.dart';
import 'package:wcas_frontend/models/request/facility_security/project_list.dart';
import 'package:wcas_frontend/repositories/facility_security_repository.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

/// to fetch, save, and delete facility data, and emits state changes
/// to update the UI accordingly.
class FacilitiesSummaryViewModel extends Cubit<FacilitiesSummaryState> {
  FacilitiesSummaryViewModel()
      : super(FacilitiesSummaryState(loaderStatus: LoadingStatus.loading));

  /// Repository instance used for fetching and saving data.
  RequestRepository repository = RequestRepository();
  ReferenceDataService referenceDataService = ReferenceDataService();
  FacilitySecurityRepository facilitySecurityRepository =
      FacilitySecurityRepository();

  /// List of customer facilities retrieved from the backend.
  List<FacilitySummaryList>? customerFacilities;
  Reference? selectedLimitDetails;
  Reference? selectedSubLimitDetails;
  List<Reference> projectNames = [];
  Reference? selectedProjectRef;

  Timer? _tooltipDebounceTimer;

  /// List of available currency codes.
  List<Reference> countryCodes = [];
  List<Reference> currencyCodes = [];
  List<Reference> spreadCommisions = [
    Reference(name: "+"),
    Reference(name: "-")
  ];
  List<Reference> tenorDays = [
    Reference(name: "Days"),
    Reference(name: "Months")
  ];
  Facility facility = Facility();

  final Map<String, String> _convertedTooltipByRow = {};

  /// List of sub-limit types.
  List<Reference> subLimitTypes = [];
  List<Reference> facilityDescriptions = [];
  List<Reference> facilityTypes = [];
  List<Reference> benchmark = [];
  List<Reference> marginSign = [];
  List<Reference> limitGroup = [];
  List<Reference> limitCapsType = [];

// not added in refernce data. will update from API
  List<Reference> productTypeOptions = [];
  Reference? selectedProductTypeOption;
  List<Reference> sustanabilityClassifications = [];
  List<Reference> period = [];

  /// Initializes the ViewModel by setting up the repository and fetching
  /// currency codes, facility summaries, and reference data.
  Future<void> init(context) async {
    logger.i('initialising FacilitiesSummaryViewModel');
    await getFacilitySummaryList();
    await Future.wait(
        [getCurrencyCodes(), getReferenceData(), getProjectList()]);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Fetches the list of customer facilities from the FacilitySecurityRepository.
  Future<void> getFacilitySummaryList() async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      customerFacilities =
          await facilitySecurityRepository.getFacilitySummaryList();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  //save data inside facility summary list table
  Future<void> saveFacilitySummaryList(FacilitySummaryList list) async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));

      final edited = _collectEditedFacilities(list);
      if (edited.isEmpty) {
        AlertManager().showWarningToast("No changes to save");
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }

      await facilitySecurityRepository.saveFacilitySummaryListEdited(edited);
      AlertManager().showSuccessToast('Saved successfully');

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Retrieves project details from the `ProjectRepository` and extracts
  /// project names from the contract list.
  Future<void> getProjectList() async {
    try {
      ProjectListResponse list =
          await facilitySecurityRepository.getProjectList(null);
      projectNames =
          list.responseData.map((name) => Reference(name: name)).toList();
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

// Helper to build a stable key for a row (use what’s available/unique)
  String _rowKey(FacilitySummaryNew f) =>
      '${f.facilityId ?? ''}-${f.limitNo ?? ''}-}'; //${f.order ?? ''

//Public getter for the message (safe default)
  String tooltipMessageFor(FacilitySummaryNew f) {
    final String code = (f.currency ?? '').trim().toUpperCase();
    return _convertedTooltipByRow[_rowKey(f)] ??
        ' Initial amount: ${(f.proposedLimit ?? 0).toInt()} $code';
  }

// fetch rate and compute tooltip text for this row
  Future<void> updateConvertedTooltipFor(FacilitySummaryNew f) async {
    _tooltipDebounceTimer?.cancel();
    _tooltipDebounceTimer = Timer(const Duration(milliseconds: 350), () async {
      try {
        final String code = (f.currency ?? '').trim().toUpperCase();
        final num amount = (f.proposedLimit ?? 0);
        final formatter = NumberFormat('#,###');
        if (code.isEmpty || code == ServerConstants.aedCurrency) {
          final msg = 'Initial Amount: ${formatter.format(amount)} $code';
          _convertedTooltipByRow[_rowKey(f)] = msg;
          emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

          return;
        }
        final ref = Reference(name: code);
        final currencyRates =
            await facilitySecurityRepository.getCurrencyRates(ref);
        final num rate = currencyRates.rates[code] ?? 0;
        final num converted = amount * rate;

        final msg =
            'AED Amount: ${formatter.format(converted.toInt())}, '
            'Initial Amount: ${formatter.format(amount)} AED';

        _convertedTooltipByRow[_rowKey(f)] = msg;
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      } catch (e) {
        AlertManager().showFailureToast(e.toString());
      }
    });
  }

// Called by FacilityProjectName.onSelected
  void onProjectNameSelected(List<Reference> selected) {
    if (selected.isNotEmpty) {
      selectedProjectRef = selected.first;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

// Apply the selected project to the facility row and refresh UI
  void applySelectedProjectTo(FacilitySummaryNew facility) {
    if (selectedProjectRef != null) {
      facility.projectName = selectedProjectRef!
          .name; // store as String for Text("${f.projectName}")
      facility.isEdited = true; // so save will pick it up
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  List<FacilitySummaryNew> _collectEditedFacilities(FacilitySummaryList list) {
    final edited = <FacilitySummaryNew>[];
    final rims = list.rims ?? const <RimSummary>[];

    for (final rim in rims) {
      final groups = rim.groups ?? const <RimGroup>[];
      for (final grp in groups) {
        final disList = grp.facilityLimits ?? const <FacilityDis>[];
        for (final dis in disList) {
          final f = dis.facility;
          if (f?.isEdited == true) {
            edited.add(f!);
          }
        }
      }
    }
    return edited;
  }

  /// Fetches the list of customer facilities from the FacilitySecurityRepository.
  Future<void> getCurrencyRates(Reference? selectedCurrency) async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      await facilitySecurityRepository.getCurrencyRates(selectedCurrency);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  /// Retrieves reference data for facility types and advance types.
  /// Populates the `limitTypes` and `subLimitTypes` lists.
  Future<void> getReferenceData() async {
    try {
      Map<String, List<Reference>> referenceData =
          await referenceDataService.getReferenceData([
        ReferenceDataKeys.facilityTypes,
        ReferenceDataKeys.productType,
        ReferenceDataKeys.sustanabilityClassification,
        ReferenceDataKeys.period,
        ReferenceDataKeys.marginSign,
        ReferenceDataKeys.benchMark,
        ReferenceDataKeys.limitGroup,
      ]);
      limitCapsType = referenceData[ReferenceDataKeys.limitCapsType] ?? [];
      limitGroup = referenceData[ReferenceDataKeys.limitGroup] ?? [];
      facilityTypes = referenceData[ReferenceDataKeys.facilityTypes] ?? [];
      benchmark = referenceData[ReferenceDataKeys.benchMark] ?? [];
      marginSign = referenceData[ReferenceDataKeys.marginSign] ?? [];
      sustanabilityClassifications =
          referenceData[ReferenceDataKeys.sustanabilityClassification] ?? [];
      period = referenceData[ReferenceDataKeys.period] ?? [];
      productTypeOptions =
          (referenceData[ReferenceDataKeys.productType] ?? [Reference()])
              .where((data) => data.id != ServerConstants.optionBothId)
              .toList();
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  /// Fetches the list of currency codes from the repository.

  Future<void> getCurrencyCodes() async {
    try {
      currencyCodes = await repository.getCurrencyCodes();
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Saves the details of a given customer facility.
  Future<void> saveFacilityDetails(CustomerFacility customerFacility) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    try {
      await facilitySecurityRepository.saveFacilityDetails(customerFacility);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    LayoutViewModel().goToNextRoute();
  }

  /// Deletes facility details based on the provided serial number and type ID.
  /// Emits loading and loaded states for the table loader.
  Future<void> deleteFacilityDetails({int? serialNumber}) async {
    emit(state.copyWith(tableLoaderStatus: LoadingStatus.loading));
    try {
      await facilitySecurityRepository.deleteFacilityDetails(
          facilityId: serialNumber!);
      getFacilitySummaryList();
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(tableLoaderStatus: LoadingStatus.loaded));
  }

  /// Saves the sub-limit details for a given facility and facility group.
  /// Emits loading and loaded states for the table loader.
  Future<void> saveFacilitySubLimit({
    required FacilityGroup? facilityGroup,
    Facility? facility,
  }) async {
    emit(state.copyWith(tableLoaderStatus: LoadingStatus.loading));
    try {
      await facilitySecurityRepository.saveFacilitySubLimit(
        rimNo: facility?.rimNo,
        limitDescriptionID: facilityGroup?.typeId,
        limitCategory: facility?.facilityDetails,
      );
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(tableLoaderStatus: LoadingStatus.loaded));
  }

  void changeProductTypeOptions(Reference selectedValue) {
    bool hasChanged = selectedProductTypeOption?.id != selectedValue.id;
    selectedProductTypeOption = selectedValue;

    if (hasChanged) {
      facility.facilityTypeSelectedValue = null;
      facilityDescriptions.clear();
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void selectLimittedGroup(Reference selectedValue) {
    facility.facilityTypeSelectedValue = selectedValue;
    facilityDescriptions.clear();
    facilityTypes.map((e) {
      if (selectedValue.reference4 == e.reference4) {
        facilityDescriptions.add(e);
      }
    }).toList();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> facilityTypeDescriptionsSelected(Reference selectedValue) async {
    facility.facilityDescription = selectedValue;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void selectSharedLimit(Reference selectedValue) {
    facility.sharedLimit = selectedValue;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void addSelectedSubLimitDetails(Reference selectedValue) {
    selectedSubLimitDetails = selectedValue;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

// Put these helpers at the top of the build row scope (or in a utils file)
  Reference matchOrFirstByName(List<Reference> list, String? name) {
    if (list.isEmpty) return Reference(); // won't be used—just a guard
    if ((name ?? '').isEmpty) return list.first;
    final lower = name!.trim().toLowerCase();
    return list.firstWhere(
      (r) => (r.name ?? '').trim().toLowerCase() == lower,
      orElse: () => list.first,
    );
  }

  Reference matchOrFirstById(List<Reference> list, dynamic id) {
    if (list.isEmpty) return Reference();
    if (id == null) return list.first;
    final target = id.toString();
    return list.firstWhere(
      (r) => r.id?.toString() == target,
      orElse: () => list.first,
    );
  }

  Reference matchOrFirstByRef1(List<Reference> list, String? ref1) {
    if (list.isEmpty) return Reference();
    if ((ref1 ?? '').isEmpty) return list.first;
    final lower = ref1!.trim().toLowerCase();
    return list.firstWhere(
      (r) => (r.reference1 ?? '').trim().toLowerCase() == lower,
      orElse: () => list.first,
    );
  }

// Change the return type to int? and use int.tryParse
  int? extractRimId(String? rimName) {
    if (rimName == null) return null;
    final parenMatches = RegExp(r'\(\s*(\d+)\s*\)').allMatches(rimName);
    if (parenMatches.isNotEmpty) {
      final digits = parenMatches.last.group(1);
      return int.tryParse(digits ?? '');
    }
    final firstNumber = RegExp(r'\d+').firstMatch(rimName)?.group(0);
    return int.tryParse(firstNumber ?? '');
  }
}
