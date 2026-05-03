import "package:easy_localization/easy_localization.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/file_upload_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/state.dart";
import "package:wcas_frontend/models/admin/file_access.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/file_attachment/document.dart";
import "package:wcas_frontend/models/request/file_attachment/file_upload.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/file_attachment_repository.dart";

class FileAttachmentViewModel extends SafeCubit<FileAttachmentState> {
  FileAttachmentViewModel()
      : super(
          FileAttachmentState(
            loaderStatus: LoadingStatus.loading,
            documentsLoaderStatus: LoadingStatus.loaded,
          ),
        );
  late FileAttachmentRepository fileAttachmentRepository;

  List<PlatformFile> selectedFiles = [];

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Request request = Globals.request!;
  String? errorMessage;
  ApplicationDetails? applicationDetails;

  String? documentName;
  String? entityId;
  double? selectedGroupRim;

  List<Reference> languages = [];
  List<Reference> applicationTypeCustom = [];

  Reference? selectedLanguageType;

  final Map<String, bool> selectedCheckbocDocuments = {};

  List<Document> selectedDocuments = [];
  List<String> selectedDocumentIds = [];
  List<dynamic> selectedDocs = [];

  List<Document> uploadedDocuments = [];

  List<Document> allDocuments = [];

  // Manage checkbox selections for products using their ID as key.
  Map<String, bool> selectedRows = {};

  // file tree data
  List<FileAccess> fileAccesses = [];

  FileAccess? selectedFolder;
  List<FileDetail> fileUploadDatas = [];

  List<Customer> rimList = [];

  List<Customer> selectedCompanyRims = [];

  bool isSelectAllCompanyRims = false;

  DateTime? selectedDate = DateTime.now();

  // Reference data lists
  List<Reference> documentTypes = [];
  List<Reference> fileType = [];
  Reference? selectedDocumentType;

  List<Reference> caSubTypes = [];
  List<Reference> caSubSubTypes = [];
  Reference? selectedSubSubType;
  //credit lens sub type
  List<Reference> clSubTypes = [];
  Reference? selectedSubTypeCreditLens;

  //credit application sub sub sub type
  List<Reference> caSubSubSubTypes = [];
  Reference? selectedSubSubSubType;

  List<Reference> cdSubTypes = [];

  List<Reference> fstSubTypes = [];
  Reference? selectedSubType;

  List<Reference> fstSubSubTypes = [];

  bool get canEdit => pageMode == PageMode.edit;
  PageMode pageMode = PageMode.na;

  final Map<FileAttachmentFields, bool Function()> buttonVisibilityStatus = {
    FileAttachmentFields.downloadDocuments: () => Utils.checkRoles([
          UserRole.creditAnalyst,
          UserRole.teamLeaderCreditLevelD1,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelB,
          UserRole.segmentHeadLevelB1,
          UserRole.segmentHeadLevelC,
          UserRole.creditCommitteeProxy,
          UserRole.creditCommitteeProxyApprover,
          UserRole.boardDirectorProxy,
          UserRole.boardDirectorProxyApproval,
        ]),
    FileAttachmentFields.showApprovalDecision: () => Utils.checkRoles([
          UserRole.creditAnalyst,
          UserRole.teamLeaderCreditLevelD1,
          UserRole.segmentHeadCreditLevelD,
          UserRole.segmentHeadLevelB,
          UserRole.segmentHeadLevelB1,
          UserRole.segmentHeadLevelC,
          UserRole.creditCommitteeProxy,
          UserRole.creditCommitteeProxyApprover,
          UserRole.boardDirectorProxy,
          UserRole.boardDirectorProxyApproval,
        ]),
  };

