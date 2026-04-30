import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/group_borrowers/state.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/borrower_repository.dart";

class GroupBorrowersViewModel extends SafeCubit<GroupBorrowersState> {
  GroupBorrowersViewModel()
      : super(GroupBorrowersState(loaderStatus: LoadingStatus.loading));

  late BorrowerRepository repository;

  /// Form key for the whole Borrowers Segregation form.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// All customers known in the Group (borrowers + non-borrowers).
  List<Customer> customers = [];

  /// Last searched / resolved customer (via RIM search).
  Customer? customer;

  /// RIM passed in when the screen opens (used for initial search).
  String? rim;

  // --- Persistence helpers for “manually added” tracking across rebuilds ---
  static final Set<int> _persistedManuallyAdded = <int>{};
  static final Set<int> _persistedAddedFromPotential = <int>{};
  static final List<int> _persistedAddedOrder = <int>[];

  /// Identifies which request/session these static caches belong to.
  /// When it changes, we reset the caches to prevent cross-request leakage.
  static String? _persistedContextKey;

  /// Input controller: auto-populated customer name when searching by RIM.
  final TextEditingController customerNameController = TextEditingController();

  /// UI overrides for borrower status per RIM (row-level).
  final Map<int, bool> _toggledBorrowerStatus = {};

  /// Non-borrower RIMs selected for “Include”.
  final Set<int> _selectedNonBorrowerRims = {};

  /// Borrower RIMs that were manually added via “Include”.
  final Set<int> _manuallyAddedBorrowerRims = {};

  /// Borrower RIMs selected for “Exclude”.
  final Set<int> _selectedForExclusion = {};

  /// Borrower RIMs added via “+Add Potential RIMs”.
  Set<int> addedFromPotential = {};

  /// Search query for the Non-Borrowers table; matches **RIM or Name**.
  String? nonBorrowersSearchQuery;

  /// Last “search result” values from RIM search.
  String? searchedCustomerName;
  String? searchedCustomerRim;

  /// Toggle for the “+Add Potential RIMs” section.
  bool showAddRimSection = false;

  /// User-typed RIM in the “Add Potential RIMs” panel.
  String? addRimInput;

  /// True when current business segment is FI (affects policy text/UI).
  bool isFI = false;

  /// Current page mode (edit/view).
  PageMode pagemode = PageMode.na;

  /// True when the current role/context should not edit this section.
  bool get isReadOnly => Globals.request?.isRequestCreated ?? false;

  // ------------------------
  // Lists derived from state
  // ------------------------

  /// Borrowers returned by previous app/API (not manually added in this session).
  List<Customer> get originalBorrowers =>
      customers.where((Customer customerItem) {
        return (customerItem.isBorrower ?? false) &&
            !_manuallyAddedBorrowerRims.contains(customerItem.customerRimNo);
      }).toList();

  /// Borrowers that were added manually (via “Include”).
  List<Customer> get manualBorrowers =>
      customers.where((Customer customerItem) {
        return _manuallyAddedBorrowerRims.contains(customerItem.customerRimNo);
      }).toList();

  /// Final Borrowers list shown in the table: original first, then manual
  /// (append-at-end).
  List<Customer> get borrowersList => [
        ...originalBorrowers,
        ...manualBorrowers,
      ];

  /// Non-Borrowers list filtered by [nonBorrowersSearchQuery].
  /// - If empty, returns all non-borrowers.
  /// - If present, matches **RIM** (string contains) or
  ///   **Name** (displayName/preferredName/customerName, case-insensitive contains).
  List<Customer> get nonBorrowersList {
    final Iterable<Customer> nonBorrowersOnly = customers
        .where((Customer customerItem) => !(customerItem.isBorrower ?? false));

    final String? searchQueryTrimmed = nonBorrowersSearchQuery?.trim();
    if (searchQueryTrimmed == null || searchQueryTrimmed.isEmpty) {
      return nonBorrowersOnly.toList();
    }

    final String searchQueryLowerCase = searchQueryTrimmed.toLowerCase();
    return nonBorrowersOnly
        .where(
          (Customer customerItem) =>
              _matchesByRimOrName(customerItem, searchQueryLowerCase),
        )
        .toList();
  }

