import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/request.dart';

import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

class RequestInformationViewModel extends Cubit<RequestInformationState> {
  RequestInformationViewModel()
      : super(RequestInformationState(loaderStatus: LoadingStatus.loading));
  late RequestRepository repository;
  late Request request;
  List<Reference> applicationTypes = [];

  void init(context) async {
    repository = RequestRepository.instance;
    await getCustomerInformation();
    applicationTypes = [Reference(name: "CCSYS")];

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Sets the selected application type in the request object.
  ///
  /// This function assigns the provided [applicationType] to the
  /// `applicationType` field of the `request` object.
  ///
  /// Parameters:
  /// - [applicationType]: A `Reference` object representing the selected application type.
  void onSelectApplicationType(Reference? applicationType) {
    request.applicationType = applicationType;
  }

  /// Handles the save button press event and executes save-related logic.
  ///
  /// This asynchronous function is intended to perform operations when the user
  /// presses the save button.
  Future<void> onSavePressed() async {
    try {
      router.go(Routes.ccsysCustomerInformation);
      // LayoutViewModel().goToNextRoute();
    } catch (e) {
      // AlertManager().showFailureToast(e.toString());
    }
  }

  /// Initializes the customer request object
  ///
  /// This asynchronous function performs the following:
  /// - Instantiates a new `Request` object and assigns it to the `request` variable.
  /// - If an error occurs during initialization, it emits an error state using `loaderStatus.error`.
  Future<void> getCustomerInformation() async {
    try {
      request = Request();
    } catch (e) {
      // emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }
}
