import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/view.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/application_details.dart';
import 'package:wcas_frontend/models/request/covenant_condtion/covenant.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/repositories/auth_repository.dart';
import 'package:wcas_frontend/repositories/covenant_condition_repository.dart';
import 'package:wcas_frontend/repositories/customer_respository.dart';
import 'state.dart';

enum CovenantTestType { rim, name }

enum InternalFinancialCovenantType { yes, no }

class CovenantEditDialogViewModel extends Cubit<CovenantEditDialogState> {
  Covenant? covenant;
  bool? isNew;
  CovenantEditDialogViewModel(this.covenant, this.isNew)
      : super(CovenantEditDialogState(loaderStatus: LoadingStatus.loading));
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
  Reference? selectedTreshold;
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
  List<Customer>? testUsers = [];
  List<Customer> selectedTestUsers = [];
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

  Reference? selectedFinancialCovenantSubType;
  Reference? selectedGeneralCovenantSubType;
  PageMode pagemode = PageMode.na;
  bool get isReadOnly => pagemode == PageMode.view;

  /// Checks if the covenant is being updated.
  bool isUpdateCovenant() => covenant != null;
  bool isFinancialCovenantDescription = true;

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
  String rimNoSearch = '';
  final TextEditingController customerNameController = TextEditingController();

  // add new covenants in the list when isNew = true
  bool isLinkFinancialView = false;
  bool isfinancialCovenantView = false;
  List<Covenant> financialCovenantSubtypes = [];
  List<Covenant> linkedFinancialCovenants = [];
  bool isNewCovenant = false;

  //covenant description
  int? selectedDescriptionTypeId;
  String? selectedDescriptionType;
  int? selectedFinancialDescriptionTypeId;
  String? selectedFinancialDescriptionType;

  bool? isFinancialStandard = true; //pawan
  bool? isStandardCovenantSelected;
  String? customLinkFinancialDescription;
  String? customAddCSFinancialDescription;
  bool get isStandardSelected =>
      selectedDescriptionTypeId == ServerConstants.standardDescriptionId;
  bool get isFinancialSubtypeEnabled =>
      selectedFinancialDescriptionTypeId ==
      ServerConstants.standardDescriptionId;
  bool isLinkFinancialSubtypeEnabled = true;
  // bool isLinkFinancialSubtypeClear = false;

  TextEditingController financialDescriptionController =
      TextEditingController();

  List<Customer>? customersList = [];

  //input standard description for covenant subtypes
  // final RegExp _bracketRegex = RegExp(r'\[(.*?)\]');
  final RegExp _bracketRegex = RegExp(r'\[(.*?)\]');

  final RegExp _allowedAlnum = RegExp(r'[A-Za-z0-9]');
  final RegExp _sanitizeToAlnum = RegExp(r'[^A-Za-z0-9]');
  final String _bracketLeftPad = '  ';
  final String _bracketRightPad = '  ';
  bool isUpdatingFinancialDescription = false;
  bool showOnlyNonFinancialSubtypeItems = false;
  bool isDescriptionReadOnly = false;

  //get covenant subytypes conditional based on selected covenant type
  List<Reference> get covenantSubTypeDropdownItems {
    List<Reference> allItems =
        referenceData[ReferenceDataKeys.covenantSubtype] ?? [];

    String? selectedTypeId = selectedGeneralCovenantSubType?.reference2 ??
        selectedCovenantType?.id?.toString() ??
        covenant?.covenantType?.toString();

    List<Reference> filtered =
        (selectedTypeId != null && selectedTypeId.isNotEmpty)
            ? allItems
                .where((ref) => ref.reference2?.trim() == selectedTypeId.trim())
                .toList()
            : allItems;

    List<Reference> finalList = filtered.isNotEmpty ? filtered : allItems;

    List<Reference> others = finalList
        .where((ref) =>
            ref.id == ServerConstants.covenantSubTypeId[CovenantSubType.other])
        .toList();
    List<Reference> nonOthers = finalList
        .where((ref) =>
            ref.id != ServerConstants.covenantSubTypeId[CovenantSubType.other])
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
    List<Reference> originalItems =
        referenceData[ReferenceDataKeys.covenantFrequency] ?? [];

    bool shouldFilter = covenant?.covenantSubType ==
            ServerConstants.covenantSubTypeIdForFrequencyFilter ||
        selectedCovenantTypeEnum == CovenantType.nonFinancial ||
        selectedCovenantTypeEnum == CovenantType.financial;

    if (!shouldFilter) return originalItems;

    return originalItems
        .where(
            (item) => !ServerConstants.excludedFrequencyIds.contains(item.id))
        .toList();
  }

