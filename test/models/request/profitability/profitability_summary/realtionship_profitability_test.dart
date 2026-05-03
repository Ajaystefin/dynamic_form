import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/profitability/profitability_summary/realtionship_profitability.dart";

void main() {
  group("RelationshipProfitability", () {
    test("fromJson creates a valid instance", () {
      final Map<String, dynamic> json = {
        "customerRim": "RIM123",
        "customerName": "Test Customer",
        "projectedNext12Months": {
          "nii": 100,
          "nfi": 50,
          "expectedNetIncome": 150,
          "avgCasa": 200,
          "rwa": 300,
          "realizedNii": 90,
          "realizedNfi": 45,
          "realizedExpectedNetIncome": 135,
          "realizedAvgCasa": 180,
          "realizedRwa": 270,
        },
        "realizedLastYear": {
          "nii": 80,
          "nfi": 40,
          "expectedNetIncome": 120,
          "avgCasa": 160,
          "rwa": 240,
          "realizedNii": 70,
          "realizedNfi": 35,
          "realizedExpectedNetIncome": 105,
          "realizedAvgCasa": 140,
          "realizedRwa": 210,
        },
        "comments": "Some comments",
      };

      final relationshipProfitability =
          RelationshipProfitability.fromJson(json);

      expect(relationshipProfitability.customerRim, "RIM123");
      expect(relationshipProfitability.customerName, "Test Customer");
      // expect(relationshipProfitability.projectedNext12Months, isNotNull);
      expect(relationshipProfitability.projectedNext12Months!.nii, "100");
      // expect(relationshipProfitability.realizedLastYear, isNotNull);
      expect(relationshipProfitability.realizedLastYear!.nii, "80");
      expect(relationshipProfitability.comments, "Some comments");
    });
  });
}
