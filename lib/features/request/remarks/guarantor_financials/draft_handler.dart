import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/remarks/guarantor_financials/model.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/income_statement_analysis.dart";

class GuarantorFinancialDraftHandler
    extends DraftHandler<GuarantorFinancialViewModel> {
  @override
  Map<String, dynamic> buildDraftData(GuarantorFinancialViewModel vm) {
    if (vm.primaryFormKey.currentState != null &&
        vm.primaryFormKey.currentState!.mounted) {
      vm.primaryFormKey.currentState?.save();
    }

    final bool isStrategyComment =
        vm.hasCreditLensData || vm.hasSavedAnalysisData;

    final List<Map<String, dynamic>> draft = [];

    for (final guarantor in vm.state.guarantors) {
      final int entityId = guarantor.entityId ?? 0;

      final bool isActive = entityId == vm.state.currentEntityId;

      final rows =
          isActive ? vm.incomeStatementRows : vm.incomeRowsFor(entityId);
      final healthId = isActive
          ? vm.selectedBalanceSheetHealth?.id
          : vm.selectedHealthFor(entityId)?.id;
      final remarks = isStrategyComment
          ? vm.editorForEntity(entityId).currentText
          : vm.controller.currentText;

      draft.add({
        "entityId": entityId,
        "healthId": healthId,
        "remarks": remarks,
        "rows": rows.map((r) => r.toJson()).toList(),
      });
    }

    return {
      "hasCreditLensData": vm.hasCreditLensData,
      "hasSavedAnalysisData": vm.hasSavedAnalysisData,
      "entities": draft,
    };
  }

  @override
  void applyDraft(
    GuarantorFinancialViewModel vm,
    Map<String, dynamic> data,
  ) {
    vm.hasCreditLensData =
        data["hasCreditLensData"] as bool? ?? vm.hasCreditLensData;
    vm.hasSavedAnalysisData =
        data["hasSavedAnalysisData"] as bool? ?? vm.hasSavedAnalysisData;

    final List<dynamic>? draftList = data["entities"] as List<dynamic>?;
    if (draftList == null) return;

    for (final dynamic draft in draftList) {
      if (draft is! Map<String, dynamic>) continue;

      final int? entityId = draft["entityId"] as int?;
      if (entityId == null) continue;

      // 1. Restore remarks directly into the unified editor
      final String? remarks = draft["remarks"] as String?;
      if (remarks != null) {
        final bool isStrategyComment =
            vm.hasCreditLensData || vm.hasSavedAnalysisData;

        if (isStrategyComment) {
          vm.editorForEntity(entityId).setText(remarks);
        } else {
          vm.controller.setText(remarks);
        }
      }

      // 2. Restore health selection
      final int? healthId = draft["healthId"] as int?;
      if (healthId != null) {
        final hList = vm.guarantorsHealth ?? [];
        final index = hList.indexWhere((r) => r.id == healthId);
        if (index >= 0) {
          vm.setSelectedHealthFor(entityId, hList[index]);
        }
      }

      // 3. Restore table rows (mutating the UI map list in-place if it exists)
      final List<dynamic>? rowsData = draft["rows"] as List<dynamic>?;
      if (rowsData != null) {
        final List<IncomeStatementAnalysisRow> restoredRows = rowsData
            .map(
              (j) => IncomeStatementAnalysisRow.fromJson(
                j as Map<String, dynamic>,
              ),
            )
            .toList();

        final rows = vm.incomeRowsFor(entityId);
        if (rows.isNotEmpty) {
          rows.clear();
          rows.addAll(restoredRows);
        }

        // Also update the active table if this is the currently viewed entity
        if (vm.state.currentEntityId == entityId) {
          vm.incomeStatementRows.clear();
          vm.incomeStatementRows.addAll(restoredRows);
          final newRows = vm.incomeStatementRows.where((r) => r.isNew).toList();
          vm.incomeRows = [...vm.incomeStatementRows, ...newRows];

          if (healthId != null) {
            final hList = vm.guarantorsHealth ?? [];
            final idx = hList.indexWhere((r) => r.id == healthId);
            if (idx >= 0) {
              vm.selectedBalanceSheetHealth = hList[idx];
            }
          }
        }
      }
    }
  }
}
