import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/file_upload_service.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/page.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/file_attachment/document.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'package:wcas_frontend/repositories/file_attachment_repository.dart';
import '../../../../models/admin/file_access.dart';
import '../../../../models/request/file_attachment/file_upload.dart';

import 'state.dart';

class FileAttachmentViewModel extends Cubit<FileAttachmentState> {
  FileAttachmentViewModel()
      : super(FileAttachmentState(
            loaderStatus: LoadingStatus.loading,
            documentsLoaderStatus: LoadingStatus.loaded));
  late FileAttachmentRepository repository;

  List<PlatformFile> selectedFiles = [];

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Request request = Globals.request!;
  String? errorMessage;

  String? documentName;
  double? selectedGroupRim;

  List<Reference> languages = [];

  Reference? selectedLanguageType;

  final Map<String, bool> selectedCheckbocDocuments = {};

  List<Document> selectedDocuments = [];

  List<Document> uploadedDocuments = [];

  List<Document> allDocuments = [];

  // Manage checkbox selections for products using their ID as key.
  Map<String, bool> selectedRows = {};

  // file tree data
  List<FileAccess> fileAccesses = [];

  FileAccess? selectedFolder;
  List<FileDetail> fileUploadDatas = [];

  List<String> rimList = [];

  List<String> selectedCompanyRims = [];

  bool isSelectAllCompanyRims = false;

  DateTime? selectedDate;

  // Reference data lists
  List<Reference> documentTypes = [];
  Reference? selectedDocumentType;

  List<Reference> caSubTypes = [];
  List<Reference> caSubSubTypes = [];
  //credit lens sub type
  List<Reference> clSubTypes = [];
  Reference? selectedSubTypeCreditLens;

  //credit application sub sub sub type
  List<Reference> caSubSubSubTypes = [];
  Reference? selectedSubSubType;

  List<Reference> cdSubTypes = [];

  List<Reference> fstSubTypes = [];
  Reference? selectedSubType;

  List<Reference> fstSubSubTypes = [];

