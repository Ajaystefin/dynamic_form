import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/models/request/profitability/relationship_profitability_detailed.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';

import 'package:wcas_frontend/repositories/profitability_repository.dart';
import 'state.dart';

class RelationshipProfitabilityDetailedViewModel
    extends Cubit<RelationshipProfitabilityDetailedState> {
  RelationshipProfitabilityDetailedViewModel()
      : super(RelationshipProfitabilityDetailedState(
            loaderStatus: LoadingStatus.loading));
  late ProfitabilityRepository repository;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<RelationshipProfitabilityDetailed> relProfitDet = [];
  BuildContext? context;
  Request? request;
  String? strategyComment;

  // Comments
  List<Comment> comments = [];
  Comment? comment;

  //paging
  int page = 0;
  final int rowsPerPage = 5;

  /// Initializes the [RelationshipProfitabilityDetailedViewModel] by:
  ///
  /// - Logging the initialization process.
  /// - Retrieving a singleton instance of [ProfitabilityRepository].
  /// - Fetching strategy comments and assigning them to [strategyComment].
  /// - Updating the state to indicate that loading is complete.
  ///
  /// This method should be called during the ViewModel's setup phase to ensure
  /// all necessary data is loaded before the UI renders.
  Future<void> init(context) async {
    logger.i('initialising RelationshipProfitabilityDetailedViewModel');
    repository = ProfitabilityRepository.instance;
    request = Globals.request;
    relProfitDet = await repository.getRelationProfitDetData();
    await getComments();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Fetches comments for a given entity and comment type.
  ///
  /// This asynchronous method retrieves comments from the [CommonRepository]
  /// based on the specified [type] and [entityIdentifier]. If the fetch fails,
  /// an error toast is displayed using [AlertManager].
  ///
  /// Parameters:
  /// - [type]: The type of comments to retrieve (e.g., general, feedback).
  /// - [entityIdentifier]: The identifier for the entity associated with the comments.
  ///
  /// Returns:
  /// - A [Future] that completes when the comments are successfully fetched or
  ///   an error is handled.
  Future<void> getComments() async {
    try {
      comments = await CommonRepository().getComments(
          CommentsType.covenantsSummary, EntityIdentifier.covenantsSummary);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Saves the strategy comment entered in the form and handles the result.
  ///
  /// This method performs the following steps:
  /// - Validates the form using [formKey].
  /// - If validation passes, saves the form state and logs the [strategyComment].
  /// - Sends the comment to the repository via [saveComments].
  /// - If an exception occurs during the process, displays a failure toast
  ///   and updates the state to [LoadingStatus.error] for [covenantsSummaryLoader].
  ///
  /// Parameters:
  /// - [ifNavigate] (optional): A flag indicating whether to navigate after saving. Currently unused.
  ///
  /// This method is asynchronous and should be awaited.
  Future<void> saveComment({bool ifNavigate = false}) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    try {
      comment?.commentId = "2";
      comment?.applicationRefNo = Globals.request?.applicationRefNo;
      comment?.draft = false;
      comment?.userId = Globals.user?.id;
      comment?.userRole = Globals.user?.currentRole?.roleId;
      comment?.reviewCommentId = "345";
      comment?.type = CommentsType.covenantsSummary;
      comment?.entityType = EntityIdentifier.covenantsSummary;

      // String responseMessage =
      //     await CommonRepository.instance.saveComment(comment!);
      // AlertManager().showSuccessToast(responseMessage);
      if (ifNavigate) {
        LayoutViewModel().goToNextRoute();
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}
