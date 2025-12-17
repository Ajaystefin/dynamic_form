import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/information/customer_request_info.dart';

import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

class InPipelineDialogViewModel extends Cubit<InPipelineDialogState> {
  InPipelineDialogViewModel()
      : super(InPipelineDialogState(loaderStatus: LoadingStatus.loading));
  late RequestRepository repository;
  List<Response> customerRequestInfo = [];
  List<Response> pipelineRequestDetails = [];

  Future<void> init(context) async {
    logger.i('initialising InPipelineDialogViewModel');
    repository = RequestRepository.instance;
    // await getCustomerRequestInfo();
    await getPipelineRequestDetails();
  }

  Future<void> getCustomerRequestInfo() async {
    try {
      customerRequestInfo = (await repository.getCustomerRequestInfo()) ?? [];
      emit(state.copyWith(
        loaderStatus: customerRequestInfo.isNotEmpty
            ? LoadingStatus.loaded
            : LoadingStatus.error,
      ));
    } catch (e) {
      logger.e('Error getting reference data types: $e');
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  Future<void> getPipelineRequestDetails() async {
    try {
      pipelineRequestDetails = (await repository.getPipelineRequestDetails()) ?? [];
      emit(state.copyWith(
        loaderStatus: pipelineRequestDetails.isNotEmpty
            ? LoadingStatus.loaded
            : LoadingStatus.error,
      ));
    } catch (e) {
      logger.e('Error getting reference data types: $e');
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }
}
