import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/draft_handler.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/balance_sheet_analysis.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/cashflow_statement_analysis.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/financial_details_response.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/income_statement_analysis.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("FinancialRatioAnalysisDraftHandler", () {
    late FinancialRatioAnalysisViewModel viewModel;
    late FinancialRatioAnalysisDraftHandler handler;

    setUp(() {
      EnvConfig.configForTesting = {"useTinyMceEditor": true};
      viewModel = FinancialRatioAnalysisViewModel();
      handler = FinancialRatioAnalysisDraftHandler();
    });

    tearDown(() {
      EnvConfig.configForTesting = null;
    });

    test("buildDraftData serializes state to JSON", () {
      // Arrange
      viewModel
        ..hasCreditLensData = true
        ..incomeStatements = [
          Statement(
            id: 1,
            date: DateTime.parse("2023-01-01"),
            periods: 12,
            statementConsts: [],
          ),
        ];

      viewModel.descTextController.setText("Description 1");
      viewModel.incomeStatementController.setText("Income Desc");
      viewModel.cashflowController.setText("Cashflow Desc");
      viewModel.balanceSheetcontroller.setText("Balance Sheet Desc");

      viewModel
        ..selectedIncomeHealth = Reference(id: 1, name: "Good")
        ..selectedCashFlowHealth = Reference(id: 2, name: "Average")
        ..selectedBalanceSheetHealth = Reference(id: 3, name: "Poor")
        ..longName = "Test Company";

      viewModel.incomeStatementRows.addAll([
        IncomeStatementAnalysisRow(
          id: "inc1",
          incomePositions: "Revenue",
          isNew: true,
        ),
      ]);
      viewModel.cashflowSheetRows.addAll([
        CashFlowSheetAnalysisRow(
          id: "cf1",
          cashFlowItems: "Cash",
        ),
      ]);
      viewModel.balanceSheetRows.addAll([
        BalanceSheetAnalysisRow(
          id: "bal1",
          balanceSheet: "Assets",
          isNew: true,
        ),
      ]);

      // Act
      final draftData = handler.buildDraftData(viewModel);

      // Assert
      expect(draftData["hasCreditLensData"], true);

      final stmts = draftData["incomeStatements"] as List<dynamic>;
      expect(stmts.length, 1);
      expect(stmts[0]["id"], 1);

      expect(draftData["descOfAccounts"], "Description 1");
      expect(draftData["incomeDescription"], "Income Desc");
      expect(draftData["cashflowDescription"], "Cashflow Desc");
      expect(draftData["balanceSheetDescription"], "Balance Sheet Desc");

      expect(draftData["selectedIncomeHealthId"], 1);
      expect(draftData["selectedCashFlowHealthId"], 2);
      expect(draftData["selectedBalanceSheetHealthId"], 3);

      expect(draftData["longName"], "Test Company");

      final incomeRows = draftData["incomeRows"] as List<dynamic>;
      expect(incomeRows.length, 1);
      expect(incomeRows[0]["id"], "inc1");
      expect(incomeRows[0]["incomePositions"], "Revenue");
      expect(incomeRows[0]["isNew"], true);

      final cashflowRows = draftData["cashflowRows"] as List<dynamic>;
      expect(cashflowRows.length, 1);
      expect(cashflowRows[0]["id"], "cf1");

      final balanceRows = draftData["balanceRows"] as List<dynamic>;
      expect(balanceRows.length, 1);
      expect(balanceRows[0]["id"], "bal1");
    });

    test("applyDraft restores draft values into live view model", () {
      // Arrange
      final draftJson = {
        "hasCreditLensData": true,
        "incomeStatements": [
          {
            "id": 2,
            "date": "2024-01-01T00:00:00.000",
            "periods": 6,
            "statementConsts": [],
          }
        ],
        "descOfAccounts": "Restored Desc",
        "incomeDescription": "Restored Income Desc",
        "cashflowDescription": "Restored Cashflow Desc",
        "balanceSheetDescription": "Restored Balance Sheet Desc",
        "selectedIncomeHealthId": 10,
        "selectedCashFlowHealthId": 20,
        "selectedBalanceSheetHealthId": 30,
        "entityId": 999,
        "longName": "Restored Name",
        "incomeRows": [
          {"id": "inc_new", "incomePositions": "New Item", "isNew": true},
        ],
        "cashflowRows": [
          {"id": "cf_new", "cashFlowItems": "New Cash", "isNew": true},
        ],
        "balanceRows": [
          {"id": "bal_new", "balanceSheet": "New Asset", "isNew": false},
        ],
      };

      // Set up reference lists in viewModel so _healthRefById works
      viewModel
        ..incomeHealth = [Reference(id: 10, name: "Income OK")]
        ..cashflowHealth = [Reference(id: 20, name: "Cashflow OK")]
        ..balanceHealth = [Reference(id: 30, name: "Balance OK")];

      // Act
      handler.applyDraft(viewModel, draftJson);

      // Assert
      expect(viewModel.hasCreditLensData, true);
      expect(viewModel.incomeStatements.length, 1);
      expect(viewModel.incomeStatements.first.id, 2);

      expect(viewModel.description, "Restored Desc");
      expect(viewModel.descTextController.currentText, "Restored Desc");

      expect(viewModel.incomeDescription, "Restored Income Desc");
      expect(viewModel.cashflowDescription, "Restored Cashflow Desc");
      expect(viewModel.balanceSheetdescription, "Restored Balance Sheet Desc");

      expect(viewModel.selectedIncomeHealth?.id, 10);
      expect(viewModel.selectedCashFlowHealth?.id, 20);
      expect(viewModel.selectedBalanceSheetHealth?.id, 30);

      expect(viewModel.entityController.text, "999");
      expect(viewModel.longName, "Restored Name");

      expect(viewModel.incomeStatementRows.length, 1);
      expect(viewModel.incomeStatementRows.first.id, "inc_new");

      expect(viewModel.cashflowSheetRows.length, 1);
      expect(viewModel.cashflowSheetRows.first.cashFlowItems, "New Cash");

      expect(viewModel.balanceSheetRows.length, 1);
      expect(viewModel.balanceSheetRows.first.balanceSheet, "New Asset");
    });

    test("applyDraft handles missing draft fields gracefully", () {
      // Arrange
      viewModel.hasCreditLensData = true;
      viewModel.descTextController.setText("Original text");

      // Omit all fields to test null safety and defaults
      final Map<String, dynamic> emptyDraftJson = {};

      // Act
      handler.applyDraft(viewModel, emptyDraftJson);

      // Assert
      expect(viewModel.hasCreditLensData, false); // Default value from mapper
      expect(
        viewModel.descTextController.currentText,
        "Original text",
      ); // Left intact
    });
  });
}
