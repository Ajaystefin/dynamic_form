import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
import 'package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart';
import 'state.dart';

class QueriesAndResponsesViewModel extends SafeCubit<QueriesAndResponsesState> {
  QueriesAndResponsesViewModel()
      : super(QueriesAndResponsesState(loaderStatus: LoadingStatus.loading));
  late ApprovalRepository repository;
  late RequestRepository requestRepository;
  int? rowsPerPage = 5;
  List<Comment> comments = [];
  Comment? comment;
  UnifiedEditorController controller = UnifiedEditorController();
  final ScrollController scrollController = ScrollController();
  bool isReadOnly = true;
  String initialText = "";
  bool canSubmit = false;

  void init(context) async {
    logger.i('initialising QueriesAndResponsesViewModel');
    repository = ApprovalRepository.instance;
    requestRepository = RequestRepository.instance;
    await getComments();
    await requestRepository.getApplicationDetails();
    await repository.fetchReference();
    isReadOnly = Globals.checkAccessbility()['isReadOnly'] ?? true;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onTextChange(String text) async {
    final plainText = text
        .replaceAll(RegExp(r'<[^>]*>'), '') // remove HTML tags
        .replaceAll('&nbsp;', ' ') // handle non-breaking spaces
        .trim();
    canSubmit = plainText.trim().isNotEmpty;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void onSavePress(
      {required BuildContext context, bool isContinue = false}) async {
    try {
      debugPrint("Inside onSavePress");
      final String rawHtml = await controller.getText();

      emit(state.copyWith(loaderStatus: LoadingStatus.loading));

      comment = Comment.fromInputData(
          type: CommentsType.queriesResponses,
          entityType: EntityIdentifier.queriesResponses,
          categoryId:
              ServerConstants.commentTypeId[CommentsType.queriesResponses],
          comment: rawHtml);

      // comment?.commentId = "2";
      // comment?.draft = false;
      // comment?.reviewCommentId = "345";

      debugPrint("Comment value : ${comment?.toJson().toString()}");

      await CommonRepository.instance.saveComment(comment!);
      AlertManager()
          .showSuccessToast("approval.creditAssessment.savedSuccessfully".tr());
      if (isContinue) {
        LayoutViewModel().goToNextRoute();
      }
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));

      if (context.mounted) {
        context.read<QueriesAndResponsesViewModel>().init(context);
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }

  Future<void> getComments() async {
    try {
      // comments = await repository.getQueryResponse();
      comments = await CommonRepository.instance.getComments(
          CommentsType.queriesResponses, EntityIdentifier.queriesResponses);
      if (comments.isNotEmpty) {
        comment = comments
            .reduce((a, b) => a.createdDate!.isAfter(b.createdDate!) ? a : b);
        initialText = comment?.comment ?? "";
        controller.setText(initialText);
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
  }
}
