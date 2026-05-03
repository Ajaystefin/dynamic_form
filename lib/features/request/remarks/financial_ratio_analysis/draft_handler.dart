import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/balance_sheet_analysis.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/cashflow_statement_analysis.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/financial_details_response.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/income_statement_analysis.dart";

class FinancialRatioAnalysisDraftHandler
    extends DraftHandler<FinancialRatioAnalysisViewModel> {
  @override
  Map<String, dynamic> buildDraftData(FinancialRatioAnalysisViewModel vm) {
    return {
      "hasCreditLensData": vm.hasCreditLensData,
      "incomeStatements": vm.incomeStatements.map((s) => s.toJson()).toList(),
      "descOfAccounts": vm.descTextController.currentText,
      "incomeDescription": vm.incomeStatementController.currentText,
      "cashflowDescription": vm.cashflowController.currentText,
      "balanceSheetDescription": vm.balanceSheetcontroller.currentText,
      "selectedIncomeHealthId": vm.selectedIncomeHealth?.id,
      "selectedCashFlowHealthId": vm.selectedCashFlowHealth?.id,
      "selectedBalanceSheetHealthId": vm.selectedBalanceSheetHealth?.id,
      "entityId": vm.state.currentEntityId,
      "longName": vm.longName,
      "incomeRows": vm.incomeStatementRows.map((r) => r.toJson()).toList(),
      "cashflowRows": vm.cashflowSheetRows.map((r) => r.toJson()).toList(),
      "balanceRows": vm.balanceSheetRows.map((r) => r.toJson()).toList(),
    };
  }

  @override
  void applyDraft(
    FinancialRatioAnalysisViewModel vm,
    Map<String, dynamic> data,
  ) {
    // 0. Base Data & Structural Headers
    vm.hasCreditLensData = data["hasCreditLensData"] as bool? ?? false;

    if (data["incomeStatements"] != null) {
      final List<dynamic> stmtsJson = data["incomeStatements"] as List<dynamic>;
      vm.incomeStatements = stmtsJson
          .map((json) => Statement.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    // 1. Descriptions
    final String? desc = data["descOfAccounts"] as String?;
    if (desc != null) {
      vm.description = desc;
      vm.descTextController.setText(desc);
    }

    final String? incDesc = data["incomeDescription"] as String?;
    if (incDesc != null) {
      vm.incomeDescription = incDesc;
      vm.incomeStatementController.setText(incDesc);
    }

    final String? cfDesc = data["cashflowDescription"] as String?;
    if (cfDesc != null) {
      vm.cashflowDescription = cfDesc;
      vm.cashflowController.setText(cfDesc);
    }

    final String? balDesc = data["balanceSheetDescription"] as String?;
    if (balDesc != null) {
      vm.balanceSheetdescription = balDesc;
      vm.balanceSheetcontroller.setText(balDesc);
    }

    // 2. Health Dropdowns
    final int? incHealthId = data["selectedIncomeHealthId"] as int?;
    if (incHealthId != null) {
      vm.selectedIncomeHealth = _healthRefById(incHealthId, vm.incomeHealth);
    }

    final int? cfHealthId = data["selectedCashFlowHealthId"] as int?;
    if (cfHealthId != null) {
      vm.selectedCashFlowHealth = _healthRefById(cfHealthId, vm.cashflowHealth);
    }

    final int? balHealthId = data["selectedBalanceSheetHealthId"] as int?;
    if (balHealthId != null) {
      vm.selectedBalanceSheetHealth =
          _healthRefById(balHealthId, vm.balanceHealth);
    }

    // 3. Entity Details
    final int? entityId = data["entityId"] as int?;
    if (entityId != null) {
      vm.entityController.text = entityId.toString();
      // Use standard method rather than emit() if available, else standard
      // state emission
      vm.changeEntityIdExternally(entityId);
    }

    final String? longName = data["longName"] as String?;
    if (longName != null) {
      vm.longName = longName;
    }

    // 4. Tables: perfectly reconstruct both API-base rows and user-added rows
    // from the saved drafts
    if (data["incomeRows"] != null) {
      final List<dynamic> jsonList = data["incomeRows"] as List<dynamic>;
      final userRows = jsonList
          .map(
            (json) => IncomeStatementAnalysisRow.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
      vm.incomeStatementRows.clear();
      vm.incomeStatementRows.addAll(userRows);

      final newRows = vm.incomeStatementRows.where((r) => r.isNew).toList();
      vm.incomeRows = [...vm.incomeStatementRows, ...newRows];
    }

    if (data["cashflowRows"] != null) {
      final List<dynamic> jsonList = data["cashflowRows"] as List<dynamic>;
      final userRows = jsonList
          .map(
            (json) =>
                CashFlowSheetAnalysisRow.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      vm.cashflowSheetRows.clear();
      vm.cashflowSheetRows.addAll(userRows);

      final newRows = vm.cashflowSheetRows.where((r) => r.isNew).toList();
      vm.cashflowRows = [...vm.cashflowSheetRows, ...newRows];
    }

    if (data["balanceRows"] != null) {
      final List<dynamic> jsonList = data["balanceRows"] as List<dynamic>;
      final userRows = jsonList
          .map(
            (json) =>
                BalanceSheetAnalysisRow.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      vm.balanceSheetRows.clear();
      vm.balanceSheetRows.addAll(userRows);

      final newRows = vm.balanceSheetRows.where((r) => r.isNew).toList();
      vm.balanceRows = [
        ...vm.balanceSheetRows,
        ...newRows,
      ];
    }
  }

  Reference? _healthRefById(int? id, List<Reference>? list) {
    if (id == null) return null;
    final healthList = list ?? const <Reference>[];
    final idx = healthList.indexWhere((r) => r.id == id);
    return (idx >= 0) ? healthList[idx] : null;
  }
}
