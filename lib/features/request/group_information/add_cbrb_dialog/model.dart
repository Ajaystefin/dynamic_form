import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/group_information/cbrb_data.dart';
import 'package:wcas_frontend/repositories/group_information_repository.dart';

import 'state.dart';

class AddCbrbDialogViewModel extends Cubit<AddCbrbDialogState> {
  AddCbrbDialogViewModel()
      : super(AddCbrbDialogState(loaderStatus: LoadingStatus.loading));

  late GroupInformationRepository repository;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<CBRB>? cbrbCollection = [];
  CBRB currentCbrbItems = CBRB();

  Customer? selectedCustomer = Customer(customerRimNo: null, customerName: '');
  List<Customer> customers =
      //Globals.request?.customers ?? [] TODO remove this after API integration/
      [
    Customer(customerName: 'RIM NO 99910', customerRimNo: 99910),
    Customer(customerName: 'RIM NO 2213', customerRimNo: 2213),
    Customer(customerName: 'RIM NO 1037489', customerRimNo: 1037489),
    Customer(customerName: 'RIM NO 5656', customerRimNo: 5656),
    Customer(customerName: 'RIM NO 1462843', customerRimNo: 1462843),
    Customer(customerName: 'RIM NO 12237', customerRimNo: 12237),
    Customer(customerName: 'RIM NO 1023563', customerRimNo: 1023563),
    Customer(customerName: 'RIM NO 1128470', customerRimNo: 1128470),
    Customer(customerName: 'RIM NO 5260', customerRimNo: 5260),
    Customer(customerName: 'RIM NO 4815', customerRimNo: 4815),
    Customer(customerName: 'RIM NO 898379', customerRimNo: 898379),
    Customer(customerName: 'RIM NO 6798', customerRimNo: 6798),
    Customer(customerName: 'RIM NO 93954', customerRimNo: 93954),
    Customer(customerName: 'RIM NO 2194743', customerRimNo: 2194743),
    Customer(customerName: 'RIM NO 1258734', customerRimNo: 1258734)
  ];

  bool showCurrentFiCreditRisk = false;

  void init(
    context, {
    CBRB? initialCbrb,
  }) async {
    logger.i('initialising AddOtherBankDialogViewModel');
    repository = GroupInformationRepository.instance;
// for checkup with request type creditRisk
    showCurrentFiCreditRisk =
        Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

    if (initialCbrb != null) {
      currentCbrbItems = initialCbrb;
      selectedCustomer = Customer(
          customerRimNo: initialCbrb.rimNo,
          customerName: initialCbrb.customerName);

      emit(state.copyWith(
          customerName: selectedCustomer?.customerName.toString()));
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Sets the selected customer RIM reference.
  ///
  /// This function updates the internal state with the selected [Customer]
  /// object
  void customerRIMReferenceSelected(Customer customer) {
    selectedCustomer = customer;
    emit(state.copyWith(
        customerName: selectedCustomer?.customerName.toString()));
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles the cancel action by closing the current dialog or screen.
  ///
  /// This function simply pops the current context from the navigation stack,
  /// effectively closing the dialog or returning to the previous screen.

  Future<void> onCancelButtonPressedCBRB(BuildContext context) async {
    context.pop();
  }

  /// Handles the save action when the user presses the "Save" button in the form.
  ///
  /// This asynchronous function performs the following steps:
  /// 1. Validates the form using [formKey].
  /// 2. If valid, saves the form state and emits a loading status.
  /// 3. Depending on whether a new entry is being added (`inDex == -1`) or an existing
  ///    one is being updated, it populates the [facilities] list accordingly.
  /// 4. Converts the [facilities] list to a JSON-compatible format.
  /// 5. Sends the data to the backend using [repository.saveFacilitiesWithOtherBank].
  /// 6. Logs the result and closes the dialog.
  /// 7. Emits a loaded or error status based on the outcome.

  Future<void> onSaveButtonPressedCBRB(BuildContext context) async {
    try {
      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();
        emit(state.copyWith(loaderStatus: LoadingStatus.loading));

        final updatedData = currentCbrbItems
          ..rimNo = selectedCustomer?.customerRimNo
          ..customerName = selectedCustomer?.customerName;

        cbrbCollection ??= [];

        updatedData
          ..news = true
          ..deleted = false;

        cbrbCollection!.add(updatedData);

        final jsonData = cbrbCollection!.map((e) => e.toJson()).toList();

        final result = await repository.saveFacilitiesWithOtherBank(jsonData);
        logger.i('onSaveButtonPressed: $result');
        logger.i('onSaveButtonPresseda: $jsonData');

        router.pop();
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      logger.e('Error in onSaveButtonPressed: $e');
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }
}