  bool get shouldShowDescriptionTextArea {
    return selectedDescriptionTypeId == ServerConstants.customDescriptionId ||
        (selectedCovenantTypeEnum == CovenantType.information &&
            selectedGeneralCovenantSubType != null &&
            selectedSubGeneralTypeValueEnum == CovenantSubType.other);
  }

  /// Initializes the view model.
  /// Sets up the repository, loads reference data, and pre-fills covenant details if available.
  /// [context] - The BuildContext for UI updates.
  /// [covenantData] - The existing covenant condition, if provided.
  Future<void> init(context, isNew, [Covenant? covenantData]) async {
    logger.i('initialising CovenantEditDialogViewModel');
    pagemode = AuthRepository.getPageMode(RightConstants.covenantsUpdate);
    debugPrint(pagemode.toString());
    repository = CovenantConditionRepository.instance;
    await loadReferenceData();
    customersList = [...(Globals.request?.customers ?? <Customer>[])];
    // getApplicationDetails();
    isNewCovenant = isNew;
    if (covenantData != null) {
      covenant = covenantData;
      getModifyData();
    } else {
      covenant = Covenant();
      selectedStatus = _getDefaultNewStatus();
    }
    initializeDefaultActionIfNeeded();
    testUsers = Globals.request?.customers;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
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
        ReferenceDataKeys.covenantDescription
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
  void getModifyData() {
    try {
      selectedCustomer = Customer(customerName: covenant!.customerName);

      selectedCovenantType =
          covenantType!.firstWhere((ref) => ref.id == covenant!.covenantType);

      creditLensController.text = covenant?.creditLensId ?? '';
      entityNameController.text = covenant?.entityName ?? '';
      state.entityName = covenant?.entityName ?? '';

      if (covenant?.covenantSubType != null) {
        selectedCovenantSubType = covenantSubType!
            .firstWhere((ref) => ref.id == covenant!.covenantSubType);
        selectedGeneralCovenantSubType = covenantSubType!
            .firstWhere((ref) => ref.id == covenant!.covenantSubType);
        selectedFinancialCovenantSubType = covenantSubType!
            .firstWhere((ref) => ref.id == covenant!.covenantSubType);
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
      initializeFinancialSelectedDescriptionType();

      selectedDescriptionType = descriptionTypes
          .firstWhere((ref) => ref.id == selectedDescriptionTypeId,
              orElse: () => descriptionTypes.first)
          .name;

      selectedFinancialDescriptionType = descriptionTypes
          .firstWhere((ref) => ref.id == selectedFinancialDescriptionTypeId,
              orElse: () => descriptionTypes.first)
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

      if (covenant?.action != null) {
        selectedAction =
            referenceData[ReferenceDataKeys.covenantConditionAction]
                ?.firstWhere((Reference value) => value.id == covenant?.action);
      }

      if (covenant?.thresholdType != null) {
        selectedTreshold = referenceData[ReferenceDataKeys.thresholdType]
            ?.firstWhere(
                (Reference value) => value.id == covenant?.thresholdType);
      }
      selectedStatus = covenant?.status != null
          ? covenantStatus?.firstWhere(
              (ref) => ref.id == covenant!.status,
              orElse: () => _getDefaultNewStatus(),
            )
          : _getDefaultNewStatus();

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

      if (isNewCovenant == false) {
        final List<Customer> list =
            customersList ?? Globals.request?.customers ?? [];
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
        apiBorrowerRim ??= covenant?.rimNo;

        if (apiBorrowerRim != null) {
          final match =
              list.where((c) => c.customerRimNo == apiBorrowerRim).toList();
          if (match.isNotEmpty) {
            selectedCustomerRim = match.first;
          }
        }
      }
    } catch (e) {
      logger.e("Failed to modify data");
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Sets the selected action and updates the covenant's action ID accordingly.
  void setSelectedAction(Reference? action) {
    selectedAction = action;
    covenant?.action = action?.id;
  }

  /// Searches for customer information using the provided RIM number.
  /// Populates the read-only name field and caches the found customer.
  /// Does NOT modify the dropdown list or selection.
  Future<void> searchByRim(String rim) async {
    final trimmed = rim.trim();
    if (trimmed.isEmpty) {
      AlertManager().showFailureToast("riskRating.invalidRim".tr());
      return;
    }

    emit(state.copyWith(searchLoaderStatus: LoadingStatus.loading));

    try {
      rimNoSearch = trimmed;

      final Customer? customerDetails =
          await CustomerRepository().searchUserDetails(trimmed, '', '', '');
      final int? rimNoFromApi = customerDetails?.customerRimNo;
      final int? rimNo = rimNoFromApi ?? int.tryParse(trimmed);

      if (rimNo == null) {
        customerNameController.text = '';
        searchedCustomer = null;
        AlertManager().showFailureToast("riskRating.invalidRim".tr());
        return;
      }

      final displayName =
          (customerDetails?.preferredName?.trim().isNotEmpty ?? false)
              ? customerDetails!.preferredName
              : (customerDetails?.customerName ?? '');
      customerNameController.text = displayName ?? '';
      searchedCustomer = customerDetails;
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    } finally {
      emit(state.copyWith(searchLoaderStatus: LoadingStatus.loaded));
    }
  }

  /// Adds the currently searched RIM into the dropdown list (top) and selects it.
  /// Does not clear/replace existing items. Does not mutate covenant.*
  /// This is triggered by the "Add" button in AddRimValueDropdown.
  void onAddRim() {
    final int? rimNo =
        (searchedCustomer?.customerRimNo) ?? int.tryParse(rimNoSearch);
    if (rimNo == null) {
      AlertManager().showFailureToast("riskRating.invalidRim".tr());
      return;
    }

    customersList ??= <Customer>[];
    customersList!.removeWhere((c) => c.customerRimNo == rimNo);

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
    rimNoSearch = '';
    searchedCustomer = null;

    showAddWidgets = false;
    emit(state.copyWith(
      showAddWidgets: false,
      searchLoaderStatus: LoadingStatus.loaded,
    ));
  }

  // /// Initializes the default action to "Create" if:
  /// - The current covenant is new (`isNewCovenant` is true)
  /// - No action has been selected yet (`selectedAction` is null)
  /// It looks for the "Create" action by its ID defined in serverconstants
  void initializeDefaultActionIfNeeded() {
    if (isNewCovenant && selectedAction == null) {
      final availableActions =
          referenceData[ReferenceDataKeys.covenantConditionAction] ?? [];
      final createAction = availableActions.firstWhere(
        (item) => item.id == ServerConstants.createActionId,
        orElse: () => Reference(),
      );
      setSelectedAction(createAction);
    }
  }

  /// Returns a list containing the currently selected action for the dropdown.
  /// - If `forceEmptySelection` is true, returns an empty list.
  /// - If a valid `selectedAction` exists in the available actions, returns it.
  /// - If it's a new covenant and no valid selection exists, returns the "Create" action by default.
  /// - Otherwise, returns an empty list.
  List<Reference> getSelectedActionItems(bool forceEmptySelection) {
    if (forceEmptySelection) return [];

    final availableActions =
        referenceData[ReferenceDataKeys.covenantConditionAction] ?? [];

    if (selectedAction != null &&
        availableActions.any((item) => item.id == selectedAction!.id)) {
      return [selectedAction!];
    }

    if (isNewCovenant) {
      final createAction = availableActions.firstWhere(
        (item) => item.id == ServerConstants.createActionId,
        orElse: () => Reference(),
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
    if (isNewCovenant == true || selectedCustomer == null) {
      return [];
    }
    return [selectedCustomer!];
  }

  /// get selected covenant sub type list in selecteditems
  List<Reference> getSelectedFinancialSubtype(
      Reference? externalSelectedItem, bool forceEmpty) {
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
      Reference? externalSelectedItem, bool forceEmpty) {
    if (forceEmpty) {
      return [];
    } else if (externalSelectedItem != null) {
      return [externalSelectedItem];
    } else if (selectedTreshold != null) {
      return [selectedTreshold!];
    } else {
      return [];
    }
  }

  Reference? findFinancialSubtypeById(int? id) {
    if (id == null) return null;
    final list = getFilteredFinancialCovenantSubtypes();
    final i = list.indexWhere((r) => r.id == id);
    return i == -1 ? null : list[i];
  }

  Reference? findThresholdById(int? id) {
    if (id == null) return null;
    final list = referenceData[ReferenceDataKeys.thresholdType] ?? [];
    final i = list.indexWhere((r) => r.id == id);
    return i == -1 ? null : list[i];
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

    return covenanttThresholdType?.firstWhere(
      (ref) => ref.id == thresholdTypeId,
      orElse: () => Reference(name: "common.selectValue".tr()),
    );
  }

  ///covenant subtype selection based on values
  void onGeneralCovenantSubTypeSelect(List<Reference> refs) {
    selectedGeneralCovenantSubType = refs.first;
    covenant?.description = selectedGeneralCovenantSubType?.name;
    covenant?.covenantSubType = selectedGeneralCovenantSubType?.id;
    if (isNewCovenant) selectedCustomerRim = null;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  ///covenant subtype selection based on values in financial covenants
  void onFinancialCovenantSubTypeSelect(List<Reference> refs) {
    selectedFinancialCovenantSubType = refs.first;
    covenant?.covenantSubType = selectedFinancialCovenantSubType?.id;
    Reference? matchedThreshold = getThresholdTypeForCovenantSubtype(
      selectedFinancialCovenantSubType?.id,
    );

    if (matchedThreshold != null) {
      thresholdType = matchedThreshold;
      selectedTreshold = matchedThreshold;
      covenant?.thresholdType = selectedTreshold?.id;
    }

    final template =
        getDescriptionTemplateForSubtype(selectedFinancialCovenantSubType?.id);
    selectedSubTypeValue?.reference1 = template.replaceAll("{value}", "");
    initializeFinancialDescription();

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  ///covenant subtype selection based on values in link financial covenants
  ///when case is information covenant and subtype is financial statements
  void onCovenantSubTypeSelect(List<Reference> refs) {
    selectedCovenantSubType = refs.first;
    covenant?.covenantSubType = selectedCovenantSubType?.id;

    Reference? matchedThreshold = getThresholdTypeForCovenantSubtype(
      selectedCovenantSubType?.id,
    );

    if (matchedThreshold != null) {
      thresholdType = matchedThreshold;
    }

    final template =
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
    int open = text.indexOf('[');
    if (open < 0) return -1;
    int close = text.indexOf(']', open + 1);
    String inside = text.substring(open + 1, close >= 0 ? close : text.length);

    int leadingSpaces = 0;
    while (leadingSpaces < inside.length &&
        inside.codeUnitAt(leadingSpaces) == 0x20) {
      leadingSpaces++;
    }

    RegExpMatch? match = _allowedAlnum.firstMatch(inside);
    if (match != null) {
      return open + 1 + match.start;
    }
    return open + 1 + leadingSpaces;
  }

  //extract inside brackets inside description
  String extractInsideBrackets(String text) {
    RegExpMatch? extractValue = _bracketRegex.firstMatch(text);
    String raw = extractValue?.group(1) ?? '';
    if (RegExp(r'\{\s*value\s*\}').hasMatch(raw)) return '';

    return raw;
  }

  //validation on input chars maxLength
  String sanitizeAndClampAlnum(String raw, {int maxLength = 100}) {
    String sanitized = raw.replaceAll(_sanitizeToAlnum, '');
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
      int open = value.indexOf('[');
      int close = value.indexOf(']', open + 1);
      int endOfBracket = close >= 0 ? close : value.length;
      final int cappedCaret = currentSel.clamp(open + 1, endOfBracket);
      final String insideUpToCaret = value.substring(open + 1, cappedCaret);
      final String allowedUpToCaret =
          insideUpToCaret.replaceAll(_sanitizeToAlnum, '');
      relativeInAllowed = allowedUpToCaret.length;
    } else {
      final String allowedInValue =
          rawInsideInValue.replaceAll(_sanitizeToAlnum, '');
      relativeInAllowed = allowedInValue.length;
    }

    int? id = selectedFinancialCovenantSubType?.id;

    final String template = (id != 11141 && id != 11142)
        ? "${selectedFinancialCovenantSubType?.name ?? ''} ${getDescriptionTemplateForSubtype(id)}"
        : (getDescriptionTemplateForSubtype(id));

    final String sanitizedAlnum =
        sanitizeAndClampAlnum(rawInsideInValue, maxLength: 100);

    final String updatedText = template.replaceAll(
      "{value}",
      "$_bracketLeftPad$sanitizedAlnum$_bracketRightPad",
    );
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

  //initialize Financial Description when called
  void initializeFinancialDescription() {
    int? id = selectedFinancialCovenantSubType?.id;

    final String template = (id != 11141 && id != 11142)
        ? "${selectedFinancialCovenantSubType?.name ?? ''} ${getDescriptionTemplateForSubtype(id)}"
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
    String rawHint =
        tr('covenantsConditions.covenantEditDialog.financialCovenantText'.tr());

    return rawHint
        .replaceAll('{basis}', selectedBasisOfPreperation?.name ?? "")
        .replaceAll('{audit}', selectedAuditStatus?.name ?? "")
        .replaceAll('{entity}', state.entityName ?? "");
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
        state.copyWith(selectedBasisOfPreperation: selectedBasisOfPreperation));
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

    Reference matchedRef = descriptionTypes.firstWhere(
      (ref) =>
          ref.id ==
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

    Reference matchedRef = descriptionTypes.firstWhere(
      (ref) =>
          ref.id ==
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
    Reference selectedRef = descriptionTypes.firstWhere(
      (ref) => ref.name == selectedDescriptionType,
      orElse: () => Reference(name: "", id: -1),
    );
    isStandardCovenantSelected =
        selectedRef.id == ServerConstants.standardDescriptionId;
  }

  /// Updates the selected radio option in covenant link financial description.
  void updateFinancialIsStandardFromSelection() {
    Reference selectedRef = descriptionTypes.firstWhere(
      (ref) => ref.name == selectedFinancialDescriptionType,
      orElse: () => Reference(name: "", id: -1),
    );
    isFinancialStandard =
        selectedRef.id == ServerConstants.standardDescriptionId;
  }

  /// Updates the selected description type.
  /// [value] - The new description type selection.
  void onDescriptionTypeChange(String? value) {
    selectedDescriptionType = value;

    Reference selectedRef = descriptionTypes.firstWhere(
      (ref) => ref.name == value,
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
    }
    isFinancialStandard = isStandardCovenantSelected; //pawan
    isLinkFinancialSubtypeEnabled = isFinancialStandard ?? false; //pawan
    selectedFinancialCovenantSubType = null; //pawan
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  //financial description
  void onFinancialDescriptionTypeChange(String? value) {
    selectedFinancialDescriptionType = value;

    Reference selectedRef = descriptionTypes.firstWhere(
      (ref) => ref.name == value,
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
      selectedTreshold = null;
      if (selectedFinancialCovenantSubType?.id !=
          ServerConstants.covenantSubTypeIdForFrequencyFilter) {
        selectedFinancialCovenantSubType?.id = null;
      }
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
    List<Reference> allItems =
        referenceData[ReferenceDataKeys.covenantSubtype] ?? [];

    // Filter by reference2 if needed (e.g., for financial covenants)
    List<Reference> filteredByReference2 = allItems
        .where((ref) =>
            ref.reference2?.trim() ==
            ServerConstants.financialCovenantReference2)
        .toList();

    if (showOnlyNonFinancialSubtypeItems) {
      final allowedIds = {11141, 11142};

      return allItems.where((item) => allowedIds.contains(item.id)).toList();
    }

    List<Reference> others = filteredByReference2
        .where((ref) =>
            ref.id == ServerConstants.covenantSubTypeId[CovenantSubType.other])
        .toList();

    List<Reference> nonOthers = filteredByReference2
        .where((ref) =>
            ref.id != ServerConstants.covenantSubTypeId[CovenantSubType.other])
        .toList();

    return [...nonOthers, ...others];
  }

  ///filtered covenant types based on link financials statement
  List<Reference> getFilteredCovenantSubtypesByType() {
    List<Reference> allItems =
        referenceData[ReferenceDataKeys.covenantSubtype] ?? [];

    List<Reference> filtered = allItems
        .where((ref) => ref.reference2 == covenant?.covenantType?.toString())
        .toList();

    List<Reference> others = filtered
        .where((ref) =>
            ref.id == ServerConstants.covenantSubTypeId[CovenantSubType.other])
        .toList();

    List<Reference> nonOthers = filtered
        .where((ref) =>
            ref.id != ServerConstants.covenantSubTypeId[CovenantSubType.other])
        .toList();

    return [...nonOthers, ...others];
  }

  ///get status to check if covenant is new or existing
  Reference _getDefaultNewStatus() {
    return covenantStatus?.firstWhere(
          (ref) => ref.id == ServerConstants.defaultNewStatusId,
          orElse: () => Reference(id: ServerConstants.defaultNewStatusId),
        ) ??
        Reference(id: ServerConstants.defaultNewStatusId);
  }

  ///financial year end date sumbission
  void onFinancialYearEndSubmit(String? value) {
    covenant ??= Covenant();
    covenant!.financialYearEndDate = value;
    updateNextMonitoringDate();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  ///Time For Submission selection in dropdown
  void onTimeForSubmissionSelected(List<Reference> refs) {
    selectedTimeForSubmission = refs.first;
    covenant ??= Covenant();
    covenant?.timeForSubmition = selectedTimeForSubmission?.id;
    updateNextMonitoringDate();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  ///next monitor date in ui from api
  String nextMonitorDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      DateTime date = DateTime.parse(dateStr); // expects yyyy-MM-dd
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
    DateTime? resultDate = getCalculatedNextMonitoringDateRaw();
    if (resultDate == null) return;

    covenant ??= Covenant();
    covenant!.nextMonitorDate = formatDateForRequest(resultDate); // for saving
    nextMonitoringDateController.text = formatDateForUI(resultDate); // for UI

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  ///next monitor date logic based on selected financial year end date
  /// and time for submission
  DateTime? getCalculatedNextMonitoringDateRaw() {
    String? fyEndStr = covenant?.financialYearEndDate;
    String? submissionDaysStr = selectedTimeForSubmission?.name;

    if (fyEndStr == null || submissionDaysStr == null) return null;

    int submissionDays = int.tryParse(submissionDaysStr) ?? 0;
    List<String> parts = fyEndStr.split('/');
    if (parts.length != 2) return null;

    int month = int.tryParse(parts[1]) ?? 1;
    int year = DateTime.now().year;

    DateTime lastDayOfMonth = DateTime(year, month + 1, 0);
    DateTime calculatedDate =
        lastDayOfMonth.add(Duration(days: submissionDays));

    DateTime fifteenth =
        DateTime(calculatedDate.year, calculatedDate.month, 15);
    DateTime endOfMonth =
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
  void onCovenantTypeSelection(List<Reference> refs) {
    selectedCovenantType = refs.first;
    covenant?.covenantType = selectedCovenantType?.id;

    refershFieldsOnCovenantTypeChange();
    isFinancialStandard = true; //pawan
    emit(state.copyWith(
        addLinkFinancialView: false,
        addFinancialCovenat: false,
        financialViewCount: 0,
        loaderStatus: LoadingStatus.loaded));
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
    final name = (selectedCustomerRim?.customerName?.trim().isNotEmpty ?? false)
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
  void onGeneralFieldChanged(Reference selectedValue, BuildContext context) {
    generalField = selectedValue;
    covenant?.isGeneric = selectedValue.id == ServerConstants.covenantGeneralId;
    if (isSpecificSelected()) {
      DialogHelper.showCustomDialog(
        barrierDismissible: true,
        title: "covenantsConditions.conditionsEditDialog.selectFacilities".tr(),
        content: const SelectFacilitiesDialogView(),
        context: context,
      ).then(
        (value) {
          emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        },
      );
    } else {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Handles Covenant Period type change.
  void onCovenantPeriodSelect(List<Reference> refs) {
    selectedPeriod = refs.first;
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
      InternalFinancialCovenantType? value) {
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
      return '';
    }
    try {
      DateTime dateTime = DateTime.parse(isoDateString);
      return DateFormat('dd/MM').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  /// - A formatted date string or an empty string if `timestamp` is n
  /// parse Financial Year End Date
  DateTime? parseFinancialYearEndDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;

    final currentYear = DateTime.now().year;
    try {
      final parts = dateStr.split('/');
      if (parts.length == 2) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        if (day != null && month != null) {
          return DateTime(currentYear, month, day);
        }
      }
    } catch (_) {}
    try {
      final date = DateFormat("MMMd").parseStrict(dateStr);
      return DateTime(currentYear, date.month, date.day);
    } catch (_) {}

    try {
      final date = DateFormat("MMMMd").parseStrict(dateStr);
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
        final isValid = formKey.currentState?.validate() ?? false;
        if (!isValid) return false;
      }

      if (covenant?.covenantType == ServerConstants.covenantTypeIdFinancial ||
          covenant?.covenantType ==
              ServerConstants.covenantTypeIdNonFinancial ||
          isLinkFinancialView ||
          isfinancialCovenantView) {
        final String descText = financialDescriptionController.text;
        final bool hasBrackets =
            descText.contains('[') && descText.contains(']');
        final String bracketRaw = getBracketRawValue(descText);
        if ((hasBrackets && bracketRaw.isEmpty)) {
          AlertManager().showFailureToast(
              "Please enter value for selected Covenant Subtype Description inside [ ]");
          return false;
        }
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      formKey.currentState?.save();
      updateFinancialIsStandardFromSelection();
      updateGeneralIsStandardFromSelection();
      final List<Map<String, dynamic>> covenantJsonList = [];

      covenant ??= Covenant();

      final List<Customer> borrowerList = selectedCustomerRim != null
          ? [selectedCustomerRim!]
          : (selectedCustomer != null ? [selectedCustomer!] : []);

      if (borrowerList.isEmpty) {
        emit(state.copyWith(loaderStatus: LoadingStatus.loading));
        return false;
      }
      covenant!.borrowers = borrowerList;
      if (isStandardSelected && !isFinancialStandard! && isLinkFinancialView) {
        covenant?.description = selectedGeneralCovenantSubType?.name;
      }

      covenant?.isCovenant = true;
      int? generalSubTypeId = selectedGeneralCovenantSubType?.id;
      int? financialSubTypeId = selectedFinancialCovenantSubType?.id;
      String? financialSubTypeName = selectedFinancialCovenantSubType?.name;
      int? originalThresholdType = covenant?.thresholdType;

      // covenant?.covenantSubType = financialSubTypeId;
      // covenant?.description = " ${financialDescriptionController.text}";

      final bool isFinancial =
          selectedCovenantTypeEnum == CovenantType.financial;

      if (isFinancial) {
        covenant?.covenantSubType = financialSubTypeId;
        final String finText = financialDescriptionController.text.trim();
        if (finText.isNotEmpty &&
            !isLinkFinancialView &&
            !isfinancialCovenantView) {
          covenant?.description = ' $finText';
        }
      } else {
        if ((covenant?.description?.trim().isEmpty ?? true)) {
          covenant?.description = selectedGeneralCovenantSubType?.name;
        }
        covenant?.covenantSubType = generalSubTypeId;
      }

      if (isNewCovenant == true) {
        covenant?.isNew = true;
        covenant?.isDeleted = false;
        if (generalSubTypeId ==
            ServerConstants.covenantSubTypeIdForFrequencyFilter) {}
        covenant?.borrowers = borrowerList;

        if (generalSubTypeId ==
                ServerConstants.covenantSubTypeIdForFrequencyFilter &&
            isLinkFinancialView == true) {
          covenant?.thresholdType = null;
          covenant?.description = selectedGeneralCovenantSubType?.name;
        }

        if (generalSubTypeId != null) {
          covenant?.covenantSubType = generalSubTypeId;
        }

        final newJson = covenant?.toSaveNewJson();
        if (newJson != null) {
          covenantJsonList.add(newJson);
        }
      } else {
        covenant?.isNew = false;
        covenant?.isDeleted = false;
        if (generalSubTypeId ==
                ServerConstants.covenantSubTypeIdForFrequencyFilter &&
            isLinkFinancialView == true) {
          covenant?.thresholdType = null;
        }
        if (covenant?.covenantType ==
            ServerConstants.covenantTypeIdInformation) {
          if (generalSubTypeId != null) {
            covenant?.covenantSubType = generalSubTypeId;
          }
        }
        final editJson = covenant?.toSaveJson();
        if (editJson != null) {
          covenantJsonList.add(editJson);
        }
      }
      covenant?.thresholdType = originalThresholdType;

      if (isLinkFinancialView && linkedFinancialCovenants.isNotEmpty) {
        for (final linkedCovenant in linkedFinancialCovenants) {
          linkedCovenant.linkFinancialCovenant(covenant!);
          linkedCovenant.isNew = true;
          linkedCovenant.rimNo = selectedCustomer?.customerRimNo ?? 50;
          linkedCovenant.isDeleted = false;
          linkedCovenant.covenantType =
              ServerConstants.covenantTypeId[CovenantType.financial];

          linkedCovenant.isStandard = isFinancialStandard;

          if (financialSubTypeId != null && isFinancialStandard!) {
            linkedCovenant.covenantSubType = financialSubTypeId;
            // linkedCovenant.description =
            //     " ${financialDescriptionController.text}";
            // linkedCovenant.description =
            //     " ${financialDescriptionController.text}";
            final String inlineText =
                (selectedSubTypeValue?.reference1?.trim().isNotEmpty ?? false)
                    ? selectedSubTypeValue!.reference1!.trim()
                    : financialDescriptionController.text.trim();
            linkedCovenant.description = inlineText.isNotEmpty
                ? ' $inlineText'
                : financialSubTypeName; 
          } else {
            linkedCovenant.covenantSubType = null;
            linkedCovenant.thresholdType = null;
            linkedCovenant.description = (isFinancialStandard == false &&
                    customLinkFinancialDescription?.isNotEmpty == true)
                ? customLinkFinancialDescription
                : financialSubTypeName;
          }

          final json = linkedCovenant.toSaveNewJson();
          covenantJsonList.add(json);
        }
      }

      if (isfinancialCovenantView && financialCovenantSubtypes.isNotEmpty) {
        for (final subtype in financialCovenantSubtypes) {
          subtype.linkFinancialCovenant(covenant!);
          subtype.covenantType =
              ServerConstants.covenantTypeId[CovenantType.financial];
          subtype.rimNo = selectedCustomer?.customerRimNo ?? 50;
          subtype.isStandard = isFinancialStandard;

          if (financialSubTypeId != null && isFinancialStandard!) {
            subtype.covenantSubType = financialSubTypeId;
            subtype.description = financialSubTypeName;
          } else {
            subtype.covenantSubType = null;
            subtype.thresholdType = null;
            subtype.description = (isFinancialStandard == false &&
                    customAddCSFinancialDescription?.isNotEmpty == true)
                ? customAddCSFinancialDescription
                : financialSubTypeName;
          }

          subtype.isNew = true;
          subtype.isDeleted = false;
          final json = subtype.toSaveNewJson();
          covenantJsonList.add(json);
        }
      }
      await repository.saveCovenantDetails(covenantJsonList, isCovenant);
      AlertManager().showSuccessToast(
          "covenantsConditions.conditionsEditDialog.savedSuccefully".tr());
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

    Reference? financialTypeRef = referenceData[ReferenceDataKeys.covenantType]
        ?.firstWhere((ref) =>
            ref.id == ServerConstants.covenantTypeId[CovenantType.financial]);

    List<Reference> subtypeList =
        referenceData[ReferenceDataKeys.covenantSubtype] ?? [];

    List<dynamic> matchingSubtypes = financialTypeRef != null
        ? subtypeList
            .where((ref) =>
                ref.reference2?.trim() == financialTypeRef.id.toString())
            .toList()
        : [];
    if (matchingSubtypes.isNotEmpty) {
      selectedLinkFinancialCovenantSubType = matchingSubtypes.first;
      // linkedCovenant?.covenantSubType = selectedLinkFinancialCovenantSubType?.id;
    }
    Covenant linkedCovenant = Covenant()
      ..isNew = true
      ..isDeleted = false
      ..rimNo =
          selectedCustomer?.customerRimNo ?? selectedCustomer?.customerRimNo
      ..borrowers = Globals.request?.customers ?? [];

    linkedFinancialCovenants.add(linkedCovenant);

    if (financialTypeRef != null) {
      selectedLinkFinancialCovenantType = financialTypeRef;
      // selectedFinancialCovenantSubType?.id = financialTypeRef?.id;
    }

    emit(state.copyWith(
      addLinkFinancialView: true,
      financialViewCount: linkedFinancialCovenants.length,
    ));
  }

  ///delete created covenant from covenant dialog
  void deleteLinkedCovenant(Covenant covenant) {
    financialDescriptionController.clear();
    linkedFinancialCovenants.remove(covenant);

    emit(state.copyWith(
      addLinkFinancialView: linkedFinancialCovenants.isNotEmpty,
      financialViewCount: linkedFinancialCovenants.length,
    ));
  }

  /// add new view financial covenant type as per cick in dialog
  void addFinancialCovenatSubtypeView() {
    financialDescriptionController.clear();
    isfinancialCovenantView = true;

    Covenant newSubtype = Covenant()
      ..isNew = true
      ..isDeleted = false
      ..rimNo =
          selectedCustomer?.customerRimNo ?? selectedCustomer?.customerRimNo
      ..borrowers = Globals.request?.customers ?? [];

    newSubtype.linkFinancialCovenant(covenant!);

    financialCovenantSubtypes.add(newSubtype);

    emit(state.copyWith(addFinancialCovenat: true));
  }

  ///delete financial covenant type view
  void deleteFinancialCovenat(int index) {
    if (index >= 0 && index < financialCovenantSubtypes.length) {
      financialCovenantSubtypes.removeAt(index);
      emit(state.copyWith(
          addFinancialCovenat: financialCovenantSubtypes.isNotEmpty));
    }
  }

  //refershed fields when covenant type changes
  void refershFieldsOnCovenantTypeChange() {
    Reference defaultRef = Reference(name: "common.selectValue".tr());
    selectedGeneralCovenantSubType = defaultRef;
    selectedFinancialCovenantSubType = defaultRef;
    selectedPeriod = defaultRef;
    selectedFrequency = defaultRef;
    selectedAction = defaultRef;
    selectedTreshold = defaultRef;
    selectedTimeForSubmission = defaultRef;
    generalField = defaultRef;
    selectedAuditStatus = null;
    selectedBasisOfPreperation = null;
    financialDescriptionController.clear();
    // Reset date fields
    covenant?.financialYearEndDate = null;
    covenant?.nextMonitorDate = null;
    nextMonitoringDateController.text = '';
    // Reset text fields and controllers
    covenant?.entityName = null;
    state.entityName = null;
    entityNameController.text = '';
    covenant?.creditLensId = null;
    creditLensController.text = '';
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
    isfinancialCovenantView = false;
    isLinkFinancialSubtypeEnabled = true;
    covenant?.description = "";
  }
}
