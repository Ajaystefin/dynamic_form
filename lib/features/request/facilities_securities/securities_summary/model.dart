import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/request/facility_security/security.dart';
import 'package:wcas_frontend/repositories/facility_security_repository.dart';
import 'state.dart';

enum Filter { securityNumber, securityType }

class SecuritiesSummaryViewModel extends Cubit<SecuritiesSummaryState> {
  SecuritiesSummaryViewModel()
      : super(SecuritiesSummaryState(loaderStatus: LoadingStatus.loading));
  FacilitySecurityRepository repository = FacilitySecurityRepository();

  /// List of security summaries associated with
  List<Security> securities = [];
  List<Security> filteredData = [];
  String? securityNumber;
  String? securityType;

  /// Initializes the view model by setting up the repository and
  /// fetching the security summary list using the application reference number.
  Future<void> init() async {
    logger.i('initialising SecuritiesSummaryViewModel');

    await getSecurities(); // need to update this argument based on dialog box generates from facility summary . remove accepting from global variable
  }

//appReffNo - 202502APNIS027140
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
          return ((data.securityNumber.toString()))
              .contains(value.toUpperCase());
        case Filter.securityType:
          return ((data.securityCode.toString())).contains(value.toUpperCase());
      }
    }).toList();

    // Update filter control values
    switch (filter) {
      case Filter.securityNumber:
        securityNumber = value;
        break;
      case Filter.securityType:
        securityType = value;
        break;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}
