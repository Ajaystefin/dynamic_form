import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/text_utils.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/esg_certification.dart';
import 'package:wcas_frontend/repositories/auth_repository.dart';
import 'package:wcas_frontend/repositories/certification_repository.dart';
import 'state.dart';

/// ViewModel for managing ESG Certification data and UI state.
///
/// This class handles loading reference data, fetching and submitting ESG certification
/// details, and managing form state for the ESG Certification screen.
class EsgCertificationViewModel extends Cubit<EsgCertificationState> {
  EsgCertificationViewModel()
      : super(const EsgCertificationState(loaderStatus: LoadingStatus.loading));
  late CertificationRepository repository;

  /// Global key for validating the RM comments form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Lookup/reference data
  List<Reference>? sectionTitles = [];
  List<Reference>? additionalGuidelines = [];
  List<Reference>? sicCodeLists = [];
  List<Reference>? esgSffCategories = [];

  // Certification details from API.
  late EsgCertification certifications;

  List<SffCategory> esgSffCategoriess = [];
  List<FacilityRiskRating> facilitiesRiskRatings = [];
  bool? isAdverseMedia;
  String adverseMediaSummary = "";
  List<String> excludedActivities = [];
  String additionalChecklist = "";

  // Ephemeral fields managed exclusively in the viewmodel.
  bool isSubmitting = false;
  int fieldVersion = 0;

  String? isExcluded;
  PageMode pagemode = PageMode.na;
  bool get isReadOnly => pagemode == PageMode.view;

  // Replace the raw String
  ExclusionStatus excludedStatus = ExclusionStatus.unknown;

  /// Expose a bool? so UI can do simple if(flag==true)… etc.
  bool? get excludedFlag => excludedStatus.toBool;

  /// Initializes the ViewModel by loading reference and certification data.
  ///
  /// Should be called during the screen's initialization phase.
  Future<void> init(BuildContext context) async {
    repository = CertificationRepository.instance;
    pagemode = AuthRepository.getPageMode(RightConstants.esgCertification);
    debugPrint(pagemode.toString());

    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      // ✅ Load reference data first
      await loadReferenceData();
    } catch (e) {
      debugPrint("Reference data load failed: $e");
      AlertManager().showFailureToast("Failed to load reference data");
    }

