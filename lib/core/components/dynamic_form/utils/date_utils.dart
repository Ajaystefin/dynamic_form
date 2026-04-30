/// Utility functions for date conversion in dynamic forms
///
/// This file provides common date conversion functions used across the dynamic
/// form
/// component to maintain consistency and reduce code duplication.
library;

/// Converts a DateTime object to the dynamic form's date value format
///
/// The returned format matches the API's expected date structure:
/// ```dart
/// {
///   'date': {'year': 2025, 'month': 12, 'day': 24},
///   'jsdate': '2025-12-24T00:00:00.000Z',
///   'formatted': '24/12/2025',
///   'epoc': 1735084800
/// }
/// ```
///
/// Returns null if the input DateTime is null.
///
/// Example:
/// ```dart
/// final dateValue = convertDateTimeToFormValue(DateTime(2025, 12, 24));
/// // Use in document map
/// document['expiryDate'] = dateValue;
/// ```
Map<String, dynamic>? convertDateTimeToFormValue(DateTime? selectedDate) {
  if (selectedDate == null) return null;

  return {
    "date": {
      "year": selectedDate.year,
      "month": selectedDate.month,
      "day": selectedDate.day,
    },
    "jsdate": selectedDate.toIso8601String(),
    "formatted":
        '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
    "epoc": selectedDate.millisecondsSinceEpoch ~/ 1000,
  };
}

/// Parses a DateTime from the dynamic form's stored date value
///
/// Supports multiple input formats:
/// - String (ISO8601 format)
/// - DateTime object
/// - Map with 'jsdate' key (dynamic form format)
///
/// Returns null if the value cannot be parsed.
///
/// Example:
/// ```dart
/// final storedValue = document['expiryDate'];
/// final dateTime = parseDateFromFormValue(storedValue);
/// ```
DateTime? parseDateFromFormValue(dynamic value) {
  if (value == null) return null;

  if (value is String) {
    return DateTime.tryParse(value);
  } else if (value is DateTime) {
    return value;
  } else if (value is Map) {
    // Handle custom date format like {"date": {...}, "jsdate": "...", "epoc":
    // ...}
    final jsdate = value["jsdate"];
    if (jsdate is String) {
      return DateTime.tryParse(jsdate);
    }
  }

  return null;
}
