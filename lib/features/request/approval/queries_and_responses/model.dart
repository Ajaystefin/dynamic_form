import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/repositories/approval_repository.dart';
import 'state.dart';

class QueriesAndResponsesViewModel extends Cubit<QueriesAndResponsesState> {
  QueriesAndResponsesViewModel()
      : super(QueriesAndResponsesState(loaderStatus: LoadingStatus.loading));
  late ApprovalRepository repository;
  int? rowsPerPage = 5;
  List<Comment> comments = [];
  Comment? comment;

  void init(context) async {
    logger.i('initialising QueriesAndResponsesViewModel');
    repository = ApprovalRepository.instance;
    await getComments();
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onSavePress({bool isContinue = false}) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    try {
      comment = Comment.fromInputData(
        type: CommentsType.approval,
        entityType: EntityIdentifier.approval,
        categoryId: ServerConstants.commentTypeId[CommentsType.approval]!,
      );

      comment?.commentId = "2";
      comment?.draft = false;
      comment?.reviewCommentId = "345";

      // String responseMessage =
      //     await CommonRepository.instance.saveComment(comment!);
      // AlertManager().showSuccessToast(responseMessage);
      if (isContinue) {
        LayoutViewModel().goToNextRoute();
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  Future<void> getComments() async {
    try {
      comments = await repository.getQueryResponse();
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }
}
