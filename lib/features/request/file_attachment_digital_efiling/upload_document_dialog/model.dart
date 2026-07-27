import "package:easy_localization/easy_localization.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/file_upload_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/file_attachment/document.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/file_attachment_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// UploadDocumentDialog ViewModel
class UploadDocumentDialogViewModel
    extends SafeCubit<UploadDocumentDialogState> {
  /// Creates instance
  UploadDocumentDialogViewModel()
      : super(
          UploadDocumentDialogState(
            loaderStatus: LoadingStatus.loading,
            uploadButtonStatus: LoadingStatus.loaded,
          ),
        );

  ///  to call RequestRepository API's
  late RequestRepository repository;

  /// to call FileAttachmentRepository API's
  late FileAttachmentRepository fileAttachmentRepository;

  /// GlobalKey key for form
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Request data from global
  Request request = Globals.request!;

  /// TextEditingController for document
  TextEditingController documentNameCtrl = TextEditingController();

  /// TextEditingController for  entity id
  TextEditingController entityIdCtrl = TextEditingController();

  /// TextEditingController for application ref no
  TextEditingController appRefNoCtrl = TextEditingController();

  /// List of Customer
  List<Customer> rimList = [];

  /// Reference Data
  Reference? selectedLanguageType;

  /// List of Customer
  List<Customer> selectedCompanyRims = [];

  /// whether select all comapny rims
  bool isSelectAllCompanyRims = false;

  /// Document name
  String? documentName;

  /// entity id
  String? entityId;

  /// application id
  String? applicationId;

  /// selected date
  DateTime? selectedDate;

  /// selected group rim
  int? selectedGroupRim;

  /// selected customer rim
  int? selectedCustomerRim;

  /// List of PlatformFile
  List<PlatformFile> selectedFiles = [];

  /// List of Document
  List<Document> selectedDocuments = [];

  /// error message
  String? errorMessage;

  /// is company rim or not
  bool isCompanyRim = false;

  /// ApplicationDetails refernce variable
  ApplicationDetails? applicationDetails;

  /// is group application flag
  bool isGroupApp = false;

  /// Reference data lists
  /// List of Reference for file type
  List<Reference> fileType = [];

  /// List of Reference for CA Sub Types
  List<Reference> caSubTypes = [];

  /// List of Reference for CA Sub SubType
  List<Reference> caSubSubTypes = [];

  /// List of Reference for languages
  List<Reference> languages = [];

  /// List of Reference for document types
  List<Reference> documentTypes = [];

  /// Reference Data
  Reference? selectedDocumentType;

  /// List of Reference
  List<Reference> subTypes = [];

  /// List of Reference
  List<Reference> subsubTypes = [];

  /// credit lens sub type
  List<Reference> clSubTypes = [];

  /// Reference Data
  Reference? selectedSubTypeCreditLens;

  /// credit application sub sub sub type
  List<Reference> caSubSubSubTypes = [];

  /// Reference Data
  Reference? selectedSubTypeCredit;

  /// List of Reference
  List<Reference> cdSubTypes = [];

  /// List of Reference
  List<Reference> fstSubTypes = [];

  /// Reference Data
  Reference? selectedSubTypeFinancial;

  /// List of Reference
  List<Reference> fstSubSubTypes = [];

  /// Reference Data
  Reference? selectedSubSubTypeFinancial;

  /// init method
  Future<void> init(
    BuildContext context, {
    required String groupRim,
    required String customerRim,
    required String applicationId,
    required int searchedBy,
    List<Customer>? companyRims,
    String? grpId,
  }) async {
    rimList = companyRims ?? [];
    repository = RequestRepository.instance;
    fileAttachmentRepository = FileAttachmentRepository.instance;
    if (applicationId.isNotEmpty) {
      updateApplicationId(applicationId);
      await getApplicationDetails(applicationId, shouldOverrideRIM: true);
      
    }
    if (searchedBy == 1 || searchedBy == 2) {
      updateGroupRim(groupRim);
      isGroupApp = true;
      if (rimList.isEmpty) {
        await getCompanyRims();
      }
    } else if (groupRim == "0") {
      updateCustomerRim(customerRim);
      if (grpId != "" && grpId != "0") {
        updateGroupRim(grpId ?? "0");
      }
    }
    if (searchedBy == 3 || searchedBy == 4) {
      updateCustomerRim(customerRim);
    }
    if (groupRim != "" && groupRim != "0") {
      updateGroupRim(groupRim);
    }
    await loadReferenceData();
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
      ReferenceDataKeys.caSubTypes,
      ReferenceDataKeys.caSubSubTypes,
      ReferenceDataKeys.caSubSubSubTypes,
    ]);

    // Populate reference data lists
    fileType = referenceData[ReferenceDataKeys.fileType] ?? [];
    documentTypes = referenceData[ReferenceDataKeys.documentTypes] ?? [];
    documentTypes = documentTypes.where((document) {
      final int? documentId = document.id;
      if (documentId == null) {
        return true;
      }
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

  /// fetch company RIM's data
  Future<void> getCompanyRims() async {
    try {
      if ((!isGroupApp || selectedGroupRim == null) && applicationId == null) {
        return;
      }
      rimList =
          await fileAttachmentRepository.getCompanyRims(selectedGroupRim!);
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// get applicaitons details
  Future<void> getApplicationDetails(
    String? applicationId, {
    required bool shouldOverrideRIM,
  }) async {
    try {
      if (applicationId == null) {
        return;
      }

      applicationDetails = await CustomerRepository.instance
          .getApplicationDetails(appRefNo: applicationId);
      isGroupApp = applicationDetails?.groupID != null &&
            applicationDetails?.groupID != 0;
      if (shouldOverrideRIM) {
        if (isGroupApp) {
          rimList = applicationDetails?.borrowers ?? [];
          updateGroupRim(applicationDetails?.groupID.toString() ?? "");
        } else {
          updateCustomerRim(
            applicationDetails?.borrowers?.first.customerRimNo.toString() ??
                "0",
          );
        }
      }
    } on Object {
      AlertManager().showFailureToast("common.noAppRef".tr());
    }
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

  /// Call this to update the document name.
  void updateApplicationId(String? appId) {
    applicationId = appId;
    appRefNoCtrl.text = appId ?? "";
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Call this to update the document name.
  void updateDocumentName(String? name) {
    documentName = name;
    documentNameCtrl.text = name!;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Call this to update the document name.
  void updateEntityId(String? name) {
    entityId = name;
    entityIdCtrl.text = name!;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// update language type
  void updateLanguageType(Reference type) {
    selectedLanguageType = type;
    if (type.id != ServerConstants.languageEnglish &&
        type.id != ServerConstants.languageArabic) {
      entityId = "";
      entityIdCtrl.text = "";
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// update group rim
  void updateGroupRim(String groupRim) {
    if (groupRim != "0" && groupRim.isNotEmpty) {
      selectedGroupRim = int.tryParse(groupRim);
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// update customer rim
  void updateCustomerRim(String customerRim) {
    isCompanyRim = true;
    selectedCustomerRim = int.tryParse(customerRim);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Call this to update the sub type credit lens.
  void updateSubTypeCredit(Reference type) {
    selectedSubTypeCredit = type;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// update SubType CreditLens
  void updateSubTypeCreditLens(Reference type) {
    selectedSubTypeCreditLens = type;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Call this to update the sub type financial.
  void updateSubTypeFinancial(Reference type) {
    selectedSubTypeFinancial = type;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// update Sub SubType Financial
  void updateSubSubTypeFinancial(Reference type) {
    selectedSubSubTypeFinancial = type;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Removes the selected file at [index] and re-emits the state.
  void removeFileAt(int index) {
    if (index >= 0 && index < selectedDocuments.length) {
      selectedDocuments.removeAt(index);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Call this method when the Upload button is clicked from the form.
  Future<void> onUploadDocumentsPressed(BuildContext context) async {
    emit(state.copyWith(uploadButtonStatus: LoadingStatus.loading));
    try {
      final String status = await fileAttachmentRepository
          .uploadDigitalDocuments(selectedDocuments);
      // status;
      AlertManager().showSuccessToast(status);
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(uploadButtonStatus: LoadingStatus.loaded));
    if (context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  /// rest form fields
  void resetFormFields() {
    selectedDocumentType = null;
    selectedLanguageType = null;
    selectedSubTypeFinancial = null;
    selectedSubTypeCreditLens = null;
    selectedSubSubTypeFinancial = null;
    selectedCompanyRims = [];
    isSelectAllCompanyRims = false;
    documentName = null;
    entityId = null;
    // applicationId = null;
    documentNameCtrl.text = "";
    entityIdCtrl.text = "";
    selectedDate = null;
    // selectedGroupRim = null;
    formKey.currentState?.reset();

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  ///pickup multiple files in one time on browse click button
  Future<void> pickMultipleFiles() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      if (appRefNoCtrl.text != "" && applicationDetails == null) {
        await getApplicationDetails(
          appRefNoCtrl.text,
          shouldOverrideRIM: false,
        );
        if (applicationDetails?.createdDate == null) {
          return;
        }
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    try {
      formKey.currentState?.save();

      final List<PlatformFile>? files =
          await FileUploadService.instance.pickMultipleFiles(fileType);

      if (files != null && files.isNotEmpty) {
        for (final PlatformFile file in files) {
          if (!isGroupApp) {
            selectedCompanyRims = [
              Customer(customerRimNo: selectedCustomerRim),
            ];
          }
          if (selectedCompanyRims.isNotEmpty) {
            for (final Customer companyRim in selectedCompanyRims) {
              final Document currentDocument = Document(
                subType: selectedSubTypeFinancial ?? selectedSubTypeCreditLens,
                subSubType: selectedSubSubTypeFinancial,
                documentType: selectedDocumentType,
                applicationId: applicationId ?? appRefNoCtrl.text,
                date: selectedDate,
                language: selectedLanguageType,
                documentName: documentName,
                entityId: entityId,
                groupRim: selectedGroupRim,
                companyRim: companyRim.customerRimNo.toString(),
                files: [file], // single file per document
              );
              selectedDocuments.add(currentDocument);
            }
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

  /// if selected document type is constitutional
  bool isConstitutionalDocumentsSelected() =>
      selectedDocumentType?.id ==
      ServerConstants.documentTypeId[DocumentType.constitutionalDocument];

  bool isCreditApplication() =>
      selectedDocumentType?.id ==
      ServerConstants.documentTypeId[DocumentType.creditApplication];

  bool isCreditLensSelected() =>
      selectedDocumentType?.id ==
      ServerConstants.documentTypeId[DocumentType.creditLensDocument];

  /// if selected document type is financial statements
  bool isFinancialStatementsSelected() =>
      selectedDocumentType?.id ==
      ServerConstants.documentTypeId[DocumentType.financialStatements];

  /// if selected document type is external opinions
  bool isExternalOpinionsSelected() =>
      selectedDocumentType?.id ==
      ServerConstants.documentTypeId[DocumentType.externalOpinions];

  /// if selected document type is other
  bool isOthersSelected() =>
      selectedDocumentType?.id ==
      ServerConstants.documentTypeId[DocumentType.other];

  ///download file attachment
  Future<void> downloadViewDocument(Document document) async {
    await fileAttachmentRepository.downloadFileAttachment(document);
  }

  /// action on document type change
  void onDocumentTypeChanged(Reference type) {
    selectedDocumentType = type;
    updateDocumentName("");
    updateEntityId("");
    // resetFormFields();
    selectedCompanyRims = [];
    selectedSubTypeFinancial = null;
    selectedSubTypeCreditLens = null;
    selectedSubSubTypeFinancial = null;
    selectedDate = null;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}
