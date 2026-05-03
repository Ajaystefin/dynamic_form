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
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/ccsys_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";

enum ControlFields { customerRim, customerName }

class CcsysCreateRequestViewModel extends SafeCubit<CcsysCreateRequestState> {
  CcsysCreateRequestViewModel()
      : super(CcsysCreateRequestState(loaderStatus: LoadingStatus.loading));
  late CustomerRepository repository;
  late CcsysRepository repositoryCCSYS;
  late Request requestCreate;
  final FocusNode formFocusNode = FocusNode();
  ApplicationDetails? applicationDetails = ApplicationDetails();

  ValueNotifier<Map<ControlFields, bool>> fieldCntrl = ValueNotifier({
    ControlFields.customerName: false,
    ControlFields.customerRim: false,
  });

  bool showError = true;
  String? customerRimNo;
  String? customerName;
  String? branchName;
  String? segmentName;

  bool isRim = true;
  bool isSearched = false;
  bool isFieldsFilled() => customerRimNo != null && customerName != null;
  List<Customer?> dailogCustomers = [];
  List<Customer?> allCustomers = []; // Store all customers for filtering

  ValueNotifier<bool?> selectedButtonModelVN = ValueNotifier(null);
  ValueNotifier<Customer?> selectedCustomer = ValueNotifier(null);

  /// Key for validating the form.

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Loading statuses for different fields.
  LoadingStatus customerRimNoLoadingStatus = LoadingStatus.loaded;
  LoadingStatus customerNameLoadingStatus = LoadingStatus.loaded;

  bool isResetPressed = false;
  List<Customer> customers = [];
  Customer? customer;
  Map<String, List<Reference>> referenceData = {};
  List<Reference> applicationType = [];

  /// Submit button validation logic
  bool submitButtonValidation() => customer == null;

  PageMode pageMode = PageMode.na;
  bool get canEdit => pageMode == PageMode.edit;

  /// Initializes the `CcsysCreateRequestViewModel`.
  ///
  /// This method performs the following actions:
  /// - Logs the initialization process.
  /// - Retrieves the singleton instance of `CustomerRepository`.
  /// - Initializes a new `Request` object for customer creation.
  /// - Loads the list of customers from the global request context, if
  /// available.
  /// - Simulates a delay (2 seconds) to mimic loading or setup time.
  /// - Emits a new state with `LoadingStatus.loaded` to indicate completion.
  ///
  /// This method should be called during the setup phase of the view model,
  /// typically when the associated widget or screen is first built.

