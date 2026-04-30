import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/in_pipeline_dialog/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/information/customer_request_info.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class InPipelineDialogViewModel extends SafeCubit<InPipelineDialogState> {
  InPipelineDialogViewModel()
      : super(InPipelineDialogState(loaderStatus: LoadingStatus.loading));
  late RequestRepository repository;
  List<Response> customerRequestInfo = [];
  List<Response> pipelineRequestDetails = [];
  Map<String, List<Reference>> referenceData = {};
  List<Reference> applicationType = [];

  Future<void> init(context) async {
    logger.i("initialising InPipelineDialogViewModel");
    repository = RequestRepository.instance;
    // await getCustomerRequestInfo();
    await getReferenceDatas();
    await getPipelineRequestDetails();
  }

  Future<void> getReferenceDatas() async {
    try {
      referenceData = await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.applicationType,
      ]);
      applicationType = referenceData[ReferenceDataKeys.applicationType] ?? [];
    } catch (e) {
      logger.e("Error getting reference data types: $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  Future<void> getCustomerRequestInfo() async {
    try {
      customerRequestInfo = (await repository.getCustomerRequestInfo()) ?? [];
      emit(
        state.copyWith(
          loaderStatus: customerRequestInfo.isNotEmpty
              ? LoadingStatus.loaded
              : LoadingStatus.error,
        ),
      );
    } catch (e) {
      logger.e("Error getting reference data types: $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  Future<void> getPipelineRequestDetails() async {
    try {
      pipelineRequestDetails =
          (await repository.getPipelineRequestDetails()) ?? [];
      emit(
        state.copyWith(
          loaderStatus: pipelineRequestDetails.isNotEmpty
              ? LoadingStatus.loaded
              : LoadingStatus.error,
        ),
      );
    } catch (e) {
      logger.e("Error getting reference data types: $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }
}
