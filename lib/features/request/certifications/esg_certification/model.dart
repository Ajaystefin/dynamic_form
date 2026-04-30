import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/draft_handler.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/esg_certification.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/certification_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";

/// ViewModel for managing ESG Certification data and UI state.
///
/// This class handles loading reference data, fetching and submitting ESG
/// certification
/// details, and managing form state for the ESG Certification screen.
class EsgCertificationViewModel extends SafeCubit<EsgCertificationState>
    with DraftMixin<EsgCertificationViewModel> {
  EsgCertificationViewModel()
      : super(const EsgCertificationState(loaderStatus: LoadingStatus.loading));

  // --- DRAFT IDENTITY ---
  @override
  String get draftModuleKey => DraftModuleKeys.certifications;
  @override
  String get draftFormKey => Routes.esgCertification;
  @override
  DraftHandler<EsgCertificationViewModel> get draftHandler =>
      EsgCertificationDraftHandler();
  // ----------------------
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

  List<Reference> dynamicSections = [];

  // Cache: refId -> latest server comment (if any)
  final Map<int, Comment> serverCommentsBySectionId = <int, Comment>{};

  // Cache: refId -> input text currently in the textarea
  final Map<int, String> inputsByRefId = <int, String>{};

  bool isFI = false;

  // New flags with safe defaults
  bool sffRequired = false;
  bool sllRequired = false;

  // convenience getters if you prefer expressive names
  bool get showSff => sffRequired;
  bool get showSll => sllRequired;

  // fast lookup for guidelines by section id (and optional 'part' key)
  final Map<int, List<Reference>> guidanceBySectionId =
      <int, List<Reference>>{};
  final Map<int, Map<String, List<Reference>>> guidanceBySectionAndPart =
      <int, Map<String, List<Reference>>>{};

  /// Initializes the ViewModel by loading reference and certification data.
  ///
  /// Should be called during the screen's initialization phase.
  Future<void> init(BuildContext context) async {
    repository = CertificationRepository.instance;
    pagemode = AuthRepository.getPageMode(RightConstants.esgCertification);

    //*****€€€ Need FI is non madatory enable this €€€*** // for checkup with request type financialInstitution
    //isFI = Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      await loadReferenceData();
      await fetchAndSetStrategyComments(
        dynamicSections: dynamicSections,
        appRefNo: Globals.request?.applicationRefNo,
      );
    } catch (e) {
      AlertManager().showFailureToast(
        "certification.esgCertification.failedRefData".tr(),
      );
    }

    try {
      // Load certification details separately
      await loadCertificationDetails();
    } catch (e) {
      AlertManager().showFailureToast(
        "certification.esgCertification.failedEsgDetails".tr(),
      );
      // Continue without breaking other flows
    }

    if (!isReadOnly) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }

    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        additionalChecklist: additionalChecklist,
        fieldVersion: fieldVersion++,
      ),
    );
  }

  // helper to join descriptions as one string, each on its own line
  String _joinGuidelineDescriptions(List<Reference> refs) {
    return refs
        .map((r) => (r.description ?? r.name ?? "").trim())
        .where((s) => s.isNotEmpty)
        .join("\n");
  }

  /// return joined guidelines for a section id (no sub-part key)
  String guidelinesForSectionId(int sectionRefId) {
    final List<Reference> items =
        guidanceBySectionId[sectionRefId] ?? const <Reference>[];
    return _joinGuidelineDescriptions(items);
  }

  /// return joined guidelines for a section id filtered by a part key (e.g.,
  /// 'SEC1', 'SEC2')
  String guidelinesForSectionPart(int sectionRefId, String partKey) {
    final Map<String, List<Reference>>? map =
        guidanceBySectionAndPart[sectionRefId];
    final List<Reference> items = map?[partKey] ?? const <Reference>[];
    return _joinGuidelineDescriptions(items);
  }

  int sectionIdAt(int index) =>
      (sectionTitles != null && sectionTitles!.length > index)
          ? (sectionTitles![index].id ?? 0)
          : 0;

  // Called when the user picks “Yes”/“No”/“N/A”
  void updateExcludedValue(String label) {
    excludedStatus = ExclusionStatusX.fromApi(label);
    if (excludedStatus != ExclusionStatus.excluded) {
      excludedActivities.clear();
    }
    if (excludedStatus == ExclusionStatus.excluded) {
      AlertManager().showWarningToast(
        "certification.esgCertification.updateDeviationRequestInfo".tr(),
      );
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void _applyNtbDefaultExcludedIfNeeded() {
    // NTB = newToBank (ID mapping in ServerConstants)
    if (Utils.checkApplicationType(ApplicationType.newToBank) &&
        excludedStatus == ExclusionStatus.unknown) {
      excludedStatus = ExclusionStatus.excluded; // shows “Yes” in dropdown
      // keep excludedActivities as-is (empty list is fine for YES unless
      // required by business)
    }
  }

  /// Called when the user selects excluded-activity SIC codes
  void updateExcludedActivities(List<String> values) {
    excludedActivities = values;
    fieldVersion++;

    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        fieldVersion: fieldVersion,
      ),
    );
  }

  /// Loads reference data required for dropdowns and labels.
  ///
  /// Fetches data from the `ReferenceDataService` and populates local lists.
  Future<void> loadReferenceData() async {
    final Map<String, List<Reference>> referenceData =
        await ReferenceDataService().getReferenceData([
      ReferenceDataKeys.esgSectionTitles,
      ReferenceDataKeys.esgAdittionalGuidance,
      ReferenceDataKeys.excludedActivityList,
      ReferenceDataKeys.esgSffCategory,
    ]);

    sectionTitles = referenceData[ReferenceDataKeys.esgSectionTitles] ?? [];
    additionalGuidelines =
        referenceData[ReferenceDataKeys.esgAdittionalGuidance] ?? [];
    sicCodeLists = referenceData[ReferenceDataKeys.excludedActivityList] ?? [];
    esgSffCategories = referenceData[ReferenceDataKeys.esgSffCategory] ?? [];

    sectionTitles?.sort((leftSectionRef, rightSectionRef) {
      final int leftId = int.tryParse("${leftSectionRef.id}") ?? 0;
      final int rightId = int.tryParse("${rightSectionRef.id}") ?? 0;
      if (leftId != 0 || rightId != 0) {
        return leftId.compareTo(rightId);
      }
      return (leftSectionRef.name ?? "")
          .toLowerCase()
          .compareTo((rightSectionRef.name ?? "").toLowerCase());
    });

    // Ensure guidance lists are old→new so the latest added always appears LAST
    // Prefer ascending by id (monotonic on your backend). If you have
    // createdDate in the model,
    // this comparator safely uses it as a secondary tie-breaker.
    additionalGuidelines?.sort((firstGuidanceRef, secondGuidanceRef) {
      final int firstGuidanceId = int.tryParse("${firstGuidanceRef.id}") ?? 0;
      final int secondGuidanceId = int.tryParse("${secondGuidanceRef.id}") ?? 0;
      if (firstGuidanceId != secondGuidanceId) {
        return firstGuidanceId.compareTo(secondGuidanceId);
      }
      // Final deterministic fallback
      return (firstGuidanceRef.name ?? "")
          .toLowerCase()
          .compareTo((secondGuidanceRef.name ?? "").toLowerCase());
    });

    // Build dynamicSections beyond your first 6
    dynamicSections =
        (sectionTitles?.length ?? 0) > 6 ? sectionTitles!.sublist(6) : [];

    // Build indices from guidance → section id (+ optional part key)
    guidanceBySectionId.clear();
    guidanceBySectionAndPart.clear();

    for (final Reference guidanceRecord
        in (additionalGuidelines ?? const <Reference>[])) {
      // reference2 holds the **section id** this guidance belongs to
      final String raw = (guidanceRecord.reference2 ?? "").trim();
      if (raw.isEmpty) continue;

      final int? secId = int.tryParse(raw);
      if (secId == null) continue;

      // Add to flat per-section list
      (guidanceBySectionId[secId] ??= <Reference>[]).add(guidanceRecord);

      // If a part key exists (e.g., 'SEC1', 'SEC2'), index under it too
      final String guidancePartKey = (guidanceRecord.reference3 ?? "").trim();
      if (guidancePartKey.isNotEmpty) {
        final Map<String, List<Reference>> sub =
            (guidanceBySectionAndPart[secId] ??= <String, List<Reference>>{});
        (sub[guidancePartKey] ??= <Reference>[]).add(guidanceRecord);
      }
    }
  }

  /// Loads ESG certification details from the backend.
  ///
  /// Populates local fields with the fetched
  Future<void> loadCertificationDetails() async {
    try {
      certifications = await repository.getEsgCertificationDetails();
      final EsgCertification data = certifications;

      sffRequired = data.sffRequired == true;
      sllRequired = data.sllRequired == true;

      esgSffCategoriess = data.sffCategories ?? [];
      facilitiesRiskRatings = data.esRiskRating ?? [];
      isAdverseMedia = data.adverseMedia;
      adverseMediaSummary = data.adverseMediaSummary ?? "";
      isExcluded = data.excludedActivity;
      excludedStatus = ExclusionStatusX.fromApi(data.excludedActivity);
      excludedActivities = data.listOfExcludedActivities ?? [];

      _applyNtbDefaultExcludedIfNeeded();

      additionalChecklist = data.additionalChecklist ?? "";
    } catch (ex) {
      throw ex.toString();
    }
  }

  /// Updates the additional checklist field when the user modifies the text
  /// area
  void updateAdditionalChecklist(String value) {
    additionalChecklist = value.capitalizeFirstLetter();
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        additionalChecklist: value,
      ),
    );
  }

  /// Submits the updated ESG certification data to the backend.
  /// Prevents duplicate submissions and resets the checklist on success.
  Future<void> submitCertification() async {
    if (isSubmitting) return;
    final FormState? form = formKey.currentState;
    if (!(form?.validate() ?? false)) {
      AlertManager().showFailureToast(
        "certification.esgCertification.fixValidationErrors".tr(),
      );
      return;
    }

    final int badIndex = esgSffCategoriess.indexWhere(
      (checkbox) =>
          checkbox.isSelected == true &&
          (checkbox.briefDesc?.trim().isEmpty ?? true),
    );
    if (badIndex != -1) {
      AlertManager().showFailureToast(
        "certification.esgCertification.briefDescRequired".tr(),
      );
      return;
    }

    if (!isFI) {
      if (excludedStatus == ExclusionStatus.excluded) {
        if (excludedActivities.isEmpty) {
          AlertManager().showFailureToast(
            "certification.esgCertification.listExcludedTextErr".tr(),
          );
          return;
        }
      }
    }

    isSubmitting = true;
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      final EsgCertification updatedCertification = certifications.copyWith(
        appRefNo: Globals.request?.applicationRefNo,
        applicationType: Globals.request?.applicationType?.name ?? "",
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

      final EsgCertification result =
          await repository.postEsgCertificationDetails(
        updatedCertification,
      );

      _applyCertificationResponse(result);

      await submitComments();

      AlertManager().showSuccessToast(
        "certification.esgCertification.certificationUpdatedSuccessfully".tr(),
      );
      fieldVersion++;

      unawaited(deleteDraft());

      if (isFI) {
        router.go(Routes.recommendationCurrentApproval);
      } else {
        LayoutViewModel().goToNextRoute();
      }
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

    sffRequired = result.sffRequired == true;
    sllRequired = result.sllRequired == true;

    facilitiesRiskRatings = result.esRiskRating ?? [];
    isAdverseMedia = result.adverseMedia;
    adverseMediaSummary = result.adverseMediaSummary ?? "";
    isExcluded = result.excludedActivity;
    excludedActivities = result.listOfExcludedActivities ?? [];
    _applyNtbDefaultExcludedIfNeeded();
    additionalChecklist = result.additionalChecklist ?? "";
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the checkbox of a specific ESG SFF category.
  ///
  /// Called when the user edits the description field
  void updateCategorySelectionById(String name, bool? newValue) {
    final int index = esgSffCategoriess
        .indexWhere((categoryName) => categoryName.sffCategory == name);

    if (index >= 0) {
      esgSffCategoriess[index].isSelected = (newValue ?? false) ? true : false;
    } else if (newValue == true) {
      esgSffCategoriess
          .add(SffCategory(sffCategory: name, isSelected: true, briefDesc: ""));
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the brief description of a specific ESG SFF category.
  ///
  /// Called when the user edits the description field
  void updateCategoryBriefDescById(String name, String desc) {
    final int index = esgSffCategoriess
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
    isAdverseMedia = (value == "certification.esgCertification.yes".tr());
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the summary text for adverse media.
  ///
  /// Called when the user edits the summary field
  void updateAdverseMediaSummary(String value) {
    adverseMediaSummary = value;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Returns the initial text to populate a section's textarea.
  /// If user has already typed, prefer that; else seed with server value.
  String initialTextOnceFor(int refId) {
    final String? userInput = inputsByRefId[refId];
    if (userInput != null) return userInput;

    final String serverText =
        serverCommentsBySectionId[refId]?.strategyComment ?? "";
    inputsByRefId[refId] = serverText; // prime for the widget
    return serverText;
  }

  /// Update textarea text for a given refId
  void updateComment(int refId, String value) {
    inputsByRefId[refId] = value;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Optional UX helper: clear all inputs (and optionally leave one blank for
  /// each section)
  void clearCommentInputs({bool leaveOneBlankPerSection = true}) {
    inputsByRefId.clear();
    if (leaveOneBlankPerSection) {
      for (final Reference ref in dynamicSections) {
        final int id = ref.id ?? 0;
        inputsByRefId[id] = "";
      }
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> fetchAndSetStrategyComments({
    List<Reference>? dynamicSections,
    String? appRefNo,
  }) async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));

      final List<Reference> sections = dynamicSections ?? this.dynamicSections;
      if (sections.isEmpty) {
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }

      serverCommentsBySectionId.clear();

      // Fetch section-by-section; do not use .map(async ...) without await
      for (final Reference ref in sections) {
        final int refId = ref.id ?? 0;

        final List<Comment> comments =
            await CommonRepository.instance.getStategyComment(
          refId,
          ServerConstants.strategyCategoryESGDynamicSection,
          appRefNo: appRefNo ?? Globals.request?.applicationRefNo,
        );

        // Take the first comment matching this categoryId, if any
        if (comments.isNotEmpty && comments.first.categoryId == refId) {
          serverCommentsBySectionId[refId] = comments.first;
        }

        // Seed inputs with server text (so the textarea shows it)
        final String seedText =
            serverCommentsBySectionId[refId]?.strategyComment?.toString() ?? "";
        inputsByRefId[refId] = seedText;
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      // Keep UI stable: seed blanks for known sections
      for (final Reference ref in (dynamicSections ?? this.dynamicSections)) {
        inputsByRefId[ref.id ?? 0] = "";
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  Future<void> submitComments() async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));

      final String appRefNo = Globals.request?.applicationRefNo ?? "";
      final int? rimNo = Globals.request?.customerRimNo;

      int successCount = 0;
      final List<String> failures = <String>[];

      // Build and save payload per section (categoryId == ref.id)
      for (final Reference ref in dynamicSections) {
        final int refId = ref.id ?? 0;
        final String text = (inputsByRefId[refId] ?? "").trim();

        if (text.isEmpty) {
          // No data to save for this section
          continue;
        }

        // Existing id if we already fetched one; else null
        final int? existingId = serverCommentsBySectionId[refId]?.id;

        final Comment payload = Comment.fromInputData(
          type: CommentsType.contract,
          strategyComment: text,
          entityType: EntityIdentifier.contract,
          categoryId: refId, // IMPORTANT: categoryId == ref_id
          strategyCategory: ServerConstants.strategyCategoryESGDynamicSection,
          id: existingId, // null for new, or existing id to update
        );

        try {
          await CommonRepository.instance.saveStategyComment(
            payload,
            appRefNo: appRefNo,
            rimNo: rimNo,
          );
          successCount++;

          // Update local cache (if your save returns a new id elsewhere, set it
          // here)
          serverCommentsBySectionId[refId] =
              payload.copyWithESGDynamicSection(id: existingId);
        } catch (e) {
          failures.add("refId=$refId → ${e.toString()}");
        }
      }

      if (successCount == 0 && failures.isEmpty) {
        // No non-empty inputs submitted; just end quietly
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }

      if (failures.isNotEmpty) {
        final String msg = failures.join("\n");
        AlertManager().showFailureToast(msg);
        // Keep inputs so the user can fix and re-try
      } else {
        // Optional UX: clear inputs after success and refresh
        clearCommentInputs(leaveOneBlankPerSection: true);
        await fetchAndSetStrategyComments(
          dynamicSections: dynamicSections,
          appRefNo: appRefNo,
        );
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }
}
