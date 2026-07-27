import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/securities_summary/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/security.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";

/// Available filter types for the securities summary screen.
enum Filter {
  /// Filters securities by security number.
  securityNumber,

  /// Filters securities by security type.
  securityType,
}

/// View model responsible for managing security summary data,
/// filtering, and screen state updates.
class SecuritiesSummaryViewModel extends SafeCubit<SecuritiesSummaryState> {
  /// Creates a securities summary view model with the initial
  /// loading state.
  SecuritiesSummaryViewModel()
      : super(
          SecuritiesSummaryState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

  /// Repository used for security summary operations.
  FacilitySecurityRepository repository = FacilitySecurityRepository();

  /// List of security summaries associated with the current application.
  List<Security> securities = [];

  /// Filtered security list displayed in the UI.
  List<Security> filteredData = [];

  /// Current security number filter value.
  String? securityNumber;

  /// Current security type filter value.
  String? securityType;

  /// Available security type filter options.
  List<Reference> securityTypeOptions = [];

  /// Returns whether the current request belongs to the
  /// Financial Institution business segment.
  bool get isFIFlow =>
      Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

  /// Page mode used when navigating to the create security screen.
  PageMode? createSecurityPageMode;

  /// Returns whether the current user can create or delete securities.
  bool get canCreateOrDeleteSecurity =>
      AuthRepository.getPageMode(RightConstants.createSecurity) ==
      PageMode.edit;

  // createSecurityPageMode == PageMode.edit &&
  // !Utils.inDocumentationQueue(); // && Utils.canEditApplication();

  /// Initializes the view model by setting up the repository and
  /// fetching the security summary list using the application reference number.
  Future<void> init({PageMode? pageMode}) async {
    logger.i("initialising SecuritiesSummaryViewModel");

    createSecurityPageMode =
        pageMode ?? AuthRepository.getPageMode(RightConstants.createSecurity);

    try {
      await _fetchSecurityTypeReferenceData();
    } on Object catch (e) {
      logger.e("Failed to fetch security type reference data: $e");
      securityTypeOptions = [];
    }

    // need to update this argument based on dialog box generates from facility
    // summary . remove accepting from global variable
    await getSecurities();
  }

  /// Fetches the list of security summaries for the given [`appReffNo`].
  ///
  /// Emits a [LoadingStatus.loaded] state on success or
  /// [LoadingStatus.error] on failure.
  Future<void> getSecurities() async {
    try {
      securities = await repository.getSecuritySummaryList();
      filteredData = securities;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Filters the [securities] by the given [securityNo].
  ///
  /// Emits a [LoadingStatus.loaded] state after filtering.
  void filterBySecurityNumber(String? securityNo) {
    securities = securities
        .where((item) => item.securityNumber.toString() == securityNo)
        .toList();
    logger.i(securities.toString());
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Filters the [securities] by the given [securityCode].
  ///
  /// Emits a [LoadingStatus.loaded] state after filtering.
  void filterBySecurityType(String? securityCode) {
    securities = securities
        .where((item) => item.securityCode.toString() == securityCode)
        .toList();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Deletes the specified security and refreshes the summary list.
  Future<void> deleteSecurityDetails(int? securityId) async {
    emit(state.copyWith(deleteButtonStatus: LoadingStatus.loading));
    try {
      await repository.deleteSecurityDetails(securityId);
      await getSecurities(); // to fetch the list again
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }

    emit(state.copyWith(deleteButtonStatus: LoadingStatus.loaded));
  }

  /// Applies the specified filter and updates the displayed
  /// security summary data.
  void onFilter(
    Filter filter, {
    required String value,
  }) {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    filteredData = securities.where((data) {
      switch (filter) {
        case Filter.securityNumber:
          return data.securityNumber.toString().contains(value.toUpperCase());
        case Filter.securityType:
          final String keyword = value.trim().toUpperCase();
          final String securityTypeName =
              securityTypeReferenceName(data).toUpperCase();
          final String securityCode =
              (data.securityCode ?? "").trim().toUpperCase();

          return securityTypeName.contains(keyword) ||
              securityCode.contains(keyword);
      }
    }).toList();

    // Update filter control values
    switch (filter) {
      case Filter.securityNumber:
        securityNumber = value;
      case Filter.securityType:
        securityType = value;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> _fetchSecurityTypeReferenceData() async {
    final String securityTypeKey = isFIFlow
        ? ReferenceDataKeys.fiSecurityType
        : ReferenceDataKeys.securityType;

    final Map<String, List<Reference>> referenceData =
        await ReferenceDataService().getReferenceData([securityTypeKey]);

    securityTypeOptions = referenceData[securityTypeKey] ?? [];
  }

  /// Resolves the security type display name using:
  /// 1. securityCode -> reference3 match (preferred, same as linkage dialog)
  /// 2. securityType id -> reference id match
  /// 3. fallback to code
  String securityTypeReferenceName(Security security) {
    final String normalizedCode =
        (security.securityCode ?? "").trim().toUpperCase();

    if (normalizedCode.isNotEmpty) {
      final Reference matchedByCode = securityTypeOptions.firstWhere(
        (Reference referenceItem) =>
            (referenceItem.reference3 ?? "").trim().toUpperCase() ==
            normalizedCode,
        orElse: Reference.new,
      );

      final String matchedName = (matchedByCode.name ?? "").trim();
      if (matchedName.isNotEmpty) {
        return matchedName;
      }
    }

    final Object? rawSecurityType = security.securityType;
    final int? securityTypeId = rawSecurityType is int
        ? rawSecurityType
        : rawSecurityType is Reference
            ? rawSecurityType.id
            : null;

    if (securityTypeId != null) {
      final Reference matchedById = securityTypeOptions.firstWhere(
        (Reference referenceItem) => referenceItem.id == securityTypeId,
        orElse: Reference.new,
      );

      final String matchedName = (matchedById.name ?? "").trim();
      if (matchedName.isNotEmpty) {
        return matchedName;
      }
    }

    return normalizedCode;
  }
}
