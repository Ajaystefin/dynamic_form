import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/date_time_utils.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/application_details.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/country.dart';
import 'package:wcas_frontend/repositories/auth_repository.dart';
import 'package:wcas_frontend/repositories/customer_respository.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

class CustomerInfoViewModel extends Cubit<CustomerInfoState> {
  CustomerInfoViewModel()
      : super(CustomerInfoState(
            loaderStatus: LoadingStatus.loading,
            userNameChangeLoader: LoadingStatus.loaded));
  late RequestRepository repository;
  late CustomerRepository repositoryCustomer;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  BuildContext? context;

  List<TextEditingController> rimControllers = [];

  bool get canEdit => (pageMode == PageMode.edit);
  Map<String, List<Reference>> referenceData = {};
  List<Country>? countries;
  Customer? customerInformation;
  List<CustomerOwnerShipInfo>? customerOwnerShipInfo = [];
  List<CustomerException>? customerException = [];
  PageMode pageMode = PageMode.na;

  Reference? selectedIfrsStaging;
  Reference? selectedProposedSicCode;
  Reference? selectedTlIssuingAuthority;
  Reference? selectedCccStatus;
  Customer? customer;
  Customer? selectedCustomer;
  List<Customer>? customerList = [];
  ApplicationDetails? applicationDetails;

  double totalShareHolding = 0;
  double totalBeneficialOwnership = 0;
  List<Reference>? proposedSICcodes = [];

  bool showCurrentFiCreditRisk = false;

  List<Reference> fiBankProposedOptions = [];
  List<Reference> policyDeviation = [];
  bool rimFound = false;
  String? residentCountryCode;
  bool isDateValid = true;
  Reference? selectedFiBankProposedValue;
  List<bool> checkboxes = [];
  bool isCheckboxEnabled = false;

  List<TextEditingController> exceptionTypeController = [];
  List<TextEditingController> exceptionFacilityController = [];
  List<TextEditingController> exceptionDescController = [];
  List<TextEditingController> exceptionRecommController = [];

  Future<void> init(cont) async {
    context = cont;
    logger.i('initialising CustomerInfoViewModel');
    repository = RequestRepository.instance;
    repositoryCustomer = CustomerRepository.instance;
    pageMode = AuthRepository.getPageMode(RightConstants.customerInformation);

    // for checkup with request type creditRisk
    showCurrentFiCreditRisk =
        Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

    selectedCustomer = getSelectedCustomer();

    try {
      await Future.wait([
        getCountries(),
        loadReferenceData(),
        getApplicationDetails(),
        getChildRimsForGroup()
      ]);
    } catch (e) {
      if (e.toString().isNotEmpty) {
        AlertManager().showFailureToast(e.toString());
      }
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Returns the selected customer based on the group ID in the global request.
  ///
  /// If `groupId` is not zero, it returns the main customer from the request.
  /// Otherwise, it returns the first customer from the `customers` list.
  ///
  /// Returns an empty [Customer] object if the request is null.
  Customer getSelectedCustomer() {
    final request = Globals.request;
    if (request == null) return Customer();
    //final bool hasGroup = request.groupId != 0;
    return Customer(
      customerName: request.customers?.first.customerName,
      customerRimNo: request.customers?.first.customerRimNo,
    );
  }

  /// Loads reference data for search criteria, segment types, region list,
  /// advance request types, and role types. Populates the [referenceData] map
  /// with the fetched data. If an error occurs during the fetching process,
  /// it updates the loader status to [LoadingStatus.error].
  Future<void> loadReferenceData() async {
    try {
      referenceData = await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.sicCodeList,
        ReferenceDataKeys.tlIssuingAuthorityList,
        ReferenceDataKeys.cccStatus,
        ReferenceDataKeys.ifrsStaging,
        ReferenceDataKeys.policyDeviation,
        ReferenceDataKeys.yesNoNa,
        ReferenceDataKeys.ownerType,
        ReferenceDataKeys.largeExposureLimit
      ]);
      fiBankProposedOptions = referenceData[ReferenceDataKeys.yesNoNa] ?? [];
      policyDeviation = referenceData[ReferenceDataKeys.policyDeviation] ?? [];
    } catch (e) {
      //emit(state.copyWith(loaderStatus: LoadingStatus.error));
      logger.i('Error ReferenceData  get: $e');
      rethrow;
    }
  }

