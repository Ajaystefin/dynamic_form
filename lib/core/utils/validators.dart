import "package:easy_localization/easy_localization.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";

/// Collection of reusable form validation utilities.
class CustomValidator {
  /// Required field validation with a custom error message.
  static String? requiredFieldCustomMsg(String? value, String? message) {
    if (value == null || value.isEmpty) {
      return message;
    }
    return null;
  }

  /// Required field validation.
  static String? requiredField(String? value) {
    if (value == null || value.isEmpty) {
      return "common.validation.emptyRequiredField".tr();
    }
    return null;
  }

  /// Required field validation for a specific field name.
  static String? requiredCustomField(String? value, String fielName) {
    if (value == null || value.isEmpty) {
      return "common.validation.pleaseEnter".tr() + fielName;
    }
    return null;
  }

  /// Required boolean field validation.
  static String? requiredBoolField({bool? value}) {
    if (value == null || !value) {
      return "common.validation.pleaseEnter".tr();
    }
    return null;
  }

  /// Email address validation.
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return "common.validation.emptyEmail".tr();
    }
    final regex = RegExp(r"\S+@\S+\.\S+");
    if (!regex.hasMatch(value)) {
      return "common.validation.invalidEmail".tr();
    }
    return null;
  }

  /// Password validation.
  ///
  /// Ensures the password:
  /// - Is not empty
  /// - Contains at least 8 characters
  /// - Contains at least one number
  /// - Contains at least one letter
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return "common.validation.emptyPassword".tr();
    }
    if (value.length < 8) {
      return "common.validation.shortPassword".tr();
    }
    if (!RegExp("[0-9]").hasMatch(value)) {
      return "common.validation.noNumberPassword".tr();
    }
    if (!RegExp("[A-Za-z]").hasMatch(value)) {
      return "common.validation.noLetterPassword".tr();
    }
    return null;
  }

  /// Phone number validation.
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return "common.validation.emptyPhoneNumber".tr();
    }
    final regex = RegExp(r"^\+?[1-9]\d{1,14}$");
    if (!regex.hasMatch(value)) {
      return "common.validation.invalidPhoneNumber".tr();
    }
    return null;
  }

  /// Numeric value validation.
  static String? numeric(String? value) {
    if (value == null || value.isEmpty) {
      return "common.validation.emptyField".tr();
    }
    if (double.tryParse(value) == null) {
      return "common.validation.invalidNumber".tr();
    }
    return null;
  }

  /// Range validation.
  ///
  /// Ensures the value is between [min] and [max].
  static String? range(String? value, {int min = 1, int max = 100}) {
    if (value == null || value.isEmpty) {
      return "common.validation.emptyField".tr();
    }
    final number = int.tryParse(value);
    if (number == null) {
      return "common.validation.invalidNumber".tr();
    }
    if (number < min || number > max) {
      return "Number must be between $min and $max";
    }
    return null;
  }

  /// Date validation using the `dd/MM/yyyy` format.
  static String? date(String? value) {
    if (value == null || value.isEmpty) {
      return "common.validation.emptyDate".tr();
    }
    // final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    // if (!regex.hasMatch(value)) {
    //   return 'common.validation.invalidDate'.tr();
    // }

    // try {
    //     DateFormat('dd/MM/yyyy').parseStrict(value);
    //   } on Object catch (_) {
    //     return 'common.validation.invalidDate'.tr();
    //   }

    // Regex for dd/MM/yyyy
    final regex = RegExp(r"^\d{2}/\d{2}/\d{4}$");
    if (!regex.hasMatch(value)) {
      return "common.validation.invalidDate".tr();
    }

    return null;
  }

  /// Accepts 'dd/MM' or 'dd/MM/yyyy'
  static String? financialYearEndValidator(String? value) {
    final v = (value ?? "").trim();

    if (v.isEmpty) {
      return "common.validation.emptyDate".tr();
    }

    // Matches dd/MM or dd/MM/yyyy
    final regex = RegExp(r"^\d{2}/\d{2}(?:/\d{4})?$");
    if (!regex.hasMatch(v)) {
      return "common.validation.invalidDate".tr();
    }

    // If yyyy is provided, parse strictly
    if (v.length == 10) {
      try {
        DateFormat("dd/MM/yyyy").parseStrict(v);
      } on Object catch (_) {
        return "common.validation.invalidDate".tr();
      }
      return null;
    }

    // For dd/MM, just range-check day & month
    final parts = v.split("/");
    final day = int.tryParse(parts[0]) ?? -1;
    final month = int.tryParse(parts[1]) ?? -1;
    if (day < 1 || day > 31 || month < 1 || month > 12) {
      return "common.validation.invalidDate".tr();
    }

    return null;
  }

  /// Optional date validation.
  ///
  /// Returns `null` when the value is empty.
  static String? optionalDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final regex = RegExp(r"^\d{4}-\d{2}-\d{2}$");
    if (!regex.hasMatch(value)) {
      return "common.validation.invalidDate".tr();
    }
    return null;
  }

  /// Confirm password validation.
  ///
  /// Ensures that the entered value matches the provided password.
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return "common.validation.confirmPassword".tr();
    }
    if (value != password) {
      return "common.validation.passwordMismatch".tr();
    }
    return null;
  }

  /// URL validation.
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return "common.validation.emptyUrl".tr();
    }
    final regex = RegExp(r"^(http|https)://\S+\.\S+$");
    if (!regex.hasMatch(value)) {
      return "common.validation.invalidUrl".tr();
    }
    return null;
  }

  /// Limits input to a maximum of 21 digits before the decimal
  /// point and 6 digits after it.
  static String? limitedNumeric(String? value) {
    if (value == null || value.isEmpty) {
      return "common.validation.emptyField".tr();
    }

    final regex = RegExp(r"^\d{1,21}(\.\d{0,6})?$");
    if (!regex.hasMatch(value)) {
      return "common.validation.enterValidNumber".tr();
    }

    return null;
  }

  /// Enforces a maximum character length.
  ///
  /// If [value] is longer than [maxLength], returns either [customMsg]
  /// or a localized default: “Maximum {maxLength} characters allowed.”
  static String? maxLength(
    String? value,
    int maxLength, {
    String? customMsg,
  }) {
    if (value != null && value.length > maxLength) {
      return customMsg ??
          "common.validation.maxLengthExceeded"
              .tr(args: [maxLength.toString()]);
    }
    return null;
  }

  /// Validator that accepts “N/A” or a numeric value ≤100.00
  /// with up to two decimal places.
  static String? naOrNumberUpTo100Validator(String? value) {
    final txt = value?.trim() ?? "";
    if (txt.toUpperCase() == "N/A") {
      return null;
    }
    final parsed = double.tryParse(txt);
    if (parsed == null) {
      return "remarks.feeStructure.plsEnterNumberNa".tr();
    }
    if (parsed > 100) {
      return "remarks.feeStructure.valueCannotExceed100".tr();
    }
    if (txt.contains(".")) {
      final fraction = txt.split(".")[1];
      if (fraction.length > 2) {
        return "common.validation.enterValidNumber".tr();
      }
    }
    return null;
  }

  /// Allows only numbers with up to two decimal places.
  static String? twoDecimalNumeric(String? value) {
    if (value == null || value.isEmpty) {
      return "common.validation.emptyField".tr();
    }

    final regex = RegExp(r"^\d+(\.\d{1,2})?$");
    if (!regex.hasMatch(value)) {
      return "common.validation.enterValidNumber".tr();
    }

    return null;
  }
}

