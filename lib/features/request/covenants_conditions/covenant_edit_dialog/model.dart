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

/// Covenant test type.
enum CovenantTestType {
  ///
  rim,

  ///
  name,
}

/// Internal financial covenant type.
enum InternalFinancialCovenantType {
  ///
  yes,

  ///
  no,
}

/// View model for the covenant edit dialog.
class CovenantEditDialogViewModel extends SafeCubit<CovenantEditDialogState> {
  /// Creates a covenant edit dialog view model.
  CovenantEditDialogViewModel(
    this.covenant, {
    this.isNew,
  }) : super(
          CovenantEditDialogState(loaderStatus: LoadingStatus.loading),
        );

  /// Covenant data.
  Covenant? covenant;

  /// Indicates whether the covenant is new.
  bool? isNew;

  /// Override page mode.
  PageMode? overridePageMode;

  /// Covenant condition repository.
  late CovenantConditionRepository repository;

  /// Form key.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Reference data map.
  Map<String, List<Reference>> referenceData = {};

  /// Selected covenant test type.
  CovenantTestType? selectedTestType = CovenantTestType.rim;

  /// Selected internal financial covenant type.
  InternalFinancialCovenantType? selectedInternalFinancialType =
      InternalFinancialCovenantType.yes;

  /// Selected customer RIM.
  Customer? selectedCustomerRim;

  /// Application details.
  ApplicationDetails? applicationDetails;

  /// Financial covenant subtype selection.
  Reference? financialCovenantSubtypeSelection;

  //fields to show data on ui

  /// Selected covenant type.
  Reference? selectedCovenantType;

  /// Selected covenant subtype.
  Reference? selectedCovenantSubType;

  /// Selected period.
  Reference? selectedPeriod;

  /// Selected frequency.
  Reference? selectedFrequency;

  /// Selected action.
  Reference? selectedAction;

  /// Selected threshold.
  Reference? selectedThreshold;

  /// Threshold type.
  Reference? thresholdType;

  /// Selected status.
  Reference? selectedStatus;

  /// Selected basis of preparation.
  Reference? selectedBasisOfPreperation;

  /// Selected time for submission.
  Reference? selectedTimeForSubmission;

  /// Selected audit status.
  Reference? selectedAuditStatus;

  /// General or specific field.
  Reference? generalField;

  //link financial view fields

  /// Selected linked financial covenant type.
  Reference? selectedLinkFinancialCovenantType;

  /// Selected linked financial covenant subtype.
  Reference? selectedLinkFinancialCovenantSubType;

  /// Selected subtype value.
  Reference? selectedSubTypeValue;

  /// Selected customer.
  Customer? selectedCustomer;

  /// Searched customer.
  Customer? searchedCustomer;

  /// Indicates whether add widgets are shown.
  bool showAddWidgets = false;

  /// Covenant indicator.
  int? isCovenant = 1;

  //reference values

  /// Covenant type reference values.
  List<Reference>? covenantType = [];

  /// Covenant subtype reference values.
  List<Reference>? covenantSubType = [];

  /// Covenant period reference values.
  List<Reference>? covenantPeriod = [];

  /// Covenant submission time reference values.
  List<Reference>? covenantSubmissionTime = [];

  /// Covenant basis of preparation reference values.
  List<Reference>? covenantBasisOfPreparation = [];

  /// Covenant audit status reference values.
  List<Reference>? covenantAuditStatus = [];

  /// Covenant status reference values.
  List<Reference>? covenantStatus = [];

  /// Covenant threshold type reference values.
  List<Reference>? covenanttThresholdType = [];

  /// Description type reference values.
  List<Reference> descriptionTypes = [];

  /// Next monitoring date controller.
  final TextEditingController nextMonitoringDateController =
      TextEditingController();

  /// Credit lens controller.
  final TextEditingController creditLensController = TextEditingController();

  /// Entity name controller.
  final TextEditingController entityNameController = TextEditingController();

  /// Name controller.
  final TextEditingController nameController = TextEditingController();

  /// Selected financial covenant subtype.
  Reference? selectedFinancialCovenantSubType;

  /// Selected general covenant subtype.
  Reference? selectedGeneralCovenantSubType;

  /// Page mode.
  PageMode pageMode = PageMode.na;

  /// Indicates whether the dialog is read-only.
  bool get isReadOnly => pageMode == PageMode.view;

  /// Covenant edit page mode.
  PageMode? covenantEditPageMode;

  /// Indicates whether the dialog can be edited.
  bool get canEdit => covenantEditPageMode == PageMode.edit;

  /// Checks if the covenant is being updated.
  bool isUpdateCovenant() => covenant != null;

  /// Indicates whether financial covenant description is enabled.
  bool isFinancialCovenantDescription = true;

  /// Selected all facilities yes/no value.
  Reference? selectedAllFacilitiesYesNo;

  // Row radio selection, keyed by a stable row identity

  /// Row level all facilities yes/no values.
  final Map<int, Reference?> rowAllFacilitiesYesNo = {};

  /// Returns all facilities option for the row.
  Reference? getRowAllFacilitiesRef(Covenant row) =>
      rowAllFacilitiesYesNo[identityHashCode(row)];

  /// Checks whether specific is selected.
  bool isSpecificSelected() =>
      ServerConstants.covenantSpecificId == generalField?.id;

  /// Indicates whether the current business segment requires fields.
  bool get isRequiredBusinessSegment =>
      Utils.checkBusinessSegment(BusinessSegment.corporate);

  /// Selected covenant type enum.
  CovenantType get selectedCovenantTypeEnum =>
      CovenantTypeHelper.fromId(selectedCovenantType?.id);

  /// Selected covenant subtype enum.
  CovenantSubType? get selectedSubTypeValueEnum =>
      CovenantSubTypeHelper.fromId(selectedCovenantSubType?.id);

  /// Selected general covenant subtype enum.
  CovenantSubType? get selectedSubGeneralTypeValueEnum =>
      CovenantSubTypeHelper.fromId(selectedGeneralCovenantSubType?.id);

  /// Selected financial covenant subtype enum.
  CovenantSubType? get selectedSubFinancialTypeValueEnum =>
      CovenantSubTypeHelper.fromId(selectedFinancialCovenantSubType?.id);

  //add rim variables

  /// RIM number search text.
  String rimNoSearch = "";

  /// Customer name controller.
  final TextEditingController customerNameController = TextEditingController();

  /// When true, linked financial rows are shown under
  /// Information + Financial Statements = financial covenants.
  bool isLinkFinancialView = false;

  /// When true, dynamically added financial subtype rows are shown
  /// in the financial covenant flow
  bool isFinancialCovenantView = false;

  /// Financial covenant subtype rows.
  List<Covenant> financialCovenantSubtypes = [];

  /// Linked financial covenant rows.
  List<Covenant> linkedFinancialCovenants = [];

  /// Indicates whether this is a new covenant.
  bool isNewCovenant = false;

  //covenant description

  /// Selected description type id.
  int? selectedDescriptionTypeId;

  /// Selected description type.
  String? selectedDescriptionType;

  /// Selected financial description type id.
  int? selectedFinancialDescriptionTypeId;

  /// Selected financial description type.
  String? selectedFinancialDescriptionType;

  /// Indicates whether the currently selected financial description type
  /// uses the standard template-based mode or the custom free-text mode.
  bool? isFinancialStandard = true;

  /// Indicates whether standard covenant is selected.
  bool? isStandardCovenantSelected;

  /// Temporary UI-only custom text holder used by linked financial row flows.
  /// Prefer row.description as the payload source of truth
  String? customLinkFinancialDescription;

  /// Custom add CS financial description.
  String? customAddCSFinancialDescription;

  /// Indicates whether standard description is selected.
  bool get isStandardSelected =>
      selectedDescriptionTypeId == ServerConstants.standardDescriptionId;

  /// Indicates whether financial subtype is enabled.
  bool get isFinancialSubtypeEnabled =>
      selectedFinancialDescriptionTypeId ==
      ServerConstants.standardDescriptionId;

  /// Indicates whether linked financial subtype is enabled.
  bool isLinkFinancialSubtypeEnabled = true;

  /// Financial description controller.
  TextEditingController financialDescriptionController =
      TextEditingController();

  /// Customer list.
  List<Customer>? customersList = [];

  /// Facility list.
  List<Facility> facilityList = [];

  /// Captures the content inside the first bracket pair: [ ...]
  final RegExp _firstBracketContentRegex = RegExp(r"\[(.*?)\]");
  final RegExp _digitCharacterRegex = RegExp("[0-9]");
  final String _leftBracketTemplatePadding = "";
  final String _rightBracketTemplatePadding = "";
  final RegExp _nonAlphanumericOrSpaceRegex = RegExp("[^A-Za-z0-9 ]");

  /// Removes any character that is not allowed in a financial bracket value.
  ///
  /// Financial bracket values support:
  /// - digits
  /// - a single decimal point
  ///
  /// Final normalization, single-decimal enforcement, and length clamping are
  /// handled by [_sanitizeFinancialBracketNumber]
  final RegExp _nonFinancialNumberCharacterRegex = RegExp("[^0-9.]");

  /// Maximum number of digits allowed before the decimal point for financial
  /// covenant bracket values.
  static const int _financialIntegerMaxDigits = 16;

