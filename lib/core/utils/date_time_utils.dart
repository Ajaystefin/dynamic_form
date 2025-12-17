import 'package:intl/intl.dart';

class DateTimeUtils {
  /// Returns the current date and time.
  static DateTime getCurrentTime() {
    return DateTime.now();
  }

  /// Formats a [DateTime] object to a readable string.
  static String formatDateTime(DateTime dateTime,
      {String format = 'yyyy-MM-dd HH:mm:ss'}) {
    return DateFormat(format).format(dateTime);
  }

  /// Parses a date string into a [DateTime] object.
  static DateTime? parseDateTime(String dateTimeStr,
      {String format = 'yyyy-MM-dd HH:mm:ss'}) {
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
      return '${duration.inSeconds} seconds ago';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes} minutes ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} hours ago';
    } else if (duration.inDays < 7) {
      return '${duration.inDays} days ago';
    } else {
      return DateFormat('yyyy-MM-dd').format(dateTime);
    }
  }

  //
  static DateTime? intToDateTime(dynamic createdDate) {
    // Check for null, empty string, or zero
    if (createdDate == null ||
        createdDate == 0 ||
        (createdDate is String && createdDate.trim().isEmpty)) {
      return null;
    }

    if (createdDate is DateTime) {
      return createdDate;
    }

    if (createdDate is String) {
      // Try to parse as an integer timestamp first
      int? timestamp = int.tryParse(createdDate);
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }

      // If not an integer, try ISO-8601 parse
      try {
        return DateTime.parse(createdDate);
      } catch (_) {
        return null;
      }
    }

    try {
      // If it's already an int, use it directly
      if (createdDate is int) {
        return DateTime.fromMillisecondsSinceEpoch(createdDate);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static int datetimeToInt(DateTime? date) {
    if (date == null) {
      DateTime now = DateTime.now();
      return now.millisecondsSinceEpoch;
    }
    return date.millisecondsSinceEpoch;
  }

  static dynamic datetimeToDynamic(DateTime? date) {
    if (date == null) {
      DateTime now = DateTime.now();
      return now.millisecondsSinceEpoch;
    }
    return date.millisecondsSinceEpoch;
  }

  static String getTimeAsString(int? timestamp) {
    if (timestamp == null) return '';
    final DateTime dateTimeUtc =
        DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);

    // Format using intl
    final formattedDate = DateFormat('dd/MM/yyyy').format(dateTimeUtc);
    return formattedDate;
  }

  //For Customer info purpose
  static String getDateAsString(String? isoDateString,
      [String format = 'dd/MM/yyyy']) {
    try {
      if (isoDateString == null || isoDateString.trim().isEmpty) return '';

      // First try ISO parsing
      DateTime? date = DateTime.tryParse(isoDateString);

      // If that fails, try parsing with the expected format
      if (date == null) {
        try {
          date = DateFormat(format).parse(isoDateString);
        } catch (_) {
          return ''; // Invalid format
        }
      }

      return DateFormat(format).format(date);
    } catch (e) {
      return '';
    }
  }

  //For Customer info purpose
  static String convertUIDateToISO(String? uiDateString) {
    try {
      if (uiDateString == null) return '';
      final parsed = DateFormat('dd/MM/yyyy').parse(uiDateString);
      return DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(parsed);
    } catch (e) {
      return '';
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
      if (dateString == null) return '';
      DateTime dateTime = DateTime.parse(dateString);
      int timestamp = dateTime.toUtc().millisecondsSinceEpoch;
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
        return DateFormat('dd-MM-yyyy').parse(date);
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
      date = DateFormat('dd/MM/yyyy').parse(input);
      // Set time to midnight
      date = DateTime(date.year, date.month, date.day, 0, 0, 0, 0);
    } else if (input is DateTime) {
      date = input;
    } else {
      throw ArgumentError('Unsupported type: ${input.runtimeType}');
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
}
