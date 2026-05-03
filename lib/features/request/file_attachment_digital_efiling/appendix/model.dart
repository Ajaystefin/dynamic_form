import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:path/path.dart" as path;
import "package:uuid/uuid.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/services/file_upload_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/draft_handler.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/country.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/file_attachment/appendix.dart"
    show Appendix, FiAppendixXlsxResponse, FiAppendixXlsxRow;
import "package:wcas_frontend/models/request/file_attachment/appendix_comment.dart";
import "package:wcas_frontend/models/request/file_attachment/appendix_entry.dart";
import "package:wcas_frontend/models/request/file_attachment/appendix_image.dart";
import "package:wcas_frontend/models/request/file_attachment/business_segment_payload.dart";
import "package:wcas_frontend/models/request/file_attachment/document.dart";
import "package:wcas_frontend/models/request/file_attachment/group_corporate_structure_payload.dart";
import "package:wcas_frontend/repositories/appendix_repository.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";

/// Image slot identifiers for the Country section.
enum CountryImage { ratingBar, countryMap, governmentIndicators }

/// ViewModel for Appendix (Country & FI Bank sections).
/// - Defers `emit` and toast calls to the next frame to avoid overlay timing
/// issues on Web.
/// - Guards list operations to avoid “Bad state: No element”.
class AppendixViewModel extends SafeCubit<AppendixState>
    with DraftMixin<AppendixViewModel> {
  AppendixViewModel({FileUploadService? files})
      : _fileService = files ?? FileUploadService.instance,
        super(const AppendixState());

  // --------------------- Runtime/UI state ---------------------
  LoadingStatus loaderStatus = LoadingStatus.loading;

  final UnifiedEditorController gcsController = UnifiedEditorController();
  final String groupCorporateStructureEditorId = const Uuid().v4();
  final List<UnifiedEditorController> commentControllers =
      <UnifiedEditorController>[];
  final UnifiedEditorController commentController = UnifiedEditorController();
  final ScrollController scrollController = ScrollController();

  String? error;
  String? requestRefNo;
  String? strategyComment;
  String? selectedRating;
  Comment? commentData;

  // Misc
  String? name;
  String? errorMessage;
  DateTime? selectedDate;
  String? applicationId;

  final Map<String, int> _fetchedStrengthCounts = <String, int>{};
  final Map<String, int> _fetchedThreatCounts = <String, int>{};

  // Legacy/global list used by old screens only. Keep isolated from new flows.
  final List<PlatformFile> selectedFiles = <PlatformFile>[];
  List<Reference> sAndP = <Reference>[];

  List<Reference> fileType = <Reference>[];

  final List<Document> uploadedDocuments = <Document>[];
  final FileUploadService _fileService;
  Map<String, List<Reference>> referenceData = <String, List<Reference>>{};

  bool showCorporateSection = false;
  bool showFinancialSection = true;
  bool showFinancialCFSection = false;

  List<Country>? countries;
  ApplicationDetails? applicationDetails;

  // Comments
  final List<Comment> comments = <Comment>[];
  Comment? comment;
  final List<AppendixComment> backendComments = <AppendixComment>[];
  bool _isFetchingComments = false;
  final Map<String, int> _entryIdToRemarkId = <String, int>{};
  int? _groupCorporateRemarkId; // kept for group-only comment update

  // For Bank (Financial)
  final List<int?> bankFinancialFileIds = <int?>[];

  // For Country slots
  final Map<CountryImage, List<int?>> countryFileIds =
      <CountryImage, List<int?>>{
    CountryImage.ratingBar: <int?>[],
    CountryImage.countryMap: <int?>[],
    CountryImage.governmentIndicators: <int?>[],
  };

  /// FI - Bank: fetched/routed financial files (images & excels)
  final List<PlatformFile> bankFinancialFiles = <PlatformFile>[];

  // ----------- XLSX Extract (server list to render) -----------
  /// Raw response payload (optional)
  List<dynamic> fiExtractRaw = <dynamic>[];
// RIM No dropdown support
  List<String> rimNumbers = [];
  String? selectedRimNumber;
  List<FiAppendixXlsxRow> allExcelRows = []; // store all rows before filtering
  /// Typed rows for UI binding
  final List<FiAppendixXlsxRow> fiServerRows = <FiAppendixXlsxRow>[];

// --------------------- Page access ---------------------
  PageMode pageMode = PageMode.na;
  PageMode effectivePageMode = PageMode.na;

  bool get canEdit => effectivePageMode == PageMode.edit;
  bool get isReadOnly => effectivePageMode == PageMode.view;
  bool get isNA => effectivePageMode == PageMode.na;

  @visibleForTesting
  bool get riskRatingEditOverrideForTest => riskRatingEditOverride;

  @visibleForTesting
  PageMode computeEffectivePageModeForTest(PageMode mode) {
    return (mode == PageMode.view && riskRatingEditOverride)
        ? PageMode.edit
        : mode;
  }

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.fileAttachmentAndDigitalEFiling;

  @override
  String get draftFormKey => Routes.appendix;

  @override
  DraftHandler<AppendixViewModel> get draftHandler => AppendixDraftHandler();

  // ---------------------------------------------------------------------------

  void _ensureGrowableLists() {
    appendix
      ..strengths = List<String>.of(appendix.strengths)
      ..threats = List<String>.of(appendix.threats)
      ..importPartners = List<String>.of(appendix.importPartners)
      ..exportPartners = List<String>.of(appendix.exportPartners)
      ..entries = List<AppendixEntry>.of(appendix.entries);
  }

  bool get isAppendixReadOnly => !_canEditAppendix();

  bool _canEditAppendix() {
    // PageMode is the first gate
    if (!canEdit) return false;

    final userRole = Globals.user?.currentRole?.userRole;
    final bool isRiskRatingApp =
        Utils.checkApplicationType(ApplicationType.riskRatingChange);

    const editableRoles = [
      UserRole.relationshipOfficer,
      UserRole.relationshipManager,
      UserRole.businessUnitHead,
    ];

    const conditionalEditRoles = [
      UserRole.creditAnalyst,
      UserRole.creditCordinator,
    ];

    if (editableRoles.contains(userRole)) return true;

    if (conditionalEditRoles.contains(userRole)) {
      return isRiskRatingApp;
    }

    return false;
  }

  bool _requireAppendixEditPermission() {
    if (_canEditAppendix()) return true;

    _toastSafe(
      () => AlertManager().showFailureToast(
        // Localize as needed, you already use .tr()
        "eDigitalFilingFileAttachments.appendix.userRoleNotAllowedCCPA".tr(),
      ),
    );
    return false;
  }

  /// Single minimal method to fetch the XLSX JSON payload (on-demand)
  Future<void> getFiAppendixXlsx() async {
    final String? appRef = Globals.request?.applicationRefNo?.trim();

    try {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loading));

      fiExtractRaw =
          await AppendixRepository.instance.fetchFiAppendixXlsx(appRef!);

      final FiAppendixXlsxResponse response =
          FiAppendixXlsxResponse.fromResponseData(fiExtractRaw);

      fiServerRows
        ..clear()
        ..addAll(response.rows);

      _toastSafe(
        () => AlertManager()
            .showSuccessToast("Fetched ${fiServerRows.length} record(s)"),
      );
    } catch (e) {
      _toastSafe(() => AlertManager().showFailureToast(e.toString()));
    } finally {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
      refresh();
    }
  }

  Future<void> autoLoadFiAppendixXlsx() async {
    final String? appRef = Globals.request?.applicationRefNo?.trim();
    if (appRef == null || appRef.isEmpty) return;

    try {
      final dynamic raw =
          await AppendixRepository.instance.fetchFiAppendixXlsx(appRef);

      final FiAppendixXlsxResponse response =
          FiAppendixXlsxResponse.fromResponseData(raw);

      // Store all rows (unfiltered)
      allExcelRows
        ..clear()
        ..addAll(response.rows);

      if (selectedRimNumber != null) {
        onSelectRim(selectedRimNumber!);
      } else {
        fiServerRows
          ..clear()
          ..addAll(allExcelRows);
      }
      // Build dropdown rim numbers
      // rimNumbers =
      //     allExcelRows.map((row) => row.rimNo.toString()).toSet().toList();

      rimNumbers.sort();

      // Set default selected RIM
      if (selectedRimNumber == null && rimNumbers.isNotEmpty) {
        selectedRimNumber = rimNumbers.first;
      }

      // Filter initial rows
      _filterExcelRows();

      refresh();
    } catch (_) {
      // silent
    }
  }

  void _filterExcelRows() {
    if (selectedRimNumber == null) {
      fiServerRows
        ..clear()
        ..addAll(allExcelRows);
      return;
    }

    final int selected = int.tryParse(selectedRimNumber!) ?? -1;

    fiServerRows
      ..clear()
      ..addAll(
        allExcelRows.where((row) => row.rimNo == selected),
      );
  }

  void onSelectRim(String rimNo) {
    selectedRimNumber = rimNo;
    final int selected = int.tryParse(rimNo) ?? -1;

    fiServerRows
      ..clear()
      ..addAll(allExcelRows.where((row) => row.rimNo == selected));

    refresh();
  }

  /// Replaces fetchRimsFromCentralRiskBureau:
  /// Loads application details and builds rimNumbers from borrowers
  /// filtered to rimType == "belowInvestmentGradeBanks".
  Future<void> getApplicationDetails(String? applicationId) async {
    try {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loading));

      applicationDetails = await CustomerRepository.instance
          .getApplicationDetails(appRefNo: applicationId);

      // If no valid application data, reset and bail.
      if (applicationDetails?.rimNo == null) {
        rimNumbers.clear();
        selectedRimNumber = null;

        _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }

      // Read borrowers (typed list as per your code usage)
      final List<Customer> borrowers = applicationDetails?.borrowers ?? [];

      // Use FIRST borrower's type as the selection anchor
      final String selectedType = borrowers.isNotEmpty
          ? (borrowers[0].type ?? "").toString().trim().toLowerCase()
          : "";

      // If no type available, clear and exit gracefully
      if (selectedType.isEmpty) {
        rimNumbers.clear();
        selectedRimNumber = null;
        _filterExcelRows();
        return;
      }

      // Filter borrowers by the same type as the first borrower
      final List<String> rims = borrowers
          .where((b) {
            final typeValue = (b.type ?? "").toString().trim().toLowerCase();
            final match = typeValue == selectedType;
            return match;
          })
          .map((b) {
            final rim = b.customerRimNo?.toString() ?? "";
            return rim;
          })
          .where((s) => s.isNotEmpty)
          .toSet() // unique
          .toList()
        ..sort();

      rimNumbers
        ..clear()
        ..addAll(rims);

      selectedRimNumber = rimNumbers.isNotEmpty ? rimNumbers.first : null;

      // If your Excel rows are already loaded, this will re-apply the grid
      // filter
      _filterExcelRows();
    } catch (e, st) {
      debugPrint("getApplicationDetails error: $e\n$st");
    } finally {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Safe display for the dynamic `fileNames` field (string | list | null).
  String fileNamesToText(dynamic fileNames) {
    if (fileNames == null) return "-";
    if (fileNames is String) {
      final String s = fileNames.trim();
      return s.isEmpty ? "-" : s;
    }
    if (fileNames is List) {
      final List<String> parts = fileNames
          .map((dynamic e) => (e?.toString() ?? "").trim())
          .where((String s) => s.isNotEmpty)
          .toList();
      return parts.isEmpty ? "-" : parts.join(", ");
    }
    return fileNames.toString();
  }

  // ----------- End XLSX Extract -----------

  /// Country section image slots (selected locally)
  final Map<CountryImage, List<PlatformFile>> countryFiles =
      <CountryImage, List<PlatformFile>>{
    CountryImage.ratingBar: <PlatformFile>[],
    CountryImage.countryMap: <PlatformFile>[],
    CountryImage.governmentIndicators: <PlatformFile>[],
  };

  /// FI Key Financial Figures
  List<PlatformFile> fiKeyFinancialFiguresExcelFiles = <PlatformFile>[];
  List<PlatformFile> fiKeyFinancialFiguresImageFiles = <PlatformFile>[];

  // Optional: if you render previews / keep ids for deletes
  final List<int?> fiExtractXlsxIds = <int?>[];
  final List<PlatformFile> fiExtractXlsxFiles = <PlatformFile>[];

  String selectedSectionType = ServerConstants.country;
  late CustomerRepository repositoryCustomer;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController draftShadowController = TextEditingController();
  Appendix appendix = Appendix();
  final TextEditingController draftController = TextEditingController();
  // --------------------- Lifecycle ---------------------
  Future<void> init(BuildContext context) async {
    // 1. Resolve page access FIRST
    pageMode = AuthRepository.getPageMode(
      RightConstants.appendix, //  make sure this exists
    );
    effectivePageMode = computeEffectivePageModeForTest(pageMode);
    effectivePageMode = pageMode;
    pageMode = AuthRepository.getPageMode(RightConstants.appendix);

// override "view" -> "edit" for Risk Rating + CA/CC
    effectivePageMode = (pageMode == PageMode.view && riskRatingEditOverride)
        ? PageMode.edit
        : pageMode;
    // Use return values from Utils.checkBusinessSegment
    showCorporateSection =
        Utils.checkBusinessSegment(BusinessSegment.corporate);
    showFinancialSection =
        Utils.checkBusinessSegment(BusinessSegment.financialInstitution);
    showFinancialCFSection =
        Utils.checkBusinessSegment(BusinessSegment.financialInstitutionCF);

    repositoryCustomer = CustomerRepository.instance;

    // 3. Load draft ONLY if editable
    if (canEdit) {
      await loadDraftIfAvailable();
      registerDraftCallback();
    }

    // Override the live data with the recovered draft data (if a draft exists)

    await getReferenceData();
    await getCountries();
    await getApplicationDetails(
      Globals.request?.applicationRefNo,
    ); // <--- MUST COME BEFORE excel loading

    await fetchAppendixImageToSelectedCollections();
    await fetchAppendixBusinessSegment();
    await getComments();
    await fetchAppendixComments();

    await autoLoadFiAppendixXlsx();
    // if (!_canEditAppendix()) {
    // Register this ViewModel to listen to the SideMenu "navigate away" events

    _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  bool _draftApplied = false;
  int formRebuildVersion = 0;

  void markDraftApplied() {
    _draftApplied = true;
    formRebuildVersion++;
  }

  /// Public helper to trigger UI rebuilds after mutating lists outside Cubit
  /// methods.
  void refresh() {
    _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> getReferenceData() async {
    try {
      referenceData = await ReferenceDataService().getReferenceData(<String>[
        ReferenceDataKeys.sAndP,
        ReferenceDataKeys.fileType,
      ]);
      sAndP = referenceData[ReferenceDataKeys.sAndP] ?? <Reference>[];
      fileType = referenceData[ReferenceDataKeys.fileType] ?? <Reference>[];

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  // After getReferenceData fills sAndP:
  List<String> get countryRatingOptions {
    return sAndP
        .map(
          (Reference rating) =>
              (rating.name ?? rating.reference1 ?? "").trim(),
        )
        .where((String data) => data.isNotEmpty)
        .toList();
  }

  // --------------------- Overlay-safe helpers ---------------------
  /// Emit in the next frame to avoid “Overlay locked” assertions on Web.
  void _emitSafe(AppendixState next) {
    SchedulerBinding.instance.addPostFrameCallback((_) => emit(next));
  }

  /// Show toast in the next frame (overlay-safe).
  void _toastSafe(void Function() show) {
    SchedulerBinding.instance.addPostFrameCallback((_) => show());
  }

  // --------------------- Countries ---------------------
  Future<void> getCountries() async {
    try {
      countries = (await repositoryCustomer.getCountries() ?? <Country>[])
        ..sort(
          (Country a, Country b) =>
              (a.description ?? "").compareTo(b.description ?? ""),
        );
    } catch (e) {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  List<String> get countryNames {
    return countries?.map((Country c) => c.description ?? "").toList() ??
        <String>[];
  }

  // --------------------- File Picking / Uploads ---------------------
  Future<void> pickFilesForCountrySlot(CountryImage slot) async {
    if (!_canEditAppendix()) {
      _toastSafe(
        () => AlertManager().showFailureToast(
          "common.readOnlyPermission".tr(),
        ),
      );
      return;
    }

    try {
      final List<PlatformFile>? picked =
          await _fileService.customPickMultipleFiles(fileType: fileType);

      if (picked != null && picked.isNotEmpty) {
        final List<PlatformFile> accepted =
            picked.where((PlatformFile f) => isAllowedImage(f.name)).toList();
        if (accepted.isEmpty) {
          countryFiles[slot] = <PlatformFile>[];
          _toastSafe(
            () => AlertManager().showFailureToast(
              "${"eDigitalFilingFileAttachments.appendix"
                  ".allowedImgExt".tr()}\n",
            ),
          );
        } else {
          countryFiles[slot] = List<PlatformFile>.of(accepted);
          selectedFiles
            ..clear()
            ..addAll(accepted);
          _toastSafe(
            () => AlertManager().showSuccessToast(
              "eDigitalFilingFileAttachments."
                      "appendix.documentSelectedSuccessFully"
                  .tr(),
            ),
          );
        }
      } else {
        countryFiles[slot] = <PlatformFile>[];
        _toastSafe(
          () => AlertManager().showFailureToast(
            "eDigitalFilingFileAttachments.appendix.noFilesSelected".tr(),
          ),
        );
      }
    } catch (e) {
      _toastSafe(() => AlertManager().showFailureToast(e.toString()));
    }
    _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<String> _safeEditorText(
    UnifiedEditorController controller, {
    String fallback = "",
  }) async {
    try {
      return await controller.getText();
    } catch (_) {
      return fallback;
    }
  }

  Future<void> syncEditorsToModel() async {
    appendix.groupCorporateStructure = await _safeEditorText(
      gcsController,
      fallback: appendix.groupCorporateStructure,
    );

    for (int i = 0; i < appendix.entries.length; i++) {
      final AppendixEntry entry = appendix.entries[i];

      final String text = i < commentControllers.length
          ? await _safeEditorText(
              commentControllers[i],
              fallback: entry.value,
            )
          : entry.value;

      appendix.entries[i] = entry.copyWith(value: text);
    }
  }

  /// Pick files for FI Bank – Excel extract (Excel only).
  Future<void> pickFilesForFiExcel() async {
    if (!_canEditAppendix()) {
      _toastSafe(
        () => AlertManager().showFailureToast(
          "common.readOnlyPermission".tr(),
        ),
      );
      return;
    }

    try {
      final List<PlatformFile>? picked =
          await _fileService.customPickMultipleFiles(fileType: fileType);
      if (picked != null && picked.isNotEmpty) {
        final List<PlatformFile> accepted =
            picked.where((PlatformFile f) => _isAllowedExcel(f.name)).toList();
        if (accepted.isEmpty) {
          fiKeyFinancialFiguresExcelFiles = <PlatformFile>[];
          _toastSafe(
            () => AlertManager().showFailureToast(
              "eDigitalFilingFileAttachments.appendix.allowedExt".tr(),
            ),
          );
        } else {
          fiKeyFinancialFiguresExcelFiles = List<PlatformFile>.of(accepted);
          selectedFiles
            ..clear()
            ..addAll(accepted);
          _toastSafe(
            () => AlertManager().showSuccessToast(
              "eDigitalFilingFileAttachments."
                      "appendix.documentSelectedSuccessFully"
                  .tr(),
            ),
          );
        }
      } else {
        fiKeyFinancialFiguresExcelFiles = <PlatformFile>[];
        _toastSafe(
          () => AlertManager().showFailureToast(
            "eDigitalFilingFileAttachments.appendix.noFilesSelected".tr(),
          ),
        );
      }
    } catch (e) {
      logger.e("pickFilesForFiExcel failed: $e");
      _toastSafe(() => AlertManager().showFailureToast(e.toString()));
    }
    _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  bool isAllowedImage(String filePathOrName) {
    final String fileName = path.basename(filePathOrName).toLowerCase();
    const Set<String> allowed = <String>{
      ".jpg",
      ".jpeg",
      ".png",
      ".tif",
      ".tiff",
      ".TIFF",
    };
    return allowed.any(fileName.endsWith);
  }

  bool _isAllowedExcel(String name) {
    final String extensionName =
        (name.isNotEmpty ? name : basename(name)).toLowerCase();
    return extensionName.endsWith(".xls") || extensionName.endsWith(".xlsx");
  }

  /// Pick files for FI Bank – Image upload.
  Future<void> pickFilesForFiImage() async {
    if (!_canEditAppendix()) {
      _toastSafe(
        () => AlertManager().showFailureToast(
          "common.readOnlyPermission".tr(),
        ),
      );
      return;
    }

    try {
      final List<PlatformFile>? picked =
          await _fileService.customPickMultipleFiles(fileType: fileType);
      if (picked != null && picked.isNotEmpty) {
        final List<PlatformFile> accepted =
            picked.where((PlatformFile f) => isAllowedImage(f.name)).toList();
        if (accepted.isEmpty) {
          fiKeyFinancialFiguresImageFiles = <PlatformFile>[];
          _toastSafe(
            () => AlertManager().showFailureToast(
              "eDigitalFilingFileAttachments.appendix.allowedImgExt".tr(),
            ),
          );
        } else {
          fiKeyFinancialFiguresImageFiles = List<PlatformFile>.of(accepted);
          selectedFiles
            ..clear()
            ..addAll(accepted);
          _toastSafe(
            () => AlertManager().showSuccessToast(
              "eDigitalFilingFileAttachments."
                      "appendix.documentSelectedSuccessFully"
                  .tr(),
            ),
          );
        }
      } else {
        fiKeyFinancialFiguresImageFiles = <PlatformFile>[];
        _toastSafe(
          () => AlertManager().showFailureToast(
            "eDigitalFilingFileAttachments.appendix.noFilesSelected".tr(),
          ),
        );
      }
    } catch (e) {
      _toastSafe(() => AlertManager().showFailureToast(e.toString()));
    }
    _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Legacy picker that builds `uploadedDocuments` + `selectedFiles`.
  Future<void> pickMultipleFiles() async {
    final Document currentDocument = Document();

    if (!(formKey.currentState?.validate() ?? false)) {
      // no-op: optional guard
    } else {
      try {
        formKey.currentState?.save();

        final List<PlatformFile>? picked =
            await _fileService.pickMultipleFiles(fileType);

        if (picked != null && picked.isNotEmpty) {
          currentDocument.files = picked;
          selectedFiles
            ..clear()
            ..addAll(picked);
          uploadedDocuments.add(currentDocument);
          errorMessage = null;
          _toastSafe(
            () => AlertManager().showSuccessToast(
              "eDigitalFilingFileAttachments."
                      "appendix.documentSelectedSuccessFully"
                  .tr(),
            ),
          );
        } else {
          errorMessage =
              "eDigitalFilingFileAttachments.appendix.noFilesSelected".tr();
          selectedFiles.clear();
          _toastSafe(() => AlertManager().showFailureToast(errorMessage!));
        }
      } catch (e) {
        _toastSafe(() => AlertManager().showFailureToast(e.toString()));
      }
    }

    _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void removeFileAt(int index) {
    if (index >= 0 && index < selectedFiles.length) {
      selectedFiles.removeAt(index);
    }
    if (index >= 0 && index < uploadedDocuments.length) {
      uploadedDocuments.removeAt(index);
    }
    _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // ------------ Upload helpers ------------
  Future<void> uploadFirstAppendixImageFrom({
    required List<PlatformFile> sourceFiles,
    required String customerType, // e.g., "Bank" or "Country"
    required String
        imageType, // "Financial" | "RatingSP" | "CountryMap" | "CountryGovt"
    String? fileNameOverride,
  }) async {
    if (!_canEditAppendix()) {
      _toastSafe(
        () => AlertManager().showFailureToast(
          "common.readOnlyPermission".tr(),
        ),
      );
      return;
    }

    if (sourceFiles.isEmpty) {
      _toastSafe(
        () => AlertManager().showFailureToast(
          "eDigitalFilingFileAttachments.appendix.noFilesSelected".tr(),
        ),
      );
      return;
    }

    final PlatformFile file = sourceFiles.first;
    final String fileName = (fileNameOverride?.trim().isNotEmpty ?? false)
        ? fileNameOverride!
        : (file.name.isNotEmpty ? file.name : "");

    try {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loading));

      final Uint8List? bytes = await _ensureFileBytes(file);
      if (bytes == null) {
        _toastSafe(
          () => AlertManager().showFailureToast(
            "eDigitalFilingFileAttachments.appendix.noFilesSelected".tr(),
          ),
        );
        _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }

      final String? message =
          await AppendixRepository.instance.saveAppendixImageBytes(
        appRefNo: Globals.request!.applicationRefNo!,
        customerType: customerType,
        fileName: fileName,
        imageType: imageType,
        bytes: bytes,
      );

      _toastSafe(
        () => AlertManager()
            .showSuccessToast(message ?? "common.saveSuccess".tr()),
      );
    } catch (e) {
      _toastSafe(() => AlertManager().showFailureToast(e.toString()));
    } finally {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  Future<void> onUploadFiExcel(BuildContext context) async {
    final AppendixViewModel viewModelRead = context.read<AppendixViewModel>();

    if (viewModelRead.fiKeyFinancialFiguresExcelFiles.isEmpty) {
      AlertManager().showFailureToast(
        "eDigitalFilingFileAttachments.appendix.noFilesSelected".tr(),
      );
      return;
    }

    final PlatformFile file =
        viewModelRead.fiKeyFinancialFiguresExcelFiles.first;
    final String? userId = Globals.user?.id?.toString();
    final String rimNo = selectedRimNumber ?? "";
    final String appRefNo = Globals.request!.applicationRefNo!;

    try {
      final String message =
          await AppendixRepository.instance.extractAppendixXlsxAsMultipart(
        bytes: file.bytes!,
        fileName: file.name,
        rimNumber: rimNo,
        userId: userId!,
        appRefNo: appRefNo,
      );

      AlertManager().showSuccessToast(
        message.isNotEmpty ? message : "common.saveSuccess".tr(),
      );
    } catch (e) {
      debugPrint("Excel Upload failed $e");
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Helper: ensure we have bytes for a selected PlatformFile.
  /// - On Web: returns PlatformFile.bytes (requires withData: true in
  /// FilePicker).
  Future<Uint8List?> _ensureFileBytes(PlatformFile file) async {
    if (file.bytes != null) return file.bytes!;
    return null;
  }

  // --------------------- Review items deletes (Strength/Threat) ---------------------

  Future<void> deleteFetchedStrengthAt(int index) async {
    final String? appRefNo = Globals.request?.applicationRefNo;
    if (appRefNo == null || appRefNo.trim().isEmpty) return;
    if (index < 0 || index >= appendix.strengths.length) return;

    final String toDelete = appendix.strengths[index].trim();

    final int fetchedCount = _fetchedStrengthCounts[toDelete] ?? 0;
    if (toDelete.isEmpty || fetchedCount == 0) {
      appendix.strengths.removeAt(index);
      refresh();
      return;
    }

    try {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loading));

      final String? message = await AppendixRepository.instance.deleteReview(
        appRefNo: appRefNo,
        type: ServerConstants.strengths,
        strengths: toDelete,
        threats: "",
      );

      appendix.strengths.removeAt(index);
      if (fetchedCount > 0) _fetchedStrengthCounts[toDelete] = fetchedCount - 1;

      refresh();
      _toastSafe(
        () => AlertManager()
            .showSuccessToast(message ?? "common.saveSuccess".tr()),
      );
    } catch (e) {
      _toastSafe(() => AlertManager().showFailureToast(e.toString()));
    } finally {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  Future<void> deleteFetchedThreatAt(int index) async {
    final String? appRefNo = Globals.request?.applicationRefNo;
    if (appRefNo == null || appRefNo.trim().isEmpty) return;
    if (index < 0 || index >= appendix.threats.length) return;

    final String toDelete = appendix.threats[index].trim();

    final int fetchedCount = _fetchedThreatCounts[toDelete] ?? 0;
    if (toDelete.isEmpty || fetchedCount == 0) {
      appendix.threats.removeAt(index);
      refresh();
      return;
    }

    try {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loading));

      final String? message = await AppendixRepository.instance.deleteReview(
        appRefNo: appRefNo,
        type: ServerConstants.threats,
        strengths: "",
        threats: toDelete,
      );

      appendix.threats.removeAt(index);
      if (fetchedCount > 0) _fetchedThreatCounts[toDelete] = fetchedCount - 1;

      refresh();
      _toastSafe(
        () => AlertManager()
            .showSuccessToast(message ?? "common.saveSuccess".tr()),
      );
    } catch (e) {
      _toastSafe(() => AlertManager().showFailureToast(e.toString()));
    } finally {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  // --------------------- Business Segment: Save/Fetch ---------------------

  Future<void> saveAppendixBusinessSegment({required int? rimNo}) async {
    final String? appRefNo = Globals.request?.applicationRefNo;
    if (appRefNo == null || appRefNo.trim().isEmpty || rimNo == null) {
      return;
    }

    try {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loading));

      final BusinessSegmentPayload payload = BusinessSegmentPayload.fromContext(
        appRefNo: appRefNo,
        rimNo: rimNo,
        customerType: selectedSectionType,
        businessSegment: ServerConstants.corporate,
        countryName: appendix.countryName ?? "",
        rating: selectedRating,
        populationText: appendix.populationText,
        gdpText: appendix.gdpText,
        exportPartners: appendix.exportPartners,
        importPartners: appendix.importPartners,
        strengths: appendix.strengths,
        threats: appendix.threats,
      );

      final String? message = await AppendixRepository.instance
          .saveAppendixBusinessSegmentPayload(payload);

      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
      if (message != null && message.isNotEmpty) {
        _toastSafe(() => AlertManager().showSuccessToast(message));
      } else {
        _toastSafe(
          () => AlertManager().showSuccessToast(
            "eDigitalFilingFileAttachments.appendix.businessSegmentSaved".tr(),
          ),
        );
      }
    } catch (e) {
      _toastSafe(() => AlertManager().showFailureToast(e.toString()));
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  Future<void> fetchAppendixBusinessSegment() async {
    final String? appRefNo = Globals.request?.applicationRefNo!.trim();
    final int? rimNo = Globals.request?.customerRimNo;
    try {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loading));

      final Appendix? fetchedAppendix =
          await AppendixRepository.instance.getAppendixBusinessSegmentToModel(
        appRefNo: appRefNo!,
        rimNo: rimNo,
      );

      if (fetchedAppendix == null) {
        return;
      }

      if (!_draftApplied) {
        appendix.countryName = fetchedAppendix.countryName;
        selectedRating = fetchedAppendix.rating;
        appendix.populationText = fetchedAppendix.populationText;
        appendix.gdpText = fetchedAppendix.gdpText;
        appendix.importPartners =
            List<String>.of(fetchedAppendix.importPartners);
        appendix.exportPartners =
            List<String>.of(fetchedAppendix.exportPartners);
        appendix.strengths = List<String>.of(fetchedAppendix.strengths);
        appendix.threats = List<String>.of(fetchedAppendix.threats);
      }

      _fetchedStrengthCounts
        ..clear()
        ..addAll({
          for (final String strength
              in fetchedAppendix.strengths.map((String e) => e.trim()))
            strength: (_fetchedStrengthCounts[strength] ?? 0) + 1,
        });

      _fetchedThreatCounts
        ..clear()
        ..addAll({
          for (final String threat
              in fetchedAppendix.threats.map((String e) => e.trim()))
            threat: (_fetchedThreatCounts[threat] ?? 0) + 1,
        });

      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      debugPrint("fetchAppendixBusinessSegment failed: $e");
    } finally {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  // --------------------- Images: Fetch/Delete ---------------------

  Future<void> fetchAppendixImageToSelectedCollections() async {
    final String? appRefNo = Globals.request?.applicationRefNo;
    if (appRefNo == null || appRefNo.trim().isEmpty) {
      return;
    }

    try {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loading));

      final List<AppendixImageItem> images =
          await AppendixRepository.instance.fetchAppendixImageItems(appRefNo);

      // Clear all containers before re-mapping
      bankFinancialFiles.clear();
      bankFinancialFileIds.clear();
      countryFiles[CountryImage.ratingBar]!.clear();
      countryFileIds[CountryImage.ratingBar]!.clear();
      countryFiles[CountryImage.countryMap]!.clear();
      countryFileIds[CountryImage.countryMap]!.clear();
      countryFiles[CountryImage.governmentIndicators]!.clear();
      countryFileIds[CountryImage.governmentIndicators]!.clear();

      for (final AppendixImageItem item in images) {
        final Uint8List? bytes = item.tryDecodeBytes();
        if (bytes == null || bytes.isEmpty) continue;

        final PlatformFile platformFile = PlatformFile(
          name: item.fileName,
          size: bytes.length,
          bytes: bytes,
          path: null,
        );

        // Bank images
        if (item.customerType == ServerConstants.bank) {
          bankFinancialFiles.add(platformFile);
          bankFinancialFileIds.add(item.fileId);
          continue;
        }

        // Country images – route strictly by imageType
        if (item.customerType == ServerConstants.country) {
          switch (item.imageType) {
            case ServerConstants.ratingSP:
              countryFiles[CountryImage.ratingBar]!.add(platformFile);
              countryFileIds[CountryImage.ratingBar]!.add(item.fileId);

            case ServerConstants.countryMap:
              countryFiles[CountryImage.countryMap]!.add(platformFile);
              countryFileIds[CountryImage.countryMap]!.add(item.fileId);

            case ServerConstants.countryGovt:
              countryFiles[CountryImage.governmentIndicators]!
                  .add(platformFile);
              countryFileIds[CountryImage.governmentIndicators]!
                  .add(item.fileId);

            default:
              // Unknown type → fall back to government indicators
              countryFiles[CountryImage.governmentIndicators]!
                  .add(platformFile);
              countryFileIds[CountryImage.governmentIndicators]!
                  .add(item.fileId);
          }
        }
      }

      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      _toastSafe(() => AlertManager().showFailureToast("$e"));
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  Future<void> deleteFetchedBankItemAt(int index) async {
    final String? appRefNo = Globals.request?.applicationRefNo;
    if (appRefNo == null || appRefNo.trim().isEmpty) {
      return;
    }

    if (index < 0 || index >= bankFinancialFileIds.length) return;

    final int? fileId = bankFinancialFileIds[index];
    if (fileId == null) {
      bankFinancialFiles.removeAt(index);
      bankFinancialFileIds.removeAt(index);
      refresh();
      return;
    }

    try {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loading));

      final String? message =
          await AppendixRepository.instance.deleteAppendixImage(
        fileId: fileId,
        appRefNo: appRefNo,
        customerType: ServerConstants.bank,
      );

      bankFinancialFiles.removeAt(index);
      bankFinancialFileIds.removeAt(index);

      _toastSafe(() => AlertManager().showSuccessToast(message!));
    } catch (e) {
      _toastSafe(() => AlertManager().showFailureToast(e.toString()));
    } finally {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  Future<void> deleteFetchedCountryItemAt(CountryImage slot, int index) async {
    if (!_canEditAppendix()) {
      _toastSafe(
        () => AlertManager().showFailureToast(
          "common.readOnlyPermission".tr(),
        ),
      );
      return;
    }

    final String? appRefNo = Globals.request?.applicationRefNo;
    if (appRefNo == null || appRefNo.trim().isEmpty) {
      return;
    }

    final List<int?> ids = countryFileIds[slot]!;
    final List<PlatformFile> files = countryFiles[slot]!;

    // If index is invalid for BOTH lists, bail out safely
    final bool indexInIds = index >= 0 && index < ids.length;
    final bool indexInFiles = index >= 0 && index < files.length;

    if (!indexInIds && !indexInFiles) {
      debugPrint(
        "Index $index is out of range. ids: "
        "${ids.length}, files: ${files.length}",
      );
      return;
    }

    // If there is no server ID at this index (e.g., locally added file),
    // remove only the local file (do not call API).
    if (!indexInIds) {
      debugPrint("No server id at index=$index; removing local file only.");
      if (indexInFiles) {
        files.removeAt(index);
        refresh();
      }
      return;
    }

    // From here on, ids[index] is safe to read
    final int? fileId = ids[index];

    // If ID is null, treat as local-only and remove from both lists
    if (fileId == null) {
      if (indexInFiles) files.removeAt(index);
      ids.removeAt(index);
      refresh();
      return;
    }

    try {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loading));

      final String? message =
          await AppendixRepository.instance.deleteAppendixImage(
        fileId: fileId,
        appRefNo: appRefNo,
        customerType: ServerConstants.country,
      );

      // Keep lists aligned
      if (indexInFiles) files.removeAt(index);
      ids.removeAt(index);

      _toastSafe(() => AlertManager().showSuccessToast(message!));
    } catch (e) {
      _toastSafe(() => AlertManager().showFailureToast(e.toString()));
    } finally {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  // --------------------- Local list remove helpers ---------------------

  void removeFiExcelAt(int index) {
    if (index >= 0 && index < fiKeyFinancialFiguresExcelFiles.length) {
      fiKeyFinancialFiguresExcelFiles.removeAt(index);
      refresh();
    }
  }

  void removeFiImageAt(int index) {
    if (index >= 0 && index < fiKeyFinancialFiguresImageFiles.length) {
      fiKeyFinancialFiguresImageFiles.removeAt(index);
      refresh();
    }
  }

  void removePlatformFileAt(List<PlatformFile> list, int index) {
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      refresh();
    }
  }

  // --------------------- Entries (AppendixEntry) ---------------------
  void onAddAppendix() {
    if (!_requireAppendixEditPermission()) return;

    final List<AppendixEntry> updated =
        List<AppendixEntry>.from(appendix.entries)
          ..add(AppendixEntry(id: const Uuid().v4()));
    commentControllers.add(UnifiedEditorController());
    appendix.entries
      ..clear()
      ..addAll(updated);

    _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onUpdateAppendix(String id, {String? label, String? commentText}) {
    if (!_requireAppendixEditPermission()) return;

    for (int index = 0; index < appendix.entries.length; index++) {
      final AppendixEntry entry = appendix.entries[index];
      if (entry.id == id) {
        final String newLabel = label ?? entry.label;
        final String newValue = entry.value;

        final bool unchanged =
            newLabel == entry.label && newValue == entry.value;
        if (unchanged) return;

        appendix.entries[index] = entry.copyWith(
          label: newLabel,
          value: newValue,
        );

        _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
        break;
      }
    }
  }

  // --------------------- Multi-select partners ---------------------
  void updateExportPartners(List<String> selected) {
    appendix.exportPartners = List<String>.of(selected);
    _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateImportPartners(List<String> selected) {
    appendix.importPartners = List<String>.of(selected);
    _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // --------------------- Strengths / Threats ---------------------
  void addStrengthTableRow() {
    _ensureGrowableLists();
    appendix.strengths.add("");
    _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void removeStrengthTableRow(int index) {
    if (index >= 0 && index < appendix.strengths.length) {
      appendix.strengths.removeAt(index);
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  void addThreatTableRow() {
    appendix.threats.add("");
    _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void removeThreatTableRow(int index) {
    if (index >= 0 && index < appendix.threats.length) {
      appendix.threats.removeAt(index);
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  void updateStrengths(List<String>? updated) {
    appendix.strengths = updated ?? <String>[];
    _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateThreats(List<String>? updated) {
    appendix.threats = updated ?? <String>[];
    _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  bool get riskRatingEditOverride {
    final role = Globals.user?.currentRole?.userRole;

    const allowed = {
      UserRole.creditAnalyst,
      UserRole.creditCordinator, // keep your enum spelling
    };

    final isRiskRatingApp =
        Utils.checkApplicationType(ApplicationType.riskRatingChange);

    return isRiskRatingApp && allowed.contains(role);
  }
  // --------------------- Save flow ---------------------

  Future<void> onSavePress({bool isContinue = false}) async {
    if (!_canEditAppendix()) {
      if (isContinue) router.go(Routes.recommendationCurrentApproval);
      return;
    }

    final FormState? currentFormState = formKey.currentState;
    final bool isValid = currentFormState?.validate() ?? false;
    if (!isValid) {
      _toastSafe(
        () => AlertManager()
            .showFailureToast("common.validation.emptyField".tr()),
      );
      return;
    }
    currentFormState?.save();
    if (!showCorporateSection) {
      final bool strengthsHaveValue =
          _hasAtLeastOneNonEmpty(appendix.strengths);
      final bool threatsHaveValue = _hasAtLeastOneNonEmpty(appendix.threats);

      if (!strengthsHaveValue || !threatsHaveValue) {
        _toastSafe(
          () => AlertManager()
              .showFailureToast("common.validation.emptyField".tr()),
        );
        return;
      }
      if (_hasAnyEmptyRow(appendix.strengths) ||
          _hasAnyEmptyRow(appendix.threats)) {
        _toastSafe(
          () => AlertManager()
              .showFailureToast("common.validation.emptyField".tr()),
        );
        return;
      }
      await saveAppendixBusinessSegment(
        rimNo: int.tryParse(selectedRimNumber!),
      );
      unawaited(
        deleteDraft(),
      ); // fire-and-forget: remove backend draft now that data is saved

      return;
    }

    await saveComments(isContinue: isContinue);
    await saveAllComments(isContinue: isContinue);
  }

  // --------------------- Simple setters ---------------------
  void updateSelectedSectionType(String value) {
    selectedSectionType = value;
    _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void setRating(String value) {
    selectedRating = value;
    _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void setApplicationId(String? value) {
    applicationId = value;
    _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void setSelectedDate(DateTime value) {
    selectedDate = value;
  }

  void setCountryName(String? value) {
    appendix.countryName = value;
  }

  void setPopulation(String? value) {
    appendix.populationText = value ?? "";
  }

  void setGdp(String? value) {
    appendix.gdpText = value ?? "";
  }

  // --------------------- Comments ---------------------

  Comment mapAppendixCommentToUiModel(AppendixComment comment) {
    String normalize(String? input) => (input ?? "").trim();

    return Comment(
      comment: normalize(comment.comments),
      commentId: normalize(comment.commentType),
      name: comment.name?.trim(),
      notes: comment.note?.trim(),
      createdBy: normalize(comment.createdBy),
      createdDate: comment.createdDate,
      updatedBy: comment.updatedBy?.trim(),
      updatedDate: comment.updatedDate,
      applicationRefNo: normalize(comment.appRefNo),
    );
  }

  void populateFieldsFromComments() {
    // Sort UI comments
    comments.sort((a, b) {
      final DateTime aDate =
          a.createdDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime bDate =
          b.createdDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    comment = comments.isNotEmpty ? comments.first : null;

    appendix.entries = <AppendixEntry>[];
    commentControllers.clear();
    _entryIdToRemarkId.clear();
    _groupCorporateRemarkId = null;

    bool isMeaningfulPair(AppendixComment backend) {
      final String name = (backend.name ?? "").trim();
      final String note = (backend.note ?? "").trim();
      return name.isNotEmpty || note.isNotEmpty;
    }

    AppendixComment? latestGroupOnly;

    for (final AppendixComment backend in backendComments) {
      final String name = (backend.name ?? "").trim();
      final String note = (backend.note ?? "").trim();

      if (!isMeaningfulPair(backend)) {
        if (latestGroupOnly == null ||
            (backend.createdDate ?? DateTime.fromMillisecondsSinceEpoch(0))
                .isAfter(
              latestGroupOnly.createdDate ??
                  DateTime.fromMillisecondsSinceEpoch(0),
            )) {
          latestGroupOnly = backend;
        }
        continue;
      }

      final AppendixEntry entry = AppendixEntry(
        id: const Uuid().v4(),
        label: name,
        value: note,
      );

      appendix.entries.add(entry);
      commentControllers.add(UnifiedEditorController());

      if (backend.appendixRemarkId != null) {
        _entryIdToRemarkId[entry.id] = backend.appendixRemarkId!;
      }
    }

    if (latestGroupOnly?.appendixRemarkId != null) {
      _groupCorporateRemarkId = latestGroupOnly!.appendixRemarkId;
    }
  }

  Future<void> fetchAppendixComments() async {
    final String? appRefNo = Globals.request?.applicationRefNo?.trim();
    if (appRefNo == null || appRefNo.isEmpty) return;

    if (_isFetchingComments) return;

    _isFetchingComments = true;
    _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      final List<AppendixComment> fetched =
          await AppendixRepository.instance.fetchAppendixComments(appRefNo);

      backendComments
        ..clear()
        ..addAll(fetched);

      comments
        ..clear()
        ..addAll(backendComments.map(mapAppendixCommentToUiModel));

      populateFieldsFromComments();
    } finally {
      _isFetchingComments = false;
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
      refresh();
    }
  }

  Future<void> onRemoveAppendixEntryById(String entryId) async {
    if (!_requireAppendixEditPermission()) return;

    final int index =
        appendix.entries.indexWhere((AppendixEntry e) => e.id == entryId);
    if (index == -1) return;

    final int? remarkId = _entryIdToRemarkId[entryId];

    if (remarkId == null) {
      appendix.entries.removeAt(index);
      if (index < commentControllers.length) {
        commentControllers.removeAt(index);
      }
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return;
    }

    final String? appRefNo = Globals.request?.applicationRefNo?.trim();
    if (appRefNo == null || appRefNo.isEmpty) {
      appendix.entries.removeAt(index);
      if (index < commentControllers.length) {
        commentControllers.removeAt(index);
      }
      _entryIdToRemarkId.remove(entryId);
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return;
    }

    try {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loading));

      final String? message =
          await AppendixRepository.instance.deleteAppendixComment(
        appRefNo: appRefNo,
        appendixRemarkId: remarkId,
      );

      appendix.entries.removeAt(index);
      if (index < commentControllers.length) {
        commentControllers.removeAt(index);
      }
      _entryIdToRemarkId.remove(entryId);

      final int backendIdx = backendComments.indexWhere(
        (AppendixComment c) => c.appendixRemarkId == remarkId,
      );
      if (backendIdx != -1) {
        backendComments.removeAt(backendIdx);
      }

      comments
        ..clear()
        ..addAll(backendComments.map(mapAppendixCommentToUiModel));
      populateFieldsFromComments();

      _toastSafe(
        () => AlertManager()
            .showSuccessToast(message ?? "common.deleteSuccess".tr()),
      );
    } catch (e) {
      _toastSafe(() => AlertManager().showFailureToast(e.toString()));
    } finally {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  // --------------------- Strengths / Threats (index-safe setters) ---------------------

  bool _hasAtLeastOneNonEmpty(List<String> list) =>
      list.any((String e) => e.trim().isNotEmpty);

  bool _hasAnyEmptyRow(List<String> list) =>
      list.any((String e) => e.trim().isEmpty);

  void _ensureStringListSize(List<String> list, int targetIndex) {
    if (targetIndex < 0) return;
    while (list.length <= targetIndex) {
      list.add("");
    }
  }

  Future<void> removeAnyFile(PlatformFile target) async {
    // Local‑only removals (no API)
    bool removeLocalByTarget(List<PlatformFile> l) {
      final int i = l.indexWhere((f) => _sameFile(f, target));
      if (i != -1) {
        l.removeAt(i);
        return true;
      }
      return false;
    }

    // Local temp lists
    if (removeLocalByTarget(fiKeyFinancialFiguresExcelFiles)) return;
    if (removeLocalByTarget(fiKeyFinancialFiguresImageFiles)) return;
    if (removeLocalByTarget(bankFinancialFiles)) return;

    for (final MapEntry<CountryImage, List<PlatformFile>> entry
        in countryFiles.entries) {
      if (removeLocalByTarget(entry.value)) return;
    }

    if (removeLocalByTarget(selectedFiles)) return;

    // NOTE:
    // Do NOT trigger server deletes here — we handle server-backed deletes
    // precisely by (slot, index) in removeFromRenderedList to avoid ambiguity.
  }

  void setStrengthAt(int index, String value) {
    if (index < 0) return;
    _ensureStringListSize(appendix.strengths, index);
    appendix.strengths[index] = value;
    _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> deleteFiExtractXlsxById(int appendixXlsxId) async {
    try {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loading));

      final String message = await AppendixRepository.instance
          .deleteExtractAppendixXlsx(appendixXlsxId: appendixXlsxId);

      _toastSafe(
        () => AlertManager().showSuccessToast(
          message.isEmpty ? "common.deleteSuccess".tr() : message,
        ),
      );

      final int idx = fiExtractXlsxIds.indexOf(appendixXlsxId);
      if (idx != -1) {
        if (idx < fiExtractXlsxFiles.length) fiExtractXlsxFiles.removeAt(idx);
        fiExtractXlsxIds.removeAt(idx);
        refresh();
      }
    } catch (e) {
      _toastSafe(() => AlertManager().showFailureToast(e.toString()));
    } finally {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  Future<void> deleteFiServerRow(int? id) async {
    // ignore: avoid_print
    print("this is excel id $id");

    try {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loading));

      final String message =
          await AppendixRepository.instance.deleteExtractAppendixXlsx(
        appendixXlsxId: id!,
      );

      fiServerRows.removeWhere((FiAppendixXlsxRow r) => r.appendixXlsxId == id);
      refresh();

      _toastSafe(
        () => AlertManager().showSuccessToast(
          message.isEmpty ? "common.deleteSuccess".tr() : message,
        ),
      );
    } catch (e) {
      _toastSafe(() => AlertManager().showFailureToast(e.toString()));
    } finally {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Identify which CountryImage bucket this list instance belongs to (by
  /// reference).
  CountryImage? _resolveCountrySlot(List<PlatformFile> ref) {
    for (final entry in countryFiles.entries) {
      if (identical(entry.value, ref)) return entry.key;
    }
    return null;
  }

  /// Safer file equality for local removal (name + size).
  bool _sameFile(PlatformFile fileA, PlatformFile fileB) {
    return fileA.name == fileB.name && fileA.size == fileB.size;
  }

  Future<void> removeFromRenderedList(
    List<PlatformFile> list,
    int index,
  ) async {
    if (!_canEditAppendix()) {
      _toastSafe(
        () => AlertManager().showFailureToast(
          "common.readOnlyPermission".tr(),
        ),
      );
      return;
    }

    if (index < 0 || index >= list.length) return;

    _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      final PlatformFile tappedFile = list[index];

      // Case A: Bank images table
      if (identical(list, bankFinancialFiles)) {
        final bool hasId = index < bankFinancialFileIds.length &&
            bankFinancialFileIds[index] != null;

        if (hasId) {
          // Server-backed: delete exactly this index via API
          await deleteFetchedBankItemAt(index);
        } else {
          // Local-only: remove from the shown list and sync
          list.removeAt(index);
          await removeAnyFile(tappedFile);
        }

        return;
      }

      // Case B: Country images table — which slot?
      final CountryImage? slot = _resolveCountrySlot(list);
      if (slot != null) {
        final List<int?> ids = countryFileIds[slot]!;
        final bool hasId = index < ids.length && ids[index] != null;

        if (hasId) {
          // Server-backed: delete exactly this index via API
          await deleteFetchedCountryItemAt(slot, index);
        } else {
          // Local-only: remove from the shown list and sync
          list.removeAt(index);
          await removeAnyFile(tappedFile);
        }

        return;
      }

      // Case C: Any other local list (e.g., FI Excel/Image temp lists, selectedFiles)
      list.removeAt(index);
      await removeAnyFile(tappedFile);
    } finally {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
      refresh();
    }
  }

  void setThreatAt(int index, String value) {
    if (index < 0) return;
    _ensureStringListSize(appendix.threats, index);
    appendix.threats[index] = value;
    _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void setFieldListItem({
    required bool useStrengths,
    required int index,
    required String value,
  }) {
    if (useStrengths) {
      setStrengthAt(index, value);
    } else {
      setThreatAt(index, value);
    }
  }

  // --------------------- Country image row: onPressed handlers
  // ---------------------

  String imageTypeForCountryType(CountryImage type) {
    switch (type) {
      case CountryImage.ratingBar:
        return ServerConstants.ratingSP;
      case CountryImage.countryMap:
        return ServerConstants.countryMap;
      case CountryImage.governmentIndicators:
        return ServerConstants.countryGovt;
    }
  }

  Future<void> onPressBrowseCountryType(CountryImage type) async {
    await pickFilesForCountrySlot(type);
  }

  Future<void> onPressUploadCountryType(
    CountryImage type, {
    String? fileNameOverride,
  }) async {
    final List<PlatformFile> source =
        countryFiles[type] ?? const <PlatformFile>[];
    if (source.isEmpty) {
      _toastSafe(
        () => AlertManager().showFailureToast(
          "eDigitalFilingFileAttachments.appendix.noFilesSelected".tr(),
        ),
      );
      return;
    }

    await uploadFirstAppendixImageFrom(
      sourceFiles: source,
      customerType: ServerConstants.country,
      imageType: imageTypeForCountryType(type),
      fileNameOverride: fileNameOverride,
    );
  }

  // --------------------- SelectedFilesList: helpers & handlers
  // ---------------------

  String basename(String input) {
    final String normalized = input.replaceAll("", "/");
    final int index = normalized.lastIndexOf("/");
    return index == -1 ? normalized : normalized.substring(index + 1);
  }

  bool _isImageExt(String nameLower) {
    return nameLower.endsWith(ServerConstants.pngExtension) ||
        nameLower.endsWith(ServerConstants.jpgExtension) ||
        nameLower.endsWith(ServerConstants.jpegExtension) ||
        nameLower.endsWith(ServerConstants.bmpExtension) ||
        nameLower.endsWith(ServerConstants.webpExtension);
  }

  List<PlatformFile> filterBankFinancial(List<PlatformFile> input) {
    if (input.isEmpty) return input;

    final List<PlatformFile> likelyFinancial = input.where((PlatformFile file) {
      final String name =
          (file.name.isNotEmpty ? file.name : basename(file.name))
              .toLowerCase();
      final bool containsKeyword =
          name.contains(ServerConstants.financial.toLowerCase());
      final bool isExcel = name.endsWith(ServerConstants.xlsxExtension) ||
          name.endsWith(ServerConstants.xlsExtension);
      final bool isImage = _isImageExt(name);
      return containsKeyword || isExcel || isImage;
    }).toList();

    return likelyFinancial.isNotEmpty ? likelyFinancial : input;
  }

  List<PlatformFile> filterCountryImages(List<PlatformFile> input) {
    if (input.isEmpty) return input;

    final List<PlatformFile> countryImages = input.where((PlatformFile file) {
      final String name =
          (file.name.isNotEmpty ? file.name : basename(file.name))
              .toLowerCase();
      final bool isImage = _isImageExt(name);
      if (!isImage) return false;

      final bool hasHint =
          name.contains(ServerConstants.country.toLowerCase()) ||
              name.contains(ServerConstants.mapHint.toLowerCase()) ||
              name.contains(ServerConstants.govHint.toLowerCase()) ||
              name.contains(ServerConstants.governmentHint.toLowerCase()) ||
              name.contains(ServerConstants.ratingHint.toLowerCase());

      return hasHint || isImage;
    }).toList();

    return countryImages.isNotEmpty ? countryImages : input;
  }

  List<PlatformFile> applySectionFilter(List<PlatformFile> input) {
    final bool isBankSection = selectedSectionType == ServerConstants.bigBank;
    final bool isCountrySection =
        selectedSectionType == ServerConstants.country;

    if (isBankSection) return filterBankFinancial(input);
    if (isCountrySection) return filterCountryImages(input);
    return input;
  }

  Future<void> onPreviewSelectedFile({
    required int index,
    required List<PlatformFile> files,
    BuildContext? context,
  }) async {
    if (index < 0 || index >= files.length) return;
    final PlatformFile file = files[index];
    final String nameLower =
        (file.name.isNotEmpty ? file.name : basename(file.name)).toLowerCase();

    final Uint8List? bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      _toastSafe(
        () => AlertManager().showFailureToast(
          "eDigitalFilingFileAttachments.appendix.cantPreview".tr(),
        ),
      );
      return;
    }

    final bool isImage = _isImageExt(nameLower);
    if (!isImage) {
      _toastSafe(() => AlertManager().showSuccessToast(file.name));
      return;
    }

    if (context != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  file.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Flexible(child: Image.memory(bytes)),
                const Gap(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "eDigitalFilingFileAttachments.appendix.closeText".tr(),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    } else {
      _toastSafe(
        () => AlertManager().showSuccessToast(
          "eDigitalFilingFileAttachments.appendix.noHandleWired".tr(),
        ),
      );
    }
  }

  Future<void> onPressRemoveCountryFile({
    required CountryImage type,
    required int index,
  }) async {
    await deleteFetchedCountryItemAt(type, index);
  }

  Future<void> saveAllComments({required bool isContinue}) async {
    _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      final String? appRefNo = Globals.request?.applicationRefNo?.trim();
      if (appRefNo == null || appRefNo.isEmpty) return;

      final String groupComment = appendix.groupCorporateStructure.trim();

      if (groupComment.isEmpty) {
        _toastSafe(
          () => AlertManager()
              .showFailureToast("common.validation.emptyField".tr()),
        );
        return;
      }

      final List<AppendixEntry> anyFilledRows = appendix.entries
          .where(
            (AppendixEntry e) =>
                e.label.trim().isNotEmpty || e.value.trim().isNotEmpty,
          )
          .toList();

      for (final AppendixEntry e in anyFilledRows) {
        final bool hasName = e.label.trim().isNotEmpty;
        final bool hasNotes = e.value.trim().isNotEmpty;
        if (hasName ^ hasNotes) {
          _toastSafe(
            () => AlertManager()
                .showFailureToast("common.validation.emptyField".tr()),
          );
          return;
        }
      }

      final List<AppendixEntry> validPairs = anyFilledRows
          .where(
            (AppendixEntry e) =>
                e.label.trim().isNotEmpty && e.value.trim().isNotEmpty,
          )
          .toList();

      final List<GroupCorporateStructureCommentPayload> payloadList =
          <GroupCorporateStructureCommentPayload>[];

      final DateTime now = DateTime.now().toUtc();

      if (validPairs.isEmpty) {
        payloadList.add(
          GroupCorporateStructureCommentPayload(
            appRefNo: appRefNo,
            commentType: ServerConstants.groupCorporateStucture,
            comments: groupComment,
            name: null,
            notes: null,
            createdBy: "${Globals.user?.id}",
            createdDate: now,
            updatedBy: "${Globals.user?.id}",
            updatedDate: now,
            appendixRemarkId: _groupCorporateRemarkId,
          ),
        );
      } else {
        for (final AppendixEntry entry in validPairs) {
          payloadList.add(
            GroupCorporateStructureCommentPayload(
              appRefNo: appRefNo,
              commentType: ServerConstants.groupCorporateStucture,
              comments: groupComment,
              name: entry.label.trim(),
              notes: entry.value.trim(),
              createdBy: "${Globals.user?.id}",
              createdDate: now,
              updatedBy: "${Globals.user?.id}",
              updatedDate: now,
              appendixRemarkId: _entryIdToRemarkId[entry.id],
            ),
          );
        }
      }

      final String message = await AppendixRepository.instance
          .saveGroupCorporateStructureCommentList(
        payloadList,
      );

      await fetchAppendixComments();

      _toastSafe(
        () => AlertManager().showSuccessToast(
          message.isEmpty ? "common.saveSuccess".tr() : message,
        ),
      );

      if (isContinue) router.go(Routes.proposedFacilities);
    } catch (e) {
      _toastSafe(() => AlertManager().showFailureToast(e.toString()));
    } finally {
      _emitSafe(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  Future<void> getComments() async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    try {
      final List<Comment> commentList =
          await CommonRepository.instance.getApplicationStrategyDetails(
        CommentsType.appendix,
        EntityIdentifier.appendix,
      );
      if (commentList.isNotEmpty) {
        appendix.groupCorporateStructure =
            commentList.first.strategyComment ?? "";
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e, st) {
      logger.e("Error fetching strategy details: $e", stackTrace: st);
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  Future<void> saveComments({bool isContinue = false}) async {
    try {
      if (!(formKey.currentState?.validate() ?? false)) {
        return;
      }

      formKey.currentState?.save();

      await syncEditorsToModel();

      strategyComment = appendix.groupCorporateStructure.trim();

      commentData = Comment.fromInputData(
        type: CommentsType.appendix,
        strategyComment: strategyComment,
        entityType: EntityIdentifier.appendix,
        categoryId: ServerConstants.appendixCommentCategoryId,
        categoryType: ServerConstants.appendixCommentCategoryType,
      );

      final int typeId = ServerConstants.commentTypeId[CommentsType.appendix]!;

      final String? response =
          await CommonRepository.instance.saveApplicationStrategyDetails(
        typeId,
        typeId,
        commentData,
      );

      if (response != null && response.isNotEmpty) {
        // optional toast
      }
    } catch (e, st) {
      logger.e("saveComments failed: $e", stackTrace: st);
      AlertManager().showFailureToast(e.toString());
    }
  }

  @override
  Future<void> close() {
    unregisterDraftCallback();
    draftShadowController.dispose();
    draftController.dispose();
    scrollController.dispose();

    return super.close();
  }
}
