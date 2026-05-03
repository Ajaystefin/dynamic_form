import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/state.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/view.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/covenant_condition_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";

enum CovenantTestType { rim, name }

enum InternalFinancialCovenantType { yes, no }

class CovenantEditDialogViewModel extends SafeCubit<CovenantEditDialogState> {
  CovenantEditDialogViewModel(
    this.covenant,
    this.isNew, {
    PageMode? overridePageMode,
  }) : super(CovenantEditDialogState(loaderStatus: LoadingStatus.loading));
  Covenant? covenant;
  bool? isNew;
  PageMode? overridePageMode;
  late CovenantConditionRepository repository;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Map<String, List<Reference>> referenceData = {};

  CovenantTestType? selectedTestType = CovenantTestType.rim;

  InternalFinancialCovenantType? selectedInternalFinancialType =
      InternalFinancialCovenantType.yes;

  Customer? selectedCustomerRim;
  ApplicationDetails? applicationDetails;
  Reference? financialCovenantSubtypeSelection;

  //fields to show data on ui
  Reference? selectedCovenantType;
  Reference? selectedCovenantSubType;
  Reference? selectedPeriod;
  Reference? selectedFrequency;
  Reference? selectedAction;
  Reference? selectedThreshold;
  Reference? thresholdType;
  Reference? selectedStatus;
  Reference? selectedBasisOfPreperation;
  Reference? selectedTimeForSubmission;
  Reference? selectedAuditStatus;
  Reference? generalField;
  //link financial view fields
  Reference? selectedLinkFinancialCovenantType;
  Reference? selectedLinkFinancialCovenantSubType;

  Reference? selectedSubTypeValue;
  Customer? selectedCustomer;
  Customer? searchedCustomer;

  bool showAddWidgets = false;
  int? isCovenant = 1;

  //reference values
  List<Reference>? covenantType = [];
  List<Reference>? covenantSubType = [];
  List<Reference>? covenantPeriod = [];
  List<Reference>? covenantSubmissionTime = [];
  List<Reference>? covenantBasisOfPreparation = [];
  List<Reference>? covenantAuditStatus = [];
  List<Reference>? covenantStatus = [];
  List<Reference>? covenanttThresholdType = [];
  List<Reference> descriptionTypes = [];

  final TextEditingController nextMonitoringDateController =
      TextEditingController();
  final TextEditingController creditLensController = TextEditingController();
  final TextEditingController entityNameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  Reference? selectedFinancialCovenantSubType;
  Reference? selectedGeneralCovenantSubType;
  PageMode pageMode = PageMode.na;
  bool get isReadOnly => pageMode == PageMode.view;

  PageMode? covenantEditPageMode;
  bool get canEdit => covenantEditPageMode == PageMode.edit;

  /// Checks if the covenant is being updated.
  bool isUpdateCovenant() => covenant != null;
  bool isFinancialCovenantDescription = true;

  Reference? selectedAllFacilitiesYesNo;

  // Row radio selection, keyed by a stable row identity
  final Map<int, Reference?> rowAllFacilitiesYesNo = {};

  Reference? getRowAllFacilitiesRef(Covenant row) =>
      rowAllFacilitiesYesNo[identityHashCode(row)];

  bool isSpecificSelected() =>
      ServerConstants.covenantSpecificId == generalField?.id;

  bool get isRequiredBusinessSegment =>
      Utils.checkBusinessSegment(BusinessSegment.corporate);

  CovenantType get selectedCovenantTypeEnum =>
      CovenantTypeHelper.fromId(selectedCovenantType?.id);

  CovenantSubType? get selectedSubTypeValueEnum =>
      CovenantSubTypeHelper.fromId(selectedCovenantSubType?.id);

  CovenantSubType? get selectedSubGeneralTypeValueEnum =>
      CovenantSubTypeHelper.fromId(selectedGeneralCovenantSubType?.id);

  CovenantSubType? get selectedSubFinancialTypeValueEnum =>
      CovenantSubTypeHelper.fromId(selectedFinancialCovenantSubType?.id);

  //add rim variables
  String rimNoSearch = "";
  final TextEditingController customerNameController = TextEditingController();

  // add new covenants in the list when isNew = true
  bool isLinkFinancialView = false;
  bool isFinancialCovenantView = false;
  List<Covenant> financialCovenantSubtypes = [];
  List<Covenant> linkedFinancialCovenants = [];
  bool isNewCovenant = false;

  //covenant description
  int? selectedDescriptionTypeId;
  String? selectedDescriptionType;
  int? selectedFinancialDescriptionTypeId;
  String? selectedFinancialDescriptionType;

  bool? isFinancialStandard = true;
  bool? isStandardCovenantSelected;
  String? customLinkFinancialDescription;
  String? customAddCSFinancialDescription;
  bool get isStandardSelected =>
      selectedDescriptionTypeId == ServerConstants.standardDescriptionId;
  bool get isFinancialSubtypeEnabled =>
      selectedFinancialDescriptionTypeId ==
      ServerConstants.standardDescriptionId;
  bool isLinkFinancialSubtypeEnabled = true;

  TextEditingController financialDescriptionController =
      TextEditingController();

  List<Customer>? customersList = [];
  List<Facility> facilityList = [];

  //input standard description for covenant subtypes
  // final RegExp _bracketRegex = RegExp(r'\[(.*?)\]');
  final RegExp _bracketRegex = RegExp(r"\[(.*?)\]");
  final RegExp _allowedAlnum = RegExp("[A-Za-z0-9]");
  final RegExp _sanitizeToAlnum = RegExp("[^A-Za-z0-9]");
  final String _bracketLeftPad = "  ";
  final String _bracketRightPad = "  ";

  bool isUpdatingFinancialDescription = false;
  bool showOnlyNonFinancialSubtypeItems = false;
  bool isDescriptionReadOnly = false;

  static const String _editableAction = ServerConstants.defaultNewStatus;

  // Frozen for this dialog session based on the response used to open it
  bool _allowActionEditing = false;

// Final gate for UI
  bool get canEditStatusAction => _allowActionEditing && canEdit;

  //get covenant subytypes conditional based on selected covenant type
  List<Reference> get covenantSubTypeDropdownItems {
    final List<Reference> allItems =
        referenceData[ReferenceDataKeys.covenantSubtype] ?? [];

    final String? selectedTypeId = selectedGeneralCovenantSubType?.reference2 ??
        selectedCovenantType?.id?.toString() ??
        covenant?.covenantType?.toString();

    final List<Reference> filtered =
        (selectedTypeId != null && selectedTypeId.isNotEmpty)
            ? allItems
                .where((ref) => ref.reference2?.trim() == selectedTypeId.trim())
                .toList()
            : allItems;

    final List<Reference> finalList = filtered.isNotEmpty ? filtered : allItems;

    final List<Reference> others = finalList
        .where(
          (ref) =>
              ref.id ==
              ServerConstants.covenantSubTypeId[CovenantSubType.other],
        )
        .toList();
    final List<Reference> nonOthers = finalList
        .where(
          (ref) =>
              ref.id !=
              ServerConstants.covenantSubTypeId[CovenantSubType.other],
        )
        .toList();

    return [...nonOthers, ...others];
  }

  //selected covenant subtypes
  List<Reference> get selectedSubTypeItems {
    if (selectedGeneralCovenantSubType != null) {
      return [selectedGeneralCovenantSubType!];
    } else {
      return [];
    }
  }

  // get filtered frequecy based on covenant type and subtype
  List<Reference> get filteredFrequencies {
    final List<Reference> originalItems =
        referenceData[ReferenceDataKeys.covenantFrequency] ?? [];

    final bool shouldFilter = covenant?.covenantSubType ==
            ServerConstants.covenantSubTypeIdForFrequencyFilter ||
        selectedCovenantTypeEnum == CovenantType.nonFinancial ||
        selectedCovenantTypeEnum == CovenantType.financial;

    if (!shouldFilter) return originalItems;

    return originalItems
        .where(
          (item) => !ServerConstants.excludedFrequencyIds.contains(item.id),
        )
        .toList();
  }

  bool get shouldShowDescriptionTextArea {
    return selectedDescriptionTypeId == ServerConstants.customDescriptionId ||
        (selectedCovenantTypeEnum == CovenantType.information &&
            selectedGeneralCovenantSubType != null &&
            selectedSubGeneralTypeValueEnum == CovenantSubType.other);
  }

  int get countFinancialSubtypesR11144 =>
      (referenceData[ReferenceDataKeys.covenantSubtype] ?? const <Reference>[])
          .where(
            (ref) =>
                ref.reference2?.trim() ==
                ServerConstants.financialCovenantReference2,
          )
          .length;

  bool get isThresholdTypeRequired => countFinancialSubtypesR11144 > 10;

  List<Customer>? customerList = [];

  int get _financialSubtypeCount {
    final List<Reference> allItems =
        referenceData[ReferenceDataKeys.covenantSubtype] ?? const <Reference>[];
    final String finRef2 = ServerConstants.financialCovenantReference2.trim();
    return allItems
        .where((value) => (value.reference2 ?? "").trim() == finRef2)
        .length;
  }

  bool get isThresholdTypeTextFieldRequired {
    if (_financialSubtypeCount <= 10) return false;
    final int? selectedId =
        selectedFinancialCovenantSubType?.id ?? covenant?.covenantSubType;
    if (selectedId == null) return false;
    return !ServerConstants.initialFinancialSubtypeIds.contains(selectedId);
  }

  String? thresholdTypeCustomValue;

