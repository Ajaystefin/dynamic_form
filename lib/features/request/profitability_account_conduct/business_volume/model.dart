import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/profitability/business_volume.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';
import 'package:wcas_frontend/repositories/profitability_repository.dart';
import 'state.dart';

class BusinessVolumeViewModel extends Cubit<BusinessVolumeState> {
  BusinessVolumeViewModel()
      : super(BusinessVolumeState(loaderStatus: LoadingStatus.loading));
  ProfitabilityRepository repository = ProfitabilityRepository();

  Map<Customer, List<BusinessVolume>> customerWiseBusinessVolume = {};

  String? comments;

  /// Initializes the BusinessVolumeViewModel.
  ///
  /// This function sets up the repository, logs the initialization
  /// process, retrieves business volume data, and updates the loader status.
  ///
  /// [context] - The BuildContext, if needed for additional initialization steps.
  ///
  Future<void> init(context) async {
    logger.i('initialising BusinessVolumeViewModel');
    await getBusinessVolume();
    await getBusinessVolumeComment();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Retrieves customer-wise business volume data asynchronously.
  ///
  /// This function fetches business volume data from the repository
  /// and assigns it to `customerWiseBusinessVolume`. If an error occurs,
  /// it updates the loader status to indicate failure.
  ///
  /// Throws:
  /// - If the repository fails to retrieve data, the loader status
  ///   is updated to `LoadingStatus.error`
  Future<void> getBusinessVolume() async {
    try {
      customerWiseBusinessVolume = await repository.getBusinessVolumes();
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  Future<void> getBusinessVolumeComment() async {
    try {
      final comment = await repository.getBusinessVolumeComment();
      comments = comment!.comment!;
      debugPrint("comment: $comments");
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Saves the customer-wise business volume data and updates the loader status.
  ///
  /// This function initiates the save process by setting the loader status to
  /// `LoadingStatus.loading`. Upon successful completion, it updates the status
  /// to `LoadingStatus.loaded` and displays a success message. If an error occurs,
  /// it shows a failure toast and sets the status to `LoadingStatus.error`.
  ///
  /// [isContinue] - (Optional) Determines whether the function should proceed
  /// to another operation after saving.
  ///
  /// Throws:
  /// - Displays a failure toast in case of an exception and updates
  ///   the loader status accordingly.
  Future<void> onSavePress({bool isContinue = false}) async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      String response = await repository.saveBusinessVolumes(
          customerWiseBusinessVolume, comments);
      AlertManager().showSuccessToast(response);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      if (isContinue) {
        LayoutViewModel().goToNextRoute();
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// to save comment data
  Future<void> saveComments() async {
    try {
      Comment commentData = Comment(comment: comments);
      commentData.commentId = "2";
      commentData.applicationRefNo = Globals.request?.applicationRefNo;
      commentData.draft = false;
      commentData.userId = Globals.user?.id;
      commentData.userRole = Globals.user?.currentRole?.roleId;
      commentData.reviewCommentId = "345";
      commentData.type = CommentsType.accountStats;
      commentData.entityType = EntityIdentifier.accountStats;
      String response =
          await CommonRepository.instance.saveComment(commentData);
      AlertManager().showSuccessToast(response);
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }
}