  /// Maximum number of digits allowed after the decimal point for financial
  /// covenant bracket values
  static const int _financialDecimalMaxDigits = 2;

  /// Indicates whether non-financial bracket input mode is enabled.
  bool get isNonFinancialBracketInputMode =>
      selectedCovenantTypeEnum == CovenantType.nonFinancial;

  /// Indicates whether financial description is being updated.
  bool isUpdatingFinancialDescription = false;

  /// Indicates whether only non-financial subtype items should be shown.
  bool showOnlyNonFinancialSubtypeItems = false;

  /// Indicates whether description is read-only.
  bool isDescriptionReadOnly = false;

  static const String _defaultEditableActionStatus =
      ServerConstants.defaultNewStatus;

  // Frozen for this dialog session based on the response used to open it
  bool _allowActionEditing = false;

  // Final gate for UI

  /// Indicates whether status/action can be edited.
  bool get canEditStatusAction => _allowActionEditing && canEdit;

  /// Indicates whether the application is cancellation.
  bool get isCancellationApp =>
      Utils.checkApplicationType(ApplicationType.cancellation);

  // Allow comment edit only for Cancellation apps
  // when the application is editable
  // for the current user (assigned + active task),
  // AND the screen is at least visible.

  /// Indicates whether comments can be edited.
  bool get canEditComments =>
      isCancellationApp &&
      Utils.canEditApplication() &&
      covenantEditPageMode != PageMode.na;

  //get covenant subytypes conditional based on selected covenant type

  /// Covenant subtype dropdown items.
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

  /// Selected subtype items.
  List<Reference> get selectedSubTypeItems {
    if (selectedGeneralCovenantSubType != null) {
      return [selectedGeneralCovenantSubType!];
    } else {
      return [];
    }
  }

  // get filtered frequecy based on covenant type and subtype

  /// Filtered frequency values.
  List<Reference> get filteredFrequencies {
    final List<Reference> originalItems =
        referenceData[ReferenceDataKeys.covenantFrequency] ?? [];

    final bool shouldFilter = covenant?.covenantSubType ==
            ServerConstants.covenantSubTypeIdForFrequencyFilter ||
        selectedCovenantTypeEnum == CovenantType.nonFinancial ||
        selectedCovenantTypeEnum == CovenantType.financial;

    if (!shouldFilter) {
      return originalItems;
    }

    return originalItems
        .where(
          (item) => !ServerConstants.excludedFrequencyIds.contains(item.id),
        )
        .toList();
  }

  /// Indicates whether description text area should be shown.
  bool get shouldShowDescriptionTextArea {
    return selectedDescriptionTypeId == ServerConstants.customDescriptionId ||
        (selectedCovenantTypeEnum == CovenantType.information &&
            selectedGeneralCovenantSubType != null &&
            selectedSubGeneralTypeValueEnum == CovenantSubType.other);
  }

  /// Count of financial subtypes with reference2 11144.
  int get countFinancialSubtypesR11144 =>
      (referenceData[ReferenceDataKeys.covenantSubtype] ?? const <Reference>[])
          .where(
            (ref) =>
                ref.reference2?.trim() ==
                ServerConstants.financialCovenantReference2,
          )
          .length;

  /// Indicates whether threshold type is required.
  bool get isThresholdTypeRequired => countFinancialSubtypesR11144 > 10;

  /// Customer list.
  List<Customer>? customerList = [];

  int get _financialSubtypeCount {
    final List<Reference> allItems =
        referenceData[ReferenceDataKeys.covenantSubtype] ?? const <Reference>[];
    final String finRef2 = ServerConstants.financialCovenantReference2.trim();
    return allItems
        .where((value) => (value.reference2 ?? "").trim() == finRef2)
        .length;
  }

  /// Indicates whether threshold type text field is required.
  bool get isThresholdTypeTextFieldRequired {
    if (_financialSubtypeCount <= 10) {
      return false;
    }
    final int? selectedId =
        selectedFinancialCovenantSubType?.id ?? covenant?.covenantSubType;
    if (selectedId == null) {
      return false;
    }
    return !ServerConstants.initialFinancialSubtypeIds.contains(selectedId);
  }

  /// Custom threshold type value.
  String? thresholdTypeCustomValue;

  /// True when the main financial covenant is in Custom description mode.
  bool get isCustomFinancialDescriptionSelected =>
      selectedFinancialDescriptionTypeId == ServerConstants.customDescriptionId;

  /// For the main financial covenant:
  /// Threshold Type must be enabled either
  /// - when custom description is selected, OR
  /// - when current standard subtype rules say it is editable.
  bool get shouldEnableMainThresholdType =>
      isCustomFinancialDescriptionSelected || isDesktopThresholdEditable;

  /// For the main financial covenant:
  /// Threshold Type is mandatory either
  /// - when custom description is selected, OR
  /// - when current >10 subtype regime requires it.
  bool get shouldRequireMainThresholdType =>
      isCustomFinancialDescriptionSelected || isThresholdTypeTextFieldRequired;

  /// Row-level helper: custom description mode for any added financial row.
  bool isCustomRowDescriptionSelected(Covenant row) =>
      !(row.isStandard ?? true);

  /// Row-level Threshold Type enablement:
  /// enable for custom rows always,
  /// otherwise use existing subtype-based rule.
  bool shouldEnableRowThresholdType(Covenant row) =>
      isCustomRowDescriptionSelected(row) || isRowThresholdEditable(row);

  /// Row-level Threshold Type mandatory:
  /// custom row => mandatory
  /// standard row => keep current subtype regime logic.
  bool shouldRequireRowThresholdType(Covenant row) =>
      isCustomRowDescriptionSelected(row) ||
      isThresholdTypeTextFieldRequiredFor(row.covenantSubType);

