import "package:flutter/widgets.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/in_pipeline_dialog/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/information/customer_request_info.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/dashboard_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// View model responsible for managing the In-Pipeline dialog.
///
/// Handles loading pipeline request data, retrieving reference data,
/// and providing the information required to display customer
/// pipeline requests within the dialog.
class InPipelineDialogViewModel extends SafeCubit<InPipelineDialogState> {
  /// Creates an [InPipelineDialogViewModel] with an initial
  /// loading state.
  InPipelineDialogViewModel()
      : super(
          const InPipelineDialogState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

  /// Repository used to retrieve request and pipeline-related data.
  late RequestRepository repository;

  /// Repository used for dashboard related API calls.
  DashboardRepository repositoryDashboard = DashboardRepository();

  /// Customer request records retrieved for the selected customer.
  List<Response> customerRequestInfo = [];

  /// Pipeline request details displayed in the dialog.
  List<Response> pipelineRequestDetails = [];

  /// Reference data grouped by reference type.
  Map<String, List<Reference>> referenceData = {};

  /// Available application types retrieved from reference data.
  List<Reference> applicationType = [];

  /// Available request types retrieved from reference data.
  List<Reference> requestTypeItems = [];

  /// Filtered application types used within the In-Pipeline workflow.
  List<Reference> customApplicationType = [];

  /// Initializes the In-Pipeline dialog.
  ///
  /// Sets up the required repository, loads reference data,
  /// and retrieves the pipeline request details required
  /// to populate the dialog.
  Future<void> init(BuildContext context) async {
    logger.i("initialising InPipelineDialogViewModel");
    repository = RequestRepository.instance;
    // await getCustomerRequestInfo();
    await getReferenceDatas();
    await getPipelineRequestDetails();
  }

  /// Retrieves the reference data required by the In-Pipeline dialog.
  ///
  /// Loads application type references and custom application type
  /// references used for displaying and filtering pipeline requests.
  Future<void> getReferenceDatas() async {
    try {
      referenceData = await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.applicationType,
        ReferenceDataKeys.customApplicationType,
      ]);
      customApplicationType =
          referenceData[ReferenceDataKeys.customApplicationType] ?? [];
      applicationType = referenceData[ReferenceDataKeys.applicationType] ?? [];
      requestTypeItems = referenceData[ReferenceDataKeys.requestType] ?? [];
    } on Object catch (e) {
      logger.e("Error getting reference data types: $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Retrieves customer request information associated with
  /// the current customer context.
  ///
  /// Updates the screen state to loaded when request data is
  /// available; otherwise sets the state to error.
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
    } on Object catch (e) {
      logger.e("Error getting reference data types: $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Retrieves pipeline request details for display in the dialog.
  ///
  /// Updates the screen state to loaded when pipeline data is
  /// available; otherwise sets the state to error.
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
    } on Object catch (e) {
      logger.e("Error getting reference data types: $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Opens an existing application from the worklist and populates the
  /// global request context with the corresponding request details.
  ///
  /// The method:
  /// - Marks the request as an existing application.
  /// - Sets the application reference number.
  /// - Resolves and assigns the request type and subtype.
  /// - Updates the application type based on the configured mappings.
  /// - Opens the application through the dashboard repository.
  /// - Updates the loader status during the operation.
  ///
  /// If the request type or subtype is unavailable, the application type
  /// is cleared and the operation exits.
  ///
  /// Any errors encountered during the process are displayed as a
  /// failure toast notification.
  Future<void> openApplication(
    BuildContext? context,
    Response info,
    Request request,
  ) async {
    try {
      final Request? globalRequest = Globals.request;

      globalRequest?.isCreateRequest = false;
      globalRequest?.applicationRefNo = info.applicationRefNo;

      final String? requestType = info.requestType;
      final String? subType = info.subType;

      if (requestType == null || subType == null) {
        globalRequest?.applicationType = null;
        return;
      }

      globalRequest?.requestType = requestTypeItems.firstWhere(
        (item) => item.reference1 == requestType,
        orElse: () => Reference(
          name: "",
          reference1: requestType,
          reference2: "",
          reference3: "",
          reference4: "",
        ),
      );

      final Reference applicationRequestType = getApplicationRequestType(
        requestType,
        subType,
      );

      globalRequest?.requestSubType = applicationRequestType;
      globalRequest?.applicationType = applicationRequestType;

      emit(state.copyWith(loaderStatus: LoadingStatus.loading));

      await repositoryDashboard.openApplication(
        request,
        isPipeline: true,
        context: context,
      );

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  Reference getApplicationRequestType(
    String requestType,
    String subType,
  ) {
    return customApplicationType.firstWhere(
      (item) => item.reference3 == requestType && item.reference1 == subType,
      orElse: () => applicationType.firstWhere(
        (item) => item.reference4 == requestType && item.reference1 == subType,
        orElse: () => Reference(
          name: "",
          reference1: subType,
          reference2: "",
          reference3: requestType,
          reference4: requestType,
        ),
      ),
    );
  }
}
