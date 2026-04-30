import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
// ignore: avoid_relative_lib_imports — intentional same-feature import
import "package:wcas_frontend/features/request/profitability_account_conduct/business_volume/model.dart";
import "package:wcas_frontend/models/request/profitability/business_volume.dart";

/// Draft handler for the Business Volume screen.
///
/// Owns all autosave serialization and deserialization logic so that
/// [BusinessVolumeViewModel] stays focused on business logic only.
class BusinessVolumeDraftHandler extends DraftHandler<BusinessVolumeViewModel> {
  /// Serialises the current business volume form state to JSON.
  ///
  /// Calls [formKey.currentState?.save()] first because the table widget uses
  /// `onSaved` callbacks (not [TextEditingController]s) to write values back
  /// into the [BusinessVolume] model objects.
  @override
  Map<String, dynamic> buildDraftData(BusinessVolumeViewModel vm) {
    // Flush onSaved callbacks — required for screens using onSaved in
    // FormFields.
    vm.formKey.currentState?.save();

    return <String, dynamic>{
      "comments": vm.comments,
      // Group business volumes by customer to support missing/null IDs.
      // We use customerRimNo as a unique key for the customer.
      "businessVolumesByCustomer": vm.customerWiseBusinessVolume.map(
        (customer, volumes) => MapEntry<String, dynamic>(
          customer.customerRimNo.toString(),
          volumes.map((bv) => bv.toJson()).toList(),
        ),
      ),
    };
  }

  /// Restores draft values into the live [customerWiseBusinessVolume] map.
  @override
  void applyDraft(BusinessVolumeViewModel vm, Map<String, dynamic> data) {
    vm.comments = data["comments"] as String? ?? vm.comments;

    // Since businessVolumeIds can be null entirely, the safest and more
    // deterministic
    // way to map the drafted values back is to use the exact structure
    // (Customer -> Index).
    final Map<String, dynamic>? draftedVolumes =
        data["businessVolumesByCustomer"] as Map<String, dynamic>?;

    if (draftedVolumes != null) {
      for (final MapEntry<dynamic, List<BusinessVolume>> entry
          in vm.customerWiseBusinessVolume.entries) {
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

            if (draftBv != null && draftBv["estimatesForNextYear"] != null) {
              entry.value[i].estimatesForNextYear =
                  draftBv["estimatesForNextYear"]?.toString();
            }
          }
        }
      }
    }
  }
}
