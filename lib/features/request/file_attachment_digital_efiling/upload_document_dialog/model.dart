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
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/file_attachment/document.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'package:wcas_frontend/repositories/file_attachment_repository.dart';

import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

class UploadDocumentDialogViewModel extends Cubit<UploadDocumentDialogState> {
  UploadDocumentDialogViewModel()
      : super(UploadDocumentDialogState(
            loaderStatus: LoadingStatus.loading,
            uploadButtonStatus: LoadingStatus.loaded));
  late RequestRepository repository;
  late FileAttachmentRepository fileAttachmentRepository;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Request request = Globals.request!;
  TextEditingController textController = TextEditingController();

  List<String> rimList = [];
  Reference? selectedLanguageType;
  List<String> selectedCompanyRim = [];
  String? documentName;
  String? applicationId;
  DateTime? selectedDate;
  int? selectedGroupRim;
  double? selectedCustomerRim;
  List<PlatformFile> selectedFiles = [];
  List<Document> selectedDocuments = [];
  String? errorMessage;
  bool isCompanyRim = false;

  // Reference data lists
  List<Reference> caSubTypes = [];
  List<Reference> caSubSubTypes = [];
  List<Reference> languages = [];
  List<Reference> documentTypes = [];
  Reference? selectedDocumentType;

  List<Reference> subTypes = [];
  List<Reference> subsubTypes = [];
  //credit lens sub type
  List<Reference> clSubTypes = [];
  Reference? selectedSubTypeCreditLens;

  //credit application sub sub sub type
  List<Reference> caSubSubSubTypes = [];
  Reference? selectedSubTypeCredit;

  List<Reference> cdSubTypes = [];

  List<Reference> fstSubTypes = [];
  Reference? selectedSubTypeFinancial;

  List<Reference> fstSubSubTypes = [];
  Reference? selectedSubSubTypeFinancial;

