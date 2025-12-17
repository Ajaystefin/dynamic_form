import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/models/request/group_information/facilities_with_cbd.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';
import 'package:wcas_frontend/repositories/group_information_repository.dart';

import 'state.dart';

class FacilitiesWithCbdViewModel extends Cubit<FacilitiesWithCbdState> {
  FacilitiesWithCbdViewModel()
      : super(FacilitiesWithCbdState(loaderStatus: LoadingStatus.loading));

  GroupInformationRepository? repository;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<FacilitiesWithCbd> groupFacilitiesWithCDB = [];
  List<Comment>? comments;
  Comment? comment;

  /// It first logs the initialization of the view model, then sets the
  /// [repository] to an instance of [GroupInformationRepository]. Finally, it awaits
  /// the completion of the following two futures:
  ///
  /// - [getApplicationStrategyDetails]
  /// - [getGroupInformation]
  void init(context) async {
    logger.i('initialising FacilitiesWithCbdViewModel');
    repository ??= GroupInformationRepository.instance;
    await Future.wait([
      getApplicationStrategyDetails(),
      getGroupInformation(),
    ]);
  }

  /// Fetches application strategy details and updates state.
  ///
  /// This method retrieves the application strategy details from the repository
  /// and logs the fetched details. It filters the `commentList` to find comments
  /// with the category type "GROUP INFORMATION" and updates `strategyComment` with
  /// the first matching comment's strategyComment. If an error occurs during the
  /// process, the loading status is set to error.
  Future<void> getApplicationStrategyDetails() async {
    try {
      comments = await CommonRepository.instance.getApplicationStrategyDetails(
          CommentsType.facilitiesWithCbd, EntityIdentifier.facilitiesWithCbd);
      final List<Comment>? commentItem = comments
          ?.where((item) => item.categoryId == ServerConstants.groupCategoryID)
          .toList();

      comment ??= Comment();
      if (commentItem != null && commentItem.isNotEmpty) {
        comment!.comment = commentItem.first.strategyComment;
      } else {
        comment!.comment = "";
      }
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Retrieves the group facilities with CBD from the repository and updates the state.
  ///
  /// This method is called when the page is first loaded. It retrieves the group
  /// facilities with CBD from the repository and logs the fetched details. If the
  /// fetch is successful, it updates the state with the fetched details. If an
  /// error occurs during the process, the loading status is set to error.
  Future<void> getGroupInformation() async {
    try {
      groupFacilitiesWithCDB = await repository!.getGroupInformation();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Saves the present request form data to the server.
  /// If the form is valid, it saves the form data, and then calls
  /// [GroupInformationRepository.saveGroupFacilitiesWithCbd] to save the form data to
  /// the server. If there is an error, it emits a new [FacilitiesWithCbdState] with
  /// the loader status set to [LoadingStatus.error].
  ///
  /// If the save is successful, it navigates to the next page.
  Future<void> onSaveButtonPressed() async {
    try {
      // if (formKey.currentState!.validate()) {
      formKey.currentState?.save();
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      // await CommonRepository.instance.saveComment(comment!);
      // await CommonRepository.instance.saveApplicationStrategyDetails(
      //     ServerConstants.groupStrategyCommentsType,
      //     ServerConstants.groupAppStrategyCommentsId,
      //     comment!);
      LayoutViewModel().goToNextRoute();
      // }

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }
}