  Future<void> init(context) async {
    logger.i("initialising FileAttachmentViewModel");
    fileAttachmentRepository = FileAttachmentRepository.instance;
    await loadReferenceData();
    await getFileAccessTree();
    await getCompanyRims();
    await getDigitalFilingViewData();

    pageMode = AuthRepository.getPageMode(RightConstants.fileAttachments);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Loads reference data required for dropdowns and labels.
  ///
  /// Fetches data from the `ReferenceDataService` and populates local lists.
  Future<void> loadReferenceData() async {
    final Map<String, List<Reference>> referenceData =
        await ReferenceDataService().getReferenceData([
      ReferenceDataKeys.fileType,
      ReferenceDataKeys.documentTypes,
      ReferenceDataKeys.fstSubTypes,
      ReferenceDataKeys.fstSubsubTypes,
      ReferenceDataKeys.languages,
      ReferenceDataKeys.clSubTypes,
      // ReferenceDataKeys.cdSubTypes,
      ReferenceDataKeys.applicationTypeCustom,
      ReferenceDataKeys.caSubTypes,
      ReferenceDataKeys.caSubSubTypes,
      ReferenceDataKeys.caSubSubSubTypes,
    ]);

    // Populate reference data lists
    fileType = referenceData[ReferenceDataKeys.fileType] ?? [];
    documentTypes = referenceData[ReferenceDataKeys.documentTypes] ?? [];
    fstSubTypes = referenceData[ReferenceDataKeys.fstSubTypes] ?? [];
    fstSubSubTypes = referenceData[ReferenceDataKeys.fstSubsubTypes] ?? [];
    languages = referenceData[ReferenceDataKeys.languages] ?? [];
    clSubTypes = referenceData[ReferenceDataKeys.clSubTypes] ?? [];
    // cdSubTypes = referenceData[ReferenceDataKeys.cdSubTypes] ?? [];
    applicationTypeCustom =
        referenceData[ReferenceDataKeys.applicationTypeCustom] ?? [];
    caSubTypes = referenceData[ReferenceDataKeys.requestType] ?? [];
    caSubSubTypes = referenceData[ReferenceDataKeys.applicationType] ?? [];
    caSubSubSubTypes = referenceData[ReferenceDataKeys.caSubSubSubTypes] ?? [];
  }

  Future<void> getFileAccessTree() async {
    try {
      fileAccesses = await fileAttachmentRepository.getFileAccessRight();
      allDocuments = await fileAttachmentRepository.getDocuments(
        documentTypes,
        [...fstSubTypes, ...clSubTypes, ...cdSubTypes, ...caSubTypes],
        [...fstSubSubTypes, ...caSubSubTypes, ...applicationTypeCustom],
        caSubSubSubTypes,
        languages,
      );
      fileAccesses = fileAttachmentRepository.calculateFileCountsAggregated(
        fileAccesses,
        allDocuments,
      );
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> getDigitalFilingViewData() async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    try {
      selectedDocs = [];
      selectedDocumentIds = [];
      fileUploadDatas = await fileAttachmentRepository.getFileUploadData(
        documentTypes,
        [...fstSubTypes, ...clSubTypes, ...cdSubTypes, ...caSubTypes],
        [...fstSubSubTypes, ...caSubSubTypes, ...applicationTypeCustom],
        caSubSubSubTypes,
        languages,
        !Utils.isGroupApplication()
            ? Globals.request!.customerRimNo?.toString()
            : null,
        null,
        Utils.isGroupApplication()
            ? Globals.request!.groupId?.toString()
            : null,
        null,
        null,
        false,
      );
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> getCompanyRims() async {
    try {
      if (!Utils.isGroupApplication()) {
        return;
      }

      applicationDetails = await CustomerRepository.instance
          .getApplicationDetails(appRefNo: Globals.request!.applicationRefNo);
      rimList = applicationDetails?.borrowers ?? [];
      // rimList = await fileAttachmentRepository
      //     .getCompanyRims(Globals.request!.groupId!);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // Call this method when the Upload button is clicked from the form.
  Future<void> onUploadDocumentsPressed() async {
    try {
      emit(state.copyWith(uploadStatus: LoadingStatus.loading));

      final String status = await fileAttachmentRepository
          .uploadDocumentsMultipart(selectedDocuments);
      selectedDocuments = [];

      AlertManager().showSuccessToast(status);
      // emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      await getFileAccessTree();
      if (selectedFolder != null) {
        onSelectFolder(selectedFolder!);
      }
      emit(state.copyWith(uploadStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(uploadStatus: LoadingStatus.error));
    }
  }

  void resetFormFields() {
    selectedLanguageType = null;
    selectedSubType = null;
    selectedSubTypeCreditLens = null;
    selectedSubSubType = null;
    selectedSubSubSubType = null;
    selectedCompanyRims = [];
    // selectedDocumentIds = [];
    // selectedDocs = [];
    isSelectAllCompanyRims = false;
    documentName = null;
    entityId = null;

    selectedDate = null;

    selectedDocumentType = null;
    formKey.currentState?.reset();

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  //pickup multiple files in one time on browse click button
  Future<void> onBrowsePressed() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    try {
      formKey.currentState?.save();

      final List<PlatformFile>? files =
          await FileUploadService.instance.pickMultipleFiles(fileType);

      if (files != null && files.isNotEmpty) {
        for (final PlatformFile file in files) {
          if (!Utils.isGroupApplication()) {
            selectedCompanyRims = [
              Customer(customerRimNo: request.customerRimNo),
            ];
          }
          // for (Customer companyRim in selectedCompanyRims) {
          if (isCreditApplicationSelected()) {
            selectedSubType = request.requestType;
            selectedSubSubType = request.applicationType;
          }
          for (final Customer companyRim in selectedCompanyRims) {
            final Document currentDocument = Document(
              folderID: selectedFolder?.id,
              subType: selectedSubType,
              subSubType: selectedSubSubType,
              subSubSubType: selectedSubSubSubType,
              documentType: selectedDocumentType,
              applicationId: request.applicationRefNo,
              date: selectedDate,
              language: selectedLanguageType,
              documentName: documentName,
              entityId: entityId,
              groupRim: request.groupId,
              companyRim: companyRim.customerRimNo.toString(),
              files: [file], // single file per document
            );

            selectedDocuments.add(currentDocument);
          }
        }

        selectedFiles = files;
        errorMessage = null;

        resetFormFields();
      } else {
        errorMessage =
            "eDigitalFilingFileAttachments.fileAttachments.noFilesSelected"
                .tr();
        selectedFiles = [];
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Removes the selected file at [index] and re-emits the state.
  void removeFileAt(int index) {
    if (index >= 0 && index < selectedDocuments.length) {
      selectedDocuments.removeAt(index);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  void onSelectFolder(FileAccess file) {
    try {
      logger.i(file.toString());
      selectedFolder = file;
      resetFormFields();
      if (file.access == AccessType.none) {
        throw "eDigitalFilingFileAttachments.fileAttachments.noAccessToView"
            .tr();
      }
      emit(
        state.copyWith(
          showUploadButton: true,
          showUploadForm: false,
        ),
      );

      uploadedDocuments = allDocuments.where((Document document) {
        return document.folderID == file.id;
      }).toList();
      if (uploadedDocuments.isEmpty) {
        emit(
          state.copyWith(
            documentsLoaderStatus: LoadingStatus.empty,
          ),
        );
      } else {
        emit(
          state.copyWith(
            documentsLoaderStatus: LoadingStatus.loaded,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          documentsLoaderStatus: LoadingStatus.error,
          documentListErrorMessage: e.toString(),
        ),
      );
    }
  }

  void showUploadForm() {
    if (selectedFolder!.access != AccessType.edit) {
      AlertManager().showFailureToast(
        "eDigitalFilingFileAttachments.fileAttachments.noAccessToUpload".tr(),
      );
      return;
    }
    emit(
      state.copyWith(
        showUploadForm: true,
        showUploadButton: false,
      ),
    );
  }

  // Toggle the selection for a given document based on its id.
  void toggleSelection(String id, bool isSelected) {
    selectedRows[id] = isSelected;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateSubTypeCredit(Reference type) {
    selectedSubSubType = type;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateSubTypeCreditLens(Reference type) {
    selectedSubTypeCreditLens = type;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void toggleDocumentSelection(String key, bool isSelected, dynamic docData) {
    final String edmsDriveItemId = docData.edmsDriveItemId ?? "";
    // selectedDocuments[key] = isSelected;
    docData.isChecked = isSelected;
    if (edmsDriveItemId != "") {
      if (isSelected) {
        selectedDocs.add(docData);
        selectedDocumentIds.add(edmsDriveItemId);
      } else {
        selectedDocs.remove(docData);
        selectedDocumentIds.remove(edmsDriveItemId);
      }
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  bool isDocumentSelected(String key) {
    return selectedCheckbocDocuments[key] ?? false;
  }

  /// Call this to update the document name.
  void updateDocumentName(String? name) {
    documentName = name;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateEntityId(String? name) {
    entityId = name;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  //update lanuguage fields
  void updateLanguageType(Reference type) {
    selectedLanguageType = type;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // Delete all documents that are selected (i.e. those with true in
  // selectedRows)
  Future<void> onDeleteDocumentPressed(Document document) async {
    try {
      document.deleteLoader = LoadingStatus.loading;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      await fileAttachmentRepository.deleteDocument(document);
      await getFileAccessTree();
      if (selectedFolder != null) {
        onSelectFolder(selectedFolder!);
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    document.deleteLoader = LoadingStatus.loaded;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onDocumentTypeChanged(Reference type) {
    resetFormFields();
    selectedDocumentType = type;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Reference? getDocumentTypeReferenceById(int id) {
    return documentTypes.firstWhere(
      (ref) => ref.id == id,
      orElse: () => Reference(id: id),
    );
  }

  void updateSelectedDate(String date) {
    selectedDate = DateTime.tryParse(date);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Call this to update the Company RIM value.
  void updateCompanyRim(List<Customer> rims) {
    selectedCompanyRims = rims;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Toggle select all company RIMs checkbox.
  /// When checked, selects all RIM values and disables the dropdown.
  /// When unchecked, clears all RIM values and enables the dropdown.
  void toggleSelectAllCompanyRims(bool value) {
    isSelectAllCompanyRims = value;
    if (value) {
      selectedCompanyRims = List.from(rimList);
    } else {
      selectedCompanyRims = [];
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Call this to update the sub type financial.
  void updateSubType(Reference type) {
    selectedSubType = type;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateSubSubType(Reference type) {
    selectedSubSubType = type;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updatesubsubsubType(Reference type) {
    selectedSubSubSubType = type;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  bool isConstitutionalDocumentsSelected() =>
      selectedDocumentType?.id ==
      ServerConstants.documentTypeId[DocumentType.constitutionalDocument];

  bool isCreditApplicationSelected() =>
      selectedDocumentType?.id ==
      ServerConstants.documentTypeId[DocumentType.creditApplication];

  bool isCreditLensSelected() =>
      selectedDocumentType?.id ==
      ServerConstants.documentTypeId[DocumentType.creditLensDocument];

  bool isFinancialStatementsSelected() =>
      selectedDocumentType?.id ==
      ServerConstants.documentTypeId[DocumentType.financialStatements];

  bool isExternalOpinionsSelected() =>
      selectedDocumentType?.id ==
      ServerConstants.documentTypeId[DocumentType.externalOpinions];

  bool isOthersSelected() =>
      selectedDocumentType?.id ==
      ServerConstants.documentTypeId[DocumentType.other];

  Future<void> downloadViewDocument(Document document) async {
    try {
      document.downloadLoader = LoadingStatus.loading;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      await fileAttachmentRepository.downloadFileAttachment(document);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    document.downloadLoader = LoadingStatus.loaded;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> downloadDocument(documentId, webUrl, documentName) async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      await fileAttachmentRepository.downloadDigitalAttachment(
        documentId,
        webUrl,
        documentName,
      );
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    // document.downloadLoader = LoadingStatus.loaded;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> downloadDocumentsZip() async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      await fileAttachmentRepository.zipDownloadDigitalAttachment(
        selectedDocumentIds,
        selectedDocs,
        request.customerRimNo.toString(),
        request.groupId.toString(),
        Globals.request?.applicationRefNo,
      );
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    // document.downloadLoader = LoadingStatus.loaded;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> mergeDownloadDocument() async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      await fileAttachmentRepository.mergeDownloadDigitalAttachment(
        selectedDocs,
        selectedDocumentIds,
        Globals.request!.customerRimNo?.toString(),
        Globals.request!.groupId?.toString(),
        "",
      );
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    // document.downloadLoader = LoadingStatus.loaded;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> linkToApplication() async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

      if (selectedDocs.isNotEmpty &&
          selectedDocs.any(
            (d) => d.docTypeId == ServerConstants.creditApplicationDocumentType,
          )) {
        AlertManager().showFailureToast(
          "eDigitalFilingFileAttachments.fileAttachments.canNotLinkApplication"
              .tr(),
        );
        return;
      }
      await fileAttachmentRepository.linkToApplication(
        Globals.request?.applicationRefNo,
        selectedDocumentIds,
      );
      AlertManager().showSuccessToast(
        "eDigitalFilingFileAttachments.fileAttachments.linkApplicationSuccess"
            .tr(),
      );
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    // document.downloadLoader = LoadingStatus.loaded;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> viewRequestSummary(
    String? applicationId,
    BuildContext context,
  ) async {
    final ApplicationDetails? applicationDetails = await CustomerRepository
        .instance
        .getApplicationDetails(appRefNo: applicationId);
    final String? applicationSummary = applicationDetails?.purpose;
    if (context.mounted) {
      await DialogHelper.showCommentContentDialog(
        context,
        applicationSummary ?? "",
        "eDigitalFilingFileAttachments.fileAttachments.requestSummary".tr(),
      );
    }
  }
}