    try {
      // ✅ Load certification details separately
      await loadCertificationDetails();
    } catch (e) {
      debugPrint("Certification details load failed: $e");
      AlertManager()
          .showFailureToast("Failed to load ESG certification details");
      // ✅ Continue without breaking other flows
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // Called when the user picks “Yes”/“No”/“N/A”
  void updateExcludedValue(String label) {
    excludedStatus = ExclusionStatusX.fromApi(label);
    if (excludedStatus != ExclusionStatus.excluded) {
      excludedActivities.clear();
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Called when the user selects excluded-activity SIC codes
  void updateExcludedActivities(List<String> values) {
    excludedActivities = values;
    fieldVersion++;

    emit(state.copyWith(
      loaderStatus: LoadingStatus.loaded,
      fieldVersion: fieldVersion,
    ));
  }

  /// Loads reference data required for dropdowns and labels.
  ///
  /// Fetches data from the `ReferenceDataService` and populates local lists.
  Future<void> loadReferenceData() async {
    Map<String, List<Reference>> referenceData =
        await ReferenceDataService().getReferenceData([
      ReferenceDataKeys.esgSectionTitles,
      ReferenceDataKeys.esgAdittionalGuidance,
      ReferenceDataKeys.excludedActivityList,
      ReferenceDataKeys.esgSffCategory
    ]);
    sectionTitles = referenceData[ReferenceDataKeys.esgSectionTitles] ?? [];
    additionalGuidelines =
        referenceData[ReferenceDataKeys.esgAdittionalGuidance] ?? [];
    sicCodeLists = referenceData[ReferenceDataKeys.excludedActivityList] ?? [];
    esgSffCategories = referenceData[ReferenceDataKeys.esgSffCategory] ?? [];
  }

  /// Loads ESG certification details from the backend.
  ///
  /// Populates local fields with the fetched
  Future<void> loadCertificationDetails() async {
    try {
      certifications = await repository.getEsgCertificationDetails();
      var data = certifications;
      esgSffCategoriess = data.sffCategories ?? [];
      facilitiesRiskRatings = data.esRiskRating ?? [];
      isAdverseMedia = data.adverseMedia;
      adverseMediaSummary = data.adverseMediaSummary ?? "";
      isExcluded = data.excludedActivity;
      excludedStatus = ExclusionStatusX.fromApi(data.excludedActivity);
      excludedActivities = data.listOfExcludedActivities ?? [];
      additionalChecklist = data.additionalChecklist ?? "";
      fieldVersion++;
      emit(state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        additionalChecklist: additionalChecklist,
        fieldVersion: fieldVersion,
      ));
    } catch (ex) {
      throw ex.toString();
    }
  }

  /// Updates the additional checklist field when the user modifies the text area
  void updateAdditionalChecklist(String value) {
    additionalChecklist = value.capitalizeFirstLetter();
    emit(state.copyWith(
      loaderStatus: LoadingStatus.loaded,
      additionalChecklist: value,
    ));
  }

  /// Submits the updated ESG certification data to the backend.
  /// Prevents duplicate submissions and resets the checklist on success.
  Future<void> submitCertification() async {
    if (isSubmitting) return;
    final form = formKey.currentState;
    if (!(form?.validate() ?? false)) {
      AlertManager().showFailureToast(
        'certification.esgCertification.fixValidationErrors'.tr(),
      );
      return;
    }

    final badIndex = esgSffCategoriess.indexWhere(
      (checkbox) =>
          checkbox.isSelected == true &&
          (checkbox.briefDesc?.trim().isEmpty ?? true),
    );
    if (badIndex != -1) {
      AlertManager().showFailureToast(
        'certification.esgCertification.briefDescRequired'.tr(),
      );
      return;
    }

    isSubmitting = true;
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      final updatedCertification = certifications.copyWith(
        appRefNo: Globals.request?.applicationRefNo,
        applicationType: Globals.request?.applicationType?.name ?? '',
        role: Globals.user!.currentRole!.roleId.toString(),
        excludedActivity: excludedStatus.apiValue,
        isRequestInfoEsgExcluded: excludedStatus != ExclusionStatus.unknown,
        listOfExcludedActivities: excludedActivities,
        sffRequired: esgSffCategoriess.any((c) => c.isSelected == true),
        sffCategories: esgSffCategoriess,
        sllRequired: facilitiesRiskRatings.isNotEmpty,
        esRiskRating: facilitiesRiskRatings,
        isRequestInfoEsgRestricted: true,
        adverseMedia: isAdverseMedia,
        adverseMediaSummary: adverseMediaSummary,
        requestInfoEsgMediaScan: true,
        additionalChecklist: additionalChecklist,
        updatedBy: Globals.user?.id,
        updatedDate: DateTime.now(),
      );

      final result = await repository.postEsgCertificationDetails(
        updatedCertification,
      );

      _applyCertificationResponse(result);
      AlertManager().showSuccessToast(
        'certification.esgCertification.certificationUpdatedSuccessfully'.tr(),
      );
      fieldVersion++;
      LayoutViewModel().goToNextRoute();
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    } finally {
      isSubmitting = false;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Applies the API response to update the local ViewModel state.
  ///
  /// This is a private helper method used after a successful submission.
  void _applyCertificationResponse(EsgCertification result) {
    certifications = result;
    facilitiesRiskRatings = result.esRiskRating ?? [];
    isAdverseMedia = result.adverseMedia;
    adverseMediaSummary = result.adverseMediaSummary ?? "";
    isExcluded = result.excludedActivity;
    excludedActivities = result.listOfExcludedActivities ?? [];
    additionalChecklist = result.additionalChecklist ?? "";
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the checkbox of a specific ESG SFF category.
  ///
  /// Called when the user edits the description field
  void updateCategorySelectionById(String name, bool? newValue) {
    final index = esgSffCategoriess
        .indexWhere((categoryName) => categoryName.sffCategory == name);

    if (index >= 0) {
      esgSffCategoriess[index].isSelected = (newValue ?? false) ? true : false;
    } else if (newValue == true) {
      esgSffCategoriess
          .add(SffCategory(sffCategory: name, isSelected: true, briefDesc: ''));
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the brief description of a specific ESG SFF category.
  ///
  /// Called when the user edits the description field
  void updateCategoryBriefDescById(String name, String desc) {
    final index = esgSffCategoriess
        .indexWhere((categoryName) => categoryName.sffCategory == name);
    if (index >= 0) {
      esgSffCategoriess[index].briefDesc = desc;
    } else {
      esgSffCategoriess.add(
        SffCategory(sffCategory: name, isSelected: false, briefDesc: desc),
      );
    }
  }

  /// Updates the `isAdverseMedia` field based on user selection.
  ///
  /// Accepts "Yes" or "No" as input.
  void updateAdverseMedia(String value) {
    isAdverseMedia = (value == 'Yes');
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the summary text for adverse media.
  ///
  /// Called when the user edits the summary field
  void updateAdverseMediaSummary(String value) {
    adverseMediaSummary = value;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}
