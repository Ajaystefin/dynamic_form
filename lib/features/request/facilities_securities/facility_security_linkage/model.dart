import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/facility_security/security.dart';

import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

/// This view model handles data fetching, filtering, and state updates
/// for the facility-security linkage screen.
class FacilitySecurityLinkageViewModel
    extends Cubit<FacilitySecurityLinkageState> {
  FacilitySecurityLinkageViewModel()
      : super(
            FacilitySecurityLinkageState(loaderStatus: LoadingStatus.loading));
  late RequestRepository repository;
  List<Security> originalSecurities = [];
  List<Security> securities = [];
  List<Reference> securityTypeOptions = [];

  /// Initializes the view model by setting up the repository and
  /// fetching the security summary list using the application reference number.
  void init(context) async {
    logger.i('initialising FacilitySecurityLinkageViewModel');
    repository = RequestRepository.instance;
    await getSecuritySummaryList();
    await getReferenceData();
  }

  Future<void> getReferenceData() async {
    try {
      final Map<String, List<Reference>> referenceData =
          await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.securityType,
        ReferenceDataKeys.facilityTypes,
      ]);

      securityTypeOptions = referenceData[ReferenceDataKeys.securityType] ?? [];
    } catch (e) {
      rethrow;
    }
  }

//appReffNo - 202502APNIS027140
  /// Fetches the list of security summaries for the given [appReffNo].
  ///
  /// Emits a [LoadingStatus.loaded] state on success or
  /// [LoadingStatus.error] on failure.
  Future<void> getSecuritySummaryList() async {
    try {
      securities = await repository.getSecuritySummaryList();
      originalSecurities = List.from(securities);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Filters the [securities] by the given [securityNo].
  ///
  /// Emits a [LoadingStatus.loaded] state after filtering.

  void filterBySecurityNumber(String? securityNo) {
    securities
        .where((item) => item.securityType.toString() == securityNo)
        .toList();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void filterBySecurityType(String? securityCode) {
    securities
        .where((item) => item.securityType?.name == securityCode)
        .toList();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  String? securityNumberFilter, securityTypeFilter;
  Future<void> onFilter(
      {required String value, required FilterType filterType}) async {
    originalSecurities = securities.where((data) {
      bool securityNumber = false;
      bool securityType = false;
      if (filterType == FilterType.securityNumber) {
        securityNumber = (data.securityNumber ?? "").contains(value);
        securityNumberFilter = value;
      } else if (filterType == FilterType.securityType) {
        securityType = (securityTypeOptions
                        .firstWhere(
                          (e) => e.id == data.securityType?.id,
                          orElse: () => Reference(id: 0, name: "--"),
                        ).name ?? "").contains(value);
        securityTypeFilter = value;
      }

      return securityType || securityNumber;
    }).toList();

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

//if a clear btn is needed then use this
// void clearFilters() {
//   securities = List.from(originalSecurities ?? []);
//   emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
// }
}
