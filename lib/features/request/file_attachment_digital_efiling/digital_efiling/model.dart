import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/state.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/view.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/file_attachment/file_upload.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/file_attachment_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

enum ControlFields {
  customerRim,
  customerName,
  groupID,
  groupName,
  applicationId
}

class DigitalEfilingViewModel extends SafeCubit<DigitalEfilingState> {
  DigitalEfilingViewModel()
      : super(
          DigitalEfilingState(
            loaderStatus: LoadingStatus.loading,
            searchLoaderStatus: LoadingStatus.loaded,
          ),
        );
  late RequestRepository requestRepository;
  late CustomerRepository customerRepository;
  late FileAttachmentRepository fileAttachmentRepository;

  ValueNotifier<Map<ControlFields, bool>> fieldCntrl = ValueNotifier({
    ControlFields.customerName: false,
    ControlFields.customerRim: false,
    ControlFields.groupID: false,
    ControlFields.groupName: false,
    ControlFields.applicationId: false,
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
  List<Reference> applicationTypeCustom = [];
  Reference? businessSegmentValue;

  bool isSearched = false;
  bool searchAllowed = false;
  bool isFileSearched = false;

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
  List<dynamic> selectedDocs = [];
  List<FileDetail> fileUploadDatas = [];
  bool showError = true;
  String? customerRimNo;
  String? customerName;
  String? groupName, groupId, grpId, grpName;
  ApplicationDetails? applicationDetails;

  List<Customer>? rimList = [];
  Customer? customer;
  bool isGroupNameSelection = false;
  String? applicationId;

  bool fieldLoading = false;
  bool isResetPressed = false;
  ValueNotifier<Customer?> selectedCustomer = ValueNotifier(null);
  List<Customer?> dailogCustomers = [];

  final Map<DigitaleFileFields, bool Function()> buttonVisibilityStatus = {
    DigitaleFileFields.uploadDocument: () => Utils.checkRoles([
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
    DigitaleFileFields.showApprovalDecision: () => Utils.checkRoles([
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

  /// check if all the text input fields are filled
  bool isFieldsFilled() =>
      customerRimNo != null &&
      customerName != null &&
      groupId != null &&
      groupName != null;

  bool iFinancialInstitutionSelected() =>
      businessSegmentValue?.id == ServerConstants.financialInstitutionId;

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

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> init(context) async {
    logger.i("initialising DigitalEfilingViewModel");
    requestRepository = RequestRepository.instance;
    fileAttachmentRepository = FileAttachmentRepository.instance;
    customerRepository = CustomerRepository.instance;
    await loadReferenceData();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> loadReferenceData() async {
    final Map<String, List<Reference>> referenceData =
        await ReferenceDataService().getReferenceData([
      ReferenceDataKeys.documentTypes,
      ReferenceDataKeys.fstSubTypes,
      ReferenceDataKeys.fstSubsubTypes,
      ReferenceDataKeys.languages,
      ReferenceDataKeys.clSubTypes,
      ReferenceDataKeys.branchList,
      ReferenceDataKeys.caSubTypes,
      ReferenceDataKeys.requestType,
      ReferenceDataKeys.caSubSubTypes,
      ReferenceDataKeys.applicationTypeCustom,
      ReferenceDataKeys.applicationType,
      ReferenceDataKeys.caSubSubSubTypes,
      ReferenceDataKeys.subSegmentValidation,
      ReferenceDataKeys.applicationSegment,
    ]);

    // Populate reference data lists
    documentTypes = referenceData[ReferenceDataKeys.documentTypes] ?? [];

    final existingIds = documentTypes.map((r) => r.id).toSet();
    // Add only those not already present
    documentTypes.addAll(
      ServerConstants.facilityValuationRefs.values
          .where((r) => !existingIds.contains(r.id)),
    );

    fstSubTypes = referenceData[ReferenceDataKeys.fstSubTypes] ?? [];
    fstSubSubTypes = referenceData[ReferenceDataKeys.fstSubsubTypes] ?? [];
    languages = referenceData[ReferenceDataKeys.languages] ?? [];
    clSubTypes = referenceData[ReferenceDataKeys.clSubTypes] ?? [];
    caSubTypes = [
      ...(referenceData[ReferenceDataKeys.caSubTypes] ?? []),
      ...(referenceData[ReferenceDataKeys.requestType] ?? []),
    ];
    caSubSubTypes = [
      ...(referenceData[ReferenceDataKeys.caSubSubTypes] ?? []),
      ...(referenceData[ReferenceDataKeys.applicationType] ?? []),
    ];

    applicationTypeCustom =
        referenceData[ReferenceDataKeys.applicationTypeCustom] ?? [];
    caSubSubSubTypes = referenceData[ReferenceDataKeys.caSubSubSubTypes] ?? [];

    subSegmentValidation =
        referenceData[ReferenceDataKeys.subSegmentValidation] ?? [];
    bussinessSegments =
        referenceData[ReferenceDataKeys.applicationSegment] ?? [];

    branchList = referenceData[ReferenceDataKeys.branchList] ?? [];
    setValueOfBusinessSegment();
  }

  void setValueOfBusinessSegment() {
    businessSegmentValue = bussinessSegments.firstWhere(
      (e) =>
          e.id == ServerConstants.businessSegmentId[BusinessSegment.corporate],
    );
  }

  void resetDependentFields() {
    formKey.currentState?.reset();
    isSearched = false;
    searchAllowed = false;
    customer = null;
    stopAllLoaders();
    customerRimNo = null;
    customerName = null;
    groupId = null;
    selectedDocumentIds = [];
    selectedDocs = [];
    groupName = null;
    selectedCustomer.value = null;
    fieldCntrl = ValueNotifier({
      ControlFields.customerName: false,
      ControlFields.customerRim: false,
      ControlFields.groupID: false,
      ControlFields.groupName: false,
      ControlFields.applicationId: false,
    });
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

      await onCustomerSearchPressed(showDialog: showDialog, searchBy: 1);
    } else {
      AlertManager().showFailureToast(
        "requestInformation.createRequest.enterGroupName".tr(),
      );
    }
  }

  /// Initiates search based on group ID if not already searched.
  Future<void> onGroupIdSearchPressed() async {
    if ((groupId ?? "").isNotEmpty && !isSearched) {
      groupIdLoadingStatus = LoadingStatus.loading;
      isSearched = true;
      await onCustomerSearchPressed(searchBy: 2);
    } else {
      AlertManager().showFailureToast(
        "requestInformation.createRequest.enterGroupId".tr(),
      );
    }
  }

  /// Initiates search based on customer RIM number if not already searched
  Future<void> onCustomerRimNoSearchPressed() async {
    if ((customerRimNo ?? "").isNotEmpty && !isSearched) {
      customerRimNoLoadingStatus = LoadingStatus.loading;
      isSearched = true;

      await onCustomerSearchPressed(searchBy: 3);
    } else {
      AlertManager().showFailureToast(
        "requestInformation.createRequest.enterCustomerRim".tr(),
      );
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

      await onCustomerSearchPressed(showDialog: showDialog, searchBy: 4);
    } else {
      AlertManager().showFailureToast(
        "requestInformation.createRequest.enterCustomerName".tr(),
      );
    }
  }

  /// on select button pressed on selection dailog

  Future<void> onSelectionPressed(context, {bool closeDialog = false}) async {
    logger.i("requestCreate${selectedCustomer.value}");
    if (selectedCustomer.value == null) {
      AlertManager().showFailureToast("common.selectValue".tr());
      searchAllowed = false;
    } else {
      customer = selectedCustomer.value;

      //  Validate immediately on selection
      // if (!validationCheck(customer)) return;
      if (shouldValidateSegmentSubSegment()) {
        await validateSubSegment();
      }

      if (closeDialog && context.mounted) {
        Navigator.pop(context);
      }

      groupId = customer?.groups?.id ?? "";
      groupName = customer?.groups?.name ?? "";
      if (groupId != "" && groupName != "") {
        customerRimNo = "";
        customerName = "";
      } else {
        customerRimNo = customer?.id ?? "";
        customerName = customer?.preferredName ?? "";
      }

      searchAllowed = true;

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

  bool checkValidRegion(Customer? customer) {
    debugPrint("========== REGION CHECK ==========");

    final String? branchCode = customer?.branchCode?.trim();
    debugPrint("Customer Branch Code : $branchCode");

    if (branchCode == null || branchCode.isEmpty) {
      debugPrint(" Branch code is NULL or EMPTY");
      debugPrint("==================================");
      return false;
    }

    debugPrint("Available Branch List:");
    for (final branch in branchList) {
      debugPrint(
        " - Branch ref1 (code): ${branch.reference1}, "
        "ref2 (region): ${branch.reference2}",
      );
    }

    final Reference matchedBranch = branchList.firstWhere(
      (branch) => branch.reference1?.trim() == branchCode,
      orElse: () {
        debugPrint(" No matching branch found for branchCode=$branchCode");
        return Reference();
      },
    );

    final String? regionCode = matchedBranch.reference2?.trim();
    debugPrint("Mapped Region Code   : $regionCode");

    if (regionCode == null || regionCode.isEmpty) {
      debugPrint(" Region code is NULL or EMPTY after branch mapping");
      debugPrint("==================================");
      return false;
    }

    final List<String> userRegions =
        (Globals.user?.regions ?? []).map((r) => r.trim()).toList();

    debugPrint("User Regions         : $userRegions");

    final bool isValid = userRegions.contains(regionCode);

    debugPrint(" Region Valid      : $isValid");
    debugPrint("==================================");

    return isValid;
  }

  void checkValidBusinessSegment(Customer? customer) {
    final String? apiSegment = customer?.segment?.trim();

    final bool isFISelected = businessSegmentValue?.id ==
        ServerConstants.businessSegmentId[BusinessSegment.financialInstitution];

    if (isFISelected &&
        apiSegment != ServerConstants.financialSegmentPartyInq) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      throw "common.segmentFiMismatch".tr();
    } else if (!isFISelected &&
        apiSegment == ServerConstants.financialSegmentPartyInq) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      throw "common.segmentCorporateMismatch".tr();
    }
  }

  bool checkValidSegment(Customer? customer) {
    return Globals.user?.segments?.contains(customer?.segment) ?? false;
  }

  /// To Validate and check if the user needs to do subsegment Validation or not
  Future<void> validateSubSegment() async {
    try {
      // Get current role ID
      final String currentRoleId = Globals.user!.currentRole!.roleId.toString();

      // Check if any reference in subSegmentValidation meets BOTH criteria
      for (final Reference reference in subSegmentValidation) {
        //  Use && to check both reference1 and role match
        if (reference.reference1 == ServerConstants.subSegmentValidationRefId &&
            (reference.reference2?.split(",") ?? []).contains(currentRoleId)) {
          // If both conditions are true, perform validation
          final String? relationshipMgrIdent =
              customer?.relationshipMgr?.isNotEmpty == true
                  ? customer!.relationshipMgr!.first["RelationshipMgrIdent"]
                      ?.trim()
                  : null;
          await customerRepository.validateSubSegment(relationshipMgrIdent);
          return; // Validation was required and executed
        }
      }

      return; // Validation not required
    } catch (e) {
      customerRimNo = null;
      customerName = null;
      groupId = null;
      groupName = null;
      // groupOwner = 0;
      isSearched = false;
      fieldCntrl = ValueNotifier({
        ControlFields.customerName: false,
        ControlFields.customerRim: false,
        ControlFields.groupID: false,
        ControlFields.groupName: false,
      });
      rethrow;
    }
  }

  bool validationCheck(Customer? customerLocal) {
    try {
      if (shouldValidateSegmentSubSegment() &&
          (!checkValidRegion(customerLocal) ||
              !checkValidSegment(customerLocal))) {
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        throw "common.segmentMismatch".tr();
      }

      // Also check FI/Corporate mismatch
      checkValidBusinessSegment(customerLocal);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      // customer = null;
      stopAllLoaders();
      return false;
    }

    return true;
  }

  Future<void> onCustomerSearchPressed({
    bool showDialog = true,
    int searchBy = 0,
  }) async {
    try {
      dailogCustomers = [];

      if (customerRimNoLoadingStatus == LoadingStatus.loading) {
        customer = await customerRepository.searchUserDetails(
          customerRimNo,
          null,
          null,
          null,
        );

        if (!validationCheck(customer)) return;

        //  Optional: sub-segment validation only if needed
        if (shouldValidateSegmentSubSegment()) {
          await validateSubSegment();
        }
      } else {
        // For name/group searches:
        final List<Customer?> resultCustomers = await customerRepository
            .searchCustomerProfile(customerName, groupId, groupName);
        rimList = resultCustomers.cast<Customer>();

        if (resultCustomers.length == 1) {
          customer = resultCustomers.first;

          if (!validationCheck(customer)) return;

          // Optional: sub-segment validation
          if (shouldValidateSegmentSubSegment()) {
            await validateSubSegment();
          }

          dailogCustomers = resultCustomers;
          emit(state.copyWith(showSelectDialog: showDialog));
          stopAllLoaders();
        } else if (resultCustomers.isNotEmpty) {
          if (groupIdLoadingStatus == LoadingStatus.loading) {
            customer = resultCustomers
                .where(
                  (user) =>
                      int.tryParse(user?.id ?? " ") == user?.groups?.groupOwner,
                )
                .toList()
                .first;

            if (!validationCheck(customer)) {
              stopAllLoaders();
              return;
            }

            if (shouldValidateSegmentSubSegment()) {
              await validateSubSegment();
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
        searchAllowed = true;
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        AlertManager().showFailureToast("common.noUserFound".tr());
        return;
      } else {
        if (searchBy == 1 || searchBy == 2) {
          groupId = customer?.groups?.id ?? "";
          groupName = customer?.groups?.name ?? "";
        } else if (searchBy == 3 || searchBy == 4) {
          customerRimNo = customer?.id ?? "";
          customerName = customer?.preferredName ?? "";
          grpId = customer?.groups?.id;
          grpName = customer?.groups?.name;
        }

        isSearched = false;
        searchAllowed = true;
        stopAllLoaders();
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }
    } catch (e) {
      stopAllLoaders();
      isSearched = false;
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Resets all form fields and state.
  void onResetButtonPress() {
    formKey.currentState?.reset();
    isSearched = false;
    isFileSearched = false;
    searchAllowed = false;
    customer = null;
    stopAllLoaders();
    selectedDocs = [];
    selectedDocumentIds = [];
    customerRimNo = null;
    customerName = null;
    groupId = null;
    grpId = null;
    groupName = null;
    grpName = null;
    selectedCustomer.value = null;
    applicationIdController.clear();
    updateApplicationId("");
    fileUploadDatas = [];
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

  Future<void> updateSearchValue(String? searchValue) async {}

  Future<void> updateApplicationId(String? appId) async {
    applicationId = appId;
    if (applicationId != "") await getApplicationDetails(applicationId);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> getApplicationDetails(String? applicationId) async {
    try {
      if (applicationId == null) {
        return;
      }

      applicationDetails = await CustomerRepository.instance
          .getApplicationDetails(appRefNo: applicationId);
      if (applicationDetails?.createdDate != null) {
        final bool isGroupApp = applicationDetails?.groupID != null &&
            applicationDetails?.groupID != 0;
        if (isGroupApp) {
          groupId = applicationDetails?.groupID?.toString();
          rimList = applicationDetails?.borrowers ?? [];
          searchAllowed = true;
          // await onGroupIdSearchPressed();
        } else {
          customerRimNo = applicationDetails?.rimNo?.toString();
          // await onCustomerRimNoSearchPressed();
          searchAllowed = true;
        }
      } else {
        isSearched = false;
        searchAllowed = false;
      }
    } catch (e) {
      AlertManager().showFailureToast("common.noAppRef".tr());
      searchAllowed = false;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  bool shouldValidateSegmentSubSegment() {
    return Utils.checkRoles([
      UserRole.relationshipOfficer,
      UserRole.relationshipManager,
      UserRole.teamLeaderBusiness,
      UserRole.commercialAreaManager,
      UserRole.segmentHeadBusiness,
    ]);
  }

// This method validates search inputs, triggers a loading state, fetches file
// attachment data based on provided search criteria
// and handles empty or invalid results by showing error messages while properly
// updating the UI loading states.
  Future<void> doSearch() async {
    emit(state.copyWith(searchLoaderStatus: LoadingStatus.loading));

    try {
      selectedDocumentIds = [];
      selectedDocs = [];
      if ((customerRimNo?.isEmpty ?? true) &&
          (customerName?.isEmpty ?? true) &&
          (groupId?.isEmpty ?? true) &&
          (groupName?.isEmpty ?? true) &&
          (applicationId?.isEmpty ?? true)) {
        emit(
          state.copyWith(
            loaderStatus: LoadingStatus.loaded,
            searchLoaderStatus: LoadingStatus.loaded,
          ),
        );
        throw "eDigitalFilingFileAttachments.digitalEfiling.searchValidation"
            .tr();
      }
      isSearched = true;
      isFileSearched = true;

      // int rimNo, String customerName, int groupId, String groupName, String
      // appRefNo
      fileUploadDatas = await fileAttachmentRepository.getFileUploadData(
        documentTypes,
        [...fstSubTypes, ...clSubTypes, ...cdSubTypes, ...caSubTypes],
        [...fstSubSubTypes, ...caSubSubTypes, ...applicationTypeCustom],
        caSubSubSubTypes,
        languages,
        ((groupId == null || groupId == "") &&
                (applicationId == null || applicationId == ""))
            ? customerRimNo
            : null,
        customerName,
        (applicationId == null || applicationId == "") ? groupId : null,
        groupName,
        applicationId,
        true,
      );

      if (fileUploadDatas.isEmpty) {
        emit(
          state.copyWith(
            loaderStatus: LoadingStatus.loaded,
            searchLoaderStatus: LoadingStatus.loaded,
          ),
        );
        isSearched = false;
        throw "common.emptyState".tr();
      }
    } catch (e) {
      // throw e.toString();
      AlertManager().showFailureToast(e.toString());
      isSearched = false;
    }
    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        searchLoaderStatus: LoadingStatus.loaded,
      ),
    );
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
        customerRimController.text,
        groupRimController.text,
        applicationIdController.text,
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
        customerRimNo,
        groupId,
        applicationId,
      );
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    // document.downloadLoader = LoadingStatus.loaded;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  //open upload dialog based on search fields data where user can add files
  Future<void> openUploadDialog(BuildContext context) async {
    await DialogHelper.showCustomDialog(
      barrierDismissible: false,
      onClosePressed: () => Navigator.pop(context),
      context: context,
      width: 900.w,
      title: "eDigitalFilingFileAttachments.digitalEfiling.title".tr(),
      content: UploadDocumentDialogView(
        groupRim: groupId ?? "0",
        customerRim: customerRimNo ?? "0",
        applicationId: applicationIdController.text,
        rimList: rimList ?? [],
        grpId: grpId,
      ),
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

  void debugValidation(String step, Customer? customer) {
    debugPrint("========== VALIDATION DEBUG ==========");
    debugPrint("STEP: $step");

    debugPrint("User Regions      : ${Globals.user?.regions}");
    debugPrint("User Segments     : ${Globals.user?.segments}");
    debugPrint("User Role         : ${Globals.user?.currentRole?.roleId}");

    debugPrint("Customer ID       : ${customer?.id}");
    debugPrint("Customer Segment  : ${customer?.segment}");
    debugPrint("Customer Branch   : ${customer?.branchCode}");

    final branch = branchList.firstWhere(
      (b) => b.reference1?.trim() == customer?.branchCode?.trim(),
      orElse: Reference.new,
    );

    debugPrint("Mapped Region     : ${branch.reference2}");
    debugPrint("Region Valid      : ${checkValidRegion(customer)}");
    debugPrint("Segment Valid     : ${checkValidSegment(customer)}");
    debugPrint("FI Selected       : ${iFinancialInstitutionSelected()}");
    debugPrint("Should Validate   : ${shouldValidateSegmentSubSegment()}");
    debugPrint("======================================");
  }
}