  /// Retrieves the application details from the repository, and updates the
  /// state with the fetched details. If an error occurs during the process,
  /// it sets the loader status to [LoadingStatus.error].
  ///
  /// This function is called when the view is first loaded. It uses the
  /// [RequestRepository] to fetch the application details. If the details are
  /// successfully fetched, it updates the state with the details. If an error
  /// occurs, it sets the loader status to [LoadingStatus.error].
  Future<void> getApplicationDetails() async {
    try {
      applicationDetails = ApplicationDetails(
          groupID: Globals.request?.groupId,
          groupName: Globals.request?.groupName);
      // await repositoryCustomer.getApplicationDetails();
      await getCustomerInformation(
          customerRimNo: selectedCustomer?.customerRimNo);
      emit(state.copyWith(
          loaderStatus: LoadingStatus.loaded,
          userNameChangeLoader: LoadingStatus.loaded));
    } catch (e) {
      logger.i('Error getApplicationDetails types: $e');
      if (e.toString().isNotEmpty) {
        AlertManager().showFailureToast(e.toString());
      }
      emit(state.copyWith(
          loaderStatus: LoadingStatus.loaded,
          userNameChangeLoader: LoadingStatus.loaded));
    }
  }

  /// Retrieves customer information by rim number. If the customer rim number is
  /// not provided, it uses the rim number from the application details.
  /// Updates the [customerInformation], [selectedTlIssuingAuthority],
  /// [selectedCountriesTradedWith], [selectedCountriesofBussinessOperation],
  /// [selectedCccStatus], and [selectedCustomer] properties.
  /// If an error occurs, it updates the loader status to [LoadingStatus.error].
  Future<void> getCustomerInformation({int? customerRimNo}) async {
    try {
      customerInformation =
          await repositoryCustomer.getCustomerInformationByRim(customerRimNo);
      if (customerInformation != null) {
        if (customerInformation?.tlIssuingAuthority != null) {
          selectedTlIssuingAuthority =
              referenceData[ReferenceDataKeys.tlIssuingAuthorityList]
                  ?.firstWhere(
            (element) =>
                element.name == customerInformation?.tlIssuingAuthority,
            orElse: () => Reference(),
          );
        }
        selectedCccStatus = null;
        if (customerInformation?.cccStatus != null) {
          selectedCccStatus =
              referenceData[ReferenceDataKeys.cccStatus]?.firstWhere(
            (element) => element.name == customerInformation?.cccStatus,
            orElse: () => Reference(name: customerInformation?.cccStatus),
          );
        }
        selectedProposedSicCode = null;
        if (customerInformation?.proposedSICCode != null) {
          selectedProposedSicCode =
              referenceData[ReferenceDataKeys.sicCodeList]?.firstWhere(
            (element) => element.name == customerInformation?.proposedSICCode,
            orElse: () => Reference(name: customerInformation?.proposedSICCode),
          );
        }

        selectedIfrsStaging = null;
        if (customerInformation?.ifrsStaging != null) {
          selectedIfrsStaging =
              referenceData[ReferenceDataKeys.ifrsStaging]?.firstWhere(
            (element) => element.name == customerInformation?.ifrsStaging,
            orElse: () => Reference(name: customerInformation?.ifrsStaging),
          );
        }

        final industrySicCode = customerInformation?.industrySicCode;
        final industrySicCodeDesc = customerInformation?.industryDescription;
        final hasPolicyDeviation =
            customerInformation?.policyDeviations?.isNotEmpty ?? false;

        emit(state.copyWith(
          industrySicCode: industrySicCode,
          industrySicCodeDesc: industrySicCodeDesc,
          isPolicyDeviation: hasPolicyDeviation,
        ));

        selectedCustomer = Customer(
            customerName: customerInformation?.customerName,
            customerRimNo: customerInformation?.customerRimNo);

        if (customerInformation?.custInfoId != null) {
          await getCustomerInformationOwnerShip(
              customerRimNo: customerInformation?.custInfoId);
          await getCustomerInformationException(
              customerRimNo: customerInformation?.custInfoId);
        } else {
          customerOwnerShipInfo = [];
          customerException = [];
        }
      }
    } catch (e) {
      // emit(state.copyWith(loaderStatus: LoadingStatus.error));
      logger.i('Error fetching getCustomerInfoByRim : $e');
      rethrow;
    }
  }