/// Text input formatter that restricts numeric input to a decimal format.
///
/// By default, allows up to 15 digits before the decimal point and
/// 6 digits after the decimal point. A custom validation pattern can be
/// provided using [regEx].
class DecimalInputFormatter extends TextInputFormatter {
  /// Creates a [DecimalInputFormatter].
  DecimalInputFormatter({
    this.regEx,
    this.allowNegativeIntermediate = false,
  });

  /// Regular expression used to validate input.
  ///
  /// If not provided, a default pattern allowing up to 15 integer digits
  /// and 6 decimal digits is used.
  final RegExp? regEx;
  final bool allowNegativeIntermediate;
  // static const _negativeRegexPattern = r"^-?[0-9,]{0,5}(\.\d{0,6})?$";
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (allowNegativeIntermediate &&
        (newValue.text.isEmpty || newValue.text == "-")) {
      return newValue;
    }
    // Allow standalone '-' only for the negative-number regex15
    // if (regEx?.pattern == _negativeRegexPattern &&
    //     (newValue.text.isEmpty || newValue.text == "-")) {
    //   return newValue;
    // }

    if ((regEx ?? RegExp(r"^\d{0,15}(\.\d{0,6})?$")).hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}

/// Text input formatter that allows up to 21 integer digits
/// and 2 decimal places, return empty if text is 'Data Not Available'.
class DecimalInputFormatterTwoDigit extends TextInputFormatter {
  final RegExp _regExp = RegExp(r"^\d{0,21}(\.\d{0,2})?$");

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    if (oldValue.text.toLowerCase() == ServerConstants.dataNotAvailable) {
      return TextEditingValue.empty;
    }
    return oldValue;
  }
}

