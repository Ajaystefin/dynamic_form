import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/create_request/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";

/// Identifies the supported control fields used in the
/// customer and group selection workflow.
enum ControlFields {
  /// Customer RIM number field.
  customerRim,

  /// Customer name field.
  customerName,

  /// Group ID field.
  groupID,

  /// Group name field.
  groupName,
}

/// View model responsible for managing the Create Request screen.
///
/// Handles customer and group lookups, request data population,
/// field validation, reference data loading, and navigation
/// throughout the request creation workflow.
class CreateRequestViewModel extends SafeCubit<CreateRequestState> {
  /// Creates a [CreateRequestViewModel] with an initial loading state.
  CreateRequestViewModel()
      : super(
          CreateRequestState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

  /// Repository used to retrieve customer-related information
  /// and support customer search operations.
  CustomerRepository repository = CustomerRepository();

  /// Initializes the ViewModel by loading reference data and setting up the
  /// request object.

  ValueNotifier<Map<ControlFields, bool>> fieldCntrl = ValueNotifier({
    ControlFields.customerName: false,
    ControlFields.customerRim: false,
    ControlFields.groupID: false,
    ControlFields.groupName: false,
  });

  /// Selected business segment for the request.
  Reference? businessSegmentValue;

  /// Selected request type for the request being created.
  Reference? selectedRequestType;

  /// Selected application type associated with the request.
  Reference? selectedApplicationType;

  /// Indicates whether validation errors should be displayed.
  bool showError = true;

  /// Customer RIM number entered or selected by the user.
  String? customerRimNo;

  /// Customer name entered or selected by the user.
  String? customerName;

  /// Group identifier entered or selected by the user.
  String? groupId;

  /// Group name entered or selected by the user.
  String? groupName;

  /// RIM number of the group owner.
  int? groupOwner;

  /// Selected group identifier returned from a group lookup.
  String? grpId;

  /// Selected group name returned from a group lookup.
  String? grpName;

  /// Request object used to capture and maintain request details.
  Request requestCreate = Request();

  /// Unique groups available for selection.
  List<Customer?> uniqueGroups = [];

  /// Selected customer type for the request.
  Reference? selectedCustomerType;

  /// Indicates whether a customer or group search has been performed.
  bool isSearched = false;

  /// Tracks the currently selected dialog action button state.
  ValueNotifier<bool?> selectedButtonModelVN = ValueNotifier(null);

  /// Tracks the customer currently selected in the dialog.
  ValueNotifier<Customer?> selectedCustomer = ValueNotifier(null);

  /// Customers displayed in the selection dialog.
  List<Customer?> dailogCustomers = [];

  /// Complete customer list used as the source for filtering operations.
  ///
  /// Store all customers for filtering
  List<Customer?> allCustomers = [];

  /// Key for validating the form.

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Loading status for the Group Name field operations.
  LoadingStatus groupNameLoadingStatus = LoadingStatus.loaded;

  /// Loading status for the Group ID field operations.
  LoadingStatus groupIdLoadingStatus = LoadingStatus.loaded;

  /// Loading status for Customer RIM Number lookup operations.
  LoadingStatus customerRimNoLoadingStatus = LoadingStatus.loaded;

  /// Loading status for Customer Name lookup operations.
  LoadingStatus customerNameLoadingStatus = LoadingStatus.loaded;

  /// Loading status for request submission operations.
  LoadingStatus submitLoadingStatus = LoadingStatus.loaded;

  /// Reference data lists.
  ///
  /// Available request types that can be selected.
  List<Reference> requestTypes = [];

  /// Available customer types that can be selected.
  List<Reference> customerTypes = [];

  /// Available application types that can be selected.
  List<Reference> applicationTypes = [];

  /// Available business segments that can be selected.
  List<Reference> bussinessSegments = [];

  /// Available branch values returned from reference data.
  List<Reference> branchList = [];

  /// Validation rules or values associated with sub-segments.
  List<Reference> subSegmentValidation = [];

  /// Customer returned from a lookup or selected by the user.
  Customer? customer;

  /// Indicates whether the current selection originated from
  /// a Group Name search or selection.
  bool isGroupNameSelection = false;

  /// Indicates whether field-level processing is currently in progress.
  bool fieldLoading = false;

  /// Indicates whether the Reset action has been triggered.
  bool isResetPressed = false;

  /// Initializes the Create Request screen.
  ///
  /// Clears any existing global request data, initializes a new
  /// request instance, loads the required reference data, and
  /// updates the screen to the loaded state.
  Future<void> init() async {
    logger.i("initialising CreateViewModel");
    Globals.cleanGlobalCache();

    requestCreate = Request();
    await loadReferenceData();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Determines if the customer type field should be shown based on business
  /// segment.
  bool iFinancialInstitutionSelected() =>
      businessSegmentValue?.id == ServerConstants.financialInstitutionId;

  /// Handles form submission.
  Future<void> onSubmitButtonPress({
    required bool isValidated,
  }) async {
    // keep original emit as you had it
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    try {
      // Preserve your existing validation
      if (!isValidated || customer == null) {
        throw ApiException(
          "requestInformation.createRequest.requiredField".tr(),
        );
      }

      // Start submit loading as you already do
      submitLoadingStatus = LoadingStatus.loading;

      requestCreate
        ..customerRimNo = int.parse(customerRimNo ?? "")
        ..customerName = valueTruncateToMax(customerName ?? "", 122)
        ..groupId = int.tryParse(groupId ?? "")
        ..groupName = valueTruncateToMax(groupName, 50)
        ..groupOwner = groupOwner
        ..businessSegment = businessSegmentValue
        ..customerType = selectedCustomerType
        ..requestType = selectedRequestType
        ..requestSubType = selectedApplicationType
        ..applicationType = selectedApplicationType
        ..customerType = selectedCustomerType;

      Globals.request?.applicationSubType = selectedApplicationType?.name;

      // Persist to Globals exactly as before
      Globals.request = requestCreate;
      Globals.request?.isCreateRequest = true;
      Globals.request?.applicationSubType = selectedApplicationType?.name;

      // Applicationsubtype Manual Entry
      Globals.request?.applicationSubType = selectedApplicationType?.name;
      // --- Consolidated segment/sub-segment validation (kept as-is) ---
      final bool shouldValidate = shouldValidateSegmentSubSegment();
      Globals.request?.applicationSubType = selectedApplicationType?.name;
      final bool isFICustomerTypeCurrencyCheck =
          validateCustomerTypeAgainstClassCode(customer);
      if (isFICustomerTypeCurrencyCheck) {
        if (shouldValidate) {
          await validateSubSegment();
        }
        // --- Borrowers flow preserved exactly ---
        if (groupId != null && groupId!.isNotEmpty) {
          // for getting the non borrower list
          final List<Customer?> resultCustomers =
              await repository.searchCustomerProfile(null, groupId, null);
          await repository.getBorrowerCustomers(resultCustomers, customer!);
        } else {
          customer?.isPrimary = true;
          Globals.request?.borrowers = [customer!];
          Globals.request?.fiCustomerListCountry = [customer];
        }

        // --- Role update and navigation preserved ---
        await AuthRepository.instance
            .updateRole(Globals.user!.currentRole!, request: requestCreate);

        // finish
        submitLoadingStatus = LoadingStatus.loaded;
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

        router.go(Routes.groupBorrowers, extra: requestCreate);
      } else {
        // finish
        submitLoadingStatus = LoadingStatus.loaded;
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      }
    } on Object catch (e) {
      // preserve your error handling + state
      AlertManager().showFailureToast(e.toString());
      submitLoadingStatus = LoadingStatus.loaded;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Resets all fields that depend on customer or group selection.
  ///
  /// Clears form values, selected reference data, customer details,
  /// group information, and selection states. Any active loading
  /// indicators are stopped and the view is refreshed with the
  /// updated state.
  void resetDependentFields() {
    formKey.currentState?.reset();
    isSearched = false;
    customer = null;
    stopAllLoaders();
    // setValueOfBusinessSegment();
    selectedRequestType = null;
    selectedApplicationType = null;
    selectedCustomerType = null;
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

  /// Resets all form fields and state.
  void onResetButtonPress() {
    formKey.currentState?.reset();
    isSearched = false;
    customer = null;
    stopAllLoaders();
    setValueOfBusinessSegment();
    selectedRequestType = null;
    selectedApplicationType = null;
    selectedCustomerType = null;
    customerRimNo = null;
    customerName = null;
    groupId = null;
    groupName = null;
    groupOwner = 0;
    selectedCustomer.value = null;
    fieldCntrl = ValueNotifier({
      ControlFields.customerName: false,
      ControlFields.customerRim: false,
      ControlFields.groupID: false,
      ControlFields.groupName: false,
    });
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Returns application type items based on selected request type.
  List<Reference> applicationTypeItems() {
    logger.i("requestCreate.applicationTypeItems()");
    final bool hasRiskRole =
        Utils.checkRoles([UserRole.creditAnalyst, UserRole.creditCordinator]);

    // Risk Roles Logic
    if (hasRiskRole) {
      final List<String> roleCodes = [
        ServerConstants.userRoleCode[UserRole.creditCordinator],
        ServerConstants.userRoleCode[UserRole.creditAnalyst],
      ].whereType<String>().toList();

      return applicationTypes
          .where(
            (element) =>
                // Match request type
                element.reference3 == selectedRequestType?.reference1 &&
                // Match user role
                isApplicableForRoles(element, roleCodes),
          )
          .toList();
    }

    // Business Segment Logic
    final bool isFI = businessSegmentValue?.id ==
        ServerConstants.businessSegmentId[BusinessSegment.financialInstitution];

    final String segmentCode = isFI
        ? ServerConstants.financialCode // "F"
        : ServerConstants.corperateCode; // "C"

    return applicationTypes
        .where(
          (element) =>
              element.reference3 == selectedRequestType?.reference1 &&
              isApplicableForSegment(element, segmentCode),
        )
        .toList();
  }

  /// Determines whether the specified reference is applicable
  /// for the given business segment.
  ///
  /// The segment mappings are retrieved from the reference's
  /// `reference2` value and compared against the provided
  /// [segmentCode].
  ///
  /// Returns `true` when the segment is applicable; otherwise `false`.
  bool isApplicableForSegment(
    Reference element,
    String segmentCode, // "C" or "F"
  ) {
    final String ref = element.reference2 ?? "";
    return ref.split(",").map((e) => e.trim()).contains(segmentCode);
  }

  /// Determines whether the specified reference is applicable
  /// for any of the provided user roles.
  ///
  /// The allowed roles are retrieved from the reference's
  /// `reference4` value and compared against the supplied
  /// [roleCodes].
  ///
  /// Returns `true` when at least one role matches; otherwise `false`.
  bool isApplicableForRoles(
    Reference element,
    List<String> roleCodes, // ["CCOOD", "CA"]
  ) {
    final String ref = element.reference4 ?? "";
    final Set<String> allowedRoles =
        ref.split(",").map((e) => e.trim()).toSet();
    return roleCodes.any(allowedRoles.contains);
  }

  /// Updates selected business segment.
  Future<void> onBussinessSegmentSelected(Reference value) async {
    fieldLoading = true;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    requestCreate.businessSegment = value;
    logger.i("requestCreate. $value");
    businessSegmentValue = value;
    // selectedApplicationType = null; //uncomment when business segment validation is required
    await Future.delayed(const Duration(milliseconds: 300));
    fieldLoading = false;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    // resetDependentFields();  //uncomment when business segment validation is required
  }

  /// Loads reference data required for the form.
  Future<void> loadReferenceData() async {
    try {
      final Map<String, List<Reference>> referenceData =
          await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.requestType,
        ReferenceDataKeys.customerType,
        ReferenceDataKeys.applicationType,
        ReferenceDataKeys.applicationTypeCustom,
        ReferenceDataKeys.applicationSegment,
        ReferenceDataKeys.branchList,
        ReferenceDataKeys.subSegmentValidation,
      ]);
      requestTypes = referenceData[ReferenceDataKeys.requestType] ?? [];
      customerTypes = referenceData[ReferenceDataKeys.customerType] ?? [];
      // applicationTypes = referenceData[ReferenceDataKeys.applicationType] ??
      // [];
      applicationTypes =
          referenceData[ReferenceDataKeys.applicationTypeCustom] ?? [];
      branchList = referenceData[ReferenceDataKeys.branchList] ?? [];
      subSegmentValidation =
          referenceData[ReferenceDataKeys.subSegmentValidation] ?? [];
      bussinessSegments =
          referenceData[ReferenceDataKeys.applicationSegment] ?? [];
      setValueOfBusinessSegment();
    } on Object {
      AlertManager().showFailureToast("common.error".tr());
    }
  }

  /// Sets the default business segment selection.
  ///
  /// Assigns the Corporate business segment as the default value
  /// when a matching reference is available in the business segment
  /// reference data list.
  void setValueOfBusinessSegment() {
    bussinessSegments.map(
      (element) {
        if (element.id ==
            ServerConstants.businessSegmentId[BusinessSegment.corporate]) {
          businessSegmentValue = element;
        }
      },
    ).toList();
  }

  /// Validates whether the specified customer belongs to a region
  /// that is accessible to the current user.
  ///
  /// The customer's branch code is matched against the configured
  /// branch reference data to determine the corresponding region.
  /// The resolved region is stored in the request customer information
  /// and checked against the user's assigned regions.
  ///
  /// Returns `true` if the customer's region is accessible to the
  /// current user; otherwise returns `false`.
  bool checkValidRegion(Customer? customer) {
    // branchList.map(
    //   (branch) {
    //     if (branch.reference1 == customer?.branchCode) {
    //       // branch.reference2 - region
    //       Globals.requestCustomerInfo?.region = branch.reference2;
    //       return Globals.user?.regions?.contains(branch.reference2);
    //     }
    //   },
    // ).toList();
    for (final Reference branch in branchList) {
      if (branch.reference1 == customer?.branchCode) {
        // branch.reference2 - region
        Globals.requestCustomerInfo?.region = branch.reference2;
        return Globals.user?.regions?.contains(branch.reference2) ?? false;
      }
    }
    return true;
  }

  /// To Validate and check if the user needs to do subsegment Validation or not
  Future<void> validateSubSegment() async {
    try {
      final String currentRoleId = Globals.user!.currentRole!.roleId.toString();

      for (final Reference reference in subSegmentValidation) {
        if (reference.reference1 == ServerConstants.subSegmentValidationRefId &&
            (reference.reference2?.split(",") ?? []).contains(currentRoleId)) {
          //  Prepare RM list safely
          final List<String> relationshipMgrIdents = customer?.relationshipMgr
                  ?.map(
                    (e) => e["RelationshipMgrUserId"]?.toString().trim(),
                  )
                  .where((id) => id != null && id.isNotEmpty)
                  .cast<String>()
                  .toList() ??
              [];

          //  Null / empty check
          if (relationshipMgrIdents.isEmpty) {
            throw ApiException("No Relationship Manager found");
          }

          Object? lastError;

          //  Try one by one (first → second → ...)

          for (int i = 0; i < relationshipMgrIdents.length; i++) {
            final String rmId = relationshipMgrIdents[i];

            try {
              await repository.validateSubSegment(rmId);
              return;
            } on Object catch (e) {
              lastError = e;
            }
          }
          if (lastError is Exception) {
            throw lastError;
          }
          if (lastError is Error) {
            throw lastError;
          }
          throw ApiException(
            lastError?.toString() ?? "common.segmentMismatch".tr(),
          );
        }
      }

      //  If no matching reference found → no validation needed
      return;
    } on Object {
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

  /// Validates that the selected customer belongs to the
  /// business segment currently chosen for the request.
  ///
  /// Throws an [ApiException] when the customer segment does not
  /// match the selected business segment.
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

  /// Validates whether the customer's segment is assigned
  /// to the current user.
  ///
  /// Returns `true` when the customer segment exists within
  /// the user's permitted segments; otherwise returns `false`.
  bool checkValidSegment(Customer? customer) {
    return Globals.user?.segments?.contains(customer?.segment) ?? false;
  }

  /// Performs customer validation checks before allowing
  /// the request creation process to continue.
  ///
  /// Validates region and segment access based on the current
  /// user's permissions and updates the global customer context.
  ///
  /// Returns `true` when all validations are successful;
  /// otherwise returns `false` and displays an error message.
  bool validationCheck(Customer? customerLocal) {
    try {
      // save the customer info to set application details on request info
      // screen
      Globals.requestCustomerInfo = customer;

      const bool isNBFISegment = false;
      // customerLocal?.segment == ServerConstants.financialSegmentPartyInq;

      //remove segment validation for NBFI
      if (!isNBFISegment && shouldValidateSegmentSubSegment()) {
        final bool isRegionValid = checkValidRegion(customerLocal);
        final bool isSegmentValid = checkValidSegment(customerLocal);

        if (!isRegionValid || !isSegmentValid) {
          emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
          throw ApiException("common.segmentMismatch".tr());
          // throw Exception('common.segmentMismatch'.tr());
        }
      }

      // checkValidBusinessSegment(customer);
      isSearched = false;
      return true;
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      customer = null;
      isSearched = false;
      stopAllLoaders();
      return false;
    }
  }

  /// Searches for customer details based on input fields.

  Future<void> onCustomerSearchPressed({bool showDialog = true}) async {
    try {
      if (selectedRequestType == null ||
          selectedApplicationType == null ||
          (iFinancialInstitutionSelected() && selectedCustomerType == null) ||
          businessSegmentValue == null) {
        AlertManager().showFailureToast(
          "requestInformation.createRequest.requiredField".tr(),
        );
        customerRimNoLoadingStatus = LoadingStatus.loaded;
        customerNameLoadingStatus = LoadingStatus.loaded;
        groupIdLoadingStatus = LoadingStatus.loaded;
        groupNameLoadingStatus = LoadingStatus.loaded;
        isSearched = false;
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }
      // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      dailogCustomers = [];
      if (customerRimNoLoadingStatus == LoadingStatus.loading) {
        customer =
            await repository.searchUserDetails(customerRimNo, null, null, null);
        checkCustomerTypeCountry(customer);
        if (!validationCheck(customer)) {
          return;
        }
      } else {
        final List<Customer?> resultCustomers =
            await repository.searchCustomerProfile(
          customerName,
          groupId,
          groupName,
        );

        allCustomers = resultCustomers.cast<Customer>();

        if (resultCustomers.isEmpty) {
          AlertManager().showFailureToast("common.noUserFound".tr());
          return;
        }
        if (resultCustomers.length == 1) {
          customer = resultCustomers.first;

          dailogCustomers = resultCustomers;
          allCustomers = resultCustomers;

          emit(state.copyWith(showSelectDialog: showDialog));

          stopAllLoaders();
          return;
        } else if (resultCustomers.isNotEmpty) {
          dailogCustomers = resultCustomers;
          if (groupIdLoadingStatus == LoadingStatus.loading) {
            Customer? finalCustomer;

            for (final user in resultCustomers) {
              final int? userId = int.tryParse(user?.id ?? "");
              final int? groupOwner = user?.groups?.groupOwner;

              if (userId != null && userId == groupOwner) {
                finalCustomer = user;
                break;
              }
            }

            finalCustomer ??= resultCustomers.first;

            customer = finalCustomer;

            checkCustomerTypeCountry(customer);

            if (!validationCheck(customer)) {
              stopAllLoaders();
              return;
            }

            customerRimNo = customer?.id ?? "";
            customerName = customer?.concatCustomerFullName ??
                customer?.displayRIMName ??
                "";
            groupId = customer?.groups?.id ?? "";
            groupName = customer?.groups?.name ?? "";
            groupOwner = customer?.groups?.groupOwner ?? 0;

            isSearched = true;

            stopAllLoaders();
            emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
            return;
          }
          if (groupNameLoadingStatus == LoadingStatus.loading) {
            final Map<String, Customer?> groupMap = {};

            for (final user in resultCustomers) {
              final gid = user?.groups?.id;

              if (gid != null && !groupMap.containsKey(gid)) {
                groupMap[gid] = user;
              }
            }

            uniqueGroups = groupMap.values.toList();

            emit(state.copyWith(showSelectDialog: showDialog));
            stopAllLoaders();
            return;
          }
          dailogCustomers = resultCustomers;
          allCustomers = resultCustomers;

          emit(state.copyWith(showSelectDialog: showDialog));
          stopAllLoaders();
          return;
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
        customerName =
            customer?.concatCustomerFullName ?? customer?.displayRIMName ?? "";
        groupId = customer?.groups?.id ?? "";
        groupName = customer?.groups?.name ?? "";
        groupOwner = customer?.groups?.groupOwner ?? 0;
        isSearched = true;
        stopAllLoaders();
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      }
    } on Object {
      stopAllLoaders();
      isSearched = false;
      AlertManager().showFailureToast("common.noUserFound".tr());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
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
      checkCustomerTypeCountry(customer);
      if (!validationCheck(customer)) {
        return;
      }
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

      if (closeDialog && context.mounted) {
        Navigator.pop(context);
      }

      customer = finalCustomer;
      isSearched = true;
      groupId = customer?.groups?.id ?? "";
      groupName = customer?.groups?.name ?? "";
      grpId = groupId;
      grpName = groupName;

      customerRimNo = customer?.id.toString();

      customerName =
          customer?.concatCustomerFullName ?? customer?.displayRIMName ?? "";

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

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
    logger
      ..i("groupIdLoadingStatus. $groupIdLoadingStatus")
      ..i("customerRimNoLoadingStatus. $customerRimNoLoadingStatus");
  }

  /// Indicates whether the selected Group ID or Group Name
  /// belongs to a Financial Institution (FI) country customer.
  ///
  /// Used to control FI-specific validation and processing logic
  /// during customer and group selection.
  bool? isGroupIdNameFICountry = false;

  /// Initiates search based on group name if not already searched.
  Future<void> onGroupNameSearchPressed({bool showDialog = true}) async {
    if ((groupName ?? "").isNotEmpty && !isSearched && groupName!.length > 3) {
      groupNameLoadingStatus = LoadingStatus.loading;
      isGroupNameSelection = true;
      isSearched = true;
      isGroupIdNameFICountry = true;
      await onCustomerSearchPressed(showDialog: showDialog);
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
      isGroupIdNameFICountry = true;
      await onCustomerSearchPressed();
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
      isGroupIdNameFICountry = false;
      await onCustomerSearchPressed();
    } else {
      AlertManager().showFailureToast(
        "requestInformation.createRequest.enterCustomerRim".tr(),
      );
    }
  }

  /// Filters customers from the existing list based on customer name
  void filterCustomers() {
    if (allCustomers.isEmpty) {
      AlertManager().showFailureToast("common.noUserFound".tr());
      return;
    }

    final String searchTerm = isGroupNameSelection
        ? (groupName ?? "").toLowerCase()
        : (customerName ?? "").toLowerCase();

    if (searchTerm.isEmpty) {
      dailogCustomers = List.from(allCustomers);
    } else {
      dailogCustomers = allCustomers.where((customer) {
        if (customer == null) {
          return false;
        }

        if (isGroupNameSelection) {
          // Filter by group name
          final String groupNameStr =
              (customer.groups?.name ?? "").toLowerCase();
          return groupNameStr.contains(searchTerm);
        } else {
          // Filter by customer name
          final String customerNameStr =
              (customer.preferredName ?? "").toLowerCase();
          return customerNameStr.contains(searchTerm);
        }
      }).toList();
    }

    if (dailogCustomers.isEmpty) {
      // AlertManager().showFailureToast("common.noUserFound".tr());
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Initiates search based on customer name if not already searched.
  Future<void> onCustomerNameSearchPressed({bool showDialog = true}) async {
    if ((customerName ?? "").isNotEmpty &&
        !isSearched &&
        customerName!.length > 3) {
      customerNameLoadingStatus = LoadingStatus.loading;
      isSearched = true;

      isGroupNameSelection = false;
      isGroupIdNameFICountry = false;
      await onCustomerSearchPressed(showDialog: showDialog);
    } else {
      AlertManager().showFailureToast(
        "requestInformation.createRequest.enterCustomerName".tr(),
      );
    }
  }

  /// on request type changed need to change the seletcedRequestType value
  Future<void> onRequestTypeChange(Reference selectedValue) async {
    fieldLoading = true;
    emit(state.copyWith());
    selectedRequestType = selectedValue;
    selectedApplicationType = null;
    await Future.delayed(const Duration(milliseconds: 300));
    fieldLoading = false;
    emit(state.copyWith());
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

  /// Submit button validation logic
  bool submitButtonValidation() =>
      customer == null ||
      selectedRequestType == null ||
      selectedApplicationType == null ||
      (iFinancialInstitutionSelected() && selectedCustomerType == null);

  /// on application type fild changed
  void onApplicationTypeChanged(Reference selectedValue) {
    logger.i("groupIdLoadingStatus. $selectedValue");
    requestCreate.applicationType = selectedValue;
    selectedApplicationType = selectedValue;
    // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
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
    groupOwner = 0;
    isResetPressed = !isResetPressed;
    isSearched = false;
    customerRimNoLoadingStatus = LoadingStatus.loaded;
    customerNameLoadingStatus = LoadingStatus.loaded;
    groupIdLoadingStatus = LoadingStatus.loaded;
    groupNameLoadingStatus = LoadingStatus.loaded;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selected customer type for the request.
  ///
  /// Stores the selected customer type in the request model and
  /// refreshes the UI to reflect the updated selection.
  Future<void> onCustomerTypeSelection(Reference selectedValue) async {
    logger.i("groupIdLoadingStatus. $selectedValue");
    selectedCustomerType = selectedValue;
    requestCreate.customerType = selectedValue;
    await Future.delayed(const Duration(milliseconds: 300));
    emit(state.copyWith());
  }

  /// Returns the list of request types available to the current user.
  ///
  /// Users with Credit Analyst or Credit Coordinator roles are
  /// restricted to the Isolated Memo request type. All other users
  /// are provided with the standard request types excluding
  /// Financial requests.
  List<Reference> getRequestTypes() {
    final hasRiskRole = Utils.checkRoles([
      UserRole.creditAnalyst,
      UserRole.creditCordinator,
    ]);

    if (hasRiskRole) {
      // Show ONLY isolated memo for these roles
      return requestTypes
          .where(
            (data) =>
                data.id == ServerConstants.isolatedMemoId ||
                data.reference1 == ServerConstants.isolatedMemo,
          )
          .toList();
    }

    // Default logic for other roles
    return requestTypes
        .where((data) => data.id != ServerConstants.requestFinancialId)
        .toList();
  }

  /// Determines whether segment and sub-segment validation
  /// should be enforced for the current user.
  ///
  /// Validation is applicable only for business-facing roles
  /// involved in relationship and segment management.
  bool shouldValidateSegmentSubSegment() {
    return Utils.checkRoles([
      UserRole.relationshipOfficer,
      UserRole.relationshipManager,
      UserRole.teamLeaderBusiness,
      UserRole.commercialAreaManager,
      UserRole.segmentHeadBusiness,
    ]);
  }

  /// Returns true when the selected customer type is compatible with the
  /// customer's classCode.
  /// Shows a toast and returns false when invalid.
  ///
  /// Rules:
  /// - If FI is NOT selected → true (skip validation)
  /// - If no selectedCustomerType → true (skip validation)
  /// - "Country" type (id == ServerConstants.countryIDFI OR name ==
  /// ServerConstants.countryNameFI):
  ///     - When isGroupIdNameFICountry == false → customer.classCode MUST equal
  /// ServerConstants.countryClassCode
  /// - "Bank" type (anything else):
  ///     - When isGroupIdNameFICountry == false → customer.classCode MUST NOT
  /// equal ServerConstants.countryClassCode
  bool validateCustomerTypeAgainstClassCode(Customer? customer) {
    try {
      // Only validate for FI flows
      if (!iFinancialInstitutionSelected()) {
        return true;
      }

      // If type not chosen yet, let the flow continue (no hard stop)
      if (selectedCustomerType == null) {
        return true;
      }

      // Normalize inputs
      final String? typeName = selectedCustomerType?.name?.trim().toLowerCase();
      final int? typeId = selectedCustomerType?.id;
      final int? classCode =
          int.tryParse(customer?.classCode?.toString() ?? "");

      // Country → match by ID or name
      final bool isCountryType = typeId == ServerConstants.countryIDFI ||
          typeName == ServerConstants.countryNameFI;

      // Bank (IG/BIG) is any non-country FI type
      final bool isBankType = !isCountryType;

      // --- VALIDATION ---

      if (isCountryType) {
        // Enforce only when your gating flag requires it (keeps your original
        // behavior)
        if (isGroupIdNameFICountry == false) {
          // Country type → classCode must be countryClassCode (e.g., "7018")
          if (classCode?.toString() != ServerConstants.countryClassCode) {
            AlertManager().showFailureToast(
              "requestInformation.createRequest.requiredFieldFI".tr(),
            );
            return false;
          }
        }
      } else if (isBankType) {
        // Enforce only when your gating flag requires it
        if (isGroupIdNameFICountry == false) {
          // Bank type → classCode must NOT be countryClassCode
          if (classCode?.toString() == ServerConstants.countryClassCode) {
            AlertManager().showFailureToast(
              "requestInformation.createRequest.requiredFieldFI".tr(),
            );
            return false;
          }
        }
      }

      // All good
      return true;
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
      return false;
    }
  }

  /// Validates customer type rules for the specified customer.
  ///
  /// Performs customer type and class code validation and resets
  /// all loading indicators when the validation fails.
  void checkCustomerTypeCountry(Customer? customer) {
    final bool isFICustomerTypeCurrencyCheck =
        validateCustomerTypeAgainstClassCode(customer);
    if (!isFICustomerTypeCurrencyCheck) {
      customerRimNoLoadingStatus = LoadingStatus.loaded;
      customerNameLoadingStatus = LoadingStatus.loaded;
      groupIdLoadingStatus = LoadingStatus.loaded;
      groupNameLoadingStatus = LoadingStatus.loaded;
      submitLoadingStatus = LoadingStatus.loaded;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return;
    }
  }

  /// Truncates the provided value to the specified maximum length.
  ///
  /// Returns an empty string when [value] is null.
  /// Otherwise, returns a string containing at most [max] characters.
  String valueTruncateToMax(String? value, int max) {
    if (value == null) {
      return "";
    }
    return value.characters.take(max).toString();
  }
}
