import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/screen_access_conditions.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/customer_information/sic_code_review/draft_handler.dart";
import "package:wcas_frontend/features/request/customer_information/sic_code_review/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/models/request/sic_code.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

/// View model for the SIC code review screen.
class SicCodeReviewViewModel extends SafeCubit<SicCodeReviewState>
    with
        DraftMixin<
            SicCodeReviewViewModel> // AutoSave related changes by extended team
{
  /// Creates a SIC code review view model.
  SicCodeReviewViewModel()
      : super(const SicCodeReviewState(loaderStatus: LoadingStatus.loading));

  /// Request repository used for SIC code review operations.
  late RequestRepository repository;

  /// Customer repository used for customer related operations.
  late CustomerRepository repositoryCustomer;

  /// List of customer SIC code review records.
  List<SicCodeReview>? customerSICcodeReview;

  /// Current request details.
  Request? request;

  /// Form key for SIC code review form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Proposed SIC code reference values.
  List<Reference>? proposedSICcodes = [];

  /// Page mode for SIC code review screen.
  PageMode pageMode = PageMode.na;

  /// Build context assigned during initialization.
  BuildContext? context;

  /// Strategy comments fetched for SIC code review.
  List<Comment>? comments = [];

  /// Active strategy comment for selected customer.
  Comment comment = Comment();

  /// Indicates whether SIC code review screen can be edited.
  bool get canEdit =>
      pageMode == PageMode.edit; // && Utils.canEditApplication();

  /// Currently selected customer.
  Customer? selectedCustomer;

  /// Child customer list used for group applications.
  List<Customer>? customerList = [];

  /// Controller for account level SIC code comments.
  TextEditingController controllerAccountLevelSicCode = TextEditingController();

  // AutoSave related changes by extended team
  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  /// Draft module key for customer information.
  @override
  String get draftModuleKey => DraftModuleKeys.customerInformation;

  /// Draft form key for SIC code review.
  @override
  String get draftFormKey => Routes.sicCodeReview;

  /// Draft handler for SIC code review.
  @override
  DraftHandler<SicCodeReviewViewModel> get draftHandler =>
      SicCodeReviewDraftHandler();

  // ---------------------------------------------------------------------------

  /// Initializes the view model by setting up the repository and
  /// fetching the SIC code review data for the current customer.
  ///
  /// Emits a [LoadingStatus.loaded] state once data is fetched.
  Future<void> init(BuildContext context) async {
    //context = context;
    logger.i("initialising SicCodeReviewViewModel");
    repository = RequestRepository.instance;
    repositoryCustomer = CustomerRepository.instance;
    request = Globals.request ?? Request();
    pageMode = AuthRepository.getPageMode(RightConstants.sicCodeReview);
    selectedCustomer = getSelectedCustomer();
    try {
      await Future.wait([
        getChildRimsForGroup(),
        getSICcodeReviewData(
          customerRimNo: selectedCustomer?.customerRimNo.toString(),
        ),
        getReferenceData(),
        getStategyComment(),
      ]);
      // AutoSave related changes by extended team
      if (canEdit) {
        registerDraftCallback();
        await loadDraftIfAvailable();
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Returns the selected customer from the current request.
  Customer getSelectedCustomer() {
    final request = Globals.request;
    if (request == null) {
      return Customer();
    }
    //final bool hasGroup = request.groupId != 0;
    return Customer(
      firstName: request.customers?.first.customerName,
      customerName: request.customers?.first.customerName,
      customerRimNo: request.customers?.first.customerRimNo,
    );
  }

  /// Retrieves child RIMs for group applications.
  Future<void> getChildRimsForGroup() async {
    try {
      if (Utils.isGroupApplication()) {
        customerList = await repositoryCustomer.getChildRimsForGroup() ?? [];
        if ((customerList ?? []).isNotEmpty) {
          selectedCustomer = customerList?.first;
        }
      }
    } on Object catch (e) {
      // emit(state.copyWith(loaderStatus: LoadingStatus.error));
      logger.i("Error fetching getChildRimsForGroup : $e");
      rethrow;
    }
  }

  /// Fetches the SIC code review data for the given [`rimNumber`].
  ///
  /// If an error occurs, a failure toast is shown.
  Future<void> getSICcodeReviewData({String? customerRimNo}) async {
    customerSICcodeReview =
        await repository.getSICcodeReviewData(customerRimNo: customerRimNo);
    unawaited(delay());
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Fetches strategy comment for the selected customer.
  Future<void> getStategyComment() async {
    comments = await CommonRepository.instance.getStategyComment(
      ServerConstants.commentTypeId[CommentsType.sicCodeReview],
      ServerConstants.strategyCategorySICCodeReview,
      appRefNo: Globals.request?.applicationRefNo,
    );

    if (comments == null || comments!.isEmpty) {
      comment = Comment();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      return;
    }

    // Filter only this customer's comments
    final customerComments = comments!
        .where((c) => c.rimNo == selectedCustomer?.customerRimNo)
        .toList();

    if (customerComments.isEmpty) {
      comment = Comment();
    } else {
      // Pick the latest one (highest ID)
      customerComments.sort((a, b) => b.id!.compareTo(a.id!));
      comment = customerComments.first;
    }

    controllerAccountLevelSicCode.text = comment.strategyComment ?? "";
    unawaited(delay());
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Fetches reference data required for SIC code review.
  Future<void> getReferenceData() async {
    final Map<String, List<Reference>> referenceData =
        await ReferenceDataService().getReferenceData([
      ReferenceDataKeys.sicCodeList,
    ]);
    proposedSICcodes = referenceData[ReferenceDataKeys.sicCodeList];
  }

  /// Handles selected customer change.
  Future<void> onCustomerSeletion(Customer selectedValue) async {
    selectedCustomer = selectedValue;
    await getSICcodeReviewData(
      customerRimNo: selectedCustomer?.customerRimNo.toString(),
    );
    await getStategyComment();
    if (canEdit) {
      await loadDraftIfAvailable();
    }
  }

  /// Saves the current [customerSICcodeReview] data to the backend.
  ///
  /// Emits a loading state before the operation and a loaded or error
  /// state depending on the result. Shows a toast message on failure.
  Future<void> onSaveSic({bool ifNavigate = false}) async {
    formKey.currentState?.save();

    try {
      comment = Comment.fromInputData(
        type: CommentsType.sicCodeReview,
        strategyComment: comment.strategyComment,
        entityType: EntityIdentifier.sicCodeReview,
        categoryId: ServerConstants.commentTypeId[CommentsType.sicCodeReview],
        strategyCategory: ServerConstants.strategyCategorySICCodeReview,
        id: comment.id, // KEEP id if matched (UPDATE)
        rimNo: comment.rimNo, // KEEP rimNo from matchedComment
      );

      if (customerSICcodeReview != null && customerSICcodeReview!.isNotEmpty) {
        // Check if ANY item has proposedSicCode not null
        final bool hasValidSic =
            customerSICcodeReview!.any((item) => item.proposedSicCode != null);
        if (hasValidSic) {
          await repository.saveSICcodeReview(customerSICcodeReview);
        }
      }
      await Future.wait([
        CommonRepository.instance.saveStategyComment(
          comment,
          appRefNo: Globals.request?.applicationRefNo,
          rimNo: selectedCustomer?.customerRimNo,
        ),
      ]);

      unawaited(delay());
      await getStategyComment();

      unawaited(
        deleteDraft(),
      ); // fire-and-forget: remove backend draft now that data is saved  // AutoSave related changes by extended team

      AlertManager().showSuccessToast("common.saveSuccess".tr());

      if (ifNavigate) {
        LayoutViewModel().goToNextRoute();
      }
    } on Object catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Adds a short delay before refreshing UI state.
  Future<void> delay() async {
    await Future.delayed(const Duration(milliseconds: 250), () {});
  }

  // AutoSave related changes by extended team

  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
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
