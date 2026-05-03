import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/securities_summary/state.dart";
import "package:wcas_frontend/models/request/facility_security/security.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";

enum Filter { securityNumber, securityType }

class SecuritiesSummaryViewModel extends SafeCubit<SecuritiesSummaryState> {
  SecuritiesSummaryViewModel()
      : super(SecuritiesSummaryState(loaderStatus: LoadingStatus.loading));
  FacilitySecurityRepository repository = FacilitySecurityRepository();

  /// List of security summaries associated with
  List<Security> securities = [];
  List<Security> filteredData = [];
  String? securityNumber;
  String? securityType;

  PageMode? createSecurityPageMode;

  bool get canEdit =>
      createSecurityPageMode == PageMode.edit; // && Utils.canEditApplication();

  /// Initializes the view model by setting up the repository and
  /// fetching the security summary list using the application reference number.
  Future<void> init({PageMode? pageMode}) async {
    logger.i("initialising SecuritiesSummaryViewModel");

    createSecurityPageMode =
        pageMode ?? AuthRepository.getPageMode(RightConstants.createSecurity);

    // need to update this argument based on dialog box generates from facility
    // summary . remove accepting from global variable
    await getSecurities();
  }

  /// Fetches the list of security summaries for the given [appReffNo].
  ///
  /// Emits a [LoadingStatus.loaded] state on success or
  /// [LoadingStatus.error] on failure.
  Future<void> getSecurities() async {
    try {
      securities = await repository.getSecuritySummaryList();
      filteredData = securities;
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
    securities = securities
        .where((item) => item.securityNumber.toString() == securityNo)
        .toList();
    debugPrint(securities.toString());
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Filters the [securities] by the given [securityCode].
  ///
  /// Emits a [LoadingStatus.loaded] state after filtering.
  void filterBySecurityType(String? securityCode) {
    securities = securities
        .where((item) => item.securityCode.toString() == securityCode)
        .toList();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> deleteSecurityDetails(int? securityId) async {
    emit(state.copyWith(deleteButtonStatus: LoadingStatus.loading));
    try {
      await repository.deleteSecurityDetails(securityId);
      await getSecurities(); // to fetch the list again
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }

    emit(state.copyWith(deleteButtonStatus: LoadingStatus.loaded));
  }

  void onFilter(Filter filter, {required String value}) {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    filteredData = securities.where((data) {
      switch (filter) {
        case Filter.securityNumber:
          return data.securityNumber.toString()
              .contains(value.toUpperCase());
        case Filter.securityType:
          return data.securityCode.toString().contains(value.toUpperCase());
      }
    }).toList();

    // Update filter control values
    switch (filter) {
      case Filter.securityNumber:
        securityNumber = value;
      case Filter.securityType:
        securityType = value;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}