  void init(context) async {
    logger.i('initialising FileAttachmentViewModel');
    repository = FileAttachmentRepository.instance;
    await loadReferenceData();
    await getFileAccessTree();
    await getCompanyRims();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Loads reference data required for dropdowns and labels.
  ///
  /// Fetches data from the `ReferenceDataService` and populates local lists.
  Future<void> loadReferenceData() async {
    Map<String, List<Reference>> referenceData =
        await ReferenceDataService().getReferenceData([
      ReferenceDataKeys.documentTypes,
      ReferenceDataKeys.fstSubTypes,
      ReferenceDataKeys.fstSubsubTypes,
      ReferenceDataKeys.languages,
      ReferenceDataKeys.clSubTypes,
      // ReferenceDataKeys.cdSubTypes,
      ReferenceDataKeys.caSubTypes,
      ReferenceDataKeys.caSubSubTypes,
      ReferenceDataKeys.caSubSubSubTypes
    ]);

    // Populate reference data lists
    documentTypes = referenceData[ReferenceDataKeys.documentTypes] ?? [];
    fstSubTypes = referenceData[ReferenceDataKeys.fstSubTypes] ?? [];
    fstSubSubTypes = referenceData[ReferenceDataKeys.fstSubsubTypes] ?? [];
    languages = referenceData[ReferenceDataKeys.languages] ?? [];
    clSubTypes = referenceData[ReferenceDataKeys.clSubTypes] ?? [];
    // cdSubTypes = referenceData[ReferenceDataKeys.cdSubTypes] ?? [];
    caSubTypes = referenceData[ReferenceDataKeys.requestType] ?? [];
    caSubSubTypes = referenceData[ReferenceDataKeys.applicationType] ?? [];
    caSubSubSubTypes = referenceData[ReferenceDataKeys.caSubSubSubTypes] ?? [];
  }

  Future<void> getFileAccessTree() async {
    try {
      fileUploadDatas = await repository.getFileUploadData(
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          Globals.request?.applicationRefNo);
      fileAccesses = await repository.getFileAccessRight();
      allDocuments = await repository.getDocuments(
          documentTypes,
          [...fstSubTypes, ...clSubTypes, ...cdSubTypes, ...caSubTypes],
          [...fstSubSubTypes, ...caSubSubTypes],
          caSubSubSubTypes,
          languages);
      fileAccesses = repository.calculateFileCounts(fileAccesses, allDocuments);
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
      rimList = await repository.getCompanyRims(Globals.request!.groupId!);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // Call this method when the Upload button is clicked from the form.
  Future<void> onUploadDocumentsPressed() async {
    try {
      await repository.uploadDocuments(selectedDocuments);
      selectedDocuments = [];

      AlertManager().showSuccessToast(
          "eDigitalFilingFileAttachments.fileAttachments.formUploadedSuccessfully"
              .tr());
      // emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      await getFileAccessTree();
      if (selectedFolder != null) {
        onSelectFolder(selectedFolder!);
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  void resetFormFields() {
    selectedLanguageType = null;
    selectedSubType = null;
    selectedSubTypeCreditLens = null;
    selectedSubSubType = null;
    selectedCompanyRims = [];
    isSelectAllCompanyRims = false;
    documentName = null;

    selectedDate = null;

    selectedDocumentType = null;
    formKey.currentState?.reset();

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  //pickup multiple files in one time on browse click button
  Future<void> onBrowsePressed() async {
    if (!(formKey.currentState!.validate())) {
      return;
    }
    try {
      formKey.currentState?.save();

      List<PlatformFile>? files =
          await FileUploadService.instance.pickMultipleFiles();

      if (files != null && files.isNotEmpty) {
        for (PlatformFile file in files) {
          for (String companyRim in selectedCompanyRims) {
            if (!Utils.isGroupApplication()) {
              selectedCompanyRims = [request.customerRimNo.toString()];
            }
            if (isCreditApplicationSelected()) {
              selectedSubType = request.requestType;
              selectedSubSubType = request.applicationType;
            }
            final Document currentDocument = Document(
              folderID: selectedFolder?.id,
              subType: selectedSubType,
              subSubType: selectedSubSubType,
              documentType: selectedDocumentType,
              applicationId: request.applicationRefNo,
              date: selectedDate,
              language: selectedLanguageType,
              documentName: documentName,
              groupRim: request.groupId,
              companyRim: companyRim,
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
    if (index >= 0 &&
        index < selectedFiles.length &&
        index < selectedDocuments.length) {
      selectedDocuments.removeAt(index);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  void onSelectFolder(FileAccess file) {
    try {
      logger.i(file.toString());
      selectedFolder = file;
      resetFormFields();
      selectedDocuments = [];
      if (file.access == AccessType.none) {
        throw 'eDigitalFilingFileAttachments.fileAttachments.noAccessToView'
            .tr();
      }
      emit(state.copyWith(
        showUploadButton: true,
        showUploadForm: false,
      ));

      uploadedDocuments = allDocuments.where((Document document) {
        return document.folderID == file.id;
      }).toList();
      if (uploadedDocuments.isEmpty) {
        emit(state.copyWith(
          documentsLoaderStatus: LoadingStatus.empty,
        ));
      } else {
        emit(state.copyWith(
          documentsLoaderStatus: LoadingStatus.loaded,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
          documentsLoaderStatus: LoadingStatus.error,
          documentListErrorMessage: e.toString()));
    }
  }

  void showUploadForm() {
    if (selectedFolder!.access != AccessType.edit) {
      AlertManager().showFailureToast(
          "eDigitalFilingFileAttachments.fileAttachments.noAccessToUpload"
              .tr());
      return;
    }
    emit(state.copyWith(
      showUploadForm: true,
      showUploadButton: false,
    ));
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

  void toggleDocumentSelection(String key, bool isSelected) {
    selectedCheckbocDocuments[key] = isSelected;
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

  //update lanuguage fields
  void updateLanguageType(Reference type) {
    selectedLanguageType = type;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // Delete all documents that are selected (i.e. those with true in selectedRows)
  Future<void> onDeleteDocumentPressed(Document document) async {
    try {
      document.deleteLoader = LoadingStatus.loading;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      await repository.deleteDocument(document);
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
  void updateCompanyRim(List<String> rims) {
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
      await repository.downloadFileAttachment(document);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    document.downloadLoader = LoadingStatus.loaded;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}