  Future<void> getCustomerInformationOwnerShip({int? customerRimNo}) async {
    try {
      customerOwnerShipInfo = await repositoryCustomer
              .getCustomerInformationByRimOwnership(customerRimNo) ??
          [];
    } catch (e) {
      // emit(state.copyWith(loaderStatus: LoadingStatus.error));
      logger.i('Error fetching Ownership : $e');
      rethrow;
    }
  }

  Future<void> getCustomerInformationException({int? customerRimNo}) async {
    try {
      customerException = await repositoryCustomer
          .getCustomerInformationByRimException(customerRimNo);
      // if ((customerException ?? []).isEmpty) {
      //   customerException?.add(CustomerException());
      // }
    } catch (e) {
      //emit(state.copyWith(loaderStatus: LoadingStatus.error));
      logger.i('Error fetching Exception : $e');
      rethrow;
    }
  }

  /// Retrieves a list of countries from the server and stores them in the
  /// [countries] property. If the retrieval fails, the loader status is set to
  /// [LoadingStatus.error].
  Future<void> getCountries() async {
    try {
      countries = (await repositoryCustomer.getCountries() ?? [])
        ..sort((a, b) => (a.description ?? '').compareTo(b.description ?? ''));
    } catch (e) {
      // emit(state.copyWith(loaderStatus: LoadingStatus.error));
      logger.i('Error fetching getCountries : $e');
      rethrow;
    }
  }

  Future<void> getChildRimsForGroup() async {
    try {
      if (Utils.isGroupOwnerApplication()) {
        customerList = (await repositoryCustomer.getChildRimsForGroup() ?? []);
      }
    } catch (e) {
      // emit(state.copyWith(loaderStatus: LoadingStatus.error));
      logger.i('Error fetching getChildRimsForGroup : $e');
      rethrow;
    }
  }

  /// Returns true if the current view is a group view, i.e. if
  /// [applicationDetails.groupID] is not null and not equal to 0.
  bool isGroupView() {
    return applicationDetails?.groupID != null &&
        applicationDetails!.groupID != 0;
  }

  Future<void> onCustomerSeletion(Customer selectedValue) async {
    selectedCustomer = selectedValue;
    emit(state.copyWith(userNameChangeLoader: LoadingStatus.loading));
    formKey.currentState?.reset();
    Future.delayed(const Duration(milliseconds: 200), () {});
    await getApplicationDetails();
  }

  /// Triggers a refresh of the customer information data when the refresh button
  /// is pressed. Updates the [CustomerInfoState.userNameChangeLoader] status to
  /// [LoadingStatus.loading] while the data is being fetched, and then updates it
  /// to [LoadingStatus.loaded] when the data is available.
  void onRefreshButtonPressed(context) async {
    if (selectedCustomer != null) {
      DialogHelper.showCustomDialog(
          context: context,
          title: "customerInformation.customerInformation.confirmation".tr(),
          content: Text(
              "customerInformation.customerInformation.doYouWishToSave".tr()),
          actions: [
            CustomButton(
                label: "customerInformation.customerInformation.save".tr(),
                onPressed: () async {
                  Navigator.pop(context);
                  if (selectedCustomer != null) {
                    emit(state.copyWith(
                        userNameChangeLoader: LoadingStatus.loading));
                    selectedCustomer = null;

                    formKey.currentState?.reset();
                    Future.delayed(const Duration(milliseconds: 200), () {});
                    selectedCustomer = getSelectedCustomer();
                    await Future.wait([getApplicationDetails()]);
                    emit(state.copyWith(
                        userNameChangeLoader: LoadingStatus.loaded));
                  }
                  // emit(state.copyWith(
                  //     userNameChangeLoader: LoadingStatus.empty));
                }),
            const Gap(
              direction: Axis.horizontal,
            ),
            CustomButton(
                label: "customerInformation.customerInformation.cancel".tr(),
                onPressed: () {
                  Navigator.pop(context);
                  selectedCustomer = null;
                  emit(state.copyWith(
                      userNameChangeLoader: LoadingStatus.empty));
                })
          ]);
    }
  }

