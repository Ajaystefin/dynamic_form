import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/profitability/relationship_profitability_detailed.dart";

void main() {
  group("RelationshipProfitabilityDetail", () {
    test("fromJson creates a valid instance", () {
      final Map<String, dynamic> json = {
        "natureOfBusiness": "Software Development",
      };

      final detail = RelationshipProfitabilityDetail.fromJson(json);

      expect(detail.natureOfBusiness, "Software Development");
    });

    test("toJson converts instance to JSON correctly", () {
      final detail = RelationshipProfitabilityDetail(
        natureOfBusiness: "Software Development",
        last12Months: "1000",
        next12MonthsAmount: "1200.0",
        next12MonthsProfitabilityPercent: "10.5",
        next12To24MonthsAmount: "1500.0",
        next12To24MonthsProfitabilityPercent: "12.0",
      );

      final json = detail.toJson();

      expect(json["natureOfBusiness"], "Software Development");
      expect(json["last12Months"], "1000");
      expect(json["next12MonthsAmount"], "1200.0");
      expect(json["next12MonthsProfitabilityPercent"], "10.5");
      expect(json["next12To24MonthsAmount"], "1500.0");
      expect(json["next12To24MonthsProfitabilityPercent"], "12.0");
    });
  });

  group("RelationshipProfitabilityDetailed", () {
    test("fromJson creates a valid instance", () {
      final Map<String, dynamic> json = {
        "rim": 123,
        "customerName": "Test Customer",
        "relationshipProfitabilityDetail": [
          {
            "natureOfBusiness": "Software Development",
          },
          {
            "natureOfBusiness": "Consulting",
          },
        ],
      };

      final detailed = RelationshipProfitabilityDetailed.fromJson(json);

      expect(detailed.rim, 123);
      expect(detailed.customerName, "Test Customer");
      expect(detailed.relationshipProfitabilityDetail, isNotNull);
      expect(detailed.relationshipProfitabilityDetail!.length, 2);
      expect(
        detailed.relationshipProfitabilityDetail![0].natureOfBusiness,
        "Software Development",
      );
      expect(
        detailed.relationshipProfitabilityDetail![1].natureOfBusiness,
        "Consulting",
      );
    });

    test("toJson converts instance to JSON correctly", () {
      final detail1 = RelationshipProfitabilityDetail(
        natureOfBusiness: "Software Development",
      );

      final detail2 = RelationshipProfitabilityDetail(
        natureOfBusiness: "Consulting",
      );

      final detailed = RelationshipProfitabilityDetailed(
        rim: 123,
        customerName: "Test Customer",
        relationshipProfitabilityDetail: [detail1, detail2],
      );

      detailed.toJson();
    });
  });
}
