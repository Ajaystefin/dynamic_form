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

/// This view model handles data fetching, filtering, and state updates
/// for the facility-security linkage screen.
class FacilitySecurityLinkageViewModel
    extends SafeCubit<FacilitySecurityLinkageState>
    with
        DraftMixin<
            // AutoSave related changes by extended team
            FacilitySecurityLinkageViewModel> {
  FacilitySecurityLinkageViewModel()
      : super(
          FacilitySecurityLinkageState(loaderStatus: LoadingStatus.loading),
        );
  late FacilitySecurityRepository repository;
  List<Security> originalSecurities = [];
  List<Facility> originalFacilities = [];
  List<Security> securities = [];
  List<Facility> facilities = [];
  List<Reference> securityTypeOptions = [];
  List<Reference> facilityTypeOptions = [];

  PageMode pageMode = PageMode.na;

  bool get canEdit => pageMode == PageMode.edit;
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
  Future<void> init(context, overridePageMode) async {
    logger.i("initialising FacilitySecurityLinkageViewModel");
    pageMode = overridePageMode ??
        AuthRepository.getPageMode(RightConstants.facilitySecurityLinkage);
    repository = FacilitySecurityRepository.instance;

    await initAPIMethod();

    // AutoSave related changes by extended team
    if (canEdit) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }
  }

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
    } catch (e) {
      if (e.toString().isNotEmpty) {
        AlertManager().showFailureToast(e.toString());
      }
    }
  }

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
    } catch (e) {
      rethrow;
    }
  }

//appReffNo - 202502APNIS027140
  /// Fetches the list of security summaries for the given [appReffNo].
  ///
  /// Emits a [LoadingStatus.loaded] state on success or
  /// [LoadingStatus.error] on failure.
  Future<void> getSecuritySummaryList() async {
    try {
      securities = await repository.getLinkageSecuritySummaryList();
      originalSecurities = List.from(securities);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getFacilitySummaryList() async {
    try {
      facilities = await repository.getLinkageFacility();
      originalFacilities = List.from(facilities);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
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

  void filterBySecurityType(String? securityCode) {
    securities
        .where((item) => item.securityType?.name == securityCode)
        .toList();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  String? securityNumberFilter, securityTypeFilter;

  Future<void> onFilter({
    required String value,
    required FilterType filterType,
    bool caseInsensitive = true, // keep defaults helpful for users
    bool useContains = true, // contains by default, equals if you want strict
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
      final bool numberOk = kwNumber.isEmpty
          ? true
          : (useContains ? candNum.contains(kwNumber) : candNum == kwNumber);

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
      final bool typeOk = kwType.isEmpty
          ? true
          : (useContains ? candType.contains(kwType) : candType == kwType);

      return numberOk && typeOk;
    }).toList();
    // Update the list the UI renders
    originalSecurities = filtered;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

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

  int? toIntOrNull(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  // Normalizer used only when caseInsensitive=true
  String norm(String? value) => (value ?? "").toLowerCase().trim();

  // AutoSave related changes by extended team
  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }
}
