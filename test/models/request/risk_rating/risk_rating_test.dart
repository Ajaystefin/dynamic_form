import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/risk_rating/external_rating.dart";
import "package:wcas_frontend/models/request/risk_rating/internal_rating.dart";
import "package:wcas_frontend/models/request/risk_rating/risk_rating.dart";

void main() {
  group("RiskRating Model Tests", () {
    test("fromJson should parse correctly", () {
      final json = {
        "externalRatingList": [
          {
            "customerName": "ABC Corp",
            "rimNo": 123,
            "ratingList": [
              {"ratingType": 196, "rating": 0},
              {"ratingType": 287, "rating": 0},
              {"ratingType": 286, "rating": 0},
            ],
          }
        ],
        "internalRatingList": [
          {
            "rimNo": 456,
            "customerName": "XYZ Ltd",
            "ifrs": "IFRS9",
            "internalRatingType": "override",
          }
        ],
      };

      final riskRating = RiskRating.fromJson(json);

      expect(riskRating.externalRatings, isNotEmpty);
      expect(riskRating.internalRatings, isNotEmpty);
      expect(riskRating.externalRatings!.first.customerName, "ABC Corp");
      expect(riskRating.internalRatings.first.customerName, "XYZ Ltd");
    });

    test("toJson should generate correct map", () {
      final externalRatings = [
        ExternalRating(
          customerName: "ABC Corp",
          customerRimNo: 123,
          sAndP: Reference(),
          moodys: Reference(),
          fitch: Reference(),
        ),
      ];

      final internalRatings = [
        InternalRating(
          customerRimNo: 456,
          customerName: "XYZ Ltd",
          ifrs: "IFRS9",
          internalRatingType: InternalRatingtype.override,
          approvedRating: 5,
          approvedCrr: 3,
        ),
      ];
      RiskRating.toJson(
        isFiFlow: false,
        externalRatings: externalRatings,
        isClDown: false,
        internalRatings: internalRatings,
      );
    });
  });
}
