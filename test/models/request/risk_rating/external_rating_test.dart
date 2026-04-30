import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/risk_rating/external_rating.dart";

void main() {
  group("ExternalRating Model Tests", () {
    test("fromJson should parse correctly", () {
      final json = {
        "customerName": "Acme Corp",
        "rimNo": 12345,
        "ratingList": [
          {"ratingType": 0, "rating": 0},
          {"ratingType": 0, "rating": 0},
        ],
      };

      ExternalRating.fromJson(json);
    });

    test("toJson should serialize correctly", () {
      final rating = ExternalRating(
        customerName: "Acme Corp",
        customerRimNo: 12345,
        isDeleted: false,
        ratings: [
          Reference(name: "S&P", description: "AA"),
          Reference(name: "Moody's", description: "A1"),
        ],
      );

      final json = rating.toJson();

      expect(json["customerName"], "Acme Corp");
      expect(json["customerRimNo"], 12345);
      expect(json["deleted"], false);
      expect(json["ratingList"]?.length, 2);
    });
  });

  group("Ratings Model Tests", () {
    test("fromJson should parse correctly", () {
      final json = {
        "ratingType": 1,
        "rating": 5,
        "cbrbClassification": 2,
        "appRefno": 1001,
      };

      final rating = Ratings.fromJson(json);

      expect(rating.ratingType, 1);
      expect(rating.rating, 5);
      expect(rating.cbrbClassification, 2);
      expect(rating.appRefno, 1001);
    });

    test("toJson should serialize correctly", () {
      final rating = Ratings(1, 5, 2, 1001);

      final json = rating.toJson();

      expect(json["ratingType"], 1);
      expect(json["rating"], 5);
      expect(json["cbrbClassification"], 2);
      expect(json["appRefno"], 1001);
    });
  });
}
