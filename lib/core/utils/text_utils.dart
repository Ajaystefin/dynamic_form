import "package:flutter/services.dart";
import "package:intl/intl.dart";

extension StringExtension on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  String capitalizeFirstLetterFirstSecond() {
    if (isEmpty) return this;
    return split(" ")
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(" ");
  }

  String formatNumber() {
    try {
      final numValue = num.parse(this);
      final format = NumberFormat.decimalPattern("en_IN");
      return format.format(numValue);
    } catch (e) {
      return this; // Return original string if parsing fails
    }
  }
}

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

class ThousandsWithMaxDigitsFormatter extends TextInputFormatter {
  ThousandsWithMaxDigitsFormatter({this.maxDigits = 12});

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
        text: "",
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
      composing: TextRange.empty,
    );
  }
}

class ThousandsSeparatorFormatter extends TextInputFormatter {
  final NumberFormat _fmt = NumberFormat("#,###");

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldV,
    TextEditingValue newV,
  ) {
    final raw = newV.text.replaceAll(",", "");
    if (raw.isEmpty) return const TextEditingValue(text: "");
    // Block non-digits (safety; you already use digitsOnly)
    if (!RegExp(r"^\d+$").hasMatch(raw)) return oldV;

    final formatted = _fmt.format(int.parse(raw));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
