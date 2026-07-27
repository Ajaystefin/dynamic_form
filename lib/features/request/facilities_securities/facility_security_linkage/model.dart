import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart"; // AutoSave related changes by extended team
import "package:wcas_frontend/core/services/draft/draft_mixin.dart"; // AutoSave related changes by extended team
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/view.dart";
import "package:wcas_frontend/features/request/facilities_securities/facility_security_linkage/draft_handler.dart"; // AutoSave related changes by extended team
import "package:wcas_frontend/features/request/facilities_securities/facility_security_linkage/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";
import "package:wcas_frontend/models/request/facility_security/security.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";

/// View model responsible for managing facility-security linkage data,
/// filtering, draft handling, and screen state updates.
class FacilitySecurityLinkageViewModel
    extends SafeCubit<FacilitySecurityLinkageState>
    with
        DraftMixin<
            // AutoSave related changes by extended team
            FacilitySecurityLinkageViewModel> {
  /// Creates a facility-security linkage view model with the initial
  /// loading state.
  FacilitySecurityLinkageViewModel()
      : super(
          const FacilitySecurityLinkageState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

  /// Repository used for facility-security linkage operations.
  late FacilitySecurityRepository repository;

  /// Original security snapshot used for comparison and reset operations.
  List<Security> originalSecurities = [];

  /// Original facility snapshot used for comparison and reset operations.
  List<Facility> originalFacilities = [];

  /// Security records displayed in the linkage screen.
  List<Security> securities = [];

  /// Facility records displayed in the linkage screen.
  List<Facility> facilities = [];

  /// Available security type filter options.
  List<Reference> securityTypeOptions = [];

  /// Available facility type filter options.
  List<Reference> facilityTypeOptions = [];

  /// Current page mode determined by user access rights.
  PageMode pageMode = PageMode.na;

  /// Returns whether the current user can edit the linkage screen.
  bool get canEdit => pageMode == PageMode.edit;

  /// Global key for the facility-security linkage form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // AutoSave related changes by extended team
  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.facilitiesAndSecurities;

  @override
  String get draftFormKey => Routes.facilitySecurityLinkage;

  @override
  DraftHandler<FacilitySecurityLinkageViewModel> get draftHandler =>
      FacilitySecurityLinkageDraftHandler();

  // ---------------------------------------------------------------------------

  /// Initializes the view model by setting up the repository and
  /// fetching the security summary list using the application reference number.
  Future<void> init(BuildContext? context, PageMode? overridePageMode) async {
    logger.i("initialising FacilitySecurityLinkageViewModel");
    pageMode = overridePageMode ??
        AuthRepository.getPageMode(RightConstants.facilitySecurityLinkage);
    // Can edit the RR type application if initialted by CA
    // final bool isInitiatedRR =
    //     Utils.checkRole(UserRole.creditAnalyst) && Globals.checkIsInitiated();
    // if (isInitiatedRR) {
    //   pageMode = PageMode.edit;
    // }
    repository = FacilitySecurityRepository.instance;

    await initAPIMethod();

    // AutoSave related changes by extended team
    if (canEdit) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }
  }

  /// Initializes the facility-security linkage screen.
  ///
  /// Loads required reference data, security records, and facility
  /// records, then clears any existing draft data and updates the
  /// screen state.
  Future<void> initAPIMethod() async {
    try {
      await Future.wait([
        getReferenceData(),
        getSecuritySummaryList(),
        getFacilitySummaryList(),
      ]);
      unawaited(
        deleteDraft(),
      ); // fire-and-forget: remove backend draft now that data is saved  // AutoSave related changes by extended team
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      if (e.toString().isNotEmpty) {
        AlertManager().showFailureToast(e.toString());
      }
    }
  }

  /// Retrieves reference data required by the facility-security
  /// linkage screen.
  ///
  /// Loads available security type and facility type options used
  /// for filtering and selection.
  Future<void> getReferenceData() async {
    try {
      final Map<String, List<Reference>> referenceData =
          await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.securityType,
        ReferenceDataKeys.facilityTypes,
      ]);
      securityTypeOptions = referenceData[ReferenceDataKeys.securityType] ?? [];
      facilityTypeOptions =
          referenceData[ReferenceDataKeys.facilityTypes] ?? [];
    } on Object {
      rethrow;
    }
  }

