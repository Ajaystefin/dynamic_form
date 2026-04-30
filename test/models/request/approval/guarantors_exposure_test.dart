import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/approval/guarantors_exposure.dart";

void main() {
  group("GuarantorsExposure", () {
    test("default constructor allows setting and reading all fields", () {
      final model = GuarantorsExposure(
        rimNo: 111,
        custName: "Acme Corp",
        fundedPresentLimit: 1000,
        nonFundedPresentLimit: 2000,
        tangiblePresentSecurity: 300,
        ccPresentSecurity: 400,
        totalTangiblePresentSecurity: 500,
        totalCCPresentSecurity: 600,
        hasFacility: true,
        totalPresentLimits: 7000,
        presentNetSecurity: 800,
        presentNetCC: 900,
      );

      expect(model.rimNo, 111);
      expect(model.custName, "Acme Corp");
      expect(model.fundedPresentLimit, 1000);
      expect(model.nonFundedPresentLimit, 2000);
      expect(model.tangiblePresentSecurity, 300);
      expect(model.ccPresentSecurity, 400);
      expect(model.totalTangiblePresentSecurity, 500);
      expect(model.totalCCPresentSecurity, 600);
      expect(model.hasFacility, isTrue);
      expect(model.totalPresentLimits, 7000);
      expect(model.presentNetSecurity, 800);
      expect(model.presentNetCC, 900);
    });

    test("fromJson maps all keys correctly when JSON is fully populated", () {
      final json = <String, dynamic>{
        "rimNo": 42,
        "custName": "Foo Ltd",
        "fundedPresentLimit": 100,
        "nonFundedPresentLimit": 200,
        "tangiblePresentSecurity": 10,
        "ccPresentSecurity": 20,
        "totalTangiblePresentSecurity": 30,
        "totalCCPresentSecurity": 40,
        "hasFacility": false,
        "totalPresentLimits": 300,
        "presentNetSecurity": 15,
        "presentNetCC": 25,
      };

      final model = GuarantorsExposure.fromJson(json);

      expect(model.rimNo, 42);
      expect(model.custName, "Foo Ltd");
      expect(model.fundedPresentLimit, 100);
      expect(model.nonFundedPresentLimit, 200);
      expect(model.tangiblePresentSecurity, 10);
      expect(model.ccPresentSecurity, 20);
      expect(model.totalTangiblePresentSecurity, 30);
      expect(model.totalCCPresentSecurity, 40);
      expect(model.hasFacility, isFalse);
      expect(model.totalPresentLimits, 300);
      expect(model.presentNetSecurity, 15);
      expect(model.presentNetCC, 25);
    });

    test("fromJson handles missing or null keys gracefully", () {
      final json = <String, dynamic>{
        "rimNo": null,
        "custName": null,
        // omit other keys entirely
      };

      final model = GuarantorsExposure.fromJson(json);

      expect(model.rimNo, isNull);
      expect(model.custName, isNull);
      expect(model.fundedPresentLimit, isNull);
      expect(model.nonFundedPresentLimit, isNull);
      expect(model.tangiblePresentSecurity, isNull);
      expect(model.ccPresentSecurity, isNull);
      expect(model.totalTangiblePresentSecurity, isNull);
      expect(model.totalCCPresentSecurity, isNull);
      expect(model.hasFacility, isNull);
      expect(model.totalPresentLimits, isNull);
      expect(model.presentNetSecurity, isNull);
      expect(model.presentNetCC, isNull);
    });

    test("toJson returns a map with all properties, including nulls", () {
      final model = GuarantorsExposure(
        rimNo: 7,
        custName: "Bar Inc",
        fundedPresentLimit: 700,
        nonFundedPresentLimit: 800,
        tangiblePresentSecurity: 50,
        ccPresentSecurity: 60,
        totalTangiblePresentSecurity: 110,
        totalCCPresentSecurity: 120,
        hasFacility: true,
        totalPresentLimits: 1500,
        presentNetSecurity: 55,
        presentNetCC: 65,
      );

      final map = model.toJson();

      expect(map["rimNo"], 7);
      expect(map["custName"], "Bar Inc");
      expect(map["fundedPresentLimit"], 700);
      expect(map["nonFundedPresentLimit"], 800);
      expect(map["tangiblePresentSecurity"], 50);
      expect(map["ccPresentSecurity"], 60);
      expect(map["totalTangiblePresentSecurity"], 110);
      expect(map["totalCCPresentSecurity"], 120);
      expect(map["hasFacility"], isTrue);
      expect(map["totalPresentLimits"], 1500);
      expect(map["presentNetSecurity"], 55);
      expect(map["presentNetCC"], 65);
    });

    test("toJson includes null values when fields are null", () {
      final model = GuarantorsExposure(); // all fields default to null

      final map = model.toJson();

      expect(map["rimNo"], isNull);
      expect(map["custName"], isNull);
      expect(map["fundedPresentLimit"], isNull);
      expect(map["nonFundedPresentLimit"], isNull);
      expect(map["tangiblePresentSecurity"], isNull);
      expect(map["ccPresentSecurity"], isNull);
      expect(map["totalTangiblePresentSecurity"], isNull);
      expect(map["totalCCPresentSecurity"], isNull);
      expect(map["hasFacility"], isNull);
      expect(map["totalPresentLimits"], isNull);
      expect(map["presentNetSecurity"], isNull);
      expect(map["presentNetCC"], isNull);
    });

    test("round-trip conversion: toJson then fromJson preserves values", () {
      final original = GuarantorsExposure(
        rimNo: 99,
        custName: "RoundTrip Co",
        fundedPresentLimit: 900,
        nonFundedPresentLimit: 1000,
        tangiblePresentSecurity: 150,
        ccPresentSecurity: 160,
        totalTangiblePresentSecurity: 310,
        totalCCPresentSecurity: 320,
        hasFacility: false,
        totalPresentLimits: 1900,
        presentNetSecurity: 140,
        presentNetCC: 150,
      );

      final json = original.toJson();
      final recreated = GuarantorsExposure.fromJson(json);

      expect(recreated.rimNo, original.rimNo);
      expect(recreated.custName, original.custName);
      expect(recreated.fundedPresentLimit, original.fundedPresentLimit);
      expect(recreated.nonFundedPresentLimit, original.nonFundedPresentLimit);
      expect(
        recreated.tangiblePresentSecurity,
        original.tangiblePresentSecurity,
      );
      expect(recreated.ccPresentSecurity, original.ccPresentSecurity);
      expect(
        recreated.totalTangiblePresentSecurity,
        original.totalTangiblePresentSecurity,
      );
      expect(recreated.totalCCPresentSecurity, original.totalCCPresentSecurity);
      expect(recreated.hasFacility, original.hasFacility);
      expect(recreated.totalPresentLimits, original.totalPresentLimits);
      expect(recreated.presentNetSecurity, original.presentNetSecurity);
      expect(recreated.presentNetCC, original.presentNetCC);
    });
  });
}
