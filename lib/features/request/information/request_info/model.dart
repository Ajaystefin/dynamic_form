import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/in_pipeline_dialog/view.dart";
import "package:wcas_frontend/features/request/information/request_info/draft_handler.dart";
import "package:wcas_frontend/features/request/information/request_info/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/information/customer_request_info.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// View model responsible for managing the Request Information screen.
///
/// Handles request information data, reference data loading,
/// field validation, draft management, and request-related
/// business logic throughout the request workflow.
class RequestInfoViewModel extends SafeCubit<RequestInfoState>
    with DraftMixin<RequestInfoViewModel> {
  /// Creates a [RequestInfoViewModel] with an initial loading state.
  RequestInfoViewModel()
      : super(
          RequestInfoState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

  /// Repository used for request-related data retrieval,
  /// updates, and persistence operations.
  RequestRepository repository = RequestRepository();

  /// Repository used for customer-related data retrieval
  /// and customer information management.
  CustomerRepository repositoryCustomer = CustomerRepository();

  /// Repository used for shared and common application operations.
  CommonRepository repositoryCommon = CommonRepository();

  /// Focus node used to manage focus within the request
  /// information form.
  FocusNode formFocusNode = FocusNode();

  /// Form key used for validating and managing the state
  /// of the Request Information form.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Rich text editor controller used for the Purpose of
  /// Application content.
  UnifiedEditorController controllerPurpose = UnifiedEditorController();

  /// Rich text editor controller used for detailed request
  /// information and descriptions.
  UnifiedEditorController controllerDetail = UnifiedEditorController();

  /// Rich text editor controller used for capturing ultimate
  /// ownership information.
  UnifiedEditorController controllerUltimate = UnifiedEditorController();

  /// Controller used for the Main Sector/Industry field.
  TextEditingController controllerMainSec = TextEditingController();

  /// Controller used for entering and managing deviation
  /// or breach justification details.
  TextEditingController deviationJustificationController =
      TextEditingController();

  /// Scroll controller used to manage scrolling behavior within
  /// the Request Information screen.
  final ScrollController scrollController =
      ScrollController(keepScrollOffset: false);

  /// Indicates whether the cancellation reason dialog has
  /// already been displayed.
  bool cancellationDialogShown = false;

  /// Indicates whether the In-Pipeline dialog should be shown.
  bool pipelineShown = true;

  /// Request object containing the information maintained
  /// on the Request Information screen.
  Request requestInformation = Request();

  /// Available product type reference values.
  List<Reference> productTypeItems = [];

  /// Available application type reference values.
  List<Reference> applicationType = [];

  /// Available request type reference values.
  List<Reference> requestTypes = [];

  /// Available customer type reference values.
  List<Reference> customerTypes = [];

  /// Application types available for Full CA requests.
  List<Reference> applicationTypesFullCA = [];

  /// Application types available for Isolated Memo requests.
  List<Reference> applicationTypesIsolated = [];

  /// Available restructured or rescheduled reference values.
  List<Reference> restructuredRescheduledItems = [];

  /// Available exposure strategy reference values.
  List<Reference> exposureStrategyItems = [];

  /// Available reason-for-deferral reference values.
  List<Reference> reasonForDeferral = [];

  /// Available TPAN required reference values.
  List<Reference> tpanRequiredItems = [];

  /// Available Sharia approval reference values.
  List<Reference> shariaApprovalItems = [];

  /// Available ERM approval reference values.
  List<Reference> ermApprovalItems = [];

  /// Available ESG reference values.
  List<Reference> esgItems = [];

  /// Available Pricing Committee reference values.
  List<Reference> pricingCommitteeItems = [];

  /// Available interim review date requirement reference values.
  List<Reference> interimReviewDateRequiredItems = [];

  /// Available policy deviation reference values.
  List<Reference> policyDeviationItems = [];

  /// Available cancellation reason reference values.
  List<Reference> cancellationReason = [];

  /// Available reconsideration requests associated with
  /// the current request.
  List<ApplicationDetails>? reconsiderations = [];

  /// Selected product type for the current request.
  Reference? selectedProductType;

  /// Selected TPAN requirement value for the current request.
  Reference? selectedTpanRequired;

  /// Selected Sharia approval value for the current request.
  Reference? selectedShariaApproval;

  /// Selected ERM approval value for the current request.
  Reference? selectedErmApproval;

  /// Selected ESG value for the current request.
  Reference? selectedEsg;

  /// Selected Pricing Committee value for the current request.
  Reference? selectedPricinCommittee;

  /// Selected interim review date requirement value
  /// for the current request.
  Reference? selectedInterimReviewDateRequired;

  /// Selected request type for the current request.
  Reference? selectedRequestType;

  /// Selected business segment associated with the request.
  Reference? selectedBusinessSegment;

  /// Selected application type for the current request.
  Reference? selectedApplicationType;

  /// Selected restructured or rescheduled status for the request.
  Reference? selectedRestructuredRescheduled;

  /// Selected exposure strategy for the current request.
  Reference? selectedExposureStrategy;

  /// Selected deferral reason code for the current request.
  Reference? selectedDeferralCode;

  /// Selected policy deviation value for the current request.
  Reference? selectedPolicyDeviation;

  /// Selected cancellation reason for the current request.
  Reference? selectedCancellationReason;

  /// Selected customer type associated with the request.
  Reference? selectedCustomerType;

  /// Selected reconsideration application details.
  ApplicationDetails? selectedReconsiderations;

  /// Application details maintained for the current request.
  ApplicationDetails? applicationDetails = ApplicationDetails();

  /// Controllers used to manage co-borrower RIM input fields.
  List<TextEditingController> rimControllers = [];

  /// Controllers used to manage co-borrower name input fields.
  List<TextEditingController> nameControllers = [];

  /// Selected reconsideration application reference number.
  String? selectedReconAppReNumber;

  /// Selected reference number of the last approved application.
  String? selectedLastApprovedAppRefNum;

  /// Selected approval date of the last approved application.
  String? selectedLastApprovedDate;

  // Comments

  /// Comment currently being created or edited for the request.
  Comment comment = Comment();

  /// Collection of comments associated with the request.
  List<Comment>? comments = [];

  /// Controls the enabled state of the Save & Continue action.
  ///
  /// A value of `true` indicates that the button is enabled and
  /// available for user interaction.
  ValueNotifier<bool> isSaveContinueButtonEnabled = ValueNotifier(true);

  /// Indicates whether the current request can be edited.
  ///
  /// Requests created through Manual Entry are always editable.
  /// For all other request types, edit access is determined by
  /// the current page mode.
  bool get canEdit {
    if (Globals.request?.applicationSubType == ServerConstants.manualEntry) {
      return true;
    }

    return pageMode == PageMode.edit;
  } // && Utils.canEditApplication();

  /// Indicates whether the current request was created
  /// through the Manual Entry process.
  bool get isManualEntry {
    return Globals.request?.applicationSubType == ServerConstants.manualEntry;
  }

  /// Current mode of the Request Information screen.
  ///
  /// Determines whether the screen is being viewed, created,
  /// or edited.
  PageMode pageMode = PageMode.na;

  /// Indicates whether the current request belongs to the
  /// Financial Institution (FI) segment.
  bool isFI = false;

  /// Indicates whether the current request is a newly created request.
  ///
  /// Defaults to `false`.
  bool isNewRequest = false; //Default false for create request.

  /// Indicates whether an API error has occurred.
  ///
  /// Defaults to `false`.
  bool isApiError = false; //Default false.

  /// Indicates whether the application reference number
  /// already exists.
  ///
  /// Defaults to `false`.
  bool isExisitngAppRefNo = false; //Default false.

  /// Reference data grouped by reference data key.
  Map<String, List<Reference>> referenceData = {};

  /// Pipeline requests associated with the current customer
  /// or request context.
  List<Response> pipelineRequests = [];

  /// Collection of co-borrowers associated with the current request.
  List<CoBorrower>? coBorrowerList = [];

  /// AutoSave related changes by extended team
  /// ---------------------------------------------------------------------------
  /// DraftMixin implementation
  /// ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.requestInformation;

  @override
  String get draftFormKey => Routes.requestInformation;

  @override
  DraftHandler<RequestInfoViewModel> get draftHandler =>
      RequestInfoDraftHandler();

  // ---------------------------------------------------------------------------

  /// Initializes the ViewModel with data from the provided [`requestCreate`]
  /// object.
  ///
  /// This method sets up the repository, controller, and form focus node,
  /// fetches reference and reconsideration data, and displays the pipeline
  /// dialog.
  ///
  /// Emits:
  /// - [LoadingStatus.loaded] when initialization is complete.
  Future<void> init(BuildContext context) async {
    //isSaveContinueButtonEnabled.value = true;
    logger.i("initialising InformationViewModel");

    pageMode = AuthRepository.getPageMode(RightConstants.requestInformation);

    // for checkup with request type creditRisk
    isFI = Utils.checkBusinessSegment(BusinessSegment.financialInstitution);

    //from previous screen
    selectedApplicationType =
        Globals.request?.applicationType ?? Reference(name: "");
    selectedRequestType = Globals.request?.requestType ?? Reference(name: "");
    selectedBusinessSegment =
        Globals.request?.businessSegment ?? Reference(name: "");
    selectedCustomerType = Globals.request?.customerType ?? Reference(name: "");

    //App Type -> markForward
    emit(
      state.copyWith(
        isApplicationTypeMarkForward:
            Utils.checkApplicationType(ApplicationType.markForward),
      ),
    );

    isNewRequest = Globals.request?.isCreateRequest ?? false;

    try {
      await Future.wait([
        getReferenceDatas(),
        getApplicationDetails(),
        getApplicationStrategyDetails(),
        if (Utils.checkApplicationType(ApplicationType.reconsideration))
          getReconsideration(),
        if (isNewRequest) getPipelineRequestDetails(),
      ]);

      final int? deferralId = applicationDetails?.deferralReasonCode;
      selectedDeferralCode = _findReferenceById(reasonForDeferral, deferralId);

      if (!cancellationDialogShown &&
          Utils.checkApplicationType(ApplicationType.cancellation)) {
        cancellationDialogShown = true;

        if (!context.mounted) {
          return;
        }
        showCancellationDialog(context);
      }

      if (!context.mounted) {
        return;
      }
      checkAndShowPipelineDialog(context);

      isApiError = false;
    } on Object catch (e) {
      isApiError = true;
      if (e.toString().isNotEmpty) {
        AlertManager().showFailureToast(e.toString());
      }
    }

    initializeDates(applicationDetails, selectedApplicationType);

    if (!isNewRequest && canEdit) {
      registerDraftCallback();
      await loadDraftIfAvailable();
    }

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Evaluates whether the In-Pipeline dialog should be displayed
  /// for the current request.
  ///
  /// The decision is based on the request type, customer segment,
  /// application type, and the availability of pipeline requests.
  /// When the criteria are met, the In-Pipeline dialog is displayed
  /// and subsequent displays are prevented for the current session.
  void checkAndShowPipelineDialog(BuildContext context) {
    if (!isNewRequest || !pipelineShown || pipelineRequests.isEmpty) {
      return;
    }

    final bool isNewToBank =
        Utils.checkApplicationType(ApplicationType.newToBank);

    bool showDialog;

    if (isFI) {
      // FI logic
      if (isNewToBank) {
        return; // FI + NTB → never show
      }
      showDialog = true; // FI + not NTB → always show
    } else {
      // Non-FI logic
      showDialog = !isNewToBank || pipelineRequests.length > 1;
    }

    if (showDialog) {
      showInPipelineDialog(context);
      pipelineShown = false;
      formFocusNode.requestFocus();
    }
  }

  /// Retrieves and populates application details for the
  /// current request.
  ///
  /// For new requests, the most recently approved application
  /// details are retrieved and initialized with customer-specific
  /// information. For existing requests, the saved application
  /// details are loaded from the backend.
  ///
  /// The retrieved data is used to populate request fields,
  /// reconsideration details, and application reference information.
  Future<void> getApplicationDetails() async {
    try {
      if (isNewRequest) {
        applicationDetails = await repository.getLastApprovedApplication() ??
            ApplicationDetails();
        if (applicationDetails != null) {
          // set the application details from the selected customer
          applicationDetails?.branch = Globals.requestCustomerInfo?.branch;
          applicationDetails?.region = Globals.requestCustomerInfo?.region;
          applicationDetails?.businessSegment =
              Globals.requestCustomerInfo?.segment;
        }
        selectedLastApprovedAppRefNum = applicationDetails?.applicationRefNo;
        selectedLastApprovedDate = applicationDetails?.approvedDate;
      } else {
        applicationDetails = await repository.getApplicationDetails(); // use
        selectedLastApprovedAppRefNum =
            applicationDetails?.lastApprovedAppRefNum;
        selectedLastApprovedDate = applicationDetails?.lastApprovedAppDate;

        isExisitngAppRefNo =
            applicationDetails?.applicationRefNo?.trim().isNotEmpty ?? false;
        Globals.request?.isCreateRequest = false;
        isNewRequest = Globals.request?.isCreateRequest ?? false;
      }

      populateApplicationDetails(applicationDetails ?? ApplicationDetails());

      if (applicationDetails?.reconAppReNumber != null) {
        selectedReconsiderations = ApplicationDetails(
          applicationRefNo: applicationDetails?.reconAppReNumber,
          reconAppReNumber: applicationDetails?.reconAppReNumber,
        );
        selectedReconAppReNumber = applicationDetails?.reconAppReNumber;
      }
    } on Object catch (e) {
      logger.i("Error getApplicationDetails types: $e");
      isApiError = true;
      rethrow;
    }
  }

  /// Fetches reconsideration reference data from the repository.
  ///
  /// Adds the retrieved requests to [reconsiderations].
  ///
  /// Emits:
  /// - [LoadingStatus.error] if the fetch fails.
  Future<void> getReconsideration() async {
    try {
      reconsiderations = await repository.applicationTypeReconsiderationData();
    } on Object {
      rethrow;
      // emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Fetches reference data for application types and customer types.
  ///
  /// Populates the lists:
  /// - [applicationType]
  /// - [applicationTypesFullCA]
  /// - [applicationTypesIsolated]
  /// - [customerTypes]
  ///
  /// Emits:
  /// - [LoadingStatus.error] if the fetch fails.
  Future<void> getReferenceDatas() async {
    try {
      referenceData = await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.applicationType,
        ReferenceDataKeys.yesNoNa,
        ReferenceDataKeys.policyDeviation,
        ReferenceDataKeys.productType,
        ReferenceDataKeys.largeExposureLimit,
        ReferenceDataKeys.restructuredRescheduled,
        ReferenceDataKeys.cancellationReason,
        ReferenceDataKeys.exposureStrategy,
        ReferenceDataKeys.deferralReasonCode,
      ]);
      applicationType = referenceData[ReferenceDataKeys.applicationType] ?? [];
      customerTypes = referenceData[ReferenceDataKeys.customerType] ?? [];
      restructuredRescheduledItems =
          referenceData[ReferenceDataKeys.restructuredRescheduled] ?? [];
      exposureStrategyItems =
          referenceData[ReferenceDataKeys.exposureStrategy] ?? [];
      reasonForDeferral =
          referenceData[ReferenceDataKeys.deferralReasonCode] ?? [];
      cancellationReason =
          referenceData[ReferenceDataKeys.cancellationReason] ?? [];
      productTypeItems = referenceData[ReferenceDataKeys.productType] ?? [];
      assignYesNoNaOptions(referenceData[ReferenceDataKeys.yesNoNa] ?? []);

      //Policy Deivation
      final List<Reference> policyDeviationRef =
          referenceData[ReferenceDataKeys.policyDeviation] ?? [];
      if (isFI) {
        // FI context (include FI + generic)
        policyDeviationItems =
            filterPolicyDeviation(policyDeviationRef, isFI: true);
      } else {
        // Corporate context (exclude FI; include generic and others)
        policyDeviationItems =
            filterPolicyDeviation(policyDeviationRef, isFI: false);
        // Corporate strict (include ONLY Corporate + generic)
        //policyDeviationItems = filterPolicyDeviation(policyDeviation,isFI:
        //false, strictCorporate: true);
      }
    } on Object catch (e) {
      e.toString();
      // emit(state.copyWith(loaderStatus: LoadingStatus.error));
      rethrow;
    }
  }

  /// Assigns the common Yes/No/NA reference options to all
  /// applicable request information fields.
  ///
  /// The provided reference list is reused across TPAN,
  /// Sharia Approval, ERM Approval, ESG, Pricing Committee,
  /// and Interim Review Date Required selections.
  void assignYesNoNaOptions(List<Reference> yesNoNaOptions) {
    tpanRequiredItems = yesNoNaOptions;
    shariaApprovalItems = yesNoNaOptions;
    ermApprovalItems = yesNoNaOptions;
    esgItems = yesNoNaOptions;
    pricingCommitteeItems = yesNoNaOptions;
    interimReviewDateRequiredItems = yesNoNaOptions;
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
            referenceData == ServerConstants.policyDeviationFI; // 'fi';
      } else {
        if (strictCorporate) {
          // Corporate strict: "corporate" or generic
          return referenceData.isEmpty ||
              referenceData ==
                  ServerConstants.policyDeviationCorporate; //'corporate';
        } else {
          // Corporate default: include anything that is NOT "fi" plus generic
          return referenceData.isEmpty ||
              referenceData != ServerConstants.policyDeviationFI; // 'fi';
        }
      }
    }).toList();
  }

  /// Fetches strategy-related comments for the current application.
  ///
  /// This asynchronous method performs the following steps:
  /// 1. Emits a loading state to indicate data retrieval is in progress.
  /// 2. Retrieves all comments of type `securityPerfection` and entity
  /// `securityPerfection`
  ///    from the `CommonRepository`.
  /// 3. Filters the retrieved comments to find those matching the
  /// `securityCategoryID`.
  /// 4. Updates the first comment's `strategyComment` field with the relevant
  /// strategy comment,
  ///    or sets it to an empty string if none are found.
  ///

  Future<void> fetchAndSetStrategyComments({String? appRefNo}) async {
    try {
      comments = await repositoryCommon.getApplicationStrategyDetails(
        CommentsType.requestApplicationDetailed,
        EntityIdentifier.requestApplicationDetailed,
        appReffNo: appRefNo,
      );

      final commentItem = comments
          ?.where(
            (item) =>
                item.categoryId ==
                ServerConstants.requestApplicationInfoCategoryID,
          )
          .toList();

      if (comments != null && comments!.isNotEmpty) {
        comments?[0].strategyComment =
            commentItem != null && commentItem.isNotEmpty
                ? commentItem.last.strategyComment
                : "";
        controllerDetail.setText(comments?[0].strategyComment ?? "");
      }
      if (comments!.isNotEmpty) {
        logger.i("Strategy comment: ${comments?[0].strategyComment}");
      }
    } on Object catch (e) {
      comments = [Comment(strategyComment: "Test")];
      logger.e("Error fetching strategy comments: $e");
    }
  }

  /// Loads strategy-related details for the current application.
  ///
  /// Strategy comments are retrieved only for existing requests.
  /// New requests do not contain previously saved strategy details.
  Future<void> getApplicationStrategyDetails() async {
    if (!isNewRequest) {
      await fetchAndSetStrategyComments();
    }
  }

  /// Updates the selected product type based on the available
  /// conventional and Islamic product indicators.
  ///
  /// Determines the corresponding product type reference and
  /// updates the selected product type in the request information.
  void updateSelectedProductType({bool? conventional, bool? islamic}) {
    // use
    final filteredOptions = getFilteredProductOptions();

    String? targetName;
    if ((conventional ?? false) && (islamic ?? false)) {
      targetName = ServerConstants.productTypeBoth;
      //'requestInformation.requestInformation.both'.tr();
    } else if (conventional ?? false) {
      targetName = ServerConstants.productTypeConventional;
      // 'requestInformation.requestInformation.conventional'.tr();
    } else if (islamic ?? false) {
      targetName = ServerConstants.productTypeIslamic;
      // 'requestInformation.requestInformation.islamic'.tr();
    }

    final selectedRef = filteredOptions.firstWhere(
      (ref) => ref.reference1 == targetName,
      orElse: () => Reference(name: "", reference1: ""),
    );

    // Update the selected product type
    onProductTypeSelected(selectedRef);
  }

  /// Returns a list of application types based on the selected request type.
  ///
  /// If the request type matches isolated or full CA IDs, it returns the
  /// corresponding list.
  /// Otherwise, it returns the default application type list.
  List<Reference> applicationTypeItems() {
    // if (selectedRequestType?.id == ServerConstants.applicationIsolatedId) {
    //   return applicationTypesIsolated;
    // } else if (selectedRequestType?.id ==
    // ServerConstants.applicationFullCAId) {
    //   return applicationTypesFullCA;
    // } else {
    //   return applicationType;
    // }

    if (selectedBusinessSegment?.id ==
        ServerConstants
            .businessSegmentId[BusinessSegment.financialInstitution]) {
      return applicationType
          .where(
            (element) =>
                element.reference4 == selectedRequestType?.reference1 &&
                (element.reference3 ?? "")
                    .contains(ServerConstants.financialCode),
          )
          .toList();
    }
    return applicationType
        .where(
          (element) =>
              element.reference4 == selectedRequestType?.reference1 &&
              (element.reference3 ?? "")
                  .contains(ServerConstants.corperateCode),
        )
        .toList();
  }

  /// Updates the selected application type and resets the cancellation dialog
  /// flag.
  ///
  /// Emits:
  /// - [LoadingStatus.loaded] to refresh the UI.
  void onApplicationTypeSelected(Reference selected) {
    selectedApplicationType = selected;
    cancellationDialogShown = false;
    applicationDetails?.subType = selected.reference1;

    if (isNewRequest &&
        !Utils.checkApplicationType(ApplicationType.newToBank)) {
      controllerPurpose.setText("");
      applicationDetails?.purpose = "";
    }

    emit(
      state.copyWith(
        isApplicationTypeMarkForward:
            Utils.checkApplicationType(ApplicationType.markForward),
        //  selected.id ==
        // ServerConstants.applicationTypeId[ApplicationType.markForward],
      ),
    );
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Sets the selected reconsideration reference value.
  ///
  /// Emits:
  /// - [LoadingStatus.loaded] to refresh the UI.

  Future<void> onReconsiderationSelected(ApplicationDetails selected) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    selectedReconsiderations = ApplicationDetails(
      applicationRefNo: selected.applicationRefNo,
    );
    selectedReconAppReNumber = selected.applicationRefNo;

    populateApplicationDetails(selected);
    initializeDates(selected, selectedApplicationType, isRecon: true);

    // await Future.delayed(const Duration(seconds: 1), () {});
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

    await fetchAndSetStrategyComments(appRefNo: selected.applicationRefNo);
  }

  /// Populates the Request Information screen with the supplied
  /// application details.
  ///
  /// Updates the selected reference values, request attributes,
  /// co-borrower information, editor content, and UI state based
  /// on the retrieved application details.
  void populateApplicationDetails(ApplicationDetails details) {
    applicationDetails = details;

    if (details.rescheduledRestructed != null) {
      selectedRestructuredRescheduled =
          Reference(name: details.rescheduledRestructed);
    }

    if (details.exposureStrategy != null) {
      selectedExposureStrategy = Reference(name: details.exposureStrategy);
    }

    if (details.deferralReasonCode != null) {
      selectedDeferralCode =
          _findReferenceById(reasonForDeferral, details.deferralReasonCode) ??
              Reference(id: details.deferralReasonCode); // temporary fallback
    }
    coBorrowerList = details.customerInformation?.coBorrower ?? [];

    updateSelectedProductType(
      conventional: details.conventional,
      islamic: details.islamic,
    ); // use
    controllerMainSec.text = details.mainSectorIndustry ?? "";

    if (isNewRequest &&
        !Utils.checkApplicationType(ApplicationType.newToBank)) {
      controllerPurpose.setText("");
      applicationDetails?.purpose = "";
    } else {
      controllerPurpose.setText(details.purpose ?? "");
    }
    controllerUltimate.setText(details.ultimateOwnership ?? "");

    emit(
      state.copyWith(
        isInterimReviewDateRequired:
            applicationDetails?.interimReviewDateRequired ?? false,
      ),
    );
    emit(state.copyWith(isTPAN: applicationDetails?.tpanRequired ?? false));
    emit(
      state.copyWith(
        isPolicyDeviation:
            applicationDetails?.policyDeviations?.isNotEmpty ?? false,
      ),
    );

    deviationJustificationController.text =
        applicationDetails?.deviationBreachJustification ?? "";

    if ((selectedApplicationType == null ||
            (selectedApplicationType?.name?.isEmpty ?? false)) &&
        (applicationDetails?.subType?.isNotEmpty ?? false) &&
        (applicationDetails?.requestType?.isNotEmpty ?? false)) {
      selectedApplicationType = applicationType.firstWhere(
        (element) => element.reference1 == applicationDetails?.subType,
        orElse: () => Reference(reference1: applicationDetails?.subType),
      );
      selectedRequestType = requestTypes.firstWhere(
        (element) => element.reference1 == applicationDetails?.requestType,
        orElse: () => Reference(reference1: applicationDetails?.requestType),
      );
      selectedBusinessSegment =
          Reference(name: applicationDetails?.businessSegment);
    }

    if (applicationDetails?.deferralReasonCode != null) {
      selectedCancellationReason = (applicationDetails?.deferralReasonCode != 0)
          ? cancellationReason.firstWhere(
              (element) => element.id == applicationDetails?.deferralReasonCode,
              orElse: () =>
                  Reference(id: applicationDetails?.deferralReasonCode),
            )
          : null;
    }

    initLockPresentReviewDateIfRequired();
  }

  /// Updates the selected product type and synchronizes the
  /// associated application detail flags.
  ///
  /// Configures the Conventional and Islamic indicators based
  /// on the selected product type and refreshes the UI state.
  void onProductTypeSelected(Reference selected) {
    // use check your function
    selectedProductType = selected;
    if (selected.reference1 == ServerConstants.productTypeConventional) {
      applicationDetails?.conventional = true;
      applicationDetails?.islamic = false;
    } else if (selected.reference1 == ServerConstants.productTypeIslamic) {
      applicationDetails?.islamic = true;
      applicationDetails?.conventional = false;
    } else if (selected.reference1 == ServerConstants.productTypeBoth) {
      applicationDetails?.conventional = true;
      applicationDetails?.islamic = true;
    }
    emit(
      state.copyWith(
        isIslamic: selected.reference1 == ServerConstants.productTypeIslamic ||
            selected.reference1 == ServerConstants.productTypeBoth,
      ),
    );
    //  selected.name.toString()
    // =='requestInformation.requestInformation.islamic'.tr()));
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selected TPAN requirement value for the request.
  ///
  /// Sets the TPAN flag in the application details and updates
  /// the corresponding UI state.
  void onTPANTypeSelected(Reference selected) {
    selectedTpanRequired = selected;
    applicationDetails?.tpanRequired =
        (selected.id == ServerConstants.yesRefId);
    emit(state.copyWith(isTPAN: selected.id == ServerConstants.yesRefId));
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Validates the form and processes the request information submission.
  ///
  /// If the form is valid, it populates the [requestInformation] object
  /// with the current form values and logs the result.
  ///
  /// Emits:
  /// - [LoadingStatus.empty] during validation.
  /// - [LoadingStatus.loaded] after validation.
  /// - Re-enables the button if validation fails.

  Future<void> saveContinueButtonPress(
    BuildContext context, {
    bool isCancel = false,
  }) async {
    emit(
      state.copyWith(
        isButtonLoading: false,
        loaderStatus: LoadingStatus.empty,
      ),
    );

    if (canEdit && otherRolesCheck()) {
      // Validate form
      final isValid = formKey.currentState?.validate() ?? false;
      if (!isValid) {
        await handleValidationFailure(
          "requestInformation.requestInformation.requiredFeild".tr(),
        );
        return;
      }
    }

    // Get raw HTML text from controllers
    String? ultimateRawValue = "";
    String? purposeRawValue = "";
    String? detailsRawValue = "";

    if (otherRolesCheck() &&
        !Utils.checkApplicationType(ApplicationType.cancellation)) {
      try {
        if (canEdit || otherRolesCheck()) {
          ultimateRawValue = await getValidatedText(
            controller: controllerUltimate,
            errorKey: "requestInformation.requestInformation.requiredOwnership",
            isRequired: !isFI,
          );

          purposeRawValue = await getValidatedText(
            controller: controllerPurpose,
            errorKey:
                "requestInformation.requestInformation.requiredAppSummary",
            isRequired: true,
          );

          detailsRawValue = await getValidatedText(
            controller: controllerDetail,
            errorKey:
                "requestInformation.requestInformation.requiredAppDetails",
            isRequired: !isFI,
          );
        }

        // =======================
        // NEXT REVIEW DATE HARD VALIDATION (FINAL – CORRECT)
        // =======================
        // Fallback date from CDA (if Present Review Date is not set)
        final DateTime caDate = DateTimeUtils.convertToDate(
          applicationDetails?.cda,
        );

        // Is NTB?
        final bool isNTB =
            Utils.checkApplicationType(ApplicationType.newToBank);

        // Determine source of Present Review Date
        final bool isFromCda = isNTB && state.presentReviewDate == null;

        // Effective Present Review Date
        final DateTime? presentReviewDate =
            isFromCda ? caDate : state.presentReviewDate;

        // Next & expected dates
        final DateTime? nextReviewDate = state.nextReviewDate;
        final DateTime? expectedNextReviewDate = state.defaultNextReviewDate;
        //Run validation ONLY when required values are available
        if (presentReviewDate != null &&
            nextReviewDate != null &&
            expectedNextReviewDate != null) {
          // -----------------------
          // Rule 1:
          // Next Review Date must NOT be before Present Review Date
          // -----------------------
          if (nextReviewDate.isBefore(presentReviewDate)) {
            await handleValidationFailure(
              isFromCda
                  ? "requestInformation.requestInformation.newReviewdateEarlierthanCda"
                      .tr()
                  : "requestInformation.requestInformation.newReviewdateEarlierthan"
                      .tr(),
            );
            return;
          }

          // -----------------------
          // Rule 2:
          // Next Review Date must be AT LEAST 12 months
          // (unless override checkbox is selected)
          // -----------------------
          // if (!(state.overrideDate ?? false)) {
          // if (nextReviewDate.isBefore(expectedNextReviewDate)) {
          //   await handleValidationFailure(
          //     isFromCda
          //         ? "requestInformation.requestInformation.newReviewdateMin12MonthsCda"
          //             .tr()
          //         : "requestInformation.requestInformation.newReviewdateMin12Months"
          //             .tr(),
          //   );
          //   return;
          // }
        }
      } on Object catch (_) {
        return; // validation already handled
      }
    }

    if ((coBorrowerList ?? []).isNotEmpty) {
      for (int i = 0; i < (coBorrowerList ?? []).length; i++) {
        if ((coBorrowerList ?? [])[i].borrowerId == 0) {
          await handleValidationFailure(
            "requestInformation.requestInformation.coborrowerError".tr(),
          );
          return;
        }
      }
    }

    formKey.currentState?.save();

    //Dont remove this for create new its working this way
    final bool isCreateRequest = Globals.request?.isCreateRequest ?? false;
    final bool isCancellation =
        Utils.checkApplicationType(ApplicationType.cancellation);
    final bool isReconsideration =
        Utils.checkApplicationType(ApplicationType.reconsideration);

    final List<Customer> selectedCustomers = getSelectedCustomers();
    final bool isGroupApplication = selectedCustomers.length > 1;

    final String businessMappings =
        buildBusinessSegmentMappings(selectedCustomers);

    try {
      applicationDetails ??= ApplicationDetails();
      applicationDetails
        ?..applicationRefNo =
            isCreateRequest ? null : applicationDetails?.applicationRefNo
        ..instanceId = isCreateRequest ? null : applicationDetails?.instanceId
        ..lastApprovedAppRefNum = selectedLastApprovedAppRefNum
        ..lastApprovedAppDate = selectedLastApprovedDate
        ..approvedDate =
            isCreateRequest ? null : applicationDetails?.approvedDate
        ..appBusinessSegment = Globals.request?.businessSegment?.name ?? ""
        ..ultimateOwnership = ultimateRawValue
        ..purpose = purposeRawValue
        ..instanceId = applicationDetails?.instanceId
        ..groupApplication = isCreateRequest
            ? isGroupApplication
            : applicationDetails?.groupApplication
        ..subType = Globals.request?.applicationType?.reference1 ??
            selectedApplicationType?.reference1 ??
            ""
        ..requestType = Globals.request?.applicationType?.reference3 ??
            selectedRequestType?.reference1 ??
            ""
        ..appTypeReferenceId = selectedApplicationType?.id ?? 0
        ..businessSegment = businessMappings
        ..branch = applicationDetails?.branch ?? ServerConstants.defaultBranch
        ..region = applicationDetails?.region ?? ServerConstants.defaultRegion
        ..borrowers = selectedCustomers
        ..nonBorrowers = Globals.request?.nonBorrowers
        ..rimNo = Globals.request?.customerRimNo
        ..customerName = Globals.request?.customerName
        ..isRightFirstTime = isCreateRequest ? 1 : 0
        ..presentReviewDate = isCheckCancellationAT()
            ? null
            : (state.isPresentReviewDate ?? false)
                ? state.presentReviewDate
                : null
        ..nextReviewDate = isCheckCancellationAT()
            ? null
            : state.nextReviewDate ?? state.defaultNextReviewDate
        ..isOverrideNextReviewDate =
            !isCheckCancellationAT() && (state.overrideDate ?? false)
        ..enabledForView = applicationDetails?.enabledForView ?? false
        ..reconAppReNumber = isReconsideration ? selectedReconAppReNumber : null
        ..customerType = isFI
            ? Globals.request?.customerType?.name ?? selectedCustomerType?.name
            : null
        ..deviationBreachJustification =
            (applicationDetails?.policyDeviations ?? []).isEmpty
                ? ""
                : applicationDetails?.deviationBreachJustification;

      // Update nested customerInformation safely
      applicationDetails?.customerInformation ??=
          ApplicationCustomerInformation(); // Ensure it's not null
      applicationDetails?.customerInformation
        ?..isGroup = Utils.isGroupApplication()
        ..coBorrower = (coBorrowerList?.map(
                  (borrower) => CoBorrower(
                    borrowerId: borrower.borrowerId,
                    customerRimNumber: borrower.customerRimNumber,
                    customerName: borrower.customerName,
                    deleted: borrower.deleted,
                    added: borrower.added ?? true,
                  ),
                ) ??
                [])
            .toList()
        ..groupMappings = groupMappingFilter();

      // logger.i(
      //   "Details: ${applicationDetails?.toString() ?? 'null'}, JSON: ${applicationDetails?.toSaveApplicationJson() ?? 'null'}",
      // );

      if (isCancellation) {
        if (!isCancel && isCreateRequest) {
          final ApplicationCustomerInformation applicationCustomerInformation =
              ApplicationCustomerInformation()
                ..customerRimNumber = Globals.request?.customerRimNo
                ..groupId = Globals.request?.groupId ?? 0
                ..isGroup = isGroupApplication
                ..groupMappings = groupMappingFilter();

          final ApplicationCustomerInformation res = await repository
              .cancelPriorValidation(applicationCustomerInformation);

          if (res.message != "") {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              DialogHelper.showCustomDialog(
                barrierDismissible: false,
                showCloseButton: false,
                width: Scale.scaleHorizontally(350),
                context: context,
                title:
                    "requestInformation.requestInformation.requestConfirmation"
                        .tr(),
                content: Builder(
                  builder: (_) {
                    // Extract keys for line-length compliance
                    const String infoKey =
                        "requestInformation.requestInformation.requestConfirmationMsg";
                    const String infoCancelKey =
                        "requestInformation.requestInformation.requestConfirmationMsgCancel";
                    final String message = res.message?.trim() ?? "";
                    final dynamic amount = res.outstandingAmount ?? 0;
                    String infoMsgKey;
                    if (amount == 0 &&
                        message ==
                            "requestInformation.requestInformation.noOutstandingAmount"
                                .tr()) {
                      infoMsgKey = infoKey.tr();
                    } else {
                      infoMsgKey = "$message $amount ${infoCancelKey.tr()}";
                    }
                    return CustomSelectableText(
                      text: infoMsgKey,
                    );
                  },
                ),
                actions: [
                  if (res.message !=
                      "requestInformation.requestInformation.cancellationCannotBeSharedLimits"
                          .tr())
                    CustomButton(
                      label:
                          "requestInformation.requestInformation.proceed".tr(),
                      onPressed: () {
                        context.pop();
                        saveContinueButtonPress(context, isCancel: true);
                      },
                    ),
                  const Gap(
                    direction: Axis.horizontal,
                  ),
                  CustomButton(
                    label: "requestInformation.requestInformation.cancel".tr(),
                    onPressed: () {
                      context.pop();
                      router.go(Routes.home);
                    },
                  ),
                ],
              );
            });
          }
          return;
        }
      }

      emit(state.copyWith(isButtonLoading: true));
      if (!isNewRequest) {
        unawaited(deleteDraft());
      }
      final String resultAppRefNo =
          await repository.saveApplicationInformation(applicationDetails);

      logger.i(resultAppRefNo);
      if (resultAppRefNo.isNotEmpty) {
        Globals.request?.applicationRefNo = resultAppRefNo;
        Globals.request?.isCreateRequest = false;
        Globals.request?.lastApprovedAppRefNum = selectedLastApprovedAppRefNum;
        emit(state.copyWith(isButtonLoading: false));
        emit(
          state.copyWith(
            isButtonLoading: false,
            loaderStatus: LoadingStatus.loaded,
          ),
        );

        if (context.mounted) {
          showDialogSuccessAppRefNo(
            context,
            appRefNo: resultAppRefNo,
            isNew: isExisitngAppRefNo
                ? null
                : selectedApplicationType?.id !=
                    ServerConstants
                        .applicationTypeId[ApplicationType.cancellation],
          );
        }

        //Lock after first successful save
        lockPresentReviewDateIfRequired();

        if (!isCancellation) {
          detailsRawValue = await getCleanText(controllerDetail);
          comment.strategyComment = detailsRawValue;

          comment = Comment.fromInputData(
            type: CommentsType.requestApplicationDetailed,
            strategyComment: comment.strategyComment,
            entityType: EntityIdentifier.requestApplicationDetailed,
            categoryId: ServerConstants.requestApplicationInfoCategoryID,
            categoryType: ServerConstants.requestApplicationInfoCategoryType,
            strategyCategory:
                ServerConstants.requestApplicationInfoCategoryType,
            id: comment.id,
          );

          final String? result =
              await repositoryCommon.saveApplicationStrategyDetails(
            ServerConstants.requestApplicationInfoStrategyCommentsType,
            ServerConstants.requestApplicationInfoStrategyCommentsId,
            comment,
          );
          logger.i("onSaveButtonPressed: $result");
          unawaited(
            deleteDraft(),
          ); // fire-and-forget: remove backend draft now that data is saved  // AutoSave related changes by extended team
        }
      } else {
        emit(state.copyWith(isButtonLoading: false));
      }
    } on Object catch (e) {
      e.toString();
      if (e.toString().isNotEmpty) {
        await handleValidationFailure(e.toString());
      }
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Returns the customers currently selected for the request.
  ///
  /// For Financial Institution (FI) requests, customers selected
  /// through any supported FI selection criteria are included.
  /// For non-FI requests, only directly selected customers
  /// are returned.
  List<Customer> getSelectedCustomers() {
    final customers = Globals.request?.customers ?? const <Customer>[];

    return customers.where((customer) {
      if (isFI) {
        return (customer.isSelected ?? false) ||
            (customer.isSelectedBelowGrade ?? false) ||
            (customer.isSelectedCountryFI ?? false);
      }
      return customer.isSelected ?? false;
    }).toList();
  }

  /// Builds the business segment mapping value for the
  /// primary customer associated with the request.
  ///
  /// Returns the primary customer's segment when available;
  /// otherwise falls back to the resolved business segment.
  String buildBusinessSegmentMappings(List<Customer> customers) {
    final int? primaryRim = Globals.request?.customerRimNo;
    if (primaryRim == null) {
      return "";
    }
    final Customer primaryCustomer = customers.firstWhere(
      (c) => c.customerRimNo == primaryRim,
      orElse: Customer.new,
    );
    return primaryCustomer.segment?.toString() ?? resolveBusinessSegment();
  }

  /// Resolves the business segment to be used for the request.
  ///
  /// Determines the most appropriate business segment using
  /// available application details, request information,
  /// user profile information, and selected values.
  String resolveBusinessSegment() {
    return isFI
        ? applicationDetails?.businessSegment ??
            Globals.user?.segments?.first ??
            Globals.request?.businessSegment?.name ??
            selectedBusinessSegment?.name ??
            ""
        : applicationDetails?.businessSegment ??
            Globals.request?.businessSegment?.name ??
            Globals.user?.segments?.first ??
            selectedBusinessSegment?.name ??
            "";
  }

  /// Builds the group mapping collection for all selected customers.
  ///
  /// Converts selected customer information into the format
  /// required for request group mapping and identifies the
  /// primary applicant when applicable.
  List<GroupMapping> groupMappingFilter() {
    final customers = Globals.request?.customers ?? const <Customer>[];
    //= getSelectedCustomers();
    final int? primaryRim = Globals.request?.customerRimNo;

    return customers.map((customer) {
      final int rim = customer.customerRimNo ?? 0;

      bool isApplicant;
      if (isFI) {
        isApplicant = (customer.isSelected ?? false) ||
            (customer.isSelectedBelowGrade ?? false) ||
            (customer.isSelectedCountryFI ?? false);
      } else {
        isApplicant = customer.isSelected ?? false;
      }

      return GroupMapping(
        rimNumber: rim,
        name: customer.concatCustomerFullName.trim().isNotEmpty
            ? customer.concatCustomerFullName.trim()
            : "RIM NO $rim",
        isPrimary: primaryRim != null && rim == primaryRim,
        sicCode: customer.proposedSICCode,
        isApplicant: isApplicant,
      );
    }).toList();
  }

  /// Retrieves and validates sanitized editor content.
  ///
  /// Returns the cleaned text from the specified [controller].
  /// If the field is required and no valid content is present,
  /// a validation error is raised and execution is stopped.
  Future<String> getValidatedText({
    required UnifiedEditorController controller,
    required String errorKey,
    required bool isRequired,
  }) async {
    final value = await getCleanText(controller);
    if (value.isEmpty || value == "<br>") {
      if (isRequired) {
        await handleValidationFailure(errorKey.tr());
        throw Exception(errorKey); // stops execution cleanly
      } else {
        return "";
      }
    }
    return value;
  }

  /// Helper to clean HTML tags and spaces
  Future<String> getCleanText(UnifiedEditorController controller) async {
    final rawHtml = await controller.getText();
    return rawHtml;
    // .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
    //     .replaceAll('&nbsp;', ' ') // Handle non-breaking spaces
    //     .replaceAll('\u00A0', ' ') // Replace non-breaking spaces
    //     .trim()
  }

  /// Helper to handle validation failure
  Future<void> handleValidationFailure(String message) async {
    // isSaveContinueButtonEnabled.value = true; // Re-enable button
    AlertManager().showFailureToast(message);
    logger.w(message);
    if (Utils.checkApplicationType(ApplicationType.reconsideration)) {
      await getReconsideration();
    }
    emit(state.copyWith(isButtonLoading: false));
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Displays a dialog with customer information in the pipeline.
  ///
  /// The dialog includes "Proceed" and "Cancel" buttons.
  /// "Cancel" triggers [`onClickCancelCustomerInfoDialog`].
  Future<void> showInPipelineDialog(BuildContext context) async {
    if (context.mounted) {
      await DialogHelper.showCustomDialog(
        barrierDismissible: false,
        title: "requestInformation.requestInformation.inPipelineTitle".tr(),
        content: const SizedBox(child: InPipelineDialogView()),
        context: context,
        actions: [
          CustomButton(
            label: "requestInformation.requestInformation.proceed".tr(),
            onPressed: () async {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          const Gap(
            direction: Axis.horizontal,
          ),
          CustomButton(
            label: "requestInformation.requestInformation.cancel".tr(),
            onPressed: () async {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
              //Router to next page
              router.go(Routes.home);
            },
          ),
        ],
      );
    }
  }

  /// Displays a confirmation dialog for cancellation.
  ///
  /// The dialog contains a message and an "OK" button to dismiss it.
  void showCancellationDialog(BuildContext context) {
    DialogHelper.showCustomDialog(
      actions: [
        CustomButton(
          label: "requestInformation.terminateWithdrawal.cancellation.ok".tr(),
          onPressed: () => context.pop(),
        ),
      ],
      title: "requestInformation.terminateWithdrawal.cancellation.confirmation"
          .tr(),
      content: CustomSelectableText(
        text: "requestInformation.terminateWithdrawal."
                "cancellation.cancellationMsg"
            .tr(),
      ),
      context: context,
    );
  }

  /// Updates the selected Sharia approval value for the request.
  ///
  /// Synchronizes the selected reference and updates the
  /// corresponding Sharia approval flag in the application details.
  void onShariaApprovalSelected(Reference selected) {
    selectedShariaApproval = selected;
    applicationDetails?.shariaApproval =
        (selected.id == ServerConstants.yesRefId);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selected ERM approval value for the request.
  ///
  /// Synchronizes the selected reference and updates the
  /// corresponding ERM approval flag in the application details.
  void onErmApprovalSelected(Reference selected) {
    selectedErmApproval = selected;
    applicationDetails?.ermApproval = (selected.id == ServerConstants.yesRefId);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selected ESG value for the request.
  ///
  /// Synchronizes the selected reference and updates the
  /// corresponding ESG approval flag in the application details.
  void onEsgSelected(Reference selected) {
    selectedEsg = selected;
    applicationDetails?.esgApproval = (selected.id == ServerConstants.yesRefId);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selected Pricing Committee value for the request.
  ///
  /// Synchronizes the selected reference and updates the
  /// corresponding Pricing Committee approval flag in the
  /// application details.
  void onPricingCommitteeSelected(Reference selected) {
    selectedPricinCommittee = selected;
    applicationDetails?.pricingCommitteApproval =
        (selected.id == ServerConstants.yesRefId);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selected restructured or rescheduled status
  /// for the request.
  void onRestructuredRescheduledSelected(Reference selected) {
    selectedRestructuredRescheduled = selected;
    applicationDetails?.rescheduledRestructed = selected.name;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the interim review date requirement for the request.
  ///
  /// Synchronizes the selected value, updates the application
  /// details, and refreshes the related UI state.
  void onInterimReviewDateRequiredSelected(Reference selected) {
    selectedInterimReviewDateRequired = selected;
    applicationDetails?.interimReviewDateRequired =
        (selected.id == ServerConstants.yesRefId);
    emit(
      state.copyWith(
        isInterimReviewDateRequired: selected.id == ServerConstants.yesRefId,
      ),
    );
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selected exposure strategy for the request.
  void onExposureStrategySelected(Reference selected) {
    selectedExposureStrategy = selected;
    applicationDetails?.exposureStrategy = selected.name;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates the selected reason for deferral.
  ///
  /// Stores the selected deferral reason code in the
  /// application details.
  void onReasonForDeferralSelected(Reference selected) {
    selectedDeferralCode = selected;
    applicationDetails?.deferralReasonCode = selected.id;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Reference? _findReferenceById(List<Reference> list, int? id) {
    if (id == null) {
      return null;
    }
    final int i = list.indexWhere((r) => r.id == id);
    return (i == -1) ? null : list[i];
  }

  /// Updates the selected policy deviations for the request.
  ///
  /// When all policy deviations are removed, any previously
  /// entered deviation justification is also cleared.
  void onPolicyDeviationSelected(List<Reference> selectedValue) {
    applicationDetails?.policyDeviations = selectedValue;
    if (selectedValue.isEmpty) {
      applicationDetails?.deviationBreachJustification = "";
      deviationJustificationController.clear(); // THIS FIXES IT
    }
    emit(
      state.copyWith(
        isPolicyDeviation: selectedValue.isNotEmpty,
        loaderStatus: LoadingStatus.loaded,
      ),
    );
  }

  /// Updates the selected cancellation reason for the request.
  void onCancellationSelected(Reference selected) {
    selectedCancellationReason = selected;
    applicationDetails?.deferralReasonCode = selected.id;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Checkbox toggles

  /// Updates the override next review date indicator.
  ///
  /// Controls whether the request should use an overridden
  /// next review date.
  void overrideSelected({bool? isChecked}) {
    applicationDetails?.isOverrideNextReviewDate = isChecked;
    emit(state.copyWith(overrideDate: isChecked ?? false));
  }

  /// Initialize controllers based on coBorrowers list
  void initializeControllers(List<CoBorrower> coBorrowers) {
    rimControllers = List.generate(coBorrowers.length, (index) {
      final rimValue = coBorrowers[index].customerRimNumber ?? "";
      return TextEditingController(text: rimValue.toString());
    });

    nameControllers = List.generate(coBorrowers.length, (index) {
      final nameValue = coBorrowers[index].customerName ?? "";
      return TextEditingController(text: nameValue);
    });
  }

  /// Update RIM No and Customer Name from API
  Future<void> updateRimNo(String rimNo, int index) async {
    try {
      final Customer? customer = await repositoryCustomer
          .searchUserDetailsPartyInqOnly(rimNo, "", "", "");
      if (customer == null) {
        //"PartyStatus": "Closed             ",
        throw ApiException("common.noUserFound".tr());
      }

      if (customer.partyStatus.toString().trim() ==
          ServerConstants.partyStatusClosed) {
        throw ApiException("common.noUserFoundClosedPartyStatus".tr());
      }

      // Update model
      coBorrowerList?[index].borrowerId = int.tryParse(customer.id ?? "");
      coBorrowerList?[index].customerRimNumber =
          int.tryParse(customer.id ?? "");
      coBorrowerList?[index].customerName = customer.displayRIMName ?? "";

      //Update controllers so UI reflects new value
      if (index < nameControllers.length) {
        nameControllers[index].text = customer.displayRIMName ?? "";
      }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      logger.i("Error updating RIM No: $e");
      // rethrow;
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Dispose controllers
  void disposeControllers() {
    for (final TextEditingController controller in rimControllers) {
      controller.dispose();
    }
    for (final TextEditingController controller in nameControllers) {
      controller.dispose();
    }
  }

  /// Adds a new co-borrower row to the request.
  ///
  /// A new row is added only when there are no existing rows or
  /// the last row already contains borrower information. This
  /// prevents multiple empty co-borrower rows from being created.
  ///
  /// The method also initializes the corresponding controllers
  /// and refreshes the screen state.
  void addCoBorrowerRow() {
    /// Work with a local copy to avoid null-bang
    final List<CoBorrower> list = coBorrowerList ?? [];

    final bool hasRows = list.isNotEmpty;
    final String lastNameFromController =
        nameControllers.isNotEmpty ? nameControllers.last.text.trim() : "";
    final String lastNameFromModel =
        hasRows ? (list.last.customerName?.trim() ?? "") : "";

    /// Allow add if list is empty OR last existing row has a non-empty name
    final bool canAdd = !hasRows ||
        lastNameFromController.isNotEmpty ||
        lastNameFromModel.isNotEmpty;

    if (!canAdd) {
      return; // Don't add another empty row
    }

    // Add new co-borrower to model and assign back
    final List<CoBorrower> newList = List<CoBorrower>.from(list)
      ..add(
        CoBorrower(
          borrowerId: 0,
          customerName: "",
          customerRimNumber: 0,
        ),
      );
    coBorrowerList = newList;

    //Add controllers for new row
    rimControllers.add(TextEditingController(text: ""));
    nameControllers.add(TextEditingController(text: ""));

    //Sync back to applicationDetails
    // applicationDetails?.customerInformation?.coBorrower = borrowerList;

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Removes the co-borrower row at the specified [index].
  ///
  /// The associated model entry and text controllers are removed
  /// together to keep the co-borrower data and UI state synchronized.
  void removeCoBorrowerRow(int index) {
    if (coBorrowerList != null &&
        index >= 0 &&
        index < coBorrowerList!.length) {
      // Remove from model
      coBorrowerList!.removeAt(index);

      //Remove controllers safely
      if (index < rimControllers.length) {
        rimControllers.removeAt(index);
      }
      if (index < nameControllers.length) {
        nameControllers.removeAt(index);
      }

      //Sync back to applicationDetails
      // applicationDetails?.customerInformation?.coBorrower = borrowerList;

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Called when a country-chip’s delete icon is tapped
  void onPolicyChipDeleted(int index) {
    final list = applicationDetails?.policyDeviations;
    if (list == null || index < 0 || index >= list.length) {
      return;
    }

    // Remove the item at the given index
    list.removeAt(index);
    applicationDetails?.policyDeviations = list;

    if (list.isEmpty) {
      applicationDetails?.deviationBreachJustification = "";
      deviationJustificationController.clear(); //REQUIRED
    }

    emit(
      state.copyWith(
        isPolicyDeviation: list.isNotEmpty,
        loaderStatus: LoadingStatus.loaded,
      ),
    );
  }

  /// REUSABLE METHODS
  /// Reusable method to Validator
  String? validateSelection(
    String? value,
    List<Reference> options,
    String errorKey,
  ) {
    final trimmedValue = value?.trim();
    final isValid = options.any((ref) => ref.name == trimmedValue);
    return isValid ? null : errorKey.tr();
  }

  /// Returns the available reference options excluding the
  /// "Not Applicable" value.
  ///
  /// Used to restrict selections to meaningful business values.
  List<Reference> getFilteredOptions(List<Reference> options) {
    return options
        .where(
          (ref) => ref.name != "requestInformation.requestInformation.na".tr(),
        )
        .toList();
  }

  // Reusable method to get selected value with fallback => Product Type Logics

  /// Returns the selected reference value or a fallback option
  /// when no valid selection exists.
  ///
  /// The fallback value is determined by [fallbackFlag]. If no
  /// matching fallback is found, the first available option is used.
  Reference getSelectedReference({
    required List<Reference> options,
    required Reference? selectedValue,
    required bool? fallbackFlag,
  }) {
    final filtered = getFilteredOptions(options);

    if (selectedValue != null && filtered.contains(selectedValue)) {
      return selectedValue;
    }

    if (filtered.isEmpty) {
      return Reference(name: "requestInformation.requestInformation.no".tr());
    }

    final fallbackName = fallbackFlag ?? false
        ? "requestInformation.requestInformation.yes".tr()
        : "requestInformation.requestInformation.no".tr();

    return filtered.firstWhere(
      (ref) => ref.name == fallbackName,
      orElse: () => filtered.first,
    );
  }

  // Filters out 'NA' from the options

  /// Returns the product type options applicable to the current
  /// business segment.
  ///
  /// Product types are filtered based on whether the request
  /// belongs to the Financial Institution (FI) segment or the
  /// Corporate segment.
  List<Reference> getFilteredProductOptions() {
    return productTypeItems.where((ref) {
      final values = ref.reference2?.toLowerCase().split(",") ?? [];

      return isFI
          ? values.contains(ServerConstants.policyDeviationFI) // "fi"
          : values.contains(ServerConstants.policyDeviationCorporateC); // "c"
    }).toList();
  }

  // Returns selected product or fallback

  /// Returns the selected product type or a fallback value when
  /// no valid selection exists.
  ///
  /// When [showSelectAsDefault] is `true`, the default fallback
  /// is the "Both" product type. Otherwise, the first available
  /// filtered product type is returned.
  Reference getSelectedProductReference({
    Reference? selectedValue,
    bool showSelectAsDefault = false,
  }) {
    final filtered = getFilteredProductOptions();

    if (selectedValue != null && filtered.contains(selectedValue)) {
      return selectedValue;
    }

    if (showSelectAsDefault) {
      return Reference(name: "requestInformation.requestInformation.both".tr());
    }

    return filtered.isNotEmpty ? filtered.first : Reference(name: "");
  }

  // Validator for product type selection

  /// Validates the selected product type against the list of
  /// supported product type options.
  ///
  /// Returns `null` when the selection is valid; otherwise
  /// returns the appropriate validation message.
  String? validateProductTypeSelection(Reference? value) {
    final isValid = getFilteredProductOptions().contains(value);
    return isValid
        ? null
        : "requestInformation.requestInformation.selectProductType".tr();
  }

  /// Calculates the Large Exposure Limit amount based on the
  /// configured amount and percentage reference values.
  ///
  /// Returns the calculated exposure limit value. Returns `0`
  /// when reference data is unavailable or invalid.
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

  /// Returns the configured Large Exposure Limit amount value.
  ///
  /// The amount is retrieved from the large exposure limit
  /// reference data.
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

  /// Returns the configured Large Exposure Limit percentage value.
  ///
  /// The percentage is retrieved from the large exposure limit
  /// reference data.
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

  /// Retrieves pipeline request details associated with the
  /// current customer or request context.
  Future<void> getPipelineRequestDetails() async {
    try {
      pipelineRequests = (await repository.getPipelineRequestDetails()) ?? [];
    } on Object catch (e) {
      logger.e("Error getting reference data types: $e");
    }
  }

  /// Initializes request review dates and related workflow dates.
  ///
  /// Default review dates are derived from the application type,
  /// reconsideration status, and available application details.
  ///
  /// When [isRecon] is `true`, reconsideration-specific date
  /// handling is applied.
  void initializeDates(
    ApplicationDetails? details,
    Reference? appType, {
    bool isRecon = false,
  }) {
    final applicationDate = DateTime.now();
    DateTime? presentReviewDate;
    DateTime defaultPresentReviewDate;
    DateTime defaultNextReviewDate;

    final isNewToBank = Utils.checkApplicationType(ApplicationType.newToBank);
    final isReconsideration =
        Utils.checkApplicationType(ApplicationType.reconsideration);

    if (isNewToBank) {
      // For New to Bank applications
      // presentReviewDate = applicationDate; no need to save current date
      defaultPresentReviewDate = DateTime(
        (presentReviewDate ?? applicationDate).year,
        (presentReviewDate ?? applicationDate).month + 11,
        0,
      );
      defaultNextReviewDate = DateTime(
        (presentReviewDate ?? applicationDate).year,
        (presentReviewDate ?? applicationDate).month + 13,
        0,
      );
    } else {
      // For other applications
      if (isRecon && isReconsideration) {
        presentReviewDate = details?.nextReviewDate;
      } else {
        presentReviewDate = details?.presentReviewDate;
      }

      defaultPresentReviewDate = DateTime(
        (presentReviewDate ?? applicationDate).year,
        (presentReviewDate ?? applicationDate).month + 11,
        0,
      );
      defaultNextReviewDate = DateTime(
        (presentReviewDate ?? applicationDate).year,
        (presentReviewDate ?? applicationDate).month + 13,
        0,
      );
    }

    // Pick the anchor date for nextReviewDate, depending on request type.
    DateTime? nextReviewDateAnchor;
    if (!isNewRequest) {
      // Existing request: use its own previously-saved nextReviewDate.
      nextReviewDateAnchor = details?.nextReviewDate;
    } else if (state.isApplicationTypeMarkForward) {
      // New mark-forward request: `details` is already the customer's last
      // approved application (fetched in getApplicationDetails), so use its
      // nextReviewDate. If none was found, fall back to the computed default.
      nextReviewDateAnchor = details?.nextReviewDate ?? defaultNextReviewDate;
    } else {
      // New, non-mark-forward request: use the computed default.
      nextReviewDateAnchor = defaultNextReviewDate;
    }

    // Normalize to a date-only value in local time (matches existing behavior).
    final DateTime? nextReviewDateValue = nextReviewDateAnchor == null
        ? null
        : DateTime(
            nextReviewDateAnchor.toLocal().year,
            nextReviewDateAnchor.toLocal().month,
            nextReviewDateAnchor.toLocal().day,
          );

    emit(
      state.copyWith(
        isPresentReviewDate: details?.presentReviewDate != null,
        presentReviewDate: isNewRequest
            ? presentReviewDate
            : details?.presentReviewDate, //?? defaultPresentReviewDate,
        defaultNextReviewDate: defaultNextReviewDate,
        defaultPresentReviewDate: defaultPresentReviewDate,
        nextReviewDate: nextReviewDateValue,
        markForwardDate: isNewRequest ? null : details?.markForwardDate,
      ),
    );
  }

  /// Validates and updates the next review date.
  ///
  /// Ensures that:
  /// - The next review date is not earlier than the present review date.
  /// - The next review date does not exceed the permitted review period
  ///   unless override approval is enabled.
  ///
  /// Returns `true` when the selected date is accepted; otherwise
  /// returns `false`.
  bool validateAndSetNextReviewDate(DateTime? selectedDate) {
    if (selectedDate == null) {
      updateNextReviewDate(selectedDate);
      return true;
    }

    final present = state.presentReviewDate ?? DateTime.now();

    // Normalize dates (remove time)
    final DateTime normalizedPresent =
        DateTime(present.year, present.month, present.day);
    final normalizedNext = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    //Rule 1: Must not be before present review date
    if (normalizedNext.isBefore(normalizedPresent)) {
      AlertManager().showWarningToast(
        "requestInformation.requestInformation.newReviewdateEarlierthan".tr(),
      );
      updateNextReviewDate(selectedDate);
      return false;
    }

    // Rule 2: Calculate max allowed date (Present + 12 months, end of month)
    final DateTime maxDate = DateTime(
      normalizedPresent.year,
      normalizedPresent.month + 12 + 1, // next month
      0, // day 0 = last day of previous month
    );

    // Rule 3: If beyond 12 months
    if (normalizedNext.isAfter(maxDate)) {
      if (state.overrideDate ?? false) {
        // Override allowed → show warning but ACCEPT
        AlertManager().showWarningToast(
          "requestInformation.requestInformation.newReviewdateGreaterthan".tr(),
        );

        updateNextReviewDate(selectedDate);
        return true; //IMPORTANT: allow override
      } else {
        // No override → reject
        AlertManager().showWarningToast(
          "requestInformation.requestInformation.newReviewdateInvalid".tr(),
        );

        updateNextReviewDate(selectedDate);
        return false;
      }
    }

    // Valid case
    updateNextReviewDate(selectedDate);
    return true;
  }

  /// Validates and updates the mark forward date.
  ///
  /// Ensures that the selected date is after the next review date
  /// and within the permitted mark-forward period.
  ///
  /// Returns `true` when the selected date is valid; otherwise
  /// returns `false`.
  bool validateAndSetMarkForwardDate(DateTime? selectedDate) {
    if (selectedDate == null) {
      updateMarkForwardDate(selectedDate);
      return true;
    }

    if (selectedDate.isBefore(state.nextReviewDate!)) {
      AlertManager().showWarningToast(
        "requestInformation.requestInformation.markfwddateEarlierthan".tr(),
      );
      return false;
    }

    final threeMonthsLater = DateTime(
      state.nextReviewDate!.year,
      state.nextReviewDate!.month + 3,
      state.nextReviewDate!.day,
    );
    if (selectedDate.isAfter(threeMonthsLater)) {
      AlertManager().showWarningToast(
        "requestInformation.requestInformation.markfwddateGreaterthan".tr(),
      );
      // Warning only, allow user to continue: still commit the selected date
      // so it is saved to the API instead of being dropped as null.
      updateMarkForwardDate(selectedDate);
      return true;
    }

    updateMarkForwardDate(selectedDate);
    return true;
  }

  /// Updates the next review date in the application details
  /// and refreshes the UI state.
  void updateNextReviewDate(DateTime? date) {
    applicationDetails?.nextReviewDate = date;
    emit(state.copyWith(nextReviewDate: date));
  }

  /// Updates the mark forward date in the application details
  /// and refreshes the UI state.
  void updateMarkForwardDate(DateTime? date) {
    applicationDetails?.markForwardDate = date;
    emit(state.copyWith(markForwardDate: date));
  }

  /// Determines whether Present Review Date is editable.
  ///
  /// Rules:
  /// - Must be in edit mode
  /// - Must have correct role
  /// - NTB first request:
  ///     - Editable until first successful save
  ///     - Locked afterwards
  /// - All other cases: always editable
  bool canEditPresentReviewDate() {
    // Base guards
    if (!canEdit) {
      return false;
    }
    if (!otherRolesCheck()) {
      return false;
    }

    final bool isNTB = Utils.checkApplicationType(ApplicationType.newToBank);

    final bool isNTBFirstRequest = isNTB && isNewRequest;

    final bool hasSavedPresentReviewDate =
        applicationDetails?.presentReviewDate != null;

    final String? autoSave = applicationDetails?.isAutoSave;

    final bool isAutoSave = autoSave == null ||
        autoSave.isEmpty ||
        autoSave == "1" ||
        autoSave == "2";

    //If need enable for CA role in Present Review Date
    // if (canEdit) {
    //   if (Utils.checkRoles([
    //     UserRole.creditAnalyst, //"CA"
    //   ])) {
    //     if (!hasSavedPresentReviewDate) {
    //       return !state.isPresentReviewDateLocked;
    //     }
    //   }
    // } else {
    //   if (Utils.checkRoles([
    //     UserRole.creditAnalyst, //"CA"
    //   ])) {
    //     if (!hasSavedPresentReviewDate) {
    //       return !state.isPresentReviewDateLocked;
    //     }
    //   } else {
    //     return false;
    //   }
    // }

    // NTB – first request: lock explicitly
    if (isNTBFirstRequest) {
      return !state.isPresentReviewDateLocked;
    }

    // New request (non‑NTB)
    if (isNewRequest) {
      if (!hasSavedPresentReviewDate) {
        return !state.isPresentReviewDateLocked;
      }
    }

    // Existing request
    if (hasSavedPresentReviewDate) {
      return isAutoSave;
    }

    // Default allow
    return true;
  }

  /// Locks the Present Review Date field when required by
  /// the request type and creation scenario.
  ///
  /// The Present Review Date is locked for newly created
  /// New-to-Bank (NTB) requests to prevent manual modification
  /// of the system-defined review date.
  void lockPresentReviewDateIfRequired() {
    final bool isNTBFirstRequest =
        Utils.checkApplicationType(ApplicationType.newToBank) && isNewRequest;

    if (isNTBFirstRequest) {
      emit(state.copyWith(isPresentReviewDateLocked: true));
    }
  }

  /// Initializes the lock state for Present Review Date.
  ///
  /// This ensures that for NTB first requests,
  /// the field is locked if the date was already saved earlier
  /// (e.g., screen reload, draft load, revisit).
  void initLockPresentReviewDateIfRequired() {
    final bool isNTBFirstRequest =
        Utils.checkApplicationType(ApplicationType.newToBank) && isNewRequest;

    final bool hasSavedPresentReviewDate =
        applicationDetails?.presentReviewDate != null;

    if (isNTBFirstRequest && hasSavedPresentReviewDate) {
      emit(state.copyWith(isPresentReviewDateLocked: true));
    }
  }

  /// Validates and updates the Present Review Date for the request.
  ///
  /// Recalculates the default review dates based on the selected
  /// Present Review Date, application type, and reconsideration
  /// status. The updated dates are then applied to the screen state.
  ///
  /// Returns `true` when the date is accepted and successfully applied.
  bool validateAndSetPresentReviewDate(
    DateTime? selectedDate, {
    ApplicationDetails? details,
    Reference? appType,
  }) {
    if (selectedDate == null) {
      updatePresentReviewDate(selectedDate);
      return true;
    }

    // No complex validation here unless you want to restrict past dates
    updatePresentReviewDate(selectedDate);

    DateTime? presentReviewDate;
    DateTime defaultPresentReviewDate;
    DateTime defaultNextReviewDate;
    presentReviewDate = selectedDate;

    final isNewToBank = Utils.checkApplicationType(ApplicationType.newToBank);
    final isReconsideration =
        Utils.checkApplicationType(ApplicationType.reconsideration);

    if (isNewToBank) {
      // For New to Bank applications
      defaultPresentReviewDate =
          DateTime(presentReviewDate.year, presentReviewDate.month + 11, 0);
      defaultNextReviewDate =
          DateTime(presentReviewDate.year, presentReviewDate.month + 13, 0);
    } else {
      // For other applications isRecon &&
      if (isReconsideration) {
        presentReviewDate = details?.nextReviewDate;
      } else {
        presentReviewDate = details?.presentReviewDate;
      }

      defaultPresentReviewDate = DateTime(
        (presentReviewDate ?? DateTime.now()).year,
        (presentReviewDate ?? DateTime.now()).month + 11,
        0,
      );
      defaultNextReviewDate = DateTime(
        (presentReviewDate ?? DateTime.now()).year,
        (presentReviewDate ?? DateTime.now()).month + 13,
        0,
      );
    }

    // Pick the anchor date for nextReviewDate, depending on request type.
    DateTime nextReviewDateAnchor;
    if (state.isApplicationTypeMarkForward && isNewRequest) {
      // New mark-forward request: `details` is already the customer's last
      // approved application, so keep using its own nextReviewDate rather
      // than recomputing a generic default from the edited present review
      // date.
      nextReviewDateAnchor = details?.nextReviewDate ?? defaultNextReviewDate;
    } else {
      // All other cases: recompute from the newly selected present review
      // date.
      nextReviewDateAnchor = defaultNextReviewDate;
    }

    // Normalize to a date-only value in local time (matches initializeDates).
    final DateTime nextReviewDateValue = DateTime(
      nextReviewDateAnchor.toLocal().year,
      nextReviewDateAnchor.toLocal().month,
      nextReviewDateAnchor.toLocal().day,
    );

    emit(
      state.copyWith(
        isPresentReviewDate: true,
        presentReviewDate: presentReviewDate,
        defaultNextReviewDate: defaultNextReviewDate,
        defaultPresentReviewDate: defaultPresentReviewDate,
        nextReviewDate: nextReviewDateValue,
      ),
    );

    return true;
  }

  /// Updates the Present Review Date in the application details
  /// and refreshes the corresponding UI state.
  ///
  /// For existing requests, the application is marked for autosave.
  void updatePresentReviewDate(DateTime? date) {
    applicationDetails?.presentReviewDate = date;
    if (!isNewRequest) {
      applicationDetails?.isAutoSave = "2";
    }
    emit(
      state.copyWith(
        presentReviewDate: date,
        isPresentReviewDate: date != null,
      ),
    );
  }

  //  RO/ RM/ Business Unit head/ Credit Coordinator/ Credit analyst/
  // CC proxy/ Board proxy

  /// Determines whether the current user has edit access based on
  /// the request state and assigned business roles.
  ///
  /// Users with supported workflow roles can edit the request when
  /// the application is in an editable state. New requests are
  /// always permitted.
  bool otherRolesCheck() {
    //202605MEMORR005403
    // final ({String userId, String roleName})? assignedUser = Utils.getAssignedUserIfNotCurrentUser();
    // final bool isEditableStage = assignedUser == null;
    //if (assignedUser != null) {isEditableStage = false;} else {isEditableStage = true;}

    final bool hasValidRole = Utils.checkRoles([
      UserRole.relationshipOfficer, // RO
      UserRole.relationshipManager, // RM
      UserRole.boardDirectorProxy, // BDP
      UserRole.creditCommitteeProxy, // CCP
      UserRole.businessUnitHead,
      UserRole.teamLeaderBusiness, // TLB
      UserRole.segmentHeadBusiness, // SH-B
      UserRole.commercialAreaManager, // CAM
      UserRole.relationshipManagerBussiness, // RMB
      UserRole.creditCordinator, // CCOOD
      UserRole.creditAnalyst, // CA
    ]);

    return isNewRequest || (Utils.canEditApplication() && hasValidRole);
  }

  /// Determines whether the current user has view access to
  /// restricted request information.
  ///
  /// Returns `true` when the user is not assigned one of the
  /// restricted proxy roles.
  bool viewAccessRolesCheck() {
    return !Utils.checkRoles([
      UserRole.boardDirectorProxy,
      UserRole.creditCommitteeProxy,
    ]);
  }

  /// Determines whether the current application type is
  /// a Cancellation request.
  bool isCheckCancellationAT() {
    return Utils.checkApplicationType(ApplicationType.cancellation);
  }

  /// Displays the application reference number confirmation dialog
  /// after a successful save operation.
  ///
  /// For new or cancellation requests, a confirmation dialog is
  /// displayed containing the generated application reference number.
  /// For other scenarios, a success notification is shown and the
  /// workflow proceeds to the next screen.
  void showDialogSuccessAppRefNo(
    BuildContext context, {
    String? appRefNo,
    bool? isNew,
  }) {
    if (isNew != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        DialogHelper.showCustomDialog(
          barrierDismissible: false,
          onClosePressed: () {
            context.pop();
            moveToNext();
          },
          width: Scale.scaleHorizontally(350),
          context: context,
          title: "requestInformation.requestInformation.confirmation".tr(),
          content: Builder(
            builder: (_) {
              // Extract keys for line-length compliance
              const String infoKey = "requestInformation.requestInformation"
                  ".informationMsg";
              const String cancelKey = "requestInformation.requestInformation"
                  ".informationCancellationMsg";
              final String ref = appRefNo ?? "";
              return CustomSelectableText(
                text: isNew ? "${infoKey.tr()}$ref" : "${cancelKey.tr()}$ref",
              );
            },
          ),
          actions: [
            CustomButton(
              label: "requestInformation.requestInformation.okay".tr(),
              onPressed: () {
                context.pop();
                // LayoutViewModel().goToNextRoute();
                moveToNext();
              },
            ),
          ],
        );
      });
    } else {
      AlertManager().showSuccessToast("common.dataSaveSuccess".tr());
      moveToNext();
    }
  }

  /// Navigates to the next step in the request workflow.
  ///
  /// Redirects the user to the Customer Information screen.
  void moveToNext() {
    router.go(Routes.customerInformation);
  }

  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }
}
