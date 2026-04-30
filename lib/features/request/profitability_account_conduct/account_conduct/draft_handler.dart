import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";

// ignore: avoid_relative_lib_imports — intentional same-feature import
import "package:wcas_frontend/features/request/profitability_account_conduct/account_conduct/model.dart";

/// Draft handler for the Business Volume / Account Conduct screen.
/// Handles serialization and restoration of per-row field values.
class AccountConductDraftHandler extends DraftHandler<AccountConductViewModel> {
  @override
  Map<String, dynamic> buildDraftData(AccountConductViewModel vm) {
    // Make sure any FormField.onSaved is flushed.
    vm.formKey.currentState?.save();

    // Sync latest text controllers back into the in-memory DTOs.
    vm.syncCustomersFromControllers();

    // Convert customers to a lightweight draft-friendly map structure.
    final customersDraft = <Map<String, dynamic>>[];
    for (final dto in vm.customers) {
      customersDraft.add({
        "passDueOrExcesses": dto.passDueOrExcesses,
        "chequeReturns": dto.chequeReturns,
        "turnoverInAcc": dto.turnoverInAcc,
        "odHardcore": dto.odHardcore,
        "unusualTransactions": dto.unusualTransactions,
        "transparencyDisclosureLevels": dto.transparencyDisclosureLevels,
      });
    }

    return <String, dynamic>{
      // 'comments': vm.comments,
      "customers": customersDraft,
      // Optional: persist headers too, in case labels are dynamic per request
      "previousYearHeader": vm.previousYearHeader,
      "currentYearHeader": vm.currentYearHeader,
    };
  }

  @override
  void applyDraft(AccountConductViewModel vm, Map<String, dynamic> data) {
    final customersDraft =
        (data["customers"] as List?)?.cast<Map<String, dynamic>>();
    if (customersDraft == null || customersDraft.isEmpty) return;

    // 1) Prefer merge-by-rimNo (stable identity). Build lookup.
    final Map<String, Map<String, dynamic>> byRim = {};
    for (final row in customersDraft) {
      final key = row["rimNo"]
          ?.toString(); // include rimNo in buildDraftData if possible
      if (key != null && key.isNotEmpty) {
        byRim[key] = row;
      }
    }

    final bool canMergeByRim = byRim.isNotEmpty;

    if (canMergeByRim) {
      // Merge by RIM: update only edited fields, keep identifiers/nested data intact
      for (int i = 0; i < vm.customers.length; i++) {
        final dto = vm.customers[i];
        final rimKey = dto.rimNo?.toString();
        if (rimKey == null || rimKey.isEmpty) continue;

        final edited = byRim[rimKey];
        if (edited == null) continue;

        vm.customers[i] = dto.copyWith(
          passDueOrExcesses: edited["passDueOrExcesses"]?.toString(),
          chequeReturns: edited["chequeReturns"]?.toString(),
          turnoverInAcc: edited["turnoverInAcc"]?.toString(),
          odHardcore: edited["odHardcore"]?.toString(),
          unusualTransactions: edited["unusualTransactions"]?.toString(),
          transparencyDisclosureLevels:
              edited["transparencyDisclosureLevels"]?.toString(),
        );
      }
    } else {
      final int n = (vm.customers.length < customersDraft.length)
          ? vm.customers.length
          : customersDraft.length;

      for (int i = 0; i < n; i++) {
        final dto = vm.customers[i];
        final edited = customersDraft[i];

        vm.customers[i] = dto.copyWith(
          passDueOrExcesses: edited["passDueOrExcesses"]?.toString(),
          chequeReturns: edited["chequeReturns"]?.toString(),
          turnoverInAcc: edited["turnoverInAcc"]?.toString(),
          odHardcore: edited["odHardcore"]?.toString(),
          unusualTransactions: edited["unusualTransactions"]?.toString(),
          transparencyDisclosureLevels:
              edited["transparencyDisclosureLevels"]?.toString(),
        );
      }
    }

    // 3) MINIMAL RESEED: push the merged values into the controllers used by
    // the UI
    String clean(String? s) => (s == null || s == "null") ? "" : s;

    for (int i = 0; i < vm.customers.length; i++) {
      final dto = vm.customers[i];

      vm.controllerFor("passDueOrExcesses", i).text =
          clean(dto.passDueOrExcesses);
      vm.controllerFor("chequeReturns", i).text = clean(dto.chequeReturns);
      vm.controllerFor("turnoverInAcc", i).text = clean(dto.turnoverInAcc);
      vm.controllerFor("odHardcore", i).text = clean(dto.odHardcore);
      vm.controllerFor("unusualTransactions", i).text =
          clean(dto.unusualTransactions);
      vm.controllerFor("transparencyDisclosureLevels", i).text =
          clean(dto.transparencyDisclosureLevels);
    }

    // 4) OPTIONAL: if your row count/order can change after draft apply, request a lightweight rebuild.
    // If you have a public VM method for this, call that instead.
    try {
      vm.emit(vm.state.copyWith());
    } catch (_) {
      // ignore if not allowed from handler
    }
  }
}
