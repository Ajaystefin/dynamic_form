import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';
import 'state.dart';

/// ViewModel for managing the state and logic of the Credit Assessment screen.
///
/// This class handles initialization, form validation, saving remarks,
/// and navigation to the next screen. It uses BLoC for state management.
class CreditAssessmentViewModel extends Cubit<CreditAssessmentState> {
  /// Constructor initializes the state with a loading status.
  CreditAssessmentViewModel()
      : super(CreditAssessmentState(loaderStatus: LoadingStatus.loading));

  /// Repository instance for handling request-related operations.
  late RequestRepository repository;

  /// Controller for the HTML editor used to input RM comments.
  HtmlEditorController controller = HtmlEditorController();

  /// Global key for validating the RM comments form.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Initializes the ViewModel by setting up the repository and updating the loader status.
  ///
  /// Logs the initialization and sets the loader status to `loaded`.
  ///
  /// [context] - The build context used for localization and navigation.
  Future<void> init(context) async {
    logger.i('initialising CreditAssessmentViewModel');
    repository = RequestRepository.instance;
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Handles the save button press logic.
  ///
  /// Validates the RM comments field, extracts plain text from the HTML editor,
  /// and shows appropriate success or failure toasts. If `isContinue` is true,
  /// navigates to the proposed facilities screen.
  ///
  /// [isContinue] - Whether to navigate to the next screen after saving.
  /// [context] - The build context used for navigation and localization.
  Future<void> onSavePress({
    bool isContinue = false,
    required BuildContext context,
  }) async {
    try {
      final rawHtml = await controller.getText();
      final plainText = rawHtml
          .replaceAll(RegExp(r'<[^>]*>'), '') // remove HTML tags
          .replaceAll('&nbsp;', ' ') // handle non-breaking spaces
          .trim();

      if (plainText.isEmpty) {
        AlertManager().showFailureToast(
          'approval.creditAssessment.pleaseEnterRemarks'.tr(),
        );
        return;
      }

      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();
        emit(state.copyWith(loaderStatus: LoadingStatus.loading));

        if (isContinue && context.mounted) {
          LayoutViewModel().goToNextRoute();
        }

        AlertManager().showSuccessToast(
          "approval.creditAssessment.savedSuccessfully".tr(),
        );
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }
}
