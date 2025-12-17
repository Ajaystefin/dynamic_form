import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/request/profitability/account_stat.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'package:wcas_frontend/repositories/profitability_repository.dart';

import 'state.dart';

class AccountConductViewModel extends Cubit<AccountConductState> {
  AccountConductViewModel()
      : super(AccountConductState(loaderStatus: LoadingStatus.loading));
  late ProfitabilityRepository repository;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  BuildContext? context;
  Request? request;
  List<AccountStatType> accountStat = [];
  bool isFIApplication = false;

  /// Initializes the `AccountConductViewModel`.
  ///
  /// This asynchronous method performs the following steps:
  /// 1. Logs the initialization process for debugging purposes.
  /// 2. Retrieves an instance of `ProfitabilityRepository`.
  /// 3. Fetches account conduct data from the repository and stores it in `accountStat`.
  /// 4. Calls `getTopSectionDetails()` to populate additional UI-related data.
  /// 5. Emits a new state with `LoadingStatus.loaded` to indicate that the data
  ///    has been successfully loaded and is ready for use.
  ///
  /// This method is typically called during the ViewModel's setup phase
  /// to prepare all necessary data for rendering the account conduct screen.
  Future<void> init(context) async {
    logger.i('initialising AccountConductViewModel');
    repository = ProfitabilityRepository.instance;
    accountStat = await repository.getAccountConductData();
    request = Globals.request;
    // isFIApplication =
    //     Utils.checkBusinessSegment(BusinessSegment.financialInstitution);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Saves the account conduct data to the backend.
  ///
  /// This asynchronous method performs the following steps:
  /// 1. Validates the form using `formKey.currentState!.validate()`.
  ///    - If the form is valid, it proceeds to save the form state.
  /// 2. Sends the `accountStat` data to the backend using the repository's
  ///    `postAccountConductData` method.
  /// 3. Displays a success toast with the result message upon successful submission.
  /// 4. If an error occurs during the process:
  ///    - Displays a failure toast with the error message.
  ///    - Emits an error state to reflect the failure in the UI.
  ///
  /// Parameters:
  /// - `ifNavigate` (optional): A flag indicating whether navigation should occur
  ///   after saving. Currently unused in the method body but can be used for future logic.
  ///
  /// This method ensures that only validated data is submitted and provides
  /// appropriate user feedback for both success and failure scenarios.
  Future<void> saveAccConductData({bool ifNavigate = false}) async {
    try {
      if (formKey.currentState!.validate()) {
        formKey.currentState?.save();

        String? result = await repository.postAccountConductData(accountStat);
        AlertManager().showSuccessToast(
          result.toString(),
        );
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