  /// True when a valid Potential RIM search has been performed and can be
  /// added.
  bool get canAddPotentialBorrower {
    final String typedRim = (addRimInput ?? "").trim();
    final String resolvedRim = (searchedCustomerRim ?? "").trim();
    final String resolvedName = (searchedCustomerName ?? "").trim();

    return typedRim.isNotEmpty &&
        resolvedRim.isNotEmpty &&
        resolvedName.isNotEmpty &&
        (resolvedRim == typedRim) &&
        customer != null;
  }

  // ------------------------
  // Loading & Initialization
  // ------------------------

  /// Loads the Group’s customers (borrowers and non-borrowers) from
  /// `Globals.request`.
  /// Deduplicates by RIM, and sets `isBorrower=true` for known borrowers.
  Future<void> fetchCustomersList() async {
    customers.clear();
    final Map<int, Customer> customersByRim = <int, Customer>{};

    // Borrowers first
    for (final dynamic borrowerEntry in Globals.request?.borrowers ?? []) {
      borrowerEntry.isBorrower = true; // ensure the flag is set
      final dynamic borrowerRim = borrowerEntry.customerRimNo;
      if (borrowerRim != null) customersByRim[borrowerRim] = borrowerEntry;
    }

    // Non-borrowers: add only if not already seen as borrower
    for (final dynamic nonBorrowerEntry
        in Globals.request?.nonBorrowers ?? []) {
      final dynamic nonBorrowerRim = nonBorrowerEntry.customerRimNo;
      final bool rimAlreadyPresent =
          nonBorrowerRim != null && customersByRim.containsKey(nonBorrowerRim);
      if (rimAlreadyPresent) continue;
      if (nonBorrowerRim != null) {
        customersByRim[nonBorrowerRim] = nonBorrowerEntry;
      }
    }

    customers = customersByRim.values.toList();
  }

