import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/certifications/other_certifications/draft_handler.dart";
import "package:wcas_frontend/features/request/certifications/other_certifications/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/certification_data.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/certification_repository.dart";

/// ViewModel for managing other certifications data and state.
class OtherCertificationsViewModel extends SafeCubit<OtherCertificationsState>
    with DraftMixin<OtherCertificationsViewModel> {
  /// Creates an other certifications view model.
  OtherCertificationsViewModel()
      : super(
          OtherCertificationsState(
            loaderStatus: LoadingStatus.loading,
            type: CertificationType.rm,
          ),
        );

  /// Certification repository instance.
  late final CertificationRepository repository;

  /// List of all certification reference records.
  List<Reference> allCertifications = [];

  /// List of attachment certification reference records.
  List<Reference> attachmentCertifications = [];

  /// List of certifications displayed for the current type.
  List<Reference> certifications = [];

  /// List of Yes, No, and N/A options.
  List<Reference> yesNoNaOptions = [];

  /// Certification data mapped by reference id.
  Map<int, CertificationData> certificationDataMap = {};

  /// Indicates whether a submission is currently in progress.
  bool isSubmitting = false;

  /// Form key for the third certification form.
  GlobalKey<FormState> formKey3 = GlobalKey<FormState>();

  /// Form key for the second certification form.
  GlobalKey<FormState> formKey2 = GlobalKey<FormState>();

  /// Form key for the first certification form.
  GlobalKey<FormState> formKey1 = GlobalKey<FormState>();

  // Role-based access for the active certification type

  /// Page mode for the current certification type.
  PageMode pageMode = PageMode.na;

  /// Effective page mode used to control edit access.
  PageMode effectivePageMode = PageMode.na;

  /// Indicates whether the current certification form can be edited.
  bool get canEdit =>
      effectivePageMode == PageMode.edit; //&& Utils.canEditApplication();

  /// Indicates whether the effective page mode is not applicable.
  bool get isNA => effectivePageMode == PageMode.na;

  // --- DRAFT IDENTITY ---

  /// Draft module key used for other certifications drafts.
  @override
  String get draftModuleKey => DraftModuleKeys.certifications;

  /// Draft form key used for the current certification type.
  @override
  String get draftFormKey {
    switch (state.type) {
      case CertificationType.rm:
        return Routes.rmCertification;
      case CertificationType.documentation:
        return Routes.documentationCertification;
      case CertificationType.limitInput:
        return Routes.limitInputCertification;
    }
  }

  /// Draft handler used for other certifications auto-save functionality.
  @override
  DraftHandler<OtherCertificationsViewModel> get draftHandler =>
      OtherCertificationsDraftHandler();
  // ----------------------

  /// Initializes the ViewModel with the given certification type.
  /// Fetches reference data, certification details, and initializes missing
  /// certificates.
  Future<void> init(CertificationType type) async {
    logger.i("Initializing OtherCertificationsViewModel");

    final String rightKey = switch (type) {
      CertificationType.rm => RightConstants.rmCertification,
      CertificationType.limitInput =>
        RightConstants.creditControlTeamCertification,
      CertificationType.documentation =>
        RightConstants.documentationCertification,
    };
    pageMode = AuthRepository.getPageMode(rightKey);

    repository = CertificationRepository.instance;
    emit(state.copyWith(type: type, loaderStatus: LoadingStatus.loading));

    try {
      await fetchReferenceData();
      await checkReadAccess();

      await fetchCertificationDetails();
      initializeMissingCertificates();

      if (canEdit) {
        registerDraftCallback();
        await loadDraftIfAvailable();
      }

      emit(
        state.copyWith(
          loaderStatus:
              allCertifications.isNotEmpty && yesNoNaOptions.isNotEmpty
                  ? LoadingStatus.loaded
                  : LoadingStatus.empty,
        ),
      );
    } on Object catch (e, st) {
      logger.e("Initialization failed", error: e, stackTrace: st);
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Returns the localized page heading string based on the current
  /// certification type.
  String getPageHeading() {
    switch (state.type) {
      case CertificationType.rm:
        return "certification.otherCertifications.rmTitle";
      case CertificationType.documentation:
        return "certification.otherCertifications.documentationTitle";
      case CertificationType.limitInput:
        return "certification.otherCertifications.limitInputTitle";
    }
  }

  /// Fetches reference data for certification types and YES/NO/NA options.
  /// Filters and categorizes certifications based on application type and
  /// reference codes.
  Future<void> fetchReferenceData() async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    try {
      final Map<String, List<Reference>> referenceData =
          await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.certificateType,
        ReferenceDataKeys.yesNoNa,
      ]);

      final List<Reference> allTypes =
          referenceData[ReferenceDataKeys.certificateType] ?? [];
      yesNoNaOptions = referenceData[ReferenceDataKeys.yesNoNa] ?? [];

      final String? typeKey = ServerConstants.certificationtypeCode[state.type];

      final List<Reference> filteredTypes = allTypes
          .where((ref) => ref.reference1?.toUpperCase() == typeKey)
          .toList();

      attachmentCertifications = filteredTypes
          .where(
            (ref) => ref.reference2 == ServerConstants.attachmentCertificatesID,
          )
          .toList();
      if (Utils.checkApplicationType(ApplicationType.markForward)) {
        certifications = filteredTypes
            .where(
              (ref) =>
                  ref.reference2 == ServerConstants.markForwardCertificatesID,
            )
            .toList();
      } else {
        certifications =
            filteredTypes.where((ref) => ref.reference2 == null).toList();
      }

      allCertifications = [
        ...attachmentCertifications,
        ...certifications,
      ];
    } catch (e, st) {
      logger.e("Reference data fetch failed", error: e, stackTrace: st);
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
      rethrow;
    }
  }

  /// Fetches existing certification details from the repository.
  /// Populates the certification data map with retrieved data.
  Future<void> fetchCertificationDetails() async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    try {
      final List<CertificationData> certificationDetailsList =
          await repository.getOtherCertificationDetails(
        allCertifications,
        yesNoNaOptions,
      );

      for (final CertificationData certificationDetail
          in certificationDetailsList) {
        final int? certificationId =
            certificationDetail.certificateInformation.id;
        if (certificationId != null) {
          certificationDataMap[certificationId] = certificationDetail;
        }
      }
    } catch (e, st) {
      logger.e("Certificate details fetch failed", error: e, stackTrace: st);
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
      rethrow;
    }
  }

  /// Initializes missing certifications by creating default entries for those
  /// not present in the data map.
  void initializeMissingCertificates() {
    for (final Reference type in allCertifications) {
      certificationDataMap.putIfAbsent(
        type.id!,
        () => CertificationData(
          appCertificationId: 0,
          certificateInformation: type,
          selectedOption: getDefaultOption(),
          remarks: "",
        ),
      );
    }
  }

  /// Returns the default YES option from the YES/NO/NA reference list.
  /// Throws if the YES option is not found.
  Reference getDefaultOption() => yesNoNaOptions
      .firstWhere((option) => option.id == ServerConstants.optionYESid);

  /// Returns certification data for a given reference ID.
  /// If not found, returns a default certification data object.
  CertificationData getCertificationById(int referenceId) =>
      certificationDataMap[referenceId] ??
      CertificationData(
        appCertificationId: 0,
        certificateInformation: Reference(id: referenceId),
        selectedOption: getDefaultOption(),
        remarks: "",
      );

  /// Handles the save and continue button action.
  /// Validates data, posts certification details, and updates loader status.
  Future<void> onSaveContinueButtonPressed() async {
    if (isSubmitting) {
      return;
    }

    final List<CertificationData> updatedCertifications =
        certificationDataMap.values.where((data) => data.isUpdated).toList();

    isSubmitting = true;
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      await repository.postOtherCertificationDetails(updatedCertifications);

      unawaited(deleteDraft());

      AlertManager().showSuccessToast(
        "certification.esgCertification.certificationUpdatedSuccessfully".tr(),
      );
      LayoutViewModel().goToNextRoute();
    } on Object catch (e, st) {
      logger.e("Certificate save failed", error: e, stackTrace: st);
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    } finally {
      isSubmitting = false;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Returns the selected dropdown option for a given reference ID.
  /// Filters YES/NO/NA options based on the selected option in certification data.
  List<Reference> getSelectedDropdownOption(int referenceId) {
    final CertificationData detail = getCertificationById(referenceId);
    return yesNoNaOptions
        .where((option) => option.id == detail.selectedOption?.id)
        .toList();
  }

  /// Returns whether the current user is in a read-only role.
  /// Checks against allowed roles for editing.
  Future<void> checkReadAccess() async {
    effectivePageMode = pageMode;
  }

  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }
}
