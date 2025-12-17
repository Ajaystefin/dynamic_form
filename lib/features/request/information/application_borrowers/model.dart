import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/request/customer.dart';

import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

class ApplicationBorrowersViewModel extends Cubit<ApplicationBorrowersState> {
  ApplicationBorrowersViewModel()
      : super(ApplicationBorrowersState(loaderStatus: LoadingStatus.loading));

  /// Repository instance used for data operations.
  late RequestRepository repository;

  /// Global key for the form used in the UI.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ///   A list of `Customer` objects representing borrowers fetched from the repository.
  List<Customer> applicationBorrowers = [];

  ///   A list of `Customer` objects representing all customers, including borrowers,
  ///   merged and deduplicated by their RIM number.
  List<Customer> customers = [];
  List<Customer> selectedCustomers = [];

  bool showCurrentFiCreditRisk = false;

  bool get isReadOnly => Globals.request!.isRequestCreated;

  ///   Initializes the ViewModel by setting up the repository, loading customers from
  ///   global request data, and fetching application borrowers. Emits a loaded state
  ///   once initialization is complete.
  void init(context) async {
    logger.i('initialising ApplicationBorrowersViewModel');
    repository = RequestRepository.instance;
    customers = Globals.request?.borrowers ?? [];
    selectedCustomers = Globals.request!.borrowers!.where((Customer customer) {
      return (customer.isSelected ?? false) ||
          (customer.isBorrowerBelowGrade ?? false);
    }).toList();
    // for checkup with request type creditRisk
    showCurrentFiCreditRisk =
        Utils.checkBusinessSegment(BusinessSegment.financialInstitution);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  ///   Placeholder method for handling save button logic. Intended to be implemented
  ///   with logic to persist borrower selections or other form data.
  void onSaveButtonPressed(BuildContext context,
      {required bool navigationOrder}) {
    Globals.request?.customers = selectedCustomers;
    Globals.request?.borrowers = selectedCustomers;
    if (Globals.request?.customers?.isEmpty ?? true) {
      AlertManager().showFailureToast(
          'requestInformation.applicationBorrowers.validationMessage'.tr());
      return;
    }

    if (navigationOrder) {
      if (context.mounted) {
        context.go(Routes.requestInformation);
      }
    } else {
      if (context.mounted) {
        context.go(Routes.groupBorrowers);
      }
    }
  }

  ///   Updates the `isSelected` status of a customer identified by their RIM number.
  ///   Emits a loaded state after updating the selection.
  ///   Updates the `isSelected` status of a customer identified by their RIM number.
  ///   Emits a loaded state after updating the selection.
  void onCustomerRimNameSelected(String rim, bool isSelected) {
    final customer =
        customers.firstWhere((c) => c.customerRimNo.toString() == rim);

    customer.isSelected = isSelected;
    if (isSelected) {
      selectedCustomers.add(customer);
    } else {
      selectedCustomers.remove(customer);
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onBelowGradeSelected(String rim, bool isSelected) {
    final customer =
        customers.firstWhere((c) => c.customerRimNo.toString() == rim);
    customer.isSelectedBelowGrade = isSelected;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}
