import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/remarks/guarantor_financials/income_statement_analysis.dart";

void main() {
  group("IncomeStatement", () {
    test("should create an IncomeStatement instance with required fields", () {
      final incomeStatement = IncomeStatement(id: "1");
      expect(incomeStatement.id, "1");
      expect(incomeStatement.incomePositions, "");
      expect(incomeStatement.audited1, "");
      expect(incomeStatement.audited2, "");
      expect(incomeStatement.audited3, "");
      expect(incomeStatement.inhouse, "");
      expect(incomeStatement.estimated, "");
      expect(incomeStatement.isNew, false);
    });

    test("should create an IncomeStatement instance with all fields", () {
      final incomeStatement = IncomeStatement(
        id: "2",
        incomePositions: "Test Income Positions",
        audited1: "100",
        audited2: "200",
        audited3: "300",
        inhouse: "400",
        estimated: "500",
        isNew: true,
      );
      expect(incomeStatement.id, "2");
      expect(incomeStatement.incomePositions, "Test Income Positions");
      expect(incomeStatement.audited1, "100");
      expect(incomeStatement.audited2, "200");
      expect(incomeStatement.audited3, "300");
      expect(incomeStatement.inhouse, "400");
      expect(incomeStatement.estimated, "500");
      expect(incomeStatement.isNew, true);
    });
  });
}
