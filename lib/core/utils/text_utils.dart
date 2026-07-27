import "package:flutter/services.dart";
import "package:intl/intl.dart";

/// String Extension
///
/// Provides utility methods for string formatting and transformation.
extension StringExtension on String {
  /// Returns the string with the first letter capitalized.
  String capitalizeFirstLetter() {
    if (isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  /// Capitalizes the first letter of each word in the string.
  String capitalizeFirstLetterFirstSecond() {
    if (isEmpty) {
      return this;
    }
    return split(" ")
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(" ");
  }

  /// Formats a numeric string using thousands separators.
  String formatNumber() {
    try {
      final numValue = num.parse(this);
      final format = NumberFormat.decimalPattern("en_IN");
      return format.format(numValue);
    } on Object {
      return this; // Return original string if parsing fails
    }
  }
}

/// Decimal Input Formatter (21.6)
///
/// Restricts input to a maximum of 27 digits and 6 decimal places.
class DecimalInputFormatter216 extends TextInputFormatter {
  final _regex = RegExp(r"^[0-9,]{0,27}(\.\d{0,6})?$");

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_regex.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}

/// Thousands With Max Digits Formatter
///
/// Formats numeric input using thousands separators and
/// enforces a maximum number of digits.
class ThousandsWithMaxDigitsFormatter extends TextInputFormatter {
  /// Creates a formatter with the specified maximum digit count.
  ThousandsWithMaxDigitsFormatter({this.maxDigits = 12});

  /// Maximum number of digits allowed.
  final int maxDigits;
  final NumberFormat _formatter = NumberFormat("#,###");

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Extract only digits
    final raw = newValue.text.replaceAll(RegExp("[^0-9]"), "");

    // Enforce max raw digits
    final clamped = raw.length > maxDigits ? raw.substring(0, maxDigits) : raw;

    if (clamped.isEmpty) {
      return const TextEditingValue(
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Format with commas (thousands separators)
    final numValue = int.parse(clamped);
    final formatted = _formatter.format(numValue);

    // Place cursor at the end (simple and stable)
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Thousands Separator Formatter
///
/// Formats numeric input using thousands separators.
class ThousandsSeparatorFormatter extends TextInputFormatter {
  final NumberFormat _fmt = NumberFormat("#,###");

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldV,
    TextEditingValue newV,
  ) {
    final raw = newV.text.replaceAll(",", "");
    if (raw.isEmpty) {
      return TextEditingValue.empty;
    }
    // Block non-digits (safety; you already use digitsOnly)
    if (!RegExp(r"^\d+$").hasMatch(raw)) {
      return oldV;
    }

    final formatted = _fmt.format(int.parse(raw));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
