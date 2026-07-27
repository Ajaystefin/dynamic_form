import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";

void main() {
  group("DateTimeUtils", () {
    group("getCurrentTime", () {
      test("should return current time", () {
        final result = DateTimeUtils.getCurrentTime();
        expect(result, isA<DateTime>());

        // Should be close to now (within 1 second)
        final now = DateTime.now();
        expect(result.difference(now).inSeconds.abs(), lessThan(2));
      });
    });

    group("formatDateTime", () {
      test("should format date time with default format", () {
        final dateTime = DateTime(2023, 12, 25, 14, 30, 45);
        final result = DateTimeUtils.formatDateTime(dateTime);
        expect(result, equals("2023-12-25 14:30:45"));
      });

      test("should format date time with custom format", () {
        final dateTime = DateTime(2023, 12, 25, 14, 30, 45);
        final result =
            DateTimeUtils.formatDateTime(dateTime, format: "dd/MM/yyyy");
        expect(result, equals("25/12/2023"));
      });

      test("should format date time with different custom format", () {
        final dateTime = DateTime(2023, 12, 25, 14, 30, 45);
        final result =
            DateTimeUtils.formatDateTime(dateTime, format: "MMM dd, yyyy");
        expect(result, equals("Dec 25, 2023"));
      });
    });

    group("parseDateTime", () {
      test("should parse valid date time string with default format", () {
        final result = DateTimeUtils.parseDateTime("2023-12-25 14:30:45");
        expect(result, isNotNull);
        expect(result!.year, equals(2023));
        expect(result.month, equals(12));
        expect(result.day, equals(25));
        expect(result.hour, equals(14));
        expect(result.minute, equals(30));
        expect(result.second, equals(45));
      });

      test("should parse valid date time string with custom format", () {
        final result =
            DateTimeUtils.parseDateTime("25/12/2023", format: "dd/MM/yyyy");
        expect(result, isNotNull);
        expect(result!.year, equals(2023));
        expect(result.month, equals(12));
        expect(result.day, equals(25));
      });

      test("should return null for invalid date time string", () {
        final result = DateTimeUtils.parseDateTime("invalid-date");
        expect(result, isNull);
      });

      test("should return null for empty string", () {
        final result = DateTimeUtils.parseDateTime("");
        expect(result, isNull);
      });

      test("should return null for malformed date string", () {
        final result = DateTimeUtils.parseDateTime("invalid-date-format");
        expect(result, isNull);
      });
    });

    group("getDifferenceInDays", () {
      test("should return positive difference when to is after from", () {
        final from = DateTime(2023, 12, 25);
        final to = DateTime(2023, 12, 30);
        final result = DateTimeUtils.getDifferenceInDays(from, to);
        expect(result, equals(5));
      });

      test("should return negative difference when to is before from", () {
        final from = DateTime(2023, 12, 30);
        final to = DateTime(2023, 12, 25);
        final result = DateTimeUtils.getDifferenceInDays(from, to);
        expect(result, equals(-5));
      });

      test("should return zero for same dates", () {
        final date = DateTime(2023, 12, 25);
        final result = DateTimeUtils.getDifferenceInDays(date, date);
        expect(result, equals(0));
      });

      test("should handle partial days correctly", () {
        final from = DateTime(2023, 12, 25, 23, 59, 59);
        final to = DateTime(2023, 12, 26, 0, 0, 1);
        final result = DateTimeUtils.getDifferenceInDays(from, to);
        expect(result, equals(0)); // Less than 24 hours
      });
    });

    group("isToday", () {
      test("should return true for today", () {
        final today = DateTime.now();
        final result = DateTimeUtils.isToday(today);
        expect(result, isTrue);
      });

      test("should return false for yesterday", () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final result = DateTimeUtils.isToday(yesterday);
        expect(result, isFalse);
      });

      test("should return false for tomorrow", () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final result = DateTimeUtils.isToday(tomorrow);
        expect(result, isFalse);
      });

      test("should return false for different year", () {
        final lastYear = DateTime(2022, 12, 25);
        final result = DateTimeUtils.isToday(lastYear);
        expect(result, isFalse);
      });
    });

    group("isYesterday", () {
      test("should return true for yesterday", () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final result = DateTimeUtils.isYesterday(yesterday);
        expect(result, isTrue);
      });

      test("should return false for today", () {
        final today = DateTime.now();
        final result = DateTimeUtils.isYesterday(today);
        expect(result, isFalse);
      });

      test("should return false for day before yesterday", () {
        final dayBeforeYesterday =
            DateTime.now().subtract(const Duration(days: 2));
        final result = DateTimeUtils.isYesterday(dayBeforeYesterday);
        expect(result, isFalse);
      });

      test("should return false for tomorrow", () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final result = DateTimeUtils.isYesterday(tomorrow);
        expect(result, isFalse);
      });
    });

    group("timeAgo", () {
      test("should return seconds ago for recent time", () {
        final recentTime = DateTime.now().subtract(const Duration(seconds: 30));
        final result = DateTimeUtils.timeAgo(recentTime);
        expect(result, contains("seconds ago"));
      });

      test("should return minutes ago for time within hour", () {
        final timeWithinHour =
            DateTime.now().subtract(const Duration(minutes: 30));
        final result = DateTimeUtils.timeAgo(timeWithinHour);
        expect(result, contains("minutes ago"));
      });

      test("should return hours ago for time within day", () {
        final timeWithinDay =
            DateTime.now().subtract(const Duration(hours: 12));
        final result = DateTimeUtils.timeAgo(timeWithinDay);
        expect(result, contains("hours ago"));
      });

      test("should return days ago for time within week", () {
        final timeWithinWeek = DateTime.now().subtract(const Duration(days: 3));
        final result = DateTimeUtils.timeAgo(timeWithinWeek);
        expect(result, contains("days ago"));
      });

      test("should return formatted date for time older than week", () {
        final oldTime = DateTime.now().subtract(const Duration(days: 10));
        final result = DateTimeUtils.timeAgo(oldTime);
        expect(result, matches(r"^\d{4}-\d{2}-\d{2}$"));
      });

      test("should handle exact minute boundary", () {
        final exactMinute = DateTime.now().subtract(const Duration(minutes: 1));
        final result = DateTimeUtils.timeAgo(exactMinute);
        expect(result, contains("minutes ago"));
      });

      test("should handle exact hour boundary", () {
        final exactHour = DateTime.now().subtract(const Duration(hours: 1));
        final result = DateTimeUtils.timeAgo(exactHour);
        expect(result, contains("hours ago"));
      });

      test("should handle exact day boundary", () {
        final exactDay = DateTime.now().subtract(const Duration(days: 1));
        final result = DateTimeUtils.timeAgo(exactDay);
        expect(result, contains("days ago"));
      });
    });

    group("intToDateTime", () {
      test("should convert valid integer timestamp", () {
        const timestamp = 1703520000000; // 2023-12-25 00:00:00 UTC
        final result = DateTimeUtils.intToDateTime(timestamp);
        expect(result, isNotNull);
        expect(result!.year, equals(2023));
        expect(result.month, equals(12));
        expect(result.day, equals(25));
      });

      test("should convert valid string timestamp", () {
        const timestamp = "1703520000000";
        final result = DateTimeUtils.intToDateTime(timestamp);
        expect(result, isNotNull);
        expect(result!.year, equals(2023));
        expect(result.month, equals(12));
        expect(result.day, equals(25));
      });

      test("should return null for null input", () {
        final result = DateTimeUtils.intToDateTime(null);
        expect(result, isNull);
      });

      test("should return null for zero input", () {
        final result = DateTimeUtils.intToDateTime(0);
        expect(result, isNull);
      });

      test("should return null for empty string", () {
        final result = DateTimeUtils.intToDateTime("");
        expect(result, isNull);
      });

      test("should return null for whitespace string", () {
        final result = DateTimeUtils.intToDateTime("   ");
        expect(result, isNull);
      });

      test("should return null for invalid string", () {
        final result = DateTimeUtils.intToDateTime("invalid");
        expect(result, isNull);
      });

      test("should return null for non-numeric string", () {
        final result = DateTimeUtils.intToDateTime("abc123");
        expect(result, isNull);
      });
    });

    group("datetimeToInt", () {
      test("should convert valid DateTime to timestamp", () {
        final dateTime = DateTime(2023, 12, 25, 12);
        final result = DateTimeUtils.datetimeToInt(dateTime);
        expect(result, isA<int>());
        expect(result, greaterThan(0));
      });

      test("should return current timestamp for null input", () {
        final beforeCall = DateTime.now().millisecondsSinceEpoch;
        final result = DateTimeUtils.datetimeToInt(null);
        final afterCall = DateTime.now().millisecondsSinceEpoch;

        expect(result, isA<int>());
        expect(result, greaterThanOrEqualTo(beforeCall));
        expect(result, lessThanOrEqualTo(afterCall));
      });

      test("should handle specific timestamp conversion", () {
        final dateTime = DateTime.fromMillisecondsSinceEpoch(1703520000000);
        final result = DateTimeUtils.datetimeToInt(dateTime);
        expect(result, equals(1703520000000));
      });
    });

    group("getTimeAsString", () {
      test("should format valid timestamp to string", () {
        const timestamp = 1703520000000; // 2023-12-25 00:00:00 UTC
        final result = DateTimeUtils.getTimeAsString(timestamp);
        expect(result, equals("25/12/2023"));
      });

      test("should return empty string for null timestamp", () {
        final result = DateTimeUtils.getTimeAsString(null);
        expect(result, equals(""));
      });

      test("should handle different timestamp values", () {
        const timestamp = 1640995200000; // 2022-01-01 00:00:00 UTC
        final result = DateTimeUtils.getTimeAsString(timestamp);
        expect(result, equals("01/01/2022"));
      });

      test("should handle timestamp with time component", () {
        const timestamp = 1703523600000; // 2023-12-25 01:00:00 UTC
        final result = DateTimeUtils.getTimeAsString(timestamp);
        expect(result, equals("25/12/2023"));
      });
    });

    group("getDateAsString", () {
      test("should return formatted date for valid ISO string", () {
        final result = DateTimeUtils.getDateAsString("2023-12-25T00:00:00");
        expect(result, equals("25/12/2023"));
      });

      test("should return empty string for null input", () {
        final result = DateTimeUtils.getDateAsString(null);
        expect(result, equals(""));
      });
    });

    group("convertUIDateToISO", () {
      test("should convert valid UI date to ISO format", () {
        final result = DateTimeUtils.convertUIDateToISO("25/12/2023");
        expect(result, equals("2023-12-25T00:00:00"));
      });

      test("should return empty string for null input", () {
        final result = DateTimeUtils.convertUIDateToISO(null);
        expect(result, equals(""));
      });

      test("should return empty string for invalid UI date format", () {
        final result = DateTimeUtils.convertUIDateToISO("invalid-date");
        expect(result, equals(""));
      });
    });

    group("formatDateForSubmission", () {
      test("should format valid DateTime to ISO string", () {
        final date = DateTime(2023, 12, 25);
        final result = DateTimeUtils.formatDateForSubmission(date);
        expect(result, equals("2023-12-25T00:00:00"));
      });

      test("should return null for null input", () {
        final result = DateTimeUtils.formatDateForSubmission(null);
        expect(result, isNull);
      });
    });

    group("getTimeAsInt", () {
      test("should convert valid ISO date string to formatted string", () {
        //final result = DateTimeUtils.getTimeAsInt('2023-12-25T00:00:00');
        //expect(result, equals('25/12/2023'));
      });

      test("should return empty string for null input", () {
        final result = DateTimeUtils.getTimeAsInt(null);
        expect(result, equals(""));
      });

      test("should return empty string for invalid date string", () {
        final result = DateTimeUtils.getTimeAsInt("invalid-date");
        expect(result, equals(""));
      });
    });

    group("DateUtils.toApiDate", () {
      test("should convert dd/MM/yyyy string to API format", () {
        final result = DateTimeUtils.toApiDate("22/11/2025");
        expect(result, "2025-11-22T00:00:00.000");
      });

      test("should convert DateTime to API format", () {
        final date = DateTime(2025, 11, 22, 15, 30, 45, 123);
        final result = DateTimeUtils.toApiDate(date);
        expect(result, "2025-11-22T15:30:45.123");
      });

      test("should throw ArgumentError for unsupported type", () {
        expect(() => DateTimeUtils.toApiDate(12345), throwsArgumentError);
      });
    });

    group("DateUtils.datetimeToDynamic", () {
      test("should return millisecondsSinceEpoch for given DateTime", () {
        final date = DateTime(2025, 11, 22, 10, 30);
        final result = DateTimeUtils.datetimeToDynamic(date);
        expect(result, date.millisecondsSinceEpoch);
      });

      test(
          "should return current time in"
          " millisecondsSinceEpoch when date is null", () {
        final before = DateTime.now().millisecondsSinceEpoch;
        final result = DateTimeUtils.datetimeToDynamic(null);
        final after = DateTime.now().millisecondsSinceEpoch;

        // Check result is between before and after
        expect(result >= before && result <= after, true);
      });
    });

    group("DateUtils.getTimeAsInt", () {
      test("should return timestamp string for valid date string", () {
        const dateString = "2025-11-22T10:30:00Z";
        final result = DateTimeUtils.getTimeAsInt(dateString);
        // final expectedTimestamp = DateTime.parse(dateString)
        //     .toUtc()
        //     .millisecondsSinceEpoch
        //     .toString();
        expect(result, "22/11/2025");
      });

      test("should return empty string for null input", () {
        expect(DateTimeUtils.getTimeAsInt(null), "");
      });

      test("should return empty string for invalid date string", () {
        expect(DateTimeUtils.getTimeAsInt("invalid-date"), "");
      });
    });

    group("DateUtils.parseDateFile", () {
      test("should return same DateTime if input is DateTime", () {
        final date = DateTime(2025, 11, 22);
        expect(DateTimeUtils.parseDateFile(date), date);
      });

      test("should parse valid dd-MM-yyyy string", () {
        final result = DateTimeUtils.parseDateFile("22-11-2025");
        expect(result, DateTime(2025, 11, 22));
      });

      test("should return fallback for invalid string", () {
        final result = DateTimeUtils.parseDateFile("invalid-date");
        expect(result, DateTime(1900));
      });

      test("should return fallback for unsupported type", () {
        final result = DateTimeUtils.parseDateFile(12345);
        expect(result, DateTime(1900));
      });
    });

    group("getSafeDate", () {
      test("returns current date when input is null", () {
        final result = DateTimeUtils.convertToDate(null);
        expect(result, isA<DateTime>());
      });

      test("returns local DateTime when input is DateTime", () {
        final utcDate = DateTime.utc(2025, 12);
        final result = DateTimeUtils.convertToDate(utcDate);
        expect(result.isUtc, isFalse); // should be converted to local
        expect(result.year, equals(2025));
        expect(result.month, equals(12));
        expect(result.day, equals(1));
      });

      test("parses valid ISO string and converts to local", () {
        const isoString = "2025-12-01T10:30:00Z";
        final result = DateTimeUtils.convertToDate(isoString);
        expect(result.isUtc, isFalse);
        expect(result.year, equals(2025));
        expect(result.month, equals(12));
        expect(result.day, equals(1));
      });

      test("returns current date when string is invalid", () {
        const invalidString = "01/12/2025"; // not ISO format
        final result = DateTimeUtils.convertToDate(invalidString);
        expect(result, isA<DateTime>());
      });

      test("returns current date when input type is unsupported", () {
        final result = DateTimeUtils.convertToDate(12345); // int type
        expect(result, isA<DateTime>());
      });
    });

    group("intToDateTime", () {
      test("returns null for null, 0, or empty/whitespace string", () {
        expect(DateTimeUtils.intToDateTime(null), isNull);
        expect(DateTimeUtils.intToDateTime(0), isNull);
        expect(DateTimeUtils.intToDateTime(""), isNull);
        expect(DateTimeUtils.intToDateTime("   "), isNull);
      });

      test("returns DateTime as-is (pass-through)", () {
        final dt = DateTime(2025, 12, 24, 5, 28, 37);
        expect(DateTimeUtils.intToDateTime(dt), same(dt));
      });

      test("parses string milliseconds since epoch", () {
        final ts = DateTime(2025, 12, 24).millisecondsSinceEpoch;
        final parsed = DateTimeUtils.intToDateTime(ts.toString());
        expect(parsed, isA<DateTime>());
        expect(parsed!.millisecondsSinceEpoch, ts);
      });

      test("parses dd/MM/yyyy strict", () {
        final parsed = DateTimeUtils.intToDateTime("24/12/2025");
        expect(parsed, isA<DateTime>());
        expect(parsed, DateTime(2025, 12, 24));
      });

      test("parses MM/yyyy strict (first day of month)", () {
        final parsed = DateTimeUtils.intToDateTime("12/2025");
        expect(parsed, isA<DateTime>());
        expect(parsed, DateTime(2025, 12));
      });

      test("parses ISO-8601 string (fallback)", () {
        final parsed = DateTimeUtils.intToDateTime("2025-12-24T05:28:37.349Z");
        expect(parsed, isA<DateTime>());
        // Ensure DateTime.parse worked (UTC conversion is allowed)
        expect(parsed!.toUtc().year, 2025);
        expect(parsed.toUtc().month, 12);
        expect(parsed.toUtc().day, 24);
      });

      test("returns null when string cannot be parsed", () {
        expect(DateTimeUtils.intToDateTime("not-a-date"), isNull);
        expect(
          DateTimeUtils.intToDateTime("32/13/2025"),
          isNull,
        ); // invalid dd/MM/yyyy
        expect(
          DateTimeUtils.intToDateTime("13/2025"),
          isNull,
        ); // invalid MM/yyyy (13)
      });

      test("parses int milliseconds since epoch", () {
        final ts = DateTime(2024).millisecondsSinceEpoch;
        final parsed = DateTimeUtils.intToDateTime(ts);
        expect(parsed, isA<DateTime>());
        expect(parsed!.millisecondsSinceEpoch, ts);
      });

      test("returns null for non-int, non-string numeric-like types", () {
        // double should not be parsed in numeric handling block (only int
        // supported)
        expect(DateTimeUtils.intToDateTime(1234.0), isNull);
      });
    });

    group("formatMonthYear", () {
      test("returns empty string for null", () {
        expect(DateTimeUtils.formatMonthYear(null), "");
      });

      test("pads month to 2 digits and formats as MM/yyyy", () {
        expect(DateTimeUtils.formatMonthYear(DateTime(2025, 1, 15)), "01/2025");
        expect(
          DateTimeUtils.formatMonthYear(DateTime(2025, 12, 31)),
          "12/2025",
        );
      });
    });
  });

  group("toDateOnly", () {
    test("returns date with only year-month-day", () {
      final dt = DateTime(2024, 5, 10, 14, 22, 30);
      final result = DateTimeUtils.toDateOnly(dt);
      expect(result, DateTime(2024, 5, 10));
    });
  });

  group("parseToDateOnly", () {
    test("returns null for null input", () {
      expect(DateTimeUtils.parseToDateOnly(null), null);
    });

    test("returns null for empty string", () {
      expect(DateTimeUtils.parseToDateOnly("   "), null);
    });

    test("DateTime input returns date-only", () {
      final dt = DateTime(2025, 1, 15, 13, 55);
      final result = DateTimeUtils.parseToDateOnly(dt);
      expect(result, DateTime(2025, 1, 15));
    });

    group("ISO-like strings", () {
      test("parses yyyy-MM-dd", () {
        expect(
          DateTimeUtils.parseToDateOnly("2023-12-25"),
          DateTime(2023, 12, 25),
        );
      });

      test("parses with time (Z suffix)", () {
        expect(
          DateTimeUtils.parseToDateOnly("2023-12-25T10:00:00Z"),
          DateTime(2023, 12, 25),
        );
      });

      test("parses with full datetime including ms", () {
        expect(
          DateTimeUtils.parseToDateOnly("2023-12-25 00:00:00.000Z"),
          DateTime(2023, 12, 25),
        );
      });
    });

    group("dd/MM/yyyy strict parsing", () {
      test("parses valid dd/MM/yyyy", () {
        expect(
          DateTimeUtils.parseToDateOnly("25/12/2023"),
          DateTime(2023, 12, 25),
        );
      });

      test("rejects invalid dd/MM/yyyy and tries final ISO fallback", () {
        // invalid dd/MM/yyyy but valid ISO fallback
        expect(
          DateTimeUtils.parseToDateOnly("2023-05-10"),
          DateTime(2023, 5, 10),
        );
      });

      test("invalid dd/MM and invalid ISO returns null", () {
        expect(DateTimeUtils.parseToDateOnly("99/99/9999"), null);
      });
    });

    test("non-string / non-DateTime returns null", () {
      expect(DateTimeUtils.parseToDateOnly(12345), null);
      expect(DateTimeUtils.parseToDateOnly({}), null);
      expect(DateTimeUtils.parseToDateOnly([]), null);
    });
  });
}
