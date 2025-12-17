import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/models/request/profitability/income_summary.dart';
import 'package:wcas_frontend/repositories/profitability_repository.dart';
import 'state.dart';

class IncomeSummaryViewModel extends Cubit<IncomeSummaryState> {
  IncomeSummaryViewModel()
      : super(IncomeSummaryState(loaderStatus: LoadingStatus.loading));
  late ProfitabilityRepository repository;

  // Local variable to store the list of ShareOfWallet records.
  List<IncomeSummary>? incomeSummaryList;

  // Add a form key for validating the RM comments field.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Field to store RM Comments.
  String? rmComments;

  // Comments
  List<Comment> comments = [];
  IncomeComment? comment;

  void init(context) async {
    logger.i('initialising IncomeSummaryViewModel');
    repository = ProfitabilityRepository.instance;
    await getIncomeSummary();
  }

  /// Fetches income summary data from the repository and updates the state.
  ///
  /// Emits a loaded state on success or an error state on failure

  Future<void> getIncomeSummary() async {
    try {
      IncomeSummaryResponseData result = await repository.getIncomeSummary();
      incomeSummaryList = result.incomeSummaryDataList;
      comment = result.comment;
      rmComments = comment?.comment; // Pre-fill RM comments field
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  Future<void> saveIncomeSummaryData(
      BuildContext context, bool navigateNext) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    try {
      // Save form fields (updates rmComments)
      formKey.currentState?.save();

      String responseMessage = await repository.saveIncomeSummary(
        incomeSummaryList!,
        rmComments,
      );

      AlertManager().showSuccessToast(responseMessage);

      if (context.mounted && navigateNext) {
        LayoutViewModel().goToNextRoute();
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Validates and saves RM comments, then navigates to the next screen.
  ///
  /// Shows a success toast on successful save or an error toast on failure.
  /// Navigates to the income Summary screen if the context is still mounted

  /// Validates and saves RM comments, then navigates to the next screen.
  ///
  /// Shows a success toast on successful save or an error toast on failure.
  /// Navigates to the income Summary screen if the context is still mounted
}
