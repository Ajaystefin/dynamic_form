import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'package:wcas_frontend/models/request/sic_code.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';
import 'package:wcas_frontend/repositories/auth_repository.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

import 'state.dart';

class SicCodeReviewViewModel extends Cubit<SicCodeReviewState> {
  SicCodeReviewViewModel()
      : super(SicCodeReviewState(loaderStatus: LoadingStatus.loading));
  late RequestRepository repository;
  List<SicCodeReview>? customerSICcodeReview;
  Request? request;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<Reference>? proposedSICcodes = [];
  PageMode pageMode = PageMode.na;
  BuildContext? context;
  List<Comment>? comments = [];
  Comment comment = Comment();

  bool get canEdit => (pageMode == PageMode.edit);

  /// Initializes the view model by setting up the repository and
  /// fetching the SIC code review data for the current customer.
  ///
  /// Emits a [LoadingStatus.loaded] state once data is fetched.
  Future<void> init(context) async {
    context = context;
    logger.i('initialising SicCodeReviewViewModel');
    repository = RequestRepository.instance;
    request = Globals.request ?? Request();
    pageMode = AuthRepository.getPageMode(RightConstants.sicCodeReview);
    try {
      await Future.wait([
        getSICcodeReviewData(),
        getReferenceData(),
        getStategyComment(),
      ]);

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Fetches the SIC code review data for the given [rimNumber].
  ///
  /// If an error occurs, a failure toast is shown.
  Future<void> getSICcodeReviewData() async {
    customerSICcodeReview = await repository.getSICcodeReviewData();
  }

  Future<void> getStategyComment() async {
    comments = await CommonRepository.instance.getStategyComment(
      ServerConstants.commentTypeId[CommentsType.sicCodeReview],
      ServerConstants.strategyCategorySICCodeReview,
    );
  }

  Future<void> getReferenceData() async {
    Map<String, List<Reference>> referenceData =
        await ReferenceDataService().getReferenceData([
      ReferenceDataKeys.sicCodeList,
    ]);
    proposedSICcodes = referenceData[ReferenceDataKeys.sicCodeList];
  }

  /// Saves the current [customerSICcodeReview] data to the backend.
  ///
  /// Emits a loading state before the operation and a loaded or error
  /// state depending on the result. Shows a toast message on failure.

  Future<void> onSaveSic({bool ifNavigate = false}) async {
    // emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    formKey.currentState?.save();
    try {
      comment = Comment.fromInputData(
        type: CommentsType.sicCodeReview,
        strategyComment: comment.strategyComment,
        entityType: EntityIdentifier.sicCodeReview,
        categoryId: ServerConstants.commentTypeId[CommentsType.sicCodeReview],
        strategyCategory: ServerConstants.strategyCategorySICCodeReview,
        id: comment.id,
      );

      if ((customerSICcodeReview ?? []).isNotEmpty) {
        repository.saveSICcodeReview(customerSICcodeReview);
      }
      await Future.wait([
        CommonRepository.instance.saveStategyComment(comment),
        getStategyComment(),
      ]);
      AlertManager().showSuccessToast("common.saveSuccess".tr());
      if (ifNavigate) {
        LayoutViewModel().goToNextRoute();
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      logger.d('Error details: ${e.toString()}');
    }

    // emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}
