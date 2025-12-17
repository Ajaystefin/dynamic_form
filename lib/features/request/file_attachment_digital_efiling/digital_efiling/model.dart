import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/view.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/file_attachment/file_upload.dart';
import 'package:wcas_frontend/repositories/customer_respository.dart';
import 'package:wcas_frontend/repositories/file_attachment_repository.dart';

import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

enum ControlFields {
  customerRim,
  customerName,
  groupID,
  groupName,
  applicationId
}

class DigitalEfilingViewModel extends Cubit<DigitalEfilingState> {
  DigitalEfilingViewModel()
      : super(DigitalEfilingState(
            loaderStatus: LoadingStatus.loading,
            searchLoaderStatus: LoadingStatus.loaded));
  late RequestRepository requestRepository;
  late CustomerRepository customerRepository;
  late FileAttachmentRepository fileAttachmentRepository;

  ValueNotifier<Map<ControlFields, bool>> fieldCntrl = ValueNotifier({
    ControlFields.customerName: false,
    ControlFields.customerRim: false,
    ControlFields.groupID: false,
    ControlFields.groupName: false,
    ControlFields.applicationId: false
  });

  /// Reference data lists.
  List<Reference> documentTypes = [];
  List<Reference> caSubTypes = [];
  List<Reference> caSubSubTypes = [];
  List<Reference> languages = [];
  List<Reference> subTypes = [];
  List<Reference> subsubTypes = [];
  List<Reference> clSubTypes = [];
  List<Reference> caSubSubSubTypes = [];
  List<Reference> cdSubTypes = [];
  List<Reference> fstSubTypes = [];
  List<Reference> fstSubSubTypes = [];
  List<Reference> requestTypes = [];
  List<Reference> customerTypes = [];
  List<Reference> applicationTypes = [];
  List<Reference> bussinessSegments = [];
  List<Reference> branchList = [];
  List<Reference> subSegmentValidation = [];

  bool isSearched = false;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController groupRimController = TextEditingController();
  final TextEditingController customerRimController = TextEditingController();
  final TextEditingController applicationIdController = TextEditingController();

  /// Loading statuses for different fields.

  LoadingStatus groupNameLoadingStatus = LoadingStatus.loaded;
  LoadingStatus groupIdLoadingStatus = LoadingStatus.loaded;
  LoadingStatus customerRimNoLoadingStatus = LoadingStatus.loaded;
  LoadingStatus customerNameLoadingStatus = LoadingStatus.loaded;
  LoadingStatus submitLoadingStatus = LoadingStatus.loaded;

  final Map<String, bool> selectedDocuments = {};
  List<String> selectedDocumentIds = [];
  List<FileDetail> fileUploadDatas = [];
  bool showError = true;
  String? customerRimNo;
  String? customerName;
  String? groupId;
  String? groupName;

  List<String>? rimList = [];
  Customer? customer;
  bool isGroupNameSelection = false;

  bool fieldLoading = false;
  bool isResetPressed = false;
  ValueNotifier<Customer?> selectedCustomer = ValueNotifier(null);
  List<Customer?> dailogCustomers = [];

  final Map<DigitaleFileFields, bool Function()> buttonVisibilityStatus = {
    DigitaleFileFields.uploadDocument: () => Utils.checkRoles([
          UserRole.relationshipOfficer,
          UserRole.relationshipManager,
          UserRole.businessUnitHead
        ])
  };

  /// check if all the text input fields are filled
  bool isFieldsFilled() =>
      customerRimNo != null &&
      customerName != null &&
      groupId != null &&
      groupName != null;

  /// Resets all individual field loading statuses to 'loaded'
  void stopAllLoaders() {
    fieldCntrl.value.forEach(
      (key, value) {
        value = true;
      },
    );
    isResetPressed = !isResetPressed;
    // isSearched = false;
    submitLoadingStatus = LoadingStatus.loaded;
    customerRimNoLoadingStatus = LoadingStatus.loaded;
    customerNameLoadingStatus = LoadingStatus.loaded;
    groupIdLoadingStatus = LoadingStatus.loaded;
    groupNameLoadingStatus = LoadingStatus.loaded;
    logger.i("groupIdLoadingStatus. $groupIdLoadingStatus");
    logger.i("customerRimNoLoadingStatus. $customerRimNoLoadingStatus");
  }

  String? applicationId;