  Future<void> updateRimNo(String rimNo, int index) async {
    try {
// Validate index before proceeding
      if (customerOwnerShipInfo == null ||
          index < 0 ||
          index >= customerOwnerShipInfo!.length) {
        return;
      }

      customer = await repositoryCustomer.searchUserDetailsPartyInqOnly(
          rimNo.toString(), "", "", "");

      if (customer == null) {
        //"PartyStatus": "Closed             ",
        throw "common.noUserFound".tr();
      }

      if (customer != null) {
        if (customer?.partyStatus.toString().trim() ==
            ServerConstants.partyStatusClosed) {
          throw "common.noUserFoundClosedPartyStatus".tr();
        } else {
          final issuedIdentList = customer?.issuedIdent ?? [];

          String? identificationDetail = "";
          String? identificationNumber = "";

          // Find NationalID with non-empty value
          final nationalIdItem = issuedIdentList.firstWhere(
            (item) =>
                item.name == ServerConstants.nationalID &&
                item.description != null &&
                item.description.toString().trim().isNotEmpty,
            orElse: () => Reference(name: "", description: ""),
          );

          // If NationalID found (name not empty), use it; else fallback to first item
          if (nationalIdItem.name.toString().isNotEmpty) {
            identificationDetail = nationalIdItem.name;
            identificationNumber = nationalIdItem.description;
          } else if (issuedIdentList.isNotEmpty) {
            identificationDetail = issuedIdentList.first.name;
            identificationNumber = issuedIdentList.first.description;
          } else {
            identificationDetail = "";
            identificationNumber = "";
          }

          // Assign to model
          customerOwnerShipInfo?[index].identificationDetail =
              identificationDetail;
          customerOwnerShipInfo?[index].identificationNumber =
              identificationNumber;

          customerOwnerShipInfo?[index].custOwnershipRim =
              int.tryParse(customer?.id ?? "");
          customerOwnerShipInfo?[index].custOwnershipName =
              customer?.displayRIMName;
          customerOwnerShipInfo?[index].nationality =
              customer?.tLIssueCountry ?? '';
          customerOwnerShipInfo?[index].resident =
              customer?.resident == ServerConstants.residentValue
                  ? ServerConstants.residentYes
                  : ServerConstants.residentNo;
          emit(state.copyWith(userNameChangeLoader: LoadingStatus.loaded));
          rimFound = true;
        }
      }
    } catch (e) {
      AlertManager().showFailureToast("common.noUserFound".tr());
    }
  }

  void addOwnershipTableRow() {
    customerOwnerShipInfo?.add(
      CustomerOwnerShipInfo(
        custOwnId: null,
        rim: -1,
        nationality: "",
        identificationDetail: "",
        custOwnershipName: "",
        identificationNumber: "",
        custOwnershipRim: -1,
        beneficialOwnerhipPercentage: 0,
        shareHoldingPercentage: 0,
        isNewlyAdded: true,
      ),
    );
    rimFound = false;
    checkboxes.add(true);
    isCheckboxEnabled = true;
    emit(state.copyWith(userNameChangeLoader: LoadingStatus.loaded));
  }