  void init(BuildContext context,
      {required String groupRim,
      required String customerRim,
      required String applicationId,
      required List<String>? rimsList}) async {
    repository = RequestRepository.instance;
    fileAttachmentRepository = FileAttachmentRepository.instance;
    await loadReferenceData();
    await getCompanyRims();
    updateGroupRim(groupRim);
    if (customerRim != '') {
      updateCustomerRim(customerRim);
    }
    updateApplicationId(applicationId);
    rimList = rimsList ?? [];
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
      ReferenceDataKeys.caSubTypes,
      ReferenceDataKeys.caSubSubTypes,
      ReferenceDataKeys.caSubSubSubTypes
    ]);

    // Populate reference data lists
    documentTypes = referenceData[ReferenceDataKeys.documentTypes] ?? [];
    documentTypes = documentTypes.where((document) {
      int? documentId = document.id;
      if (documentId == null) return true;
      return documentId !=
          ServerConstants.documentTypeId[DocumentType.creditApplication];
    }).toList();

    fstSubTypes = referenceData[ReferenceDataKeys.fstSubTypes] ?? [];
    fstSubSubTypes = referenceData[ReferenceDataKeys.fstSubsubTypes] ?? [];
    languages = referenceData[ReferenceDataKeys.languages] ?? [];
    clSubTypes = referenceData[ReferenceDataKeys.clSubTypes] ?? [];
    subTypes = referenceData[ReferenceDataKeys.caSubTypes] ?? [];
    subsubTypes = referenceData[ReferenceDataKeys.caSubSubTypes] ?? [];
    caSubSubSubTypes = referenceData[ReferenceDataKeys.caSubSubSubTypes] ?? [];
  }

  void updateSearchValue(String? searchValue) async {}

  Future<void> getCompanyRims() async {
    try {
      if (!Utils.isGroupApplication() || selectedGroupRim == null) {
        return;
      }
      rimList =
          await fileAttachmentRepository.getCompanyRims(selectedGroupRim!);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Call this to update the Company RIM value.
  void updateCompanyRim(List<String> rims) {
    selectedCompanyRim = rims;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Call this to update the document name.
  void updateApplicationId(String? appId) {
    applicationId = appId;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Call this to update the document name.
  void updateDocumentName(String? name) {
    documentName = name;
    textController.text = name!;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateDocumentType(Reference type) {
    selectedDocumentType = type;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateLanguageType(Reference type) {
    selectedLanguageType = type;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateGroupRim(String groupRim) {
    selectedGroupRim = int.tryParse(groupRim);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateCustomerRim(String customerRim) {
    isCompanyRim = true;
    selectedCustomerRim = double.tryParse(customerRim);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Call this to update the sub type credit lens.
  void updateSubTypeCredit(Reference type) {
    selectedSubTypeCredit = type;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateSubTypeCreditLens(Reference type) {
    selectedSubTypeCreditLens = type;
    updateDocumentName(type.name);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Call this to update the sub type financial.
  void updateSubTypeFinancial(Reference type) {
    selectedSubTypeFinancial = type;
    // update document name accordingly
    updateDocumentName(type.name);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateSubSubTypeFinancial(Reference type) {
    selectedSubSubTypeFinancial = type;
    if (type.id == ServerConstants.subSubTypeFinancialProjection) {
      updateDocumentName("");
    } else {
      updateDocumentName(selectedSubTypeFinancial?.name);
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

  // Call this method when the Upload button is clicked from the form.
  Future<void> onUploadDocumentsPressed(BuildContext context) async {
    emit(state.copyWith(uploadButtonStatus: LoadingStatus.loading));
    String? status = await fileAttachmentRepository
        .uploadDigitalDocuments(selectedDocuments);

    emit(state.copyWith(uploadButtonStatus: LoadingStatus.loaded));
    AlertManager().showSuccessToast(status ??
        "eDigitalFilingFileAttachments.fileAttachments.formUploadedSuccessfully"
            .tr());
    if (context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void resetFormFields() {
    selectedLanguageType = null;
    selectedSubTypeFinancial = null;
    selectedSubTypeCreditLens = null;
    selectedSubSubTypeFinancial = null;
    selectedCompanyRim = [];
    documentName = null;
    // applicationId = null;
    textController.text = "";
    selectedDate = null;
    selectedGroupRim = null;
    formKey.currentState?.reset();

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

//pickup multiple files in one time on browse click button
  Future<void> pickMultipleFiles() async {
    if (!(formKey.currentState!.validate())) {
      return;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    try {
      formKey.currentState?.save();

      List<PlatformFile>? files =
          await FileUploadService.instance.pickMultipleFiles();

      if (files != null && files.isNotEmpty) {
        for (PlatformFile file in files) {
          if (selectedCompanyRim.isNotEmpty) {
            for (String rim in selectedCompanyRim) {
              final Document currentDocument = Document(
                // folderID: selectedFolder?.id,
                subType: selectedSubTypeFinancial ?? selectedSubTypeCreditLens,
                subSubType: selectedSubSubTypeFinancial,
                documentType: selectedDocumentType,
                applicationId: applicationId,
                date: selectedDate,
                language: selectedLanguageType,
                documentName: documentName,
                groupRim: selectedGroupRim,
                companyRim: rim, // single RIM per document
                files: [file], // single file per document
              );
              selectedDocuments.add(currentDocument);
            }
          } else {
            // fallback if no RIM selected
            final Document currentDocument = Document(
              // folderID: selectedFolder?.id,
              subType: selectedSubTypeFinancial,
              subSubType: selectedSubSubTypeFinancial,
              documentType: selectedDocumentType,
              applicationId: applicationId,
              date: selectedDate,
              language: selectedLanguageType,
              documentName: documentName,
              groupRim: selectedGroupRim,
              companyRim: null,
              files: [file],
            );
            selectedDocuments.add(currentDocument);
          }
        }

        selectedFiles = files;
        errorMessage = null;

        // AlertManager().showSuccessToast(
        //   "eDigitalFilingFileAttachments.fileAttachments.documentUploadedSuccessFully"
        //       .tr(),
        // );

        // resetFormFields();
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

  bool isConstitutionalDocumentsSelected() =>
      selectedDocumentType?.id ==
      ServerConstants.documentTypeId[DocumentType.constitutionalDocument];

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
    await fileAttachmentRepository.downloadFileAttachment(document);
  }

  void onDocumentTypeChanged(Reference type) {
    selectedDocumentType = type;
    updateDocumentName("");
    resetFormFields();
    selectedSubTypeFinancial = null;
    selectedSubTypeCreditLens = null;
    selectedSubSubTypeFinancial = null;
    selectedDate = null;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}
