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

class UploadDocumentDialogViewModel
    extends SafeCubit<UploadDocumentDialogState> {
  UploadDocumentDialogViewModel()
      : super(
          UploadDocumentDialogState(
            loaderStatus: LoadingStatus.loading,
            uploadButtonStatus: LoadingStatus.loaded,
          ),
        );
  late RequestRepository repository;
  late FileAttachmentRepository fileAttachmentRepository;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Request request = Globals.request!;
  TextEditingController documentNameCtrl = TextEditingController();
  TextEditingController entityIdCtrl = TextEditingController();
  TextEditingController appRefNoCtrl = TextEditingController();

  List<Customer> rimList = [];
  Reference? selectedLanguageType;
  List<Customer> selectedCompanyRims = [];
  bool isSelectAllCompanyRims = false;
  String? documentName, entityId;
  String? applicationId;
  DateTime? selectedDate;
  int? selectedGroupRim;
  int? selectedCustomerRim;
  List<PlatformFile> selectedFiles = [];
  List<Document> selectedDocuments = [];
  String? errorMessage;
  bool isCompanyRim = false;
  ApplicationDetails? applicationDetails;
  bool isGroupApp = false;

  // Reference data lists
  List<Reference> fileType = [];
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

  Future<void> init(
    BuildContext context, {
    required String groupRim,
    required String customerRim,
    required String applicationId,
    List<Customer>? companyRims,
    String? grpId,
  }) async {
    rimList = companyRims ?? [];
    repository = RequestRepository.instance;
    fileAttachmentRepository = FileAttachmentRepository.instance;
    if (applicationId.isNotEmpty) updateApplicationId(applicationId);
    if (applicationId != "" && rimList.isEmpty) {
      await getApplicationDetails(applicationId, true);
    } else if (groupRim != "" && groupRim != "0") {
      updateGroupRim(groupRim);
      isGroupApp = true;
      if (rimList.isEmpty) await getCompanyRims();
    } else if (groupRim == "0") {
      updateCustomerRim(customerRim);
      if (grpId != "" && grpId != "0") {
        updateGroupRim(grpId ?? "0");
      }
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

  Future<void> updateSearchValue(String? searchValue) async {}

  Future<void> getCompanyRims() async {
    try {
      if ((!Utils.isGroupApplication() || selectedGroupRim == null) &&
          applicationId == null) {
        return;
      }
      rimList =
          await fileAttachmentRepository.getCompanyRims(selectedGroupRim!);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> getApplicationDetails(
    String? applicationId,
    bool shouldOverrideRIM,
  ) async {
    try {
      if (applicationId == null) {
        return;
      }

      applicationDetails = await CustomerRepository.instance
          .getApplicationDetails(appRefNo: applicationId);
      if (shouldOverrideRIM) {
        isGroupApp = applicationDetails?.groupID != null &&
            applicationDetails?.groupID != 0;
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
    } catch (e) {
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
  void toggleSelectAllCompanyRims(bool value) {
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

  void updateDocumentType(Reference type) {
    selectedDocumentType = type;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateLanguageType(Reference type) {
    selectedLanguageType = type;
    if (type.id != ServerConstants.languageEnglish &&
        type.id != ServerConstants.languageArabic) {
      entityId = "";
      entityIdCtrl.text = "";
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void updateGroupRim(String groupRim) {
    if (groupRim != "0" && groupRim.isNotEmpty) {
      selectedGroupRim = int.tryParse(groupRim);
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

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

  void updateSubTypeCreditLens(Reference type) {
    selectedSubTypeCreditLens = type;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Call this to update the sub type financial.
  void updateSubTypeFinancial(Reference type) {
    selectedSubTypeFinancial = type;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

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

  // Call this method when the Upload button is clicked from the form.
  Future<void> onUploadDocumentsPressed(BuildContext context) async {
    emit(state.copyWith(uploadButtonStatus: LoadingStatus.loading));
    try {
      final String status = await fileAttachmentRepository
          .uploadDigitalDocuments(selectedDocuments);
      status;
      AlertManager().showSuccessToast(status);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(uploadButtonStatus: LoadingStatus.loaded));
    if (context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

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

//pickup multiple files in one time on browse click button
  Future<void> pickMultipleFiles() async {
    if (!(formKey.currentState!.validate())) {
      return;
    }

    try {
      if (appRefNoCtrl.text != "" && applicationDetails == null) {
        await getApplicationDetails(appRefNoCtrl.text, false);
        if (applicationDetails?.createdDate == null) {
          return;
        }
      }
    } catch (e) {
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
