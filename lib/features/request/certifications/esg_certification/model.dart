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
/// This class is responsible for:
/// - loading reference data and ESG certification details
/// - restoring draft values when available
/// - applying NTB-specific defaulting rules for Excluded Activity
/// - managing form state, validation, and submission
/// - handling dynamic section comments
///
/// NTB-specific behavior:
/// - for NTB applications, `Excluded Activity` defaults to `Yes` only when no
///   persisted backend value exists yet
/// - if the backend explicitly returns `YES`, `NO`, or `NA`, that value is
///   preserved and must not be overridden during initialization
///
/// UI initialization behavior:
/// - the screen stays in loading state until all required data sources complete
/// - this prevents the dropdown from briefly showing `N/A` before the final
///   NTB defaulting logic is applied
class EsgCertificationViewModel extends SafeCubit<EsgCertificationState>
    with DraftMixin<EsgCertificationViewModel> {
  /// Creates an ESG certification view model.
  EsgCertificationViewModel()
      : super(const EsgCertificationState(loaderStatus: LoadingStatus.loading));

  // --- DRAFT IDENTITY ---

  /// Draft module key used for ESG Certification drafts.
  @override
  String get draftModuleKey => DraftModuleKeys.certifications;

  /// Draft form key used for ESG Certification drafts.
  @override
  String get draftFormKey => Routes.esgCertification;

  /// Draft handler used for ESG Certification auto-save functionality.
  @override
  DraftHandler<EsgCertificationViewModel> get draftHandler =>
      EsgCertificationDraftHandler();
  // ----------------------

  /// Certification repository instance.
  late CertificationRepository repository;

  /// Global key for validating the RM comments form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Lookup/reference data

  /// ESG section title reference data.
  List<Reference>? sectionTitles = [];

  /// Additional guidance reference data.
  List<Reference>? additionalGuidelines = [];

  /// Excluded activity SIC code reference data.
  List<Reference>? sicCodeLists = [];

  /// Sustainable finance category reference data.
  List<Reference>? esgSffCategories = [];

  // Certification details from API.

  /// ESG certification details retrieved from the API.
  late EsgCertification certifications;

  /// Selected Sustainable Finance Framework categories.
  List<SffCategory> esgSffCategoriess = [];

  /// ESG facility risk ratings.
  List<FacilityRiskRating> facilitiesRiskRatings = [];

  /// Indicates whether adverse media exists.
  bool? isAdverseMedia;

  /// Adverse media summary text.
  String adverseMediaSummary = "";

  /// Selected excluded activities.
  List<String> excludedActivities = [];

  /// Additional checklist text.
  String additionalChecklist = "";

  // Ephemeral fields managed exclusively in the viewmodel.

  /// Indicates whether a submission is currently in progress.
  bool isSubmitting = false;

  /// Version counter used to force widget rebuilds.
  int fieldVersion = 0;

  /// Raw backend value for Excluded Activity (`YES`, `NO`, `NA`, or empty).
  ///
  /// This is preserved to distinguish between:
  /// - no persisted value yet
  /// - an explicitly saved `NA` value
  String? isExcluded;

  /// Current page mode.
  PageMode pagemode = PageMode.na;

  /// Indicates whether the page is in read-only mode.
  bool get isReadOnly => pagemode == PageMode.view;

  /// Normalized runtime exclusion status used by the UI and validation logic.
  ///
  /// This is derived from the backend value and may receive an NTB initial
  /// default only when no persisted backend value exists.
  ExclusionStatus excludedStatus = ExclusionStatus.unknown;

  /// Expose a bool? so UI can do simple if(flag==true)… etc.
  bool? get excludedFlag => excludedStatus.toBool;

  /// Dynamic ESG sections loaded from reference data.
  List<Reference> dynamicSections = [];

  /// Cache: refId -> latest server comment (if any)
  final Map<int, Comment> serverCommentsBySectionId = <int, Comment>{};

  /// Cache: refId -> input text currently in the textarea
  final Map<int, String> inputsByRefId = <int, String>{};

  /// Indicates whether the current application is FI.
  bool isFI = false;

  // New flags with safe defaults

  /// Indicates whether SFF is required.
  bool sffRequired = false;

  /// Indicates whether SLL is required.
  bool sllRequired = false;

  // convenience getters if you prefer expressive names

  /// Convenience flag for showing SFF-related UI.
  bool get showSff => sffRequired;

  /// Convenience flag for showing SLL-related UI.
  bool get showSll => sllRequired;

  /// Marks whether the full screen initialization flow has completed.
  ///
  /// This flag is intended for UI guards to prevent rendering partially-initialized
  /// values while reference data, API data, draft data, and NTB defaulting logic
  /// are still being resolved.
  bool isInitCompleted = false;

  // fast lookup for guidelines by section id (and optional 'part' key)

  /// Guideline lookup indexed by section id.
  final Map<int, List<Reference>> guidanceBySectionId =
      <int, List<Reference>>{};

  /// Guideline lookup indexed by section id and part key.
  final Map<int, Map<String, List<Reference>>> guidanceBySectionAndPart =
      <int, Map<String, List<Reference>>>{};

  /// Initializes the ESG Certification screen state.
  ///
  /// Initialization order is important:
  /// 1. load reference data
  /// 2. fetch dynamic section comments without changing the main loader state
  /// 3. load persisted ESG certification details from the backend
  /// 4. restore draft data when editing is allowed
  /// 5. apply NTB defaulting for Excluded Activity only if no persisted
  ///    backend value exists
  ///
  /// The final `loaded` state is emitted only after all initialization logic
  /// completes, so the UI does not briefly render intermediate values such as
  /// `N/A` before NTB defaults are applied.
  Future<void> init(BuildContext context) async {
    repository = CertificationRepository.instance;
    pagemode = AuthRepository.getPageMode(RightConstants.esgCertification);

    isInitCompleted = false;

    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    try {
      await loadReferenceData();
      await fetchAndSetStrategyComments(
        dynamicSections: dynamicSections,
        appRefNo: Globals.request?.applicationRefNo,
        manageLoader: false,
      );
    } on Object {
      AlertManager().showFailureToast(
        "certification.esgCertification.failedRefData".tr(),
      );
    }

    try {
      // Load certification details separately
      await loadCertificationDetails();
    } on Object {
      AlertManager().showFailureToast(
        "certification.esgCertification.failedEsgDetails".tr(),
      );
      // Continue without breaking other flows
    }

    if (!isReadOnly) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }

    // Apply NTB default only after API + draft have both finished loading
    _applyNtbDefaultExcludedIfNeeded();

    isInitCompleted = true;

    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        additionalChecklist: additionalChecklist,
        fieldVersion: fieldVersion++,
      ),
    );
  }

  /// Builds a multi-line guideline string from the given reference items.
  ///
  /// For each item:
  /// - uses `description` when available
  /// - falls back to `name` when `description` is null or empty
  /// - skips blank values
  ///
  /// Each non-empty value is placed on its own line.
  String _buildGuidelineText(List<Reference> guidelineReferences) {
    return guidelineReferences
        .map(
          (Reference guidelineReference) =>
              (guidelineReference.description ?? guidelineReference.name ?? "")
                  .trim(),
        )
        .where((String guidelineText) => guidelineText.isNotEmpty)
        .join("\n");
  }

  /// Returns all guideline text mapped to the given section id as a multi-line
  /// string.
  String guidelinesForSectionId(int sectionRefId) {
    final List<Reference> sectionGuidelines =
        guidanceBySectionId[sectionRefId] ?? const <Reference>[];
    return _buildGuidelineText(sectionGuidelines);
  }

  /// Returns guideline text for the given section id and part key as a
  /// multi-line string.
  ///
  /// Example part keys: `SEC1`, `SEC2`
  String guidelinesForSectionPart(int sectionRefId, String partKey) {
    final Map<String, List<Reference>>? guidelinesByPart =
        guidanceBySectionAndPart[sectionRefId];

    final List<Reference> partGuidelines =
        guidelinesByPart?[partKey] ?? const <Reference>[];
    return _buildGuidelineText(partGuidelines);
  }

  /// Returns the section reference matching the given reference id.
  ///
  /// This method searches the loaded ESG section title references and returns
  /// the first [Reference] whose id matches [refId].
  ///
  /// Why this exists:
  /// - standard ESG sections should be resolved by immutable reference id
  ///   instead of mutable section name
  /// - this prevents the UI from breaking when a user updates the displayed
  ///   section title in reference data
  ///
  /// Returns:
  /// - the matching [Reference] when found
  /// - `null` when no section exists for the provided id
  Reference? sectionRefById(int refId) {
    final List<Reference> titles = sectionTitles ?? const <Reference>[];
    for (final ref in titles) {
      if ((ref.id ?? 0) == refId) {
        return ref;
      }
    }
    return null;
  }

  /// Returns whether a section exists for the given reference id.
  ///
  /// This is a convenience helper used by the UI to decide whether a
  /// particular ESG section should be rendered.
  ///
  /// Unlike name-based checks such as `Section 1`, `Section 2`, etc.,
  /// this lookup remains stable even if the section title is renamed in
  /// reference data.
  ///
  /// Returns `true` if a matching section reference is found, otherwise `false`.
  bool hasSectionId(int refId) => sectionRefById(refId) != null;

  /// Returns the display title for the section identified by [refId].
  ///
  /// The method uses the matching section reference name when available.
  /// If the section is missing or its name is blank, [fallback] is returned
  /// instead.
  ///
  /// This helps keep the UI resilient by:
  /// - resolving sections using immutable ids
  /// - still allowing a safe fallback title when reference data is incomplete
  ///
  /// Example:
  /// - `sectionTitleById(8636, fallback: "Section 1 Excluded Activity")`
  String sectionTitleById(int refId, {String fallback = ""}) {
    final String title = (sectionRefById(refId)?.name ?? "").trim();
    return title.isNotEmpty ? title : fallback;
  }

  /// Updates the selected Excluded Activity value from the dropdown.
  ///
  /// Behavior:
  /// - selecting `Yes` sets the exclusion status to `excluded`
  /// - selecting `No` or `N/A` clears any previously selected excluded SIC
  ///   activities because the SIC list is only relevant when `Yes` is selected
  /// - selecting `Yes` triggers the warning toast prompting the user about the
  ///   related deviation request information
  ///
  /// Note:
  /// The dropdown value is treated as the user's explicit selection and must
  /// take precedence over any NTB initial default.
  void updateExcludedValue(String label) {
    final String yesLabel = "certification.esgCertification.yes".tr();
    final String noLabel = "certification.esgCertification.no".tr();
    final String naLabel = "certification.esgCertification.na".tr();

    if (label == yesLabel) {
      isExcluded = ServerConstants.esgExcludedActivityYes;
      excludedStatus = ExclusionStatus.excluded;
    } else if (label == noLabel) {
      isExcluded = ServerConstants.esgExcludedActivityNo;
      excludedStatus = ExclusionStatus.included;
    } else if (label == naLabel) {
      isExcluded = ServerConstants.esgExcludedActivityNa;
      excludedStatus = ExclusionStatus.unknown;
    }

    if (excludedStatus != ExclusionStatus.excluded) {
      excludedActivities = <String>[];
    }

    if (excludedStatus == ExclusionStatus.excluded) {
      AlertManager().showWarningToast(
        "certification.esgCertification.updateDeviationRequestInfo".tr(),
      );
    }

    fieldVersion++;

    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        fieldVersion: fieldVersion,
      ),
    );
  }

  /// Updates the exclusion status using the API value.
  void updateExcludedValueApi(String apiValue) {
    final String previousValue = (isExcluded ?? "").trim().toUpperCase();
    final String value = apiValue.trim().toUpperCase();

    final bool excludedActivityChanged = previousValue != value;

    isExcluded = value;
    excludedStatus = ExclusionStatusX.fromApi(value);

    // Clear SIC descriptions whenever parent dropdown value changes.
    // This fixes Yes -> No -> Yes showing old SIC descriptions.
    if (excludedActivityChanged) {
      excludedActivities = <String>[];
    }

    if (excludedStatus == ExclusionStatus.excluded) {
      AlertManager().showWarningToast(
        "certification.esgCertification.updateDeviationRequestInfo".tr(),
      );
    }

    fieldVersion++;

    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        fieldVersion: fieldVersion,
      ),
    );
  }

  /// Clears the currently selected excluded activity value.
  void clearExcludedValue() {
    excludedStatus = ExclusionStatus.unknown;
    isExcluded = "";
    excludedActivities = <String>[];

    fieldVersion++;

    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        fieldVersion: fieldVersion,
      ),
    );
  }

  /// Applies the NTB default for Excluded Activity only when no persisted value
  /// exists yet.
  ///
  /// Business rule:
  /// - NTB applications should initially default `Excluded Activity` to `Yes`
  /// - however, if the backend has already persisted a value (`YES`, `NO`, or
  ///   `NA`), that value must be preserved exactly as returned
  ///
  /// This prevents a saved `N/A` value from being incorrectly re-mapped to
  /// `Yes` when the screen is reopened.
  void _applyNtbDefaultExcludedIfNeeded() {
    final String rawExcludedValue = (isExcluded ?? "").trim();

    // Default to YES for NTB only when there is no persisted backend value yet.
    // If backend explicitly returned "NA", "NO", or "YES", preserve it.
    final bool hasPersistedValue = rawExcludedValue.isNotEmpty;

    if (Utils.checkApplicationType(ApplicationType.newToBank) &&
        excludedStatus == ExclusionStatus.unknown &&
        !hasPersistedValue) {
      excludedStatus = ExclusionStatus.excluded; // initial default only
      isExcluded = ServerConstants.esgExcludedActivityYes;
    }
  }

  /// Updates the selected excluded activity SIC codes.
  ///
  /// Also increments `fieldVersion` so dependent widgets can rebuild with the
  /// latest values.
  void updateExcludedActivities(List<String> values) {
    excludedActivities = List<String>.of(values);
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

    dynamicSections =
        (sectionTitles ?? const <Reference>[]).where((Reference ref) {
      final int refId = ref.id ?? 0;
      final String name = (ref.name ?? "").trim();

      if (name.isEmpty) {
        return false;
      }

      // exclude all locked standard section/part ids
      if (ServerConstants.esgSectionLockedReferenceIds.contains(refId)) {
        return false;
      }

      return true;
    }).toList();

    // Build indices from guidance → section id (+ optional part key)
    guidanceBySectionId.clear();
    guidanceBySectionAndPart.clear();

    for (final Reference guidanceRecord
        in (additionalGuidelines ?? const <Reference>[])) {
      // reference2 holds the **section id** this guidance belongs to
      final String raw = (guidanceRecord.reference2 ?? "").trim();
      if (raw.isEmpty) {
        continue;
      }

      final int? secId = int.tryParse(raw);
      if (secId == null) {
        continue;
      }

      // Add to flat per-section list
      (guidanceBySectionId[secId] ??= <Reference>[]).add(guidanceRecord);

      // If a part key exists (e.g., 'SEC1', 'SEC2'), index under it too
      final String guidancePartKey = (guidanceRecord.reference3 ?? "").trim();
      if (guidancePartKey.isNotEmpty) {
        final Map<String, List<Reference>> sub =
            guidanceBySectionAndPart[secId] ??= <String, List<Reference>>{};
        (sub[guidancePartKey] ??= <Reference>[]).add(guidanceRecord);
      }
    }
  }

  /// Loads ESG certification details from the backend and hydrates the local
  /// view model state.
  ///
  /// This method only maps and stores persisted backend values.
  /// It does not apply NTB-specific defaulting directly.
  ///
  /// NTB defaulting is intentionally deferred until the full initialization flow
  /// completes, so persisted backend values such as `NA` are not overridden
  /// prematurely.
  Future<void> loadCertificationDetails() async {
    try {
      certifications = await repository.getEsgCertificationDetails();
      final EsgCertification data = certifications;

      sffRequired = data.sffRequired ?? false;
      sllRequired = data.sllRequired ?? false;

      esgSffCategoriess = data.sffCategories ?? [];
      facilitiesRiskRatings = data.esRiskRating ?? [];
      isAdverseMedia = data.adverseMedia;
      adverseMediaSummary = data.adverseMediaSummary ?? "";
      isExcluded = data.excludedActivity;
      excludedStatus = ExclusionStatusX.fromApi(data.excludedActivity);
      excludedActivities = data.listOfExcludedActivities ?? [];
      additionalChecklist = data.additionalChecklist ?? "";
    } catch (ex) {
      rethrow;
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
    if (isSubmitting) {
      return;
    }
    final FormState? form = formKey.currentState;
    if (!(form?.validate() ?? false)) {
      AlertManager().showFailureToast(
        "certification.esgCertification.fixValidationErrors".tr(),
      );
      return;
    }

    final int badIndex = esgSffCategoriess.indexWhere(
      (checkbox) =>
          (checkbox.isSelected ?? false) &&
          (checkbox.briefDesc?.trim().isEmpty ?? true),
    );
    if (badIndex != -1) {
      AlertManager().showFailureToast(
        "certification.esgCertification.briefDescRequired".tr(),
      );
      return;
    }

    if (!isFI && (isExcluded ?? "").trim().isEmpty) {
      AlertManager().showFailureToast(
        "certification.esgCertification.excludedTextRequired".tr(),
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

    try {
      final EsgCertification updatedCertification = certifications.copyWith(
        appRefNo: Globals.request?.applicationRefNo,
        applicationType: Globals.request?.applicationType?.name ?? "",
        role: Globals.user!.currentRole!.roleId.toString(),
        excludedActivity: (isExcluded ?? "").trim(),
        isRequestInfoEsgExcluded: (isExcluded ?? "").trim().isNotEmpty,
        listOfExcludedActivities: List<String>.of(excludedActivities),
        sffRequired: esgSffCategoriess.any((c) => c.isSelected ?? false),
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

      unregisterDraftCallback();
      await deleteDraft();

      if (isFI) {
        router.go(Routes.recommendationCurrentApproval);
      } else {
        LayoutViewModel().goToNextRoute();
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    } finally {
      isSubmitting = false;
    }
  }

  /// Applies the latest saved ESG Certification response returned by the backend.
  ///
  /// This method must preserve the backend's explicit `excludedActivity` value
  /// exactly as returned (`YES`, `NO`, or `NA`).
  ///
  /// NTB defaulting is intentionally not applied here, because once a record has
  /// been saved, the persisted backend value must take precedence over any
  /// initial default rule.
  void _applyCertificationResponse(EsgCertification result) {
    certifications = result;

    sffRequired = result.sffRequired ?? false;
    sllRequired = result.sllRequired ?? false;

    facilitiesRiskRatings = result.esRiskRating ?? [];
    isAdverseMedia = result.adverseMedia;
    adverseMediaSummary = result.adverseMediaSummary ?? "";
    isExcluded = result.excludedActivity;
    excludedStatus = ExclusionStatusX.fromApi(result.excludedActivity);
    excludedActivities = result.listOfExcludedActivities ?? [];
    additionalChecklist = result.additionalChecklist ?? "";
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the checkbox of a specific ESG SFF category.
  ///
  /// Called when the user edits the description field
  void updateCategorySelectionById(String name, {bool? newValue}) {
    final int index = esgSffCategoriess
        .indexWhere((categoryName) => categoryName.sffCategory == name);

    if (index >= 0) {
      esgSffCategoriess[index].isSelected = newValue ?? false;
    } else if (newValue ?? false) {
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

  /// Returns the initial comment text for a section.
  ///
  /// If the user has already entered text for the section, that value is returned.
  /// Otherwise, the method uses the latest cached server comment and stores it in
  /// the local input cache for subsequent reads
  String initialTextOnceFor(int refId) {
    final String? userInput = inputsByRefId[refId];
    if (userInput != null) {
      return userInput;
    }

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

  /// Clears cached comment inputs.
  ///
  /// When `leaveOneBlankPerSection` is true, an empty input entry is created for
  /// each dynamic section so the UI remains ready for user input
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

  /// Fetches dynamic section comments and seeds the local input cache.
  ///
  /// Existing server comments are stored in `serverCommentsBySectionId`, and the
  /// corresponding text inputs are pre-filled in `inputsByRefId`.
  ///
  /// The optional `manageLoader` flag controls whether this method should update
  /// the screen-level loading state:
  /// - `true`: this method manages `loading` and `loaded` states itself
  /// - `false`: the caller is responsible for keeping the screen in loading state
  ///
  /// This is used during screen initialization to avoid rendering partial UI
  /// before all other data sources and NTB defaulting logic are complete.
  Future<void> fetchAndSetStrategyComments({
    List<Reference>? dynamicSections,
    String? appRefNo,
    bool manageLoader = true,
  }) async {
    try {
      if (manageLoader) {
        emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      }

      final List<Reference> sections = dynamicSections ?? this.dynamicSections;
      if (sections.isEmpty) {
        if (manageLoader) {
          emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        }
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

      if (manageLoader) {
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      }
    } on Object {
      // Keep UI stable: seed blanks for known sections
      for (final Reference ref in (dynamicSections ?? this.dynamicSections)) {
        inputsByRefId[ref.id ?? 0] = "";
      }

      if (manageLoader) {
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      }
    }
  }

  /// Saves non-empty dynamic section comments to the backend.
  ///
  /// Each dynamic section is submitted using its section id as `categoryId`.
  /// On full success, local inputs are cleared and comments are re-fetched.
  /// On partial failure, the entered inputs are preserved so the user can retry.
  Future<void> submitComments() async {
    try {
      final String appRefNo = Globals.request?.applicationRefNo ?? "";
      final int? rimNo = Globals.request?.customerRimNo;

      int successCount = 0;
      final List<String> failures = <String>[];
      final List<Reference> sectionsSnapshot =
          List<Reference>.of(dynamicSections);

      // Build and save payload per section (categoryId == ref.id)
      for (final Reference ref in sectionsSnapshot) {
        final int refId = ref.id ?? 0;
        final String text = (inputsByRefId[refId] ?? "").trim();

        if (text.isEmpty) {
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
        } on Object catch (e) {
          failures.add("refId=$refId → $e");
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
        clearCommentInputs();
        await fetchAndSetStrategyComments(
          dynamicSections: dynamicSections,
          appRefNo: appRefNo,
          manageLoader: false,
        );
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }
}
