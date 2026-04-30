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

class SicCodeReviewViewModel extends SafeCubit<SicCodeReviewState>
    with
        DraftMixin<
            SicCodeReviewViewModel> // AutoSave related changes by extended team
{
  SicCodeReviewViewModel()
      : super(SicCodeReviewState(loaderStatus: LoadingStatus.loading));
  late RequestRepository repository;
  late CustomerRepository repositoryCustomer;
  List<SicCodeReview>? customerSICcodeReview;
  Request? request;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<Reference>? proposedSICcodes = [];
  PageMode pageMode = PageMode.na;
  BuildContext? context;
  List<Comment>? comments = [];
  Comment comment = Comment();

  bool get canEdit =>
      (pageMode == PageMode.edit); // && Utils.canEditApplication();

  Customer? selectedCustomer;
  List<Customer>? customerList = [];
  TextEditingController controllerAccountLevelSicCode = TextEditingController();

  // AutoSave related changes by extended team
  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.customerInformation;

  @override
  String get draftFormKey => Routes.sicCodeReview;

  @override
  DraftHandler<SicCodeReviewViewModel> get draftHandler =>
      SicCodeReviewDraftHandler();

  // ---------------------------------------------------------------------------

  /// Initializes the view model by setting up the repository and
  /// fetching the SIC code review data for the current customer.
  ///
  /// Emits a [LoadingStatus.loaded] state once data is fetched.
  Future<void> init(context) async {
    context = context;
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
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  Customer getSelectedCustomer() {
    final request = Globals.request;
    if (request == null) return Customer();
    //final bool hasGroup = request.groupId != 0;
    return Customer(
      firstName: request.customers?.first.customerName,
      customerName: request.customers?.first.customerName,
      customerRimNo: request.customers?.first.customerRimNo,
    );
  }

  Future<void> getChildRimsForGroup() async {
    try {
      if (Utils.isGroupApplication()) {
        customerList = (await repositoryCustomer.getChildRimsForGroup() ?? []);
        if ((customerList ?? []).isNotEmpty) {
          selectedCustomer = customerList?.first;
        }
      }
    } catch (e) {
      // emit(state.copyWith(loaderStatus: LoadingStatus.error));
      logger.i("Error fetching getChildRimsForGroup : $e");
      rethrow;
    }
  }

  /// Fetches the SIC code review data for the given [rimNumber].
  ///
  /// If an error occurs, a failure toast is shown.
  Future<void> getSICcodeReviewData({String? customerRimNo}) async {
    customerSICcodeReview =
        await repository.getSICcodeReviewData(customerRimNo: customerRimNo);
    await Future.delayed(const Duration(milliseconds: 500), () {});
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

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
    await Future.delayed(const Duration(milliseconds: 500), () {});
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> getReferenceData() async {
    final Map<String, List<Reference>> referenceData =
        await ReferenceDataService().getReferenceData([
      ReferenceDataKeys.sicCodeList,
    ]);
    proposedSICcodes = referenceData[ReferenceDataKeys.sicCodeList];
  }

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

      await Future.delayed(const Duration(milliseconds: 500), () {});
      await getStategyComment();

      unawaited(
        deleteDraft(),
      ); // fire-and-forget: remove backend draft now that data is saved  // AutoSave related changes by extended team

      AlertManager().showSuccessToast("common.saveSuccess".tr());

      if (ifNavigate) {
        LayoutViewModel().goToNextRoute();
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  // AutoSave related changes by extended team
  @override
  Future<void> close() {
    unregisterDraftCallback();
    return super.close();
  }
}
