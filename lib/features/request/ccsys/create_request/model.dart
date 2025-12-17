import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'package:wcas_frontend/repositories/customer_respository.dart';

import 'state.dart';

enum ControlFields { customerRim, customerName }

class CcsysCreateRequestViewModel extends Cubit<CcsysCreateRequestState> {
  CcsysCreateRequestViewModel()
      : super(CcsysCreateRequestState(loaderStatus: LoadingStatus.loading));
  late CustomerRepository repository;
  late Request requestCreate;
  final FocusNode formFocusNode = FocusNode();

  ValueNotifier<Map<ControlFields, bool>> fieldCntrl = ValueNotifier({
    ControlFields.customerName: false,
    ControlFields.customerRim: false,
  });

  bool showError = true;
  String? customerRimNo;
  String? customerName;

  bool isSearched = false;
  bool isFieldsFilled() => customerRimNo != null && customerName != null;

  ValueNotifier<bool?> selectedButtonModelVN = ValueNotifier(null);
  ValueNotifier<Customer?> selectedCustomer = ValueNotifier(null);

  /// Key for validating the form.

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Loading statuses for different fields.
  LoadingStatus customerRimNoLoadingStatus = LoadingStatus.loaded;
  LoadingStatus customerNameLoadingStatus = LoadingStatus.loaded;

  bool isResetPressed = false;
  List<Customer> customers = [];
  Customer? customer;

  /// Submit button validation logic
  bool submitButtonValidation() => customer == null;

  /// Initializes the `CcsysCreateRequestViewModel`.
  ///
  /// This method performs the following actions:
  /// - Logs the initialization process.
  /// - Retrieves the singleton instance of `CustomerRepository`.
  /// - Initializes a new `Request` object for customer creation.
  /// - Loads the list of customers from the global request context, if available.
  /// - Simulates a delay (2 seconds) to mimic loading or setup time.
  /// - Emits a new state with `LoadingStatus.loaded` to indicate completion.
  ///
  /// This method should be called during the setup phase of the view model,
  /// typically when the associated widget or screen is first built.

