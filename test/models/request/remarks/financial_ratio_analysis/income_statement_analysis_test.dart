import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/income_statement_analysis.dart";

void main() {
  group("IncomeStatementAnalysis", () {
    test(
        "should create an IncomeStatementAnalysis"
        " instance with required fields", () {
      final incomeStatementAnalysis = IncomeStatementAnalysisRow(id: "1");
      expect(incomeStatementAnalysis.id, "1");
      expect(incomeStatementAnalysis.incomePositions, "");
      expect(incomeStatementAnalysis.audited1, "");
      expect(incomeStatementAnalysis.audited2, "");
      expect(incomeStatementAnalysis.audited3, "");
      expect(incomeStatementAnalysis.inhouse, "");
      expect(incomeStatementAnalysis.estimated, "");
      expect(incomeStatementAnalysis.isNew, false);
    });

    test("should create an IncomeStatementAnalysis instance with all fields",
        () {
      final incomeStatementAnalysis = IncomeStatementAnalysisRow(
        id: "2",
        incomePositions: "Test Income Positions",
        audited1: "100",
        audited2: "200",
        audited3: "300",
        inhouse: "400",
        estimated: "500",
        isNew: true,
      );
      expect(incomeStatementAnalysis.id, "2");
      expect(incomeStatementAnalysis.incomePositions, "Test Income Positions");
      expect(incomeStatementAnalysis.audited1, "100");
      expect(incomeStatementAnalysis.audited2, "200");
      expect(incomeStatementAnalysis.audited3, "300");
      expect(incomeStatementAnalysis.inhouse, "400");
      expect(incomeStatementAnalysis.estimated, "500");
      expect(incomeStatementAnalysis.isNew, true);
    });
  });
}
