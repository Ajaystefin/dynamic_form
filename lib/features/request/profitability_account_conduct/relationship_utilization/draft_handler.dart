import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
// ignore: avoid_relative_lib_imports — intentional same-feature import
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/model.dart";
import "package:wcas_frontend/models/request/profitability/relationship_utilization.dart";

/// Draft handler for the Relationship Utilization screen.
///
/// Owns all autosave serialization and deserialization logic so that
/// [RelationshipUtilizationViewModel] stays focused on business logic only.
class RelationshipUtilizationDraftHandler
    extends DraftHandler<RelationshipUtilizationViewModel> {
  static const String _rowsKey = "relationshipUtilizationData";

  /// Serializes the current form state to JSON.
  ///
  /// We call both:
  /// - `formKey.currentState?.save()` for any fields using `onSaved`
  /// - `syncControllersToModel()` for controller-backed fields
  @override
  Map<String, dynamic> buildDraftData(RelationshipUtilizationViewModel vm) {
    // Flush FormField onSaved callbacks
    vm.formKey.currentState?.save();

    // Ensure controller values are copied into model before serializing
    vm.syncControllersToModel();

    return <String, dynamic>{
      _rowsKey:
          vm.relationshipUtilizationData.map((RelationshipUtilization item) {
        return <String, dynamic>{
          "clientTurnover": vm.clean(item.clientTurnover),
          "turnoverInCbdCua": vm.clean(item.turnoverInCbdCua),
          "throughputToCbdPercentage": vm.clean(item.throughputToCbdPercentage),

          // Include a stable row identifier if available in your model.
          // Useful if later you want to restore by key instead of by index.
          // 'customerName': item.customerName,
          // 'customerId': item.customerId,
        };
      }).toList(),
    };
  }

  /// Restores draft values into the live [relationshipUtilizationData] list.
  ///
  /// This restores row values by index because the API data is already loaded
  /// first in `init()`. After patching the live models, controllers are
  /// rebuilt.
  @override
  void applyDraft(
    RelationshipUtilizationViewModel vm,
    Map<String, dynamic> data,
  ) {
    final dynamic rawRows = data[_rowsKey];
    if (rawRows is! List || rawRows.isEmpty) return;
    if (vm.relationshipUtilizationData.isEmpty) return;

    final int count = rawRows.length < vm.relationshipUtilizationData.length
        ? rawRows.length
        : vm.relationshipUtilizationData.length;

    for (int i = 0; i < count; i++) {
      final dynamic rawRow = rawRows[i];
      if (rawRow is! Map) continue;

      final row = Map<String, dynamic>.from(rawRow);
      final item = vm.relationshipUtilizationData[i];

      final restoredTurnover = vm.clean(row["turnoverInCbdCua"]);

      item
        ..clientTurnover = vm.clean(row["clientTurnover"])
        ..throughputToCbdPercentage = vm.clean(row["throughputToCbdPercentage"])
        ..turnoverInCbdCua = restoredTurnover.isNotEmpty
            ? restoredTurnover
            : item.turnoverInCbdCua;
    }

    // Rebuild controllers from restored model values
    vm.initalize();

    // Recalculate % to ensure consistency
    for (int i = 0; i < count; i++) {
      vm.recalcPercentage(i);
    }
  }
}
