import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/remarks/financial_ratio_analysis/financial_ratio_analysis.dart";

void main() {
  group("FinancialRatioAnalysis", () {
    test("should create a FinancialRatioAnalysis instance with required fields",
        () {
      final financialRatioAnalysis = FinancialRatioAnalysis(
        entityId: "1",
        name: "Test Financial Ratio",
        analysisHtml: "<html><body>Test</body></html>",
        spreadsmartUrl: "http://test.com",
      );
      expect(financialRatioAnalysis.entityId, "1");
      expect(financialRatioAnalysis.name, "Test Financial Ratio");
      expect(
        financialRatioAnalysis.analysisHtml,
        "<html><body>Test</body></html>",
      );
      expect(financialRatioAnalysis.spreadsmartUrl, "http://test.com");
      expect(financialRatioAnalysis.canDelete, false);
    });

    test("should create a FinancialRatioAnalysis instance with all fields", () {
      final financialRatioAnalysis = FinancialRatioAnalysis(
        entityId: "2",
        name: "Another Financial Ratio",
        analysisHtml: "<html><body>Another Test</body></html>",
        spreadsmartUrl: "http://another.com",
        canDelete: true,
      );
      expect(financialRatioAnalysis.entityId, "2");
      expect(financialRatioAnalysis.name, "Another Financial Ratio");
      expect(
        financialRatioAnalysis.analysisHtml,
        "<html><body>Another Test</body></html>",
      );
      expect(financialRatioAnalysis.spreadsmartUrl, "http://another.com");
      expect(financialRatioAnalysis.canDelete, true);
    });

    test("copyWith should return a new instance with updated values", () {
      final original = FinancialRatioAnalysis(
        entityId: "1",
        name: "Test Financial Ratio",
        analysisHtml: "<html><body>Test</body></html>",
        spreadsmartUrl: "http://test.com",
        canDelete: false,
      );

      final updated = original.copyWith(
        name: "Updated Financial Ratio",
        canDelete: true,
      );

      expect(updated.entityId, "1");
      expect(updated.name, "Updated Financial Ratio");
      expect(updated.analysisHtml, "<html><body>Test</body></html>");
      expect(updated.spreadsmartUrl, "http://test.com");
      expect(updated.canDelete, true);
    });

    test("copyWith should return a new instance with same values if no changes",
        () {
      final original = FinancialRatioAnalysis(
        entityId: "1",
        name: "Test Financial Ratio",
        analysisHtml: "<html><body>Test</body></html>",
        spreadsmartUrl: "http://test.com",
        canDelete: false,
      );

      final updated = original.copyWith();

      expect(updated.entityId, "1");
      expect(updated.name, "Test Financial Ratio");
      expect(updated.analysisHtml, "<html><body>Test</body></html>");
      expect(updated.spreadsmartUrl, "http://test.com");
      expect(updated.canDelete, false);
    });
  });
}
