import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';

import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

/// ViewModel for managing the state and logic of the Group Summary screen.
///
/// This class handles tab switching, form validation, saving comments,
/// and updating the UI state using the BLoC pattern.
class GroupSummaryViewModel extends Cubit<GroupSummaryState> {
  /// Constructor initializes the state with a loading status.
  GroupSummaryViewModel()
      : super(const GroupSummaryState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for handling request-related operations.
  late RequestRepository repository;

  /// Controller for the HTML editor used to input group summary comments.
  HtmlEditorController controller = HtmlEditorController();

  /// Global key for validating the group summary form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Comments
  List<Comment> comments = [];
  Comment? comment;

  /// Initializes the ViewModel by setting up the repository and updating the loader status.
  ///
  /// Logs the initialization and sets the loader status to `loaded`.
  ///
  /// [context] - The build context used for localization and navigation.
  void init(context) async {
    logger.i('initialising GroupSummaryViewModel');
    repository = RequestRepository.instance;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles tab switching in the Group Summary screen.
  ///
  /// Emits a loading state, simulates a delay (e.g., for data fetching),
  /// and then updates the active tab and loader status.
  ///
  /// [tab] - The selected tab to switch to.
  void changeTab(GroupSummaryTabs tab) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    // Simulate API call or data loading
    await Future.delayed(const Duration(seconds: 1));
    emit(state.copyWith(
      loaderStatus: LoadingStatus.loaded,
      activeTab: tab,
    ));
  }

  //get active for label heading
  String getTabLabel(GroupSummaryTabs tab) {
    return TabConstants.groupSummaryTitles[tab]!.tr();
  }

  /// Handles the save button press logic.
  ///
  /// Validates the comments field, extracts plain text from the HTML editor,
  /// and shows appropriate success or failure toasts. Updates the loader status accordingly.
  ///
  /// [context] - The build context used for localization and toast display.
  Future<void> onSavePress(
    bool isContinue, {
    required BuildContext context,
  }) async {
    try {
      final rawHtml = await controller.getText();
      final newComment = rawHtml
          .replaceAll(RegExp(r'<[^>]*>'), '') // remove HTML tags
          .replaceAll('&nbsp;', ' ') // handle non-breaking spaces
          .trim();

      if (rawHtml.isEmpty) {
        AlertManager().showFailureToast(
          'approval.groupSummary.pleaseEnterSummary'.tr(),
        );
        return;
      }

      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();
        emit(state.copyWith(loaderStatus: LoadingStatus.loading));
        saveComment(newComment);
        AlertManager().showSuccessToast(
          "approval.groupSummary.savedSuccessfully".tr(),
        );
        if (isContinue && context.mounted) {
          navigate(context);
        }
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  Future<void> saveComment(String newComment) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));

    try {
      comment = Comment.fromInputData(
        comment: newComment,
        type: CommentsType.approval,
        entityType: EntityIdentifier.approval,
        categoryId: ServerConstants.commentTypeId[CommentsType.approval]!,
      );

      await CommonRepository.instance.saveComment(comment!);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  void navigate(BuildContext context) {
    bool isCurrentRouteFound = false;
    for (MapEntry<GroupSummaryTabs, String> entry
        in TabConstants.groupSumaryRoutes.entries) {
      if (isCurrentRouteFound) {
        // can move to next tab/route
        changeTab(entry.key);
        return;
      }
      if (entry.key == state.activeTab) {
        isCurrentRouteFound = true;
      }
    }
    LayoutViewModel().goToNextRoute();
  }
}
