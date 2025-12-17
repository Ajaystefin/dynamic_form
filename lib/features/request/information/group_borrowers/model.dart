import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/repositories/auth_repository.dart';
import 'package:wcas_frontend/repositories/borrower_repository.dart';

import 'state.dart';

class GroupBorrowersViewModel extends Cubit<GroupBorrowersState> {
  GroupBorrowersViewModel()
      : super(GroupBorrowersState(loaderStatus: LoadingStatus.loading));
  late BorrowerRepository repository;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<Customer> customers = [];
  Customer? customer;
  String? rim;
  final TextEditingController customerNameController = TextEditingController();

  /// Overrides for each customer's borrower status.
  final Map<int, bool> _toggledBorrowerStatus = {};

  /// RIM numbers selected for inclusion.
  final Set<int> _selectedNonBorrowerRims = {};

  /// RIMs manually added via the non-borrowers table ("Include" button).
  final Set<int> _manuallyAddedBorrowerRims = {};

  /// Borrowers selected for exclusion.
  final Set<int> _selectedForExclusion = {};

  /// RIMs added via the Add Potential RIM view.
  Set<int> addedFromPotential = {};

  // field for search query for non borrower table
  String? nonBorrowersSearchQuery;

  //var for displaying searched customer details.
  String? searchedCustomerName;
  String? searchedCustomerRim;

  /// UI‐only: controls “Add Potential RIM” panel
  bool showAddRimSection = false;
  String? addRimInput;

  PageMode pagemode = PageMode.na;
  bool get isReadOnly =>
      (pagemode == PageMode.view || Globals.request!.isRequestCreated);

  /// Returns a list of original borrowers from the API,
  /// excluding those manually added.
  List<Customer> get originalBorrowers => customers.where((c) {
        return (c.isBorrower ?? false) &&
            !_manuallyAddedBorrowerRims.contains(c.customerRimNo);
      }).toList();

  // Get those borrowers that were manually added.
  List<Customer> get manualBorrowers => customers.where((c) {
        return _manuallyAddedBorrowerRims.contains(c.customerRimNo);
      }).toList();

  // Combined borrowers list: first original borrowers, then manually added ones.
  List<Customer> get borrowersList => [
        ...originalBorrowers,
        ...manualBorrowers,
      ];

  /// Returns the list of customers that are non-borrowers
  /// filtered by the search query.
  List<Customer> get nonBorrowersList {
    final all = customers.where((c) => !(c.isBorrower ?? false));
    if (nonBorrowersSearchQuery?.isNotEmpty ?? false) {
      return all
          .where((c) =>
              c.customerRimNo.toString().contains(nonBorrowersSearchQuery!))
          .toList();
    }
    return all.toList();
  }

  Future<void> fetchCustomersList() async {
    customers.clear();
    final Map<int, Customer> byRim = {};

    for (final b in Globals.request?.borrowers ?? []) {
      b.isBorrower = true; // ensure the flag is set
      final rim = b.customerRimNo;
      if (rim != null) byRim[rim] = b;
    }

    for (final nb in Globals.request?.nonBorrowers ?? []) {
      final rim = nb.customerRimNo;
      if (rim != null && byRim.containsKey(rim)) continue;
      if (rim != null) byRim[rim] = nb;
    }

    customers = byRim.values.toList();
  }

