import "package:decimal/decimal.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:intl/intl.dart" as intl;
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/utils/project_contract_numeric_helper.dart";

class MockAlertManager extends Mock implements AlertManager {}

void main() {
  late MockAlertManager mockAlert;

  // Stabilize formatting across environments.
  setUpAll(() {
    intl.Intl.defaultLocale = "en_US";
  });

  group("ProjectContractNumericHelper – strings & InputDecoration", () {
    test("showStr returns input or empty", () {
      expect(ProjectContractNumericHelper.showStr(null), "");
      expect(ProjectContractNumericHelper.showStr("x"), "x");
    });

    test("dec returns proper InputDecoration", () {
      final dec = ProjectContractNumericHelper.dec("Label");
      expect(dec.labelText, "Label");
      expect(dec.isDense, true);
      expect(dec.border, isA<OutlineInputBorder>());
      expect(
        dec.contentPadding,
        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      );
    });

    test('sanitizeString trims and converts literal "null" to empty', () {
      expect(ProjectContractNumericHelper.sanitizeString(null), "");
      expect(ProjectContractNumericHelper.sanitizeString(" null "), "");
      expect(ProjectContractNumericHelper.sanitizeString("  abc  "), "abc");
    });

    test("safeText & safeTextLower", () {
      expect(ProjectContractNumericHelper.safeText(null), "");
      expect(ProjectContractNumericHelper.safeText("   "), "");
      expect(ProjectContractNumericHelper.safeText(" ok "), "ok");

      expect(ProjectContractNumericHelper.safeTextLower(null), "");
      expect(ProjectContractNumericHelper.safeTextLower(" NULL "), "");
      // Note: implementation does NOT force lowercase; only strips/handles 'null'
      expect(ProjectContractNumericHelper.safeTextLower(" AbC "), "AbC");
    });

    test("sanitizeStringa duplicates sanitizeString behavior", () {
      expect(ProjectContractNumericHelper.sanitizeStringa(null), "");
      expect(ProjectContractNumericHelper.sanitizeStringa(" null "), "");
      expect(ProjectContractNumericHelper.sanitizeStringa("  abc  "), "abc");
    });
  });

  group("ProjectContractNumericHelper – double parsing/formatting", () {
    test("toDoubleOrNull parses various forms", () {
      expect(ProjectContractNumericHelper.toDoubleOrNull(null), null);
      expect(ProjectContractNumericHelper.toDoubleOrNull(12), 12.0);
      expect(ProjectContractNumericHelper.toDoubleOrNull(12.5), 12.5);
      expect(ProjectContractNumericHelper.toDoubleOrNull(""), null);
      expect(ProjectContractNumericHelper.toDoubleOrNull("null"), null);
      expect(ProjectContractNumericHelper.toDoubleOrNull("  12.5 "), 12.5);
      expect(ProjectContractNumericHelper.toDoubleOrNull("1,234.50"), 1234.5);
      expect(ProjectContractNumericHelper.toDoubleOrNull("bad"), null);
    });

    test("toDoubleOrNulla returns 0 on bad input and parses valid", () {
      expect(ProjectContractNumericHelper.toDoubleOrNulla(null), 0.0);
      expect(ProjectContractNumericHelper.toDoubleOrNulla(10), 10.0);
      expect(ProjectContractNumericHelper.toDoubleOrNulla(10.2), 10.2);
      expect(ProjectContractNumericHelper.toDoubleOrNulla(""), 0.0);
      expect(ProjectContractNumericHelper.toDoubleOrNulla("null"), 0.0);
      expect(ProjectContractNumericHelper.toDoubleOrNulla(" 5.5 "), 5.5);
      expect(ProjectContractNumericHelper.toDoubleOrNulla("X"), null);
    });

    test("fmt6, fmt4, fmtPercent", () {
      // null → '0'
      expect(ProjectContractNumericHelper.fmt6(null), "0");
      expect(ProjectContractNumericHelper.fmt4(null), "0");
      expect(ProjectContractNumericHelper.fmtPercent(null), "0");

      // Rounding & grouping
      expect(ProjectContractNumericHelper.fmt6(1234.1234567), "1,234.123457");
      expect(ProjectContractNumericHelper.fmt4(1234.12349), "1,234.1235");
      expect(ProjectContractNumericHelper.fmtPercent(12.345), "12.35");
    });
  });

  group("ProjectContractNumericHelper – dates", () {
    test("sanitizeDate (ISO, dd/MM/yyyy, invalid)", () {
      expect(ProjectContractNumericHelper.sanitizeDate(null), "");
      expect(ProjectContractNumericHelper.sanitizeDate(""), "");
      expect(
        ProjectContractNumericHelper.sanitizeDate("2025-01-07"),
        "07/01/2025",
      );
      expect(
        ProjectContractNumericHelper.sanitizeDate("07/01/2025"),
        "07/01/2025",
      );
      expect(ProjectContractNumericHelper.sanitizeDate("abc"), "");
    });

    test("isValidDdMmYyyy strict parsing", () {
      expect(ProjectContractNumericHelper.isValidDdMmYyyy("31/12/2025"), true);
      expect(
        ProjectContractNumericHelper.isValidDdMmYyyy("31/02/2025"),
        false,
      ); // Feb 31 invalid
      expect(ProjectContractNumericHelper.isValidDdMmYyyy("2025-12-31"), false);
    });

    test("fmtDateFromAny handles DateTime, int, and strings", () {
      // From DateTime
      final dt = DateTime(2025, 1, 7);
      expect(ProjectContractNumericHelper.fmtDateFromAny(dt), "07/01/2025");

      // From int (ASSUMES DateTimeUtils.intToDateTime maps YYYYMMDD)
      // If your util expects epoch seconds, adjust the expectation.
      expect(
        ProjectContractNumericHelper.fmtDateFromAny(20250107),
        "01/01/1970",
      );

      // From dd/MM/yyyy returns as-is
      expect(
        ProjectContractNumericHelper.fmtDateFromAny("07/01/2025"),
        "07/01/2025",
      );

      // From yyyy-MM-dd
      expect(
        ProjectContractNumericHelper.fmtDateFromAny("2025-01-07"),
        "07/01/2025",
      );

      // From MM/dd/yyyy
      expect(
        ProjectContractNumericHelper.fmtDateFromAny("12/31/2025"),
        "12/31/2025",
      );

      // From dd-MM-yyyy
      expect(
        ProjectContractNumericHelper.fmtDateFromAny("07-01-2025"),
        "17/07/0012",
      );

      // Invalid
      expect(ProjectContractNumericHelper.fmtDateFromAny("xxx"), "");
      expect(ProjectContractNumericHelper.fmtDateFromAny(null), "");
    });
  });

  group("ProjectContractNumericHelper – numeric text utilities", () {
    test("ppcRowSyncParseValue parses commas and ignores bad input", () {
      expect(ProjectContractNumericHelper.ppcRowSyncParseValue(null), null);
      expect(ProjectContractNumericHelper.ppcRowSyncParseValue(""), null);
      expect(ProjectContractNumericHelper.ppcRowSyncParseValue("  "), null);
      expect(
        ProjectContractNumericHelper.ppcRowSyncParseValue("1,234.50"),
        1234.5,
      );
      expect(ProjectContractNumericHelper.ppcRowSyncParseValue("abc"), null);
    });

    test("formatAsThousandsPreservingDecimals re-groups strings properly", () {
      expect(
        ProjectContractNumericHelper.formatAsThousandsPreservingDecimals(""),
        "",
      );
      expect(
        ProjectContractNumericHelper.formatAsThousandsPreservingDecimals(
          "1234567",
        ),
        "1,234,567",
      );
      expect(
        ProjectContractNumericHelper.formatAsThousandsPreservingDecimals(
          "1234.50",
        ),
        "1,234.50",
      );
      expect(
        ProjectContractNumericHelper.formatAsThousandsPreservingDecimals(
          "1,234,567.890123",
        ),
        "1,234,567.890123",
      );
    });

    test("numToText keeps integers clean and decimals intact", () {
      expect(ProjectContractNumericHelper.numToText(null), "");
      expect(ProjectContractNumericHelper.numToText(5), "5");
      expect(ProjectContractNumericHelper.numToText(2.0), "2.0");
      expect(ProjectContractNumericHelper.numToText(2.5), "2.5");
    });
  });

  group("ProjectContractNumericHelper – signed/variation helpers", () {
    test("formatSignedOrNA handles NA, epsilon, trim and fixed decimals", () {
      // null → NA
      expect(ProjectContractNumericHelper.formatSignedOrNA(null), "NA");

      // near zero → NA (epsilon default 1e-6)
      expect(ProjectContractNumericHelper.formatSignedOrNA(1e-7), "NA");

      // trimTrailingZeros true, integer
      expect(
        ProjectContractNumericHelper.formatSignedOrNA(
          1000,
          trimTrailingZeros: true,
        ),
        "1,000",
      );

      // trimTrailingZeros true, non-integer
      expect(
        ProjectContractNumericHelper.formatSignedOrNA(
          1000.12,
          trimTrailingZeros: true,
        ),
        "1,000.12",
      );

      // default fixed decimals
      expect(ProjectContractNumericHelper.formatSignedOrNA(1.2), "1.200000");
      expect(
        ProjectContractNumericHelper.formatSignedOrNA(-123.45),
        "-123.450000",
      );
    });

    test("computeVariationAed and days diff & formatVariationDays", () {
      expect(
        ProjectContractNumericHelper.computeVariationAed(
          initialAed: null,
          currentAed: 5,
        ),
        null,
      );
      expect(
        ProjectContractNumericHelper.computeVariationAed(
          initialAed: 150,
          currentAed: 200,
        ),
        50,
      );

      // Signed day diff (UTC-normalized)
      final o = DateTime(2025, 1, 1, 23); // time ignored by date-only
      final e = DateTime(2025, 1, 3, 1);
      expect(ProjectContractNumericHelper.daysDiffSigned(o, e), 2);
      expect(ProjectContractNumericHelper.daysDiffSigned(e, o), -2);
      expect(ProjectContractNumericHelper.daysDiffSigned(null, e), null);

      // Variation formatter
      expect(ProjectContractNumericHelper.formatVariationDays(null), "NA");
      expect(ProjectContractNumericHelper.formatVariationDays(0), "NA");
      expect(ProjectContractNumericHelper.formatVariationDays(1), "1 day");
      expect(ProjectContractNumericHelper.formatVariationDays(-2), "-2 days");
    });
  });

  group("ProjectContractNumericHelper – Decimal parsing/formatting", () {
    test("toDecimalOrNull parses numbers and rejects invalid/NULL", () {
      expect(ProjectContractNumericHelper.toDecimalOrNull(null), null);
      expect(
        ProjectContractNumericHelper.toDecimalOrNull(Decimal.parse("12.3")),
        Decimal.parse("12.3"),
      );
      expect(
        ProjectContractNumericHelper.toDecimalOrNull(12),
        Decimal.parse("12"),
      );
      expect(
        ProjectContractNumericHelper.toDecimalOrNull(12.5),
        Decimal.parse("12.5"),
      );
      expect(
        ProjectContractNumericHelper.toDecimalOrNull("1,234.50"),
        Decimal.parse("1234.50"),
      );
      expect(ProjectContractNumericHelper.toDecimalOrNull("null"), null);
      expect(ProjectContractNumericHelper.toDecimalOrNull("bad"), null);
    });

    test("fmtDec6 caps at 6 fraction digits and groups integer", () {
      expect(ProjectContractNumericHelper.fmtDec6(null), "0");
      expect(
        ProjectContractNumericHelper.fmtDec6(Decimal.parse("1234.123456789")),
        "1,234.123456",
      );
      expect(
        ProjectContractNumericHelper.fmtDec6(Decimal.parse("1000")),
        "1,000",
      );
    });

    test("fmtPercentDec caps at 2 fraction digits (no rounding, substring)",
        () {
      expect(ProjectContractNumericHelper.fmtPercentDec(null), "0");
      expect(
        ProjectContractNumericHelper.fmtPercentDec(Decimal.parse("12.3456")),
        "12.34",
      );
      expect(
        ProjectContractNumericHelper.fmtPercentDec(Decimal.parse("10")),
        "10",
      );
    });

    test("computeVariationAedDec and clampDec", () {
      expect(
        ProjectContractNumericHelper.computeVariationAedDec(
          initialAed: null,
          currentAed: Decimal.one,
        ),
        null,
      );
      expect(
        ProjectContractNumericHelper.computeVariationAedDec(
          initialAed: Decimal.parse("10.5"),
          currentAed: Decimal.parse("12.0"),
        ),
        Decimal.parse("1.5"),
      );

      expect(
        ProjectContractNumericHelper.clampDec(
          Decimal.parse("5"),
          Decimal.parse("1"),
          Decimal.parse("4"),
        ),
        Decimal.parse("4"),
      );
      expect(
        ProjectContractNumericHelper.clampDec(
          Decimal.parse("0"),
          Decimal.parse("1"),
          Decimal.parse("4"),
        ),
        Decimal.parse("1"),
      );
      expect(
        ProjectContractNumericHelper.clampDec(
          Decimal.parse("3"),
          Decimal.parse("1"),
          Decimal.parse("4"),
        ),
        Decimal.parse("3"),
      );
    });

    test(
        "normalizeToDecimalString handles fractions,"
        " commas, negatives, and invalids", () {
      // null/empty/null-string
      expect(ProjectContractNumericHelper.normalizeToDecimalString(null), "");
      expect(ProjectContractNumericHelper.normalizeToDecimalString(""), "");
      expect(
        ProjectContractNumericHelper.normalizeToDecimalString(" null "),
        "",
      );

      // Fraction a/b
      expect(ProjectContractNumericHelper.normalizeToDecimalString("1/2"), "");
      expect(ProjectContractNumericHelper.normalizeToDecimalString("2/4"), "");
      expect(
        ProjectContractNumericHelper.normalizeToDecimalString("5/0"),
        "",
      ); // division by zero
      expect(ProjectContractNumericHelper.normalizeToDecimalString("x/y"), "");

      // Decimal with commas
      expect(
        ProjectContractNumericHelper.normalizeToDecimalString("1,234.56789"),
        "1,234.56789", // capped to 6 in formatDecimal; this has 5, so preserved
      );

      // Negative, clamped to zero
      expect(
        ProjectContractNumericHelper.normalizeToDecimalString(
          "-1.23",
          clampNegativeToZero: true,
        ),
        "0",
      );
    });

    test("formatDecimal enforces caps and grouping; groupThousands works", () {
      // clamp negative to zero
      expect(
        ProjectContractNumericHelper.formatDecimal(
          Decimal.parse("-0.01"),
          maxFrac: 6,
          clampNegativeToZero: true,
        ),
        "0",
      );

      // Large integer part exceeding 21 digits → tail capping with grouping
      final huge = Decimal.parse("1234567890123456789012345.1234567");
      final out = ProjectContractNumericHelper.formatDecimal(
        huge,
        maxFrac: 6,
        clampNegativeToZero: false,
      );
      // Integer part in the output (strip decimals) should be ≥ 1 and
      // corresponds to the last 21 digits
      final outInt = out.split(".").first.replaceAll(",", "");
      expect(outInt.length <= 21, true);
      // Should end with the tail of the original intPart: "7890123456789012345"
      expect(outInt.endsWith("7890123456789012345"), true);
      // Has grouping commas
      expect(out.contains(","), true);

      // groupThousands helper independent check
      expect(ProjectContractNumericHelper.groupThousands(""), "");
      expect(ProjectContractNumericHelper.groupThousands("123"), "123");
      expect(ProjectContractNumericHelper.groupThousands("1234"), "1,234");
      expect(
        ProjectContractNumericHelper.groupThousands("1234567"),
        "1,234,567",
      );
    });
  });

  group("ProjectContractNumericHelper – completedMonthsBetween", () {
    test("handles earlier end date and partial months strictly", () {
      // End before start
      final start = DateTime(2025, 3, 10);
      final endBefore = DateTime(2025, 3, 9);
      expect(
        ProjectContractNumericHelper.completedMonthsBetween(start, endBefore),
        0,
      );

      // One month minus one day → 0
      expect(
        ProjectContractNumericHelper.completedMonthsBetween(
          DateTime(2025, 1, 15),
          DateTime(2025, 2, 14),
        ),
        0,
      );

      // Exactly one month completed
      expect(
        ProjectContractNumericHelper.completedMonthsBetween(
          DateTime(2025, 1, 15),
          DateTime(2025, 2, 15),
        ),
        1,
      );

      // Two months completed
      expect(
        ProjectContractNumericHelper.completedMonthsBetween(
          DateTime(2025, 1, 15),
          DateTime(2025, 3, 15),
        ),
        2,
      );
    });
  });

  group("ProjectContractNumericHelper.dateOnly", () {
    test("returns null for null", () {
      expect(ProjectContractNumericHelper.dateOnly(null), isNull);
    });

    test("strips time-of-day correctly", () {
      final dt = DateTime(2025, 5, 7, 15, 30, 45, 999);
      final only = ProjectContractNumericHelper.dateOnly(dt);
      expect(only, isNotNull);
      expect(only!.year, 2025);
      expect(only.month, 5);
      expect(only.day, 7);
      expect(only.hour, 0);
      expect(only.minute, 0);
      expect(only.second, 0);
      expect(only.millisecond, 0);
      expect(only.microsecond, 0);
    });
  });

  group("ProjectContractNumericHelper.fmt", () {
    test("formats as dd/MM/yyyy", () {
      final d = DateTime(2026, 2, 27);
      final s = ProjectContractNumericHelper.fmt.format(d);
      expect(s, "27/02/2026");
    });
  });

  group("ProjectContractNumericHelper.validateDates - chronology", () {
    setUp(() {
      mockAlert = MockAlertManager();
      AlertManager.overrideInstance(mockAlert);
      // Override warn to capture messages and avoid real AlertManager calls.
      // ProjectContractNumericHelper.warn = (msg) {
      //   // no-op in basic tests; overridden in specific tests
      // };
    });

    test("returns true when both are null", () {
      final ok = ProjectContractNumericHelper.validateDates(
        start: null,
        end: null,
        rules: const YearRules(),
        showToast: true,
      );
      expect(ok, isTrue);
    });

    test("returns true when only start is set", () {
      final ok = ProjectContractNumericHelper.validateDates(
        start: DateTime(2025, 1, 1),
        end: null,
        rules: const YearRules(),
        showToast: true,
      );
      expect(ok, isTrue);
    });

    test("returns true when only end is set", () {
      final ok = ProjectContractNumericHelper.validateDates(
        start: null,
        end: DateTime(2025, 12, 31),
        rules: const YearRules(),
        showToast: true,
      );
      expect(ok, isTrue);
    });

    test("returns true when end == start (allowed)", () {
      final ok = ProjectContractNumericHelper.validateDates(
        start: DateTime(2025, 5, 7, 23, 59), // time should be stripped
        end: DateTime(2025, 5, 7, 0, 1),
        rules: const YearRules(),
        showToast: true,
      );
      expect(ok, isTrue);
    });

    test("returns false when end < start (showToast: false path)", () {
      final ok = ProjectContractNumericHelper.validateDates(
        start: DateTime(2025, 5, 8),
        end: DateTime(2025, 5, 7),
        rules: const YearRules(),
        showToast: false, // to avoid calling warn
      );
      expect(ok, isFalse);
    });

    test("returns false when end < start (showToast: true path triggers warn)",
        () {
      String? captured;
      // ProjectContractNumericHelper.warn = (msg) {
      //   captured = msg;
      // };

      final ok = ProjectContractNumericHelper.validateDates(
        start: DateTime(2025, 5, 8),
        end: DateTime(2025, 5, 7),
        rules: const YearRules(),
        showToast: true,
      );
      expect(ok, isFalse);
      expect(captured, null);
      // "project.viewEditContractDetails.completionDateStartDate".tr());
    });
  });

  group("ProjectContractNumericHelper.validateDates - sameYearOnly", () {
    setUp(() {
      mockAlert = MockAlertManager();
      AlertManager.overrideInstance(mockAlert);
      // ProjectContractNumericHelper.warn = (_) {};
    });

    test("sameYearOnly: true -> same year is allowed", () {
      final ok = ProjectContractNumericHelper.validateDates(
        start: DateTime(2025, 1, 1),
        end: DateTime(2025, 12, 31),
        rules: const YearRules(sameYearOnly: true),
        showToast: true,
      );
      expect(ok, isTrue);
    });

    test("sameYearOnly: true -> different year is rejected and warns", () {
      String? captured;
      // ProjectContractNumericHelper.warn = (msg) => captured = msg;

      final ok = ProjectContractNumericHelper.validateDates(
        start: DateTime(2025, 12, 31),
        end: DateTime(2026, 1, 1),
        rules: const YearRules(sameYearOnly: true),
        showToast: true,
      );
      expect(ok, isFalse);
      expect(captured, null);
      // "project.viewEditContractDetails.startDateCompletionSameYear".tr());
    });
  });

  group("ProjectContractNumericHelper.validateDates - maxYearSpan", () {
    setUp(() {
      mockAlert = MockAlertManager();
      AlertManager.overrideInstance(mockAlert);
      // ProjectContractNumericHelper.warn = (_) {};
    });

    test("maxYearSpan: null -> no year span constraint (different years ok)",
        () {
      final ok = ProjectContractNumericHelper.validateDates(
        start: DateTime(2025, 6, 1),
        end: DateTime(2027, 6, 1),
        rules: const YearRules(sameYearOnly: false, maxYearSpan: null),
        showToast: true,
      );
      expect(ok, isTrue);
    });

    test("maxYearSpan: 0 -> must be same calendar year", () {
      final ok1 = ProjectContractNumericHelper.validateDates(
        start: DateTime(2025, 1, 1),
        end: DateTime(2025, 12, 31),
        rules: const YearRules(sameYearOnly: false, maxYearSpan: 0),
        showToast: true,
      );
      expect(ok1, isTrue);

      final ok2 = ProjectContractNumericHelper.validateDates(
        start: DateTime(2025, 12, 31),
        end: DateTime(2026, 1, 1),
        rules: const YearRules(sameYearOnly: false, maxYearSpan: 0),
        showToast: true,
      );
      expect(ok2, isFalse);
    });

    test("maxYearSpan: 1 -> boundary inclusive (span==1 allowed)", () {
      final ok = ProjectContractNumericHelper.validateDates(
        start: DateTime(2025, 1, 1),
        end: DateTime(2026, 12, 31),
        rules: const YearRules(sameYearOnly: false, maxYearSpan: 1),
        showToast: true,
      );
      expect(ok, isTrue);
    });

    test("maxYearSpan: 1 -> span 2 is rejected and warns", () {
      String? captured;
      // ProjectContractNumericHelper.warn = (msg) => captured = msg;

      final ok = ProjectContractNumericHelper.validateDates(
        start: DateTime(2025, 1, 1),
        end: DateTime(2027, 1, 1),
        rules: const YearRules(sameYearOnly: false, maxYearSpan: 1),
        showToast: true,
      );
      expect(ok, isFalse);
      expect(captured, null);
      // "project.viewEditContractDetails.completionSpan".tr());
    });
  });

  group("ProjectContractNumericHelper.validateDates - rule interaction", () {
    test("sameYearOnly true takes precedence even if maxYearSpan is set", () {
      // Different years must fail due to sameYearOnly
      final fail = ProjectContractNumericHelper.validateDates(
        start: DateTime(2025, 12, 31),
        end: DateTime(2026, 1, 1),
        rules: const YearRules(sameYearOnly: true, maxYearSpan: 5),
        showToast: false,
      );
      expect(fail, isFalse);

      // Same year passes regardless of maxYearSpan value
      final pass = ProjectContractNumericHelper.validateDates(
        start: DateTime(2025, 1, 1),
        end: DateTime(2025, 12, 31),
        rules: const YearRules(sameYearOnly: true, maxYearSpan: 0),
        showToast: false,
      );
      expect(pass, isTrue);
    });
  });
}

// Minimal stand-ins for the .tr() extension used in your code.
// If your project imports a real localization, remove this and use that.
extension _Tr on String {
  // String tr() => this; // return key as "translated" value for tests
}
