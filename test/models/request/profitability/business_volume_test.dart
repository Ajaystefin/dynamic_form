import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/profitability/business_volume.dart";

void main() {
  group("BusinessVolume", () {
    test("fromJson creates a valid instance", () {
      final Map<String, dynamic> json = {
        "natureOfBusiness": "Software Development",
        "previousYear": "100000.0",
        "currentYearYtd": "120000.0",
        "estimatesForNextYear": "150000.0",
      };

      final businessVolume = BusinessVolume.fromJson(json);

      expect(businessVolume.natureOfBusiness, "Software Development");
      expect(businessVolume.previousYear, "100000.0");
      expect(businessVolume.currentYearYtd, "120000.0");
      expect(businessVolume.estimatesForNextYear, "150000.0");
    });

    test("toJson converts instance to JSON correctly", () {
      final businessVolume = BusinessVolume(
        natureOfBusiness: "Software Development",
        previousYear: "100000.0",
        currentYearYtd: "120000.0",
        estimatesForNextYear: "150000.0",
      );

      final json = businessVolume.toJson();

      expect(json["natureOfBusiness"], "Software Development");
      expect(json["previousYear"], "100000.0");
      expect(json["currentYearYtd"], "120000.0");
      expect(json["estimatesForNextYear"], "150000.0");
    });
  });
}