  /// Initializes the view model.
  /// Sets up the repository, loads reference data, and pre-fills covenant
  /// details if available.
  /// [context] - The BuildContext for UI updates.
  /// [covenantData] - The existing covenant condition, if provided.
  Future<void> init(
    context,
    isNew,
    overridePageMode, [
    Covenant? covenantData,
  ]) async {
    covenantEditPageMode = overridePageMode ??
        AuthRepository.getPageMode(RightConstants.covenantsUpdate);
    repository = CovenantConditionRepository.instance;
    await loadReferenceData();
    await getChildRimsForGroup();
    customersList = [...(Globals.request?.customers ?? <Customer>[])];
    isNewCovenant = isNew;
    if (covenantData != null) {
      covenant = covenantData;
      _allowActionEditing = (covenant?.status != _editableAction);
      populateFromExistingCovenant();
    } else {
      covenant = Covenant();
      _allowActionEditing = false;
    }
    initializeDefaultActionIfNeeded();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  bool get isActionEditable {
    final int masterId = covenant?.covConMasterId ?? 0;
    return !isReadOnly && masterId != 0;
  }

  //get child rim list for customer name  dropdown
  Future<void> getChildRimsForGroup() async {
    try {
      if (Utils.isGroupApplication()) {
        customerList =
            await CustomerRepository.instance.getChildRimsForGroup() ?? [];
      } else {
        // Fallback for non-owner: use customers already in this request
        customerList = Globals.request?.customers ?? [];
      }
    } catch (e) {
      logger.i("Error fetching getChildRimsForGroup : $e");
      rethrow;
    }
  }

  /// Loads reference data for search criteria, segment types, region list,
  /// advance request types, and role types. Populates the [referenceData] map
  /// with the fetched data. If an error occurs during the fetching process,
  /// it updates the loader status to [LoadingStatus.error].
  Future<void> loadReferenceData() async {
    try {
      referenceData = await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.covenantType,
        ReferenceDataKeys.covenantConditionAction,
        ReferenceDataKeys.covenantConditionStatus,
        ReferenceDataKeys.covenantFrequency,
        ReferenceDataKeys.covenantAuditStatus,
        ReferenceDataKeys.covenantSubmissionTime,
        ReferenceDataKeys.covenantBasicSeperation,
        ReferenceDataKeys.covenantPeriod,
        ReferenceDataKeys.covenantSubtype,
        ReferenceDataKeys.thresholdType,
        ReferenceDataKeys.covenantGeneralSpecific,
        ReferenceDataKeys.covenantDescription,
      ]);
      covenantType = referenceData[ReferenceDataKeys.covenantType] ?? [];
      covenantSubType = referenceData[ReferenceDataKeys.covenantSubtype] ?? [];
      covenantPeriod = referenceData[ReferenceDataKeys.covenantPeriod] ?? [];
      covenantSubmissionTime =
          referenceData[ReferenceDataKeys.covenantSubmissionTime] ?? [];
      covenantBasisOfPreparation =
          referenceData[ReferenceDataKeys.covenantBasicSeperation] ?? [];
      covenantAuditStatus =
          referenceData[ReferenceDataKeys.covenantAuditStatus] ?? [];
      covenantStatus =
          referenceData[ReferenceDataKeys.covenantConditionStatus] ?? [];
      covenanttThresholdType =
          referenceData[ReferenceDataKeys.thresholdType] ?? [];
      descriptionTypes =
          referenceData[ReferenceDataKeys.covenantDescription] ?? [];
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      rethrow;
    }
  }

  /// if isNewCovenant is false Pre-fills covenant data
  /// based on the provided information from convenant summary list.
  void populateFromExistingCovenant() {
    try {
      selectedCustomer = Customer(
        customerRimNo: covenant?.rimNo,
        customerName: covenant?.customerName,
        firstName: covenant?.customerName,
      );

      selectedCovenantType =
          covenantType!.firstWhere((ref) => ref.id == covenant!.covenantType);

      creditLensController.text = covenant?.creditLensId ?? "";
      entityNameController.text = covenant?.entityName ?? "";
      state.entityName = covenant?.entityName ?? "";

      if (covenant?.covenantSubType != null) {
        selectedCovenantSubType = covenantSubType!
            .firstWhere((ref) => ref.id == covenant!.covenantSubType);
        selectedGeneralCovenantSubType = covenantSubType!
            .firstWhere((ref) => ref.id == covenant!.covenantSubType);
        selectedFinancialCovenantSubType = covenantSubType!
            .firstWhere((ref) => ref.id == covenant!.covenantSubType);
      }

      if (covenant?.facilityDetailList != null &&
          covenant!.facilityDetailList!.isNotEmpty) {
        facilityList = covenant!.facilityDetailList!;
      }

      if (covenant?.periodTerm != null) {
        selectedPeriod =
            covenantPeriod!.firstWhere((ref) => ref.id == covenant!.periodTerm);
      }

      if (covenant?.basisOfPreparation != null) {
        selectedBasisOfPreperation = covenantBasisOfPreparation!
            .firstWhere((ref) => ref.id == covenant!.basisOfPreparation);
      }

      if (covenant?.isInternalFinancial != null) {
        selectedInternalFinancialType = (covenant?.isInternalFinancial ?? true)
            ? InternalFinancialCovenantType.yes
            : InternalFinancialCovenantType.no;
      }
      if (covenant?.isStandard != null) {
        isStandardCovenantSelected = covenant!.isStandard;
        selectedDescriptionTypeId = isStandardCovenantSelected!
            ? ServerConstants.standardDescriptionId
            : ServerConstants.customDescriptionId;
      }

      if (covenant?.isStandard != null) {
        isFinancialStandard = covenant!.isStandard;
        selectedFinancialDescriptionTypeId = isFinancialStandard!
            ? ServerConstants.standardDescriptionId
            : ServerConstants.customDescriptionId;
      }

      initializeSelectedDescriptionType();
      //restore Non-Financial subtype enable/disable state on reopen
      if (selectedCovenantTypeEnum == CovenantType.nonFinancial) {
        // Non-financial subtype dropdown is driven by this flag in UI
        isLinkFinancialSubtypeEnabled = isStandardCovenantSelected ?? true;

        // If Custom covenant, subtype must be cleared + disabled
        if (!(isStandardCovenantSelected ?? true)) {
          selectedFinancialCovenantSubType = null;
          selectedGeneralCovenantSubType = null;
          selectedCovenantSubType = null;
          covenant?.covenantSubType = null;
        }
      }
      initializeFinancialSelectedDescriptionType();

      selectedDescriptionType = descriptionTypes
          .firstWhere(
            (ref) => ref.id == selectedDescriptionTypeId,
            orElse: () => descriptionTypes.first,
          )
          .name;

      selectedFinancialDescriptionType = descriptionTypes
          .firstWhere(
            (ref) => ref.id == selectedFinancialDescriptionTypeId,
            orElse: () => descriptionTypes.first,
          )
          .name;

      if (covenant?.timeForSubmition != null) {
        selectedTimeForSubmission = covenantSubmissionTime!
            .firstWhere((ref) => ref.id == covenant!.timeForSubmition);
      }

      if (covenant?.auditStatus != null) {
        selectedAuditStatus = covenantAuditStatus!
            .firstWhere((ref) => ref.id == covenant!.auditStatus);
      }

      if (covenant?.frequency != null) {
        selectedFrequency = referenceData[ReferenceDataKeys.covenantFrequency]
            ?.firstWhere((Reference value) => value.id == covenant?.frequency);
      }

      final int? actionId = covenant?.action;
      if (actionId != null && actionId != 0) {
        final List<Reference> actions =
            referenceData[ReferenceDataKeys.covenantConditionAction] ?? [];
        selectedAction = actions.firstWhere(
          (ref) => ref.id == actionId,
          orElse: Reference.new,
        );
      } else {
        selectedAction = null;
      }

      if (covenant?.thresholdType != null) {
        selectedThreshold =
            referenceData[ReferenceDataKeys.thresholdType]?.firstWhere(
          (Reference value) => value.id == covenant?.thresholdType,
        );
      }

      if (covenant?.isGeneric ?? false) {
        referenceData[ReferenceDataKeys.covenantGeneralSpecific]?.map(
          (element) {
            if (element.id == ServerConstants.covenantGeneralId) {
              generalField = element;
            }
          },
        ).toList();
      } else {
        referenceData[ReferenceDataKeys.covenantGeneralSpecific]?.map(
          (element) {
            if (element.id == ServerConstants.covenantSpecificId) {
              generalField = element;
            }
          },
        ).toList();
      }

      if (!isNewCovenant) {
        // Ensure borrowers from saved covenant exist in dropdown list
        // (customersList)
        // This is required when borrower RIM was added via AddRim flow and is
        // not part of Globals.request.customers.
        final List<Customer> list =
            customersList ?? Globals.request?.customers ?? <Customer>[];

        final List<Customer> borrowers = covenant?.borrowers ?? <Customer>[];
        for (final Customer borrower in borrowers) {
          final int? rim = borrower.customerRimNo;

          // Skip Name-mode borrower (9999) or invalid
          if (rim == null || rim == ServerConstants.covenantToBeTestedName) {
            continue;
          }

          final bool exists =
              list.any((customer) => customer.customerRimNo == rim);
          if (!exists) {
            // Insert same object reference so selection works even if dropdown
            // compares by identity
            list.insert(
              0,
              Customer(
                customerRimNo: rim,
                customerName: (borrower.customerName ??
                        borrower.displayName ??
                        borrower.firstName ??
                        "")
                    .trim(),
              ),
            );
          }
        }

        customersList = List<Customer>.from(list);
        int? apiBorrowerRim;
        try {
          if ((covenant?.borrowers?.isNotEmpty ?? false) &&
              (covenant?.borrowers?.first.customerRimNo != null)) {
            apiBorrowerRim = covenant!.borrowers!.first.customerRimNo;
          }
        } catch (_) {}
        try {
          if (apiBorrowerRim == null &&
              (covenant?.borrowers?.isNotEmpty ?? false)) {
            apiBorrowerRim = covenant!.borrowers!.first.customerRimNo;
          }
        } catch (_) {}

        if (apiBorrowerRim != null) {
          final List<Customer> match = list
              .where((customer) => customer.customerRimNo == apiBorrowerRim)
              .toList();
          if (match.isNotEmpty) {
            selectedCustomerRim = match.first;
          }
        }
      }

      // ------------------------------------------------------------------
      // If any borrower has rimNo == 9999, switch to "Name" mode and
      //      prefill NameField with custName (e.g., "test2").
      //      This is ONLY for rimNo == 9999 as per requirement.
      // ------------------------------------------------------------------
      final bool hasborrowerWithNameMode = covenant?.borrowers?.any(
            (borrower) =>
                borrower.customerRimNo ==
                ServerConstants.covenantToBeTestedName,
          ) ??
          false;

      if (hasborrowerWithNameMode) {
        // If there are multiple borrowers, we use the first 9999-rim entry for
        // the name.
        final Customer borrowerWithNameMode = covenant!.borrowers!.firstWhere(
          (borrower) =>
              borrower.customerRimNo == ServerConstants.covenantToBeTestedName,
          orElse: Customer.new,
        );
        selectedTestType = CovenantTestType.name;
        nameController.text = (borrowerWithNameMode.customerName ?? "").trim();

        // Make sure RIM-based UI is not selected
        selectedCustomerRim = null;
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Sets the selected action and updates the covenant's action ID accordingly.
  void setSelectedAction(Reference? action) {
    selectedAction = action;
    covenant?.action = action?.id;
  }

  void setRowFacilitiesAndOption(
    Covenant row,
    List<Facility> facilities,
    Reference? allRef,
  ) {
    row.facilityDetailList = facilities;
    rowAllFacilitiesYesNo[identityHashCode(row)] = allRef;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Searches for customer information using the provided RIM number.
  /// Populates the read-only name field and caches the found customer.
  /// Does NOT modify the dropdown list or selection.
  Future<void> searchByRim(String rim) async {
    final String trimmed = rim.trim();
    if (trimmed.isEmpty) {
      AlertManager().showFailureToast("riskRating.invalidRim".tr());
      return;
    }

    emit(state.copyWith(searchLoaderStatus: LoadingStatus.loading));

    try {
      rimNoSearch = trimmed;

      final Customer? customerDetails =
          await CustomerRepository().searchUserDetails(trimmed, "", "", "");
      final int? rimNoFromApi = customerDetails?.customerRimNo;
      final int? rimNo = rimNoFromApi ?? int.tryParse(trimmed);

      if (rimNo == null) {
        customerNameController.text = "";
        searchedCustomer = null;
        AlertManager().showFailureToast("riskRating.invalidRim".tr());
        return;
      }

      final String? displayName =
          (customerDetails?.preferredName?.trim().isNotEmpty ?? false)
              ? customerDetails!.preferredName
              : (customerDetails?.customerName ?? "");
      customerNameController.text = displayName ?? "";
      searchedCustomer = customerDetails;
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    } finally {
      emit(state.copyWith(searchLoaderStatus: LoadingStatus.loaded));
    }
  }

  /// Adds the currently searched RIM into the dropdown list (top) and selects
  /// it.
  /// Does not clear/replace existing items. Does not mutate covenant.*
  /// This is triggered by the "Add" button in AddRimValueDropdown.
  void addSearchedRimToList() {
    final int? rimNo =
        searchedCustomer?.customerRimNo ?? int.tryParse(rimNoSearch);
    if (rimNo == null) {
      AlertManager().showFailureToast("riskRating.invalidRim".tr());
      return;
    }

    customersList ??= <Customer>[];
    customersList!.removeWhere((customer) => customer.customerRimNo == rimNo);

    final String? name =
        (searchedCustomer?.customerName?.trim().isNotEmpty ?? false)
            ? searchedCustomer!.customerName
            : (customerNameController.text.trim().isNotEmpty
                ? customerNameController.text.trim()
                : null);

    final String? id = searchedCustomer?.id;
    final Customer newEntry = Customer(
      id: id,
      customerRimNo: rimNo,
      customerName: name,
      type: searchedCustomer?.type,
    );

    customersList!.insert(0, newEntry);
    customersList = List<Customer>.from(customersList!);
    selectedCustomerRim = newEntry;

    customerNameController.clear();
    rimNoSearch = "";
    searchedCustomer = null;

    showAddWidgets = false;
    emit(
      state.copyWith(
        showAddWidgets: false,
        searchLoaderStatus: LoadingStatus.loaded,
      ),
    );
  }

  // /// Initializes the default action to "Create" if:
  /// - The current covenant is new (`isNewCovenant` is true)
  /// - No action has been selected yet (`selectedAction` is null)
  /// It looks for the "Create" action by its ID defined in serverconstants
  void initializeDefaultActionIfNeeded() {
    if (isNewCovenant && selectedAction == null) {
      final List<Reference> availableActions =
          referenceData[ReferenceDataKeys.covenantConditionAction] ?? [];
      final Reference createAction = availableActions.firstWhere(
        (item) => item.id == ServerConstants.createActionId,
        orElse: Reference.new,
      );
      setSelectedAction(createAction);
    }
  }

  /// Returns a list containing the currently selected action for the dropdown.
  /// - If `forceEmptySelection` is true, returns an empty list.
  /// - If a valid `selectedAction` exists in the available actions, returns it.
  /// - If it's a new covenant and no valid selection exists, returns the
  /// "Create" action by default.
  /// - Otherwise, returns an empty list.
  List<Reference> getSelectedActionItems(bool forceEmptySelection) {
    if (forceEmptySelection) return [];

    final List<Reference> availableActions =
        referenceData[ReferenceDataKeys.covenantConditionAction] ?? [];

    if (selectedAction != null &&
        availableActions.any((item) => item.id == selectedAction!.id)) {
      return [selectedAction!];
    }

    if (isNewCovenant) {
      final Reference createAction = availableActions.firstWhere(
        (item) => item.id == ServerConstants.createActionId,
        orElse: Reference.new,
      );
      return [createAction];
    }

    return [];
  }

  //isNew Covenant not customer name in field
  List<Customer> getSelectedCustomerForDropdown(forceShow) {
    if (forceShow && selectedCustomer != null) {
      return [selectedCustomer!];
    }
    if (isNewCovenant && selectedCustomer == null) {
      return [];
    }
    return [selectedCustomer!];
  }

  /// get selected covenant sub type list in selecteditems
  List<Reference> getSelectedFinancialSubtype(
    Reference? externalSelectedItem,
    bool forceEmpty,
  ) {
    if (forceEmpty) {
      return [];
    } else if (externalSelectedItem != null) {
      return [externalSelectedItem];
    } else if (selectedFinancialCovenantSubType != null) {
      return [selectedFinancialCovenantSubType!];
    } else {
      return [];
    }
  }

  /// get selected threshold list for selectedItems
  // Replace your current getSelectedThreshold with this overload:
  List<Reference> getSelectedThreshold(
    Reference? externalSelectedItem,
    bool forceEmpty,
  ) {
    if (forceEmpty) {
      return [];
    } else if (externalSelectedItem != null) {
      return [externalSelectedItem];
    } else if (selectedThreshold != null) {
      return [selectedThreshold!];
    } else {
      return [];
    }
  }

  Reference? findFinancialSubtypeById(int? id) {
    if (id == null) return null;
    final List<Reference> list = getFilteredFinancialCovenantSubtypes();
    final int filteredItems =
        list.indexWhere((reference) => reference.id == id);
    return filteredItems == -1 ? null : list[filteredItems];
  }

  Reference? findThresholdById(int? id) {
    if (id == null) return null;
    final List<Reference> threshold =
        referenceData[ReferenceDataKeys.thresholdType] ?? [];
    final int thresholdId =
        threshold.indexWhere((reference) => reference.id == id);
    return thresholdId == -1 ? null : threshold[thresholdId];
  }

  // get selected covenant type list in selecteditems
  List<Reference> getSelectedCovenantType(Reference? externalSelectedItem) {
    if (externalSelectedItem != null) {
      return [externalSelectedItem];
    } else if (selectedCovenantType != null) {
      return [selectedCovenantType!];
    } else {
      return [];
    }
  }

  //map covenants and threhold type
  Reference? getThresholdTypeForCovenantSubtype(int? subtypeId) {
    if (subtypeId == null) return null;

    int? thresholdTypeId;

    if (ServerConstants.minThresholdSubtypeIds.contains(subtypeId)) {
      thresholdTypeId = ServerConstants.thresholdTypeMin;
    } else if (ServerConstants.maxThresholdSubtypeIds.contains(subtypeId)) {
      thresholdTypeId = ServerConstants.thresholdTypeMax;
    }

    if (thresholdTypeId == null) return null;

    final List<Reference> list = covenanttThresholdType ?? const <Reference>[];
    final int index =
        list.indexWhere((reference) => reference.id == thresholdTypeId);
    return (index == -1) ? null : list[index];
  }

// Whether text-field mode is required for a GIVEN subtype id
  bool isThresholdTypeTextFieldRequiredFor(int? subtypeId) {
    if (_financialSubtypeCount <= 10) return false;
    if (subtypeId == null) return false;
    return !ServerConstants.initialFinancialSubtypeIds.contains(subtypeId);
  }

// Desktop enablement: enabled when there is NO mapping; disabled when matched
  bool get isDesktopThresholdEditable {
    if (isThresholdTypeTextFieldRequired) {
      return true; // >10 regime => let user pick
    }
    final int? id =
        selectedFinancialCovenantSubType?.id ?? covenant?.covenantSubType;
    if (id == null) return false; // nothing selected yet
    final Reference? mapped = getThresholdTypeForCovenantSubtype(id);
    // ENABLE if NO match; DISABLE if matched
    return mapped == null;
  }

// ThresholdEditable enablement: but for the row's own subtype
  bool isRowThresholdEditable(Covenant row) {
    final int? subId = row.covenantSubType;
    if (subId == null) return false; // NEW: no subtype => keep disabled

    // If your >10 regime says "user must pick threshold type", allow editing.
    if (isThresholdTypeTextFieldRequiredFor(subId)) return true;

    // ENABLE only when there is NO mapping for the selected subtype.
    final Reference? mapped = getThresholdTypeForCovenantSubtype(subId);
    return mapped == null;
  }

  ///covenant subtype selection based on values
  void onGeneralCovenantSubTypeSelect(List<Reference> selectedReferences) {
    selectedGeneralCovenantSubType = selectedReferences.first;
    covenant?.description = selectedGeneralCovenantSubType?.name;
    covenant?.covenantSubType = selectedGeneralCovenantSubType?.id;
    if (isNewCovenant) selectedCustomerRim = null;

    // if we are in Information and moved to "Financial Statements" subtype (the
    // filter regime),
    // clear any previously chosen frequency because it may now be excluded.
    if (selectedCovenantTypeEnum == CovenantType.information &&
        selectedGeneralCovenantSubType?.id ==
            ServerConstants.covenantSubTypeIdForFrequencyFilter) {
      _clearSelectedFrequency();
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  ///  Clear the frequency when the Information
  /// subtype switches to Financial Statements
  void _clearSelectedFrequency() {
    selectedFrequency = null;
    covenant?.frequency = null;
  }

  ///covenant subtype selection based on values in financial covenants
  void onFinancialCovenantSubTypeSelect(List<Reference> selectedReferences) {
    selectedFinancialCovenantSubType = selectedReferences.first;
    covenant?.covenantSubType = selectedFinancialCovenantSubType?.id;

    // If we're still in the original-10 regime, use dropdown mapping as before.
    if (!isThresholdTypeTextFieldRequired) {
      final Reference? matchedThreshold = getThresholdTypeForCovenantSubtype(
        selectedFinancialCovenantSubType?.id,
      );
      if (matchedThreshold != null) {
        thresholdType = matchedThreshold;
        selectedThreshold = matchedThreshold;
        covenant?.thresholdType = selectedThreshold?.id;
      } else {
        // No match: clear any prior selection
        thresholdType = null;
        selectedThreshold = null;
        covenant?.thresholdType = null;
      }
    } else {
      // Newly added subtype — switch to text field: clear dropdown selection.
      thresholdType = null;
      selectedThreshold = null;
      covenant?.thresholdType = null;
    }

    if (covenant?.covenantType == 11145) {
      covenant?.covenantSubType = selectedFinancialCovenantSubType?.id;
    }

    final String template =
        getDescriptionTemplateForSubtype(selectedFinancialCovenantSubType?.id);
    selectedSubTypeValue?.reference1 = template.replaceAll("{value}", "");

    initializeFinancialDescription();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  ///covenant subtype selection based on values in link financial covenants
  ///when case is information covenant and subtype is financial statements
  void onCovenantSubTypeSelect(List<Reference> selectedReferences) {
    selectedCovenantSubType = selectedReferences.first;
    covenant?.covenantSubType = selectedCovenantSubType?.id;

    final Reference? matchedThreshold = getThresholdTypeForCovenantSubtype(
      selectedCovenantSubType?.id,
    );

    if (matchedThreshold != null) {
      thresholdType = matchedThreshold;
    }

    final String template =
        getDescriptionTemplateForSubtype(selectedCovenantSubType?.id);
    selectedSubTypeValue?.reference1 = template.replaceAll("{value}", "");
    initializeFinancialDescription();

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  //get mapped string in description
  String getDescriptionTemplateForSubtype(int? subtypeId) {
    if (subtypeId == null) return "";
    return ServerConstants.financialDescriptionTemplates[subtypeId] ??
        "Shall not exceed [ {value} ]";
  }

  //chars allowed inside brackets inside description
  int firstAllowedCharIndexInsideBrackets(String text) {
    final int open = text.indexOf("[");
    if (open < 0) return -1;
    final int close = text.indexOf("]", open + 1);
    final String inside =
        text.substring(open + 1, close >= 0 ? close : text.length);

    int leadingSpaces = 0;
    while (leadingSpaces < inside.length &&
        inside.codeUnitAt(leadingSpaces) == 0x20) {
      leadingSpaces++;
    }

    final RegExpMatch? match = _allowedAlnum.firstMatch(inside);
    if (match != null) {
      return open + 1 + match.start;
    }
    return open + 1 + leadingSpaces;
  }

  //extract inside brackets inside description
  String extractInsideBrackets(String text) {
    final RegExpMatch? extractValue = _bracketRegex.firstMatch(text);
    final String raw = extractValue?.group(1) ?? "";
    if (RegExp(r"\{\s*value\s*\}").hasMatch(raw)) return "";

    return raw;
  }

  //validation on input chars maxLength
  String sanitizeAndClampAlnum(String raw, {int maxLength = 100}) {
    final String sanitized = raw.replaceAll(_sanitizeToAlnum, "");
    return sanitized.length <= maxLength
        ? sanitized
        : sanitized.substring(0, maxLength);
  }

  String getBracketRawValue(String text) {
    final String raw = extractInsideBrackets(text);
    return raw.trim();
  }

  bool isBracketValueEmpty(String text) {
    return getBracketRawValue(text).isEmpty;
  }

  //description changes when type selected
  void onFinancialDescriptionChanged(String value) {
    if (isUpdatingFinancialDescription) return;
    isUpdatingFinancialDescription = true;

    final int currentSel = financialDescriptionController.selection.baseOffset;
    final String rawInsideInValue = extractInsideBrackets(value);
    final int startOfEditableInValue =
        firstAllowedCharIndexInsideBrackets(value);
    int relativeInAllowed;
    if (startOfEditableInValue >= 0 && currentSel >= startOfEditableInValue) {
      final int open = value.indexOf("[");
      final int close = value.indexOf("]", open + 1);
      final int endOfBracket = close >= 0 ? close : value.length;
      final int cappedCaret = currentSel.clamp(open + 1, endOfBracket);
      final String insideUpToCaret = value.substring(open + 1, cappedCaret);
      final String allowedUpToCaret =
          insideUpToCaret.replaceAll(_sanitizeToAlnum, "");
      relativeInAllowed = allowedUpToCaret.length;
    } else {
      final String allowedInValue =
          rawInsideInValue.replaceAll(_sanitizeToAlnum, "");
      relativeInAllowed = allowedInValue.length;
    }

    final int? id = selectedFinancialCovenantSubType?.id;

    final String template = (id != 11141 && id != 11142)
        ? '${selectedFinancialCovenantSubType?.name ?? ''} '
            "${getDescriptionTemplateForSubtype(id)}"
        : (getDescriptionTemplateForSubtype(id));

    final String sanitizedAlnum =
        sanitizeAndClampAlnum(rawInsideInValue, maxLength: 100);

    final String updatedText = template.replaceAll(
      "{value}",
      "$_bracketLeftPad$sanitizedAlnum$_bracketRightPad",
    );

    // keep threshold value in sync (top-level covenant)
    applyThresholdFromDescription(updatedText);

    selectedSubTypeValue?.reference1 = updatedText;
    final int startOfEditableInUpdated =
        firstAllowedCharIndexInsideBrackets(updatedText);
    final int newAllowedLen = sanitizedAlnum.length;

    int targetOffset;
    if (startOfEditableInUpdated >= 0) {
      int relativeOffset = relativeInAllowed;
      if (relativeOffset < 0) relativeOffset = 0;
      if (relativeOffset > newAllowedLen) relativeOffset = newAllowedLen;
      targetOffset = startOfEditableInUpdated + relativeOffset;
    } else {
      targetOffset = updatedText.length;
    }
    final TextEditingValue oldValue = financialDescriptionController.value;
    final int clampedOffset = targetOffset.clamp(0, updatedText.length);
    if (oldValue.text != updatedText ||
        oldValue.selection.baseOffset != clampedOffset) {
      financialDescriptionController.value = TextEditingValue(
        text: updatedText,
        selection: TextSelection.collapsed(offset: clampedOffset),
        composing: TextRange.empty,
      );
    }

    isUpdatingFinancialDescription = false;
  }

  ///for covenant subtype link financial ,financial covenant and
  ///non financial covenant we are taking user input inside
  /// description we have to send that value in treshold field
  /// Extracts only the digits inside [...] and parses them to int.
  /// Returns null if no digits found.
  int? _parseThresholdDigits(String text) {
    final String raw = extractInsideBrackets(text); // e.g., " 134 "
    final String digits = raw.replaceAll(RegExp("[^0-9]"), ""); // "134"
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  /// Applies extracted threshold to either the top-level covenant or a given
  /// row.
  void applyThresholdFromDescription(String text, {Covenant? target}) {
    final int? val = _parseThresholdDigits(text);
    if (target != null) {
      target.threshold = val ?? 0;
    } else {
      covenant ??= Covenant();
      covenant!.threshold = val ?? 0;
    }
  }

  //initialize Financial Description when called
  void initializeFinancialDescription() {
    final int? id = selectedFinancialCovenantSubType?.id;

    final String template = (id != 11141 && id != 11142)
        ? "${selectedFinancialCovenantSubType?.name ?? ''} "
            "${getDescriptionTemplateForSubtype(id)}"
        : (getDescriptionTemplateForSubtype(id));

    final String existingText = selectedSubTypeValue?.reference1 ?? template;

    final String rawInside = extractInsideBrackets(existingText);
    final String initialAlnum =
        sanitizeAndClampAlnum(rawInside, maxLength: 100);

    final String updatedText = template.replaceAll(
      "{value}",
      "$_bracketLeftPad$initialAlnum$_bracketRightPad",
    );

    final int targetOffset = firstAllowedCharIndexInsideBrackets(updatedText);

    financialDescriptionController.value = TextEditingValue(
      text: updatedText,
      selection: TextSelection.collapsed(
        offset: targetOffset >= 0 ? targetOffset : updatedText.length,
      ),
      composing: TextRange.empty,
    );
  }

  ///get placeholders in description hint from en.json
  String getDescriptionCovenantHint() {
    final String rawHint =
        tr("covenantsConditions.covenantEditDialog.financialCovenantText".tr());

    return rawHint
        .replaceAll("{basis}", selectedBasisOfPreperation?.name ?? "")
        .replaceAll("{audit}", selectedAuditStatus?.name ?? "")
        .replaceAll("{entity}", state.entityName ?? "");
  }

  //Entity name field selection
  void onEntityNameChanged(String value) {
    covenant?.entityName = value;
    emit(state.copyWith(entityName: value));
  }

  //basis of preperation field selection
  void onBasisOfPreparationSelected(List<Reference> selected) {
    selectedBasisOfPreperation = selected.first;
    covenant?.basisOfPreparation = selectedBasisOfPreperation?.id;

    emit(
      state.copyWith(selectedBasisOfPreperation: selectedBasisOfPreperation),
    );
  }

  //Audit status field Selection
  void onAuditStatusSelected(List<Reference> selected) {
    selectedAuditStatus = selected.first;
    covenant?.auditStatus = selectedAuditStatus?.id;

    emit(state.copyWith(selectedAuditStatus: selectedAuditStatus));
  }

  ///fetch and intitialize selected description field
  void initializeSelectedDescriptionType() {
    final bool isStandard = isStandardCovenantSelected ?? true;

    final Reference matchedRef = descriptionTypes.firstWhere(
      (reference) =>
          reference.id ==
          (isStandard
              ? ServerConstants.standardDescriptionId
              : ServerConstants.customDescriptionId),
      orElse: () => descriptionTypes.first,
    );

    selectedDescriptionType = matchedRef.name;
    selectedDescriptionTypeId = matchedRef.id;
  }

  void initializeFinancialSelectedDescriptionType() {
    final bool isStandard = isFinancialStandard ?? true;

    final Reference matchedRef = descriptionTypes.firstWhere(
      (reference) =>
          reference.id ==
          (isStandard
              ? ServerConstants.standardDescriptionId
              : ServerConstants.customDescriptionId),
      orElse: () => descriptionTypes.first,
    );

    selectedFinancialDescriptionType = matchedRef.name;
    selectedFinancialDescriptionTypeId = matchedRef.id;
  }

  /// Updates the selected radio option in covenant description.
  void updateGeneralIsStandardFromSelection() {
    final Reference selectedRef = descriptionTypes.firstWhere(
      (reference) => reference.name == selectedDescriptionType,
      orElse: () => Reference(name: "", id: -1),
    );
    isStandardCovenantSelected =
        selectedRef.id == ServerConstants.standardDescriptionId;
  }

  /// Updates the selected radio option in covenant link financial description.
  void updateFinancialIsStandardFromSelection() {
    final Reference selectedRef = descriptionTypes.firstWhere(
      (reference) => reference.name == selectedFinancialDescriptionType,
      orElse: () => Reference(name: "", id: -1),
    );
    isFinancialStandard =
        selectedRef.id == ServerConstants.standardDescriptionId;
  }

  /// Updates the selected description type.
  /// [value] - The new description type selection.
  void onDescriptionTypeChange(String? value) {
    selectedDescriptionType = value;

    final Reference selectedRef = descriptionTypes.firstWhere(
      (reference) => reference.name == value,
      orElse: () => Reference(name: "", id: -1),
    );

    selectedDescriptionTypeId = selectedRef.id;
    isStandardCovenantSelected =
        selectedRef.id == ServerConstants.standardDescriptionId;
    covenant?.isStandard = isStandardCovenantSelected;

    if (selectedRef.id == ServerConstants.customDescriptionId) {
      selectedGeneralCovenantSubType = null;
      covenant?.covenantSubType = null;
      linkedFinancialCovenants.clear();
      isLinkFinancialView = false;
      // keep your "mirror" flags
      // isFinancialStandard = isStandardCovenantSelected;
      // isLinkFinancialSubtypeEnabled = isFinancialStandard ?? false;
      // clear any mapped subtype selection used by the std editor
      // selectedFinancialCovenantSubType = null;
      covenant?.description = "";
      financialDescriptionController.clear();
    }
    isFinancialStandard = isStandardCovenantSelected;
    isLinkFinancialSubtypeEnabled = isFinancialStandard ?? false;
    selectedFinancialCovenantSubType = null;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  //financial description
  void onFinancialDescriptionTypeChange(String? value) {
    selectedFinancialDescriptionType = value;

    final Reference selectedRef = descriptionTypes.firstWhere(
      (reference) => reference.name == value,
      orElse: () => Reference(name: "", id: -1),
    );

    selectedFinancialDescriptionTypeId = selectedRef.id;
    isFinancialStandard =
        selectedRef.id == ServerConstants.standardDescriptionId;

    if (selectedCovenantTypeEnum == CovenantType.financial &&
        !isLinkFinancialView) {
      covenant?.isStandard = isFinancialStandard;
    }

    if (selectedRef.id == ServerConstants.customDescriptionId) {
      isLinkFinancialSubtypeEnabled = false;
      selectedFinancialCovenantSubType = null;
      covenant?.covenantSubType = null;
      selectedThreshold = null;
      if (selectedFinancialCovenantSubType?.id !=
          ServerConstants.covenantSubTypeIdForFrequencyFilter) {
        selectedFinancialCovenantSubType?.id = null;
      }

      // also clear mapped values and text on CUSTOM Description
      covenant?.thresholdType = null;
      covenant?.threshold = null;
      covenant?.description = ""; // make desktop CustomTextArea empt

      financialDescriptionController.clear(); // clear the standard controller

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } else {
      customLinkFinancialDescription = null;
      isLinkFinancialSubtypeEnabled = true;
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// get filtered list of covenant subytpe field for the
  ///  financial and non-financial covenant type selections
  List<Reference> getFilteredFinancialCovenantSubtypes() {
    final List<Reference> allItems =
        referenceData[ReferenceDataKeys.covenantSubtype] ?? [];

    // Filter by reference2 if needed (e.g., for financial covenants)
    final List<Reference> filteredByReference2 = allItems
        .where(
          (reference) =>
              reference.reference2?.trim() ==
              ServerConstants.financialCovenantReference2,
        )
        .toList();

    if (showOnlyNonFinancialSubtypeItems) {
      return allItems
          .where(
            (reference) =>
                reference.reference2?.trim() ==
                ServerConstants.covenantTypeIdNonFinancial.toString(),
          )
          .toList();
    }

    final List<Reference> others = filteredByReference2
        .where(
          (reference) =>
              reference.id ==
              ServerConstants.covenantSubTypeId[CovenantSubType.other],
        )
        .toList();

    final List<Reference> nonOthers = filteredByReference2
        .where(
          (reference) =>
              reference.id !=
              ServerConstants.covenantSubTypeId[CovenantSubType.other],
        )
        .toList();

    return [...nonOthers, ...others];
  }

  ///filtered covenant types based on link financials statement
  List<Reference> getFilteredCovenantSubtypesByType() {
    final List<Reference> allItems =
        referenceData[ReferenceDataKeys.covenantSubtype] ?? [];

    final List<Reference> filtered = allItems
        .where(
          (reference) =>
              reference.reference2 == covenant?.covenantType?.toString(),
        )
        .toList();

    final List<Reference> others = filtered
        .where(
          (reference) =>
              reference.id ==
              ServerConstants.covenantSubTypeId[CovenantSubType.other],
        )
        .toList();

    final List<Reference> nonOthers = filtered
        .where(
          (reference) =>
              reference.id !=
              ServerConstants.covenantSubTypeId[CovenantSubType.other],
        )
        .toList();

    return [...nonOthers, ...others];
  }

  ///financial year end date sumbission
  void onFinancialYearEndSubmit(String? value) {
    covenant ??= Covenant();
    covenant!.financialYearEndDate = value;
    updateNextMonitoringDate();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  ///Time For Submission selection in dropdown
  void onTimeForSubmissionSelected(List<Reference> selectedReferences) {
    selectedTimeForSubmission = selectedReferences.first;
    covenant ??= Covenant();
    covenant?.timeForSubmition = selectedTimeForSubmission?.id;
    updateNextMonitoringDate();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Reference? _findSubmissionTimeById(int? id) {
    if (id == null) return null;
    final List<Reference> items =
        referenceData[ReferenceDataKeys.covenantSubmissionTime] ??
            const <Reference>[];
    final int submissionTimeById =
        items.indexWhere((reference) => reference.id == id);
    return submissionTimeById == -1 ? null : items[submissionTimeById];
  }

  DateTime? _calculateNextMonitoringAnchorDate({
    String? fyEndStr,
    String? submissionDaysStr,
  }) {
    if (fyEndStr == null || submissionDaysStr == null) return null;
    final int submissionDays = int.tryParse(submissionDaysStr) ?? 0;
    final List<String> parts = fyEndStr.split("/");
    if (parts.length != 2) return null;
    final int month = int.tryParse(parts[1]) ?? 1;
    final int year = DateTime.now().year;
    final DateTime lastDayOfMonth = DateTime(year, month + 1, 0);
    final DateTime calculatedDate =
        lastDayOfMonth.add(Duration(days: submissionDays));
    final DateTime fifteenth =
        DateTime(calculatedDate.year, calculatedDate.month, 15);
    final DateTime endOfMonth =
        DateTime(calculatedDate.year, calculatedDate.month + 1, 0);
    return (calculatedDate.day <= 15) ? fifteenth : endOfMonth;
  }

  void _updateRowNextMonitoringDate(Covenant row) {
    final String? fyEndStr = row.financialYearEndDate;
    final Reference? subRef = _findSubmissionTimeById(row.timeForSubmition);
    final String? submissionDaysStr = subRef?.name;
    final DateTime? nextMonitoringDate = _calculateNextMonitoringAnchorDate(
      fyEndStr: fyEndStr,
      submissionDaysStr: submissionDaysStr,
    );
    if (nextMonitoringDate != null) {
      row.nextMonitorDate = formatDateForRequest(nextMonitoringDate);
    }
  }

  void onRowTimeForSubmissionSelected(
    Covenant row,
    List<Reference> selectedReferences,
  ) {
    final Reference selected = selectedReferences.first;
    row.timeForSubmition = selected.id;
    _updateRowNextMonitoringDate(row);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onRowFinancialYearEndSubmit(Covenant row, String? value) {
    row.financialYearEndDate = value;
    _updateRowNextMonitoringDate(row);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onRowFrequencySelected(
    Covenant row,
    List<Reference> selectedReferences,
  ) {
    row.frequency = selectedReferences.first.id;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onFrequencySelected(List<Reference> selectedReferences) {
    selectedFrequency = selectedReferences.first;
    covenant?.frequency = selectedFrequency?.id;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  ///next monitor date in ui from api
  String formatApiDateForUi(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "";
    try {
      final DateTime date = DateTime.parse(dateStr); // expects yyyy-MM-dd
      return "${date.day.toString().padLeft(2, '0')}-"
          "${date.month.toString().padLeft(2, '0')}-"
          "${date.year.toString().padLeft(4, '0')}";
    } catch (_) {
      return dateStr; // fallback to original if parsing fails
    }
  }

  ///update next monitor date in ui
  ///updation based on financial year end
  ///and time for submission field inputs
  void updateNextMonitoringDate() {
    final DateTime? resultDate = getCalculatedNextMonitoringDateRaw();
    if (resultDate == null) return;

    covenant ??= Covenant();
    covenant!.nextMonitorDate = formatDateForRequest(resultDate); // for saving
    nextMonitoringDateController.text = formatDateForUI(resultDate); // for UI

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  ///next monitor date logic based on selected financial year end date
  /// and time for submission
  DateTime? getCalculatedNextMonitoringDateRaw() {
    final String? fyEndStr = covenant?.financialYearEndDate;
    final String? submissionDaysStr = selectedTimeForSubmission?.name;

    if (fyEndStr == null || submissionDaysStr == null) return null;

    final int submissionDays = int.tryParse(submissionDaysStr) ?? 0;
    final List<String> parts = fyEndStr.split("/");
    if (parts.length != 2) return null;

    final int month = int.tryParse(parts[1]) ?? 1;
    final int year = DateTime.now().year;

    final DateTime lastDayOfMonth = DateTime(year, month + 1, 0);
    final DateTime calculatedDate =
        lastDayOfMonth.add(Duration(days: submissionDays));

    final DateTime fifteenth =
        DateTime(calculatedDate.year, calculatedDate.month, 15);
    final DateTime endOfMonth =
        DateTime(calculatedDate.year, calculatedDate.month + 1, 0);

    return calculatedDate.day <= 15 ? fifteenth : endOfMonth;
  }

  //show formatted next monitor date in ui
  String formatDateForUI(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year.toString().padLeft(4, '0')}";
  }

  //formatted fetched next monitor date from api
  String formatDateForRequest(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  /// Updates the selected Covenant Type .
  void onCovenantTypeSelection(List<Reference> selectedReferences) {
    selectedCovenantType = selectedReferences.first;
    covenant?.covenantType = selectedCovenantType?.id;

    resetFieldsOnCovenantTypeChange();
    isFinancialStandard = true; //pawan
    emit(
      state.copyWith(
        addLinkFinancialView: false,
        addFinancialCovenat: false,
        financialViewCount: 0,
        loaderStatus: LoadingStatus.loaded,
      ),
    );
  }

  /// Updates the Customer Name type.
  void onCustomerSelection(Customer selectedValue) {
    selectedCustomer = selectedValue;
    covenant ??= Covenant();
    covenant!
      ..customerName = selectedValue.customerName ?? selectedValue.displayName
      ..rimNo = selectedValue.customerRimNo;
  }

  /// Updates the selected Customer Rim in field
  void onCustomerRimSelection(Customer selectedValue) {
    selectedCustomerRim = selectedValue;

    // Ensure name is present for payload (custName)
    final String? name =
        (selectedCustomerRim?.customerName?.trim().isNotEmpty ?? false)
            ? selectedCustomerRim!.customerName
            : (selectedCustomerRim?.displayName?.trim().isNotEmpty ?? false)
                ? selectedCustomerRim!.displayName
                : selectedCustomerRim?.groupName;

    // Mutate only the needed field (minimal change)
    selectedCustomerRim?.customerName = name;
  }

  ///get application details from api
  Future<void> getApplicationDetails() async {
    try {
      applicationDetails =
          await CustomerRepository.instance.getApplicationDetails();
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
      rethrow;
    }
  }

  /// on general or Specific field selection changed
  Future<void> onGeneralFieldChanged(
    Reference selectedValue,
    BuildContext context,
  ) async {
    generalField = selectedValue;
    covenant?.isGeneric = selectedValue.id == ServerConstants.covenantGeneralId;
    if (isSpecificSelected()) {
      final dynamic data = await DialogHelper.showCustomDialog(
        barrierDismissible: false,
        title: "covenantsConditions.conditionsEditDialog.selectFacilities".tr(),
        content: SelectFacilitiesDialogView(
          selectedFacility: facilityList,
          isLinakage: false,
          isSecuritySummary: false,
          preselectedAllFacilities: selectedAllFacilitiesYesNo,
          isCovenant: true,
        ),
        context: context,
      );
      if (data != null) {
        await setFacility(data);
      }
    } else {
      Future.delayed(
        const Duration(milliseconds: 300),
        () {
          emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        },
      );
    }
  }

  List<Reference> getSelectedGeneralForRow(Covenant row) {
    // If row.isGeneric is null => no pre-selection
    if (row.isGeneric == null) return const <Reference>[];

    final List<Reference> items =
        referenceData[ReferenceDataKeys.covenantGeneralSpecific] ?? [];
    final int targetId = (row.isGeneric == true)
        ? ServerConstants.covenantGeneralId
        : ServerConstants.covenantSpecificId;

    final int index = items.indexWhere((reference) => reference.id == targetId);
    return (index == -1) ? const <Reference>[] : <Reference>[items[index]];
  }

  Future<void> onLinkedGeneralFieldChanged(
    Covenant row,
    Reference selectedValue,
    BuildContext context,
  ) async {
    // Set isGeneric based on selection
    row.isGeneric = (selectedValue.id == ServerConstants.covenantGeneralId);

    if (row.isGeneric == false) {
      // Specific selected: open facilities dialog per row
      final dynamic data = await DialogHelper.showCustomDialog(
        barrierDismissible: false,
        title: "covenantsConditions.conditionsEditDialog.selectFacilities".tr(),
        content: SelectFacilitiesDialogView(
          selectedFacility: row.facilityDetailList ?? const <Facility>[],
          isLinakage: false,
          isSecuritySummary: false,
          preselectedAllFacilities: getRowAllFacilitiesRef(row),
          isCovenant: true, // NEW
        ),
        context: context,
      );

      if (data != null) {
        setRowFacility(row, data);
      }
    } else {
      // General: clear row facility list
      row.facilityDetailList = <Facility>[];
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> setFacility(data) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    if (data == null) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return;
    }
    if (data is List<Facility>) {
      facilityList = data;
    } else if (data is Map) {
      // Preferred new format from dialog
      final List<Facility> selectedFacilities =
          data["selectedFacilities"] as List<Facility>? ?? const [];
      final Reference? allRef = data["allFacilitiesOption"] as Reference?;
      facilityList = selectedFacilities;
      selectedAllFacilitiesYesNo = allRef; // persist desktop radio
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void setRowFacility(Covenant row, dynamic data) {
    if (data == null) return;
    if (data is List<Facility>) {
      setRowFacilitiesAndOption(row, data, null);
    } else if (data is Map) {
      final List<Facility> selectedFacilities =
          data["selectedFacilities"] as List<Facility>? ?? const [];
      final Reference? allRef = data["allFacilitiesOption"] as Reference?;
      setRowFacilitiesAndOption(row, selectedFacilities, allRef);
    }
  }

  List<Reference>? getActionvalues() {
    return referenceData[ReferenceDataKeys.conditionAction]
        ?.where(
          (element) => element.id != ServerConstants.conditionActionCreateId,
        )
        .toList();
  }

  /// Handles Covenant Period type change.
  void onCovenantPeriodSelect(List<Reference> selectedReferences) {
    selectedPeriod = selectedReferences.first;
    covenant?.periodTerm = selectedPeriod?.id;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles covenant test type change.
  void onCovenantTestChanged(CovenantTestType? value) {
    selectedTestType = value;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles covenant test type change.
  void onInternalFinancialCovenantChanged(
    InternalFinancialCovenantType? value,
  ) {
    selectedInternalFinancialType = value;
    covenant?.isInternalFinancial =
        (value == InternalFinancialCovenantType.yes);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles subtype selection and UI updates.
  void onSubtypeSelection(List<Reference> selectedValue) {
    selectedSubTypeValue = selectedValue.first;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles subtype selection and UI updates.
  void onFinancialCovenantSubtypeSelection(List<Reference> selectedValue) {
    financialCovenantSubtypeSelection = selectedValue.first;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Searches for a customer by RIM number.
  Future<void> onRimSearch() async {
    if (rimNoSearch.trim().isEmpty) {
      return;
    }
    emit(state.copyWith(searchLoaderStatus: LoadingStatus.loading));
    try {
      searchedCustomer = await CustomerRepository.instance
          .searchUserDetails(rimNoSearch, "", "", "");

      emit(state.copyWith(searchLoaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(searchLoaderStatus: LoadingStatus.error));
    }
  }

  /// Handles UI update when the add button is pressed.
  void onAddButtonPress() {
    showAddWidgets = true;
    emit(state.copyWith(showAddWidgets: !state.showAddWidgets));
  }

  /// Handles cancellation of adding a test user.
  void onCancelPress() {
    showAddWidgets = false;
    emit(state.copyWith(showAddWidgets: false));
  }

  /// Converts a timestamp into a formatted date string (Dubai timezone).
  /// - A formatted date string or an empty string if `timestamp` is null.
  String getTimeAsString(String? isoDateString) {
    if (isoDateString == null || isoDateString.isEmpty) {
      return "";
    }
    try {
      final DateTime dateTime = DateTime.parse(isoDateString);
      return DateFormat("dd/MM").format(dateTime);
    } catch (e) {
      return "";
    }
  }

  /// - A formatted date string or an empty string if `timestamp` is n
  /// parse Financial Year End Date
  DateTime? parseFinancialYearEndDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;

    final int currentYear = DateTime.now().year;
    try {
      final List<String> parts = dateStr.split("/");
      if (parts.length == 2) {
        final int? day = int.tryParse(parts[0]);
        final int? month = int.tryParse(parts[1]);
        if (day != null && month != null) {
          return DateTime(currentYear, month, day);
        }
      }
    } catch (_) {}
    try {
      final DateTime date = DateFormat("MMMd").parseStrict(dateStr);
      return DateTime(currentYear, date.month, date.day);
    } catch (_) {}

    try {
      final DateTime date = DateFormat("MMMMd").parseStrict(dateStr);
      return DateTime(currentYear, date.month, date.day);
    } catch (_) {}

    return null;
  }

  /// Saves the covenant condition details.
  /// If successful, displays a success toast and updates the loader status.
  /// - `true` if the save is successful, otherwise `false`.
  ///  Validate form only if isRequiredBusinessSegment is required
  Future<bool> onSavePress() async {
    try {
      if (isRequiredBusinessSegment) {
        final bool isValid = formKey.currentState?.validate() ?? false;
        if (!isValid) return false;
      }

      if (covenant?.covenantType == ServerConstants.covenantTypeIdFinancial ||
          covenant?.covenantType ==
              ServerConstants.covenantTypeIdNonFinancial ||
          isLinkFinancialView ||
          isFinancialCovenantView) {
        final String descText = financialDescriptionController.text;
        final bool hasBrackets =
            descText.contains("[") && descText.contains("]");
        final String bracketRaw = getBracketRawValue(descText);
        if (hasBrackets && bracketRaw.isEmpty) {
          AlertManager().showFailureToast(
            "covenantsConditions.covenantEditDialog.requiredTresholdValue".tr(),
          );
          return false;
        }
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      formKey.currentState?.save();
      updateFinancialIsStandardFromSelection();
      updateGeneralIsStandardFromSelection();
      final List<Map<String, dynamic>> covenantJsonList = [];
      covenant ??= Covenant();
      // - RIM: keep the existing behavior
      // - NAME: send only the typed name with rimNo = null
      List<Customer> borrowerList;
      if (selectedTestType == CovenantTestType.rim) {
        borrowerList = selectedCustomerRim != null
            ? [selectedCustomerRim!]
            : (selectedCustomer != null ? [selectedCustomer!] : []);
      } else {
        final String enteredBorrowerName = nameController.text.trim();

        // When saving an EXISTING covenant in "Name" mode, always send 9999.
        // For a NEW covenant in "Name" mode, send 0 (first-time behavior).
        final bool isExistingCovenant = !isNewCovenant;

        // Also true for covenants that originally came with 9999 in payload.
        final bool payloadCameWithNameModeBorrower = covenant?.borrowers?.any(
              (borrower) =>
                  borrower.customerRimNo ==
                  ServerConstants.covenantToBeTestedName,
            ) ??
            false;

        final int borrowerNameModeRimNo =
            (isExistingCovenant || payloadCameWithNameModeBorrower)
                ? ServerConstants.covenantToBeTestedName
                : 0;

        borrowerList = [
          Customer(
            customerRimNo: borrowerNameModeRimNo, // rimNo -> null in payload
            customerName: enteredBorrowerName, // custName -> typed name
          ),
        ];
      }

      if (borrowerList.isEmpty) {
        if (isRequiredBusinessSegment) {
          emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
          return false;
        } else {
          return true;
        }
      }

      covenant!.borrowers = borrowerList;
      if (isStandardSelected && !isFinancialStandard! && isLinkFinancialView) {
        covenant?.description = selectedGeneralCovenantSubType?.name;
      }

      covenant?.isCovenant = true;
      covenant?.facilityDetailList = facilityList;

      final int? generalSubTypeId = selectedGeneralCovenantSubType?.id;
      final int? financialSubTypeId = selectedFinancialCovenantSubType?.id;
      final int? originalThresholdType = covenant?.thresholdType;
      final bool isFinancial =
          selectedCovenantTypeEnum == CovenantType.financial;
      if (isFinancial) {
        covenant?.covenantSubType = financialSubTypeId;
        final String finText = financialDescriptionController.text.trim();
        if (finText.isNotEmpty &&
            !isLinkFinancialView &&
            !isFinancialCovenantView) {
          covenant?.description = " $finText";
        }
      } else {
        if (covenant?.description?.trim().isEmpty ?? true) {
          covenant?.description = selectedGeneralCovenantSubType?.name;
        }
        covenant?.covenantSubType = generalSubTypeId;
      }

      //If New Covenant
      if (isNewCovenant) {
        covenant?.isNew = true;
        if (generalSubTypeId ==
            ServerConstants.covenantSubTypeIdForFrequencyFilter) {}
        covenant?.borrowers = borrowerList;

        if (generalSubTypeId ==
                ServerConstants.covenantSubTypeIdForFrequencyFilter &&
            isLinkFinancialView) {
          covenant?.thresholdType = null;
          covenant?.description = selectedGeneralCovenantSubType?.name;
        }

        if (generalSubTypeId != null) {
          covenant?.covenantSubType = generalSubTypeId;
        }
        if (covenant?.covenantType == 11145) {
          covenant?.covenantSubType = selectedFinancialCovenantSubType?.id;
        }
        final Map<String, dynamic>? newJson = covenant?.toSaveNewJson();
        if (newJson != null) {
          covenantJsonList.add(newJson);
        }
      } else {
        //If existing Covenant
        covenant?.isNew = false;
        covenant?.isDeleted = false;
        covenant?.appRefNum = Globals.request?.applicationRefNo;
        if (generalSubTypeId ==
                ServerConstants.covenantSubTypeIdForFrequencyFilter &&
            isLinkFinancialView) {
          covenant?.thresholdType = null;
        }
        if (covenant?.covenantType ==
            ServerConstants.covenantTypeIdInformation) {
          if (generalSubTypeId != null) {
            covenant?.covenantSubType = generalSubTypeId;
          }
        }
        if (covenant?.covenantType == 11145) {
          covenant?.covenantSubType = selectedFinancialCovenantSubType?.id;
        }
        final Map<String, dynamic>? editJson = covenant?.toSaveJson();
        if (editJson != null) {
          covenantJsonList.add(editJson);
        }
      }
      covenant?.thresholdType = originalThresholdType;

      if (isLinkFinancialView && linkedFinancialCovenants.isNotEmpty) {
        for (final Covenant row in linkedFinancialCovenants) {
          // Keep the row’s own choices
          final int? rowSubtype = row.covenantSubType;
          final int? rowThresholdType = row.thresholdType;
          final String? rowDescription = row.description;
          final bool? rowIsStandard = row.isStandard;

          // copy base fields from desktop (same as before)
          row
            ..linkFinancialCovenant(covenant!)
            ..covenantType =
                ServerConstants.covenantTypeId[CovenantType.financial]
            ..rimNo = selectedCustomer?.customerRimNo
            ..isStandard = rowIsStandard ?? true
            ..covenantSubType = rowSubtype
            ..thresholdType = rowThresholdType
            ..description = (rowDescription ?? "").trim();

          // If standard & empty description but subtype chosen → build template
          if ((row.isStandard ?? true) &&
              (row.description?.isEmpty ?? true) &&
              row.covenantSubType != null) {
            final Reference? ref = covenantSubType?.firstWhere(
              (reference) => reference.id == row.covenantSubType,
              orElse: Reference.new,
            );

            final String name = (ref?.name ?? "").trim();
            final String template =
                getDescriptionTemplateForSubtype(row.covenantSubType);
            final bool prefix = row.covenantSubType != 11141 &&
                row.covenantSubType != 11142 &&
                name.isNotEmpty;
            row.description = (prefix ? "$name $template" : template)
                .replaceAll("{value}", "");
          }

          // finalize flags, collect
          row
            ..isNew = true
            ..isDeleted = false;
          final Map<String, dynamic> json = row.toSaveNewJson();
          covenantJsonList.add(json);
        }
      }

      if (isFinancialCovenantView && financialCovenantSubtypes.isNotEmpty) {
        for (final Covenant row in financialCovenantSubtypes) {
          //Capture the row's own values (in case linkFinancialCovenant copies
          //again)
          final int? rowSubtype = row.covenantSubType;
          final int? rowThresholdType = row.thresholdType;
          final String? rowDescription = row.description;
          final bool? rowIsStandard = row.isStandard;

          // link (copies base fields)
          row
            ..linkFinancialCovenant(covenant!)
            ..covenantType =
                ServerConstants.covenantTypeId[CovenantType.financial];

          // Always take RIM from the header covenant (fallback to selections if
          // needed)
          final int? baseRim = covenant?.rimNo ??
              selectedCustomerRim?.customerRimNo ??
              selectedCustomer?.customerRimNo;

          row
            ..rimNo = baseRim
            ..isStandard =
                rowIsStandard ?? true // default to standard for safety
            ..covenantSubType = rowSubtype // keep row selection
            ..thresholdType = rowThresholdType // keep row mapping/manual
            ..description = (rowDescription ?? "")
                .trim(); // use row text (from AddFinancialDescriptionView)

          // if you want to enforce a non-empty standard template when row is
          // std & description empty:
          if ((row.isStandard ?? true) &&
              (row.description?.isEmpty ?? true) &&
              row.covenantSubType != null) {
            final Reference? reference = covenantSubType?.firstWhere(
              (reference) => reference.id == row.covenantSubType,
              orElse: Reference.new,
            );
            final String name = (reference?.name ?? "").trim();
            final String template =
                getDescriptionTemplateForSubtype(row.covenantSubType);
            final bool prefix = row.covenantSubType != 11141 &&
                row.covenantSubType != 11142 &&
                name.isNotEmpty;
            row.description = (prefix ? "$name $template" : template)
                .replaceAll("{value}", "");
          }

          // finalize flags
          row
            ..isNew = true
            ..isDeleted = false;

          final Map<String, dynamic> json = row.toSaveNewJson();
          covenantJsonList.add(json);
        }
      }

      await repository.saveCovenantDetails(covenantJsonList, isCovenant);
      AlertManager().showSuccessToast(
        "covenantsConditions.conditionsEditDialog.savedSuccefully".tr(),
      );
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return true;
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return false;
    }
  }

  // // link financial view data updated as per click in dialog
  void addLinkFinancialView() {
    isLinkFinancialView = true;

    final Reference? financialTypeRef =
        referenceData[ReferenceDataKeys.covenantType]?.firstWhere(
      (reference) =>
          reference.id ==
          ServerConstants.covenantTypeId[CovenantType.financial],
    );

    final List<Reference> subtypeList =
        referenceData[ReferenceDataKeys.covenantSubtype] ?? [];

    final List<dynamic> matchingSubtypes = financialTypeRef != null
        ? subtypeList
            .where(
              (reference) =>
                  reference.reference2?.trim() ==
                  financialTypeRef.id.toString(),
            )
            .toList()
        : [];
    if (matchingSubtypes.isNotEmpty) {
      selectedLinkFinancialCovenantSubType = matchingSubtypes.first;
    }

    final int? baseRim = covenant?.rimNo ??
        selectedCustomerRim?.customerRimNo ??
        selectedCustomer?.customerRimNo;

    final Covenant linkedCovenant = Covenant()
      ..isNew = true
      ..isDeleted = false
      ..rimNo = baseRim
      ..borrowers = Globals.request?.customers ?? []
      ..isStandard = true
      ..isInternalFinancial = true
      ..covenantSubType = null
      ..thresholdType = null
      ..description = null;

    linkedFinancialCovenants.add(linkedCovenant);

    if (financialTypeRef != null) {
      selectedLinkFinancialCovenantType = financialTypeRef;
    }

    emit(
      state.copyWith(
        addLinkFinancialView: true,
        financialViewCount: linkedFinancialCovenants.length,
      ),
    );
  }

  ///delete created covenant from covenant dialog
  void deleteLinkedCovenant(Covenant covenant) {
    financialDescriptionController.clear();
    linkedFinancialCovenants.remove(covenant);

    emit(
      state.copyWith(
        addLinkFinancialView: linkedFinancialCovenants.isNotEmpty,
        financialViewCount: linkedFinancialCovenants.length,
      ),
    );
  }

  void onRowFinancialCovenantSubTypeSelect(
    Covenant row,
    List<Reference> selectedReferences,
  ) {
    final Reference selected = selectedReferences.first;
    row.covenantSubType = selected.id;

    final Reference? matched = getThresholdTypeForCovenantSubtype(selected.id);
    row.thresholdType = matched?.id; // stays null if no match

    final int id = selected.id ?? 0;
    final String template = getDescriptionTemplateForSubtype(id);
    final String subName = (selected.name ?? "").trim();
    final bool prefix = id != 11141 && id != 11142 && subName.isNotEmpty;

    row.description =
        (prefix ? "$subName $template" : template).replaceAll("{value}", "");
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void addFinancialCovenatSubtypeView() {
    isFinancialCovenantView = true;

    final Covenant newSubtype = Covenant()
      ..isNew = true
      ..isDeleted = false
      ..rimNo =
          selectedCustomer?.customerRimNo ?? selectedCustomer?.customerRimNo
      ..borrowers = Globals.request?.customers ?? []
      ..linkFinancialCovenant(covenant!)
      ..isStandard = true
      ..covenantSubType = null
      ..thresholdType = null
      ..isInternalFinancial = true
      ..description = null
      ..timeForSubmition = null
      ..frequency = null
      ..financialYearEndDate = null
      ..nextMonitorDate = null
      ..isGeneric = null
      ..facilityDetailList = <Facility>[];

    financialCovenantSubtypes.add(newSubtype);
    emit(state.copyWith(addFinancialCovenat: true));
  }

  ///delete financial covenant type view
  void deleteFinancialCovenat(int index) {
    if (index >= 0 && index < financialCovenantSubtypes.length) {
      financialCovenantSubtypes.removeAt(index);
      emit(
        state.copyWith(
          addFinancialCovenat: financialCovenantSubtypes.isNotEmpty,
        ),
      );
    }
  }

  //refershed fields when covenant type changes
  void resetFieldsOnCovenantTypeChange() {
    final Reference defaultRef = Reference(name: "common.selectValue".tr());
    selectedGeneralCovenantSubType = defaultRef;
    selectedFinancialCovenantSubType = defaultRef;
    selectedPeriod = defaultRef;
    selectedFrequency = defaultRef;
    selectedAction = defaultRef;
    selectedThreshold = defaultRef;
    selectedTimeForSubmission = defaultRef;
    generalField = defaultRef;
    selectedAuditStatus = null;
    selectedBasisOfPreperation = null;
    financialDescriptionController.clear();
    // Reset date fields
    covenant?.financialYearEndDate = null;
    covenant?.nextMonitorDate = null;
    nextMonitoringDateController.text = "";
    // Reset text fields and controllers
    covenant?.entityName = null;
    state.entityName = null;
    entityNameController.text = "";
    covenant?.creditLensId = null;
    creditLensController.text = "";
    // Reset flags
    covenant?.isStandard = true;
    covenant?.isInternalFinancial = true;
    selectedInternalFinancialType = InternalFinancialCovenantType.yes;

    isStandardCovenantSelected = null;
    isFinancialStandard = null;
    selectedCustomerRim = null;

    selectedDescriptionTypeId = null;
    selectedFinancialDescriptionTypeId = null;

    linkedFinancialCovenants.clear();
    financialCovenantSubtypes.clear();
    isLinkFinancialView = false;
    isFinancialCovenantView = false;
    isLinkFinancialSubtypeEnabled = true;
    covenant?.description = "";
    nameController.clear();
    selectedTestType = CovenantTestType.rim;
    selectedCustomerRim = null;
  }
}