  Future<void> init(context) async {
    logger.i("initialising CcsysCreateRequestViewModel");
    Globals.cleanGlobalCache();
    repository = CustomerRepository.instance;
    repositoryCCSYS = CcsysRepository.instance;
    requestCreate = Request();
    customers = Globals.request?.customers ?? [];

    Globals.request ??= Request();
    Globals.request!.requestType ??= Reference();
    Globals.request!.requestSubType ??= Reference();
    Globals.request!.requestType!.reference1 =
        ServerConstants.ccsysAppReference2;
    Globals.request!.requestSubType!.reference1 =
        ServerConstants.ccsysAppReference1;
    await AuthRepository.instance
        .updateRole(Globals.user!.currentRole!, request: Globals.request);
    pageMode = AuthRepository.getPageMode(RightConstants.ccsysCreateRequest);

    await getReferenceDatas();

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> getReferenceDatas() async {
    try {
      referenceData = await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.applicationType,
        ReferenceDataKeys.yesNoNa,
      ]);
      applicationType = referenceData[ReferenceDataKeys.applicationType] ?? [];
    } catch (e) {
      e.toString();
      // emit(state.copyWith(loaderStatus: LoadingStatus.error));
      rethrow;
    }
  }

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
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
    fieldCntrl.value = updatedMap;
  }

  /// Initiates a customer search based on the entered customer name.
  ///
  /// This method checks if the [customerName] is not empty, has not already
  /// been searched,
  /// and is longer than 3 characters. If these conditions are met, it sets the
  /// `customerNameLoadingStatus` to `LoadingStatus.loading` and triggers the
  /// `onCustomerSearchPressed` method to perform the search.
  ///
  /// If the conditions are not met, it displays a failure toast prompting the
  /// user
  /// to enter a valid customer name.
  ///
  /// [showDialog] determines whether a dialog should be shown during the search
  /// process.
  /// Defaults to `true`.

  void onCustomerNameSearchPressed({bool showDialog = true}) {
    if ((customerName ?? "").isNotEmpty &&
        !isSearched &&
        customerName!.length > 3) {
      customerNameLoadingStatus = LoadingStatus.loading;
      onCustomerSearchPressed(showDialog: showDialog, isRim: false);
    } else {
      AlertManager().showFailureToast(
        "requestInformation.createRequest.enterCustomerName".tr(),
      );
    }
  }

  void onSelectionCancelButtonPress() {
    customer = null;
    final updatedMap = <ControlFields, bool>{};
    fieldCntrl.value.forEach((key, _) {
      updatedMap[key] = false;
    });
    fieldCntrl.value = updatedMap;
    customerName = null;
    customerRimNo = null;

    isResetPressed = !isResetPressed;
    isSearched = false;
    customerRimNoLoadingStatus = LoadingStatus.loaded;
    customerNameLoadingStatus = LoadingStatus.loaded;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onSelectionPressed(context, {bool closeDialog = false}) {
    logger.i("requestCreate${selectedCustomer.value}");
    if (selectedCustomer.value == null) {
      AlertManager().showFailureToast("common.selectValue".tr());
    } else {
      customer = selectedCustomer.value;

      if (closeDialog && context.mounted) {
        Navigator.pop(context);
      }
      isSearched = true;
      customerRimNo = "${customer?.customerRimNo}";
      customerName = customer?.displayRIMName ?? "";

      branchName = customer?.branch ?? ServerConstants.defaultBranch;
      segmentName = customer?.segment ?? ServerConstants.defaultSegment;

      debugPrint("customerRimNo $customerRimNo $customerName");
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  void filterCustomers() {
    if (allCustomers.isEmpty) {
      AlertManager().showFailureToast("common.noUserFound".tr());
      return;
    }

    final String searchTerm = (customerName ?? "").toLowerCase();

    if (searchTerm.isEmpty) {
      dailogCustomers = List.from(allCustomers);
    } else {
      dailogCustomers = allCustomers.where((customer) {
        if (customer == null) return false;

        // Filter by customer name
        final String customerNameStr =
            (customer.preferredName ?? "").toLowerCase();
        return customerNameStr.contains(searchTerm);
      }).toList();
    }

    if (dailogCustomers.isEmpty) {
      // AlertManager().showFailureToast("common.noUserFound".tr());
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> onCustomerSearchPressed({
    bool showDialog = true,
    bool isRim = true,
  }) async {
    try {
      // Use Loading here if your UI shows a spinner from this flag.
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));

      dailogCustomers = [];

      if (isRim) {
        // RIM search
        customer = await CcsysRepository()
            .searchUserDetails(customerRimNo ?? "", customerName ?? "");

        if (customer != null) {
          customerRimNo = customer?.id ?? customerRimNo;
          customerName = customer?.customerName ?? customerName;
          branchName = customer?.branch ?? ServerConstants.defaultBranch;
          segmentName = customer?.segment ?? ServerConstants.defaultSegment;

          isSearched = true;
          stopAllLoaders();
          emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
          return;
        }

        // No match — clean exit
        isSearched = false;
        stopAllLoaders();
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        return;
      } else {
        // Name/Group search
        final List<Customer?> resultCustomers =
            await CcsysRepository().searchCustomerProfile(customerName, "", "");

        if (resultCustomers.length == 1) {
          customer = resultCustomers.first;

          customerRimNo = customer?.id ?? customerRimNo;
          customerName = customer?.customerName ?? customerName;
          branchName = customer?.branch ?? ServerConstants.defaultBranch;
          segmentName = customer?.segment ?? ServerConstants.defaultSegment;

          // Ensure lists are set BEFORE you emit
          dailogCustomers = resultCustomers;
          allCustomers = resultCustomers;

          // Stop loaders, then emit showSelectDialog in SAME emit
          stopAllLoaders();
          emit(
            state.copyWith(
              loaderStatus: LoadingStatus.loaded,
              showSelectDialog: showDialog,
            ),
          );
          return;
        }

        if (resultCustomers.isNotEmpty) {
          dailogCustomers = resultCustomers;
          allCustomers = resultCustomers;

          stopAllLoaders();
          emit(
            state.copyWith(
              loaderStatus: LoadingStatus.loaded,
              showSelectDialog: showDialog,
            ),
          );
          return;
        }

        // No matches
        isSearched = false;
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

  /// Resets all individual field loading statuses to 'loaded'
  void stopAllLoaders() {
    isSearched = false;
    customerRimNoLoadingStatus = LoadingStatus.loaded;
    customerNameLoadingStatus = LoadingStatus.loaded;

    // final updatedMap = <ControlFields, bool>{};
    // fieldCntrl.value.forEach((key, _) {
    //   updatedMap[key] = true;
    // });
    // fieldCntrl.value = updatedMap;

    fieldCntrl.value.forEach(
      (key, value) {
        value = true;
      },
    );
    isResetPressed = !isResetPressed;
  }

  /// Resets all form fields and state.
  void onResetButtonPress() {
    formKey.currentState?.reset();
    customerRimNo = null;
    customerName = null;
    isSearched = false;
    customer = null;
    stopAllLoaders();
    selectedCustomer.value = null;
    fieldCntrl = ValueNotifier({
      ControlFields.customerName: false,
      ControlFields.customerRim: false,
    });
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles the submission of the customer request form.
  ///
  /// This method performs the following actions:
  /// - Validates the form using [formKey].
  /// - If the form is valid:
  ///   - Emits a loading state.
  ///   - Populates the [requestCreate] object with the entered customer name
  /// and RIM number.
  ///   - Stores the request in a global variable [Globals.request].
  ///   - Navigates to the next route using [LayoutViewModel] and [router].
  /// - Emits a final state update with `LoadingStatus.loaded` after processing.
  ///
  /// This method is typically triggered when the user presses the submit button

  Future<void> onSubmitButtonPress(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? true)) return;

    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    try {
      final rim = int.tryParse(customerRimNo ?? "");
      if (rim == null) {
        throw "common.invalidRimNo".tr();
      }

      // Provide region/branch from UI or defaults
      // final String segment = customer!.segment ?? "Jumeirah";
      // final String branch = customer!.branch ?? "Al Qouz Branch";

      // Optional +04:00 date if your backend requires it
      // final caDate = "2025-12-12T00:00:00.000+04:00";

      // final appRefNo =
      //     await CcsysRepository.instance.saveApplicationInformation(
      //   region: segment,
      //   branch: branch,
      //   rimNo: rim,
      //   customerName: customerName ?? "",
      //   // caDateIsoPlus4: caDate, // include only if required
      // );

      final Reference appType = applicationType.firstWhere(
        (e) => e.id == ServerConstants.ccsysAppReferenceId,
        orElse: () => Reference(
          id: ServerConstants.ccsysAppReferenceId,
          name: ServerConstants.ccsysAppReferenceName,
          reference1: ServerConstants.ccsysAppReference1,
          reference2: ServerConstants.ccsysAppReference2,
          reference3: ServerConstants.ccsysAppReference3,
          reference4: ServerConstants.ccsysAppReference4,
          reference5: ServerConstants.ccsysAppReference5,
        ),
      );

      // Persist locally if needed

      requestCreate
        ..customerName = customerName
        ..customerRimNo = rim
        ..branch = branchName
        ..region = Globals.user?.regions?.first
        ..applicationType = appType
        ..isCreateRequest = true
        ..businessSegment = Reference(name: segmentName)
        ..enabledForView = false
        ..ccsysCanEditReadOnly = true
        ..ccsysLifeCycleStatus = null
        ..requestType?.reference1 = ServerConstants.ccsysAppReference2
        ..requestSubType?.reference1 = ServerConstants.ccsysAppReference1;

      Globals.request = requestCreate;
      router.go(Routes.ccsysRequestInformation, extra: requestCreate);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      // moveToNext();
    } finally {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Initiates search based on customer RIM number if not already searched
  void onCustomerRimNoSearchPressed() {
    if ((customerRimNo ?? "").isNotEmpty && !isSearched) {
      customerRimNoLoadingStatus = LoadingStatus.loading;
      onCustomerSearchPressed(isRim: true);
    }
  }

  bool otherRolesCheck() {
    return (Utils.checkRoles([
      UserRole.teamLeaderBusiness,
      UserRole.commercialAreaManager,
      UserRole.relationshipManagerBussiness,
      UserRole.segmentHeadBusiness,
    ]))
        ? true
        : false;
  }

  bool otherRolesCheckCC() {
    return (Utils.checkRoles([
      UserRole.ccuChecker,
    ]))
        ? true
        : false;
  }
}
