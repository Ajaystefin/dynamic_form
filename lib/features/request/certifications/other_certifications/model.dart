import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/features/request/certifications/other_certifications/state.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/certification_data.dart';
import 'package:wcas_frontend/repositories/auth_repository.dart';
import 'package:wcas_frontend/repositories/certification_repository.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';

/// ViewModel for managing other certifications data and state.
class OtherCertificationsViewModel extends Cubit<OtherCertificationsState> {
  OtherCertificationsViewModel()
      : super(OtherCertificationsState(
          loaderStatus: LoadingStatus.loading,
          type: CertificationType.rm,
        ));

  late final CertificationRepository repository;

  List<Reference> allCertifications = [];
  List<Reference> attachmentCertifications = [];
  List<Reference> certifications = [];
  List<Reference> yesNoNaOptions = [];
  Map<int, CertificationData> certificationDataMap = {};

  bool isSubmitting = false;
  final formKey3 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final formKey1 = GlobalKey<FormState>();

  PageMode rmPagemode = PageMode.na;
  PageMode litPagemode = PageMode.na;
  PageMode dcPagemode = PageMode.na;
  bool isReadOnly = false;

  /// Initializes the ViewModel with the given certification type.
  /// Fetches reference data, certification details, and initializes missing certificates.
  Future<void> init(CertificationType type) async {
    logger.i('Initializing OtherCertificationsViewModel');
    rmPagemode = AuthRepository.getPageMode(RightConstants.rmCertification);
    litPagemode = AuthRepository.getPageMode(
        RightConstants.creditControlTeamCertification);
    dcPagemode =
        AuthRepository.getPageMode(RightConstants.documentationCertification);
    repository = CertificationRepository.instance;
    emit(state.copyWith(type: type, loaderStatus: LoadingStatus.loading));

    try {
      await fetchReferenceData();
      await checkReadAccess();

      await fetchCertificationDetails();
      initializeMissingCertificates();
    } catch (e, st) {
      logger.e("Initialization failed", error: e, stackTrace: st);
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Returns the localized page heading string based on the current certification type.
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
  /// Filters and categorizes certifications based on application type and reference codes.
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
          .where((ref) =>
              ref.reference2 == ServerConstants.attachmentCertificatesID)
          .toList();
      if (Utils.checkApplicationType(ApplicationType.markForward)) {
        certifications = filteredTypes
            .where((ref) =>
                ref.reference2 == ServerConstants.markForwardCertificatesID)
            .toList();
      } else {
        certifications =
            filteredTypes.where((ref) => ref.reference2 == null).toList();
      }

      allCertifications = [
        ...attachmentCertifications,
        ...certifications,
      ];

      emit(state.copyWith(
        loaderStatus: allCertifications.isNotEmpty && yesNoNaOptions.isNotEmpty
            ? LoadingStatus.loaded
            : LoadingStatus.empty,
      ));
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

      for (final certificationDetail in certificationDetailsList) {
        final int? certificationId =
            certificationDetail.certificateInformation.id;
        if (certificationId != null) {
          certificationDataMap[certificationId] = certificationDetail;
        }
      }

      emit(state.copyWith(
        loaderStatus: certificationDataMap.isNotEmpty
            ? LoadingStatus.loaded
            : LoadingStatus.empty,
      ));
    } catch (e, st) {
      logger.e("Certificate details fetch failed", error: e, stackTrace: st);
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
      rethrow;
    }
  }

  /// Initializes missing certifications by creating default entries for those not present in the data map.
  void initializeMissingCertificates() {
    for (final type in allCertifications) {
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

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
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
    if (isSubmitting) return;

    final updatedCertifications =
        certificationDataMap.values.where((data) => data.isUpdated).toList();

    isSubmitting = true;
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      await repository.postOtherCertificationDetails(updatedCertifications);

      AlertManager().showSuccessToast(
        'certification.esgCertification.certificationUpdatedSuccessfully'.tr(),
      );
      LayoutViewModel().goToNextRoute();
    } catch (e, st) {
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

  void updateSelectedOption(int referenceId, Reference selected) {
    final data = certificationDataMap[referenceId];
    if (data != null && data.selectedOption?.id != selected.id) {
      data.selectedOption = selected;
      data.isUpdated = true;
      emit(state.copyWith());
    }
  }

  void updateRemarks(int referenceId, String remarks) {
    final data = certificationDataMap[referenceId];
    if (data != null && data.remarks != remarks) {
      data.remarks = remarks;
      data.isUpdated = true;
      emit(state.copyWith());
    }
  }

  /// Returns whether the current user is in a read-only role.
  /// Checks against allowed roles for editing.
  Future<void> checkReadAccess() async {
    if (state.type == CertificationType.rm) {
      isReadOnly = rmPagemode == PageMode.view;
      debugPrint('RM Page Mode: $rmPagemode');
    } else if (state.type == CertificationType.limitInput) {
      isReadOnly = litPagemode == PageMode.view;
      debugPrint('RM Page Mode: $rmPagemode');
    } else if (state.type == CertificationType.documentation) {
      isReadOnly = dcPagemode == PageMode.view;
      debugPrint('RM Page Mode: $rmPagemode');
    } else {
      isReadOnly = false;
    }
  }
}
