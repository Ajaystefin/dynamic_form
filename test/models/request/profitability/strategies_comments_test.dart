import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/profitability/strategies_comments.dart";

void main() {
  group("StrategiesComments", () {
    test("fromJson creates a valid instance", () {
      final Map<String, dynamic> json = {
        "relationshipStrategy": "Strategy 1",
        "depositStrategy": "Strategy 2",
        "transactionBankingComments": "Comments 1",
        "tradeFinanceComments": "Comments 2",
        "treasuryComments": "Comments 3",
      };

      final comments = StrategiesComments.fromJson(json);

      expect(comments.relationshipStrategy, "Strategy 1");
      expect(comments.depositStrategy, "Strategy 2");
      expect(comments.transactionBankingComments, "Comments 1");
      expect(comments.tradeFinanceComments, "Comments 2");
      expect(comments.treasuryComments, "Comments 3");
    });

    test("toJson converts instance to JSON correctly", () {
      final comments = StrategiesComments(
        relationshipStrategy: "Strategy 1",
        depositStrategy: "Strategy 2",
        transactionBankingComments: "Comments 1",
        tradeFinanceComments: "Comments 2",
        treasuryComments: "Comments 3",
      );

      final json = comments.toJson();

      expect(json["relationshipStrategy"], "Strategy 1");
      expect(json["depositStrategy"], "Strategy 2");
      expect(json["transactionBankingComments"], "Comments 1");
      expect(json["tradeFinanceComments"], "Comments 2");
      expect(json["treasuryComments"], "Comments 3");
    });

    test("copyWith creates a new instance with updated values", () {
      final originalComments = StrategiesComments(
        relationshipStrategy: "Original Strategy 1",
        depositStrategy: "Original Strategy 2",
        transactionBankingComments: "Original Comments 1",
        tradeFinanceComments: "Original Comments 2",
        treasuryComments: "Original Comments 3",
      );

      final updatedComments = originalComments.copyWith(
        relationshipStrategy: "New Strategy 1",
        depositStrategy: "New Strategy 2",
      );

      expect(updatedComments.relationshipStrategy, "New Strategy 1");
      expect(updatedComments.depositStrategy, "New Strategy 2");
      expect(updatedComments.transactionBankingComments, "Original Comments 1");
      expect(updatedComments.tradeFinanceComments, "Original Comments 2");
      expect(updatedComments.treasuryComments, "Original Comments 3");
    });

    test("copyWith returns same instance if no new values provided", () {
      final originalComments = StrategiesComments(
        relationshipStrategy: "Original Strategy 1",
        depositStrategy: "Original Strategy 2",
        transactionBankingComments: "Original Comments 1",
        tradeFinanceComments: "Original Comments 2",
        treasuryComments: "Original Comments 3",
      );

      final updatedComments = originalComments.copyWith();

      expect(updatedComments.relationshipStrategy, "Original Strategy 1");
      expect(updatedComments.depositStrategy, "Original Strategy 2");
      expect(updatedComments.transactionBankingComments, "Original Comments 1");
      expect(updatedComments.tradeFinanceComments, "Original Comments 2");
      expect(updatedComments.treasuryComments, "Original Comments 3");
    });
  });
}
