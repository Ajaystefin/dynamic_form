import "package:intl/intl.dart";

class DateTimeUtils {
  /// Returns the current date and time.
  static DateTime getCurrentTime() {
    return DateTime.now();
  }

  /// Formats a [DateTime] object to a readable string.
  static String formatDateTime(
    DateTime dateTime, {
    String format = "yyyy-MM-dd HH:mm:ss",
  }) {
    return DateFormat(format).format(dateTime);
  }

  /// Parses a date string into a [DateTime] object.
  static DateTime? parseDateTime(
    String dateTimeStr, {
    String format = "yyyy-MM-dd HH:mm:ss",
  }) {
    try {
      return DateFormat(format).parse(dateTimeStr);
    } catch (e) {
      return null;
    }
  }

  /// Returns the difference in days between two dates.
  static int getDifferenceInDays(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }

  /// Checks if a given date is today.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Checks if a given date is yesterday.
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Returns a human-readable time difference (e.g., "2 hours ago").
  static String timeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inSeconds < 60) {
      return "${duration.inSeconds} seconds ago";
    } else if (duration.inMinutes < 60) {
      return "${duration.inMinutes} minutes ago";
    } else if (duration.inHours < 24) {
      return "${duration.inHours} hours ago";
    } else if (duration.inDays < 7) {
      return "${duration.inDays} days ago";
    } else {
      return DateFormat("yyyy-MM-dd").format(dateTime);
    }
  }

  //

  static DateTime? intToDateTime(dynamic createdDate) {
    // Null/empty/zero guard
    if (createdDate == null ||
        createdDate == 0 ||
        (createdDate is String && createdDate.trim().isEmpty)) {
      return null;
    }

    // Pass-through
    if (createdDate is DateTime) {
      return createdDate;
    }

    // String handling
    if (createdDate is String) {
      final s = createdDate.trim();

      // 1) Try milliseconds timestamp (as string)
      final ts = int.tryParse(s);
      if (ts != null) {
        // NOTE: Assumes milliseconds since epoch. If you're storing seconds,
        // convert: ts * 1000
        return DateTime.fromMillisecondsSinceEpoch(ts);
      }

      // 2) Support "dd/MM/yyyy" strictly (e.g., "24/12/2025")
      final ddMMyyyy =
          RegExp(r"^(0[1-9]|[12]\d|3[01])\/(0[1-9]|1[0-2])\/\d{4}$");
      if (ddMMyyyy.hasMatch(s)) {
        final parts = s.split("/");
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        // Construct local DateTime
        return DateTime(year, month, day);
      }

      // 3) Support "MM/yyyy" strictly (e.g., "12/2025" -> first day of month)
      final mmYYYY = RegExp(r"^(0[1-9]|1[0-2])\/\d{4}$");
      if (mmYYYY.hasMatch(s)) {
        final parts = s.split("/");
        final month = int.parse(parts[0]);
        final year = int.parse(parts[1]);
        return DateTime(year, month, 1);
      }

      // 4) Fallback: ISO-8601 (e.g., "2025-12-24T05:28:37.349Z")
      try {
        return DateTime.parse(s);
      } catch (_) {
        return null;
      }
    }

    // Numeric handling (milliseconds since epoch)
    try {
      if (createdDate is int) {
        return DateTime.fromMillisecondsSinceEpoch(createdDate);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static int datetimeToInt(DateTime? date) {
    if (date == null) {
      final DateTime now = DateTime.now();
      return now.millisecondsSinceEpoch;
    }
    return date.millisecondsSinceEpoch;
  }

  static dynamic datetimeToDynamic(DateTime? date) {
    if (date == null) {
      final DateTime now = DateTime.now();
      return now.millisecondsSinceEpoch;
    }
    return date.millisecondsSinceEpoch;
  }

  static String getTimeAsString(int? timestamp) {
    if (timestamp == null) return "";
    final DateTime dateTimeUtc =
        DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);

    // Format using intl
    final formattedDate = DateFormat("dd/MM/yyyy").format(dateTimeUtc);
    return formattedDate;
  }

  //For Customer info purpose
  static String getDateAsString(
    String? isoDateString, [
    String format = "dd/MM/yyyy",
  ]) {
    try {
      if (isoDateString == null || isoDateString.trim().isEmpty) return "";

      // First try ISO parsing
      DateTime? date = DateTime.tryParse(isoDateString);

      // If that fails, try parsing with the expected format
      if (date == null) {
        try {
          date = DateFormat(format).parse(isoDateString);
        } catch (_) {
          return ""; // Invalid format
        }
      }

      return DateFormat(format).format(date);
    } catch (e) {
      return "";
    }
  }

  //For Customer info purpose
  static String convertUIDateToISO(String? uiDateString) {
    try {
      if (uiDateString == null) return "";
      final parsed = DateFormat("dd/MM/yyyy").parse(uiDateString);
      return DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(parsed);
    } catch (e) {
      return "";
    }
  }

  //For Customer info purpose
  static String? formatDateForSubmission(DateTime? date) {
    if (date == null) return null;
    return DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(date);
  }

  //For Customer info purpose
  static String getTimeAsInt(String? dateString) {
    try {
      if (dateString == null) return "";
      final DateTime dateTime = DateTime.parse(dateString);
      final int timestamp = dateTime.toUtc().millisecondsSinceEpoch;
      return getTimeAsString(timestamp);
    } catch (e) {
      // print("Error formatting date: $e");
      return "";
    }
  }

  static DateTime parseDateFile(dynamic date) {
    if (date is DateTime) return date;
    if (date is String) {
      try {
        return DateFormat("dd-MM-yyyy").parse(date);
      } catch (_) {
        return DateTime(1900); // fallback
      }
    }
    return DateTime(1900);
  }

  static String toApiDate(dynamic input) {
    DateTime date;

    if (input is String) {
      // Parse dd/MM/yyyy
      date = DateFormat("dd/MM/yyyy").parse(input);
      // Set time to midnight
      date = DateTime(date.year, date.month, date.day, 0, 0, 0, 0);
    } else if (input is DateTime) {
      date = input;
    } else {
      throw ArgumentError("Unsupported type: ${input.runtimeType}");
    }

    return DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(date);
  }

  // Utility function
  static DateTime convertToDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is DateTime) return date.toLocal();
    if (date is String) {
      // Try parsing ISO string, fallback    // Try parsing ISO string, fallback to now
      return DateTime.tryParse(date)?.toLocal() ?? DateTime.now();
    }
    return DateTime.now();
  }

  static String formatMonthYear(DateTime? date) {
    //  final formatter = DateFormat('MM/yyyy');
    if (date == null) return "";
    final month = date.month.toString().padLeft(2, "0");
    final year = date.year.toString();
    return "$month/$year";
  }

