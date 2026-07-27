import "package:flutter/services.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";

/// Percentage input formatter.
class PercentageInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Allow empty while deleting
    if (text.isEmpty) {
      return newValue;
    }

    // Pattern: up to 3 digits + optional decimal with max 2 digits
    final regex = RegExp(r"^\d{0,3}(\.\d{0,4})?$");
    if (!regex.hasMatch(text)) {
      return oldValue;
    }

    // Block "100." or "100.x"
    if (text.startsWith(ServerConstants.dot_100)) {
      return oldValue;
    }

    // If exactly "100" allow
    if (text == ServerConstants.max_100) {
      return newValue;
    }

    // Parse number
    final value = double.tryParse(text);
    if (value == null) {
      return oldValue;
    }

    // Reject > 100
    if (value > ServerConstants.int_100) {
      return oldValue;
    }

    return newValue;
  }
}

/// Creates a percentage input formatter with optional decimals.
///
/// - [maxValue]: inclusive max allowed value (default 100).
/// - [allowDecimal]: whether to allow decimal input (default false).
/// - [maxDecimalPlaces]: max digits after decimal when [allowDecimal] is true.
/// - [maxIntegerDigits]: max digits before decimal (default 3, fits 0–999).
TextInputFormatter createPercentageFormatter({
  num maxValue = 100,
  bool allowDecimal = false,
  int maxDecimalPlaces = 2,
  int maxIntegerDigits = 3,
}) {
  assert(
    maxValue >= 0,
    "maxValue must be greater than or equal to 0",
  );
  assert(
    maxDecimalPlaces >= 0,
    "maxDecimalPlaces must be greater than or equal to 0",
  );
  assert(
    maxIntegerDigits > 0,
    "maxIntegerDigits must be greater than 0",
  );

  // Build a regex according to settings.
  // - If decimals disabled: only digits, up to [maxIntegerDigits].
  // - If enabled: digits + optional "." + up to [maxDecimalPlaces].
  final String decimalPart = allowDecimal && maxDecimalPlaces > 0
      ? "(\\.\\d{0,$maxDecimalPlaces})?"
      : "";
  final RegExp pattern = RegExp("^\\d{0,$maxIntegerDigits}$decimalPart\$");

  return TextInputFormatter.withFunction(
    (oldValue, newValue) {
      final text = newValue.text;

      // Allow deletion to empty
      if (text.isEmpty) {
        return newValue;
      }

      // Disallow leading '.' (e.g., ".5") – make user type "0.5"
      if (text.startsWith(".")) {
        return oldValue;
      }

      // If decimals are not allowed, reject any '.' presence
      if (!allowDecimal && text.contains(".")) {
        return oldValue;
      }

      // Quick shape check using regex
      if (!pattern.hasMatch(text)) {
        return oldValue;
      }

      // "100." / "100.x" like cases: block trailing dot or decimals for max value
      // Also block any value starting with the max integer then dot.
      final String maxIntStr = maxValue.toStringAsFixed(0);
      if (text.startsWith("$maxIntStr.") || text == "$maxIntStr.") {
        return oldValue;
      }

      // Parse numeric value
      final num? value = num.tryParse(text);
      if (value == null) {
        return oldValue;
      }

      // Reject values above maxValue (inclusive allowed)
      if (value > maxValue) {
        return oldValue;
      }

      // If decimals disabled, ensure integer (no stray decimal)
      if (!allowDecimal && (value is double && value % 1 != 0)) {
        return oldValue;
      }

      // Optionally, prevent leading zeros like "001" unless the number is
      // exactly "0"
      // Keep if you want strictness, otherwise comment out:
      // if (text.length > 1 && text.startsWith('0') && !text.startsWith('0.'))
      // {
      //   return oldValue;
      // }

      return newValue;
    },
  );
}
