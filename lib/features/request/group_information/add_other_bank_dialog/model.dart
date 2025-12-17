import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
// import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/group_information/facilities_data.dart';
import 'package:wcas_frontend/repositories/group_information_repository.dart';

import 'state.dart';

class AddOtherBankDialogViewModel extends Cubit<AddOtherBankDialogState> {
  AddOtherBankDialogViewModel()
      : super(AddOtherBankDialogState(loaderStatus: LoadingStatus.loading));

  late GroupInformationRepository repository;
  late ReferenceDataService repositoryDataService;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<Facility>? facilityCollection = [];
  Facility currentFacilityItems = Facility();

  List<Reference> bankNameOptions = [];
  List<Reference> typeOfFacilityOptions = [];
  List<Reference> securityOptions = [];

  Customer? selectedCustomer = Customer(customerRimNo: null, customerName: '');
  List<Customer> customers =
      //Globals.request?.customers ?? [] TODO remove this after API integration/
      [
    Customer(customerName: 'RIM NO 50', customerRimNo: 50),
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

  /// Initializes the `AddOtherBankDialogViewModel` with provided data and context.
  ///
  /// This asynchronous function performs the following:
  /// - Logs the initialization process.
  /// - Sets up the repository instance.
  /// - Fetches reference data using [getReferenceDatas].
  /// - Initializes the index and facilities list.
  /// - If a [initalFacility] is provided, it populates the form fields such as
  ///   `fundedValue`, `notFundedValue`, `totalValue`, `comments`, and `bankId`
  ///   based on the selected index.
  /// - Sets default customer RIM reference values for display or selection.
  ///

  Future<void> init(
    BuildContext context, {
    Facility? initalFacility,
  }) async {
    logger.i('Initializing AddOtherBankDialogViewModel');

    repository = GroupInformationRepository.instance;
    repositoryDataService = ReferenceDataService();
    // for checkup with request type creditRisk
    showCurrentFiCreditRisk =
        Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

    await getReferenceDatas();

    if (initalFacility != null) {
      currentFacilityItems = initalFacility;
      selectedCustomer = Customer(
          customerRimNo: initalFacility.customerRimNo,
          customerName: initalFacility.customerName);
    }
  }

  /// Fetches reference data for the list of banks and updates the state accordingly.
  ///
  /// This asynchronous function retrieves reference data using the [ReferenceDataService]
  /// for the key [ReferenceDataKeys.bankList]. The resulting list of banks is stored in
  /// [bankNameOptions]. It then updates the state to reflect the loading status:
  ///
  /// - If the data is successfully fetched, the state is updated with [LoadingStatus.loaded].
  /// - If an error occurs during the fetch, the state is updated with [LoadingStatus.error].

  Future<void> getReferenceDatas() async {
    try {
      Map<String, List<Reference>>? referenceData =
          await repositoryDataService.getReferenceData([
        ReferenceDataKeys.bankList,
        ReferenceDataKeys.facilityTypes,
        ReferenceDataKeys.securityType
      ]);
      bankNameOptions = referenceData[ReferenceDataKeys.bankList] ?? [];
      typeOfFacilityOptions =
          referenceData[ReferenceDataKeys.facilityTypes] ?? [];
      securityOptions = referenceData[ReferenceDataKeys.securityType] ?? [];
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Sets the selected customer RIM reference.
  ///
  /// This function updates the internal state with the selected [Customer]
  /// object
  void customerRIMReferenceSelected(Customer customer) {
    selectedCustomer = customer;
  }

  /// Sets the selected bank reference and updates the state.
  ///
  /// This function updates the selected bank ID and reference object,
  /// then emits a state change to indicate that the data has been loaded.
  ///

  void nameofBanksReferenceSelected(Reference bankData) {
    currentFacilityItems.bankNameId = bankData.id;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onFacilityTypeSelected(List<Reference> facilityTypeData) {
    currentFacilityItems.facilityWith = facilityTypeData;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onSecurityTypeSelected(List<Reference> securityTypeData) {
    currentFacilityItems.securityWith = securityTypeData;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Calculates the total value by summing funded and non-funded values,
  /// and updates the state accordingly.
  ///
  /// This function:
  /// - Parses the `fundedValue` and `notFundedValue` strings into doubles.
  /// - Calculates their sum and stores it as a string in `totalValue`.
  /// - Emits a loading state before the calculation and a loaded state after.
  ///
  /// If either value is null or cannot be parsed, it defaults to `0.0`.

  void calculateTotal() {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    final double value1 =
        double.tryParse(currentFacilityItems.fundedLimit.toString()) ?? 0.0;
    final double value2 =
        double.tryParse(currentFacilityItems.nonFundedLimit.toString()) ?? 0.0;
    final double sum = value1 + value2;
    currentFacilityItems.total = sum.toInt();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles the cancel action by closing the current dialog or screen.
  ///
  /// This function simply pops the current context from the navigation stack,
  /// effectively closing the dialog or returning to the previous screen.

  Future<void> onCancelButtonPressed(BuildContext context) async {
    context.pop();
  }

  /// Handles the save action when the user presses the "Save" button in the form.
  ///
  /// This asynchronous function performs the following steps:
  /// 1. Validates the form using [formKey].
  /// 2. If valid, saves the form state and emits a loading status.
  /// 3. Depending on whether a new entry is being added (`inDex == -1`) or an existing
  ///    one is being updated, it populates the [facilityCollection] list accordingly.
  /// 4. Converts the [facilityCollection] list to a JSON-compatible format.
  /// 5. Sends the data to the backend using [repository.saveFacilitiesWithOtherBank].
  /// 6. Logs the result and closes the dialog.
  /// 7. Emits a loaded or error status based on the outcome.

  Future<void> onSaveButtonPressed(BuildContext context) async {
    try {
      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();
        emit(state.copyWith(loaderStatus: LoadingStatus.loading));

        final updatedData = currentFacilityItems
          ..customerRimNo = selectedCustomer?.customerRimNo
          ..customerName = selectedCustomer?.customerName;

        facilityCollection ??= [];

        updatedData
          ..news = true
          ..deleted = false;

        facilityCollection!.add(updatedData);

        final jsonData = facilityCollection!.map((e) => e.toJson()).toList();

        final result = await repository.saveFacilitiesWithOtherBank(jsonData);
        logger.i('onSaveButtonPressed: $result');
        logger.i('onSaveButtonPressed: $jsonData');

        router.pop();
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      logger.e('Error in onSaveButtonPressed: $e');
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  void onSecurityDeleted(int index) {
    final list = currentFacilityItems.securityWith;
    if (list == null || index < 0 || index >= list.length) return;

    list.removeAt(index);

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onFacilityDeleted(int index) {
    final list = currentFacilityItems.facilityWith;
    if (list == null || index < 0 || index >= list.length) return;

    list.removeAt(index);

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

// Source of truth for selection (IDs)
  List<int>? securityWithIds;

// Optional: maintain Reference selection in your current model (for UI)
// currentFacilityItems.securityWith : List<Reference>?

  void onSecurityTypeSelectedById(List<int> ids) {
    securityWithIds = ids;

    // Keep currentFacilityItems.securityWith in sync (if you still use it)
    final selectedRefs =
        securityOptions.where((opt) => ids.contains(opt.id)).toList();

    currentFacilityItems.securityWith = selectedRefs;

    // Trigger your state update, e.g. setState/emit/etc.
    // emit(state.copyWith(...));
  }

  /// Resolve display name by ID from the options list.
  /// Falls back to the provided `ref.name`, then to "--" if nothing found.
  String displayNameFromIdOrRef({
    required Reference ref,
    required List<Reference> options,
    String fallback = "",
  }) {
    final id = ref.id;
    if (id != null) {
      final match = options.firstWhere(
        (e) => e.id == id,
        orElse: () => Reference(id: 0, name: null),
      );
      // Prefer authoritative options name, then ref.name, then fallback
      return (match.name ?? ref.name ?? fallback);
    }
    return ref.name ?? fallback;
  }
}