  /// Initializes the ViewModel:
  /// - Sets repositories and page mode
  /// - Loads customers
  /// - Restores persisted “manually added”/order flags for current list
  /// - Optionally performs an initial RIM search
  Future<void> init(context) async {
    logger.i("initialising GroupBorrowersViewModel");
    repository = BorrowerRepository.instance;
    pagemode = AuthRepository.getPageMode(RightConstants.groupBorrowers);

    // prevent static cache leaking across different request/appRef
    final String currentContextKey = _buildContextKeyFromGlobalsRequest();
    final bool contextChanged = _persistedContextKey != currentContextKey;

    if (contextChanged) {
      _clearPersistedCaches();
      _persistedContextKey = currentContextKey;
    }

    // Business segment flag (FI/non-FI)
    isFI = Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

    await fetchCustomersList();

    // Restore persisted flags and prune to currently known customers
    final Set<int> currentRims = customers
        .map((Customer customerItem) => customerItem.customerRimNo)
        .whereType<int>()
        .toSet();

    _manuallyAddedBorrowerRims
      ..clear()
      ..addAll(_persistedManuallyAdded.where(currentRims.contains));

    addedFromPotential =
        _persistedAddedFromPotential.where(currentRims.contains).toSet();

    final Set<int> dedupeVisited = <int>{};
    _persistedAddedOrder
      ..removeWhere((int rimNumber) => !currentRims.contains(rimNumber))
      ..removeWhere((int rimNumber) => !dedupeVisited.add(rimNumber));

    if (rim != null) {
      await searchCustomerByRim(rim!);
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // ------------------------
  // Search & Mutations
  // ------------------------

  /// Searches by RIM (string), resolves a customer, and populates
  /// `searchedCustomerX` fields.
  Future<void> searchCustomerByRim(String rimInput) async {
    final int? rimAsInt = int.tryParse(rimInput);
    if (rimAsInt == null) {
      searchedCustomerName = null;
      searchedCustomerRim = null;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return;
    }
    try {
      final Customer? searchResponse =
          await repository.getCustomerByPotentialRim(rimAsInt);

      searchedCustomerRim = rimAsInt.toString();
      searchedCustomerName = searchResponse?.lastName;

      customerNameController.text = searchedCustomerName ?? "";

      customer = Customer(
        customerRimNo: rimAsInt,
        isBorrower: true,
        firstName: searchResponse?.firstName,
        middleName: searchResponse?.middleName,
        lastName: searchResponse?.lastName,
        customerName: searchResponse?.concatCustomerFullName,
      );

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
      searchedCustomerName = null;
      searchedCustomerRim = null;
    }
  }

  /// Toggles the visibility of the “+Add Potential RIMs” section.
  void toggleAddRimSection() {
    showAddRimSection = !showAddRimSection;
    emit(state.copyWith(loaderStatus: state.loaderStatus));
  }

  /// Promote selected Non-Borrowers to Borrowers.
  /// - Moves selected rows to `borrowers`
  /// - Tracks manual additions and ordering
  /// - Clears the selection
  void includeSelectedBorrowers() {
    try {
      if (_selectedNonBorrowerRims.isEmpty) {
        throw "requestInformation.groupBorrowers.nonBorrowerInclude".tr();
      }

      // Avoid duplicate additions to request.borrowers
      final Set<int> existingBorrowerRims = <int>{
        ...?Globals.request?.borrowers
            ?.map((Customer borrowerItem) => borrowerItem.customerRimNo)
            .whereType<int>(),
      };

      for (final Customer customerItem in customers) {
        final int? rimNumber = customerItem.customerRimNo;

        final bool isCurrentlyNonBorrower = !(customerItem.isBorrower ?? false);
        final bool isSelectedToInclude =
            _selectedNonBorrowerRims.contains(rimNumber);

        if (isCurrentlyNonBorrower && isSelectedToInclude) {
          customerItem.isBorrower = true;

          // Remove from nonBorrowers (if present)
          Globals.request?.nonBorrowers?.removeWhere(
            (Customer nonBorrowerItem) =>
                nonBorrowerItem.customerRimNo == rimNumber,
          );

          // Add to borrowers only if not already there
          final bool rimIsNew =
              rimNumber != null && !existingBorrowerRims.contains(rimNumber);
          if (rimIsNew) {
            Globals.request?.borrowers?.add(customerItem);
            existingBorrowerRims.add(rimNumber);
          }

          // Track manual inclusion (affects ordering and exclusion rules)
          _manuallyAddedBorrowerRims.add(rimNumber ?? 0);
          _persistedManuallyAdded.add(rimNumber ?? 0);

          // Maintain append-at-end order for the combined table
          final bool orderNotTracked =
              rimNumber != null && !_persistedAddedOrder.contains(rimNumber);
          if (orderNotTracked) {
            _persistedAddedOrder.add(rimNumber);
          }
        }
      }

      _selectedNonBorrowerRims.clear();
      emit(GroupBorrowersState(loaderStatus: LoadingStatus.loaded));
    } catch (error) {
      AlertManager().showFailureToast(error.toString());
    }
  }

  /// Toggle borrower status for a given [rimNumber] in the non-borrowers table
  /// (UI only).
  void toggleBorrowerStatus(int rimNumber, bool newIsBorrowerValue) {
    _toggledBorrowerStatus[rimNumber] = newIsBorrowerValue;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Toggle inclusion selection (checkbox) for a given [rimNumber].
  void toggleBorrowerSelection(int rimNumber, bool selectedForInclusion) {
    if (selectedForInclusion) {
      _selectedNonBorrowerRims.add(rimNumber);
    } else {
      _selectedNonBorrowerRims.remove(rimNumber);
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// True when [customerItem] is currently checked to be included as a
  /// borrower.
  bool isSelectedForInclusion(Customer customerItem) {
    return _selectedNonBorrowerRims.contains(customerItem.customerRimNo);
  }

  /// True when [customerItem] was added manually via “Include”.
  bool isManuallyAdded(Customer customerItem) {
    return _manuallyAddedBorrowerRims.contains(customerItem.customerRimNo);
  }

  /// Toggle exclusion selection for a borrower by [rimNumber].
  void toggleBorrowerExclusion(int rimNumber, bool selectedForExclusion) {
    if (selectedForExclusion) {
      _selectedForExclusion.add(rimNumber);
    } else {
      _selectedForExclusion.remove(rimNumber);
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// True when [customerItem] is currently selected for exclusion.
  bool isSelectedForExclusion(Customer customerItem) {
    return _selectedForExclusion.contains(customerItem.customerRimNo);
  }

  /// Excludes (moves back) only the borrowers that were manually added from the
  /// Non-Borrowers section.
  ///
  /// This method must update `Globals.request.borrowers` AND
  /// `Globals.request.nonBorrowers`,
  /// because the GroupBorrowers screen is rebuilt from those lists on re-entry
  void excludeSelectedBorrowers() {
    // Ensure lists exist
    final List<Customer> requestBorrowers =
        Globals.request?.borrowers ?? <Customer>[];
    final List<Customer>? requestNonBorrowers =
        Globals.request?.nonBorrowers ??= <Customer>[];

    // Track existing non-borrowers by rim to prevent duplicates
    final Set<int> nonBorrowerRimsAlreadyPresent = requestNonBorrowers!
        .map((Customer customerItem) => customerItem.customerRimNo)
        .whereType<int>()
        .toSet();

    for (final Customer customerItem in customers) {
      final int? rimNumber = customerItem.customerRimNo;
      if (rimNumber == null) continue;

      final bool isBorrowerRow = customerItem.isBorrower ?? false;
      final bool wasManuallyAdded =
          _manuallyAddedBorrowerRims.contains(rimNumber);
      final bool selectedForExclusion =
          _selectedForExclusion.contains(rimNumber);

      // Only allow excluding borrowers that were manually added
      if (!isBorrowerRow || !wasManuallyAdded || !selectedForExclusion) {
        continue;
      }

      // Flip local flag so tables update immediately
      customerItem.isBorrower = false;

      // Remove from request.borrowers by rim (safer than object reference)
      requestBorrowers.removeWhere(
        (Customer borrowerItem) => borrowerItem.customerRimNo == rimNumber,
      );

      //  Add back to request.nonBorrowers if missing
      if (!nonBorrowerRimsAlreadyPresent.contains(rimNumber)) {
        requestNonBorrowers.add(customerItem);
        nonBorrowerRimsAlreadyPresent.add(rimNumber);
      }

      // Cleanup tracking flags/order so it doesn't show as "manual borrower" anymore
      _manuallyAddedBorrowerRims.remove(rimNumber);
      _persistedManuallyAdded.remove(rimNumber);
      _persistedAddedOrder.remove(rimNumber);
    }

    // Clear exclusion selection after action
    _selectedForExclusion.clear();

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Adds the last successfully searched Potential RIM to the Borrowers list.
  /// Only works when `searchedCustomerRim` and `searchedCustomerName` are
  /// present and consistent.
  void addPotentialBorrower() {
    if (searchedCustomerRim != null || searchedCustomerName != null) {
      toggleAddRimSection();
    }

    if (searchedCustomerRim != null && searchedCustomerName != null) {
      final int rimNumber = int.tryParse(searchedCustomerRim!) ?? 0;

      if (rimNumber == 0) {
        AlertManager().showFailureToast(
          "requestInformation.groupBorrowers.errorAddPotentialBorrower".tr(),
        );
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }

      // block duplicates with user-friendly toast + clear state
      if (isRimAlreadyInBorrowersList(rimNumber)) {
        AlertManager().showWarningToast(
          "requestInformation.groupBorrowers.rimAlreadyPresent".tr(),
        );

        // Clear the last successful search so reopening is clean
        clearPotentialRimSearchResult(clearTypedRimInput: true);
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }

      final Customer newCustomer = Customer(
        customerRimNo: rimNumber,
        firstName: customer?.firstName,
        middleName: customer?.middleName,
        lastName: customer?.lastName,
        customerName: customer?.concatCustomerFullName,
        isBorrower: true,
      );

      final Customer? resolvedCustomer = customer;
      if (resolvedCustomer != null) {
        Globals.request?.borrowers?.add(resolvedCustomer);
      }

      customers.add(newCustomer);
      addedFromPotential.add(rimNumber);
      _persistedAddedFromPotential.add(rimNumber);

      if (!_persistedAddedOrder.contains(rimNumber)) {
        _persistedAddedOrder.add(rimNumber);
      }
      AlertManager().showSuccessToast(
        "requestInformation.groupBorrowers.addedPotentialBorrower".tr(),
      );
      clearPotentialRimSearchResult(clearTypedRimInput: true);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } else {
      AlertManager().showFailureToast(
        "requestInformation.groupBorrowers.customerRimNotExist".tr(),
      );
    }
  }

  /// Returns true if the given [rimNumber] is already present in the Borrowers
  /// list.
  /// This covers both original group borrowers and borrowers manually added via Include/Potential flow.
  bool isRimAlreadyInBorrowersList(int rimNumber) {
    return borrowersList.any(
      (Customer borrowerItem) => borrowerItem.customerRimNo == rimNumber,
    );
  }

  /// Updates the typed RIM value in the Potential RIM panel.
  /// If user edits the value after a successful search, invalidate search
  /// result
  /// so "Add" button stays disabled until search is performed again.
  void updateAddRimInput(String rimText) {
    addRimInput = rimText;

    final String typedRim = (addRimInput ?? "").trim();
    final String searchedRim = (searchedCustomerRim ?? "").trim();

    // If user changes typed rim, previous search result should no longer be
    // valid.
    if (searchedRim.isNotEmpty && typedRim != searchedRim) {
      clearPotentialRimSearchResult(clearTypedRimInput: false);
    }

    emit(state.copyWith(loaderStatus: state.loaderStatus));
  }

  /// Clears the last successful Potential RIM search result.
  /// This disables the "Add" button until the user searches again.
  void clearPotentialRimSearchResult({bool clearTypedRimInput = false}) {
    searchedCustomerName = null;
    searchedCustomerRim = null;
    customer = null;
    customerNameController.text = "";

    if (clearTypedRimInput) {
      addRimInput = null;
    }
  }

  /// Cancels the Potential RIM panel:
  /// - closes the section
  /// - clears any successful search state
  /// - optionally clears typed input
  void cancelAddPotentialRimSection() {
    showAddRimSection = false;
    clearPotentialRimSearchResult(clearTypedRimInput: true);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Removes a Potential RIM (added via the panel) by [rimNumber].
  /// Cleans up lists, ordering, and manual flags.
  void removePotentialBorrower(int rimNumber) {
    if (addedFromPotential.contains(rimNumber)) {
      customers.removeWhere((Customer c) => c.customerRimNo == rimNumber);
      Globals.request?.borrowers
          ?.removeWhere((Customer c) => c.customerRimNo == rimNumber);

      addedFromPotential.remove(rimNumber);
      _persistedAddedFromPotential.remove(rimNumber);

      _manuallyAddedBorrowerRims.remove(rimNumber);
      _persistedManuallyAdded.remove(rimNumber);
      _persistedAddedOrder.remove(rimNumber);

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Updates the Non-Borrowers filter query (RIM/Name). Debounced by caller.
  Future<void> updateNonBorrowersSearchQuery(String? rawQuery) async {
    final String? trimmedQuery = rawQuery?.trim();
    if (trimmedQuery == null || trimmedQuery.isEmpty) {
      nonBorrowersSearchQuery = null;
      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.loaded,
          isSearchingNonBorrowers: false,
        ),
      );
      return;
    }
    emit(state.copyWith(isSearchingNonBorrowers: true));
    await Future.delayed(const Duration(milliseconds: 500));
    nonBorrowersSearchQuery = trimmedQuery;

    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        isSearchingNonBorrowers: false,
      ),
    );
  }

  // ------------------------
  // Matching helpers
  // ------------------------

  /// Case-insensitive `contains` for strings.
  bool _containsIgnoreCase(String? sourceText, String queryLowerCase) {
    if (sourceText == null || sourceText.trim().isEmpty) return false;
    return sourceText.toLowerCase().contains(queryLowerCase);
  }

  /// True if the customer matches the query by RIM (string contains)
  /// or by any of the name fields (display/preferred/registered) case-insensitively.
  bool _matchesByRimOrName(Customer customerItem, String queryLowerCase) {
    final String rimAsString = (customerItem.customerRimNo ?? "").toString();
    final bool rimMatches = rimAsString.contains(queryLowerCase);

    final String? displayName = customerItem.displayName;
    final String? preferredName = customerItem.preferredName;
    final String? registeredName = customerItem.customerName;

    final bool nameMatches = _containsIgnoreCase(displayName, queryLowerCase) ||
        _containsIgnoreCase(preferredName, queryLowerCase) ||
        _containsIgnoreCase(registeredName, queryLowerCase);

    return rimMatches || nameMatches;
  }

  /// Builds a stable context key so we can reset static caches
  /// when switching to another request/appRefNo or after logout/login.
  String _buildContextKeyFromGlobalsRequest() {
    final String applicationRefNo =
        (Globals.request?.applicationRefNo ?? "").trim();
    final String groupId = (Globals.request?.groupId?.toString() ?? "").trim();
    final String customerRimNo =
        (Globals.request?.customerRimNo?.toString() ?? "").trim();

    // Key priority: appRefNo (best), else fallback to group+rim
    if (applicationRefNo.isNotEmpty) {
      return "APPREF:$applicationRefNo";
    }
    return "GROUP:$groupId|RIM:$customerRimNo";
  }

  /// Clears all static "persisted" caches that should NOT leak across requests.
  static void _clearPersistedCaches() {
    _persistedManuallyAdded.clear();
    _persistedAddedFromPotential.clear();
    _persistedAddedOrder.clear();
  }
}
