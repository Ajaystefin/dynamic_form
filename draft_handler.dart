import 'package:wcas_frontend/core/services/draft/draft_handler_base.dart';
import 'package:wcas_frontend/models/request/profitability/business_volume.dart';

// ignore: avoid_relative_lib_imports — intentional same-feature import
import 'model.dart';

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
    // Flush onSaved callbacks — required for screens using onSaved in FormFields.
    vm.formKey.currentState?.save();

    return <String, dynamic>{
      'comments': vm.comments,
      // Flatten all BusinessVolume objects using the model's own toJson().
      // No customer-level grouping needed — applyDraft matches by businessVolumeId.
      'businessVolumes': vm.customerWiseBusinessVolume.values
          .expand((List<BusinessVolume> list) => list)
          .map((BusinessVolume bv) => bv.toJson())
          .toList(),
    };
  }

  /// Restores draft values into the live [customerWiseBusinessVolume] map.
  @override
  void applyDraft(BusinessVolumeViewModel vm, Map<String, dynamic> data) {
    vm.comments = data['comments'] as String? ?? vm.comments;

    // Build a typed lookup: businessVolumeId → estimatesForNextYear draft value
    final Map<dynamic, String?> draftMap = <dynamic, String?>{
      for (final Map<String, dynamic> bv
          in (data['businessVolumes'] as List<dynamic>?)
                  ?.whereType<Map<String, dynamic>>() ??
              <Map<String, dynamic>>[])
        bv['businessVolumeId']: bv['estimatesForNextYear']?.toString(),
    };

    // Apply to live data
    for (final List<BusinessVolume> volumes
        in vm.customerWiseBusinessVolume.values) {
      for (final BusinessVolume bv in volumes) {
        if (draftMap.containsKey(bv.businessVolumeId)) {
          bv.estimatesForNextYear = draftMap[bv.businessVolumeId];
        }
      }
    }
  }
}
