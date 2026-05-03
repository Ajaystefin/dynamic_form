import "package:decimal/decimal.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/group_information/facilities_data.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/group_information_repository.dart";

class AddOtherBankDialogViewModel extends SafeCubit<AddOtherBankDialogState> {
  AddOtherBankDialogViewModel()
      : super(AddOtherBankDialogState(loaderStatus: LoadingStatus.loading));

  late GroupInformationRepository repository;
  late ReferenceDataService repositoryDataService;
  late CustomerRepository customerRepository;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController customerController = TextEditingController();
  TextEditingController facilityController = TextEditingController();
  ApplicationDetails? applicationDetails;

  List<Facility>? facilityCollection = [];
  Facility currentFacilityItems = Facility();

  List<Reference> bankNameOptions = [];
  List<Reference> typeOfFacilityOptions = [];
  List<Reference> securityOptions = [];

  Customer? selectedCustomer = Customer(customerRimNo: null, customerName: "");
  List<Customer> customers = [];

  bool isFiFlow = false;
  Facility? initalFacilitys;

  /// Initializes the `AddOtherBankDialogViewModel` with provided data and
  /// context.
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
    logger.i("Initializing AddOtherBankDialogViewModel");
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    repository = GroupInformationRepository.instance;
    repositoryDataService = ReferenceDataService();
    customerRepository = CustomerRepository.instance;
    // for checkup with request type creditRisk
    isFiFlow = Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

    await getReferenceDatas();
    await getApplicationDetails();

    if (initalFacility != null) {
      currentFacilityItems = initalFacility;
      initalFacilitys = initalFacility;
      selectedCustomer = Customer(
        customerRimNo: initalFacility.customerRimNo,
        customerName: initalFacility.customerName,
      );
      customerController.text = selectedCustomer?.customerName ?? "";
    }
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        customerName:
            initalFacility?.customerName ?? selectedCustomer?.displayName,
      ),
    );
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
    // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Fetches reference data for the list of banks and updates the state
  /// accordingly.
  ///
  /// This asynchronous function retrieves reference data using the
  /// [ReferenceDataService]
  /// for the key [ReferenceDataKeys.bankList]. The resulting list of banks is
  /// stored in
  /// [bankNameOptions]. It then updates the state to reflect the loading
  /// status:
  ///
  /// - If the data is successfully fetched, the state is updated with
  /// [LoadingStatus.loaded].
  /// - If an error occurs during the fetch, the state is updated with
  /// [LoadingStatus.error].

  Future<void> getReferenceDatas() async {
    try {
      final Map<String, List<Reference>> referenceData =
          await repositoryDataService.getReferenceData([
        ReferenceDataKeys.bankList,
        ReferenceDataKeys.facilityTypes,
        ReferenceDataKeys.securityType,
      ]);
      bankNameOptions = referenceData[ReferenceDataKeys.bankList] ?? [];
      typeOfFacilityOptions =
          referenceData[ReferenceDataKeys.facilityTypes] ?? [];
      securityOptions = referenceData[ReferenceDataKeys.securityType] ?? [];
      // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
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
    customerController.text = selectedCustomer?.concatCustomerFullName ??
        selectedCustomer?.customerName ??
        "";
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
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
    final Decimal? value1 =
        currentFacilityItems.fundedLimit ?? Decimal.tryParse("0.0");
    final Decimal? value2 =
        currentFacilityItems.nonFundedLimit ?? Decimal.tryParse("0.0");
    final Decimal sum = value1! + value2!;
    currentFacilityItems.total = sum;
    facilityController.text = currentFacilityItems.total.toString();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles the cancel action by closing the current dialog or screen.
  ///
  /// This function simply pops the current context from the navigation stack,
  /// effectively closing the dialog or returning to the previous screen.

  Future<void> onCancelButtonPressed(BuildContext context) async {
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
  ///    one is being updated, it populates the [facilityCollection] list
  ///accordingly.
  /// 4. Converts the [facilityCollection] list to a JSON-compatible format.
  /// 5. Sends the data to the backend using
  /// [repository.saveFacilitiesWithOtherBank].
  /// 6. Logs the result and closes the dialog.
  /// 7. Emits a loaded or error status based on the outcome.

  Future<void> onSaveButtonPressed(BuildContext context) async {
    try {
      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();
        emit(state.copyWith(loaderStatus: LoadingStatus.loading));

        final updatedData = currentFacilityItems
          ..customerRimNo = selectedCustomer?.customerRimNo
          ..customerName = (initalFacilitys != null)
              ? selectedCustomer?.customerName ??
                  selectedCustomer?.concatCustomerFullName ??
                  ""
              : selectedCustomer?.concatCustomerFullName ?? "";

        facilityCollection ??= [];

        updatedData
          ..news = (initalFacilitys != null) ? false : true
          ..deleted = false;

        final result = await repository.saveOtherBankData(updatedData);
        AlertManager().showSuccessToast(result.toString());

        router.pop();
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      logger.e("Error in onSaveButtonPressed: $e");
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
      return match.name ?? ref.name ?? fallback;
    }
    return ref.name ?? fallback;
  }
}
