import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/ccsys/customer_information.dart';
import 'package:wcas_frontend/models/request/country.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

class CustomerInformationViewModel extends Cubit<CustomerInformationState> {
  CustomerInformationViewModel()
      : super(CustomerInformationState(loaderStatus: LoadingStatus.loading));
  RequestRepository repository = RequestRepository();

  List<Customer>? customers = [];
  List<Country>? countries = [];
  List<Reference>? status = [];
  Customer? customer;
  Request request = Request();
  CcsysCustomerInformation customerInformation = CcsysCustomerInformation();
  bool isBorrowingSubsidiary = false;
  bool isLegalEntityIdentifier = false;
  List<Reference> applicationTypes = [];

  List<Reference> radioButtonItems = [
    Reference(id: 0, name: "No"),
    Reference(id: 1, name: "Yes"),
  ];

  List<Reference> genders = [
    Reference(id: 0, name: "Male"),
    Reference(id: 1, name: "Female"),
  ];

  List<Reference> legalStatusPartners = [
    Reference(id: 0, name: "JP - Juridical", reference1: "JP"),
    Reference(id: 1, name: "NP - Non-Person", reference1: "NP"),
  ];

  List<Reference> residencyStatus = [
    Reference(id: 0, name: "RE - Resident", reference1: "RE"),
    Reference(id: 1, name: "NR - Non-resident", reference1: "NR"),
  ];

  List<Reference> shareholderTypes = [
    Reference(id: 0, name: "PR1"),
    Reference(id: 1, name: "SH2"),
    Reference(id: 1, name: "JA3"),
  ];

  Reference defaultField = Reference(id: 0, name: "NA");

  void onLegalStatusPartnerSelected(Reference legalStatusPartners) {
    customerInformation.legalStatusPartners = legalStatusPartners;
    emit(state.copyWith(customerSelectedStatus: LoadingStatus.loaded));
  }

  // is Legal status == NP and Residency status == RE
  bool isLegalNpAndResidencyRE() {
    bool isLegalStatusNP =
        customerInformation.legalStatusPartners == legalStatusPartners[1];
    bool isResidencyStatusRE =
        customerInformation.residencyStatus == residencyStatus[1];
    if (isLegalStatusNP && isResidencyStatusRE) {
      return true;
    } else {
      return false;
    }
  }

  void onChangeBorrowingSubsidiary(Reference? selectedOption) {
    selectedOption == radioButtonItems[0]
        ? isBorrowingSubsidiary = false
        : isBorrowingSubsidiary = true;
    customerInformation.radioButtonItems = selectedOption;
    emit(state.copyWith(customerSelectedStatus: LoadingStatus.loaded));
  }

  void setEmiratesId(String? emiratesIdPartner) {
    customerInformation.emiratesIdPartner = emiratesIdPartner;
    emit(state.copyWith(customerSelectedStatus: LoadingStatus.loaded));
  }

  void onChangeisLegalEntityIdentifier(Reference legalEntityIdentifier) {
    legalEntityIdentifier == radioButtonItems[0]
        ? isLegalEntityIdentifier = false
        : isLegalEntityIdentifier = true;
    customerInformation.legalEntityIdentifier = legalEntityIdentifier;
    emit(state.copyWith(customerSelectedStatus: LoadingStatus.loaded));
  }

  List<Reference> countryCodes = [];
  void init(context) async {
    logger.i('initialising CustomerInformationViewModel');
    request = Globals.request ?? Request();
    getCustomerList();
    applicationTypes = [Reference(name: "CCSYS")];

    await Future.wait([getReferenceData(), getCurrencyCodes()]);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Assign [customers] from [Globals]
  void getCustomerList() {
    customers = Globals.request?.customers;
    emit(state.copyWith(customerSelectedStatus: LoadingStatus.loaded));
  }

  /// Handles the selection of a customer and triggers related data loading.
  ///
  /// This asynchronous function performs the following steps:
  /// 1. Introduces a short delay (500ms) to simulate a loading effect.
  /// 2. Emits a loading state to indicate that data fetching is in progress.
  /// 3. Sets the selected customer to the local `customer` variable.
  /// 4. Concurrently fetches reference data and currency codes using `Future.wait`.
  /// 5. Catches and displays any errors using `AlertManager`.
  /// 6. Emits a loaded state once all operations are complete.
  ///
  /// Parameters:
  /// - [selectedCustomer]: The customer object selected by the user.
  Future<void> customerNameSelected(Customer selectedCustomer) async {
    try {
      emit(state.copyWith(customerSelectedStatus: LoadingStatus.loading));
      customer = selectedCustomer;
    } catch (e) {
      // AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(customerSelectedStatus: LoadingStatus.loaded));
  }

  /// Fetches reference data related to CCC status and updates the local `status` variable.
  ///
  /// This asynchronous function performs the following:
  /// - Calls `ReferenceDataService().getReferenceData()` with the `cccStatus` key.
  /// - Retrieves a map of reference data categorized by keys.
  /// - Extracts the list of references associated with `cccStatus`.
  /// - Updates the local `status` variable with the retrieved list, or an empty list if none is found.
  Future<void> getReferenceData() async {
    Map<String, List<Reference>> referenceData =
        await ReferenceDataService().getReferenceData([
      ReferenceDataKeys.cccStatus,
    ]);
    status = referenceData[ReferenceDataKeys.cccStatus] ?? [];
  }

  /// Retrieves currency codes from the repository and updates the local `countryCodes` variable.
  ///
  /// This asynchronous function performs the following:
  /// - Calls `repository.getCurrencyCodes()` to fetch a list of currency codes.
  /// - Assigns the result to the `countryCodes` variable.
  /// - If an error occurs during the fetch, it displays a failure toast using `AlertManager`.
  Future<void> getCurrencyCodes() async {
    try {
      countryCodes = await repository.getCurrencyCodes();
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  void onPressedSave(BuildContext context) {
    if (customer != null) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      customer = null;
    }
  }

  /// Initiates the process to save customer information and manages loading state.
  ///
  /// This function performs the following:
  /// - Emits a loading state to indicate the start of the save operation.
  /// - Catches and displays any errors using `AlertManager`.
  /// - Emits a loaded state after the operation completes, regardless of success or failure.
  void saveCustomerInformation() {
    //integrate mockAPI
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    // LayoutViewModel().goToNextRoute();
    router.go(Routes.ccsysApproval);

    try {} catch (e) {
      // AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}
