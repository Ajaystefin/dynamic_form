import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/state.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/group_information/cbrb_data.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/group_information_repository.dart";

class AddCbrbDialogViewModel extends SafeCubit<AddCbrbDialogState> {
  AddCbrbDialogViewModel()
      : super(AddCbrbDialogState(loaderStatus: LoadingStatus.loading));

  late GroupInformationRepository repository;
  late CustomerRepository customerRepository;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  ApplicationDetails? applicationDetails;

  List<CBRB>? cbrbCollection = [];
  CBRB currentCbrbItems = CBRB();

  Customer? selectedCustomer = Customer(customerRimNo: null, customerName: "");
  List<Customer> customers = [];

  bool isFiFlow = false;
  CBRB? initialCbrbs;
  Future<void> init(
    context, {
    CBRB? initialCbrb,
  }) async {
    logger.i("initialising AddOtherBankDialogViewModel");
    repository = GroupInformationRepository.instance;
    customerRepository = CustomerRepository.instance;
    isFiFlow = Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

    await getApplicationDetails();

    if (initialCbrb != null) {
      initialCbrbs = initialCbrb;
      currentCbrbItems = initialCbrb;
      selectedCustomer = Customer(
        customerRimNo: initialCbrb.rimNo,
        customerName: initialCbrb.customerName,
      );

      emit(
        state.copyWith(
          customerName:
              selectedCustomer?.customerName ?? selectedCustomer?.displayName,
        ),
      );
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> getApplicationDetails() async {
    try {
      applicationDetails = await CustomerRepository.instance
          .getApplicationDetails(appRefNo: null);

      customers = [
        ...?applicationDetails?.borrowers,
        ...?applicationDetails?.nonBorrowers,
      ];
    } catch (e) {
      AlertManager().showFailureToast("common.noAppRef".tr());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Sets the selected customer RIM reference.
  ///
  /// This function updates the internal state with the selected [Customer]
  /// object
  void customerRIMReferenceSelected(Customer customer) {
    selectedCustomer = customer;
    emit(
      state.copyWith(
        customerName: selectedCustomer?.concatCustomerFullName ??
            selectedCustomer?.displayRIMName ??
            "",
      ),
    );
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles the cancel action by closing the current dialog or screen.
  ///
  /// This function simply pops the current context from the navigation stack,
  /// effectively closing the dialog or returning to the previous screen.

  Future<void> onCancelButtonPressedCBRB(BuildContext context) async {
    context.pop();
  }

  /// Handles the save action when the user presses the "Save" button in the
  /// form.
  ///
  /// This asynchronous function performs the following steps:
  /// 1. Validates the form using [formKey].
  /// 2. If valid, saves the form state and emits a loading status.
  /// 3. Depending on whether a new entry is being added (`inDex == -1`) or an
  /// existing
  ///    one is being updated, it populates the [facilities] list accordingly.
  /// 4. Converts the [facilities] list to a JSON-compatible format.
  /// 5. Sends the data to the backend using
  /// [repository.saveFacilitiesWithOtherBank].
  /// 6. Logs the result and closes the dialog.
  /// 7. Emits a loaded or error status based on the outcome.

  Future<void> onSaveButtonPressedCBRB(BuildContext context) async {
    try {
      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();
        emit(state.copyWith(loaderStatus: LoadingStatus.loading));

        final updatedData = currentCbrbItems
          ..rimNo = selectedCustomer?.customerRimNo
          ..customerName = (initialCbrbs != null)
              ? selectedCustomer?.customerName ??
                  selectedCustomer?.displayRIMName ??
                  ""
              : selectedCustomer?.concatCustomerFullName ??
                  selectedCustomer?.displayRIMName ??
                  "";

        cbrbCollection ??= [];

        updatedData
          ..news = true
          ..deleted = false;

        cbrbCollection!.add(updatedData);

        final jsonData = cbrbCollection!.map((e) => e.toJson()).toList();

        final result = await repository.saveCBRBData(jsonData);
        AlertManager().showSuccessToast(result.toString());
        logger
          ..i("onSaveButtonPressed: $result")
          ..i("onSaveButtonPresseda: $jsonData");

        router.pop();
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      logger.e("Error in onSaveButtonPressed: $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }
}