  void init(context) async {
    logger.i('initialising DigitalEfilingViewModel');
    requestRepository = RequestRepository.instance;
    fileAttachmentRepository = FileAttachmentRepository.instance;
    customerRepository = CustomerRepository.instance;
    await loadReferenceData();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

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
    fstSubTypes = referenceData[ReferenceDataKeys.fstSubTypes] ?? [];
    fstSubSubTypes = referenceData[ReferenceDataKeys.fstSubsubTypes] ?? [];
    languages = referenceData[ReferenceDataKeys.languages] ?? [];
    clSubTypes = referenceData[ReferenceDataKeys.clSubTypes] ?? [];
    caSubTypes = referenceData[ReferenceDataKeys.caSubTypes] ?? [];
    caSubSubTypes = referenceData[ReferenceDataKeys.caSubSubTypes] ?? [];
    caSubSubSubTypes = referenceData[ReferenceDataKeys.caSubSubSubTypes] ?? [];
  }

  void resetDependentFields() {
    formKey.currentState?.reset();
    isSearched = false;
    customer = null;
    stopAllLoaders();
    customerRimNo = null;
    customerName = null;
    groupId = null;
    groupName = null;
    selectedCustomer.value = null;
    fieldCntrl = ValueNotifier({
      ControlFields.customerName: false,
      ControlFields.customerRim: false,
      ControlFields.groupID: false,
      ControlFields.groupName: false,
      ControlFields.applicationId: false
    });
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void toggleDocumentSelection(String key, bool isSelected, dynamic docData) {
    String edmsDriveItemId = docData.edmsDriveItemId ?? "";
    // selectedDocuments[key] = isSelected;
    docData.isChecked = isSelected;
    if (edmsDriveItemId != "") {
      if (isSelected) {
        selectedDocumentIds.add(edmsDriveItemId);
      } else {
        selectedDocumentIds.remove(edmsDriveItemId);
      }
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // handling the enable and desable other fields than focused field
  void handleFieldControl(ControlFields cntrl, String data) {
    final updatedMap = <ControlFields, bool>{};
    fieldCntrl.value.forEach((key, _) {
      if (data.isNotEmpty) {
        updatedMap[key] = key != cntrl;
      } else {
        updatedMap[key] = false;
      }
    });
    if (data.isEmpty) {
      customerName = null;
      customerRimNo = null;
      groupId = null;
      groupName = null;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
    fieldCntrl.value = updatedMap;
  }

  /// Initiates search based on group name if not already searched.
  Future<void> onGroupNameSearchPressed({bool showDialog = true}) async {
    if ((groupName ?? "").isNotEmpty && !isSearched && groupName!.length > 3) {
      groupNameLoadingStatus = LoadingStatus.loading;
      isGroupNameSelection = true;
      isSearched = true;

      await onCustomerSearchPressed(showDialog: showDialog);
    } else {
      AlertManager().showFailureToast(
          "requestInformation.createRequest.enterGroupName".tr());
    }
  }

  /// Initiates search based on group ID if not already searched.
  Future<void> onGroupIdSearchPressed() async {
    if ((groupId ?? "").isNotEmpty && !isSearched) {
      groupIdLoadingStatus = LoadingStatus.loading;
      isSearched = true;
      await onCustomerSearchPressed();
    } else {
      AlertManager().showFailureToast(
          "requestInformation.createRequest.enterGroupId".tr());
    }
  }

  /// Initiates search based on customer RIM number if not already searched
  Future<void> onCustomerRimNoSearchPressed() async {
    if ((customerRimNo ?? "").isNotEmpty && !isSearched) {
      customerRimNoLoadingStatus = LoadingStatus.loading;
      isSearched = true;

      await onCustomerSearchPressed();
    } else {
      AlertManager().showFailureToast(
          "requestInformation.createRequest.enterCustomerRim".tr());
    }
  }

  /// Initiates search based on customer name if not already searched.
  Future<void> onCustomerNameSearchPressed({bool showDialog = true}) async {
    if ((customerName ?? "").isNotEmpty &&
        !isSearched &&
        customerName!.length > 3) {
      customerNameLoadingStatus = LoadingStatus.loading;
      isSearched = true;

      isGroupNameSelection = false;

      await onCustomerSearchPressed(showDialog: showDialog);
    } else {
      AlertManager().showFailureToast(
          "requestInformation.createRequest.enterCustomerName".tr());
    }
  }

  /// on select button pressed on selection dailog
  void onSelectionPressed(context, {bool closeDialog = false}) {
    logger.i("requestCreate${selectedCustomer.value}");
    if (selectedCustomer.value == null) {
      AlertManager().showFailureToast("common.selectValue".tr());
    } else {
      customer = selectedCustomer.value;
      if (!validationCheck(customer)) {
        return;
      }
      if (closeDialog && context.mounted) {
        Navigator.pop(context);
      }
      customerRimNo = customer?.id ?? "";
      customerName = customer?.preferredName ?? "";
      groupId = customer?.groups?.id ?? "";
      groupName = customer?.groups?.name ?? "";
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// on cancel button on selection dialogue pressed
  void onSelectionCancelButtonPress() {
    customer = null;
    final updatedMap = <ControlFields, bool>{};
    fieldCntrl.value.forEach((key, _) {
      updatedMap[key] = false;
    });
    fieldCntrl.value = updatedMap;
    customerName = null;
    customerRimNo = null;
    groupId = null;
    groupName = null;
    isResetPressed = !isResetPressed;
    customerRimNoLoadingStatus = LoadingStatus.loaded;
    customerNameLoadingStatus = LoadingStatus.loaded;
    groupIdLoadingStatus = LoadingStatus.loaded;
    groupNameLoadingStatus = LoadingStatus.loaded;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  bool checkValidSegment(Customer? customer) {
    return Globals.user?.segments?.contains(customer?.segment) ?? false;
  }

  bool validationCheck(Customer? customerLocal) {
    try {
      if (shouldValidateSegmentSubSegment() &&
          (!checkValidRegion(customer) || !checkValidSegment(customer))) {
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        throw "common.segmentMismatch".tr();
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      customer = null;
      stopAllLoaders();
      return false;
    }

    return true;
  }

  bool shouldValidateSegmentSubSegment() {
    return Utils.checkRoles([
      UserRole.relationshipOfficer,
      UserRole.relationshipManager,
      UserRole.teamLeaderBusiness,
      UserRole.commercialAreaManager,
      // UserRole.regionalManager,
      UserRole.segmentHeadBusiness
    ]);
  }

  bool checkValidRegion(Customer? customer) {
    branchList.map(
      (branch) {
        if (branch.reference1 == customer?.branchCode) {
          return Globals.user?.regions?.contains(branch.reference2);
        }
      },
    ).toList();

    return true;
  }

  /// To Validate and check if the user needs to do subsegment Validation or not
  Future<void> validateSubSegment() async {
    try {
      // Get current role ID
      String currentRoleId = Globals.user!.currentRole!.roleId.toString();

      // Check if any reference in subSegmentValidation meets BOTH criteria
      for (Reference reference in subSegmentValidation) {
        //  Use && to check both reference1 and role match
        if (reference.reference1 == ServerConstants.subSegmentValidationRefId &&
            (reference.reference2?.split(',') ?? []).contains(currentRoleId)) {
          // If both conditions are true, perform validation
          String? relationshipMgrIdent =
              customer?.relationshipMgr?.isNotEmpty == true
                  ? customer!.relationshipMgr!.first['RelationshipMgrIdent']
                      ?.trim()
                  : null;
          await customerRepository.validateSubSegment(relationshipMgrIdent);
          return; // Validation was required and executed
        }
      }

      return; // Validation not required
    } catch (e) {
      rethrow;
    }
  }

  /// Searches for customer details based on input fields.
  Future<void> onCustomerSearchPressed({bool showDialog = true}) async {
    try {
      // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      dailogCustomers = [];
      if (customerRimNoLoadingStatus == LoadingStatus.loading) {
        customer = await customerRepository.searchUserDetails(
            customerRimNo, null, null, null);
        if (!validationCheck(customer)) {
          return;
        }
      } else {
        List<Customer?> resultCustomers = await customerRepository
            .searchCustomerProfile(customerName, groupId, groupName);
        if (resultCustomers.length == 1) {
          customer = resultCustomers.first;
          if (!validationCheck(customer)) {
            return;
          }
          //added for visa checking with dialog not loading in single item.
          dailogCustomers = resultCustomers;
          emit(state.copyWith(showSelectDialog: showDialog));
          stopAllLoaders();
        } else if (resultCustomers.isNotEmpty) {
          if (groupIdLoadingStatus == LoadingStatus.loading) {
            customer = resultCustomers
                .where((user) =>
                    int.tryParse(user?.id ?? " ") == user?.groups?.groupOwner)
                .toList()
                .first;
            if (!validationCheck(customer)) {
              stopAllLoaders();
              return;
            }
          } else {
            dailogCustomers = resultCustomers;
            emit(state.copyWith(showSelectDialog: showDialog));
            stopAllLoaders();
            return;
          }
        }
      }

      if (customer == null) {
        customerRimNoLoadingStatus = LoadingStatus.loaded;
        customerNameLoadingStatus = LoadingStatus.loaded;
        groupIdLoadingStatus = LoadingStatus.loaded;
        groupNameLoadingStatus = LoadingStatus.loaded;
        isSearched = false;
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        AlertManager().showFailureToast("common.noUserFound".tr());
        return;
      } else {
        customerRimNo = customer?.id ?? "";
        customerName = customer?.preferredName ?? "";
        groupId = customer?.groups?.id ?? "";
        groupName = customer?.groups?.name ?? "";
        isSearched = true;
        stopAllLoaders();
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }
    } catch (e) {
      stopAllLoaders();
      isSearched = false;
      AlertManager().showFailureToast("common.noUserFound".tr());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Resets all form fields and state.
  void onResetButtonPress() {
    formKey.currentState?.reset();
    isSearched = false;
    customer = null;
    stopAllLoaders();
    customerRimNo = null;
    customerName = null;
    groupId = null;
    groupName = null;
    selectedCustomer.value = null;
    fieldCntrl = ValueNotifier({
      ControlFields.customerName: false,
      ControlFields.customerRim: false,
      ControlFields.groupID: false,
      ControlFields.groupName: false,
    });
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  bool isDocumentSelected(String key) {
    return selectedDocuments[key] ?? false;
  }

  void updateSearchValue(String? searchValue) async {}

  void updateApplicationId(String? appId) {
    applicationId = appId;
    applicationIdController.text = appId ?? '';
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void doSearch() async {
    emit(state.copyWith(searchLoaderStatus: LoadingStatus.loading));
    try {
      if ((customerRimNo?.isEmpty ?? true) &&
          (customerName?.isEmpty ?? true) &&
          (groupId?.isEmpty ?? true) &&
          (groupName?.isEmpty ?? true) &&
          (applicationId?.isEmpty ?? true)) {
        emit(state.copyWith(
            loaderStatus: LoadingStatus.loaded,
            searchLoaderStatus: LoadingStatus.loaded));
        throw "eDigitalFilingFileAttachments.digitalEfiling.searchValidation"
            .tr();
      }
      isSearched = true;
      // int rimNo, String customerName, int groupId, String groupName, String appRefNo
      fileUploadDatas = await fileAttachmentRepository.getFileUploadData(
          documentTypes,
          [...fstSubTypes, ...clSubTypes, ...cdSubTypes, ...caSubTypes],
          [...fstSubSubTypes, ...caSubSubTypes],
          caSubSubSubTypes,
          languages,
          customerRimNo,
          customerName,
          groupId,
          groupName,
          applicationId);

      if (fileUploadDatas.isEmpty) {
        emit(state.copyWith(
            loaderStatus: LoadingStatus.loaded,
            searchLoaderStatus: LoadingStatus.loaded));

        throw "common.emptyState".tr();
      } else {
        // All names (flattened across all FileDetail.documents), with null-safety and trimming.

        final List<String> names = fileUploadDatas
            .map((f) => (f.name ?? '').trim()) // null-safe and trimmed
            .where((n) => n.isNotEmpty) // remove empty strings
            .toList();

        // If you want only unique names:
        rimList = names.toSet().toList();
      }
    } catch (e) {
      // throw e.toString();
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        searchLoaderStatus: LoadingStatus.loaded));
  }

  Future<void> downloadDocument(documentId, documentName) async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      await fileAttachmentRepository.downloadDigitalAttachment(
          documentId, documentName);
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
          customerRimController.text,
          groupRimController.text,
          applicationIdController.text);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    // document.downloadLoader = LoadingStatus.loaded;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> mergeDownloadDocument() async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      await fileAttachmentRepository
          .mergeDownloadDigitalAttachment(selectedDocumentIds);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    // document.downloadLoader = LoadingStatus.loaded;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  //open upload dialog based on search fields data where user can add files
  Future<void> openUploadDialog(BuildContext context) async {
    await DialogHelper.showCustomDialog(
      barrierDismissible: true,
      onClosePressed: () => Navigator.pop(context),
      context: context,
      width: 900.w,
      title: "eDigitalFilingFileAttachments.digitalEfiling.title".tr(),
      content: UploadDocumentDialogView(
          groupRim: groupId ?? "0",
          customerRim: customerRimNo ?? "0",
          applicationId: applicationId ?? "0",
          rimList: rimList),
    ).then((_) {
      // Clear controllers
      // groupRimController.clear();
      // groupNameController.clear();
      // customerRimController.clear();
      // customerNameController.clear();
      // applicationIdController.clear();
      // applicationId = null;
      // isSearched = false;

      // // Emit new state with cleared values
      // emit(state.copyWith(
      //   loaderStatus: LoadingStatus.loaded,
      //   groupName: null,
      //   groupRim: null,
      //   customerName: null,
      //   customerRim: null,
      // ));
      doSearch();
    });
  }
}