  Future<void> init(context) async {
    logger.i('initialising CcsysCreateRequestViewModel');
    repository = CustomerRepository.instance;
    requestCreate = Request();
    customers = Globals.request?.customers ?? [];

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles the control logic for form fields based on user input.
  ///
  /// This method updates the `fieldCntrl` map to reflect which field is currently active,
  /// based on the provided [cntrl] (the field being edited) and the [data] entered by the user.
  ///
  /// - If [data] is not empty, it sets all other fields to `true` (active) except the current one.
  /// - If [data] is empty, it resets all fields to `false`, clears the `customerName` and `customerRimNo`,
  ///   and emits a state update with `LoadingStatus.loaded`.
  ///
  /// This logic is typically used to manage dynamic form validation or UI behavior
  /// depending on which field the user is interacting with.

  void handleFieldControl(ControlFields cntrl, String data) {
    final updatedMap = <ControlFields, bool>{};
    fieldCntrl.value.forEach((key, _) {
      if (data.isNotEmpty) {
        updatedMap[key] = key != cntrl;
      } else {
        updatedMap[key] = false;
      }
    });
    if (data.isEmpty) {
      customerName = null;
      customerRimNo = null;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
    fieldCntrl.value = updatedMap;
  }

  /// Initiates a customer search based on the entered customer name.
  ///
  /// This method checks if the [customerName] is not empty, has not already been searched,
  /// and is longer than 3 characters. If these conditions are met, it sets the
  /// `customerNameLoadingStatus` to `LoadingStatus.loading` and triggers the
  /// `onCustomerSearchPressed` method to perform the search.
  ///
  /// If the conditions are not met, it displays a failure toast prompting the user
  /// to enter a valid customer name.
  ///
  /// [showDialog] determines whether a dialog should be shown during the search process.
  /// Defaults to `true`.

  void onCustomerNameSearchPressed({bool showDialog = true}) {
    if ((customerName ?? "").isNotEmpty &&
        !isSearched &&
        customerName!.length > 3) {
      customerNameLoadingStatus = LoadingStatus.loading;
      onCustomerSearchPressed(showDialog: showDialog, isRim: false);
    } else {
      AlertManager().showFailureToast(
          "requestInformation.createRequest.enterCustomerName".tr());
    }
  }

  /// Performs a customer search using the provided RIM number and customer name.
  ///
  /// This asynchronous method interacts with the `CustomerRepository` to search for
  /// customer details based on the current values of [customerRimNo] and [customerName].
  ///
  /// - Emits a state update with `LoadingStatus.loaded` before initiating the search.
  /// - If a customer is found:
  ///   - Updates the local [customer], [customerRimNo], and [customerName] variables.
  ///   - Sets [isSearched] to `true`.
  ///   - Stops all loading indicators.
  ///   - Emits a final state update with `LoadingStatus.loaded`.
  /// - If an error occurs during the search:
  ///   - Stops all loading indicators.
  ///   - Sets [isSearched] to `false`.
  ///   - Displays a failure toast with a generic error message.
  ///   - Emits a final state update with `LoadingStatus.loaded`.
  ///
  /// [showDialog] determines whether a dialog should be shown during the search process.
  /// Defaults to `true`.

  Future<void> onCustomerSearchPressed(
      {bool showDialog = true, bool isRim = true}) async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

      if (isRim) {
        customer = await repository.searchUserDetails(
            customerRimNo ?? "", customerName ?? "", "", "");
      } else {
        List<Customer?> resultCustomers =
            await repository.searchCustomerProfile(customerName, '', '');

        if (resultCustomers.length == 1) {
          customer = resultCustomers.first;
        }
      }

      if (customer != null) {
        customerRimNo = customer?.id ?? "";
        customerName = customer?.preferredName ?? "";

        isSearched = true;
        stopAllLoaders();
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }
    } catch (e) {
      stopAllLoaders();
      isSearched = false;
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Resets all individual field loading statuses to 'loaded'
  void stopAllLoaders() {
    isSearched = false;
    customerRimNoLoadingStatus = LoadingStatus.loaded;
    customerNameLoadingStatus = LoadingStatus.loaded;

    // final updatedMap = <ControlFields, bool>{};
    // fieldCntrl.value.forEach((key, _) {
    //   updatedMap[key] = true;
    // });
    // fieldCntrl.value = updatedMap;

    fieldCntrl.value.forEach(
      (key, value) {
        value = true;
      },
    );
    isResetPressed = !isResetPressed;
  }

  /// Resets all form fields and state.
  void onResetButtonPress() {
    formKey.currentState?.reset();
    customerRimNo = null;
    customerName = null;
    isSearched = false;
    customer = null;
    stopAllLoaders();
    selectedCustomer.value = null;
    fieldCntrl = ValueNotifier({
      ControlFields.customerName: false,
      ControlFields.customerRim: false,
    });
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles the submission of the customer request form.
  ///
  /// This method performs the following actions:
  /// - Validates the form using [formKey].
  /// - If the form is valid:
  ///   - Emits a loading state.
  ///   - Populates the [requestCreate] object with the entered customer name and RIM number.
  ///   - Stores the request in a global variable [Globals.request].
  ///   - Navigates to the next route using [LayoutViewModel] and [router].
  /// - Emits a final state update with `LoadingStatus.loaded` after processing.
  ///
  /// This method is typically triggered when the user presses the submit button
  /// to proceed with creating a customer request.

  void onSubmitButtonPress({bool mockValidate = false}) {
    if (mockValidate || formKey.currentState!.validate()) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      requestCreate
        ..customerName = customerName
        ..customerRimNo = int.parse(customerRimNo ?? "");

      // Router to next page
      Globals.request = requestCreate;
      // LayoutViewModel().goToNextRoute(extra: requestCreate);
      router.go(Routes.ccsysRequestInformation, extra: requestCreate);
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Initiates search based on customer RIM number if not already searched
  void onCustomerRimNoSearchPressed() {
    if ((customerRimNo ?? "").isNotEmpty && !isSearched) {
      customerRimNoLoadingStatus = LoadingStatus.loading;
      onCustomerSearchPressed(isRim: true);
    }
  }
}
