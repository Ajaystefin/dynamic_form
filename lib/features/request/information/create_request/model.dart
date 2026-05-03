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
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/create_request/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";

enum ControlFields { customerRim, customerName, groupID, groupName }

class CreateRequestViewModel extends SafeCubit<CreateRequestState> {
  CreateRequestViewModel()
      : super(CreateRequestState(loaderStatus: LoadingStatus.loading));
  CustomerRepository repository = CustomerRepository();

  /// Initializes the ViewModel by loading reference data and setting up the
  /// request object.

  ValueNotifier<Map<ControlFields, bool>> fieldCntrl = ValueNotifier({
    ControlFields.customerName: false,
    ControlFields.customerRim: false,
    ControlFields.groupID: false,
    ControlFields.groupName: false,
  });

  Reference? businessSegmentValue;
  Reference? selectedRequestType;
  Reference? selectedApplicationType;
  bool showError = true;
  String? customerRimNo;
  String? customerName;
  String? groupId;
  String? groupName;
  int? groupOwner;
  Request requestCreate = Request();

  Reference? selectedCustomerType;
  bool isSearched = false;
  ValueNotifier<bool?> selectedButtonModelVN = ValueNotifier(null);
  ValueNotifier<Customer?> selectedCustomer = ValueNotifier(null);
  List<Customer?> dailogCustomers = [];
  List<Customer?> allCustomers = []; // Store all customers for filtering

  /// Key for validating the form.

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Loading statuses for different fields.

  LoadingStatus groupNameLoadingStatus = LoadingStatus.loaded;
  LoadingStatus groupIdLoadingStatus = LoadingStatus.loaded;
  LoadingStatus customerRimNoLoadingStatus = LoadingStatus.loaded;
  LoadingStatus customerNameLoadingStatus = LoadingStatus.loaded;
  LoadingStatus submitLoadingStatus = LoadingStatus.loaded;

  /// Reference data lists.
  List<Reference> requestTypes = [];
  List<Reference> customerTypes = [];
  List<Reference> applicationTypes = [];
  List<Reference> bussinessSegments = [];
  List<Reference> branchList = [];
  List<Reference> subSegmentValidation = [];

  Customer? customer;
  bool isGroupNameSelection = false;

  bool fieldLoading = false;
  bool isResetPressed = false;

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
  Future<void> onSubmitButtonPress(
    bool isValidated,
  ) async {
    // keep original emit as you had it
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    try {
      // Preserve your existing validation
      if (!isValidated || customer == null) {
        throw "requestInformation.createRequest.requiredField".tr();
      }

      // Start submit loading as you already do
      submitLoadingStatus = LoadingStatus.loading;

      requestCreate
        ..customerRimNo = int.parse(customerRimNo ?? "")
        ..customerName = valueTruncateToMax(customerName ?? "", 50)
        ..groupId = int.tryParse(groupId ?? "")
        ..groupName = valueTruncateToMax(groupName, 50)
        ..groupOwner = groupOwner
        ..businessSegment = businessSegmentValue
        ..customerType = selectedCustomerType
        ..requestType = selectedRequestType
        ..requestSubType = selectedApplicationType
        ..applicationType = selectedApplicationType
        ..customerType = selectedCustomerType;

      // Persist to Globals exactly as before
      Globals.request = requestCreate;
      Globals.request?.isCreateRequest = true;

      // --- Consolidated segment/sub-segment validation (kept as-is) ---
      final bool shouldValidate = shouldValidateSegmentSubSegment();

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
    } catch (e) {
      // preserve your error handling + state
      AlertManager().showFailureToast(e.toString());
      submitLoadingStatus = LoadingStatus.loaded;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

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

  bool isApplicableForSegment(
    Reference element,
    String segmentCode, // "C" or "F"
  ) {
    final String ref = element.reference2 ?? "";
    return ref.split(",").map((e) => e.trim()).contains(segmentCode);
  }

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
    } catch (e) {
      AlertManager().showFailureToast("common.error".tr());
    }
  }

  // set value for business segment as default
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
          await repository.validateSubSegment(relationshipMgrIdent);
          return; // Validation was required and executed
        }
      }

      return; // Validation not required
    } catch (e) {
      customerRimNo = null;
      customerName = null;
      groupId = null;
      groupName = null;
      groupOwner = 0;
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
          throw "common.segmentMismatch".tr();
          // throw Exception('common.segmentMismatch'.tr());
        }
      }

      // checkValidBusinessSegment(customer);
      isSearched = false;
      return true;
    } catch (e) {
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
        final List<Customer?> resultCustomers = await repository
            .searchCustomerProfile(customerName, groupId, groupName);
        if (resultCustomers.length == 1) {
          customer = resultCustomers.first;
          checkCustomerTypeCountry(customer);
          if (!validationCheck(customer)) {
            return;
          }

          //added for visa checking with dialog not loading in single item.
          dailogCustomers = resultCustomers;
          allCustomers = resultCustomers; // Store all customers
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
            checkCustomerTypeCountry(customer);
            if (!validationCheck(customer)) {
              stopAllLoaders();
              return;
            }
          } else {
            dailogCustomers = resultCustomers;
            allCustomers = resultCustomers; // Store all customers
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
    } catch (e) {
      stopAllLoaders();
      isSearched = false;
      AlertManager().showFailureToast("common.noUserFound".tr());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// on select button pressed on selection dailog
  void onSelectionPressed(context, {bool closeDialog = false}) {
    logger.i("requestCreate${selectedCustomer.value}");
    if (selectedCustomer.value == null) {
      AlertManager().showFailureToast("common.selectValue".tr());
    } else {
      customer = selectedCustomer.value;
      checkCustomerTypeCountry(customer);
      if (!validationCheck(customer)) {
        return;
      }
      if (closeDialog && context.mounted) {
        Navigator.pop(context);
      }
      isSearched = true;
      customerRimNo = customer?.id ?? "";
      customerName =
          customer?.concatCustomerFullName ?? customer?.displayRIMName ?? "";
      groupId = customer?.groups?.id ?? "";
      groupName = customer?.groups?.name ?? "";
      groupOwner = customer?.groups?.groupOwner ?? 0;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
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
        if (customer == null) return false;

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

  /// Submit button validation logic
  bool submitButtonValidation() =>
      customer == null ||
      selectedRequestType == null ||
      selectedApplicationType == null ||
      (iFinancialInstitutionSelected() ? selectedCustomerType == null : false);

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

  Future<void> onCustomerTypeSelection(Reference selectedValue) async {
    logger.i("groupIdLoadingStatus. $selectedValue");
    selectedCustomerType = selectedValue;
    requestCreate.customerType = selectedValue;
    await Future.delayed(const Duration(milliseconds: 300));
    emit(state.copyWith());
  }

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
      if (!iFinancialInstitutionSelected()) return true;

      // If type not chosen yet, let the flow continue (no hard stop)
      if (selectedCustomerType == null) return true;

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
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      return false;
    }
  }

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

  String valueTruncateToMax(String? value, int max) {
    if (value == null) return "";
    return value.characters.take(max).toString();
  }
}
