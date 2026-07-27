import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/customer_information/sic_code_review/model.dart";

/// Draft handler for the SIC Code Review screen.
///
/// Keeps [SicCodeReviewViewModel] focused on business logic by owning
/// autosave serialization/deserialization of minimal, user-entered state.
///
/// This mirrors the flat style of the attached sample draft handler:
/// - uses [buildDraftData] and [applyDraft]
/// - no custom schema/versioning
/// - persists only user-entered values needed to restore the screen quickly
class SicCodeReviewDraftHandler extends DraftHandler<SicCodeReviewViewModel> {
  /// Serializes current screen state to a JSON-safe map.
  ///
  /// We flush form onSaved callbacks (if any) and then capture only the
  /// user-entered account-level SIC comment. Complex tables/lists are
  /// intentionally excluded to keep drafts lightweight and robust.
  @override
  Map<String, dynamic> buildDraftData(SicCodeReviewViewModel vm) {
    vm.formKey.currentState?.save();

    final int? rim = vm.selectedCustomer?.customerRimNo;

    return <String, dynamic>{
      "rimNo": rim,
      "accountLevelComment": vm.comment.strategyComment,
      "sicReviews": vm.customerSICcodeReview
          ?.asMap()
          .entries
          .where((e) => e.value.rimNo == rim)
          .map(
            (e) => <String, dynamic>{
              "rowIndex": e.key, // <-- stable client key
              "rimNo": e.value.rimNo,
              "proposedSicCode": e.value.proposedSicCode, // may be null
            },
          )
          .toList(),
    };
  }

  /// Restores draft values into the live ViewModel.
  ///
  /// - Rehydrates [`vm.comment.strategyComment`]
  /// - Updates the bound [`controllerAccountLevelSicCode`]
  /// - Emits a no-op state change to refresh listeners
  @override
  void applyDraft(
    SicCodeReviewViewModel vm,
    Map<String, dynamic> data,
  ) {
    if (data.isEmpty) {
      return;
    }

    // 1) RIM validation — only apply if draft is for the current customer
    final int? currentRim = vm.selectedCustomer?.customerRimNo;
    final int? draftRim = int.tryParse(data["rimNo"]?.toString() ?? "");
    if (currentRim == null || draftRim == null || draftRim != currentRim) {
      return; // different customer → ignore draft
    }

    // 2) Restore account-level comment
    final Object? rawComment = data["accountLevelComment"];
    if (rawComment is String) {
      vm.comment.strategyComment = rawComment;
      vm.controllerAccountLevelSicCode.text = rawComment;
    }

    // 3) Restore SIC rows
    final List<dynamic>? draftedReviews = data["sicReviews"] as List<dynamic>?;
    String? normCode(v) {
      final s = v?.toString().trim();
      if (s == null || s.isEmpty || s.toLowerCase() == "null") {
        return null;
      }
      return s;
    }

    if (draftedReviews != null &&
        vm.customerSICcodeReview != null &&
        vm.customerSICcodeReview!.isNotEmpty) {
      for (final item in draftedReviews) {
        final int? rowRim = int.tryParse(item["rimNo"]?.toString() ?? "");
        final String? rowProposed = normCode(item["proposedSicCode"]);
        final int? rowIndex = int.tryParse(item["rowIndex"]?.toString() ?? "");

        if (rowRim == null || rowRim != currentRim) {
          continue;
        }

        // Prefer index-based restore when available (most robust)
        int idx = -1;
        if (rowIndex != null &&
            rowIndex >= 0 &&
            rowIndex < vm.customerSICcodeReview!.length) {
          idx = rowIndex;
        } else {
          // Backward-compatible fallback: try to match by previous
          // proposedSicCode
          idx = vm.customerSICcodeReview!.indexWhere(
            (r) =>
                r.rimNo == currentRim &&
                normCode(r.proposedSicCode) == rowProposed,
          );

          // If draft had null proposedSicCode, attach to a null/empty row for this rim
          if (idx == -1 && rowProposed == null) {
            idx = vm.customerSICcodeReview!.indexWhere(
              (r) =>
                  r.rimNo == currentRim && normCode(r.proposedSicCode) == null,
            );
          }
        }

        if (idx != -1) {
          final row = vm.customerSICcodeReview![idx];

          // ✅ THIS is the crucial part you were missing:
          // Write back the drafted value so the change (e.g., 1456) is
          // reflected,
          // even if the API still returns the old code (e.g., 1234) on first
          // load.
          if (rowProposed != null) {
            row.proposedSicCode = rowProposed;
          } else {
            // Keep as null if draft stored null (optional: leave untouched)
            row.proposedSicCode = null;
          }
        }
      }
    }

    // 4) Nudge UI
    vm.emit(vm.state.copyWith());
  }
}
