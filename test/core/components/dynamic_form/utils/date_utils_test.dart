import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dynamic_form/utils/date_utils.dart";

void main() {
  group("convertDateTimeToFormValue", () {
    test("returns null when input is null", () {
      final result = convertDateTimeToFormValue(null);

      expect(result, isNull);
    });

    test("converts DateTime to correct map format", () {
      final date = DateTime(2025, 12, 24);

      final result = convertDateTimeToFormValue(date);

      expect(result, isNotNull);
      expect(result!["date"]["year"], 2025);
      expect(result["date"]["month"], 12);
      expect(result["date"]["day"], 24);

      expect(result["jsdate"], date.toIso8601String());
      expect(result["formatted"], "24/12/2025");

      expect(result["epoc"], date.millisecondsSinceEpoch ~/ 1000);
    });

    test("formats day and month with leading zeros", () {
      final date = DateTime(2025, 1, 5); // 05/01/2025

      final result = convertDateTimeToFormValue(date);

      expect(result!["formatted"], "05/01/2025");
    });
  });

  group("parseDateFromFormValue", () {
    test("returns null when input is null", () {
      final result = parseDateFromFormValue(null);

      expect(result, isNull);
    });

    test("parses ISO string", () {
      const dateString = "2025-12-24T00:00:00.000Z";

      final result = parseDateFromFormValue(dateString);

      expect(result, isNotNull);
      expect(result!.year, 2025);
      expect(result.month, 12);
      expect(result.day, 24);
    });

    test("returns null for invalid string", () {
      final result = parseDateFromFormValue("invalid-date");

      expect(result, isNull);
    });

    test("returns DateTime if already DateTime", () {
      final date = DateTime(2025, 12, 24);

      final result = parseDateFromFormValue(date);

      expect(result, date);
    });

    test("parses from map with jsdate", () {
      final map = {
        "jsdate": "2025-12-24T00:00:00.000Z",
      };

      final result = parseDateFromFormValue(map);

      expect(result, isNotNull);
      expect(result!.year, 2025);
      expect(result.month, 12);
      expect(result.day, 24);
    });

    test("returns null if map has no jsdate", () {
      final map = {"date": {}};

      final result = parseDateFromFormValue(map);

      expect(result, isNull);
    });

    test("returns null for unsupported type", () {
      final result = parseDateFromFormValue(12345);

      expect(result, isNull);
    });
  });
}
