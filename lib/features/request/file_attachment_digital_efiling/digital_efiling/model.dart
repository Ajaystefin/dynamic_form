import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
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
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart";
import "package:wcas_frontend/models/request/file_attachment/file_upload.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/file_attachment_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// Enumeration for control fields
enum ControlFields {
  /// Customer Rim
  customerRim,

  /// Customer Name
  customerName,

  /// Group Id
  groupID,

  /// Group Name
  groupName,

  /// Application Id
  applicationId
}

/// DigitalEfilingViewModel
class DigitalEfilingViewModel extends SafeCubit<DigitalEfilingState>
    implements AttachmentViewModel {
  /// Creates [DigitalEfilingViewModel] instance
  DigitalEfilingViewModel()
      : super(
          DigitalEfilingState(
            loaderStatus: LoadingStatus.loading,
            searchLoaderStatus: LoadingStatus.loaded,
          ),
        );

  /// RequestRepository reference variable
  late RequestRepository requestRepository;

  /// CustomerRepository reference variable
  late CustomerRepository customerRepository;

  /// FileAttachmentRepository reference variable
  late FileAttachmentRepository fileAttachmentRepository;

  /// Default values for field controllers
  ValueNotifier<Map<ControlFields, bool>> fieldCntrl = ValueNotifier({
    ControlFields.customerName: false,
    ControlFields.customerRim: false,
    ControlFields.groupID: false,
    ControlFields.groupName: false,
    ControlFields.applicationId: false,
  });

  /// Reference data lists for document types.
  List<Reference> documentTypes = [];

  /// Reference data lists for caSubTypes.
  List<Reference> caSubTypes = [];

  /// Reference data lists for caSubSubTypes.
  List<Reference> caSubSubTypes = [];

  /// Reference data lists for languages.
  List<Reference> languages = [];

  /// Reference data lists for subTypes.
  List<Reference> subTypes = [];

  /// Reference data lists for subsubTypes.
  List<Reference> subsubTypes = [];

  /// Reference data lists for clSubTypes.
  List<Reference> clSubTypes = [];

  /// Reference data lists for caSubSubSubTypes.
  List<Reference> caSubSubSubTypes = [];

  /// Reference data lists for cdSubTypes.
  List<Reference> cdSubTypes = [];

  /// Reference data lists for fstSubTypes.
  List<Reference> fstSubTypes = [];

  /// Reference data lists for fstSubSubTypes.
  List<Reference> fstSubSubTypes = [];

  /// Reference data lists for request types.
  List<Reference> requestTypes = [];

  /// Reference data lists for customer types.
  List<Reference> customerTypes = [];

  /// Reference data lists for application types.
  List<Reference> applicationTypes = [];

  /// Reference data lists for bussiness segments.
  List<Reference> bussinessSegments = [];

  /// Reference data lists for branch .
  List<Reference> branchList = [];

  /// Reference data lists for sub segment validation.
  List<Reference> subSegmentValidation = [];

  /// Reference data lists for application type custom.
  List<Reference> applicationTypeCustom = [];

  /// Reference data business segment value.
  Reference? businessSegmentValue;

  /// List of Customer
  List<Customer?> uniqueGroups = [];

  /// searched flag
  bool isSearched = false;

  /// search allowed flag
  bool searchAllowed = false;

  /// file searched flag
  bool isFileSearched = false;

  /// GlobalKey key for form
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// TextEditing Controller for group name
  final TextEditingController groupNameController = TextEditingController();

  /// TextEditing Controller for customer name
  final TextEditingController customerNameController = TextEditingController();

  /// TextEditing Controller for group rim
  final TextEditingController groupRimController = TextEditingController();

  /// TextEditing Controller for customer rim
  final TextEditingController customerRimController = TextEditingController();

  /// TextEditing Controller for application id
  final TextEditingController applicationIdController = TextEditingController();

  /// Loading statuses for different fields.
  /// Loading statuses for group name.
  LoadingStatus groupNameLoadingStatus = LoadingStatus.loaded;

  /// Loading statuses for group.
  LoadingStatus groupIdLoadingStatus = LoadingStatus.loaded;

  /// Loading statuses for customer rim no.
  LoadingStatus customerRimNoLoadingStatus = LoadingStatus.loaded;

  /// Loading statuses for customer name.
  LoadingStatus customerNameLoadingStatus = LoadingStatus.loaded;

  /// Loading statuses for submit loading.
  LoadingStatus submitLoadingStatus = LoadingStatus.loaded;

  /// Selected Document data
  final Map<String, bool> selectedDocuments = {};

  /// List of selected docuement ids
  List<String> selectedDocumentIds = [];

  /// List of DocSubTypeData
  List<DocSubTypeData?> selectedDocs = [];
  @override

  /// List of FileDetail
  List<FileDetail> fileUploadDatas = [];

  /// whether to show error or not
  bool showError = true;

  /// customer rim no
  String? customerRimNo;

  /// customer name
  String? customerName;

  /// group name
  String? groupName;

  /// group id
  String? groupId;

  /// group id
  String? grpId;

  /// group name
  String? grpName;

  /// Application Details
  ApplicationDetails? applicationDetails;

  /// searched by
  int searchedBy = 0;

  /// List of Customer as rim
  List<Customer>? rimList = [];

  /// Customer reference variable
  Customer? customer;

  /// is group name selection flag
  bool isGroupNameSelection = false;

  /// application id
  String? applicationId;

  /// field loading flag
  bool fieldLoading = false;

  /// is reset pressed flag
  bool isResetPressed = false;

  /// selected customer
  ValueNotifier<Customer?> selectedCustomer = ValueNotifier(null);

  /// List of Dialog Customer
  List<Customer?> dailogCustomers = [];

  /// Data for button visibility status
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

  /// financial institution selected
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
    logger
      ..i("groupIdLoadingStatus. $groupIdLoadingStatus")
      ..i("customerRimNoLoadingStatus. $customerRimNoLoadingStatus");

    emit(
      state.copyWith(
        loaderStatus: LoadingStatus.loaded,
        showSelectDialog: false,
      ),
    );
  }

  /// init method
  Future<void> init(BuildContext context) async {
    logger.i("initialising DigitalEfilingViewModel");
    requestRepository = RequestRepository.instance;
    fileAttachmentRepository = FileAttachmentRepository.instance;
    customerRepository = CustomerRepository.instance;
    await loadReferenceData();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// gets reference data
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

  /// set value of business segement
  void setValueOfBusinessSegment() {
    businessSegmentValue = bussinessSegments.firstWhere(
      (e) =>
          e.id == ServerConstants.businessSegmentId[BusinessSegment.corporate],
    );
  }

  /// reset dependent fields
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
    searchedBy = 0;
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

  /// mark checked by edms id
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

  /// handling the enable and desable other fields than focused field
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
      // isSearched = true;
      groupId = null;

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
      // isSearched = true;
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
      // isSearched = true;

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
      // isSearched = true;

      isGroupNameSelection = false;

      await onCustomerSearchPressed(showDialog: showDialog, searchBy: 4);
    } else {
      AlertManager().showFailureToast(
        "requestInformation.createRequest.enterCustomerName".tr(),
      );
    }
  }

  /// on select button pressed on selection dailog
  Future<void> onSelectionPressed(
    BuildContext context, {
    bool closeDialog = false,
  }) async {
    try {
      if (selectedCustomer.value == null) {
        AlertManager().showFailureToast("common.selectValue".tr());
        return;
      }

      customer = selectedCustomer.value;

      final String? selectedGroupId = customer?.groups?.id;
      final int? groupOwner = customer?.groups?.groupOwner;

      final List<Customer?> sameGroupList = dailogCustomers.where((user) {
        return user?.groups?.id == selectedGroupId;
      }).toList();

      Customer? finalCustomer;

      for (final user in sameGroupList) {
        final int? userId = int.tryParse(user?.id ?? "");

        if (userId != null && userId == groupOwner) {
          finalCustomer = user;
          break;
        }
      }

      finalCustomer ??= customer;

      customer = finalCustomer;

      if (shouldValidateSegmentSubSegment()) {
        await validateSubSegment();
      }

      if (closeDialog && context.mounted) {
        Navigator.pop(context);
      }

      customer = finalCustomer;

      groupId = customer?.groups?.id ?? "";
      groupName = customer?.groups?.name ?? "";
      grpId = groupId;
      grpName = groupName;

      customerRimNo = customer?.id.toString();

       customerName = customer?.concatCustomerFullName ??
                customer?.displayRIMName ??
                "";

      groupNameController.text = groupName ?? "";
      groupRimController.text = groupId ?? "";

      if (searchedBy == 1 || searchedBy == 2) {
        customerName = "";
        customerRimNo = "";
      } else {
        customerName = customerName ?? "";
        customerRimNo = customerRimNo ?? "";
      }

      searchAllowed = true;

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
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

  /// check valid region
  bool checkValidRegion(Customer? customer) {
    logger.i("========== REGION CHECK ==========");

    final String? branchCode = customer?.branchCode?.trim();
    logger.i("Customer Branch Code : $branchCode");

    if (branchCode == null || branchCode.isEmpty) {
      logger
        ..i(" Branch code is NULL or EMPTY")
        ..i("==================================");
      return false;
    }

    logger.i("Available Branch List:");
    for (final branch in branchList) {
      logger.i(
        " - Branch ref1 (code): ${branch.reference1}, "
        "ref2 (region): ${branch.reference2}",
      );
    }

    final Reference matchedBranch = branchList.firstWhere(
      (branch) => branch.reference1?.trim() == branchCode,
      orElse: () {
        logger.i(" No matching branch found for branchCode=$branchCode");
        return Reference();
      },
    );

    final String? regionCode = matchedBranch.reference2?.trim();
    logger.i("Mapped Region Code   : $regionCode");

    if (regionCode == null || regionCode.isEmpty) {
      logger
        ..i(" Region code is NULL or EMPTY after branch mapping")
        ..i("==================================");
      return false;
    }

    final List<String> userRegions =
        (Globals.user?.regions ?? []).map((r) => r.trim()).toList();

    logger.i("User Regions         : $userRegions");

    final bool isValid = userRegions.contains(regionCode);

    logger
      ..i(" Region Valid      : $isValid")
      ..i("==================================");

    return isValid;
  }

  /// method to check valid business segment
  void checkValidBusinessSegment(Customer? customer) {
    final String? apiSegment = customer?.segment?.trim();

    final bool isFISelected = businessSegmentValue?.id ==
        ServerConstants.businessSegmentId[BusinessSegment.financialInstitution];

    if (isFISelected &&
        apiSegment != ServerConstants.financialSegmentPartyInq) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      throw ApiException("common.segmentFiMismatch".tr());
    } else if (!isFISelected &&
        apiSegment == ServerConstants.financialSegmentPartyInq) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      throw ApiException("common.segmentCorporateMismatch".tr());
    }
  }

  /// method to check valid segment
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
          // If both are true,try all rln managers until one pass
          // ignore: prefer_final_locals
          List<String> relationshipMgrIdents = customer?.relationshipMgr
                  ?.map(
                    // Map parameter with type annotation
                    // ignore: avoid_final_parameters
                    (final Map<String, dynamic> relationshipMgr) =>
                        relationshipMgr["RelationshipMgrUserId"]
                            ?.toString()
                            .trim(),
                  )
                  // Final for sonar
                  // ignore: avoid_final_parameters
                  .where((final String? id) => id != null && id.isNotEmpty)
                  .cast<String>()
                  .toList() ??
              <String>[];

          Object? lastError;

          // Local variable sonarqube
          // ignore: prefer_final_in_for_each
          for (String relationshipMgrIdent in relationshipMgrIdents) {
            try {
              await customerRepository.validateSubSegment(relationshipMgrIdent);
              return; // Validation succeeded for one relationship manager
            } on Object catch (e) {
              lastError = e;
            }
          }

          // Local final Ignored for sonarqube
          // ignore: prefer_final_locals
          Object fallbackError =
              lastError ?? Exception("common.segmentMismatch".tr());
          if (fallbackError is Exception) {
            throw fallbackError;
          }
          if (fallbackError is Error) {
            throw fallbackError;
          }
          throw Exception(fallbackError.toString());
        }
      }

      return; // Validation not required
    } on Object {
      // customerRimNo = null;
      // customerName = null;
      // groupId = null;
      // groupName = null;
      // groupOwner = 0;
      isSearched = false;

      searchAllowed = false;

      fieldCntrl = ValueNotifier({
        ControlFields.customerName: false,
        ControlFields.customerRim: false,
        ControlFields.groupID: false,
        ControlFields.groupName: false,
      });
      rethrow;
    }
  }

  /// method to check validtions
  bool validationCheck(Customer? customerLocal) {
    try {
      if (shouldValidateSegmentSubSegment() &&
          (!checkValidRegion(customerLocal) ||
              !checkValidSegment(customerLocal))) {
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        throw ApiException("common.segmentMismatch".tr());
      }

      // Also check FI/Corporate mismatch
      checkValidBusinessSegment(customerLocal);
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      // customer = null;
      stopAllLoaders();
      return false;
    }

    return true;
  }

  /// on customer search button press action
  Future<void> onCustomerSearchPressed({
    bool showDialog = true,
    int searchBy = 0,
  }) async {
    try {
      searchedBy = searchBy;
      dailogCustomers = [];

      if (customerRimNoLoadingStatus == LoadingStatus.loading) {
        customer = await customerRepository.searchUserDetails(
          customerRimNo,
          null,
          null,
          null,
        );

        if (!validationCheck(customer)) {
          return;
        }

        //  Optional: sub-segment validation only if needed
        if (shouldValidateSegmentSubSegment()) {
          await validateSubSegment();
        }
      } else {
        // For name/group searches:
        final List<Customer?> resultCustomers =
            await customerRepository.searchCustomerProfile(
          searchBy == 1 ? null : customerName,
          groupId,
          groupName,
        );
        rimList = resultCustomers.cast<Customer>();

        if (resultCustomers.length == 1) {
          customer = resultCustomers.first;

          if (!validationCheck(customer)) {
            return;
          }

          // Optional: sub-segment validation
          if (searchBy != 4 && shouldValidateSegmentSubSegment()) {
            await validateSubSegment();
          }

          dailogCustomers = resultCustomers;
          emit(state.copyWith(showSelectDialog: showDialog));
          stopAllLoaders();
        } else if (resultCustomers.isNotEmpty) {
          if (groupIdLoadingStatus == LoadingStatus.loading) {
            customer = resultCustomers.firstWhere(
              (user) =>
                  int.tryParse(user?.id ?? "") == user?.groups?.groupOwner,
              orElse: () => resultCustomers.first,
            );

            if (!validationCheck(customer)) {
              stopAllLoaders();
              return;
            }

            if (searchBy != 4 && shouldValidateSegmentSubSegment()) {
              await validateSubSegment();
            }
          } else {
            dailogCustomers = resultCustomers;

            if (searchBy == 1) {
              final Map<String, Customer?> groupMap = {};

              for (final user in resultCustomers) {
                final gid = user?.groups?.id;

                if (gid != null && !groupMap.containsKey(gid)) {
                  groupMap[gid] = user;
                }
              }
              uniqueGroups = groupMap.values.toList();
            }

            if (searchBy == 4) {
              uniqueGroups = resultCustomers;
            }
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
        // isSearched = false;
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
           customerName = customer?.concatCustomerFullName ??
                customer?.displayRIMName ??
                "";
          grpId = customer?.groups?.id;
          grpName = customer?.groups?.name;
        }

        // isSearched = false;
        searchAllowed = true;
        stopAllLoaders();
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }
    } on Object catch (e) {
      stopAllLoaders();
      isSearched = false;
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// on reset button press action
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
    searchedBy = 0;
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

  /// update application id
  Future<void> updateApplicationId(String? appId) async {
    applicationId = appId;
    if (applicationId != "") {
      await getApplicationDetails(applicationId);
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// fetch application details
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
    } on Object {
      AlertManager().showFailureToast("common.noAppRef".tr());
      searchAllowed = false;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// list of user roles to validate segemtn sub-segment
  bool shouldValidateSegmentSubSegment() {
    return Utils.checkRoles([
      UserRole.relationshipOfficer,
      UserRole.relationshipManager,
      UserRole.teamLeaderBusiness,
      UserRole.commercialAreaManager,
      UserRole.segmentHeadBusiness,
    ]);
  }

  /// This method validates search inputs, triggers a loading state, fetches file
  /// attachment data based on provided search criteria
  /// and handles empty or invalid results by showing error messages while properly
  /// updating the UI loading states.
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
        final errorMessage =
            "eDigitalFilingFileAttachments.digitalEfiling.searchValidation"
                .tr();

        throw ApiException(errorMessage);
      }
      isSearched = true;
      isFileSearched = true;

      // int rimNo, String customerName, int groupId, String groupName, String
      // appRefNo
      fileUploadDatas = await fileAttachmentRepository.getFileUploadData(
        [...documentTypes, ...ServerConstants.legacyUncategorizedRefs.values],
        [...fstSubTypes, ...clSubTypes, ...cdSubTypes, ...caSubTypes],
        [...fstSubSubTypes, ...caSubSubTypes, ...applicationTypeCustom],
        caSubSubSubTypes,
        languages,
        ((searchedBy == 3 || searchedBy == 4) &&
                (applicationId == null || applicationId == ""))
            ? customerRimNo
            : null,
        customerName,
        ((searchedBy == 1 || searchedBy == 2) &&
                (applicationId == null || applicationId == ""))
            ? groupId
            : null,
        groupName,
        applicationId,
        isLegacy: true,
      );

      if (fileUploadDatas.isEmpty) {
        emit(
          state.copyWith(
            loaderStatus: LoadingStatus.loaded,
            searchLoaderStatus: LoadingStatus.loaded,
          ),
        );
        // isSearched = false;
        // throw Exception("common.emptyState".tr());
        AlertManager().showFailureToast("common.emptyState".tr());
      }
    } on Object catch (e) {
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

  @override
  Future<void> downloadDocument(
    String documentId,
    String webUrl,
    String documentName,
  ) async {
    try {
      // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      await fileAttachmentRepository.downloadDigitalAttachment(
        documentId,
        webUrl,
        documentName,
      );
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    // document.downloadLoader = LoadingStatus.loaded;
    // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// download documents in zip
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
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    // document.downloadLoader = LoadingStatus.loaded;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// merge download document
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
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    // document.downloadLoader = LoadingStatus.loaded;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// open upload dialog based on search fields data where user can add files
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
        searchedBy: searchedBy,
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

  /// debug validation method for test
  void debugValidation(String step, Customer? customer) {
    logger
      ..i("========== VALIDATION DEBUG ==========")
      ..i("STEP: $step")
      ..i("User Regions      : ${Globals.user?.regions}")
      ..i("User Segments     : ${Globals.user?.segments}")
      ..i("User Role         : ${Globals.user?.currentRole?.roleId}")
      ..i("Customer ID       : ${customer?.id}")
      ..i("Customer Segment  : ${customer?.segment}")
      ..i("Customer Branch   : ${customer?.branchCode}");

    final branch = branchList.firstWhere(
      (b) => b.reference1?.trim() == customer?.branchCode?.trim(),
      orElse: Reference.new,
    );

    logger
      ..i("Mapped Region     : ${branch.reference2}")
      ..i("Region Valid      : ${checkValidRegion(customer)}")
      ..i("Segment Valid     : ${checkValidSegment(customer)}")
      ..i("FI Selected       : ${iFinancialInstitutionSelected()}")
      ..i("Should Validate   : ${shouldValidateSegmentSubSegment()}")
      ..i("======================================");
  }
}
