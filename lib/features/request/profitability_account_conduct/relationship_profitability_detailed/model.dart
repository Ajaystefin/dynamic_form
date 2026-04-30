import "dart:async";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/core/services/draft/draft_mixin.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_detailed/draft_handler.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_detailed/state.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/profitability/relationship_profitability_detailed.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/profitability_repository.dart";

class RelationshipProfitabilityDetailedViewModel
    extends SafeCubit<RelationshipProfitabilityDetailedState>
    with DraftMixin<RelationshipProfitabilityDetailedViewModel> {
  RelationshipProfitabilityDetailedViewModel()
      : super(
          RelationshipProfitabilityDetailedState(
            loaderStatus: LoadingStatus.loading,
          ),
        );

  late ProfitabilityRepository repository;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<RelationshipProfitabilityDetailed> relProfitDet = [];

  BuildContext? context;
  Request? request;

  String? strategyComment;
  Comment? commentData;

  final TextEditingController strategyCommentController =
      TextEditingController();

  int page = 0;
  final int rowsPerPage = 5;

  // ---------------------------------------------------------------------------
  // DraftMixin implementation
  // ---------------------------------------------------------------------------

  @override
  String get draftModuleKey => DraftModuleKeys.profitabilityAndAccountConduct;

  @override
  String get draftFormKey => Routes.relationshipProfitabilityDetailed;

  @override
  DraftHandler<RelationshipProfitabilityDetailedViewModel> get draftHandler =>
      RelationshipProfitabilityDetailedDraftHandler();

  // ---------------------------------------------------------------------------

  /// Initializes the RelationshipProfitabilityDetailedViewModel.
  ///
  /// This function sets up the repository, logs the initialization
  /// process, retrieves business volume data, and updates the loader status.
  ///
  /// [context] - The BuildContext, if needed for additional initialization
  /// steps.
  ///

  PageMode pageMode = PageMode.na;
  bool get canEdit => (pageMode == PageMode.edit);

  Future<void> init(BuildContext context) async {
    logger.i("initialising RelationshipProfitabilityDetailedViewModel");
    this.context = context;
    pageMode = AuthRepository.getPageMode(
      RightConstants.relationshipProfitabilityDetailed,
    );

    strategyCommentController.addListener(() {
      strategyComment = strategyCommentController.text;
    });

    try {
      repository = ProfitabilityRepository.instance;
      request = Globals.request;

      relProfitDet = await repository.getRelationProfitDetData();
      await getComments();
      if (canEdit) {
        registerDraftCallback();
        await loadDraftIfAvailable();
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e, st) {
      logger.e("init failed: $e", stackTrace: st);
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Save comment data for Relationship Profitability Detailed (strategy
  /// comment).
  Future<void> saveComments({bool isContinue = false}) async {
    try {
      //  Ensure the latest textarea value is captured
      formKey.currentState?.save();
      strategyComment = strategyCommentController.text.trim();
      // Optional: trim/normalize
      strategyComment = strategyComment?.trim();

      // Optional validation: if required or max length
      // if ((strategyComment ?? '').isEmpty) {
      //   AlertManager().showFailureToast('Please enter a comment');
      //   return;
      // }

      //  Keep the comment type consistent with the screen
      commentData = Comment.fromInputData(
        type: CommentsType.relationshipProfitabilityDetailed,
        strategyComment: strategyComment,
        entityType: EntityIdentifier.relationshipProfitabilityDetailed,
        categoryId:
            ServerConstants.relationshipProfitabilityDetailedCommentCategoryId,
        categoryType: ServerConstants
            .relationshipProfitabilityDetailedCommentCategoryType,
      );

      //  Use the correct commentTypeId for RelationshipProfitabilityDetailed
      final int typeId = ServerConstants
          .commentTypeId[CommentsType.relationshipProfitabilityDetailed]!;

      // If API expects a single typeId:
      final String? response =
          await CommonRepository.instance.saveApplicationStrategyDetails(
        typeId,
        typeId, // or remove this param if the method signature allows
        commentData,
      );

      // If API actually requires two IDs (e.g., type & subtype),
      // make sure they are distinct and correct:
      // final String? response =
      //     await CommonRepository.instance.saveApplicationStrategyDetails(
      //   typeId,
      //   ServerConstants.relationshipProfitabilityDetailedSubTypeId,
      //   commentData!,
      // );

      unawaited(deleteDraft());

      if (response != null && response.isNotEmpty) {
        AlertManager().showSuccessToast(response);
      }

      if (isContinue) {
        LayoutViewModel().goToNextRoute();
      }
    } catch (e, st) {
      logger.e("saveComments failed: $e", stackTrace: st);
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Fetch application strategy details (existing comment) for Relationship
  /// Profitability Detailed.
  Future<void> getComments() async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    try {
      final commentList =
          await CommonRepository.instance.getApplicationStrategyDetails(
        CommentsType.relationshipProfitabilityDetailed,
        EntityIdentifier.relationshipProfitabilityDetailed,
      );

      final relevantComments = commentList
          .where(
            (item) =>
                item.categoryId ==
                ServerConstants
                    .relationshipProfitabilityDetailedCommentCategoryId,
          )
          .toList();

      final String existing = relevantComments.isNotEmpty
          ? (relevantComments.first.strategyComment ?? "")
          : "";

      if (commentList.isNotEmpty) {
        commentList[0].strategyComment = existing;
      }

      strategyComment = existing;

      strategyCommentController.text = existing;

      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e, st) {
      logger.e("Error fetching strategy details: $e", stackTrace: st);
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }
}