//appReffNo - 202502APNIS027140
  /// Fetches the list of security summaries for the given [`appReffNo`].
  ///
  /// Emits a [LoadingStatus.loaded] state on success or
  /// [LoadingStatus.error] on failure.
  Future<void> getSecuritySummaryList() async {
    try {
      securities = await repository.getLinkageSecuritySummaryList();

      // originalSecurities = List.from(securities);

      originalSecurities = {
        for (final Security security in securities)
          security.securityId: security,
      }.values.toList();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object {
      rethrow;
    }
  }

  /// Retrieves facility records used in the facility-security linkage
  /// screen.
  ///
  /// Loads the available facilities and preserves an original snapshot
  /// for comparison, filtering, and reset operations.
  Future<void> getFacilitySummaryList() async {
    try {
      facilities = await repository.getLinkageFacility();
      originalFacilities = List.from(facilities);

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object {
      rethrow;
    }
  }

  /// Filters the [securities] by the given [securityNo].
  ///
  /// Emits a [LoadingStatus.loaded] state after filtering.
  void filterBySecurityNumber(String? securityNo) {
    securities
        .where((item) => item.securityType.toString() == securityNo)
        .toList();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Filters securities by the selected security type.
  ///
  /// Updates the rendered security list to include only securities
  /// matching the specified security type.
  void filterBySecurityType(String? securityCode) {
    securities
        .where((item) => item.securityType?.name == securityCode)
        .toList();

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Current filter value for the security number column.
  String? securityNumberFilter;

  /// Current filter value for the security type column.
  String? securityTypeFilter;

  /// Filters the security list using the active filter criteria.
  ///
  /// Supports filtering by:
  /// - Security number
  /// - Security type
  ///
  /// Filters are applied cumulatively and always evaluated against the
  /// original security collection.
  Future<void> onFilter({
    required String value,
    required FilterType filterType,
    bool caseInsensitive = true,
    bool useContains = true,
  }) async {
    // Persist the just-edited filter value
    if (filterType == FilterType.securityNumber) {
      securityNumberFilter = value;
    } else if (filterType == FilterType.securityType) {
      securityTypeFilter = value;
    }

    // Read both active filters (combine them)
    final String kwNumberRaw = (securityNumberFilter ?? "").trim();
    final String kwTypeRaw = (securityTypeFilter ?? "").trim();

    final String kwNumber = caseInsensitive ? norm(kwNumberRaw) : kwNumberRaw;
    final String kwType = caseInsensitive ? norm(kwTypeRaw) : kwTypeRaw;

    // Always filter from MASTER list (securities)
    final List<Security> source = List<Security>.from(securities);

    final List<Security> filtered = source.where((s) {
      // --- Security Number ---
      final String candNumRaw = (s.securityNumber?.toString() ?? "").trim();
      final String candNum = caseInsensitive ? norm(candNumRaw) : candNumRaw;
      final bool numberOk = kwNumber.isEmpty ||
          (useContains ? candNum.contains(kwNumber) : candNum == kwNumber);

      // --- Type of Security: match against what UI shows ---
      // Use the CODE shown in UI + the reference name.
      final String codeRaw =
          (s.securityCode ?? "").trim(); // e.g., ASR / PGT / ASI
      final String nameRaw =
          (s.securityType?.name ?? "").trim(); // sometimes empty
      final String ref1Raw = (s.securityType?.reference1 ?? "").trim();

      // Join all non-empty parts so users can search "ASR" or "ASR Something"
      final String candTypeRaw =
          [codeRaw, nameRaw, ref1Raw].where((e) => e.isNotEmpty).join(" ");

      final String candType = caseInsensitive ? norm(candTypeRaw) : candTypeRaw;
      final bool typeOk = kwType.isEmpty ||
          (useContains ? candType.contains(kwType) : candType == kwType);

      return numberOk && typeOk;
    }).toList();
    // Update the list the UI renders
    originalSecurities = filtered;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Opens the facility selection dialog for the specified security.
  ///
  /// Refreshes facility-security linkage data when changes are saved
  /// from the dialog.
  Future<void> onPressedItemSecurityNo(
    BuildContext context, {
    Security? security,
  }) async {
    final data = await DialogHelper.showCustomDialog(
      barrierDismissible: false,
      width: 700.w,
      title: "security.securityFacilityLinkage.select_facilities".tr(),
      content: SelectFacilitiesDialogView(
        securityItem: security,
        isLinakage: true,
        overridePageMode: pageMode,
      ),
      context: context,
    );

    if (data != null) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      await initAPIMethod();
    }
  }

  /// Safely converts the provided value to an integer.
  ///
  /// Supports `int`, `num`, and numeric string values.
  /// Returns `null` when conversion is not possible.
  int? toIntOrNull(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }

  /// Normalizes text values for case-insensitive comparisons.
  ///
  /// Converts the value to lowercase and trims surrounding whitespace.
  String norm(String? value) => (value ?? "").toLowerCase().trim();

  // AutoSave related changes by extended team
  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }
}
