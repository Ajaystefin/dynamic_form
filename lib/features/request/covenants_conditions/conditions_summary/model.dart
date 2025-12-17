import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/reference_data_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/text_utils.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/view.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/models/request/covenant_condtion/covenant_condition.dart';
import 'package:wcas_frontend/repositories/auth_repository.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';
import 'package:wcas_frontend/repositories/covenant_condition_repository.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

class ConditionsSummaryViewModel extends Cubit<ConditionsSummaryState> {
  ConditionsSummaryViewModel()
      : super(ConditionsSummaryState(loaderStatus: LoadingStatus.loading));
  CovenantConditionRepository repository = CovenantConditionRepository();
  CommonRepository commonRepo = CommonRepository();
  RequestRepository requestRepo = RequestRepository();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final HtmlEditorController controller = HtmlEditorController();
  BuildContext? context;
  String? strategyComment = '';
  int? isCovenant = 0;
  Request? request;
  List<CovenantCondition> conditions = [];

  // Comments
  List<Comment> comments = [];
  Comment comment = Comment();

  ReferenceDataService referenceDataService = ReferenceDataService();
  Map<String, List<Reference>> referenceData = {};
  //paging
  final int rowsPerPage = 10;
  PageMode pageMode = PageMode.na;

  bool get isReadOnlyMode => pageMode == PageMode.view;
  bool get isViewOnlyMode => pageMode == PageMode.na;

  /// Initializes the `CovenantsSummaryViewModel` by fetching covenant conditions,
  /// comments, and top section details from the repository.
  ///
  /// This method sets up the repository instance and attempts to retrieve
  /// the necessary data asynchronously. If any error occurs during the
  /// data fetching process, it logs the error and updates the state to reflect
  /// a loading error.
  ///
  /// Emits:
  /// - Updated state with fetched data on success.
  /// - Updated state with `LoadingStatus.error` on failure.
  ///
  /// Logs:
  /// - Initialization start and any errors encountered.
  Future<void> init(context) async {
    logger.i('initialising CovenantsSummaryViewModel');
    repository = CovenantConditionRepository();
    commonRepo = CommonRepository();
    requestRepo = RequestRepository();
    pageMode = AuthRepository.getPageMode(RightConstants.conditionsSummary);
    await loadReferenceData();
    try {
      await getConditions();
      await getComments(
          CommentsType.conditionsSummary, EntityIdentifier.conditionsSummary);
      request = Globals.request;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      logger.e("Error Fetching : $e");
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      AlertManager().showFailureToast("common.error".tr());
    }
  }

  Future<void> getConditions() async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    conditions = await repository.getConditions();
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
  Future<void> getComments(
      CommentsType type, EntityIdentifier entityIdentifier) async {
    try {
      comments = await commonRepo.getComments(type, entityIdentifier);
      logger.d(comments);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Validates and saves the strategy comment using the repository.
  ///
  /// This method first checks if the form is valid. If validation passes,
  /// it saves the form state and sends the comment to the backend via the
  /// `saveComments` API. If an error occurs during the process, it displays
  /// a failure toast and updates the state to reflect an error.
  ///
  /// Parameters:
  /// - [ifNavigate] (optional): A flag indicating whether to navigate after saving. Defaults to `false`.
  ///
  /// Emits:
  /// - Updated state with `LoadingStatus.error` if an exception occurs.
  ///
  /// Logs:
  /// - The comment being saved.
  ///
  /// Shows:
  /// - A failure toast if an exception is thrown.
  Future<void> saveComment() async {
    if (comment.comment == null) {
      // nav to next page
      LayoutViewModel().goToNextRoute();
      return;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    try {
      Comment saveComment = Comment.fromInputData(
          type: CommentsType.conditionsSummary,
          entityType: EntityIdentifier.conditionsSummary,
          comment: comment.comment,
          categoryId:
              ServerConstants.commentTypeId[CommentsType.conditionsSummary]);

      comment.draft = false;

      await CommonRepository.instance.saveComment(
        saveComment,
      );
      AlertManager().showSuccessToast("common.commentSaveSuccess".tr());
      //Nav to next page
      LayoutViewModel().goToNextRoute();
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Deletes a specified covenant condition and refreshes the condition list.
  ///
  /// This method attempts to delete the provided [conditionData] using the
  /// repository's `deleteCovenantCondition` method. Upon successful deletion,
  /// it shows a success toast and refreshes the list of covenant conditions.
  /// If an error occurs, it displays a failure toast and updates the state
  /// to reflect an error.
  ///
  /// Parameters:
  /// - [conditionData]: The `CovenantCondition` object to be deleted.
  ///
  /// Emits:
  /// - Updated state with `LoadingStatus.error` if an exception occurs.
  ///
  /// Logs:
  /// - The condition data being deleted.
  ///
  /// Shows:
  /// - A success toast on successful deletion.
  /// - A failure toast if an exception is thrown.
  Future<void> onDeleteCondition(
      CovenantCondition conditionData, int index) async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      logger.i(conditionData);
      conditionData.isDeleted = true;
      conditionData.isCovenant = false;
      conditionData.mode = TypeMode.edit.name.capitalizeFirstLetter();
      String? result = await requestRepo.saveConditionDetails(conditionData);
      AlertManager().showSuccessToast(result);
      conditions.removeAt(index);
      //  = await repository.getCovenants();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(
        e.toString(),
      );
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

//To show the condition information create / Update dialogue
  Future<void> showConditionCreate(BuildContext context,
      {CovenantCondition? condition}) async {
    DialogHelper.showCustomDialog(
        context: context,
        width: Scale.scaleHorizontally(800),
        title: "covenantsConditions.conditionsEditDialog.conditionInfo".tr(),
        content: ConditionEditDialogView(
          condition: condition,
        )).then((_) async {
      try {
        await getConditions();
      } catch (e) {
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        AlertManager().showFailureToast("common.error".tr());
      }
    });
  }

  String getReferenceName(List<Reference>? list, int? id) {
    if (list == null || id == null) return '';
    return list
            .firstWhere(
              (ref) => ref.id == id,
              orElse: () => Reference(name: ''),
            )
            .name ??
        '';
  }

  /// Loads reference data for search criteria, segment types, region list,
  /// advance request types, and role types. Populates the [referenceData] map
  /// with the fetched data. If an error occurs during the fetching process,
  /// it updates the loader status to [LoadingStatus.error].
  Future<void> loadReferenceData() async {
    try {
      referenceData = await referenceDataService.getReferenceData([
        ReferenceDataKeys.conditionDescriptionTemplate,
        ReferenceDataKeys.conditionAction,
        ReferenceDataKeys.conditionFrequency,
        ReferenceDataKeys.conditionGeneral,
        ReferenceDataKeys.conditionStandard,
        ReferenceDataKeys.conditionStatus,
        ReferenceDataKeys.covenantConditionType,
      ]);
    } catch (e) {
      AlertManager().showFailureToast("common.error".tr());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      rethrow;
    }
  }
}
