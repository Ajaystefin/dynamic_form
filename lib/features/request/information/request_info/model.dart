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

class RequestInfoViewModel extends SafeCubit<RequestInfoState>
    with DraftMixin<RequestInfoViewModel> {
  RequestInfoViewModel()
      : super(RequestInfoState(loaderStatus: LoadingStatus.loading));
  RequestRepository repository = RequestRepository();
  CustomerRepository repositoryCustomer = CustomerRepository();
  CommonRepository repositoryCommon = CommonRepository();
  FocusNode formFocusNode = FocusNode();

  var formKey = GlobalKey<FormState>();
  UnifiedEditorController controllerPurpose = UnifiedEditorController();
  UnifiedEditorController controllerDetail = UnifiedEditorController();
  UnifiedEditorController controllerUltimate = UnifiedEditorController();
  TextEditingController controllerMainSec = TextEditingController();
  TextEditingController deviationJustificationController =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController(keepScrollOffset: false);

  bool cancellationDialogShown = false;
  bool pipelineShown = true;
  Request requestInformation = Request();

  List<Reference> productTypeItems = [];
  List<Reference> applicationType = [];
  List<Reference> requestTypes = [];
  List<Reference> customerTypes = [];
  List<Reference> applicationTypesFullCA = [];
  List<Reference> applicationTypesIsolated = [];
  List<Reference> restructuredRescheduledItems = [];
  List<Reference> exposureStrategyItems = [];
  List<Reference> reasonForDeferral = [];
  List<Reference> tpanRequiredItems = [];
  List<Reference> shariaApprovalItems = [];
  List<Reference> ermApprovalItems = [];
  List<Reference> esgItems = [];
  List<Reference> pricingCommitteeItems = [];
  List<Reference> interimReviewDateRequiredItems = [];
  List<Reference> policyDeviationItems = [];
  List<Reference> cancellationReason = [];
  List<ApplicationDetails>? reconsiderations = [];

  Reference? selectedProductType;
  Reference? selectedTpanRequired;
  Reference? selectedShariaApproval;
  Reference? selectedErmApproval;
  Reference? selectedEsg;
  Reference? selectedPricinCommittee;
  Reference? selectedInterimReviewDateRequired;
  Reference? selectedRequestType;
  Reference? selectedBusinessSegment;
  Reference? selectedApplicationType;
  Reference? selectedRestructuredRescheduled;
  Reference? selectedExposureStrategy;
  Reference? selectedDeferralCode;
  Reference? selectedPolicyDeviation;
  Reference? selectedCancellationReason;
  Reference? selectedCustomerType;
  ApplicationDetails? selectedReconsiderations;

  ApplicationDetails? applicationDetails = ApplicationDetails();

  List<TextEditingController> rimControllers = [];
  List<TextEditingController> nameControllers = [];

  String? selectedReconAppReNumber;
  String? selectedLastApprovedAppRefNum;
// Comments
  Comment comment = Comment();
  List<Comment>? comments = [];

  ValueNotifier<bool> isSaveContinueButtonEnabled = ValueNotifier(true);

  bool get canEdit =>
      pageMode == PageMode.edit; // && Utils.canEditApplication();

  PageMode pageMode = PageMode.na;

  bool isFI = false;

  bool isNewRequest = false; //Default false for create request.
  bool isApiError = false; //Default false.
  bool isExisitngAppRefNo = false; //Default false.

  Map<String, List<Reference>> referenceData = {};
  List<Response> pipelineRequests = [];

  List<CoBorrower>? coBorrowerList = [];

// AutoSave related changes by extended team
  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.requestInformation;

  @override
  String get draftFormKey => Routes.requestInformation;

  @override
  DraftHandler<RequestInfoViewModel> get draftHandler =>
      RequestInfoDraftHandler();

  // ---------------------------------------------------------------------------

  /// Initializes the ViewModel with data from the provided [requestCreate]
  /// object.
  ///
  /// This method sets up the repository, controller, and form focus node,
  /// fetches reference and reconsideration data, and displays the pipeline
  /// dialog.
  ///
  /// Emits:
  /// - [LoadingStatus.loaded] when initialization is complete.
  Future<void> init(context) async {
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
        showCancellationDialog(context);
      }

      checkAndShowPipelineDialog(context);

      isApiError = false;
    } catch (e) {
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

  void checkAndShowPipelineDialog(BuildContext context) {
    if (!isNewRequest || !pipelineShown || pipelineRequests.isEmpty) return;

    final bool isNewToBank =
        Utils.checkApplicationType(ApplicationType.newToBank);

    bool showDialog;

    if (isFI) {
      // FI logic
      if (isNewToBank) return; // FI + NTB → never show
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
      } else {
        applicationDetails = await repository.getApplicationDetails(); // use
        selectedLastApprovedAppRefNum =
            applicationDetails?.lastApprovedAppRefNum;
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
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
      e.toString();
      // emit(state.copyWith(loaderStatus: LoadingStatus.error));
      rethrow;
    }
  }

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
  /// isFI == true:
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
                ? commentItem.first.strategyComment
                : "";
        controllerDetail.setText(comments?[0].strategyComment ?? "");
      }
      if (comments!.isNotEmpty) {
        logger.i("Strategy comment: ${comments?[0].strategyComment}");
      }
    } catch (e) {
      comments = [Comment(strategyComment: "Test")];
      logger.e("Error fetching strategy comments: $e");
    }
  }

  Future<void> getApplicationStrategyDetails() async {
    if (!isNewRequest) {
      await fetchAndSetStrategyComments();
    }
  }

  void updateSelectedProductType({bool? conventional, bool? islamic}) {
    // use
    final filteredOptions = getFilteredProductOptions();

    String? targetName;
    if (conventional == true && islamic == true) {
      targetName = ServerConstants.productTypeBoth;
      //'requestInformation.requestInformation.both'.tr();
    } else if (conventional == true) {
      targetName = ServerConstants.productTypeConventional;
      // 'requestInformation.requestInformation.conventional'.tr();
    } else if (islamic == true) {
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

    await Future.delayed(const Duration(seconds: 1), () {});
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

    await fetchAndSetStrategyComments(appRefNo: selected.applicationRefNo);
  }

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
    controllerPurpose.setText(details.purpose ?? "");
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
            selectedApplicationType?.name?.isEmpty == true) &&
        (applicationDetails?.subType?.isNotEmpty == true) &&
        (applicationDetails?.requestType?.isNotEmpty == true)) {
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
      selectedCancellationReason = cancellationReason.firstWhere(
        (element) => element.id == applicationDetails?.deferralReasonCode,
        orElse: () => Reference(id: applicationDetails?.deferralReasonCode),
      );
    }

    initLockPresentReviewDateIfRequired();
  }

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
        isIslamic: selected.reference1 == ServerConstants.productTypeIslamic,
      ),
    );
    //  selected.name.toString()
    // =='requestInformation.requestInformation.islamic'.tr()));
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

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

  Future<void> saveContinueButtonPress(BuildContext context) async {
    emit(
      state.copyWith(
        isButtonLoading: false,
        loaderStatus: LoadingStatus.empty,
      ),
    );

    if (otherRolesCheck()) {
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
        purposeRawValue = await getValidatedText(
          controller: controllerPurpose,
          errorKey: "requestInformation.requestInformation.requiredAppSummary",
        );

        if (!isFI) {
          ultimateRawValue = await getValidatedText(
            controller: controllerUltimate,
            errorKey: "requestInformation.requestInformation.requiredOwnership",
          );

          detailsRawValue = await getValidatedText(
            controller: controllerDetail,
            errorKey:
                "requestInformation.requestInformation.requiredAppDetails",
          );
        }
      } catch (_) {
        return; // validation already handled
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
        ..requestType = Globals.request?.requestType?.reference1 ??
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
        ..presentReviewDate = state.presentReviewDate
        ..nextReviewDate = isCheckCancellationAT()
            ? null
            : state.nextReviewDate ?? state.defaultNextReviewDate
        ..isOverrideNextReviewDate =
            isCheckCancellationAT() ? false : state.overrideDate ?? false
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

      // logger.i(applicationDetails?.toString());
      // logger.i(applicationDetails?.toSaveApplicationJson());

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
    } catch (e) {
      e.toString();
      if (e.toString().isNotEmpty) {
        await handleValidationFailure(e.toString());
      }
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

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

  String buildBusinessSegmentMappings(List<Customer> customers) {
    final int? primaryRim = Globals.request?.customerRimNo;
    if (primaryRim == null) return "";
    final Customer primaryCustomer = customers.firstWhere(
      (c) => c.customerRimNo == primaryRim,
      orElse: Customer.new,
    );
    return primaryCustomer.segment?.toString() ?? resolveBusinessSegment();
  }

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

  List<GroupMapping> groupMappingFilter() {
    final customers = getSelectedCustomers();
    final int? primaryRim = Globals.request?.customerRimNo;

    return customers.map((customer) {
      final int rim = customer.customerRimNo ?? 0;

      return GroupMapping(
        rimNumber: rim,
        name: customer.concatCustomerFullName.trim().isNotEmpty
            ? customer.concatCustomerFullName.trim()
            : "RIM NO $rim",
        isPrimary: primaryRim != null && rim == primaryRim,
        sicCode: customer.proposedSICCode,
        isApplicant: true,
      );
    }).toList();
  }

  Future<String> getValidatedText({
    required UnifiedEditorController controller,
    required String errorKey,
  }) async {
    final value = await getCleanText(controller);
    if (value.isEmpty) {
      await handleValidationFailure(errorKey.tr());
      throw Exception(errorKey); // stops execution cleanly
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
  /// "Cancel" triggers [onClickCancelCustomerInfoDialog].
  Future<void> showInPipelineDialog(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 1));
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
              await Future.delayed(const Duration(seconds: 2));
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          const Gap(
            size: GapSize.medium,
            direction: Axis.horizontal,
          ),
          CustomButton(
            label: "requestInformation.requestInformation.cancel".tr(),
            onPressed: () async {
              await Future.delayed(const Duration(milliseconds: 500));
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

  void onShariaApprovalSelected(Reference selected) {
    selectedShariaApproval = selected;
    applicationDetails?.shariaApproval =
        (selected.id == ServerConstants.yesRefId);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onErmApprovalSelected(Reference selected) {
    selectedErmApproval = selected;
    applicationDetails?.ermApproval = (selected.id == ServerConstants.yesRefId);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onEsgSelected(Reference selected) {
    selectedEsg = selected;
    applicationDetails?.esgApproval = (selected.id == ServerConstants.yesRefId);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onPricingCommitteeSelected(Reference selected) {
    selectedPricinCommittee = selected;
    applicationDetails?.pricingCommitteApproval =
        (selected.id == ServerConstants.yesRefId);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onRestructuredRescheduledSelected(Reference selected) {
    selectedPricinCommittee = selected;
    applicationDetails?.rescheduledRestructed = selected.name;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

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

  void onExposureStrategySelected(Reference selected) {
    selectedExposureStrategy = selected;
    applicationDetails?.exposureStrategy = selected.name;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onReasonForDeferralSelected(Reference selected) {
    selectedDeferralCode = selected;
    applicationDetails?.deferralReasonCode = selected.id;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Reference? _findReferenceById(List<Reference> list, int? id) {
    if (id == null) return null;
    final int i = list.indexWhere((r) => r.id == id);
    return (i == -1) ? null : list[i];
  }

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

  void onCancellationSelected(Reference selected) {
    selectedCancellationReason = selected;
    applicationDetails?.deferralReasonCode = selected.id;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  // Checkbox toggles
  void overrideSelected(bool? isChecked) {
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
        throw "common.noUserFound".tr();
      }

      if (customer.partyStatus.toString().trim() ==
          ServerConstants.partyStatusClosed) {
        throw "common.noUserFoundClosedPartyStatus".tr();
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
    } catch (e) {
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

  void addCoBorrowerRow() {
// Work with a local copy to avoid null-bang
    final list = coBorrowerList ?? [];

    final hasRows = list.isNotEmpty;
    final lastNameFromController =
        nameControllers.isNotEmpty ? nameControllers.last.text.trim() : "";
    final lastNameFromModel =
        hasRows ? (list.last.customerName?.trim() ?? "") : "";

    // Allow add if list is empty OR last existing row has a non-empty name
    final canAdd = !hasRows ||
        lastNameFromController.isNotEmpty ||
        lastNameFromModel.isNotEmpty;

    if (!canAdd) {
      return; // Don't add another empty row
    }

    // Add new co-borrower to model and assign back
    final newList = List<CoBorrower>.from(list)
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

  void removeCoBorrowerRow(int index) {
    if (coBorrowerList != null &&
        index >= 0 &&
        index < coBorrowerList!.length) {
      // Remove from model
      coBorrowerList!.removeAt(index);

      //Remove controllers safely
      if (index < rimControllers.length) rimControllers.removeAt(index);
      if (index < nameControllers.length) nameControllers.removeAt(index);

      //Sync back to applicationDetails
      // applicationDetails?.customerInformation?.coBorrower = borrowerList;

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  /// Called when a country-chip’s delete icon is tapped
  void onPolicyChipDeleted(int index) {
    final list = applicationDetails?.policyDeviations;
    if (list == null || index < 0 || index >= list.length) return;

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

////REUSABLE METHODS
// Reusable method to Validator
  String? validateSelection(
    String? value,
    List<Reference> options,
    String errorKey,
  ) {
    final trimmedValue = value?.trim();
    final isValid = options.any((ref) => ref.name == trimmedValue);
    return isValid ? null : errorKey.tr();
  }

  // Reusable method to filter out 'NA'
  List<Reference> getFilteredOptions(List<Reference> options) {
    return options
        .where(
          (ref) => ref.name != "requestInformation.requestInformation.na".tr(),
        )
        .toList();
  }

  // Reusable method to get selected value with fallback => Product Type Logics
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

    final fallbackName = fallbackFlag == true
        ? "requestInformation.requestInformation.yes".tr()
        : "requestInformation.requestInformation.no".tr();

    return filtered.firstWhere(
      (ref) => ref.name == fallbackName,
      orElse: () => filtered.first,
    );
  }

  // Filters out 'NA' from the options
  List<Reference> getFilteredProductOptions() {
    return productTypeItems.where((ref) {
      final values = ref.reference2?.toLowerCase().split(",") ?? [];

      return isFI
          ? values.contains(ServerConstants.policyDeviationFI) // "fi"
          : values.contains(ServerConstants.policyDeviationCorporateC); // "c"
    }).toList();
  }

  // Returns selected product or fallback
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
  String? validateProductTypeSelection(Reference? value) {
    final isValid = getFilteredProductOptions().contains(value);
    return isValid
        ? null
        : "requestInformation.requestInformation.selectProductType".tr();
  }

  double calculateLargeExposureLimit(
    Map<String, List<Reference>> referenceData,
  ) {
    final List<dynamic> referenceRawList =
        referenceData[ReferenceDataKeys.largeExposureLimit] ?? [];

    final List<Reference> referenceList = referenceRawList.map((dynamic item) {
      if (item is Reference) return item;
      if (item is Map<String, dynamic>) return Reference.fromJson(item);
      throw Exception("Unexpected item type: ${item.runtimeType}");
    }).toList();

    // Always use the FIRST item and ignore IDs.
    // columnsInfo = "Amount;Percentage" → reference1=Amount,
    // reference2=Percentage
    // (as per the server contract you shared)
    if (referenceList.isEmpty) return 0;
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

  double calculateLargeExposureLimitAmountValues(
    Map<String, List<Reference>> referenceData,
  ) {
    final List<dynamic> referenceRawList =
        referenceData[ReferenceDataKeys.largeExposureLimit] ?? [];

    final List<Reference> referenceList = referenceRawList.map((dynamic item) {
      if (item is Reference) return item;
      if (item is Map<String, dynamic>) return Reference.fromJson(item);
      throw Exception("Unexpected item type: ${item.runtimeType}");
    }).toList();

    if (referenceList.isEmpty) return 0;
    final Reference first = referenceList.first;
    // Be forgiving with formatting (e.g., "5,000" or "10%")
    final String amountRaw =
        (first.reference1 ?? "0").replaceAll(",", "").trim();
    final double amount = double.tryParse(amountRaw) ?? 0.0;
    return amount;
  }

  double calculateLargeExposureLimitPercentageValues(
    Map<String, List<Reference>> referenceData,
  ) {
    final List<dynamic> referenceRawList =
        referenceData[ReferenceDataKeys.largeExposureLimit] ?? [];

    final List<Reference> referenceList = referenceRawList.map((dynamic item) {
      if (item is Reference) return item;
      if (item is Map<String, dynamic>) return Reference.fromJson(item);
      throw Exception("Unexpected item type: ${item.runtimeType}");
    }).toList();

    if (referenceList.isEmpty) return 0;
    final Reference first = referenceList.first;
    // Be forgiving with formatting (e.g., "5,000" or "10%")
    final String percentRaw =
        (first.reference2 ?? "0").replaceAll("%", "").trim();
    final double percentage = double.tryParse(percentRaw) ?? 0.0;
    return percentage;
  }

  Future<void> getPipelineRequestDetails() async {
    try {
      pipelineRequests = (await repository.getPipelineRequestDetails()) ?? [];
    } catch (e) {
      logger.e("Error getting reference data types: $e");
    }
  }

  void initializeDates(
    ApplicationDetails? details,
    Reference? appType, {
    bool isRecon = false,
  }) {
    final applicationDate = DateTime.now();
    DateTime? presentReviewDate;
    DateTime defaultPresentReviewDate;
    DateTime defaultNextReviewDate;

    final isNewToBank = appType?.id ==
        ServerConstants.applicationTypeId[ApplicationType.newToBank];
    final isReconsideration = appType?.id ==
        ServerConstants.applicationTypeId[ApplicationType.reconsideration];

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

    emit(
      state.copyWith(
        presentReviewDate:
            isNewRequest ? presentReviewDate : details?.presentReviewDate,
        defaultNextReviewDate: defaultNextReviewDate,
        defaultPresentReviewDate: defaultPresentReviewDate,
        nextReviewDate: isNewRequest
            ? defaultNextReviewDate
            : (isRecon && isReconsideration)
                ? defaultNextReviewDate
                : details?.nextReviewDate,
        markForwardDate: isNewRequest ? null : details?.markForwardDate,
      ),
    );
  }

  bool validateAndSetNextReviewDate(DateTime? selectedDate) {
    if (selectedDate == null) {
      updateNextReviewDate(selectedDate);
      return true;
    }

    if (selectedDate.isBefore(state.presentReviewDate ?? DateTime.now())) {
      AlertManager().showWarningToast(
        "requestInformation.requestInformation.newReviewdateEarlierthan".tr(),
      );
      updateNextReviewDate(
        state.defaultNextReviewDate,
      ); // or null if you want empty
      return false;
    }

    if (selectedDate.isAfter(state.defaultNextReviewDate!)) {
      if (state.overrideDate ?? false) {
        AlertManager().showWarningToast(
          "requestInformation.requestInformation.newReviewdateGreaterthan".tr(),
        );
        updateNextReviewDate(selectedDate); // or null
        return false;
      }
    }

    updateNextReviewDate(selectedDate);
    return true;
  }

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
      // Warning only, allow user to continue
      // or null if you want empty
      return false;
    }

    updateMarkForwardDate(selectedDate);
    return true;
  }

  void updateNextReviewDate(DateTime? date) {
    applicationDetails?.nextReviewDate = date;
    emit(state.copyWith(nextReviewDate: date));
  }

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
    if (!canEdit) return false;
    if (!otherRolesCheck()) return false;

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

    final isNewToBank = appType?.id ==
        ServerConstants.applicationTypeId[ApplicationType.newToBank];
    final isReconsideration = appType?.id ==
        ServerConstants.applicationTypeId[ApplicationType.reconsideration];

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

    emit(
      state.copyWith(
        isPresentReviewDate: true,
        presentReviewDate: presentReviewDate,
        defaultNextReviewDate: defaultNextReviewDate,
        defaultPresentReviewDate: defaultPresentReviewDate,
        nextReviewDate: isNewRequest
            ? defaultNextReviewDate
            : isReconsideration
                ? defaultNextReviewDate
                : details?.nextReviewDate,
      ),
    );

    return true;
  }

  void updatePresentReviewDate(DateTime? date) {
    applicationDetails?.presentReviewDate = date;
    if (!isNewRequest) {
      applicationDetails?.isAutoSave == "2";
    }
    emit(state.copyWith(presentReviewDate: date));
  }

  bool otherRolesCheck() {
    return (Utils.checkRoles([
      UserRole.relationshipOfficer, //RO
      UserRole.relationshipManager, //RM
      UserRole.boardDirectorProxy, // BDP
      UserRole.creditCommitteeProxy, //CCP
      // Relationship / Business
      UserRole.businessUnitHead,
      UserRole.teamLeaderBusiness, //TLB
      UserRole.segmentHeadBusiness, //SH-B
      UserRole.commercialAreaManager, //CAM
      UserRole.relationshipManagerBussiness, //RMB
      UserRole.creditCordinator, // "CCOOD"
      UserRole.creditAnalyst, //"CA"
    ]))
        ? true
        : false;
  }

  bool viewAccessRolesCheck() {
    return (Utils.checkRoles([
      UserRole.boardDirectorProxy,
      UserRole.creditCommitteeProxy,
    ]))
        ? false
        : true;
  }

  bool isCheckCancellationAT() {
    return selectedApplicationType?.id ==
        ServerConstants.applicationTypeId[ApplicationType.cancellation];
  }

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

  void moveToNext() {
    router.go(Routes.customerInformation);
  }

  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }
}
