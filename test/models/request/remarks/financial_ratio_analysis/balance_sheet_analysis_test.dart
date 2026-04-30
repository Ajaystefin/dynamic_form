import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/balance_sheet_analysis.dart";

void main() {
  group("BalanceSheetAnalysis", () {
    test("should create a BalanceSheetAnalysis instance with required fields",
        () {
      final balanceSheetAnalysis = BalanceSheetAnalysisRow(id: "1");
      expect(balanceSheetAnalysis.id, "1");
      expect(balanceSheetAnalysis.balanceSheet, "");
      expect(balanceSheetAnalysis.audited1, "");
      expect(balanceSheetAnalysis.audited2, "");
      expect(balanceSheetAnalysis.audited3, "");
      expect(balanceSheetAnalysis.inhouse, "");
      expect(balanceSheetAnalysis.estimated, "");
      expect(balanceSheetAnalysis.isNew, false);
    });

    test("should create a BalanceSheetAnalysis instance with all fields", () {
      final balanceSheetAnalysis = BalanceSheetAnalysisRow(
        id: "2",
        balanceSheet: "Test Balance Sheet",
        audited1: "100",
        audited2: "200",
        audited3: "300",
        inhouse: "400",
        estimated: "500",
        isNew: true,
      );
      expect(balanceSheetAnalysis.id, "2");
      expect(balanceSheetAnalysis.balanceSheet, "Test Balance Sheet");
      expect(balanceSheetAnalysis.audited1, "100");
      expect(balanceSheetAnalysis.audited2, "200");
      expect(balanceSheetAnalysis.audited3, "300");
      expect(balanceSheetAnalysis.inhouse, "400");
      expect(balanceSheetAnalysis.estimated, "500");
      expect(balanceSheetAnalysis.isNew, true);
    });
  });
}
