import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/request/profitability/strategies_comments.dart';
import 'package:wcas_frontend/repositories/profitability_repository.dart';
import 'state.dart';

class StrategiesAndCommentsViewModel extends Cubit<StrategiesAndCommentsState> {
  StrategiesAndCommentsViewModel()
      : super(StrategiesAndCommentsState(loaderStatus: LoadingStatus.loading));
  late ProfitabilityRepository repository;

  StrategiesComments? strategiesComments;

  Future<void> init(context) async {
    logger.i('initialising StrategiesAndCommentsViewModel');
    repository = ProfitabilityRepository.instance;
    await getStrategiesComments();
  }

  Future<void> getStrategiesComments() async {
    try {
      final result = await repository.getStrategiesAndComments(
          CommentsType.strategyComments, EntityIdentifier.strategyComments);
      strategiesComments = result;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (error) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  Future<void> updateStrategiesComments(
      {String? newRelationshipStrategy,
      String? newDepositStrategy,
      String? newTransactionBankingComments,
      String? newTradeFinanceComments,
      String? newTreasuryComments,
      String? appRefNo,
      bool isContinue = false}) async {
    if (strategiesComments == null) {
      AlertManager().showFailureToast(
          'profitabilityAccountConduct.strategiesComments.failedToUpdateStrategies'
              .tr());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
      return;
    }

    // Prepare updated object
    final updated = strategiesComments!.copyWith(
      relationshipStrategy:
          newRelationshipStrategy ?? strategiesComments!.relationshipStrategy,
      depositStrategy:
          newDepositStrategy ?? strategiesComments!.depositStrategy,
      transactionBankingComments: newTransactionBankingComments ??
          strategiesComments!.transactionBankingComments,
      tradeFinanceComments:
          newTradeFinanceComments ?? strategiesComments!.tradeFinanceComments,
      treasuryComments:
          newTreasuryComments ?? strategiesComments!.treasuryComments,
    );

    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      // Call API
      final success = await repository.updateStrategiesComments(
          CommentsType.strategyComments, updated,
          appRefNo: appRefNo);

      if (success) {
        strategiesComments = updated;
        AlertManager().showSuccessToast(
            'profitabilityAccountConduct.strategiesComments.strategiesUpdatedSuccessfully'
                .tr());
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        if (isContinue) {
          LayoutViewModel().goToNextRoute();
        }
      } else {
        AlertManager().showFailureToast(
            'profitabilityAccountConduct.strategiesComments.failedToUpdateStrategies'
                .tr());
        emit(state.copyWith(loaderStatus: LoadingStatus.error));
      }
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }
}
