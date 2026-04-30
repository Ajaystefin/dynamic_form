// income_summary_draft_handler.dart
import "dart:convert";
import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";

// ignore: avoid_relative_lib_imports
import "package:wcas_frontend/features/request/profitability_account_conduct/income_summary/model.dart";

/// Draft handler for the Income Summary screen.
/// Expects `rawData` to be the payload only (as provided by
/// loadDraftIfAvailable()).
class IncomeSummaryDraftHandler extends DraftHandler<IncomeSummaryViewModel> {
  @override
  Map<String, dynamic> buildDraftData(IncomeSummaryViewModel vm) {
    try {
      vm.formKey.currentState?.save();
    } catch (_) {}

    String? nz(String? s) {
      final t = s?.trim();
      return (t != null && t.isNotEmpty) ? t : null;
    }

    // Ensure model mirrors controller before serialising (in case onSaved
    // didn’t run)
    final String currentText = vm.rmCommentsController.text;
    final String? normalised =
        currentText.trim().isEmpty ? vm.rmComments : currentText.trim();

    return <String, dynamic>{
      "rmComments": nz(normalised ?? vm.rmComments),
    };
  }

  @override
  void applyDraft(IncomeSummaryViewModel vm, Map<String, dynamic> rawData) {
    if (rawData.isEmpty) return;

    try {
      Map<String, dynamic> data = rawData;

      // Edge case: payload may still be nested as a JSON string in
      // rawData['payload']
      final dynamic maybePayload = rawData["payload"];
      if (maybePayload is String && maybePayload.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(maybePayload);
          if (decoded is Map) {
            data = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      } else if (maybePayload is Map) {
        data = Map<String, dynamic>.from(maybePayload);
      }

      final Object? raw = data["rmComments"];
      final String? drafted = (raw is String) ? raw.trim() : null;
      final String? normalized =
          (drafted != null && drafted.isNotEmpty) ? drafted : null;

      // Update VM model and controller
      vm.rmComments = normalized;
      vm.rmCommentsController.text = normalized ?? "";

      // Light rebuild so widgets depending on state also refresh
      // ignore: invalid_use_of_protected_member
      vm.emit(vm.state.copyWith());
    } catch (_) {
      // Ignore malformed drafts
    }
  }
}
