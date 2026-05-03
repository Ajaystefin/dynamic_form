import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/cashflow_statement_analysis.dart";

void main() {
  group("CashFlowSheetAnalysis", () {
    test("should create a CashFlowSheetAnalysis instance with required fields",
        () {
      final cashFlowSheetAnalysis = CashFlowSheetAnalysisRow(id: "1");
      expect(cashFlowSheetAnalysis.id, "1");
      expect(cashFlowSheetAnalysis.cashFlowItems, "");
      expect(cashFlowSheetAnalysis.audited1, "");
      expect(cashFlowSheetAnalysis.audited2, "");
      expect(cashFlowSheetAnalysis.audited3, "");
      expect(cashFlowSheetAnalysis.inhouse, "");
      expect(cashFlowSheetAnalysis.estimated, "");
      expect(cashFlowSheetAnalysis.isNew, false);
    });

    test("should create a CashFlowSheetAnalysis instance with all fields", () {
      final cashFlowSheetAnalysis = CashFlowSheetAnalysisRow(
        id: "2",
        cashFlowItems: "Test Cash Flow Items",
        audited1: "100",
        audited2: "200",
        audited3: "300",
        inhouse: "400",
        estimated: "500",
        isNew: true,
      );
      expect(cashFlowSheetAnalysis.id, "2");
      expect(cashFlowSheetAnalysis.cashFlowItems, "Test Cash Flow Items");
      expect(cashFlowSheetAnalysis.audited1, "100");
      expect(cashFlowSheetAnalysis.audited2, "200");
      expect(cashFlowSheetAnalysis.audited3, "300");
      expect(cashFlowSheetAnalysis.inhouse, "400");
      expect(cashFlowSheetAnalysis.estimated, "500");
      expect(cashFlowSheetAnalysis.isNew, true);
    });
  });
}