  Future<void> removeOwnershipTableRow(int index) async {
    final ownership = customerOwnerShipInfo?[index];

    if (ownership == null || selectedCustomer?.customerRimNo == null) {
      emit(state.copyWith(userNameChangeLoader: LoadingStatus.loaded));
      return;
    }

    try {
      if (customerInformation?.custInfoId != null) {
        final custOwnershipName = ownership.custOwnId;
        if (custOwnershipName != null ||
            (custOwnershipName!.toString().isNotEmpty ||
                custOwnershipName.toString() != "0")) {
          final result = await repositoryCustomer.deleteOwnership(
            ownership.custOwnId,
            ownership.rim,
          );
          logger.i('deleteException save: $result');
          AlertManager().showSuccessToast("common.deleteSuccess".tr());
        }
      }
    } catch (e) {
      logger.i(e.toString());
      if (e.toString().isNotEmpty) {
        //"Unexpected null value."
        //AlertManager().showFailureToast(e.toString());
      }
    }

    customerOwnerShipInfo?.removeAt(index);

    emit(state.copyWith(userNameChangeLoader: LoadingStatus.loaded));
  }

  void updateOwnershipRim(int index, bool isChecked) {
    final owner = customerOwnerShipInfo?[index];
    if (owner != null) {
      owner.rim = isChecked ? 1 : 0;
    }
    emit(state.copyWith(userNameChangeLoader: LoadingStatus.loaded));
  }

  void removeCheckbox(int index) {
    if (checkboxes.length > index) {
      checkboxes.removeAt(index);
    }
  }

  String? shareHoldingPercentageValidator(String? value) {
    if (value == null) {
      return 'This field cannot be empty';
    }
    double totalPercentage = 0;
    for (CustomerOwnerShipInfo owner in (customerOwnerShipInfo ?? [])) {
      if ((owner.shareHoldingPercentage ?? 0) == 0) {
        return "Shareholding percentage cannot be 0";
      }
      totalPercentage += owner.shareHoldingPercentage ?? 0;
    }
    if (totalPercentage != 100) {
      return 'Total Shareholding Percentage should be 100%';
    }
    return null;
  }

  String? beneficialOwnerhipPercentageValidator(String? value) {
    if (value == null) {
      return 'This field cannot be empty';
    }
    double totalPercentage = 0;
    for (CustomerOwnerShipInfo owner in (customerOwnerShipInfo ?? [])) {
      if ((owner.beneficialOwnerhipPercentage ?? 0) == 0) {
        return "Beneficial percentage cannot be 0";
      }
      totalPercentage += owner.beneficialOwnerhipPercentage ?? 0;
    }

    if (totalPercentage != 100) {
      return 'Total Beneficial Percentage should be 100%';
    }
    return null;
  }

  String? checkTlDateAlert(String? value, {bool isSave = false}) {
    if (value == null || value.trim().isEmpty) {
      return null; // No validation for empty/null
    }

    try {
      final isoDate = DateTimeUtils.convertUIDateToISO(value);
      final enteredDate = DateTime.parse(isoDate);

      final today = DateTime.now();
      final todayDateOnly = DateTime(today.year, today.month, today.day);

      if (enteredDate.isBefore(todayDateOnly)) {
        isDateValid = false;
        return "The expiry date cannot be before today's date.";
      }

      isDateValid = true;
      return null; // Valid date
    } catch (e) {
      isDateValid = false;
      return null; // Ignore invalid format instead of showing error
    }
  }

