import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/profitability/profitability_summary/profitability_data.dart";

void main() {
  // ──────────────────────────────────────────────────────────────────
  // Default constructor
  // ──────────────────────────────────────────────────────────────────
  group("ProfitabilityData – default constructor", () {
    test("all fields null when not provided", () {
      final data = ProfitabilityData();
      expect(data.nii, isNull);
      expect(data.nfi, isNull);
      expect(data.expectedNetIncome, isNull);
      expect(data.avgCasa, isNull);
      expect(data.rwa, isNull);
      expect(data.realizedNii, isNull);
      expect(data.realizedNfi, isNull);
      expect(data.realizedExpectedNetIncome, isNull);
      expect(data.realizedAvgCasa, isNull);
      expect(data.realizedRwa, isNull);
    });

    test("all fields set when provided as strings", () {
      final data = ProfitabilityData(
        nii: "100",
        nfi: "50",
        expectedNetIncome: "150",
        avgCasa: "200",
        rwa: "300",
        realizedNii: "90",
        realizedNfi: "45",
        realizedExpectedNetIncome: "135",
        realizedAvgCasa: "180",
        realizedRwa: "270",
      );
      expect(data.nii, "100");
      expect(data.nfi, "50");
      expect(data.expectedNetIncome, "150");
      expect(data.avgCasa, "200");
      expect(data.rwa, "300");
      expect(data.realizedNii, "90");
      expect(data.realizedNfi, "45");
      expect(data.realizedExpectedNetIncome, "135");
      expect(data.realizedAvgCasa, "180");
      expect(data.realizedRwa, "270");
    });

    test("partial fields – only projected set", () {
      final data = ProfitabilityData(nii: "10", rwa: "20");
      expect(data.nii, "10");
      expect(data.rwa, "20");
      expect(data.nfi, isNull);
      expect(data.realizedNii, isNull);
    });
  });

  // ──────────────────────────────────────────────────────────────────
  // fromJhson  (note the typo in the source – "Jhson")
  // ──────────────────────────────────────────────────────────────────
  group("ProfitabilityData.fromJhson", () {
    test("converts int values to String correctly", () {
      final json = <String, dynamic>{
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
      };
      final data = ProfitabilityData.fromJhson(json);
      expect(data.nii, "100");
      expect(data.nfi, "50");
      expect(data.expectedNetIncome, "150");
      expect(data.avgCasa, "200");
      expect(data.rwa, "300");
      expect(data.realizedNii, "90");
      expect(data.realizedNfi, "45");
      expect(data.realizedExpectedNetIncome, "135");
      expect(data.realizedAvgCasa, "180");
      expect(data.realizedRwa, "270");
    });

    test("converts double values to String correctly", () {
      final json = <String, dynamic>{
        "nii": 1.5,
        "nfi": 2.75,
        "expectedNetIncome": 3.0,
        "avgCasa": 4.1,
        "rwa": 5.9,
        "realizedNii": 6.2,
        "realizedNfi": 7.8,
        "realizedExpectedNetIncome": 8.3,
        "realizedAvgCasa": 9.0,
        "realizedRwa": 10.1,
      };
      final data = ProfitabilityData.fromJhson(json);
      expect(data.nii, "1.5");
      expect(data.nfi, "2.75");
      expect(data.realizedRwa, "10.1");
    });

    test("keeps String values as-is", () {
      final json = <String, dynamic>{
        "nii": "500",
        "nfi": "250",
        "expectedNetIncome": "750",
        "avgCasa": "1000",
        "rwa": "1500",
        "realizedNii": "450",
        "realizedNfi": "225",
        "realizedExpectedNetIncome": "675",
        "realizedAvgCasa": "900",
        "realizedRwa": "1350",
      };
      final data = ProfitabilityData.fromJhson(json);
      expect(data.nii, "500");
      expect(data.realizedRwa, "1350");
    });

    test("all null values produce null fields", () {
      final json = <String, dynamic>{
        "nii": null,
        "nfi": null,
        "expectedNetIncome": null,
        "avgCasa": null,
        "rwa": null,
        "realizedNii": null,
        "realizedNfi": null,
        "realizedExpectedNetIncome": null,
        "realizedAvgCasa": null,
        "realizedRwa": null,
      };
      final data = ProfitabilityData.fromJhson(json);
      expect(data.nii, isNull);
      expect(data.nfi, isNull);
      expect(data.expectedNetIncome, isNull);
      expect(data.avgCasa, isNull);
      expect(data.rwa, isNull);
      expect(data.realizedNii, isNull);
      expect(data.realizedNfi, isNull);
      expect(data.realizedExpectedNetIncome, isNull);
      expect(data.realizedAvgCasa, isNull);
      expect(data.realizedRwa, isNull);
    });

    test("missing keys produce null fields", () {
      final data = ProfitabilityData.fromJhson({});
      expect(data.nii, isNull);
      expect(data.realizedRwa, isNull);
    });

    test("partial json – only some keys present", () {
      final json = <String, dynamic>{
        "nii": 42,
        "realizedNfi": 21,
      };
      final data = ProfitabilityData.fromJhson(json);
      expect(data.nii, "42");
      expect(data.realizedNfi, "21");
      expect(data.nfi, isNull);
      expect(data.realizedNii, isNull);
    });
  });

  // ──────────────────────────────────────────────────────────────────
  // fromProjectedNext12MonthsJson
  // ──────────────────────────────────────────────────────────────────
  group("ProfitabilityData.fromProjectedNext12MonthsJson", () {
    test("converts int values – projected only (5 fields)", () {
      final json = <String, dynamic>{
        "nii": 10,
        "nfi": 20,
        "expectedNetIncome": 30,
        "avgCasa": 40,
        "rwa": 50,
      };
      final data = ProfitabilityData.fromProjectedNext12MonthsJson(json);
      expect(data.nii, "10");
      expect(data.nfi, "20");
      expect(data.expectedNetIncome, "30");
      expect(data.avgCasa, "40");
      expect(data.rwa, "50");
      // realized fields should be null
      expect(data.realizedNii, isNull);
      expect(data.realizedNfi, isNull);
      expect(data.realizedExpectedNetIncome, isNull);
      expect(data.realizedAvgCasa, isNull);
      expect(data.realizedRwa, isNull);
    });

    test("handles null values", () {
      final json = <String, dynamic>{
        "nii": null,
        "nfi": null,
        "expectedNetIncome": null,
        "avgCasa": null,
        "rwa": null,
      };
      final data = ProfitabilityData.fromProjectedNext12MonthsJson(json);
      expect(data.nii, isNull);
      expect(data.rwa, isNull);
    });

    test("empty json produces all null", () {
      final data = ProfitabilityData.fromProjectedNext12MonthsJson({});
      expect(data.nii, isNull);
      expect(data.nfi, isNull);
      expect(data.expectedNetIncome, isNull);
      expect(data.avgCasa, isNull);
      expect(data.rwa, isNull);
    });

    test("string values kept as-is", () {
      final json = <String, dynamic>{
        "nii": "99",
        "nfi": "88",
        "expectedNetIncome": "77",
        "avgCasa": "66",
        "rwa": "55",
      };
      final data = ProfitabilityData.fromProjectedNext12MonthsJson(json);
      expect(data.nii, "99");
      expect(data.rwa, "55");
    });
  });

  // ──────────────────────────────────────────────────────────────────
  // fromRealizedLastYearsJson
  // ──────────────────────────────────────────────────────────────────
  group("ProfitabilityData.fromRealizedLastYearsJson", () {
    test("converts int values – 5 fields, realized fields remain null", () {
      final json = <String, dynamic>{
        "nii": 11,
        "nfi": 22,
        "expectedNetIncome": 33,
        "avgCasa": 44,
        "rwa": 55,
      };
      final data = ProfitabilityData.fromRealizedLastYearsJson(json);
      expect(data.nii, "11");
      expect(data.nfi, "22");
      expect(data.expectedNetIncome, "33");
      expect(data.avgCasa, "44");
      expect(data.rwa, "55");
      expect(data.realizedNii, isNull);
      expect(data.realizedRwa, isNull);
    });

    test("handles null values", () {
      final json = <String, dynamic>{
        "nii": null,
        "nfi": null,
        "expectedNetIncome": null,
        "avgCasa": null,
        "rwa": null,
      };
      final data = ProfitabilityData.fromRealizedLastYearsJson(json);
      expect(data.nii, isNull);
      expect(data.rwa, isNull);
    });

    test("empty json produces all null", () {
      final data = ProfitabilityData.fromRealizedLastYearsJson({});
      expect(data.nii, isNull);
      expect(data.rwa, isNull);
    });

    test("double values are stringified", () {
      final json = <String, dynamic>{
        "nii": 3.14,
        "nfi": 2.71,
        "expectedNetIncome": 1.41,
        "avgCasa": 1.73,
        "rwa": 2.23,
      };
      final data = ProfitabilityData.fromRealizedLastYearsJson(json);
      expect(data.nii, "3.14");
      expect(data.rwa, "2.23");
    });
  });

  // ──────────────────────────────────────────────────────────────────
  // toProjectedNext12MonthsJson
  // ──────────────────────────────────────────────────────────────────
  group("ProfitabilityData.toProjectedNext12MonthsJson", () {
    test("returns correct map with all projected fields", () {
      final data = ProfitabilityData(
        nii: "10",
        nfi: "20",
        expectedNetIncome: "30",
        avgCasa: "40",
        rwa: "50",
        // realized fields should NOT appear
        realizedNii: "9",
        realizedRwa: "45",
      );
      final map = data.toProjectedNext12MonthsJson();
      expect(map.length, 5);
      expect(map["nii"], "10");
      expect(map["nfi"], "20");
      expect(map["expectedNetIncome"], "30");
      expect(map["avgCasa"], "40");
      expect(map["rwa"], "50");
      expect(map.containsKey("realizedNii"), isFalse);
      expect(map.containsKey("realizedRwa"), isFalse);
    });

    test("returns null values when fields are null", () {
      final data = ProfitabilityData();
      final map = data.toProjectedNext12MonthsJson();
      expect(map["nii"], isNull);
      expect(map["rwa"], isNull);
    });
  });

  // ──────────────────────────────────────────────────────────────────
  // toRealizedLastYearsJson
  // ──────────────────────────────────────────────────────────────────
  group("ProfitabilityData.toRealizedLastYearsJson", () {
    test("returns correct map with projected-named keys only", () {
      final data = ProfitabilityData(
        nii: "100",
        nfi: "200",
        expectedNetIncome: "300",
        avgCasa: "400",
        rwa: "500",
        realizedNii: "90",
      );
      final map = data.toRealizedLastYearsJson();
      expect(map.length, 5);
      expect(map["nii"], "100");
      expect(map["nfi"], "200");
      expect(map["expectedNetIncome"], "300");
      expect(map["avgCasa"], "400");
      expect(map["rwa"], "500");
      expect(map.containsKey("realizedNii"), isFalse);
    });

    test("null fields produce null values in map", () {
      final data = ProfitabilityData();
      final map = data.toRealizedLastYearsJson();
      expect(map["nii"], isNull);
      expect(map["rwa"], isNull);
    });
  });

  // ──────────────────────────────────────────────────────────────────
  // toJson (full 10-field map)
  // ──────────────────────────────────────────────────────────────────
  group("ProfitabilityData.toJson", () {
    test("returns all 10 fields when fully populated", () {
      final data = ProfitabilityData(
        nii: "100",
        nfi: "50",
        expectedNetIncome: "150",
        avgCasa: "200",
        rwa: "300",
        realizedNii: "90",
        realizedNfi: "45",
        realizedExpectedNetIncome: "135",
        realizedAvgCasa: "180",
        realizedRwa: "270",
      );
      final map = data.toJson();
      expect(map.length, 10);
      expect(map["nii"], "100");
      expect(map["nfi"], "50");
      expect(map["expectedNetIncome"], "150");
      expect(map["avgCasa"], "200");
      expect(map["rwa"], "300");
      expect(map["realizedNii"], "90");
      expect(map["realizedNfi"], "45");
      expect(map["realizedExpectedNetIncome"], "135");
      expect(map["realizedAvgCasa"], "180");
      expect(map["realizedRwa"], "270");
    });

    test("all null when empty constructor", () {
      final map = ProfitabilityData().toJson();
      expect(map.length, 10);
      expect(map["nii"], isNull);
      expect(map["realizedRwa"], isNull);
    });

    test("roundtrip fromJhson → toJson preserves values", () {
      final json = <String, dynamic>{
        "nii": 1,
        "nfi": 2,
        "expectedNetIncome": 3,
        "avgCasa": 4,
        "rwa": 5,
        "realizedNii": 6,
        "realizedNfi": 7,
        "realizedExpectedNetIncome": 8,
        "realizedAvgCasa": 9,
        "realizedRwa": 10,
      };
      final roundTrip = ProfitabilityData.fromJhson(json).toJson();
      expect(roundTrip["nii"], "1");
      expect(roundTrip["realizedRwa"], "10");
    });

    test("roundtrip fromProjectedNext12MonthsJson → toJson", () {
      final json = <String, dynamic>{
        "nii": 7,
        "nfi": 8,
        "expectedNetIncome": 9,
        "avgCasa": 10,
        "rwa": 11,
      };
      final data = ProfitabilityData.fromProjectedNext12MonthsJson(json);
      final map = data.toJson();
      expect(map["nii"], "7");
      expect(map["rwa"], "11");
      expect(map["realizedNii"], isNull);
    });

    test("roundtrip fromRealizedLastYearsJson → toJson", () {
      final json = <String, dynamic>{
        "nii": 15,
        "nfi": 16,
        "expectedNetIncome": 17,
        "avgCasa": 18,
        "rwa": 19,
      };
      final data = ProfitabilityData.fromRealizedLastYearsJson(json);
      final map = data.toJson();
      expect(map["nii"], "15");
      expect(map["realizedNii"], isNull);
    });
  });

  // ──────────────────────────────────────────────────────────────────
  // Field mutation (direct field set)
  // ──────────────────────────────────────────────────────────────────
  group("ProfitabilityData – field mutation", () {
    test("fields are mutable", () {
      final data = ProfitabilityData()
        ..nii = "updated"
        ..realizedRwa = "realizedUpdated";
      expect(data.nii, "updated");
      expect(data.realizedRwa, "realizedUpdated");
    });
  });
}
