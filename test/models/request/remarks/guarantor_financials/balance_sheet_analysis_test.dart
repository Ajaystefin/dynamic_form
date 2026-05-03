import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/remarks/guarantor_financials/balance_sheet_analysis.dart";

void main() {
  group("BalanceSheet", () {
    test("should create a BalanceSheet instance with required fields", () {
      final balanceSheet = BalanceSheet(id: "1");
      expect(balanceSheet.id, "1");
      expect(balanceSheet.balanceSheet, "");
      expect(balanceSheet.audited1, "");
      expect(balanceSheet.audited2, "");
      expect(balanceSheet.audited3, "");
      expect(balanceSheet.inhouse, "");
      expect(balanceSheet.estimated, "");
      expect(balanceSheet.isNew, false);
    });

    test("should create a BalanceSheet instance with all fields", () {
      final balanceSheet = BalanceSheet(
        id: "2",
        balanceSheet: "Test Balance Sheet",
        audited1: "100",
        audited2: "200",
        audited3: "300",
        inhouse: "400",
        estimated: "500",
        isNew: true,
      );
      expect(balanceSheet.id, "2");
      expect(balanceSheet.balanceSheet, "Test Balance Sheet");
      expect(balanceSheet.audited1, "100");
      expect(balanceSheet.audited2, "200");
      expect(balanceSheet.audited3, "300");
      expect(balanceSheet.inhouse, "400");
      expect(balanceSheet.estimated, "500");
      expect(balanceSheet.isNew, true);
    });
  });
}