/// Text input formatter that allows either numeric values
/// or alphanumeric text with a limited set of special characters.
class AlphanumericOrTwoDecimalInputFormatter extends TextInputFormatter {
  final RegExp _decimalRegExp = RegExp(r"^\d+$");

  final RegExp _regExp = RegExp(r"^[a-zA-Z0-9 %,#$()'’&/ ]*$");

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }
    if (_decimalRegExp.hasMatch(text) || _regExp.hasMatch(text)) {
      return newValue;
    }
    return oldValue;
  }
}

/// Text input formatter that validates input against a regular expression
/// pattern.
class RegexInputFormatter extends TextInputFormatter {
  /// Creates a [RegexInputFormatter].
  RegexInputFormatter(this.pattern) : _regExp = RegExp(pattern);

  /// Regular expression pattern used to validate input.
  final String pattern;

  final RegExp _regExp;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    if (_regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}

/// Text input formatter that restricts numeric values to a configurable
/// number of integer and decimal digits.
///
/// Originally introduced for project contract values using a 21+6 format and
/// currently used with a 15+6 digit configuration.
class NumericDecimalTextInputFormatter extends TextInputFormatter {
  /// Creates a [NumericDecimalTextInputFormatter].
  NumericDecimalTextInputFormatter({
    required this.maxIntegerDigits,
    required this.maxDecimalDigits,
  });

  /// Maximum number of digits allowed before the decimal point.
  final int maxIntegerDigits;

  /// Maximum number of digits allowed after the decimal point.
  final int maxDecimalDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Always allow empty input (user deleting)
    if (text.isEmpty) {
      return newValue;
    }

    // Quick reject: only digits, commas, and at most one dot
    // (we check counts precisely below)
    if (!RegExp(r"^[0-9,]*\.?[0-9,]*$").hasMatch(text)) {
      return oldValue;
    }

    // Remove commas for validation
    final noCommas = text.replaceAll(",", "");

    // Reject if multiple dots
    final dotCount = ".".allMatches(noCommas).length;
    if (dotCount > 1) {
      return oldValue;
    }

    // Basic numeric structure: digits, optional dot, digits
    if (!RegExp(r"^\d*\.?\d*$").hasMatch(noCommas)) {
      return oldValue;
    }

    // Split integer and decimal parts
    final parts = noCommas.split(".");
    final integerPart = parts[0];
    final decimalPart = parts.length == 2 ? parts[1] : "";

    // Enforce max digits
    if (integerPart.length > maxIntegerDigits) {
      return oldValue;
    }
    if (decimalPart.length > maxDecimalDigits) {
      return oldValue;
    }

    // All checks passed
    return newValue;
  }
}
