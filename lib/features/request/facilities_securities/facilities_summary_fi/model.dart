// import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
// import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
// import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/security_summary_dialogbox.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary_list.dart';
import 'package:wcas_frontend/repositories/facility_security_repository.dart';

import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

/// to fetch, save, and delete facility data, and emits state changes
/// to update the UI accordingly.
class FacilitiesSummaryFiViewModel extends Cubit<FacilitiesSummaryFiState> {
  FacilitiesSummaryFiViewModel()
      : super(FacilitiesSummaryFiState(loaderStatus: LoadingStatus.loading));

  /// Repository instance used for fetching and saving data.
  RequestRepository repository = RequestRepository();
  FacilitySecurityRepository facilitySecurityRepository =
      FacilitySecurityRepository();
  ReferenceDataService referenceDataService = ReferenceDataService();

  /// List of customer facilities retrieved from the backend.
  List<FacilitySummaryList>? customerFacilities = [];

  /// List of available currency codes.
  List<Reference> currencyCodes = [];

  /// List of facility limit types.
  List<Reference> limitTypes = [];

  /// List of sub-limit types.
  List<Reference> subLimitTypes = [];

  List<Reference> facilityTypeOptions = [
    Reference(name: "Conventional"),
    Reference(name: "Islamic")
  ]; // not added in refernce data. will update from API
  Reference? selectedFacilityOption;

  /// Initializes the ViewModel by setting up the repository and fetching
  /// currency codes, facility summaries, and reference data.

  Future<void> init(context) async {
    logger.i('initialising FacilitiesSummaryViewModel');
    await Future.wait([
      getCurrencyCodes(),
      getFacilitySummaryList(),
      getReferenceData(),
    ]);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Fetches the list of customer facilities from the FacilitySecurityRepository.

  Future<void> getFacilitySummaryList() async {
    try {
      customerFacilities =
          await facilitySecurityRepository.getFacilitySummaryList();
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
        ReferenceDataKeys.advanceType,
      ]);
      limitTypes = referenceData[ReferenceDataKeys.facilityTypes] ?? [];
      subLimitTypes = referenceData[ReferenceDataKeys.advanceType] ?? [];
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

  Future<void> deleteFacilityDetails({int? serialNumber, int? typeID}) async {
    emit(state.copyWith(tableLoaderStatus: LoadingStatus.loading));
    try {
      await facilitySecurityRepository.deleteFacilityDetails(
          facilityId: serialNumber!);
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

  void changeFacilityTypeOptions(Reference selectedvalue) {
    selectedFacilityOption = selectedvalue;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void openLinkedFacilityDialog(BuildContext context) {
    // DialogHelper.showCustomDialog(
    //   barrierDismissible: false,
    //   title: "facilities.facilitySummary.linkedFacility".tr(),
    //   content: SecuritySummaryTable(
    //     customerFacilities?.first.generalWorkingCapitalLimits,
    //   ),
    //   context: context,
    // );
  }
}