//For CCSYS
  static DateTime toDateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  /// Tolerant parser:
  /// - Accepts DateTime
  /// - Accepts 'dd/MM/yyyy' (strict)
  /// - Accepts ISO-like strings (e.g., '2233-01-01', '2233-01-01
  /// 00:00:00.000Z', '2233-01-01T00:00:00Z')
  static DateTime? parseToDateOnly(dynamic input) {
    if (input == null) return null;

    // Already a DateTime
    if (input is DateTime) return toDateOnly(input);

    // String cases
    if (input is String) {
      final s = input.trim();
      if (s.isEmpty) return null;

      // If it looks ISO-ish (yyyy-mm-dd...), try ISO first to avoid throwing
      // inside intl
      final looksIso = RegExp(r"^\d{4}-\d{2}-\d{2}").hasMatch(s);
      if (looksIso) {
        final iso = DateTime.tryParse(s);
        if (iso != null) return toDateOnly(iso);
        // If ISO try fails (rare), fall back to dd/MM
      }

      // Try strict dd/MM/yyyy
      try {
        final dmy = DateFormat("dd/MM/yyyy").parseStrict(s);
        return toDateOnly(dmy);
      } catch (_) {
        // If not dd/MM, one last ISO fallback for odd strings
        final iso = DateTime.tryParse(s);
        if (iso != null) return toDateOnly(iso);
      }
    }

    return null;
  }
}