  /// Initializes the view model.
  /// Sets up the repository, loads reference data, and pre-fills covenant
  /// details if available.
  /// [context] - The BuildContext for UI updates.
  /// [covenantData] - The existing covenant condition, if provided.
  Future<void> init(
    BuildContext? context,
    PageMode? overridePageMode, {
    required bool? isNew,
    Covenant? covenantData,
  }) async {
    covenantEditPageMode = overridePageMode ??
        AuthRepository.getPageMode(RightConstants.covenantsUpdate);
    repository = CovenantConditionRepository.instance;
    await loadReferenceData();
    await getChildRimsForGroup();
    customersList = [...(Globals.request?.customers ?? <Customer>[])];
    isNewCovenant = isNew ?? false;
    if (covenantData != null) {
      covenant = covenantData;
      _allowActionEditing = (covenant?.status != _defaultEditableActionStatus);
      populateFromExistingCovenant();
    } else {
      covenant = Covenant();
      _allowActionEditing = false;
    }
    initializeDefaultActionIfNeeded();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Indicates whether action is editable.
  bool get isActionEditable {
    final int masterId = covenant?.covConMasterId ?? 0;
    return !isReadOnly && masterId != 0;
  }

  //get child rim list for customer name  dropdown

  /// Gets child RIMs for group applications.
  Future<void> getChildRimsForGroup() async {
    try {
      if (Utils.isGroupApplication()) {
        customerList =
            await CustomerRepository.instance.getChildRimsForGroup() ?? [];
      } else {
        // Fallback for non-owner: use customers already in this request
        customerList = Globals.request?.customers ?? [];
      }
    } on Object catch (e) {
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
    } on Object {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      rethrow;
    }
  }

  Reference? _findReferenceById(List<Reference>? list, int? id) {
    if (list == null || id == null) {
      return null;
    }

    final int index = list.indexWhere((ref) => ref.id == id);
    return index == -1 ? null : list[index];
  }

  /// Populates the dialog state from an existing covenant record.
  ///
  /// This method restores:
  /// - selected dropdown values
  /// - radio button state
  /// - text controllers
  /// - row-level UI flags
  ///
  /// Important custom-description behavior:
  /// If a covenant was saved with the custom-description fallback subtype ID
  /// (used only for payload compatibility), the subtype is intentionally ignored
  /// when reopening the dialog so the UI can continue to behave like a true
  /// "Custom Description" case.
  ///
  /// This prevents:
  /// - invalid subtype hydration
  /// - bad state / no element errors
  /// - incorrect radio button selection on reopen
  void populateFromExistingCovenant() {
    try {
      selectedCustomer = Customer(
        customerRimNo: covenant?.rimNo,
        customerName: covenant?.customerName,
        firstName: covenant?.customerName,
      );

      selectedCovenantType = _findReferenceById(
        covenantType,
        covenant?.covenantType,
      );
      creditLensController.text = covenant?.creditLensId ?? "";
      entityNameController.text = covenant?.entityName ?? "";
      state.entityName = covenant?.entityName ?? "";

      final bool isCustomPseudoSubtype = (covenant?.isStandard == false) &&
          covenant?.covenantSubType == ServerConstants.customDescriptionId;

      if (covenant?.covenantSubType != null && !isCustomPseudoSubtype) {
        final Reference? matchedSubType = _findReferenceById(
          covenantSubType,
          covenant?.covenantSubType,
        );

        selectedCovenantSubType = matchedSubType;
        selectedGeneralCovenantSubType = matchedSubType;
        selectedFinancialCovenantSubType = matchedSubType;
      } else if (isCustomPseudoSubtype) {
        selectedCovenantSubType = null;
        selectedGeneralCovenantSubType = null;
        selectedFinancialCovenantSubType = null;
        covenant?.covenantSubType = null; // only for UI state in this session
      }

      if (covenant?.facilityDetailList != null &&
          covenant!.facilityDetailList!.isNotEmpty) {
        facilityList = covenant!.facilityDetailList!;
      }

      if (covenant?.periodTerm != null) {
        if (covenant?.periodTerm != null) {
          selectedPeriod = _findReferenceById(
            covenantPeriod,
            covenant?.periodTerm,
          );
        }
      }

      if (covenant?.basisOfPreparation != null) {
        selectedBasisOfPreperation = _findReferenceById(
          covenantBasisOfPreparation,
          covenant?.basisOfPreparation,
        );
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
      final Reference? descriptionTypeRef = _findReferenceById(
        descriptionTypes,
        selectedDescriptionTypeId,
      );

      selectedDescriptionType = descriptionTypeRef?.name ?? "";
      final Reference? financialDescriptionTypeRef = _findReferenceById(
        descriptionTypes,
        selectedFinancialDescriptionTypeId,
      );

      selectedFinancialDescriptionType =
          financialDescriptionTypeRef?.name ?? "";

      if (covenant?.timeForSubmition != null) {
        if (covenant?.timeForSubmition != null) {
          selectedTimeForSubmission = _findReferenceById(
            covenantSubmissionTime,
            covenant?.timeForSubmition,
          );
        }
      }

      if (covenant?.auditStatus != null) {
        selectedAuditStatus = _findReferenceById(
          covenantAuditStatus,
          covenant?.auditStatus,
        );
      }

      if (covenant?.frequency != null) {
        selectedFrequency = _findReferenceById(
          referenceData[ReferenceDataKeys.covenantFrequency],
          covenant?.frequency,
        );
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
        selectedThreshold = _findReferenceById(
          referenceData[ReferenceDataKeys.thresholdType],
          covenant?.thresholdType,
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
        } on Object catch (_) {}
        try {
          if (apiBorrowerRim == null &&
              (covenant?.borrowers?.isNotEmpty ?? false)) {
            apiBorrowerRim = covenant!.borrowers!.first.customerRimNo;
          }
        } on Object catch (_) {}

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
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Sets the selected action and updates the covenant's action ID accordingly.
  void setSelectedAction(Reference? action) {
    selectedAction = action;
    covenant?.action = action?.id;
  }

  /// Sets facilities and all facilities option for a row.
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
    } on Object catch (e) {
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
        (item) => item.id == ServerConstants.covenantCreateActionId,
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
  List<Reference> getSelectedActionItems({required bool forceEmptySelection}) {
    if (forceEmptySelection) {
      return [];
    }

    final List<Reference> availableActions =
        referenceData[ReferenceDataKeys.covenantConditionAction] ?? [];

    if (selectedAction != null &&
        availableActions.any((item) => item.id == selectedAction!.id)) {
      return [selectedAction!];
    }

    if (isNewCovenant) {
      final Reference createAction = availableActions.firstWhere(
        (item) => item.id == ServerConstants.covenantCreateActionId,
        orElse: Reference.new,
      );
      return [createAction];
    }

    return [];
  }

  //isNew Covenant not customer name in field

  /// Gets selected customer for dropdown.
  List<Customer> getSelectedCustomerForDropdown({required bool forceShow}) {
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
    Reference? externalSelectedItem, {
    required bool forceEmpty,
  }) {
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
    Reference? externalSelectedItem, {
    required bool forceEmpty,
  }) {
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

  /// Finds financial subtype by id.
  Reference? findFinancialSubtypeById(int? id) {
    if (id == null) {
      return null;
    }
    final List<Reference> list = getFilteredFinancialCovenantSubtypes();
    final int filteredItems =
        list.indexWhere((reference) => reference.id == id);
    return filteredItems == -1 ? null : list[filteredItems];
  }

  /// Finds threshold by id.
  Reference? findThresholdById(int? id) {
    if (id == null) {
      return null;
    }
    final List<Reference> threshold =
        referenceData[ReferenceDataKeys.thresholdType] ?? [];
    final int thresholdId =
        threshold.indexWhere((reference) => reference.id == id);
    return thresholdId == -1 ? null : threshold[thresholdId];
  }

  // get selected covenant type list in selecteditems

  /// Gets selected covenant type.
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

  /// Gets threshold type for covenant subtype.
  Reference? getThresholdTypeForCovenantSubtype(int? subtypeId) {
    if (subtypeId == null) {
      return null;
    }

    int? thresholdTypeId;

    if (ServerConstants.minThresholdSubtypeIds.contains(subtypeId)) {
      thresholdTypeId = ServerConstants.thresholdTypeMin;
    } else if (ServerConstants.maxThresholdSubtypeIds.contains(subtypeId)) {
      thresholdTypeId = ServerConstants.thresholdTypeMax;
    }

    if (thresholdTypeId == null) {
      return null;
    }

    final List<Reference> list = covenanttThresholdType ?? const <Reference>[];
    final int index =
        list.indexWhere((reference) => reference.id == thresholdTypeId);
    return (index == -1) ? null : list[index];
  }

// Whether text-field mode is required for a GIVEN subtype id

  /// Indicates whether threshold type text field is required for subtype.
  bool isThresholdTypeTextFieldRequiredFor(int? subtypeId) {
    if (_financialSubtypeCount <= 10) {
      return false;
    }
    if (subtypeId == null) {
      return false;
    }
    return !ServerConstants.initialFinancialSubtypeIds.contains(subtypeId);
  }

// Desktop enablement: enabled when there is NO mapping; disabled when matched

  /// Indicates whether desktop threshold is editable.
  bool get isDesktopThresholdEditable {
    if (isThresholdTypeTextFieldRequired) {
      return true; // >10 regime => let user pick
    }
    final int? id =
        selectedFinancialCovenantSubType?.id ?? covenant?.covenantSubType;
    if (id == null) {
      return false; // nothing selected yet
    }
    final Reference? mapped = getThresholdTypeForCovenantSubtype(id);
    // ENABLE if NO match; DISABLE if matched
    return mapped == null;
  }

  // ThresholdEditable enablement: but for the row's own subtype

  /// Indicates whether row threshold is editable.
  bool isRowThresholdEditable(Covenant row) {
    final int? subId = row.covenantSubType;
    if (subId == null) {
      return false; // NEW: no subtype => keep disabled
    }

    // If your >10 regime says "user must pick threshold type", allow editing.
    if (isThresholdTypeTextFieldRequiredFor(subId)) {
      return true;
    }

    // ENABLE only when there is NO mapping for the selected subtype.
    final Reference? mapped = getThresholdTypeForCovenantSubtype(subId);
    return mapped == null;
  }

  ///covenant subtype selection based on values
  void onGeneralCovenantSubTypeSelect(List<Reference> selectedReferences) {
    selectedGeneralCovenantSubType = selectedReferences.first;
    covenant?.description = selectedGeneralCovenantSubType?.name;
    covenant?.covenantSubType = selectedGeneralCovenantSubType?.id;
    if (isNewCovenant) {
      selectedCustomerRim = null;
    }

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

    if (covenant?.covenantType == ServerConstants.covenantTypeIdNonFinancial) {
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

  /// Returns the description template for a given covenant subtype.
  ///
  /// This method is mainly used for standard financial covenant descriptions,
  /// where the subtype controls the sentence pattern shown in the UI.
  ///
  /// If covenantSubtypeId is null, an empty string is returned.
  ///
  /// If no subtype-specific template is configured in
  /// [ServerConstants.financialDescriptionTemplates], the default template
  /// `"Shall not exceed [ {value} ]"` is returne
  String getDescriptionTemplateForSubtype(int? subtypeId) {
    if (subtypeId == null) {
      return "";
    }
    return ServerConstants.financialDescriptionTemplates[subtypeId] ??
        "Shall not exceed [ {value} ]";
  }

  /// Builds the full standard description for a row-level covenant.
  ///
  /// This method is used for dynamically added financial covenant rows.
  ///
  /// Behavior:
  /// - resolves the row's selected subtype
  /// - gets the matching description template
  /// - prefixes the subtype name for most subtype IDs
  /// - replaces `{value}` with the provided bracket numeric text
  ///
  /// The injected financial value may be:
  /// - an integer value up to 16 digits
  /// - a decimal value with up to 16 digits before decimal and 2 digits after
  ///   decimal
  ///
  /// [covenantRow] is the row currently being edited.
  /// [digitsOnly] is the sanitized numeric text to inject into the template.
  /// Despite the name, it may contain one decimal point for financial covenants.
  String buildStandardRowDescription(Covenant covenantRow, String digitsOnly) {
    final int? selectedSubtypeId = covenantRow.covenantSubType;
    final String descriptionTemplate =
        getDescriptionTemplateForSubtype(selectedSubtypeId);

    // Try to prefix subtype name like your other flows
    final Reference? subtypeReference = covenantSubType?.firstWhere(
      (referenceItem) => referenceItem.id == selectedSubtypeId,
      orElse: Reference.new,
    );
    final String subtypeDisplayName = (subtypeReference?.name ?? "").trim();

    final bool shouldPrefixSubtypeName = selectedSubtypeId !=
            ServerConstants.nonFinancialSubTypefirstItem &&
        selectedSubtypeId != ServerConstants.nonFinancialSubTypeSecondItem &&
        subtypeDisplayName.isNotEmpty;

    final String descriptionBase = shouldPrefixSubtypeName
        ? "$subtypeDisplayName  $descriptionTemplate "
        : descriptionTemplate;

    // Put digits into {value}. If template doesn't have {value}, this is safe.
    return descriptionBase.replaceAll("{value}", digitsOnly);
  }

  /// Returns the index of the first editable character inside the first bracket
  /// pair.
  ///
  /// This method helps place the text cursor correctly inside bracket-based
  /// descriptions such as:
  /// `Shall not exceed [ 123.45 ]`.
  ///
  /// Behavior:
  /// - In financial mode, the first digit is treated as the editable starting
  ///   character. Decimal handling is done by financial sanitization.
  /// - In non-financial mode, alphanumeric characters are treated as editable.
  /// - If no editable character is found, the method falls back to the first
  ///   character after `[`.
  ///
  /// Returns:
  /// - the zero-based offset of the first editable character
  /// - `-1` if no opening bracket is found
  int getFirstEditableCharacterIndexInsideBrackets(String text) {
    final int openingBracketIndex = text.indexOf("[");
    if (openingBracketIndex < 0) {
      return -1;
    }

    final int closingBracketIndex = text.indexOf("]", openingBracketIndex + 1);

    final String bracketContent = text.substring(
      openingBracketIndex + 1,
      closingBracketIndex >= 0 ? closingBracketIndex : text.length,
    );

    final RegExp editableCharacterPattern = isNonFinancialBracketInputMode
        ? RegExp("[A-Za-z0-9]")
        : _digitCharacterRegex;

    final RegExpMatch? firstEditableCharacterMatch =
        editableCharacterPattern.firstMatch(bracketContent);

    if (firstEditableCharacterMatch != null) {
      return openingBracketIndex + 1 + firstEditableCharacterMatch.start;
    }

    if (isNonFinancialBracketInputMode) {
      final int firstNonSpaceCharacterIndex =
          bracketContent.indexOf(RegExp(r"\S"));
      if (firstNonSpaceCharacterIndex >= 0) {
        return openingBracketIndex + 1 + firstNonSpaceCharacterIndex;
      }
    }

    return openingBracketIndex + 1;
  }

  /// Extracts the content inside the first bracket pair from [text].
  ///
  /// Example:
  /// - Input: `Shall not exceed [ 123 ]`
  /// - Output: ` 123 `
  ///
  /// If the bracket content still contains the template placeholder
  /// (for example `{value}`), this method returns an empty string.
  ///
  /// This method only inspects the first bracket pair
  String extractFirstBracketContent(String text) {
    final RegExpMatch? firstBracketMatch =
        _firstBracketContentRegex.firstMatch(text);

    final String bracketContentRaw = firstBracketMatch?.group(1) ?? "";
    if (RegExp(r"\{\s*value\s*\}").hasMatch(bracketContentRaw)) {
      return "";
    }

    return bracketContentRaw;
  }

  /// Removes the structural template spaces from bracket content.
  ///
  /// This is used for templates like:
  /// `[ {value} ]`
  ///
  /// It removes only the outer template padding:
  /// - one leading space
  /// - one trailing space
  ///
  /// It does not remove user-entered inner spaces
  String _stripTemplateBracketSpaces(String rawBracketContent) {
    String trimmedBracketContent = rawBracketContent;
    if (trimmedBracketContent.startsWith(" ")) {
      trimmedBracketContent = trimmedBracketContent.substring(1);
    }
    if (trimmedBracketContent.endsWith(" ")) {
      trimmedBracketContent =
          trimmedBracketContent.substring(0, trimmedBracketContent.length - 1);
    }
    return trimmedBracketContent;
  }

  /// Sanitizes bracket input and enforces covenant-type-specific input rules.
  /// Behavior differs by covenant type:
  /// - Financial covenant mode:
  ///   - allows numeric input only
  ///   - allows one decimal point
  ///   - allows up to 16 digits before the decimal point
  ///   - allows up to 2 digits after the decimal point
  ///   - ignores [maxLength], because financial limits are fixed by
  ///     [_financialIntegerMaxDigits] and [_financialDecimalMaxDigits]
  /// - Non-financial covenant mode:
  ///   - allows letters, digits, and spaces
  ///   - preserves spaces when requested
  ///   - counts only non-space characters toward [maxLength]
  /// [rawBracketContent] is the raw text extracted from inside the first bracket
  /// pair.
  /// [maxLength] is used only for non-financial values.
  /// [preserveBoundarySpaces] skips template-padding trimming when true.
  /// Returns the sanitized and length-clamped bracket content.
  String sanitizeAndClampBracketInput(
    String rawBracketContent, {
    int? maxLength,
    bool preserveBoundarySpaces = false,
  }) {
    final String normalizedBracketContent = preserveBoundarySpaces
        ? rawBracketContent
        : _stripTemplateBracketSpaces(rawBracketContent);

    final int effectiveMaxLength =
        maxLength ?? (isNonFinancialBracketInputMode ? 100 : 10);

    if (isNonFinancialBracketInputMode) {
      final String sanitizedBracketContent =
          normalizedBracketContent.replaceAll(_nonAlphanumericOrSpaceRegex, "");
      return _clampNonFinancialPreservingSpaces(
        sanitizedBracketContent,
        effectiveMaxLength,
      );
    }
    return _sanitizeFinancialBracketNumber(normalizedBracketContent);
  }

  /// Sanitizes and clamps a financial covenant bracket number.
  ///
  /// Rules:
  /// - removes all characters except digits and decimal points
  /// - keeps only the first decimal point
  /// - removes any additional decimal points
  /// - allows a maximum of 16 digits before the decimal point
  /// - allows a maximum of 2 digits after the decimal point
  ///
  /// Examples:
  /// - `123456789012345678` becomes `1234567890123456`
  /// - `1234567890123456.789` becomes `1234567890123456.78`
  /// - `12.3.4` becomes `12.34`
  /// - `abc12.34xyz` becomes `12.34`
  ///
  /// Returns the normalized financial bracket number as text.
  String _sanitizeFinancialBracketNumber(String inputValue) {
    final String cleanedValue =
        inputValue.replaceAll(_nonFinancialNumberCharacterRegex, "");

    final int firstDecimalIndex = cleanedValue.indexOf(".");

    if (firstDecimalIndex < 0) {
      return cleanedValue.length <= _financialIntegerMaxDigits
          ? cleanedValue
          : cleanedValue.substring(0, _financialIntegerMaxDigits);
    }

    final String integerPartRaw =
        cleanedValue.substring(0, firstDecimalIndex).replaceAll(".", "");

    final String decimalPartRaw =
        cleanedValue.substring(firstDecimalIndex + 1).replaceAll(".", "");

    final String integerPart =
        integerPartRaw.length <= _financialIntegerMaxDigits
            ? integerPartRaw
            : integerPartRaw.substring(0, _financialIntegerMaxDigits);

    final String decimalPart =
        decimalPartRaw.length <= _financialDecimalMaxDigits
            ? decimalPartRaw
            : decimalPartRaw.substring(0, _financialDecimalMaxDigits);

    return "$integerPart.$decimalPart";
  }

  /// Clamps non-financial bracket input while preserving spaces.
  ///
  /// In non-financial mode:
  /// - spaces are allowed
  /// - spaces do not count toward the maximum allowed length
  /// - only non-space characters count toward [maxLength]
  ///
  /// This is useful for values like:
  /// `Operating Budget FY 2026`
  ///
  /// where spaces should be preserved without consuming the limit.
  String _clampNonFinancialPreservingSpaces(String inputValue, int maxLength) {
    if (inputValue.isEmpty || maxLength <= 0) {
      return "";
    }

    final StringBuffer resultBuffer = StringBuffer();
    int nonSpaceCharacterCount = 0;

    for (final int runeValue in inputValue.runes) {
      final String currentCharacter = String.fromCharCode(runeValue);

      // spaces are allowed and do NOT count towards maxLength
      if (currentCharacter == " ") {
        resultBuffer.write(currentCharacter);
        continue;
      }

      if (nonSpaceCharacterCount >= maxLength) {
        continue;
      }

      resultBuffer.write(currentCharacter);
      nonSpaceCharacterCount++;
    }

    return resultBuffer.toString();
  }

  /// Extracts bracket input for editing.
  ///
  /// In financial mode:
  /// - removes template padding only
  ///
  /// In non-financial mode:
  /// - removes only the outer structural template spaces
  /// - keeps user-typed spaces between words intact
  ///
  /// This helps preserve user-entered text correctly during rebuilds.
  String _extractBracketInputForEditing(String fullDescriptionText) {
    final String rawBracketContent =
        extractFirstBracketContent(fullDescriptionText);

    // Financial keeps existing behavior exactly as before.
    if (!isNonFinancialBracketInputMode) {
      return _stripTemplateBracketSpaces(rawBracketContent);
    }

    // Non-financial:
    // Remove only the single structural space added by the template
    // on the left and right side of {value}, but preserve user-typed spaces.
    String editableBracketContent = rawBracketContent;

    if (editableBracketContent.startsWith(" ")) {
      editableBracketContent = editableBracketContent.substring(1);
    }
    if (editableBracketContent.endsWith(" ")) {
      editableBracketContent = editableBracketContent.substring(
        0,
        editableBracketContent.length - 1,
      );
    }

    return editableBracketContent;
  }

  /// Extracts non-financial bracket content up to the current caret position.
  ///
  /// This method is used to preserve the caret position correctly while rebuilding
  /// non-financial descriptions.
  ///
  /// It:
  /// - finds the first bracket pair
  /// - takes content only up to [caretOffset]
  /// - removes the leading structural template space if present
  /// - keeps user-entered inner spaces untouched
  ///
  /// Returns an empty string if no opening bracket is found.
  String _extractNonFinancialBracketPrefixUpToCaret(
    String fullDescriptionText,
    int caretOffset,
  ) {
    final int openingBracketIndex = fullDescriptionText.indexOf("[");
    if (openingBracketIndex < 0) {
      return "";
    }

    final int closingBracketIndex =
        fullDescriptionText.indexOf("]", openingBracketIndex + 1);

    final int bracketEndIndex = closingBracketIndex >= 0
        ? closingBracketIndex
        : fullDescriptionText.length;

    final int safeCaretOffset =
        caretOffset.clamp(openingBracketIndex + 1, bracketEndIndex);

    String bracketContentUpToCaret =
        fullDescriptionText.substring(openingBracketIndex + 1, safeCaretOffset);

    // Remove only the template's leading structural space.
    // Do NOT remove typed spaces between words.
    if (bracketContentUpToCaret.startsWith(" ")) {
      bracketContentUpToCaret = bracketContentUpToCaret.substring(1);
    }

    return bracketContentUpToCaret;
  }

  /// Removes auto-inserted template padding from a partial bracket slice.
  ///
  /// This helper is mainly used for caret calculations while the user is typing.
  ///
  /// It removes:
  /// - up to _leftBracketTemplatePadding.length spaces from the start
  /// - up to _rightBracketTemplatePadding.length spaces from the end
  ///
  /// It does not remove user-entered inner spaces.
  String _stripAutoPadPartial(String partialBracketContent) {
    String trimmedPartialBracketContent = partialBracketContent;

    // strip up to leftPad length from start
    final int leftPaddingLength = _leftBracketTemplatePadding.length;
    int removedLeftPaddingCount = 0;
    while (removedLeftPaddingCount < leftPaddingLength &&
        trimmedPartialBracketContent.isNotEmpty &&
        trimmedPartialBracketContent.codeUnitAt(0) == 0x20) {
      trimmedPartialBracketContent = trimmedPartialBracketContent.substring(1);
      removedLeftPaddingCount++;
    }

    // strip up to rightPad length from end
    final int rp = _rightBracketTemplatePadding.length;
    int j = 0;
    while (j < rp &&
        trimmedPartialBracketContent.isNotEmpty &&
        trimmedPartialBracketContent
                .codeUnitAt(trimmedPartialBracketContent.length - 1) ==
            0x20) {
      trimmedPartialBracketContent = trimmedPartialBracketContent.substring(
        0,
        trimmedPartialBracketContent.length - 1,
      );
      j++;
    }

    return trimmedPartialBracketContent;
  }

  /// Returns the trimmed content inside the first bracket pair.
  ///
  /// Example:
  /// - Input: `Shall not exceed [ 123 ]`
  /// - Output: `123`
  String getBracketRawValue(String fullDescriptionText) {
    final String rawBracketContent =
        extractFirstBracketContent(fullDescriptionText);
    return rawBracketContent.trim();
  }

  /// Returns `true` if the text contains brackets but the bracket content is empty.
  ///
  /// This is used before save validation to ensure required standard description
  /// threshold/input values are not left blank
  bool hasEmptyBracketContent(String fullDescriptionText) {
    final bool containsBracketPair =
        fullDescriptionText.contains("[") && fullDescriptionText.contains("]");
    if (!containsBracketPair) {
      return false;
    }
    return getBracketRawValue(fullDescriptionText).isEmpty;
  }

  /// Validates that required bracket-based values are present before save.
  ///
  /// Validation is applied to:
  /// - the main covenant description when bracket validation is required
  /// - linked financial rows
  /// - financial subtype rows
  ///
  /// A validation error is shown when a standard description contains brackets
  /// but the bracket value is empty.
  bool _validateBracketValuesBeforeSave() {
    final bool shouldValidateMainDescription = covenant?.covenantType ==
            ServerConstants.covenantTypeIdFinancial ||
        covenant?.covenantType == ServerConstants.covenantTypeIdNonFinancial ||
        isLinkFinancialView ||
        isFinancialCovenantView;

    if (shouldValidateMainDescription) {
      final String mainDescriptionText = financialDescriptionController.text;
      if (hasEmptyBracketContent(mainDescriptionText)) {
        AlertManager().showFailureToast(
          "covenantsConditions.covenantEditDialog.requiredTresholdValue".tr(),
        );
        return false;
      }
    }

    //  Validate each linked-financial row
    if (isLinkFinancialView && linkedFinancialCovenants.isNotEmpty) {
      for (final Covenant linkedFinancialRow in linkedFinancialCovenants) {
        final String rowDescriptionText =
            (linkedFinancialRow.description ?? "").trim();
        // Validate only if row is standard (optional safeguard)
        if ((linkedFinancialRow.isStandard ?? true) &&
            hasEmptyBracketContent(rowDescriptionText)) {
          AlertManager().showFailureToast(
            "covenantsConditions.covenantEditDialog.requiredTresholdValue".tr(),
          );
          return false;
        }
      }
    }

    // Validate each financial-subtype row
    if (isFinancialCovenantView && financialCovenantSubtypes.isNotEmpty) {
      for (final Covenant financialSubtypeRow in financialCovenantSubtypes) {
        final String rowDescriptionText =
            (financialSubtypeRow.description ?? "").trim();
        if ((financialSubtypeRow.isStandard ?? true) &&
            hasEmptyBracketContent(rowDescriptionText)) {
          AlertManager().showFailureToast(
            "covenantsConditions.covenantEditDialog.requiredTresholdValue".tr(),
          );
          return false;
        }
      }
    }

    return true;
  }

  /// Rebuilds the standard covenant description while the user types.
  ///
  /// Financial mode:
  /// - sanitizes the value inside the first bracket pair
  /// - allows numeric values with one decimal point
  /// - allows up to 16 digits before the decimal point
  /// - allows up to 2 digits after the decimal point
  /// - preserves caret position relative to the sanitized numeric content
  /// - updates `threshold` only when the sanitized value is an integer
  /// - clears `threshold` when the value contains a decimal, unless the model and
  ///   backend support decimal thresholds
  ///
  /// Non-financial mode:
  /// - allows alphanumeric characters and spaces inside the first bracket pair
  /// - does not update threshold
  /// - preserves caret position relative to the typed bracket content
  ///
  /// This method updates:
  /// - [financialDescriptionController]
  /// - [selectedSubTypeValue]
  /// - covenant description indirectly through the controller flow
  ///
  /// This method is guarded by [isUpdatingFinancialDescription] to avoid
  /// recursive controller updates.
  void onFinancialDescriptionChanged(String value) {
    if (isUpdatingFinancialDescription) {
      return;
    }
    isUpdatingFinancialDescription = true;

    final int? selectedSubtypeId = selectedFinancialCovenantSubType?.id;

    final String descriptionTemplate = (selectedSubtypeId !=
                ServerConstants.nonFinancialSubTypefirstItem &&
            selectedSubtypeId != ServerConstants.nonFinancialSubTypeSecondItem)
        ? '${selectedFinancialCovenantSubType?.name ?? ''} '
            "${getDescriptionTemplateForSubtype(selectedSubtypeId)}"
        : getDescriptionTemplateForSubtype(selectedSubtypeId);

    final String userInsideInValue = _extractBracketInputForEditing(value);

    final String sanitizedAlnum = sanitizeAndClampBracketInput(
      userInsideInValue,
      // maxLength: isNonFinancialBracketInputMode ? 100 : null,
      preserveBoundarySpaces: isNonFinancialBracketInputMode,
    );

    final String updatedText = descriptionTemplate.replaceAll(
      "{value}",
      "$_leftBracketTemplatePadding$sanitizedAlnum$_rightBracketTemplatePadding",
    );

    // -------------------------------
    // NON-FINANCIAL:
    // -------------------------------
    if (isNonFinancialBracketInputMode) {
      covenant?.threshold = null;
      selectedSubTypeValue?.reference1 = updatedText;

      final int currentCaretOffset =
          financialDescriptionController.selection.baseOffset;

      final String prefixUpToCaret = _extractNonFinancialBracketPrefixUpToCaret(
        value,
        currentCaretOffset,
      );

      final String sanitizedPrefix = sanitizeAndClampBracketInput(
        prefixUpToCaret,
        maxLength: 100,
        preserveBoundarySpaces: true,
      );

      final int editableContentStartIndexInInput =
          getFirstEditableCharacterIndexInsideBrackets(updatedText);

      final int targetOffset = editableContentStartIndexInInput >= 0
          ? (editableContentStartIndexInInput + sanitizedPrefix.length)
              .clamp(0, updatedText.length)
          : updatedText.length;

      final TextEditingValue oldValue = financialDescriptionController.value;
      if (oldValue.text != updatedText ||
          oldValue.selection.baseOffset != targetOffset) {
        financialDescriptionController.value = TextEditingValue(
          text: updatedText,
          selection: TextSelection.collapsed(offset: targetOffset),
        );
      }

      isUpdatingFinancialDescription = false;
      return;
    }
    // -------------------------------
    // FINANCIAL:
    // -------------------------------
    final int currentCaretOffset =
        financialDescriptionController.selection.baseOffset;
    final int editableContentStartIndexInInput =
        getFirstEditableCharacterIndexInsideBrackets(value);

    int allowedCharacterCountBeforeCaret;
    if (editableContentStartIndexInInput >= 0 &&
        currentCaretOffset >= editableContentStartIndexInInput) {
      final int open = value.indexOf("[");
      final int close = value.indexOf("]", open + 1);
      final int endOfBracket = close >= 0 ? close : value.length;
      final int cappedCaret = currentCaretOffset.clamp(open + 1, endOfBracket);
      final String insideUpToCaret = value.substring(open + 1, cappedCaret);

      final String caretSlice = _stripAutoPadPartial(insideUpToCaret);

      final String allowedUpToCaret =
          _sanitizeFinancialBracketNumber(caretSlice);
      allowedCharacterCountBeforeCaret = allowedUpToCaret.length;
    } else {
      final String allowedInValue =
          _sanitizeFinancialBracketNumber(userInsideInValue);
      allowedCharacterCountBeforeCaret = allowedInValue.length;
    }

    applyThresholdFromDescription(updatedText);

    selectedSubTypeValue?.reference1 = updatedText;
    final int startOfEditableInUpdated =
        getFirstEditableCharacterIndexInsideBrackets(updatedText);
    final int newAllowedLen = sanitizedAlnum.length;

    int updatedCaretOffset;
    if (startOfEditableInUpdated >= 0) {
      int relativeOffset = allowedCharacterCountBeforeCaret;
      if (relativeOffset < 0) {
        relativeOffset = 0;
      }
      if (relativeOffset > newAllowedLen) {
        relativeOffset = newAllowedLen;
      }
      updatedCaretOffset = startOfEditableInUpdated + relativeOffset;
    } else {
      updatedCaretOffset = updatedText.length;
    }

    final TextEditingValue oldValue = financialDescriptionController.value;
    final int clampedOffset = updatedCaretOffset.clamp(0, updatedText.length);
    if (oldValue.text != updatedText ||
        oldValue.selection.baseOffset != clampedOffset) {
      financialDescriptionController.value = TextEditingValue(
        text: updatedText,
        selection: TextSelection.collapsed(offset: clampedOffset),
      );
    }

    isUpdatingFinancialDescription = false;
  }

  /// Calculates the caret position for a rebuilt financial description.
  ///
  /// This helper is used after sanitizing bracket input in financial mode.
  /// It keeps the caret aligned with the number of valid financial-number
  /// characters typed before the user's current caret position.
  ///
  /// Financial-number characters include:
  /// - digits
  /// - the first valid decimal point
  ///
  /// The same 16-digit integer and 2-digit decimal rules are applied before
  /// calculating the final caret offset.
  ///
  /// [inputText] is the original user input before rebuilding.
  /// [rebuiltText] is the sanitized description text after template rebuild.
  /// [currentCaret] is the current caret offset in the original input.
  ///
  /// Returns a safe caret offset inside the rebuilt bracket content.
  int calculateFinancialBracketCaretOffset({
    required String inputText,
    required String rebuiltText,
    required int currentCaret,
  }) {
    final int openInInput = inputText.indexOf("[");
    if (openInInput < 0) {
      return rebuiltText.length;
    }

    final int closeInInput = inputText.indexOf("]", openInInput + 1);
    final int endInInput = closeInInput >= 0 ? closeInInput : inputText.length;
    final int cappedCaret = currentCaret.clamp(openInInput + 1, endInInput);

    final String insideUpToCaret =
        inputText.substring(openInInput + 1, cappedCaret);

    final String numberBeforeCaret =
        _sanitizeFinancialBracketNumber(insideUpToCaret);

    final int openInRebuilt = rebuiltText.indexOf("[");
    if (openInRebuilt < 0) {
      return rebuiltText.length;
    }

    final int closeInRebuilt = rebuiltText.indexOf("]", openInRebuilt + 1);
    final int endInRebuilt =
        closeInRebuilt >= 0 ? closeInRebuilt : rebuiltText.length;

    final int startEditable =
        getFirstEditableCharacterIndexInsideBrackets(rebuiltText);
    final int safeStart =
        startEditable >= 0 ? startEditable : (openInRebuilt + 1);

    final int target = safeStart + numberBeforeCaret.length;
    return target.clamp(safeStart, endInRebuilt);
  }

  /// Extracts and parses the numeric value from inside the first bracket pair
  /// `[...]` in [text].
  ///
  /// The extracted value is sanitized using financial covenant number rules:
  /// - only digits and one decimal point are allowed
  /// - up to 16 digits are allowed before decimal
  /// - up to 2 digits are allowed after decimal
  ///
  /// Returns:
  /// - parsed [num] value if a valid number exists
  /// - `null` if the bracket content is empty or not parseable
  ///
  /// Note:
  /// This is mainly used for custom financial descriptions where decimal
  /// thresholds may be supported by the model/backend.
  num? parseThresholdNumberFromDescription(String text) {
    final String raw = extractFirstBracketContent(text);
    final String numberText = _sanitizeFinancialBracketNumber(raw.trim());

    if (numberText.isEmpty || numberText == ".") {
      return null;
    }

    return num.tryParse(numberText);
  }

  /// Syncs the covenant threshold from the bracket value in [text].
  ///
  /// If [target] is provided, updates row-level threshold; otherwise updates the
  /// dialog-level [covenant] threshold.
  ///
  /// Current behavior:
  /// - integer bracket values are parsed and assigned to `threshold`
  /// - decimal bracket values are allowed in the description but `threshold` is
  ///   set to `null`
  ///
  /// This avoids corrupting decimal values when `threshold` is still treated as
  /// integer-compatible by downstream payload/model handling.
  ///
  /// Example:
  /// - `[ 12345 ]` sets threshold to `12345`
  /// - `[ 123.45 ]` keeps description as decimal text and sets threshold to null
  void applyThresholdFromDescription(String text, {Covenant? target}) {
    final String raw = extractFirstBracketContent(text);
    final String numberText = _sanitizeFinancialBracketNumber(raw.trim());

    final bool hasDecimal = numberText.contains(".");

    if (hasDecimal) {
      if (target != null) {
        target.threshold = null;
      } else {
        covenant ??= Covenant();
        covenant!.threshold = null;
      }
      return;
    }

    final int? val = int.tryParse(numberText);

    if (target != null) {
      target.threshold = val ?? 0;
    } else {
      covenant ??= Covenant();
      covenant!.threshold = val ?? 0;
    }
  }

  //initialize Financial Description when called

  /// Initializes financial description.
  void initializeFinancialDescription() {
    final int? id = selectedFinancialCovenantSubType?.id;

    final String template =
        (id != ServerConstants.nonFinancialSubTypefirstItem &&
                id != ServerConstants.nonFinancialSubTypeSecondItem)
            ? "${selectedFinancialCovenantSubType?.name ?? ''} "
                "${getDescriptionTemplateForSubtype(id)}"
            : (getDescriptionTemplateForSubtype(id));

    final String existingText = selectedSubTypeValue?.reference1 ?? template;

    final String initialValue = _extractBracketInputForEditing(existingText);

    final String initialAlnum = sanitizeAndClampBracketInput(
      initialValue,
      preserveBoundarySpaces: isNonFinancialBracketInputMode,
    );

    final String updatedText = template.replaceAll(
      "{value}",
      "$_leftBracketTemplatePadding$initialAlnum$_rightBracketTemplatePadding",
    );

    final int targetOffset =
        getFirstEditableCharacterIndexInsideBrackets(updatedText);

    financialDescriptionController.value = TextEditingValue(
      text: updatedText,
      selection: TextSelection.collapsed(
        offset: targetOffset >= 0 ? targetOffset : updatedText.length,
      ),
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

  /// Handles entity name changes.
  void onEntityNameChanged(String value) {
    covenant?.entityName = value;
    emit(state.copyWith(entityName: value));
  }

  //basis of preperation field selection

  /// Handles basis of preparation selection.
  void onBasisOfPreparationSelected(List<Reference> selected) {
    selectedBasisOfPreperation = selected.first;
    covenant?.basisOfPreparation = selectedBasisOfPreperation?.id;

    emit(
      state.copyWith(selectedBasisOfPreperation: selectedBasisOfPreperation),
    );
  }

  //Audit status field Selection

  /// Handles audit status selection.
  void onAuditStatusSelected(List<Reference> selected) {
    selectedAuditStatus = selected.first;
    covenant?.auditStatus = selectedAuditStatus?.id;

    emit(state.copyWith(selectedAuditStatus: selectedAuditStatus));
  }

  ///fetch and intitialize selected description field
  void initializeSelectedDescriptionType() {
    final bool isStandard = isStandardCovenantSelected ?? true;

    // final Reference matchedRef = descriptionTypes.firstWhere(
    //   (reference) =>
    //       reference.id ==
    //       (isStandard
    //           ? ServerConstants.standardDescriptionId
    //           : ServerConstants.customDescriptionId),
    //   orElse: () => descriptionTypes.first,
    // );

    final int id = isStandard
        ? ServerConstants.standardDescriptionId
        : ServerConstants.customDescriptionId;

    final Reference? matchedRef = _findReferenceById(descriptionTypes, id);

    selectedDescriptionType = matchedRef?.name ?? "";
    selectedDescriptionTypeId = matchedRef?.id;

    // selectedDescriptionType = matchedRef.name;
    // selectedDescriptionTypeId = matchedRef.id;
  }

  /// Initializes selected financial description type.
  void initializeFinancialSelectedDescriptionType() {
    final bool isStandard = isFinancialStandard ?? true;

    final int id = isStandard
        ? ServerConstants.standardDescriptionId
        : ServerConstants.customDescriptionId;

    final Reference? matchedRef = _findReferenceById(descriptionTypes, id);

    selectedFinancialDescriptionType = matchedRef?.name ?? "";
    selectedFinancialDescriptionTypeId = matchedRef?.id;
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
      covenant?.description = "";
      financialDescriptionController.clear();
    }
    isFinancialStandard = isStandardCovenantSelected;
    isLinkFinancialSubtypeEnabled = isFinancialStandard ?? false;
    selectedFinancialCovenantSubType = null;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  //financial description

  /// Handles financial description type changes.
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
    if (id == null) {
      return null;
    }
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
    if (fyEndStr == null || submissionDaysStr == null) {
      return null;
    }
    final int submissionDays = int.tryParse(submissionDaysStr) ?? 0;
    final List<String> parts = fyEndStr.split("/");
    if (parts.length != 2) {
      return null;
    }
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
      row.nextMonitorDate = formatDateForApiRequest(nextMonitoringDate);
    }
  }

  /// Handles row time for submission selection.
  void onRowTimeForSubmissionSelected(
    Covenant row,
    List<Reference> selectedReferences,
  ) {
    final Reference selected = selectedReferences.first;
    row.timeForSubmition = selected.id;
    _updateRowNextMonitoringDate(row);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles row financial year end submission.
  void onRowFinancialYearEndSubmit(Covenant row, String? value) {
    row.financialYearEndDate = value;
    _updateRowNextMonitoringDate(row);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles row frequency selection.
  void onRowFrequencySelected(
    Covenant row,
    List<Reference> selectedReferences,
  ) {
    row.frequency = selectedReferences.first.id;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles frequency selection.
  void onFrequencySelected(List<Reference> selectedReferences) {
    selectedFrequency = selectedReferences.first;
    covenant?.frequency = selectedFrequency?.id;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  ///next monitor date in ui from api
  String formatApiDateForUi(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return "";
    }
    try {
      final DateTime date = DateTime.parse(dateStr); // expects yyyy-MM-dd
      return "${date.day.toString().padLeft(2, '0')}-"
          "${date.month.toString().padLeft(2, '0')}-"
          "${date.year.toString().padLeft(4, '0')}";
    } on Object catch (_) {
      return dateStr; // fallback to original if parsing fails
    }
  }

  ///update next monitor date in ui
  ///updation based on financial year end
  ///and time for submission field inputs
  void updateNextMonitoringDate() {
    final DateTime? resultDate = getCalculatedNextMonitoringDateRaw();
    if (resultDate == null) {
      return;
    }

    covenant ??= Covenant();
    covenant!.nextMonitorDate =
        formatDateForApiRequest(resultDate); // for saving
    nextMonitoringDateController.text =
        formatDateForDisplay(resultDate); // for UI

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  ///next monitor date logic based on selected financial year end date
  /// and time for submission
  DateTime? getCalculatedNextMonitoringDateRaw() {
    final String? fyEndStr = covenant?.financialYearEndDate;
    final String? submissionDaysStr = selectedTimeForSubmission?.name;

    if (fyEndStr == null || submissionDaysStr == null) {
      return null;
    }

    final int submissionDays = int.tryParse(submissionDaysStr) ?? 0;
    final List<String> parts = fyEndStr.split("/");
    if (parts.length != 2) {
      return null;
    }

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

  /// Formats date for display.
  String formatDateForDisplay(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year.toString().padLeft(4, '0')}";
  }

  //formatted fetched next monitor date from api

  /// Formats date for API request.
  String formatDateForApiRequest(DateTime date) {
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
    } on Object {
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
          preselectedAllFacilities: selectedAllFacilitiesYesNo,
          isCovenant: true,
          overridePageMode: covenantEditPageMode,
        ),
        context: context,
      );
      if (data != null) {
        await setFacility(data);
      }
    } else {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Gets selected general value for row.
  List<Reference> getSelectedGeneralForRow(Covenant row) {
    // If row.isGeneric is null => no pre-selection
    if (row.isGeneric == null) {
      return const <Reference>[];
    }

    final List<Reference> items =
        referenceData[ReferenceDataKeys.covenantGeneralSpecific] ?? [];
    final int targetId = (row.isGeneric ?? false)
        ? ServerConstants.covenantGeneralId
        : ServerConstants.covenantSpecificId;

    final int index = items.indexWhere((reference) => reference.id == targetId);
    return (index == -1) ? const <Reference>[] : <Reference>[items[index]];
  }

  /// Handles linked general field change.
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
          preselectedAllFacilities: getRowAllFacilitiesRef(row),
          isCovenant: true, // NEW
          overridePageMode: covenantEditPageMode,
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

  /// Sets selected facilities.
  Future<void> setFacility(Object? data) async {
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

  /// Sets selected facilities for a row.
  void setRowFacility(Covenant row, Object? data) {
    if (data == null) {
      return;
    }
    if (data is List<Facility>) {
      setRowFacilitiesAndOption(row, data, null);
    } else if (data is Map) {
      final List<Facility> selectedFacilities =
          data["selectedFacilities"] as List<Facility>? ?? const [];
      final Reference? allRef = data["allFacilitiesOption"] as Reference?;
      setRowFacilitiesAndOption(row, selectedFacilities, allRef);
    }
  }

  /// Returns action values.
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
    } on Object {
      emit(state.copyWith(searchLoaderStatus: LoadingStatus.error));
    }
  }

  /// Handles UI update when the add button is pressed.
  void onAddButtonPress() {
    final bool nextValue = !showAddWidgets;
    showAddWidgets = nextValue;
    emit(state.copyWith(showAddWidgets: nextValue));
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
    } on Object {
      return "";
    }
  }

  /// - A formatted date string or an empty string if `timestamp` is n
  /// parse Financial Year End Date
  DateTime? parseFinancialYearEndDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return null;
    }

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
    } on Object catch (_) {}
    try {
      final DateTime date = DateFormat("MMMd").parseStrict(dateStr);
      return DateTime(currentYear, date.month, date.day);
    } on Object catch (_) {}

    try {
      final DateTime date = DateFormat("MMMMd").parseStrict(dateStr);
      return DateTime(currentYear, date.month, date.day);
    } on Object catch (_) {}

    return null;
  }

  /// Validates, normalizes, and saves covenant data.
  ///
  /// Save behavior includes:
  /// - form validation
  /// - borrower payload construction
  /// - radio-button-based standard/custom handling
  /// - fallback subtype assignment for custom-description cases
  /// - custom threshold extraction from description text
  /// - row-level payload generation for linked financial rows
  /// - row-level payload generation for financial subtype rows
  ///
  /// Important:
  /// For custom-description cases, the system may send a fallback subtype ID
  /// in payload for backend compatibility. That fallback subtype is ignored
  /// during UI rehydration when reopening the dialog.
  Future<bool> onSavePress() async {
    try {
      if (isRequiredBusinessSegment) {
        final bool isValid = formKey.currentState?.validate() ?? false;
        if (!isValid) {
          return false;
        }
      }

      if (!_validateBracketValuesBeforeSave()) {
        return false;
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      formKey.currentState?.save();
      final bool isCustomFinancialSelected =
          selectedFinancialDescriptionTypeId ==
              ServerConstants.customDescriptionId;

      final bool isCustomGeneralSelected =
          selectedDescriptionTypeId == ServerConstants.customDescriptionId;

      const int customDescriptionPseudoSubtypeId =
          ServerConstants.customDescriptionId;

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
      const customFinancialFallbackSubtypeId =
          ServerConstants.customDescriptionId;
      if (selectedCovenantTypeEnum == CovenantType.nonFinancial) {
        covenant?.threshold = null;
      }
      if (isFinancial) {
        covenant?.covenantSubType = isCustomFinancialSelected
            ? (financialSubTypeId ?? customDescriptionPseudoSubtypeId)
            : financialSubTypeId;
        if (isCustomFinancialSelected) {
          covenant?.threshold = null; // Custom text should not derive threshold
          covenant?.description = (covenant?.description ?? "").trim();
        } else {
          final String finText = financialDescriptionController.text.trim();
          if (finText.isNotEmpty &&
              !isLinkFinancialView &&
              !isFinancialCovenantView) {
            covenant?.description = " $finText";
          }
        }
      } else {
        if (covenant?.description?.trim().isEmpty ?? true) {
          covenant?.description = selectedGeneralCovenantSubType?.name;
        }
        // covenant?.covenantSubType = generalSubTypeId;
        covenant?.covenantSubType = isCustomGeneralSelected
            ? (generalSubTypeId ?? customDescriptionPseudoSubtypeId)
            : generalSubTypeId;
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
        if (covenant?.covenantType ==
            ServerConstants.covenantTypeIdNonFinancial) {
          // covenant?.covenantSubType = selectedFinancialCovenantSubType?.id;
          covenant?.covenantSubType = isCustomGeneralSelected
              ? customDescriptionPseudoSubtypeId
              : selectedFinancialCovenantSubType?.id;
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
          covenant?.covenantSubType = isCustomGeneralSelected
              ? customDescriptionPseudoSubtypeId
              : generalSubTypeId;
        }
        if (covenant?.covenantType ==
            ServerConstants.covenantTypeIdNonFinancial) {
          covenant?.covenantSubType = isCustomGeneralSelected
              ? customDescriptionPseudoSubtypeId
              : selectedFinancialCovenantSubType?.id;
        }
        final Map<String, dynamic>? editJson = covenant?.toSaveJson();
        if (editJson != null) {
          covenantJsonList.add(editJson);
        }
      }
      covenant?.thresholdType = originalThresholdType;

      if (isLinkFinancialView && linkedFinancialCovenants.isNotEmpty) {
        for (final Covenant row in linkedFinancialCovenants) {
          if (!(row.isStandard ?? true)) {
            row
              ..description = (row.description ?? "").trim()
              ..threshold = null;
          }

          // Keep the row’s own choices
          final int? rowSubtype = row.covenantSubType;
          final int? rowThresholdType = row.thresholdType;
          final num? rowThreshold = row.threshold;
          final String? rowDescription = row.description;
          final bool? rowIsStandard = row.isStandard;

          // copy base fields from desktop (same as before)
          row
            ..linkFinancialCovenant(covenant!)
            ..covenantType =
                ServerConstants.covenantTypeId[CovenantType.financial]
            ..rimNo = selectedCustomer?.customerRimNo
            ..isStandard = rowIsStandard ?? true
            ..covenantSubType = (rowIsStandard ?? true)
                ? rowSubtype
                : (rowSubtype ?? customFinancialFallbackSubtypeId)
            ..thresholdType = rowThresholdType
            ..threshold = rowThreshold
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
            final bool prefix = row.covenantSubType !=
                    ServerConstants.nonFinancialSubTypefirstItem &&
                row.covenantSubType !=
                    ServerConstants.nonFinancialSubTypeSecondItem &&
                name.isNotEmpty;
            row.description = (prefix ? "$name $template" : template)
                .replaceAll("{value}", "");
          }
          row
            ..isNew = true
            ..isDeleted = false;
          final Map<String, dynamic> json = row.toSaveNewJson();
          covenantJsonList.add(json);
        }
      }

      //Financial subtype rows
      if (isFinancialCovenantView && financialCovenantSubtypes.isNotEmpty) {
        for (final Covenant row in financialCovenantSubtypes) {
          if (!(row.isStandard ?? true)) {
            row
              ..description = (row.description ?? "").trim()
              ..threshold = null;
          }

          //Capture the row's own values (in case linkFinancialCovenant copies
          //again)
          final int? rowSubtype = row.covenantSubType;
          final int? rowThresholdType = row.thresholdType;
          final num? rowThreshold = row.threshold;
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
            ..covenantSubType = (rowIsStandard ?? true)
                ? rowSubtype
                : (rowSubtype ?? customFinancialFallbackSubtypeId)
            ..thresholdType = rowThresholdType // keep row mapping/manual
            ..threshold = rowThreshold
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
            final bool prefix = row.covenantSubType !=
                    ServerConstants.nonFinancialSubTypefirstItem &&
                row.covenantSubType !=
                    ServerConstants.nonFinancialSubTypeSecondItem &&
                name.isNotEmpty;
            row.description = (prefix ? "$name $template" : template)
                .replaceAll("{value}", "");
          }

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
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return false;
    }
  }

  /// Adds a new linked financial covenant row under
  /// Information > Financial Statements.
  ///
  /// Each row is initialized independently so its:
  /// - description mode
  /// - subtype
  /// - threshold type
  /// - threshold value
  /// can be managed separately before save
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

  /// Updates a dynamically added financial row when subtype changes.
  ///
  /// This method:
  /// - stores the selected subtype ID in the row
  /// - derives threshold type mapping if applicable
  /// - rebuilds the standard template description for that row
  ///
  /// This logic applies only to row-level financial subtype items,
  /// not the main covenant header.
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
    final bool prefix = id != ServerConstants.nonFinancialSubTypefirstItem &&
        id != ServerConstants.nonFinancialSubTypeSecondItem &&
        subName.isNotEmpty;

    row.description =
        (prefix ? "$subName $template" : template).replaceAll("{value}", "");
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Adds a new financial covenant subtype row in the financial covenant flow.
  ///
  /// Each newly added row behaves as an independent item and may carry:
  /// - its own standard/custom description selection
  /// - its own subtype
  /// - its own threshold type
  /// - its own threshold value
  ///
  /// This is required because multiple custom financial rows can exist and each
  /// row must send its own exact threshold value in payload
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

  /// Sanitizes a custom financial description entered in free-text mode.
  ///
  /// Rules:
  /// - only the first bracket pair `[ ... ]` is inspected
  /// - text outside the first bracket pair is left unchanged
  /// - inside the bracket pair, only financial numeric input is allowed
  /// - allows one decimal point
  /// - allows up to 16 digits before the decimal point
  /// - allows up to 2 digits after the decimal point
  /// - surrounding spaces inside the bracket pair are preserved
  ///
  /// Examples:
  /// - Input:  `Leverage Ratio [ ab12c3 ]`
  ///   Output: `Leverage Ratio [ 123 ]`
  ///
  /// - Input:  `Leverage Ratio [ 123456789012345678.999 ]`
  ///   Output: `Leverage Ratio [ 1234567890123456.99 ]`
  ///
  /// - Input:  `Leverage Ratio [ 12.3.4 ]`
  ///   Output: `Leverage Ratio [ 12.34 ]`
  String sanitizeCustomFinancialDescription(String input) {
    final RegExpMatch? match = _firstBracketContentRegex.firstMatch(input);

    if (match == null) {
      return input;
    }

    final String rawBracketContent = match.group(1) ?? "";

    final bool hasLeadingSpace = rawBracketContent.startsWith(" ");
    final bool hasTrailingSpace = rawBracketContent.endsWith(" ");
    final String clampedDigits =
        _sanitizeFinancialBracketNumber(rawBracketContent);

    final String rebuiltBracketContent = "${hasLeadingSpace ? " " : ""}"
        "$clampedDigits"
        "${hasTrailingSpace ? " " : ""}";

    return input.replaceRange(
      match.start + 1,
      match.end - 1,
      rebuiltBracketContent,
    );
  }

  /// Synchronizes description and threshold from a custom financial description.
  ///
  /// This method:
  /// - sanitizes the first bracket pair using financial numeric rules
  /// - updates `description` with the sanitized text
  /// - parses the sanitized bracket number
  /// - updates `threshold` with the parsed numeric value when available
  ///
  /// Financial numeric rules:
  /// - one decimal point is allowed
  /// - up to 16 digits are allowed before decimal
  /// - up to 2 digits are allowed after decimal
  ///
  /// If [target] is provided, the update is applied to the specific row.
  /// Otherwise, the update is applied to the main dialog covenant.
  ///
  /// If no valid bracket pair exists, threshold becomes null.
  void syncThresholdFromCustomFinancialDescription(
    String text, {
    Covenant? target,
  }) {
    final String sanitizedText = sanitizeCustomFinancialDescription(text);
    final bool hasBracketPair =
        sanitizedText.contains("[") && sanitizedText.contains("]");
    final num? parsedThreshold = hasBracketPair
        ? parseThresholdNumberFromDescription(sanitizedText)
        : null;

    if (target != null) {
      target
        ..description = sanitizedText
        ..threshold = parsedThreshold;
    } else {
      covenant ??= Covenant();
      covenant!.description = sanitizedText;
      covenant!.threshold = parsedThreshold;
    }
  }

  /// Same as [syncThresholdFromCustomFinancialDescription], but also triggers
  /// a UI refresh when sanitization changes the user-entered text.
  ///
  /// This is mainly used by custom text areas where:
  /// - users can type free text outside brackets
  /// - only the first bracket pair is sanitized
  /// - financial bracket values may contain one decimal point
  /// - financial bracket values are limited to 16 digits before decimal and
  ///   2 digits after decimal
  ///
  /// Returns true if the input text had to be sanitized.
  bool syncThresholdFromCustomFinancialDescriptionAndRefresh(
    String text, {
    Covenant? target,
  }) {
    final String sanitizedText = sanitizeCustomFinancialDescription(text);

    final num? parsedThreshold =
        sanitizedText.contains("[") && sanitizedText.contains("]")
            ? parseThresholdNumberFromDescription(sanitizedText)
            : null;

    if (target != null) {
      target
        ..description = sanitizedText
        ..threshold = parsedThreshold;
    } else {
      covenant ??= Covenant();
      covenant!
        ..description = sanitizedText
        ..threshold = parsedThreshold;
    }

    final bool changed = sanitizedText != text;
    if (changed) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
    return changed;
  }

  /// Resets fields when covenant type changes.
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
