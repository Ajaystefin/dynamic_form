import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
// ignore: avoid_relative_lib_imports — intentional same-feature import
import "package:wcas_frontend/features/request/approval/queries_and_responses/model.dart";

/// Draft handler for the Queries & Responses screen.
///
/// Responsible for autosave serialization and restoring the draft so that
/// [QueriesAndResponsesViewModel] stays focused on business logic only.
///
/// Persisted fields:
/// - `initialText`: Plain text synced with the rich-text editor
/// - `canSubmit`: Whether editor text is considered valid
///
/// We intentionally do **not** persist:
/// - reviewCommentId
/// - comment history
/// - reference data / user lists
/// - transient server-provided flags
class QueriesAndResponsesDraftHandler
    extends DraftHandler<QueriesAndResponsesViewModel> {
  @override
  Map<String, dynamic> buildDraftData(QueriesAndResponsesViewModel vm) {
    // Flush form state in case any fields use onSaved().
    // vm.formKey.currentState?.save();
    final String draftText = vm.controller.currentText;

    return <String, dynamic>{
      // 'initialText': vm.initialText,
      "initialText": draftText,
      "canSubmit": vm.canSubmit,
    };
  }

  @override
  void applyDraft(QueriesAndResponsesViewModel vm, Map<String, dynamic> data) {
    // Restore text value & push into the rich text editor.
    final String? draftedText = data["initialText"] as String?;
    if (draftedText != null) {
      vm.initialText = draftedText;
      vm.controller.setText(draftedText);
    }

    // Restore canSubmit flag if present.
    final dynamic submitVal = data["canSubmit"];
    if (submitVal is bool) {
      vm.canSubmit = submitVal;
    }
  }
}