  // Called when the "Include" button is pressed.
  // For each selected non-borrower, update their flag and mark them as manually added.
  void includeSelectedBorrowers() {
    try {
      if (_selectedNonBorrowerRims.isEmpty) {
        throw "Please select Non-Borrowers to include";
      }

      // Fast lookup to avoid duplicate adds
      final existingBorrowerRims = <int>{
        ...?Globals.request?.borrowers
            ?.map((c) => c.customerRimNo)
            .whereType<int>(),
      };

      for (final c in customers) {
        final rim = c.customerRimNo;

        if (!(c.isBorrower ?? false) &&
            _selectedNonBorrowerRims.contains(rim)) {
          // 1) Flip local flag
          c.isBorrower = true;

          // 2) Remove from request.nonBorrowers if present
          Globals.request?.nonBorrowers
              ?.removeWhere((n) => n.customerRimNo == rim);

          // 3) Add to request.borrowers only if not already there
          if (rim != null && !existingBorrowerRims.contains(rim)) {
            Globals.request?.borrowers?.add(c);
            existingBorrowerRims.add(rim);
          }

          // Track manual inclusion for table/exclusion logic
          _manuallyAddedBorrowerRims.add(rim ?? 0);
        }
      }

      _selectedNonBorrowerRims.clear();
      logger.i(
          'Included selected borrowers. Manually added: $_manuallyAddedBorrowerRims');
      emit(GroupBorrowersState(loaderStatus: LoadingStatus.loaded));
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  /// Initializes the view model by setting the repository instance and
  /// fetching group customers; if [rim] is provided, it performs a search.
  Future<void> init(context) async {
    logger.i('initialising GroupBorrowersViewModel');
    repository = BorrowerRepository.instance;
    pagemode = AuthRepository.getPageMode(RightConstants.groupBorrowers);
    await fetchCustomersList();
    logger.i(Globals.request);
    if (rim != null) {
      await searchCustomerByRim(rim!);
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // Search method accepts a rim value as a string, verifies it,
  // calls the API, updates the local search variables, and emits a state update.
  Future<void> searchCustomerByRim(String rimInput) async {
    final rimValue = int.tryParse(rimInput);
    if (rimValue == null) {
      searchedCustomerName = null;
      searchedCustomerRim = null;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return;
    }
    try {
      final model = await repository.getCustomerByRim(rimValue);
      final lastName =
          model.responseData?.partyInfo?.personData?.personName?.lastName;
      searchedCustomerRim = rimValue.toString();
      searchedCustomerName = lastName ?? '';
      customerNameController.text = searchedCustomerName ?? "";

      customer = Customer(
          customerRimNo: rimValue, isBorrower: true, customerName: lastName);

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
      searchedCustomerName = null;
      searchedCustomerRim = null;
    }
  }

  /// Toggle the visibility of the “Add RIM” section
  void toggleAddRimSection() {
    showAddRimSection = !showAddRimSection;
    emit(state.copyWith(loaderStatus: state.loaderStatus));
  }

  /// Called by the text-field’s onChanged
  void updateAddRimInput(String rim) {
    addRimInput = rim;
    emit(state.copyWith(loaderStatus: state.loaderStatus));
  }

  // Toggle the borrower status for a customer in the non-borrowers table.
  // This method updates the toggle map and triggers a rebuild.
  void toggleBorrowerStatus(int rim, bool newValue) {
    _toggledBorrowerStatus[rim] = newValue;
    logger.i('Toggled customer ($rim) isBorrower status to $newValue');
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // Toggle the selection state for a customer in the non-borrowers table.
  // This selection is temporary until the user clicks "Include".
  void toggleBorrowerSelection(int rim, bool newValue) {
    if (newValue) {
      _selectedNonBorrowerRims.add(rim);
    } else {
      _selectedNonBorrowerRims.remove(rim);
    }
    logger.i('Toggled selection for customer ($rim) to $newValue');
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Checks whether the specified [customer] is selected for inclusion.
  /// so that its checkbox is checked.
  bool isSelectedForInclusion(Customer customer) {
    return _selectedNonBorrowerRims.contains(customer.customerRimNo);
  }

  // Helper for the borrowers table UI: check if customer was manually added.
  bool isManuallyAdded(Customer customer) {
    return _manuallyAddedBorrowerRims.contains(customer.customerRimNo);
  }

  /// Toggles the exclusion selection for a borrower identified by [rim].
  /// Updates the exclusion set and emits a state update.
  void toggleBorrowerExclusion(int rim, bool newValue) {
    if (newValue) {
      _selectedForExclusion.add(rim);
    } else {
      _selectedForExclusion.remove(rim);
    }
    logger.i('Toggled exclusion selection for borrower ($rim) to $newValue');
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Checks if the customer is selected for exclusion.
  bool isSelectedForExclusion(Customer customer) {
    return _selectedForExclusion.contains(customer.customerRimNo);
  }

  /// Excludes selected borrowers by setting their borrower status to false.
  /// Clears the exclusion selection and updates the state.
  void excludeSelectedBorrowers() {
    for (var customer in customers) {
      if ((customer.isBorrower ?? false) &&
          _manuallyAddedBorrowerRims.contains(customer.customerRimNo) &&
          _selectedForExclusion.contains(customer.customerRimNo)) {
        customer.isBorrower = false;
        Globals.request?.borrowers?.remove(customer);
        _manuallyAddedBorrowerRims.remove(customer.customerRimNo);
      }
    }
    _selectedForExclusion.clear();
    logger.i('Excluded selected borrowers.');
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Adds a potential borrower based on the current search result.
  /// If the customer does not already exist, it is added to the list.
  void addPotentialBorrower() {
    if (searchedCustomerRim != null || searchedCustomerName != null) {
      toggleAddRimSection();
    }
    if (searchedCustomerRim != null && searchedCustomerName != null) {
      int rimNumber = int.tryParse(searchedCustomerRim!) ?? 0;
      bool alreadyExists =
          customers.any((customer) => customer.customerRimNo == rimNumber);
      if (!alreadyExists) {
        Customer newCustomer = Customer(
          customerRimNo: rimNumber,
          customerName: searchedCustomerName,
          isBorrower: true,
        );
        Customer? addCustomer = customer;
        if (addCustomer != null) Globals.request?.borrowers?.add(addCustomer);
        customers.add(newCustomer);
        addedFromPotential.add(rimNumber);
        searchedCustomerRim = null;
        searchedCustomerName = null;
        customerNameController.text = "";
        logger.i('Added potential borrower: $newCustomer');
        AlertManager().showSuccessToast(
            "requestInformation.groupBorrowers.addedPotentialBorrower".tr());
      } else {
        logger.i('Customer with RIM $rimNumber already exists');
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } else {
      AlertManager().showFailureToast(
          "requestInformation.groupBorrowers.customerRimNotExist".tr());
    }
  }

  /// Removes a potential borrower added via the Add Potential RIM view.
  /// Updates the customer list and emits a state update.
  void removePotentialBorrower(int rim) {
    if (addedFromPotential.contains(rim)) {
      customers.removeWhere((customer) => customer.customerRimNo == rim);

      Globals.request?.borrowers
          ?.removeWhere((customer) => customer.customerRimNo == rim);

      addedFromPotential.remove(rim);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// the search query used to filter the non-borrowers list.
  /// After setting the query, the state is emitted with [LoadingStatus.loaded])`
  /// the search query used to filter the non-borrowers list.
  Future<void> updateNonBorrowersSearchQuery(String? query) async {
    final rimValue = query?.trim();
    if (rimValue == null || rimValue.isEmpty) {
      nonBorrowersSearchQuery = null;
      emit(state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        isSearchingNonBorrowers: false,
      ));
      return;
    }
    emit(state.copyWith(isSearchingNonBorrowers: true));
    await Future.delayed(const Duration(milliseconds: 500));
    nonBorrowersSearchQuery = rimValue;

    emit(state.copyWith(
      loaderStatus: LoadingStatus.loaded,
      isSearchingNonBorrowers: false,
    ));
  }
}
