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
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/view.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/models/request/covenant_condtion/covenant.dart';
import 'package:wcas_frontend/repositories/auth_repository.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';
import 'package:wcas_frontend/repositories/covenant_condition_repository.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'state.dart';

class CovenantsSummaryViewModel extends Cubit<CovenantsSummaryState> {
  CovenantsSummaryViewModel()
      : super(CovenantsSummaryState(
            loaderStatus: LoadingStatus.loading,
            covenantsSummaryLoader: LoadingStatus.loaded));
  late CovenantConditionRepository repository;
  List<Covenant> covenant = [];
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  HtmlEditorController controller = HtmlEditorController();
  BuildContext? context;
  Request? request;
  String? strategyComment;
  int? isCovenant = 1;
  Map<String, List<Reference>> referenceData = {};

  // Comments
  List<Comment> comments = [];
  Comment? comment;

  List<Reference>? covenantType = [];
  List<Reference>? covenantSubtype = [];
  List<Reference>? frequency = [];
  List<Reference>? action = [];
  List<Reference>? status = [];
  List<Reference>? covenantGeneralSpecific = [];

  //paging
  final int rowsPerPage = 10;
  PageMode pagemode = PageMode.na;
  bool get isReadOnly => pagemode == PageMode.view;

  /// Initializes the [CovenantsSummaryViewModel] by loading necessary data.
  ///
  /// This method performs the following steps:
  /// - Logs the start of the initialization process.
  /// - Retrieves a singleton instance of [CovenantConditionRepository].
  /// - Fetches the list of covenant conditions and assigns it to [_covenant].
  /// - Fetches associated comments and assigns them to [_comment].
  /// - Calls [getTopSectionDetails] to load additional summary information.
  /// - If any error occurs during data fetching, logs the error and updates the state to [LoadingStatus.error].
  ///
  /// This method should be called during the ViewModel's setup phase to ensure
  /// all required data is available for the UI.
  Future<void> init(context) async {
    logger.i('initialising CovenantsSummaryViewModel');
    pagemode = AuthRepository.getPageMode(RightConstants.covenantsSummary);
    debugPrint(pagemode.toString());
    repository = CovenantConditionRepository.instance;
    loadReferenceData();
    try {
      covenant = await repository.getCovenants(isCovenant);
      await getComments(
          CommentsType.covenantsSummary, EntityIdentifier.covenantsSummary);
      request = Globals.request;
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
  }

  Future<void> fetchCovenants() async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    covenant = await repository.getCovenants(isCovenant);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> loadReferenceData() async {
    try {
      referenceData = await ReferenceDataService().getReferenceData([
        ReferenceDataKeys.covenantType,
        ReferenceDataKeys.covenantConditionAction,
        ReferenceDataKeys.covenantConditionStatus,
        ReferenceDataKeys.covenantFrequency,
        ReferenceDataKeys.covenantAuditStatus,
        ReferenceDataKeys.covenantSubmissionTime,
        ReferenceDataKeys.covenantBasicSeperation,
        ReferenceDataKeys.covenantPeriod,
        ReferenceDataKeys.covenantSubtype,
        ReferenceDataKeys.thresholdType,
        ReferenceDataKeys.covenantGeneralSpecific,
      ]);
      covenantType = referenceData[ReferenceDataKeys.covenantType] ?? [];
      covenantSubtype = referenceData[ReferenceDataKeys.covenantSubtype] ?? [];
      frequency = referenceData[ReferenceDataKeys.covenantFrequency] ?? [];
      action = referenceData[ReferenceDataKeys.covenantConditionAction] ?? [];
      status = referenceData[ReferenceDataKeys.covenantConditionStatus] ?? [];
      covenantGeneralSpecific =
          referenceData[ReferenceDataKeys.covenantGeneralSpecific] ?? [];
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      rethrow;
    }
  }

  Future<void> showCovenantCreate(BuildContext context,
      {Covenant? condition}) async {
    DialogHelper.showCustomDialog(
            context: context,
            width: Scale.scaleHorizontally(800),
            title: "covenantsConditions.covenantEditDialog.covenantInfo".tr(),
            content: const CovenantEditDialogView(isNew: true))
        .then((_) async {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));
      covenant = await repository.getCovenants(isCovenant);
      if (covenant.isEmpty) {
        emit(state.copyWith(
          loaderStatus: LoadingStatus.error,
        ));
        return;
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
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

  String getGeneralSpecificName(List<Reference>? list, int? id) {
    if (list == null || id == null) return '';
    return list
            .firstWhere(
              (ref) => ref.id == id,
              orElse: () => Reference(name: ''),
            )
            .name ??
        '';
  }

  void addCovenant() {
    emit(state.copyWith(covenantsSummaryLoader: LoadingStatus.loaded));
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
    // String rawHtml = await controller.getText();
    // String newComment = rawHtml
    //     .replaceAll(RegExp(r'<[^>]*>'), '') // remove HTML tags
    //     .replaceAll('&nbsp;', ' ') // handle non-breaking spaces
    //     .trim();

    comment ??= Comment();
    comment!
      ..applicationRefNo = Globals.request?.applicationRefNo
      ..userId = Globals.user?.id
      ..userRole = Globals.user?.currentRole?.roleId
      ..comment =
          // Utils.checkBusinessSegment(BusinessSegment.financialInstitution)
          //     ? newComment
          // :
          comment?.comment
      ..categoryId =
          ServerConstants.commentTypeId[CommentsType.covenantsSummary]!;

    try {
      await CommonRepository.instance.saveComment(comment!);
      if (!isReadOnly) {
        AlertManager().showSuccessToast(
            "covenantsConditions.conditionsEditDialog.savedSuccefully".tr());
      }
      if (ifNavigate) {
        LayoutViewModel().goToNextRoute();
      }
    } catch (e) {
      logger.e('saveComment failed: $e');
      AlertManager().showFailureToast(e.toString());
    } finally {
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    }
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
      comments =
          await CommonRepository.instance.getComments(type, entityIdentifier);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  /// Deletes a specific covenant covenant and updates the covenant list.
  ///
  /// This method performs the following steps:
  /// - Logs the covenant data to be deleted.
  /// - Calls the repository to delete the specified [covenantData], using the [isCovenant] flag.
  /// - Refreshes the [_covenant] list by fetching the updated data from the repository.
  /// - Displays a success toast with the result message upon successful deletion.
  /// - If an error occurs, displays a failure toast and updates the state to [LoadingStatus.error]
  ///   for [covenantsSummaryLoader].
  ///
  /// Parameters:
  /// - [covenantData]: The [CovenantCondition] object to be deleted.
  ///
  /// This method is asynchronous and should be awaited.
  /// In your CovenantsSummaryViewModel (or wherever you keep your list):
  Future<void> onDeleteCovenant(
    Covenant covenatDelete,
    int index,
  ) async {
    try {
      emit(state.copyWith(loaderStatus: LoadingStatus.loading));

      covenatDelete.isDeleted = true;
      covenatDelete.isNew = false;
      covenatDelete.isCovenant = true;
      // String covenantMode = ServerConstants.covenantEdit;
      final raw = covenatDelete.toDeleteJson(Globals.request?.applicationRefNo);
      await repository.saveCovenantDetails(
        [raw], isCovenant,
        //  covenantMode
      );

      covenant = await repository.getCovenants(isCovenant);

      if (covenant.isEmpty) {
        emit(state.copyWith(loaderStatus: LoadingStatus.error));
        return;
      }

      AlertManager().showSuccessToast(
          "covenantsConditions.conditionsEditDialog.savedSuccefully".tr());
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }
}
