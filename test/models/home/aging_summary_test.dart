import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/home/aging_summary.dart";

void main() {
  group("AgingSummary", () {
    test("constructor creates valid object with all parameters", () {
      const summary = AgingSummary(
        zeroToSevenDays: 10,
        eightToFifteenDays: 20,
        sixteenToThirtyDays: 30,
        aboveThirtyDays: 40,
      );

      expect(summary.zeroToSevenDays, 10.0);
      expect(summary.eightToFifteenDays, 20.0);
      expect(summary.sixteenToThirtyDays, 30.0);
      expect(summary.aboveThirtyDays, 40.0);
    });

    test("fromJson creates valid AgingSummary object", () {
      final json = {
        "0_7_days": 15.5,
        "8_15_days": 25.5,
        "16_30_days": 35.5,
        "abv_30_days": 45.5,
      };

      final summary = AgingSummary.fromJson(json);

      expect(summary.zeroToSevenDays, 15.5);
      expect(summary.eightToFifteenDays, 25.5);
      expect(summary.sixteenToThirtyDays, 35.5);
      expect(summary.aboveThirtyDays, 45.5);
    });

    test("fromJson handles null values with defaults", () {
      final json = <String, dynamic>{};

      final summary = AgingSummary.fromJson(json);

      expect(summary.zeroToSevenDays, 0);
      expect(summary.eightToFifteenDays, 0);
      expect(summary.sixteenToThirtyDays, 0);
      expect(summary.aboveThirtyDays, 0);
    });

    test("fromJson handles partial data", () {
      final json = {
        "0_7_days": 5.0,
      };

      final summary = AgingSummary.fromJson(json);

      expect(summary.zeroToSevenDays, 5.0);
      expect(summary.eightToFifteenDays, 0);
      expect(summary.sixteenToThirtyDays, 0);
      expect(summary.aboveThirtyDays, 0);
    });

    test("toJson returns correct map", () {
      const summary = AgingSummary(
        zeroToSevenDays: 10,
        eightToFifteenDays: 20,
        sixteenToThirtyDays: 30,
        aboveThirtyDays: 40,
      );

      final json = summary.toJson();

      expect(json["0_7_days"], 10.0);
      expect(json["8_15_days"], 20.0);
      expect(json["16_30_days"], 30.0);
      expect(json["abv_30_days"], 40.0);
    });

    test("toJson and fromJson are reversible", () {
      const original = AgingSummary(
        zeroToSevenDays: 12.5,
        eightToFifteenDays: 22.5,
        sixteenToThirtyDays: 32.5,
        aboveThirtyDays: 42.5,
      );

      final json = original.toJson();
      final restored = AgingSummary.fromJson(json);

      expect(restored.zeroToSevenDays, original.zeroToSevenDays);
      expect(restored.eightToFifteenDays, original.eightToFifteenDays);
      expect(restored.sixteenToThirtyDays, original.sixteenToThirtyDays);
      expect(restored.aboveThirtyDays, original.aboveThirtyDays);
    });

    test("fromJson handles double values as strings", () {
      // Test with explicit double values
      final json = {
        "0_7_days": 10.0,
        "8_15_days": 20.0,
        "16_30_days": 30.0,
        "abv_30_days": 40.0,
      };

      final summary = AgingSummary.fromJson(json);

      expect(summary.zeroToSevenDays, 10.0);
      expect(summary.eightToFifteenDays, 20.0);
      expect(summary.sixteenToThirtyDays, 30.0);
      expect(summary.aboveThirtyDays, 40.0);
    });

    test("fromJson handles zero values", () {
      final json = {
        "0_7_days": 0.0,
        "8_15_days": 0.0,
        "16_30_days": 0.0,
        "abv_30_days": 0.0,
      };

      final summary = AgingSummary.fromJson(json);

      expect(summary.zeroToSevenDays, 0.0);
      expect(summary.eightToFifteenDays, 0.0);
      expect(summary.sixteenToThirtyDays, 0.0);
      expect(summary.aboveThirtyDays, 0.0);
    });
  });
}