  Future<void> onSave({bool ifNavigate = false}) async {
    try {
      if (!formKey.currentState!.validate()) {
        String? shareHolderMessage = shareHoldingPercentageValidator("0");
        String? beneficialOwnerhipMessage =
            beneficialOwnerhipPercentageValidator("0");
        if (shareHolderMessage != null) throw shareHolderMessage;
        if (beneficialOwnerhipMessage != null) throw beneficialOwnerhipMessage;
        throw "Please fill all required fields";
      }

      formKey.currentState?.save();

      populateCustomerInformation();

      String? response = await repositoryCustomer.saveUserDetails(
        customerInformation,
        customerOwnerShipInfo,
        customerException,
      );

      if (response == "common.success".tr()) {
        AlertManager().showSuccessToast("common.saveSuccess".tr());
        if (ifNavigate) {
          LayoutViewModel().goToNextRoute();
        }
      } else {
        AlertManager().showFailureToast("$response");
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  void populateCustomerInformation() {
    customerInformation?.industryDescription ??= state.industrySicCodeDesc;
    customerInformation?.industrySicCode ??= state.industrySicCode;
    customerInformation?.addressLine3 = 'DUBAI'.tr();

    customerInformation?.tlExpiryDateLong =
        convertIsoDateToTimestamp(customerInformation?.tlExpiryDate);
    customerInformation?.relatnStartDateLong =
        convertIsoDateToTimestamp(customerInformation?.relatnStartDate);
    customerInformation?.establishmentDateLong =
        convertIsoDateToTimestamp(customerInformation?.establishmentDate);
    customerInformation?.borrowRelationShipDateLong =
        convertIsoDateToTimestamp(customerInformation?.borrowRelationShipDate);

    final exceptions = customerException ?? [];
    if (exceptions.isNotEmpty) {
      for (int i = 0; i < exceptions.length; i++) {
        if (exceptions[i].dueDate != null &&
            exceptions[i].dueDate!.isNotEmpty) {
          exceptions[i].dueDateLong =
              convertIsoDateToTimestamp(exceptions[i].dueDate);
        }
      }
    }
  }

  int convertIsoDateToTimestamp(String? isoDateStr) {
    if (isoDateStr == null) {
      DateTime now = DateTime.now();
      return now.millisecondsSinceEpoch ~/ 1000;
    } else {
      final DateTime? dateTime = DateTime.tryParse(isoDateStr);
      if (dateTime == null) {
        DateTime now = DateTime.now();
        return now.millisecondsSinceEpoch ~/ 1000;
      }
      return dateTime.millisecondsSinceEpoch ~/ 1000;
    }
  }

  /// Resets the total share holding and beneficial ownership percentages to
  /// zero.
  void clearPercentageValues() {
    totalShareHolding = 0;
    totalBeneficialOwnership = 0;
  }

  /// Returns the application or transaction type based on the subtype of the
  /// [ApplicationDetails].
  ///
  /// If the subtype matches an application type, the method returns a string
  /// starting with "Application" followed by the application type name.
  ///
  /// If the subtype matches a transaction type, the method returns a string
  /// starting with "Transaction" followed by the transaction type name.
  ///
  /// If the subtype does not match any application or transaction type, the
  /// method returns an empty string.
  String getRequestType() {
    final subType = applicationDetails?.subType;

    Reference? reference =
        referenceData[ReferenceDataKeys.applicationType]?.firstWhere(
      (element) => element.reference1 == subType,
    );

    if (reference != null) {
      return "${"customerInformation.customerInformation.application".tr()} ${reference.name}";
    }

    reference = referenceData[ReferenceDataKeys.transactionType]?.firstWhere(
      (element) => element.reference1 == subType,
    );

    if (reference != null) {
      return "${"customerInformation.customerInformation.transaction".tr()} ${reference.name}";
    }

    return "";
  }

  /// Initialize controllers based on coBorrowers list

  void initializeControllers(List<CustomerException> customerException) {
    exceptionTypeController = List.generate(customerException.length, (index) {
      final val = customerException[index].type ?? '';
      final c = TextEditingController(text: val);
      c.addListener(() {
        customerException[index].type = c.text;
      });
      return c;
    });

    exceptionFacilityController =
        List.generate(customerException.length, (index) {
      final val = customerException[index].facilityId ?? '';
      final c = TextEditingController(text: val);
      c.addListener(() {
        customerException[index].facilityId = c.text;
      });
      return c;
    });

    exceptionDescController = List.generate(customerException.length, (index) {
      final val = customerException[index].description ?? '';
      final c = TextEditingController(text: val);
      c.addListener(() {
        customerException[index].description = c.text;
      });
      return c;
    });

    exceptionRecommController =
        List.generate(customerException.length, (index) {
      final val = customerException[index].recommendations ?? '';
      final c = TextEditingController(text: val);
      c.addListener(() {
        customerException[index].recommendations = c.text;
      });
      return c;
    });
  }

  /// Dispose controllers
  void disposeControllers() {
    for (TextEditingController controller in exceptionTypeController) {
      controller.dispose();
    }
    for (TextEditingController controller in exceptionFacilityController) {
      controller.dispose();
    }
    for (TextEditingController controller in exceptionDescController) {
      controller.dispose();
    }
    for (TextEditingController controller in exceptionRecommController) {
      controller.dispose();
    }
  }

  void addExcptionTableRow() {
    // Work with a local copy to avoid null-bang
    final list = customerException ?? [];
    final hasRows = list.isNotEmpty;
    final lastNameFromModel =
        hasRows ? (list.last.description?.trim() ?? '') : '';

    // Allow add if list is empty OR last existing row has a non-empty name
    final canAdd = !hasRows || lastNameFromModel.isNotEmpty;

    if (!canAdd) {
      return; // Don't add another empty row
    }

    // Add new co-borrower to model and assign back
    final newList = List<CustomerException>.from(list)
      ..add(CustomerException(
          type: '', facilityId: "", description: '', recommendations: ''));
    customerException = newList;

    //Add controllers for new row
    exceptionTypeController.add(TextEditingController(text: ""));
    exceptionFacilityController.add(TextEditingController(text: ""));
    exceptionDescController.add(TextEditingController(text: ""));
    exceptionRecommController.add(TextEditingController(text: ""));

    emit(state.copyWith(userNameChangeLoader: LoadingStatus.loaded));
  }

  Future<void> removeExcptionTableRow(int index) async {
    CustomerException? exception = customerException?[index];

    if (exception == null || selectedCustomer?.customerRimNo == null) {
      emit(state.copyWith(userNameChangeLoader: LoadingStatus.loaded));
      return;
    }

    try {
      if (customerInformation?.custInfoId != null) {
        final custOwnershipName = exception.exceptionId;
        if (custOwnershipName != null ||
            (custOwnershipName!.toString().isNotEmpty ||
                custOwnershipName.toString() != "0")) {
          final String result = await repositoryCustomer.deleteException(
              exception.exceptionId, exception.custInfoId);
          logger.i('deleteException save: $result');
          AlertManager().showSuccessToast("common.deleteSuccess".tr());
        }
      }
    } catch (e) {
      logger.i(e.toString());
      // AlertManager().showFailureToast(e.toString());
    }

    customerException?.removeAt(index);

    //Remove controllers safely
    if (index < exceptionTypeController.length) {
      exceptionTypeController.removeAt(index);
    }
    if (index < exceptionFacilityController.length) {
      exceptionFacilityController.removeAt(index);
    }
    if (index < exceptionDescController.length) {
      exceptionDescController.removeAt(index);
    }
    if (index < exceptionRecommController.length) {
      exceptionRecommController.removeAt(index);
    }

    emit(state.copyWith(userNameChangeLoader: LoadingStatus.loaded));
  }

  void onFiBankProposedSelected(Reference selected) {
    selectedFiBankProposedValue = selected;
    if (selectedFiBankProposedValue?.id == ServerConstants.yesRefId) {
      customerInformation?.isLimitWithinPolicy = true;
    } else if (selectedFiBankProposedValue?.id == ServerConstants.noRefId) {
      customerInformation?.isLimitWithinPolicy = false;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

// Reusable method to Validator
  String? validateSelection(
      String? value, List<Reference> options, String errorKey) {
    final trimmedValue = value?.trim();
    final isValid = options.any((ref) => ref.name == trimmedValue);
    return isValid ? null : errorKey.tr();
  }

  // Reusable method to filter out 'NA'
  List<Reference> getFilteredOptions(List<Reference> options) {
    return options
        .where((ref) => ref.id != ServerConstants.naRefId)
        //    ref.name != 'requestInformation.requestInformation.na'.tr())
        .toList();
  }

  // Reusable method to get selected value with fallback
  Reference getSelectedReference({
    required List<Reference> options,
    required Reference? selectedValue,
    required bool? fallbackFlag,
  }) {
    final filtered = getFilteredOptions(options);

    if (selectedValue != null && filtered.contains(selectedValue)) {
      return selectedValue;
    }

    final fallbackName = fallbackFlag == true
        ? 'requestInformation.requestInformation.yes'.tr()
        : 'requestInformation.requestInformation.no'.tr();

    return filtered.firstWhere(
      (ref) => ref.name == fallbackName,
      orElse: () => filtered.first,
    );
  }

  /// Called when a country-chip’s delete icon is tapped
  void onCountryChipDeleted(int index) {
    final list = customerInformation?.countryRiskWith;
    if (list == null || index < 0 || index >= list.length) return;

    list.removeAt(index);

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Overwrite the entire Country selection (from onSelected) and emit.
  void updateCountriesOfRisk(List<Country> selected) {
    customerInformation?.countryRiskWith = selected;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Called when a country-chip’s delete icon is tapped
  void onCountryTradedDeleted(int index) {
    final list = customerInformation?.countriesTradedWith;
    if (list == null || index < 0 || index >= list.length) return;

    list.removeAt(index);

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Overwrite the entire Country selection (from onSelected) and emit.
  void updateCountriesOfTraded(List<Country> selected) {
    customerInformation?.countriesTradedWith = selected;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Called when a country-chip’s delete icon is tapped
  void onCountryBuisnessOperationDeleted(int index) {
    final list = customerInformation?.countriesofBussinessOperation;
    if (list == null || index < 0 || index >= list.length) return;

    list.removeAt(index);

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Overwrite the entire Country selection (from onSelected) and emit.
  void updateCountriesOfBuisnessOperation(List<Country> selected) {
    customerInformation?.countriesofBussinessOperation = selected;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onPolicyDeviationSelected(List<Reference> selectedValue) {
    customerInformation?.policyDeviations = selectedValue;
    emit(state.copyWith(
        isPolicyDeviation: selectedValue.isNotEmpty,
        loaderStatus: LoadingStatus.loaded));
  }

  /// Called when a country-chip’s delete icon is tapped
  void onPolicyChipDeleted(int index) {
    final list = customerInformation?.policyDeviations;
    if (list == null || index < 0 || index >= list.length) return;

    list.removeAt(index);
    customerInformation?.policyDeviations = list;

    emit(state.copyWith(
      isPolicyDeviation: list.isNotEmpty,
      loaderStatus: LoadingStatus.loaded,
    ));
  }

  double calculateLargeExposureLimit(
      Map<String, List<Reference>> referenceData) {
    final List<dynamic> referenceRawList =
        referenceData[ReferenceDataKeys.largeExposureLimit] ?? [];

    final List<Reference> referenceList = referenceRawList.map((dynamic item) {
      if (item is Reference) return item;
      if (item is Map<String, dynamic>) return Reference.fromJson(item);
      throw Exception('Unexpected item type: ${item.runtimeType}');
    }).toList();

    final Reference amountItem = referenceList.firstWhere(
      (Reference item) =>
          item.id == ServerConstants.largeExposureLimitAmountRefId,
      orElse: () => Reference(id: 0, name: '', reference1: '0'),
    );

    final Reference percentageItem = referenceList.firstWhere(
      (Reference item) =>
          item.id == ServerConstants.largeExposureLimitPercentageRefId,
      orElse: () => Reference(id: 0, name: '', reference1: '0'),
    );

    final double amount = double.tryParse(amountItem.reference1 ?? '0') ?? 0.0;
    final double percentage =
        double.tryParse(percentageItem.reference1 ?? '0') ?? 0.0;

    return (amount * percentage) / 100;
  }

  DateTime? getDueDate(dynamic dueDate) {
    try {
      return DateTimeUtils.intToDateTime(dueDate);
    } catch (e) {
      logger.e("Error converting dueDate: $e");
      return DateTime.now(); // fallback
    }
  }

  void onSelectPropsedSicCode(List<Reference> selectedValue) {
    customerInformation?.proposedSICCode = selectedValue.first.name;
    selectedProposedSicCode = (selectedValue.first);
    customerInformation?.industryDescription = selectedValue.first.description;
    customerInformation?.industrySicCode = selectedValue.first.name;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  bool isRimNoEmpty(int? rimNo) {
    return rimNo == null || rimNo.toString().isNotEmpty;
  }
}
