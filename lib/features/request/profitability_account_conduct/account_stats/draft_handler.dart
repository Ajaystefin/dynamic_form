import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
// ignore: avoid_relative_lib_imports — intentional same-feature import
import "package:wcas_frontend/features/request/profitability_account_conduct/account_stats/model.dart";
import "package:wcas_frontend/models/request/profitability/account_stat.dart";

/// Draft handler for the Account Stats screen.
///
/// Owns all autosave serialization and deserialization logic so that
/// [AccountStatsViewModel] stays focused on business logic only.
class AccountStatsDraftHandler extends DraftHandler<AccountStatsViewModel> {
  /// Serialises the current account stats form state to JSON.
  ///
  /// Calls [formKey.currentState?.save()] first because the table widget uses
  /// `onSaved` callbacks (not [TextEditingController]s) to write values back
  /// into the [AccountStats] model objects.
  @override
  Map<String, dynamic> buildDraftData(AccountStatsViewModel vm) {
    // Flush onSaved callbacks — required for screens using onSaved in
    // FormFields.
    vm.formKey.currentState?.save();

    return <String, dynamic>{
      "comments": vm.comment,
      // Group account stats by customer to support missing/null IDs.
      // We use customerRimNo as a unique key for the customer.
      "accountStatsByCustomer": vm.customerWiseAccountStat.map(
        (customer, volumes) => MapEntry<String, dynamic>(
          customer.customerRimNo.toString(),
          volumes.map((bv) => bv.toJson()).toList(),
        ),
      ),
    };
  }

  /// Restores draft values into the live [customerWiseAccountStats] map.
  @override
  void applyDraft(AccountStatsViewModel vm, Map<String, dynamic> data) {
    vm.comment = data["comments"] as String? ?? vm.comment;

    // Since accountStatsIds can be null entirely, the safest and more
    // deterministic
    // way to map the drafted values back is to use the exact structure
    // (Customer -> Index).
    final Map<String, dynamic>? draftedVolumes =
        data["accountStatsByCustomer"] as Map<String, dynamic>?;

    if (draftedVolumes != null) {
      for (final MapEntry<dynamic, List<AccountStat>> entry
          in vm.customerWiseAccountStat.entries) {
        final String customerKey = entry.key.customerRimNo.toString();
        // Look up the drafted list for this specific customer
        final List<dynamic>? draftList =
            draftedVolumes[customerKey] as List<dynamic>?;

        // If we found draft data for this customer and the item count matches
        // the live data
        if (draftList != null && draftList.length == entry.value.length) {
          // Restore row sequentially using the array index
          for (int i = 0; i < entry.value.length; i++) {
            final Map<String, dynamic>? draftBv =
                draftList[i] as Map<String, dynamic>?;

            if (draftBv != null && draftBv["accountCommitmentNumber"] != null) {
              entry.value[i].accountCommitmentNumber =
                  draftBv["accountCommitmentNumber"]?.toString();
            }
            if (draftBv != null && draftBv["highBalancePreviousYear"] != null) {
              entry.value[i].highBalancePreviousYear =
                  draftBv["highBalancePreviousYear"]?.toString();
            }
            if (draftBv != null && draftBv["lowBalancePreviousYear"] != null) {
              entry.value[i].lowBalancePreviousYear =
                  draftBv["lowBalancePreviousYear"]?.toString();
            }
            if (draftBv != null &&
                draftBv["averageBalancePreviousYear"] != null) {
              entry.value[i].averageBalancePreviousYear =
                  draftBv["averageBalancePreviousYear"]?.toString();
            }
            if (draftBv != null && draftBv["turnoverPreviousYear"] != null) {
              entry.value[i].turnoverPreviousYear =
                  draftBv["turnoverPreviousYear"]?.toString();
            }
            if (draftBv != null && draftBv["highBalanceCurrentYear"] != null) {
              entry.value[i].highBalanceCurrentYear =
                  draftBv["highBalanceCurrentYear"]?.toString();
            }
            if (draftBv != null && draftBv["lowBalanceCurrentYear"] != null) {
              entry.value[i].lowBalanceCurrentYear =
                  draftBv["lowBalanceCurrentYear"]?.toString();
            }
            if (draftBv != null &&
                draftBv["averageBalanceCurrentYear"] != null) {
              entry.value[i].averageBalanceCurrentYear =
                  draftBv["averageBalanceCurrentYear"]?.toString();
            }
            if (draftBv != null && draftBv["turnoverCurrentYear"] != null) {
              entry.value[i].turnoverCurrentYear =
                  draftBv["turnoverCurrentYear"]?.toString();
            }
          }
        }
      }
    }
  }
}
