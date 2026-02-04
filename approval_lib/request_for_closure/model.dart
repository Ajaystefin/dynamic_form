import 'package:easy_localization/easy_localization.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/safe_cubit.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/repositories/approval_repository.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

class RequestForClosureViewModel extends SafeCubit<RequestForClosureState> {
  RequestForClosureViewModel()
      : super(RequestForClosureState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for handling request-related operations.
  late RequestRepository requestRepository;
  late ApprovalRepository repository;
  String? strategyComment;
  int? rowsPerPage = 5;
  UserRole? userRole = Globals.user?.currentRole!.userRole;
  bool canSubmit = false;
  bool isReadOnly = true;

  // Comments
  List<Comment>? comments = [];
  Comment? comment;

  void init(context) async {
    logger.i('initialising RequestForFolViewModel');
    repository = ApprovalRepository.instance;
    requestRepository = RequestRepository.instance;
    await requestRepository.getApplicationDetails();
    isReadOnly = Globals.checkAccessbility()['isReadOnly'] ?? true;
    // debugPrint("isReadOnly closure : $isReadOnly");
    await getComments(CommentsType.approval, EntityIdentifier.approval);
    await repository.fetchReference();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onTextChange(String plainText) async {
    canSubmit = plainText.trim().isNotEmpty;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
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

    comment ??= Comment();
    comment!
      ..applicationRefNo = Globals.request?.applicationRefNo
      ..userId = Globals.user?.id
      ..userRole = Globals.user?.currentRole?.roleId
      ..comment = strategyComment
      ..entityType = EntityIdentifier.requestForClosure
      ..categoryId = ServerConstants
          .commentCategoryId[CommentsCategory.requestForClosure]!;

    try {
      await CommonRepository.instance.saveComment(comment!);
      AlertManager().showSuccessToast("common.success".tr());
      if (ifNavigate) {
        LayoutViewModel().goToNextRoute();
      }
      await requestRepository.getApplicationDetails();
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
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
      comments =
          await CommonRepository.instance.getComments(type, entityIdentifier);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  Future<void> getApplicationStrategyDetails() async {
    try {
      comments = await repository.getApplicationStrategyDetails(
        CommentsType.creditAppraisal,
        EntityIdentifier.creditAssesment,
      );
      List<int?> categoryIds = [
        ServerConstants.approvalCategoryId[ApprovalCategory.groupManagement],
        ServerConstants.approvalCategoryId[ApprovalCategory.groupOverview],
        ServerConstants.approvalCategoryId[ApprovalCategory.groupRisk],
        ServerConstants.approvalCategoryId[ApprovalCategory.groupStrategy],
      ];

      final commentItem = comments
          ?.where((item) => categoryIds.contains(item.categoryId))
          .toList();

      if (comments != null && comments!.isNotEmpty) {
        comments?[0].strategyComment =
            commentItem != null && commentItem.isNotEmpty
                ? commentItem.first.strategyComment
                : "commentitem not matched";
      }

      logger.i('Strategy comment: $comments?[0].strategyComment');
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }
}
