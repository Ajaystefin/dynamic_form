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
import "package:wcas_frontend/core/utils/api_exception.dart";
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
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart";
import "package:wcas_frontend/models/request/file_attachment/document.dart";
import "package:wcas_frontend/models/request/file_attachment/file_upload.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/file_attachment_repository.dart";

/// FileAttachmentViewModel view model
class FileAttachmentViewModel extends SafeCubit<FileAttachmentState>
    implements AttachmentViewModel {
  /// Creates instance
  FileAttachmentViewModel()
      : super(
          FileAttachmentState(
            loaderStatus: LoadingStatus.loading,
            documentsLoaderStatus: LoadingStatus.loaded,
            digitalFilesStatus: LoadingStatus.loaded,
            legacyLoaderStatus: LoadingStatus.loaded,
          ),
        );

  /// FileAttachmentRepository reference variable
  late FileAttachmentRepository fileAttachmentRepository;

  /// List of PlatformFile
  List<PlatformFile> selectedFiles = [];

  /// GlobalKey key for form
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Request data from globals
  Request request = Globals.request!;

  /// error message
  String? errorMessage;

  /// ApplicationDetails reference variable
  ApplicationDetails? applicationDetails;

  /// document name
  String? documentName;

  /// entity id
  String? entityId;

  /// selected group rim
  double? selectedGroupRim;

  /// List of Reference
  List<Reference> languages = [];

  /// List of Reference
  List<Reference> applicationTypeCustom = [];

  /// Reference data
  Reference? selectedLanguageType;

  /// Data for selected Checkboc Documents
  final Map<String, bool> selectedCheckbocDocuments = {};

  /// List of Document
  List<Document> selectedDocuments = [];

  /// List of selected document ids
  List<String> selectedDocumentIds = [];

  /// List of DocSubTypeData
  List<DocSubTypeData?> selectedDocs = [];

  /// List of Document
  List<Document> uploadedDocuments = [];

  /// List of Document
  List<Document> allDocuments = [];

  /// Manage checkbox selections for products using their ID as key.
  Map<String, bool> selectedRows = {};

  /// file tree data
  List<FileAccess> fileAccesses = [];

  /// FileAccess reference variable
  FileAccess? selectedFolder;
  @override
  List<FileDetail> fileUploadDatas = [];

  List<DocSubTypeDetail> legacyFiles = [];

  /// List of Customer
  List<Customer> rimList = [];

  /// List of Customer
  List<Customer> selectedCompanyRims = [];

  /// is Select All Company Rims flag
  bool isSelectAllCompanyRims = false;

  /// selected date
  DateTime? selectedDate = DateTime.now();

  /// Reference data lists
  List<Reference> documentTypes = [];

  /// Reference data lists
  List<Reference> fileType = [];

  /// Reference data
  Reference? selectedDocumentType;

  /// Reference data lists
  List<Reference> caSubTypes = [];

  /// Reference data lists
  List<Reference> caSubSubTypes = [];

  /// Reference data
  Reference? selectedSubSubType;

  ///credit lens sub type
  List<Reference> clSubTypes = [];

  /// Reference data
  Reference? selectedSubTypeCreditLens;

  ///credit application sub sub sub type
  List<Reference> caSubSubSubTypes = [];

  /// Reference data
  Reference? selectedSubSubSubType;

  /// Reference data lists
  List<Reference> cdSubTypes = [];

  /// Reference data lists
  List<Reference> fstSubTypes = [];

  /// Reference data
  Reference? selectedSubType;

  /// Reference data lists
  List<Reference> fstSubSubTypes = [];

  /// can edit page mode
  bool get canEdit => pageMode == PageMode.edit;

  /// page mode
  PageMode pageMode = PageMode.na;

  /// status for button visibility
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

  /// show Approval SubType for user roles
  final bool showApprovalSubType = Utils.checkRoles([
    UserRole.relationshipOfficer,
    UserRole.relationshipManager,
    UserRole.businessUnitHead,
    UserRole.creditCordinator,
  ]);

  /// init method
  Future<void> init(BuildContext context) async {
    logger.i("initialising FileAttachmentViewModel");
    fileAttachmentRepository = FileAttachmentRepository.instance;
    await loadReferenceData();
    await getFileAccessTree();
    await getCompanyRims();
    await getLegacyDocuments();

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

    if (showApprovalSubType) {
      caSubSubSubTypes = caSubSubSubTypes.where((document) {
        final int? documentId = document.id;
        if (documentId == null) {
          return true;
        }
        return documentId !=
            ServerConstants.subSubSubTypeCreditApplicationApprovalDecision;
      }).toList();
    }
  }

  /// get File Access Tree
  Future<void> getFileAccessTree() async {
    try {
      fileAccesses = await fileAttachmentRepository.getFileAccessRight();
      allDocuments = await fileAttachmentRepository.getDocuments(
        showApprovalSubType: showApprovalSubType,
        documentTypes: documentTypes,
        subTypes: [...fstSubTypes, ...clSubTypes, ...cdSubTypes, ...caSubTypes],
        subSubTypes: [
          ...fstSubSubTypes,
          ...caSubSubTypes,
          ...applicationTypeCustom,
        ],
        subSubSubTypes: caSubSubSubTypes,
        languages: languages,
      );
      fileAccesses = fileAttachmentRepository.calculateFileCountsAggregated(
        fileAccesses,
        allDocuments,
      );
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// get Digital Filing View Data
  Future<void> getDigitalFilingViewData() async {
    try {
      selectedDocs = [];
      selectedDocumentIds = [];
      fileUploadDatas = await fileAttachmentRepository.getFileUploadData(
        [...documentTypes, ...ServerConstants.facilityValuationRefs.values],
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
        isLegacy: false,
      );
      emit(state.copyWith(digitalFilesStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(digitalFilesStatus: LoadingStatus.loaded));
  }

  Future<void> getLegacyDocuments() async {
    emit(state.copyWith(legacyLoaderStatus: LoadingStatus.loading));
    try {
      legacyFiles = await fileAttachmentRepository.getLegacyDocuments();
      emit(state.copyWith(legacyLoaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(legacyLoaderStatus: LoadingStatus.loaded));
  }

  /// get Company Rims data
  Future<void> getCompanyRims() async {
    try {
      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.loaded,
          digitalFilesStatus: LoadingStatus.loading,
        ),
      );

      applicationDetails =
          await CustomerRepository.instance.getApplicationDetails(
        appRefNo: Globals.request!.applicationRefNo,
      );

      if (Utils.isGroupApplication()) {
        rimList = applicationDetails?.borrowers ?? [];
      }
      // Always call this
      await getDigitalFilingViewData();
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    } finally {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Call this method when the Upload button is clicked from the form.
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
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(uploadStatus: LoadingStatus.error));
    }
  }

  /// reset Form Fields
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

  ///pickup multiple files in one time on browse click button
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
    } on Object catch (e) {
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

  /// on Select Folder action
  void onSelectFolder(FileAccess file) {
    try {
      logger.i(file.toString());
      selectedFolder = file;
      resetFormFields();
      if (file.access == AccessType.none) {
        final message =
            "eDigitalFilingFileAttachments.fileAttachments.noAccessToView".tr();
        throw ApiException(message);
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
    } on Object catch (e) {
      emit(
        state.copyWith(
          documentsLoaderStatus: LoadingStatus.error,
          documentListErrorMessage: e.toString(),
        ),
      );
    }
  }

  /// show Upload Form
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

  /// Toggle the selection for a given document based on its id.
  void toggleSelection(String id, {required bool isSelected}) {
    selectedRows[id] = isSelected;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// update SubType Credit
  void updateSubTypeCredit(Reference type) {
    selectedSubSubType = type;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// update SubType CreditLens
  void updateSubTypeCreditLens(Reference type) {
    selectedSubTypeCreditLens = type;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// mark Checked By Edms Id
  Future<void> markCheckedByEdmsId(
    List<FileDetail>? fileUploadDatas,
    String? targetEdmsDriveItemId, {
    required bool isChecked,
  }) async {
    if (fileUploadDatas == null || targetEdmsDriveItemId == null) {
      return;
    }

    for (final fileDetail in fileUploadDatas) {
      final documents = fileDetail.documents;
      if (documents == null) {
        continue;
      }

      for (final document in documents) {
        final docYears = document.docYears;
        if (docYears == null) {
          continue;
        }

        for (final year in docYears) {
          final caDocTypes = year.caDocTypeData;
          if (caDocTypes == null) {
            continue;
          }

          for (final caType in caDocTypes) {
            final subTypes = caType.docSubType;
            if (subTypes == null) {
              continue;
            }

            for (final subType in subTypes) {
              final data = subType.data;
              if (data?.edmsDriveItemId == targetEdmsDriveItemId) {
                data?.isChecked = isChecked;
                return; // stop once found
              }
            }
          }
        }
      }
    }
  }

  @override
  Future<void> toggleDocumentSelection(
    String key,
    DocSubTypeData? docData, {
    required bool isSelected,
  }) async {
    final String edmsDriveItemId = docData?.edmsDriveItemId ?? "";
    // selectedDocuments[key] = isSelected;
    docData?.isChecked = isSelected;

    await markCheckedByEdmsId(
      fileUploadDatas,
      edmsDriveItemId,
      isChecked: isSelected,
    );

    if (edmsDriveItemId != "") {
      if (isSelected) {
        selectedDocs.add(docData);
        selectedDocumentIds.add(edmsDriveItemId);
      } else {
        selectedDocs.removeWhere(
          (detail) =>
              detail?.edmsDriveItemId == edmsDriveItemId ||
              (detail?.files ?? [])
                  .any((f) => f.edmsDriveItemId == edmsDriveItemId),
        );

        // selectedDocs.remove(docData);
        selectedDocumentIds.remove(edmsDriveItemId);
      }
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Call this to update the document name.
  void updateDocumentName(String? name) {
    documentName = name;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// update Entity Id
  void updateEntityId(String? name) {
    entityId = name;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  ///update lanuguage fields
  void updateLanguageType(Reference type) {
    selectedLanguageType = type;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Delete all documents that are selected (i.e. those with true in
  /// selectedRows)
  Future<void> onDeleteDocumentPressed(Document document) async {
    try {
      document.deleteLoader = LoadingStatus.loading;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      await fileAttachmentRepository.deleteDocument(document);
      await getFileAccessTree();
      if (selectedFolder != null) {
        onSelectFolder(selectedFolder!);
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    document.deleteLoader = LoadingStatus.loaded;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// on Document Type Changed
  void onDocumentTypeChanged(Reference type) {
    resetFormFields();
    selectedDocumentType = type;
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
  void toggleSelectAllCompanyRims({required bool value}) {
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

  /// update Sub SubType
  void updateSubSubType(Reference type) {
    selectedSubSubType = type;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// update Sub Sub SubType
  void updatesubsubsubType(Reference type) {
    selectedSubSubSubType = type;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// is Constitutional Documents Selected
  bool isConstitutionalDocumentsSelected() =>
      selectedDocumentType?.id ==
      ServerConstants.documentTypeId[DocumentType.constitutionalDocument];

  /// is Credit Application Selected
  bool isCreditApplicationSelected() =>
      selectedDocumentType?.id ==
      ServerConstants.documentTypeId[DocumentType.creditApplication];

  /// is CreditLens Selected
  bool isCreditLensSelected() =>
      selectedDocumentType?.id ==
      ServerConstants.documentTypeId[DocumentType.creditLensDocument];

  /// is Financial Statements Selected
  bool isFinancialStatementsSelected() =>
      selectedDocumentType?.id ==
      ServerConstants.documentTypeId[DocumentType.financialStatements];

  /// is External Opinions Selected
  bool isExternalOpinionsSelected() =>
      selectedDocumentType?.id ==
      ServerConstants.documentTypeId[DocumentType.externalOpinions];

  /// is Others Selected
  bool isOthersSelected() =>
      selectedDocumentType?.id ==
      ServerConstants.documentTypeId[DocumentType.other];

  /// download View Document
  Future<void> downloadViewDocument(Document document) async {
    try {
      document.downloadLoader = LoadingStatus.loading;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      await fileAttachmentRepository.downloadFileAttachment(document);
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    document.downloadLoader = LoadingStatus.loaded;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  @override
  Future<void> downloadDocument(
    String documentId,
    String webUrl,
    String documentName,
  ) async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      await fileAttachmentRepository.downloadDigitalAttachment(
        documentId,
        webUrl,
        documentName,
      );
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    // document.downloadLoader = LoadingStatus.loaded;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// download Documents in Zip
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
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    // document.downloadLoader = LoadingStatus.loaded;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// merge Download Document
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
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    // document.downloadLoader = LoadingStatus.loaded;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// link to application
  Future<void> linkToApplication() async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

      if (selectedDocs.isNotEmpty &&
          selectedDocs.any(
            (d) => d?.docTypeId == DocumentType.creditApplication,
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
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    // document.downloadLoader = LoadingStatus.loaded;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  @override
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
