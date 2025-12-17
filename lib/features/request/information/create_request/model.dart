import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'package:wcas_frontend/repositories/auth_repository.dart';
import 'package:wcas_frontend/repositories/customer_respository.dart';

import 'state.dart';

enum ControlFields { customerRim, customerName, groupID, groupName }

class CreateRequestViewModel extends Cubit<CreateRequestState> {
  CreateRequestViewModel()
      : super(CreateRequestState(loaderStatus: LoadingStatus.loading));
  CustomerRepository repository = CustomerRepository();

  /// Initializes the ViewModel by loading reference data and setting up the request object.

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
    logger.i('initialising CreateViewModel');
    requestCreate = Request();
    await loadReferenceData();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Determines if the customer type field should be shown based on business segment.
  bool iFinancialInstitutionSelected() =>
      businessSegmentValue?.id == ServerConstants.financialInstitutionId;

  /// Handles form submission.
  Future<void> onSubmitButtonPress(
    bool isValidated,
  ) async {
    // submitLoadingStatus = LoadingStatus.loading;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    try {
      if (!isValidated || customer == null) {
        throw "requestInformation.createRequest.requiredField".tr();
      }
      submitLoadingStatus = LoadingStatus.loading;
      requestCreate
        ..customerRimNo = int.parse(customerRimNo ?? "")
        ..customerName = customerName ?? ""
        ..groupId = int.tryParse(groupId ?? "")
        ..groupName = groupName
        ..groupOwner = groupOwner
        ..businessSegment = businessSegmentValue
        ..customerType = selectedCustomerType
        ..requestType = selectedRequestType
        ..requestSubType = selectedApplicationType
        ..applicationType = selectedApplicationType;
      // Router to next page
      Globals.request = requestCreate;
      Globals.request?.isCreateRequest = true;

      if (shouldValidateSegmentSubSegment()) {
        await validateSubSegment();
      }
      if (groupId != null && groupId!.isNotEmpty) {
        /// for getting the non borrower list
        List<Customer?> resultCustomers =
            await repository.searchCustomerProfile(null, groupId, null);
        await repository.getBorrowerCustomers(resultCustomers, customer!);
      } else {
        customer?.isPrimary = true;
        Globals.request?.borrowers = [customer!];
      }

      await AuthRepository.instance
          .updateRole(Globals.user!.currentRole!, request: requestCreate);
      router.go(Routes.groupBorrowers, extra: requestCreate);

      submitLoadingStatus = LoadingStatus.loaded;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      // LayoutViewModel().goToNextRoute(extra: requestCreate);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      submitLoadingStatus = LoadingStatus.loaded;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }

    // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
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
  List<Reference>? applicationTypeItems() {
    logger.i("requestCreate.validate()}");

    // Check if user has specific roles
    final hasRiskRole = Utils.checkRoles([
      UserRole.creditAnalyst,
      UserRole.creditCordinator,
    ]);

    if (hasRiskRole) {
      // Show only Risk Rating Changes for these roles
      return applicationTypes
          .where((element) => element.id == ServerConstants.riskRatingchanges)
          .toList();
    }

    // For all other roles, apply old logic
    if (businessSegmentValue?.id ==
        ServerConstants
            .businessSegmentId[BusinessSegment.financialInstitution]) {
      return applicationTypes
          .where((element) =>
              element.reference4 == selectedRequestType?.reference1 &&
              (element.reference3 ?? "")
                  .contains(ServerConstants.financialCode))
          .toList();
    }

    return applicationTypes
        .where((element) =>
            element.reference4 == selectedRequestType?.reference1 &&
            (element.reference3 ?? "").contains(ServerConstants.corperateCode))
        .toList();
  }

  /// Updates selected business segment.
  Future<void> onBussinessSegmentSelected(Reference value) async {
    fieldLoading = true;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    requestCreate.businessSegment = value;
    logger.i("requestCreate. $value");
    businessSegmentValue = value;
    selectedApplicationType = null;
    await Future.delayed(const Duration(milliseconds: 300));
    fieldLoading = false;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    resetDependentFields();
  }

  /// Loads reference data required for the form.
  Future<void> loadReferenceData() async {
    try {
      Map<String, List<Reference>> referenceData =
          await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.requestType,
        ReferenceDataKeys.customerType,
        ReferenceDataKeys.applicationType,
        ReferenceDataKeys.applicationSegment,
        ReferenceDataKeys.branchList,
        ReferenceDataKeys.subSegmentValidation,
      ]);
      requestTypes = referenceData[ReferenceDataKeys.requestType] ?? [];
      customerTypes = referenceData[ReferenceDataKeys.customerType] ?? [];
      applicationTypes = referenceData[ReferenceDataKeys.applicationType] ?? [];
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
    String? apiSegment = customer?.segment?.trim();
    bool isFISelected = businessSegmentValue?.id ==
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
      if (shouldValidateSegmentSubSegment() &&
          (!checkValidRegion(customer) || !checkValidSegment(customer))) {
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        throw "common.segmentMismatch".tr();
      }

      checkValidBusinessSegment(customer);
      isSearched = false;
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      customer = null;
      isSearched = false;
      stopAllLoaders();
      return false;
    }

    return true;
  }

  /// Searches for customer details based on input fields.

  Future<void> onCustomerSearchPressed({bool showDialog = true}) async {
    try {
      if (selectedRequestType == null ||
          selectedApplicationType == null ||
          (iFinancialInstitutionSelected() && selectedCustomerType == null) ||
          businessSegmentValue == null) {
        AlertManager().showFailureToast(
            "requestInformation.createRequest.requiredField".tr());
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
        if (!validationCheck(customer)) {
          return;
        }
      } else {
        List<Customer?> resultCustomers = await repository
            .searchCustomerProfile(customerName, groupId, groupName);
        if (resultCustomers.length == 1) {
          customer = resultCustomers.first;
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
        customerName = customer?.displayRIMName ?? "";
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
      if (!validationCheck(customer)) {
        return;
      }
      if (closeDialog && context.mounted) {
        Navigator.pop(context);
      }
      isSearched = true;
      customerRimNo = customer?.id ?? "";
      customerName = customer?.displayRIMName ?? "";
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
    logger.i("groupIdLoadingStatus. $groupIdLoadingStatus");
    logger.i("customerRimNoLoadingStatus. $customerRimNoLoadingStatus");
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

  /// Filters customers from the existing list based on customer name
  void filterCustomers() {
    if (allCustomers.isEmpty) {
      AlertManager().showFailureToast("common.noUserFound".tr());
      return;
    }

    String searchTerm = isGroupNameSelection
        ? (groupName ?? "").toLowerCase()
        : (customerName ?? "").toLowerCase();

    if (searchTerm.isEmpty) {
      dailogCustomers = List.from(allCustomers);
    } else {
      dailogCustomers = allCustomers.where((customer) {
        if (customer == null) return false;

        if (isGroupNameSelection) {
          // Filter by group name
          String groupNameStr = (customer.groups?.name ?? "").toLowerCase();
          return groupNameStr.contains(searchTerm);
        } else {
          // Filter by customer name
          String customerNameStr = (customer.preferredName ?? "").toLowerCase();
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

      await onCustomerSearchPressed(showDialog: showDialog);
    } else {
      AlertManager().showFailureToast(
          "requestInformation.createRequest.enterCustomerName".tr());
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
          .where((data) => data.id == ServerConstants.isolatedMemo)
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
      UserRole.segmentHeadBusiness
    ]);
  }
}
