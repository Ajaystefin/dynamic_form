import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/screen_access_conditions.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/draft_handler.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/country.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// View model for the customer information screen.
class CustomerInfoViewModel extends SafeCubit<CustomerInfoState>
    with DraftMixin<CustomerInfoViewModel> {
  /// Creates a customer information view model.
  CustomerInfoViewModel()
      : super(
          CustomerInfoState(
            loaderStatus: LoadingStatus.loading,
            userNameChangeLoader: LoadingStatus.loaded,
          ),
        );

  /// Request repository used to fetch request/application data.
  late RequestRepository repository;

  /// Customer repository used to fetch and save customer information.
  late CustomerRepository repositoryCustomer;

  /// Form key used by customer information form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Build context assigned during initialization.
  BuildContext? context;

  /// Controllers for ownership RIM fields.
  List<TextEditingController> rimControllers = [];

  /// Indicates whether the customer information screen can be edited.
  bool get canEdit {
    if (Globals.request?.applicationSubType == ServerConstants.manualEntry) {
      return true;
    }

    return pageMode == PageMode.edit;
  } // && Utils.canEditApplication();

  final bool _tradeLicensePrefilledOnLoad = false;

  /// Indicates whether trade license was prefilled on initial load.
  bool get isTradeLicensePrefilledOnLoad => _tradeLicensePrefilledOnLoad;

  /// Reference data mapped by reference keys.
  Map<String, List<Reference>> referenceData = {};

  /// Country list used by dropdowns and multi-select fields.
  List<Country>? countries;

  /// Main customer information model.
  Customer? customerInformation;

  /// Ownership information rows for customer.
  List<CustomerOwnerShipInfo>? customerOwnerShipInfo = [];

  /// Exception detail rows for customer.
  List<CustomerException>? customerException = [];

  /// Current page mode for this screen.
  PageMode pageMode = PageMode.na;

  /// Selected country of incorporation.
  Country? selectedCountryOfIncorporate;

  /// Selected IFRS staging reference.
  Reference? selectedIfrsStaging;

  /// Selected proposed SIC code reference.
  Reference? selectedProposedSicCode;

  /// Selected trade licence issuing authority.
  Reference? selectedTlIssuingAuthority;

  /// Selected CCC status.
  Reference? selectedCccStatus;

  /// Customer object used by ownership RIM search.
  Customer? customer;

  /// Currently selected customer.
  Customer? selectedCustomer;

  /// Child customer list used for group applications.
  List<Customer>? customerList = [];

  // ApplicationDetails? applicationDetails;

  /// Total shareholding percentage.
  double totalShareHolding = 0;

  /// Total beneficial ownership percentage.
  double totalBeneficialOwnership = 0;

  /// Proposed SIC code reference values.
  List<Reference>? proposedSICcodes = [];

  /// Indicates whether current business segment is FI.
  bool isFI = false;

  /// FI bank proposed options.
  List<Reference> fiBankProposedOptions = [];

  /// Policy deviation reference values.
  List<Reference> policyDeviation = [];

  /// Customer identification reference values.
  List<Reference> customerIdentificationList = [];

  /// Indicates whether ownership RIM search found a valid customer.
  bool ownershipRimFound = false;

  /// Resident country code.
  String? residentCountryCode;

  /// Indicates whether date validation passed.
  bool isDateValid = true;

  /// Selected FI bank proposed value.
  Reference? selectedFiBankProposedValue;

  /// Ownership checkbox states.
  List<bool> ownershipCheckboxes = [];

  /// Exception type controllers.
  List<TextEditingController> exceptionTypeController = [];

  /// Exception facility controllers.
  List<TextEditingController> exceptionFacilityController = [];

  /// Exception description controllers.
  List<TextEditingController> exceptionDescController = [];

  /// Exception recommendation controllers.
  List<TextEditingController> exceptionRecommController = [];

  /// Indicates whether current request is manual entry.
  bool get isManualEntry {
    return Globals.request?.applicationSubType == ServerConstants.manualEntry;
  }

  /// Indicates whether request has last approved application.
  bool get hasLastApprovedApp =>
      (Globals.request?.lastApprovedAppRefNum ?? "").isNotEmpty;

  /// Indicates whether borrowing relationship field can be edited.
  bool get isBorrowingRelationshipEditable {
    final bool existingEditable = !(!canEdit || hasLastApprovedApp);

    return isManualEntry || existingEditable;
  }

  // ---------------------------------------------------------------------------
  // Trade License No. backend protection
  // ---------------------------------------------------------------------------

  TradeLicenseSource _tradeLicenseSource = TradeLicenseSource.none;

  /// Source of the trade license value.
  TradeLicenseSource get tradeLicenseSource => _tradeLicenseSource;

  CountryOfIncorporateSource _countryOfIncorporateSource =
      CountryOfIncorporateSource.none;

  /// Source of the country of incorporation value.
  CountryOfIncorporateSource get countryOfIncorporateSource =>
      _countryOfIncorporateSource;

  // ---------------------------------------------------------------------------

  // Allow: letters, numbers, space and limited special characters

  /// Formatter that allows free text with limited special characters.
  final TextInputFormatter freeTextFormatter =
      FilteringTextInputFormatter.allow(
    RegExp(r"[a-zA-Z0-9 ,\-./#&']"),
  );

  /// Selected application type reference.
  Reference? selectedApplicationType;

  /// Selected request type reference.
  Reference? selectedRequestType;

  /// Selected business segment reference.
  Reference? selectedBusinessSegment;

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  /// Draft module key for customer information.
  @override
  String get draftModuleKey => DraftModuleKeys.customerInformation;

  /// Draft form key for customer information.
  @override
  String get draftFormKey =>
      "${Routes.customerInformation}_${selectedCustomer?.customerRimNo}";

  /// Draft handler for customer information.
  @override
  DraftHandler<CustomerInfoViewModel> get draftHandler =>
      CustomerInfoDraftHandler();

  // ---------------------------------------------------------------------------

  /// Initializes customer information view model.
  Future<void> init(BuildContext cont) async {
    context = cont;
    logger.i("initialising CustomerInfoViewModel");
    repository = RequestRepository.instance;
    repositoryCustomer = CustomerRepository.instance;
    await repository.getApplicationDetails();
    await AuthRepository.instance
        .updateRole(Globals.user!.currentRole!, request: Globals.request);
    checkApplicationFirstTime();

    selectedApplicationType =
        Globals.request?.applicationType ?? Reference(name: "");
    selectedRequestType = Globals.request?.requestType ?? Reference(name: "");
    selectedBusinessSegment =
        Globals.request?.businessSegment ?? Reference(name: "");
    // for checkup with request type creditRisk
    isFI = Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

    selectedCustomer = getSelectedCustomer();

    try {
      await Future.wait([
        getCountries(),
        loadReferenceData(),
        getChildRimsForGroup(),
        getApplicationDetails(),
      ]);

      if (canEdit) {
        registerDraftCallback();
        // IMPORTANT:
        // Do not load draft here. Draft must be loaded only
        //after backend customer data
        // is fetched inside getCustomerInformation(),
        //otherwise draft can overwrite
        // backend-prefilled Trade License Number.
      }
    } on Object catch (e) {
      if (e.toString().isNotEmpty) {
        AlertManager().showFailureToast(e.toString());
      }
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Determines first-time application access and page mode.
  void checkApplicationFirstTime() {
    final bool isRiskRating =
        Utils.checkApplicationType(ApplicationType.riskRatingChange);

    final bool hasValidRole = Utils.checkRoles([
      UserRole.creditAnalyst,
      UserRole.creditCordinator,
    ]);

    final bool viewOnlyRoles = Utils.checkRoles([
      UserRole.boardDirectorProxy, // BDP
      UserRole.creditCommitteeProxy, // CCP
      UserRole.creditAnalyst, // CA
    ]);

    final bool isEditableStage =
        Globals.applicationDetails?.applicationLifeCycle?.userAction == 0;

    if (Utils.isApprovedApplication() || !Utils.canEditApplication()) {
      pageMode = PageMode.view;
      return;
    }

    if (isRiskRating && hasValidRole) {
      pageMode = isEditableStage ? PageMode.edit : PageMode.view;
      return;
    }

    if (viewOnlyRoles) {
      pageMode = PageMode.view;
      return;
    }

    final ({String userId, String roleName})? assignedUser =
        Utils.getAssignedUserIfNotCurrentUser();
    if (assignedUser != null) {
      pageMode = PageMode.view;
      return;
      // AlertManager().showWarningToast("dashboard.home.assignedToAnotherUserWarning".tr(
      //     namedArgs: { "userId": assignedUser.userId,"roleName": assignedUser.roleName,
      //     },),);
    }

    // fallback to backend
    pageMode = AuthRepository.getPageMode(RightConstants.customerInformation);
  }

  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }

  /// Returns the selected customer based on the group ID in the global request.
  ///
  /// If `groupId` is not zero, it returns the main customer from the request.
  /// Otherwise, it returns the first customer from the `customers` list.
  ///
  /// Returns an empty [Customer] object if the request is null.
  Customer getSelectedCustomer() {
    if (Globals.request == null) {
      return Customer();
    }

    return Customer(
      customerRimNo: Globals.request?.customerRimNo,
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
        ReferenceDataKeys.largeExposureLimit,
        ReferenceDataKeys.customerIdentificationList,
      ]);
      customerIdentificationList =
          referenceData[ReferenceDataKeys.customerIdentificationList] ?? [];
      fiBankProposedOptions = referenceData[ReferenceDataKeys.yesNoNa] ?? [];
      //Policy Deivation
      final List<Reference> policyDeviationRef =
          referenceData[ReferenceDataKeys.policyDeviation] ?? [];
      if (isFI) {
        // FI context (include FI + generic)
        policyDeviation = filterPolicyDeviation(policyDeviationRef, isFI: true);
      } else {
        // Corporate context (exclude FI; include generic and others)
        policyDeviation =
            filterPolicyDeviation(policyDeviationRef, isFI: false);
        // Corporate strict (include ONLY Corporate + generic)
        //policyDeviation = filterPolicyDeviation(policyDeviation,isFI: false,
        //strictCorporate: true);
      }
    } on Object catch (e) {
      //emit(state.copyWith(loaderStatus: LoadingStatus.error));
      logger.i("Error ReferenceData  get: $e");
      rethrow;
    }
  }

  /// Filters policy deviation references based on FI/Corporate context.
  ///
  /// isFI ?? false:
  ///   include: reference1 == "FI" OR generic (null / empty)
  ///
  /// isFI == false (Corporate):
  ///   include: generic and NOT "FI"
  ///   set [strictCorporate] = true to include ONLY "Corporate" + generic
  List<Reference> filterPolicyDeviation(
    List<Reference> items, {
    required bool isFI,
    bool strictCorporate = false,
  }) {
    String norm(String? value) => (value ?? "").trim().toLowerCase();
    return items.where((ref) {
      final String referenceData = norm(ref.reference1);
      if (isFI) {
        // FI view: "fi" or generic
        return referenceData.isEmpty ||
            referenceData == ServerConstants.policyDeviationFI; // "fi";
      } else {
        if (strictCorporate) {
          // Corporate strict: "corporate" or generic
          return referenceData.isEmpty ||
              referenceData ==
                  ServerConstants.policyDeviationCorporate; //"corporate";
        } else {
          // Corporate default: include anything that is NOT "fi" plus generic
          return referenceData.isEmpty ||
              referenceData != ServerConstants.policyDeviationFI; // "fi";
        }
      }
    }).toList();
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
      // applicationDetails = ApplicationDetails(
      //     groupID: Globals.request?.groupId,
      //     groupName: Globals.request?.groupName);
      // await repositoryCustomer.getApplicationDetails();
      await getCustomerInformation(
        customerRimNo: selectedCustomer?.customerRimNo,
      );
      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.loaded,
          userNameChangeLoader: LoadingStatus.loaded,
        ),
      );
    } on Object catch (e) {
      logger.i("Error getApplicationDetails types: $e");
      if (e.toString().isNotEmpty) {
        AlertManager().showFailureToast(e.toString());
      }
      emit(
        state.copyWith(
          loaderStatus: LoadingStatus.loaded,
          userNameChangeLoader: LoadingStatus.loaded,
        ),
      );
    }
  }

  /// Retrieves customer information by rim number. If the customer rim number
  /// is
  /// not provided, it uses the rim number from the application details.
  /// Updates the [customerInformation], [selectedTlIssuingAuthority],
  /// [`selectedCountriesTradedWith`], [`selectedCountriesofBussinessOperation`]
  /// [selectedCccStatus], and [selectedCustomer] properties.
  /// If an error occurs, it updates the loader status to [LoadingStatus.error].
  Future<void> getCustomerInformation({int? customerRimNo}) async {
    try {
      customerInformation =
          await repositoryCustomer.getCustomerInformationByRim(customerRimNo);

      /// Save backend value BEFORE loading draft
      final String serverTradeLicense =
          (customerInformation?.tradeLicenseNumber ?? "").trim();

      /// Save backend value BEFORE loading draft
      final String serverCountryOfIncorporate =
          (customerInformation?.incorporateCountry ?? "").trim();

      /// Load draft only in edit mode
      if (canEdit) {
        await loadDraftIfAvailable();
      }

      /// Value after draft load
      final String currentTradeLicense =
          (customerInformation?.tradeLicenseNumber ?? "").trim();
      final String currentCountryOfIncorporate =
          (customerInformation?.incorporateCountry ?? "").trim();

      /// Final source decision:
      /// 1. If backend had value, backend wins and field becomes readOnly
      /// 2. Else if draft filled it, source = draft and editable
      /// 3. Else no value
      if (serverTradeLicense.isNotEmpty) {
        customerInformation?.tradeLicenseNumber = serverTradeLicense;
        _tradeLicenseSource = TradeLicenseSource.backend;
      } else if (currentTradeLicense.isNotEmpty) {
        _tradeLicenseSource = TradeLicenseSource.draft;
      } else {
        _tradeLicenseSource = TradeLicenseSource.none;
      }

      if (serverCountryOfIncorporate.isNotEmpty) {
        selectedCountryOfIncorporate =
            Country(description: serverCountryOfIncorporate);
        _countryOfIncorporateSource = CountryOfIncorporateSource.backend;
      } else if (currentCountryOfIncorporate.isNotEmpty) {
        selectedCountryOfIncorporate =
            Country(description: currentCountryOfIncorporate);
        _countryOfIncorporateSource = CountryOfIncorporateSource.draft;
      } else {
        _countryOfIncorporateSource = CountryOfIncorporateSource.none;
      }

      if (customerInformation != null) {
        rebuildSelectionStateFromCustomer();

        if (customerInformation?.custInfoId != null) {
          await getCustomerInformationOwnerShip(
            customerRimNo: customerInformation?.custInfoId,
          );
          await getCustomerInformationException(
            customerRimNo: customerInformation?.custInfoId,
          );
        } else {
          customerOwnerShipInfo = [];
          customerException = [];
        }
      }
    } on Object catch (e) {
      logger.i("Error fetching getCustomerInfoByRim : $e");
      rethrow;
    }
  }

  /// Rebuilds selected dropdown and state values from [customerInformation].
  void rebuildSelectionStateFromCustomer() {
    // ---- TL Issuing Authority
    selectedTlIssuingAuthority = null;
    if (customerInformation?.tlIssuingAuthority != null) {
      selectedTlIssuingAuthority =
          Reference(name: customerInformation!.tlIssuingAuthority);
    }

    // ---- CCC Status
    selectedCccStatus = null;
    if (customerInformation?.cccStatus != null) {
      selectedCccStatus = Reference(name: customerInformation!.cccStatus);
    }

    // ---- Proposed SIC Code
    selectedProposedSicCode = null;
    if (customerInformation?.proposedSICCode != null) {
      selectedProposedSicCode =
          Reference(name: customerInformation!.proposedSICCode);
    }

    // ---- IFRS Staging
    selectedIfrsStaging = null;
    if (customerInformation?.ifrsStaging != null) {
      selectedIfrsStaging = Reference(name: customerInformation!.ifrsStaging);
    }

    // ---- Country of Incorporation Staging
    selectedCountryOfIncorporate = null;
    if (customerInformation?.incorporateCountry != null) {
      selectedCountryOfIncorporate =
          Country(description: customerInformation!.incorporateCountry);
    }

    // ---- Derived flags
    final hasPolicyDeviation =
        customerInformation?.policyDeviations?.isNotEmpty ?? false;

    emit(
      state.copyWith(
        // industrySicCode: customerInformation?.industrySicCode,
        industrySicCodeDesc: customerInformation?.industryDescription,
        isPolicyDeviation: hasPolicyDeviation,
      ),
    );

    // ---- Special group handling
    // if (customerInformation?.groupId == 0) {
    //   selectedCustomer = Customer(
    //     firstName: customerInformation?.customerName,
    //     customerName: customerInformation?.customerName,
    //     customerRimNo: customerInformation?.customerRimNo,
    //   );
    // }
  }

  /// Retrieves ownership information for the selected customer.
  Future<void> getCustomerInformationOwnerShip({int? customerRimNo}) async {
    try {
      customerOwnerShipInfo = await repositoryCustomer
              .getCustomerInformationByRimOwnership(customerRimNo) ??
          [];
      if (rimControllers.isNotEmpty) {
        rimControllers.clear();
      }
    } on Object catch (e) {
      // emit(state.copyWith(loaderStatus: LoadingStatus.error));
      logger.i("Error fetching Ownership : $e");
      rethrow;
    }
  }

  /// Retrieves exception information for the selected customer.
  Future<void> getCustomerInformationException({int? customerRimNo}) async {
    try {
      customerException = await repositoryCustomer
          .getCustomerInformationByRimException(customerRimNo);
      initializeControllers(customerException ?? []);
    } on Object catch (e) {
      //emit(state.copyWith(loaderStatus: LoadingStatus.error));
      logger.i("Error fetching Exception : $e");
      rethrow;
    }
  }

  /// Retrieves a list of countries from the server and stores them in the
  /// [countries] property. If the retrieval fails, the loader status is set to
  /// [LoadingStatus.error].
  Future<void> getCountries() async {
    try {
      countries = (await repositoryCustomer.getCountries() ?? [])
        ..sort(
          (firstCountry, secondCountry) => (firstCountry.description ?? "")
              .compareTo(secondCountry.description ?? ""),
        );
    } on Object catch (e) {
      logger.i("Error fetching getCountries : $e");
      rethrow;
    }
  }

  /// Retrieves child RIMs for group application customers.
  Future<void> getChildRimsForGroup() async {
    try {
      if (Utils.isGroupApplication()) {
        customerList = await repositoryCustomer.getChildRimsForGroup() ?? [];
        if ((customerList ?? []).isNotEmpty) {
          selectedCustomer = Customer(
            customerRimNo: Globals.request?.customerRimNo,
          );
        }
      }
    } on Object catch (e) {
      // emit(state.copyWith(loaderStatus: LoadingStatus.error));
      logger.i("Error fetching getChildRimsForGroup : $e");
      rethrow;
    }
  }

  /// Handles selected customer change.
  Future<void> onCustomerSeletion(Customer selectedValue) async {
    selectedCustomer = selectedValue;
    emit(state.copyWith(userNameChangeLoader: LoadingStatus.loading));
    formKey.currentState?.reset();
    await getApplicationDetails();
    emit(state.copyWith(userNameChangeLoader: LoadingStatus.loaded));
  }

  /// Triggers a refresh of the customer information data when the refresh
  /// button
  /// is pressed. Updates the [CustomerInfoState.userNameChangeLoader] status to
  /// [LoadingStatus.loading] while the data is being fetched, and then updates
  /// it
  /// to [LoadingStatus.loaded] when the data is available.
  Future<void> onRefreshButtonPressed(BuildContext context) async {
    if (selectedCustomer != null) {
      await DialogHelper.showCustomDialog(
        context: context,
        title: "customerInformation.customerInformation.confirmation".tr(),
        content: Text(
          "customerInformation.customerInformation.doYouWishToSave".tr(),
        ),
        actions: [
          CustomButton(
            label: "customerInformation.customerInformation.save".tr(),
            onPressed: () async {
              Navigator.pop(context);
              if (selectedCustomer != null) {
                emit(
                  state.copyWith(
                    userNameChangeLoader: LoadingStatus.loading,
                  ),
                );
                selectedCustomer = null;

                formKey.currentState?.reset();
                // Future.delayed(const Duration(milliseconds: 200), () {});
                selectedCustomer = getSelectedCustomer();
                await Future.wait([getApplicationDetails()]);
                emit(
                  state.copyWith(
                    userNameChangeLoader: LoadingStatus.loaded,
                  ),
                );
              }
              // emit(state.copyWith(
              //     userNameChangeLoader: LoadingStatus.empty));
            },
          ),
          const Gap(
            direction: Axis.horizontal,
          ),
          CustomButton(
            label: "customerInformation.customerInformation.cancel".tr(),
            onPressed: () {
              Navigator.pop(context);
              selectedCustomer = null;
              emit(
                state.copyWith(
                  userNameChangeLoader: LoadingStatus.empty,
                ),
              );
            },
          ),
        ],
      );
    }
  }

  /// Updates ownership details by searching for the given RIM number.
  Future<void> updateRimNo(String rimNo, int index) async {
    try {
      // Validate index before proceeding
      if (customerOwnerShipInfo == null ||
          index < 0 ||
          index >= customerOwnerShipInfo!.length) {
        return;
      }

      customer = await repositoryCustomer.searchUserDetailsPartyInqOnly(
        rimNo,
        "",
        "",
        "",
      );

      if (customer == null) {
        //"PartyStatus": "Closed             ",
        throw ApiException(
          "common.noUserFound".tr(),
        );
      }

      if (customer != null) {
        if (customer?.partyStatus.toString().trim() ==
            ServerConstants.partyStatusClosed) {
          throw ApiException(
            "common.noUserFoundClosedPartyStatus".tr(),
          );
        } else {
          final List<Reference> issuedIdentList = customer?.issuedIdent ?? [];

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

          // If NationalID found (name not empty), use it; else fallback to
          // first item
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
              customer?.tLIssueCountry ?? "";
          customerOwnerShipInfo?[index].resident =
              customer?.resident == ServerConstants.residentValue
                  ? ServerConstants.residentYes
                  : ServerConstants.residentNo;
          customerOwnerShipInfo?[index]
            ?..custOwnershipRim = int.tryParse(customer?.id ?? "")
            ..isNewlyAdded = false;

          if (rimControllers.length > index) {
            rimControllers[index].text =
                customerOwnerShipInfo?[index].custOwnershipRim?.toString() ??
                    rimNo;
          }

          emit(state.copyWith(userNameChangeLoader: LoadingStatus.loaded));
          ownershipRimFound = true;
        }
      }
    } on Object {
      //if (rimNo != "0") {
      AlertManager().showFailureToast("common.noUserFound".tr());
      //  }
      customerOwnerShipInfo?[index].shareHoldingPercentage = 0;
      customerOwnerShipInfo?[index].beneficialOwnerhipPercentage = 0;
      customerOwnerShipInfo?[index].identificationDetail = "";
      customerOwnerShipInfo?[index].identificationNumber = "";
      customerOwnerShipInfo?[index].custOwnershipRim = int.tryParse("");
      customerOwnerShipInfo?[index].custOwnershipName = "";
      customerOwnerShipInfo?[index].nationality = "";
      customerOwnerShipInfo?[index].resident = "";

      /// NEW LOGIC
      final CustomerOwnerShipInfo? owner = customerOwnerShipInfo?[index];
      if (owner != null) {
        owner
          ..hasRim = false
          ..hasRimInitialized = true
          ..rim = customerInformation?.custInfoId; //0;
      }

      if (rimControllers.length > index) {
        rimControllers[index].clear();
      }

      emit(state.copyWith(userNameChangeLoader: LoadingStatus.loaded));
      ownershipRimFound = false;
    }

    // logger.i("RIM=${customerOwnerShipInfo?[index].custOwnershipRim}");
    // logger.i("CTRL=${rimControllers[index].text}");
  }

  /// Ensures a RIM controller exists for the given row index.
  void ensureRimController(int index, int? rim, {bool isNew = false}) {
    final text = (!isNew && rim != null && rim > 0) ? rim.toString() : "";

    if (rimControllers.length <= index) {
      rimControllers.add(
        TextEditingController(text: text),
      );
    } else {
      rimControllers[index].text = text;
    }
  }

  /// Adds a new ownership table row.
  void addOwnershipTableRow() {
    customerOwnerShipInfo?.add(
      CustomerOwnerShipInfo(
        rim: customerInformation?.custInfoId, // legacy, untouched
        nationality: "",
        identificationDetail: "",
        custOwnershipName: "",
        identificationNumber: "",
        beneficialOwnerhipPercentage: 0,
        shareHoldingPercentage: 0,
        isNewlyAdded: true,

        // IMPORTANT
        hasRim: true, // default = YES
        hasRimInitialized: true, // lock default
      ),
    );

    ownershipRimFound = false;
    ownershipCheckboxes.add(true);

    // Add a fresh controller for the new row
    rimControllers.add(TextEditingController());

    emit(state.copyWith(userNameChangeLoader: LoadingStatus.loaded));
  }

  /// Removes an ownership table row by index.
  Future<void> removeOwnershipTableRow(int index) async {
    final CustomerOwnerShipInfo? ownership = customerOwnerShipInfo?[index];

    if (ownership == null || selectedCustomer?.customerRimNo == null) {
      emit(state.copyWith(userNameChangeLoader: LoadingStatus.loaded));
      return;
    }

    try {
      if (customerInformation?.custInfoId != null) {
        final int? custOwnershipName = ownership.custOwnId;
        if (custOwnershipName != null ||
            (custOwnershipName!.toString().isNotEmpty ||
                custOwnershipName.toString() != "0")) {
          final String result = await repositoryCustomer.deleteOwnership(
            ownership.custOwnId,
            ownership.rim,
          );
          logger.i("deleteException save: $result");
          AlertManager().showSuccessToast("common.deleteSuccess".tr());
        }
      }
    } on Object catch (e) {
      logger.i(e.toString());
      if (e.toString().isNotEmpty) {
        //"Unexpected null value."
        //AlertManager().showFailureToast(e.toString());
      }
    }

    customerOwnerShipInfo?.removeAt(index);

    if (rimControllers.length > index) {
      rimControllers[index].dispose();
      rimControllers.removeAt(index);
    }

    emit(state.copyWith(userNameChangeLoader: LoadingStatus.loaded));
  }

  /// Updates ownership RIM availability for a row.
  void updateOwnershipRim(int index, {required bool isChecked}) {
    final CustomerOwnerShipInfo? owner = customerOwnerShipInfo?[index];
    if (owner == null) {
      return;
    }

    /// UI state ONLY
    owner
      ..hasRim = isChecked
      ..hasRimInitialized = true
      ..rim = customerInformation?.custInfoId; // isChecked ? 1 : 0;

    /// RULE:
    /// hasRim == false → clear RIM field
    /// hasRim ?? false  → DO NOT clear
    if (!isChecked) {
      if (rimControllers.length > index) {
        rimControllers[index].clear();
      }

      owner.custOwnershipRim = 0;

      ///Clear data ONLY for newly added rows
      if (owner.isNewlyAdded ?? false) {
        if (rimControllers.length > index) {
          rimControllers[index].clear();
        }
        owner
          ..custOwnershipRim = 0
          ..custOwnershipName = ""
          ..nationality = ""
          ..resident = ""
          ..identificationDetail = ""
          ..identificationNumber = "";
      }
    }

    emit(state.copyWith(userNameChangeLoader: LoadingStatus.loaded));
  }

  /// Removes an ownership checkbox by index.
  void removeCheckbox(int index) {
    if (ownershipCheckboxes.length > index) {
      ownershipCheckboxes.removeAt(index);
    }
  }

  /// Validates total shareholding percentage.
  String? shareHoldingPercentageValidator(String? value) {
    if (value == null) {
      return "common.validation.emptyField".tr();
    }
    double totalPercentage = 0;
    for (final CustomerOwnerShipInfo owner in (customerOwnerShipInfo ?? [])) {
      if ((owner.shareHoldingPercentage ?? 0) == 0) {
        return "customerInformation.customerInformation.zeroShareholding".tr();
      }
      totalPercentage += owner.shareHoldingPercentage ?? 0;
    }
    if (totalPercentage == 0) {
      return "common.validation.emptyField".tr();
    }
    if (totalPercentage != 100) {
      return "customerInformation.customerInformation.exceedShareholding".tr();
    }
    return null;
  }

  /// Validates total beneficial ownership percentage.
  String? beneficialOwnerhipPercentageValidator(String? value) {
    if (value == null) {
      return "common.validation.emptyField".tr();
    }
    double totalPercentage = 0;
    for (final CustomerOwnerShipInfo owner in (customerOwnerShipInfo ?? [])) {
      if ((owner.beneficialOwnerhipPercentage ?? 0) == 0) {
        return "customerInformation.customerInformation.zeroOwnership".tr();
      }
      totalPercentage += owner.beneficialOwnerhipPercentage ?? 0;
    }

    if (totalPercentage != 100) {
      return "customerInformation.customerInformation.exceedOwnership".tr();
    }
    return null;
  }

  /// Checks trade licence expiry date alert validation.
  String? checkTlDateAlert(String? value, {bool isSave = false}) {
    if (value == null || value.trim().isEmpty) {
      return null; // No validation for empty/null
    }

    try {
      final String isoDate = DateTimeUtils.convertUIDateToISO(value);
      final DateTime enteredDate = DateTime.parse(isoDate);

      final DateTime today = DateTime.now();
      final DateTime todayDateOnly =
          DateTime(today.year, today.month, today.day);

      if (enteredDate.isBefore(todayDateOnly)) {
        isDateValid = false;
        return "The expiry date cannot be before today's date.";
      }

      isDateValid = true;
      return null; // Valid date
    } on Object {
      isDateValid = false;
      return null; // Ignore invalid format instead of showing error
    }
  }

  /// Saves customer information and optionally navigates to the next route.
  Future<void> onSave({bool ifNavigate = false}) async {
    try {
      if (!formKey.currentState!.validate()) {
        if (!isFI) {
          if (canEdit) {
            final String? shareHolderMessage =
                shareHoldingPercentageValidator("0");
            final String? beneficialOwnerhipMessage =
                beneficialOwnerhipPercentageValidator("0");
            if (shareHolderMessage != null) {
              throw ApiException(
                shareHolderMessage,
              );
            }
            if (beneficialOwnerhipMessage != null) {
              throw ApiException(
                beneficialOwnerhipMessage,
              );
            }
          }
        } else {
          if (canEdit) {
            if ((customerOwnerShipInfo ?? []).isNotEmpty) {
              final String? shareHolderMessage =
                  shareHoldingPercentageValidator("0");
              final String? beneficialOwnerhipMessage =
                  beneficialOwnerhipPercentageValidator("0");
              if (shareHolderMessage != null) {
                throw ApiException(
                  shareHolderMessage,
                );
              }

              if (beneficialOwnerhipMessage != null) {
                throw ApiException(
                  beneficialOwnerhipMessage,
                );
              }
            }
          }
        }
        throw ApiException(
          "customerInformation.customerInformation.requiredFeild".tr(),
        );
      }

      if (!isFI) {
        if (canEdit) {
          if ((customerOwnerShipInfo ?? []).isEmpty) {
            throw ApiException(
              "customerInformation.customerInformation.requiredOwnership".tr(),
            );
          }
          // if (customerInformation?.incorporateCountry?.isEmpty ?? true) {
          //   AlertManager().showFailureToast(
          //     "customerInformation.customerInformation.countryOfIncorporationRequired"
          //         .tr(),
          //   );
          //   return;
          // }
        }
      } else {
        if (canEdit) {
          if ((customerOwnerShipInfo ?? []).isNotEmpty) {
            final String? shareHolderMessage =
                shareHoldingPercentageValidator("0");
            final String? beneficialOwnerhipMessage =
                beneficialOwnerhipPercentageValidator("0");
            if (shareHolderMessage != null) {
              throw ApiException(
                shareHolderMessage,
              );
            }

            if (beneficialOwnerhipMessage != null) {
              throw ApiException(
                beneficialOwnerhipMessage,
              );
            }
          }
        }
      }

      formKey.currentState?.save();

      populateCustomerInformation();

      if (isFI) {
        customerInformation?.businessSegment = selectedBusinessSegment?.name;
      }

      final String? response = await repositoryCustomer.saveUserDetails(
        customerInformation,
        customerOwnerShipInfo,
        customerException,
      );

      if (response == "common.success".tr()) {
        await deleteDraft();
        AlertManager().showSuccessToast("common.saveSuccess".tr());
        if (ifNavigate) {
          LayoutViewModel().goToNextRoute();
        } else {
          emit(state.copyWith(userNameChangeLoader: LoadingStatus.loading));
          //formKey.currentState?.reset();
          // Future.delayed(const Duration(seconds: 1), () {});
          await getApplicationDetails();
        }
      } else {
        AlertManager().showFailureToast("$response");
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Populates derived customer information values before save.
  void populateCustomerInformation() {
    customerInformation?.industryDescription ??= state.industrySicCodeDesc;
    // customerInformation?.industrySicCode ??= state.industrySicCode;
    customerInformation?.addressLine3 = "DUBAI".tr();

    customerInformation?.tlExpiryDateLong =
        convertIsoDateToTimestamp(customerInformation?.tlExpiryDate);
    customerInformation?.relatnStartDateLong =
        convertIsoDateToTimestamp(customerInformation?.relatnStartDate);
    customerInformation?.establishmentDateLong =
        convertIsoDateToTimestamp(customerInformation?.establishmentDate);

    if (customerInformation?.isBorrowerRelationshipDate ?? false) {
      customerInformation?.borrowRelationShipDateLong =
          convertIsoDateToTimestamp(
        customerInformation?.borrowRelationShipDate,
      );
    }

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

  /// Converts ISO date string to timestamp in seconds.
  int convertIsoDateToTimestamp(String? isoDateStr) {
    if (isoDateStr == null) {
      final DateTime now = DateTime.now();
      return now.millisecondsSinceEpoch ~/ 1000;
    } else {
      final DateTime? dateTime = DateTime.tryParse(isoDateStr);
      if (dateTime == null) {
        final DateTime now = DateTime.now();
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

  /// Initialize controllers based on coBorrowers list
  void initializeControllers(List<CustomerException> customerException) {
    exceptionTypeController = List.generate(customerException.length, (index) {
      final val = customerException[index].type ?? "";
      final c = TextEditingController(text: val);
      c.addListener(() {
        customerException[index].type = c.text;
      });
      return c;
    });

    exceptionFacilityController =
        List.generate(customerException.length, (index) {
      final val = customerException[index].facilityId ?? "";
      final c = TextEditingController(text: val);
      c.addListener(() {
        customerException[index].facilityId = c.text;
      });
      return c;
    });

    exceptionDescController = List.generate(customerException.length, (index) {
      final val = customerException[index].description ?? "";
      final c = TextEditingController(text: val);
      c.addListener(() {
        customerException[index].description = c.text;
      });
      return c;
    });

    exceptionRecommController =
        List.generate(customerException.length, (index) {
      final val = customerException[index].recommendations ?? "";
      final c = TextEditingController(text: val);
      c.addListener(() {
        customerException[index].recommendations = c.text;
      });
      return c;
    });
  }

  /// Dispose controllers
  void disposeControllers() {
    for (final TextEditingController controller in exceptionTypeController) {
      controller.dispose();
    }
    for (final TextEditingController controller
        in exceptionFacilityController) {
      controller.dispose();
    }
    for (final TextEditingController controller in exceptionDescController) {
      controller.dispose();
    }
    for (final TextEditingController controller in exceptionRecommController) {
      controller.dispose();
    }
  }

  /// Adds a new exception table row.
  void addExcptionTableRow() {
    // Work with a local copy to avoid null-bang
    final list = customerException ?? [];
    final hasRows = list.isNotEmpty;
    final lastNameFromModel =
        hasRows ? (list.last.description?.trim() ?? "") : "";

    // Allow add if list is empty OR last existing row has a non-empty name
    final canAdd = !hasRows || lastNameFromModel.isNotEmpty;

    if (!canAdd) {
      return; // Don"t add another empty row
    }

    // Add new co-borrower to model and assign back
    final newList = List<CustomerException>.from(list)
      ..add(
        CustomerException(
          type: "",
          facilityId: "",
          description: "",
          recommendations: "",
        ),
      );
    customerException = newList;

    //Add controllers for new row
    exceptionTypeController.add(TextEditingController(text: ""));
    exceptionFacilityController.add(TextEditingController(text: ""));
    exceptionDescController.add(TextEditingController(text: ""));
    exceptionRecommController.add(TextEditingController(text: ""));

    emit(state.copyWith(userNameChangeLoader: LoadingStatus.loaded));
  }

  /// Removes an exception table row by index.
  Future<void> removeExcptionTableRow(int index) async {
    final CustomerException? exception = customerException?[index];

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
            exception.exceptionId,
            exception.custInfoId,
          );
          logger.i("deleteException save: $result");
          AlertManager().showSuccessToast("common.deleteSuccess".tr());
        }
      }
    } on Object catch (e) {
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

  /// Handles FI bank proposed value selection.
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

  /// Validates selected reference against available options.
  String? validateSelection(
    String? value,
    List<Reference> options,
    String errorKey,
  ) {
    final trimmedValue = value?.trim();
    final isValid = options.any((ref) => ref.name == trimmedValue);
    return isValid ? null : errorKey.tr();
  }

  // Reusable method to filter out "NA"

  /// Filters out NA reference option.
  List<Reference> getFilteredOptions(List<Reference> options) {
    return options
        .where((ref) => ref.id != ServerConstants.naRefId)
        //    ref.name != "requestInformation.requestInformation.na".tr())
        .toList();
  }

  // Reusable method to get selected value with fallback

  /// Returns selected reference value with Yes/No fallback.
  Reference getSelectedReference({
    required List<Reference> options,
    required Reference? selectedValue,
    required bool? fallbackFlag,
  }) {
    final filtered = getFilteredOptions(options);

    if (selectedValue != null && filtered.contains(selectedValue)) {
      return selectedValue;
    }

    final fallbackName = fallbackFlag ?? false
        ? "requestInformation.requestInformation.yes".tr()
        : "requestInformation.requestInformation.no".tr();

    return filtered.firstWhere(
      (ref) => ref.name == fallbackName,
      orElse: () => filtered.first,
    );
  }

  /// Called when a country-chip’s delete icon is tapped
  void onCountryChipDeleted(int index) {
    final list = customerInformation?.countryRiskWith;
    if (list == null || index < 0 || index >= list.length) {
      return;
    }

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
    if (list == null || index < 0 || index >= list.length) {
      return;
    }

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
    if (list == null || index < 0 || index >= list.length) {
      return;
    }

    list.removeAt(index);

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Overwrite the entire Country selection (from onSelected) and emit.
  void updateCountriesOfBuisnessOperation(List<Country> selected) {
    customerInformation?.countriesofBussinessOperation = selected;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles policy deviation multi-select changes.
  void onPolicyDeviationSelected(List<Reference> selectedValue) {
    customerInformation?.policyDeviations = selectedValue;
    if (selectedValue.isEmpty) {
      customerInformation?.deviationBreachJustification = "";
    }
    emit(
      state.copyWith(
        isPolicyDeviation: selectedValue.isNotEmpty,
        loaderStatus: LoadingStatus.loaded,
      ),
    );
  }

  /// Called when a country-chip’s delete icon is tapped
  void onPolicyChipDeleted(int index) {
    final list = customerInformation?.policyDeviations;
    if (list == null || index < 0 || index >= list.length) {
      return;
    }

    list.removeAt(index);
    customerInformation?.policyDeviations = list;

    if (list.isEmpty) {
      customerInformation?.deviationBreachJustification = "";
    }

    emit(
      state.copyWith(
        isPolicyDeviation: list.isNotEmpty,
        loaderStatus: LoadingStatus.loaded,
      ),
    );
  }

  /// Calculates large exposure limit amount from reference data.
  double calculateLargeExposureLimit(
    Map<String, List<Reference>> referenceData,
  ) {
    final List<dynamic> referenceRawList =
        referenceData[ReferenceDataKeys.largeExposureLimit] ?? [];

    final List<Reference> referenceList = referenceRawList.map((item) {
      if (item is Reference) {
        return item;
      }
      if (item is Map<String, dynamic>) {
        return Reference.fromJson(item);
      }
      throw ApiException("Unexpected item type: ${item.runtimeType}");
    }).toList();

    // Always use the FIRST item and ignore IDs.
    // columnsInfo = "Amount;Percentage" → reference1=Amount,
    // reference2=Percentage
    // (as per the server contract you shared)
    if (referenceList.isEmpty) {
      return 0;
    }
    final Reference first = referenceList.first;

    // Be forgiving with formatting (e.g., "5,000" or "10%")
    final String amountRaw =
        (first.reference1 ?? "0").replaceAll(",", "").trim();
    final String percentRaw =
        (first.reference2 ?? "0").replaceAll("%", "").trim();

    final double amount = double.tryParse(amountRaw) ?? 0.0;
    final double percentage = double.tryParse(percentRaw) ?? 0.0;

    return (amount * percentage) / 100.0;
  }

  /// Calculates large exposure limit amount value from reference data.
  double calculateLargeExposureLimitAmountValues(
    Map<String, List<Reference>> referenceData,
  ) {
    final List<dynamic> referenceRawList =
        referenceData[ReferenceDataKeys.largeExposureLimit] ?? [];

    final List<Reference> referenceList = referenceRawList.map((item) {
      if (item is Reference) {
        return item;
      }
      if (item is Map<String, dynamic>) {
        return Reference.fromJson(item);
      }
      throw ApiException("Unexpected item type: ${item.runtimeType}");
    }).toList();

    if (referenceList.isEmpty) {
      return 0;
    }
    final Reference first = referenceList.first;
    // Be forgiving with formatting (e.g., "5,000" or "10%")
    final String amountRaw =
        (first.reference1 ?? "0").replaceAll(",", "").trim();
    final double amount = double.tryParse(amountRaw) ?? 0.0;
    return amount;
  }

  /// Calculates large exposure limit percentage value from reference data.
  double calculateLargeExposureLimitPercentageValues(
    Map<String, List<Reference>> referenceData,
  ) {
    final List<dynamic> referenceRawList =
        referenceData[ReferenceDataKeys.largeExposureLimit] ?? [];

    final List<Reference> referenceList = referenceRawList.map((item) {
      if (item is Reference) {
        return item;
      }
      if (item is Map<String, dynamic>) {
        return Reference.fromJson(item);
      }
      throw ApiException("Unexpected item type: ${item.runtimeType}");
    }).toList();

    if (referenceList.isEmpty) {
      return 0;
    }
    final Reference first = referenceList.first;
    // Be forgiving with formatting (e.g., "5,000" or "10%")
    final String percentRaw =
        (first.reference2 ?? "0").replaceAll("%", "").trim();
    final double percentage = double.tryParse(percentRaw) ?? 0.0;
    return percentage;
  }

  /// Converts due date object into [DateTime].
  DateTime? getDueDate(Object? dueDate) {
    try {
      return DateTimeUtils.intToDateTime(dueDate);
    } on Object catch (e) {
      logger.e("Error converting dueDate: $e");
      return DateTime.now(); // fallback
    }
  }

  /// Handles proposed SIC code selection.
  void onSelectPropsedSicCode(List<Reference> selectedValue) {
    customerInformation?.proposedSICCode = selectedValue.first.name;
    selectedProposedSicCode = selectedValue.first;
    customerInformation?.industryDescription = selectedValue.first.description;
    // customerInformation?.industrySicCode = selectedValue.first.name;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Checks whether RIM number is empty.
  bool isRimNoEmpty(int? rimNo) {
    return rimNo == null || rimNo.toString().isNotEmpty;
  }

  /// Checks whether current user has CA/CCP/BDP roles and is assigned user.
  bool otherCACCPBDPRolesCheck() {
    final bool hasValidRole = Utils.checkRoles([
      UserRole.boardDirectorProxy, // BDP
      UserRole.creditCommitteeProxy, // CCP
      UserRole.creditAnalyst, // CA
    ]);
    return hasValidRole && ScreenAccessConditions.isAssignedToCurrentUser();
  }
}

/// Source of trade license value.
enum TradeLicenseSource {
  /// No trade license source.
  none,

  /// Trade license came from backend.
  backend,

  /// Trade license came from draft.
  draft,
}

/// Source of country of incorporation value.
enum CountryOfIncorporateSource {
  /// No country of incorporation source.
  none,

  /// Country of incorporation came from backend.
  backend,

  /// Country of incorporation came from draft.
  draft,
}
