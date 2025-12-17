import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/request/profitability/relationship_utilization.dart';
import 'package:wcas_frontend/models/request/request.dart';

import 'package:wcas_frontend/repositories/profitability_repository.dart';
import 'state.dart';

class RelationshipUtilizationViewModel
    extends Cubit<RelationshipUtilizationState> {
  RelationshipUtilizationViewModel()
      : super(
            RelationshipUtilizationState(loaderStatus: LoadingStatus.loading));
  late ProfitabilityRepository repository;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  BuildContext? context;
  Request? request;
  List<RelationshipUtilization> relationshipUtilizationData = [];
  bool isFIApplication = false;

  //paging
  final int rowsPerPage = 5;

  /// Initializes the `RelationshipUtilizationViewModel`.
  ///
  /// This method performs the following:
  /// - Logs the initialization process.
  /// - Retrieves an instance of `ProfitabilityRepository`.
  /// - Fetches relationship utilization data asynchronously from the repository.
  /// - Initializes a `Request` object using global user and request data.
  ///
  /// Parameters:
  /// - [context]: The BuildContext in which this method is called.
  Future<void> init(context) async {
    logger.i('initialising RelationshipUtilizationViewModel');
    repository = ProfitabilityRepository.instance;
    request = Globals.request;
    relationshipUtilizationData =
        await repository.getRelationshipUtilizationData();
    isFIApplication =
        Utils.checkBusinessSegment(BusinessSegment.financialInstitution);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Calculates the throughput to CBD/CUA percentage for a specific relationship.
  ///
  /// This method performs the following:
  /// 1. Validates that `clientTurnOver` is not less than `turnoverInCbdCua`.
  ///    - If invalid, sets the percentage to 0 and shows a validation error toast.
  /// 2. If valid, calculates the percentage as:
  ///    `(turnoverInCbdCua / clientTurnOver) * 100`
  ///    and updates the corresponding entry in `relationshipUtilizationData`.
  /// 3. Emits a new state with `LoadingStatus.loaded` to reflect the update.
  ///
  /// Parameters:
  /// - `clientTurnOver`: The total turnover of the client.
  /// - `turnoverInCbdCua`: The turnover attributed to CBD/CUA.
  /// - `index`: The index of the data entry to update in `relationshipUtilizationData`.
  ///
  /// This method ensures that the calculated percentage is only applied when
  /// the input values are logically valid, and provides user feedback otherwise.
  void calculatePercentage(
      {required double clientTurnOver, required int index}) {
    double turnoverInCbdCua =
        (relationshipUtilizationData[index].turnoverInCbdCua ?? 0);
    if (clientTurnOver < turnoverInCbdCua) {
      relationshipUtilizationData[index].throughputToCbdPercentage = 0;
      AlertManager().showFailureToast(
          "profitabilityAccountConduct.relationshipUtilisation.turnOverValidationMsg"
              .tr());
    } else {
      relationshipUtilizationData[index].throughputToCbdPercentage =
          (turnoverInCbdCua / clientTurnOver) * 100;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Saves the relationship utilization data to the backend.
  ///
  /// This asynchronous method performs the following steps:
  /// 1. Validates the form using `formKey.currentState!.validate()`.
  ///    - If the form is valid, it proceeds to save the form state.
  /// 2. Sends the `relationshipUtilizationData` to the backend via the repository's
  ///    `postRelationshipUtilizationData` method.
  /// 3. Displays a success toast with the result message upon successful submission.
  /// 4. If an error occurs during the process:
  ///    - Displays a failure toast with the error message.
  ///    - Emits an error state to update the UI accordingly.
  ///
  /// This method ensures that only valid data is submitted and provides user feedback
  /// for both success and failure scenarios.

  Future<void> saveRelationUtilData(
      {required bool isValidate, bool ifNavigate = false}) async {
    try {
      if (isValidate) {
        formKey.currentState?.save();

        String result = await repository
            .postRelationshipUtilizationData(relationshipUtilizationData);
        AlertManager().showSuccessToast(result);
        if (ifNavigate) {
          LayoutViewModel().goToNextRoute();
        }
      }
    } catch (e) {
      AlertManager().showFailureToast(
        e.toString(),
      );
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }
}
