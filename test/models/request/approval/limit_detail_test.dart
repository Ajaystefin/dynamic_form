import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/approval/limit_detail.dart";

void main() {
  group("LimitDetail", () {
    test("fromJson creates a valid LimitDetail object", () {
      final Map<String, dynamic> json = {
        "custName": "Test Customer",
        "rimNo": 12345,
        "limitNumber": "67890",
        "proposedLimit": 100000,
        "presentLimit": 50000,
      };

      final limitDetail = LimitDetail.fromJson(json);

      expect(limitDetail.custName, "Test Customer");
      expect(limitDetail.rimNo, 12345);
      expect(limitDetail.limitNumber, "67890");
      expect(limitDetail.proposedLimit, 100000);
      expect(limitDetail.presentLimit, 50000);
    });

    test("toJson converts LimitDetail object to JSON", () {
      final limitDetail = LimitDetail(
        custName: "Test Customer",
        rimNo: 12345,
        limitNumber: "67890",
        proposedLimit: 100000,
        presentLimit: 50000,
      );

      final json = limitDetail.toJson();

      expect(json["custName"], "Test Customer");
      expect(json["rimNo"], 12345);
      expect(json["limitNumber"], "67890");
      expect(json["proposedLimit"], 100000);
      expect(json["presentLimit"], 50000);
    });

    test("fromJson handles null values", () {
      final Map<String, dynamic> json = {};

      final limitDetail = LimitDetail.fromJson(json);

      expect(limitDetail.custName, isNull);
      expect(limitDetail.rimNo, isNull);
      expect(limitDetail.limitNumber, "");
      expect(limitDetail.proposedLimit, 0);
      expect(limitDetail.presentLimit, 0);
    });

    test("toJson handles null values", () {
      final limitDetail = LimitDetail();

      final json = limitDetail.toJson();

      expect(json["custName"], isNull);
      expect(json["rimNo"], isNull);
      expect(json["limitNumber"], isNull);
      expect(json["proposedLimit"], isNull);
      expect(json["presentLimit"], isNull);
    });
  });
}
