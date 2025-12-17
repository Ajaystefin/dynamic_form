import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

class CustomValidator {
  // Required field validation with custm message
  static String? requiredFieldCustomMsg(String? value, String? message) {
    if (value == null || value.isEmpty) {
      return message;
    }
    return null;
  }

  // Required field validation
  static String? requiredField(String? value) {
    if (value == null || value.isEmpty) {
      return 'common.validation.emptyRequiredField'.tr();
    }
    return null;
  }

  // Required custom field name validation
  static String? requiredCustomField(String? value, String fielName) {
    if (value == null || value.isEmpty) {
      return 'common.validation.pleaseEnter'.tr() + fielName;
    }
    return null;
  }

// Please enter
  // Required field validation
  static String? requiredBoolField(bool? value) {
    if (value == null || !value) {
      return 'common.validation.pleaseEnter'.tr();
    }
    return null;
  }

  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'common.validation.emptyEmail'.tr();
    }
    final regex = RegExp(r'\S+@\S+\.\S+');
    if (!regex.hasMatch(value)) {
      return 'common.validation.invalidEmail'.tr();
    }
    return null;
  }

  // Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'common.validation.emptyPassword'.tr();
    }
    if (value.length < 8) {
      return 'common.validation.shortPassword'.tr();
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'common.validation.noNumberPassword'.tr();
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      return 'common.validation.noLetterPassword'.tr();
    }
    return null;
  }

  // Phone number validation
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'common.validation.emptyPhoneNumber'.tr();
    }
    final regex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!regex.hasMatch(value)) {
      return 'common.validation.invalidPhoneNumber'.tr();
    }
    return null;
  }

  // Numeric validation
  static String? numeric(String? value) {
    if (value == null || value.isEmpty) {
      return 'common.validation.emptyField'.tr();
    }
    if (double.tryParse(value) == null) {
      return 'common.validation.invalidNumber'.tr();
    }
    return null;
  }

  // Range validation
  static String? range(String? value, {int min = 1, int max = 100}) {
    if (value == null || value.isEmpty) {
      return 'common.validation.emptyField'.tr();
    }
    final number = int.tryParse(value);
    if (number == null) {
      return 'common.validation.invalidNumber'.tr();
    }
    if (number < min || number > max) {
      return 'Number must be between $min and $max';
    }
    return null;
  }

  // Date validation
  static String? date(String? value) {
    if (value == null || value.isEmpty) {
      return 'common.validation.emptyDate'.tr();
    }
    // final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    // if (!regex.hasMatch(value)) {
    //   return 'common.validation.invalidDate'.tr();
    // }

    // try {
    //     DateFormat('dd/MM/yyyy').parseStrict(value);
    //   } catch (_) {
    //     return 'common.validation.invalidDate'.tr();
    //   }

    // Regex for dd/MM/yyyy
    final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!regex.hasMatch(value)) {
      return 'common.validation.invalidDate'.tr();
    }

    return null;
  }

  /// Accepts 'dd/MM' or 'dd/MM/yyyy'
 static String? financialYearEndValidator(String? value) {
    final v = (value ?? '').trim();

    if (v.isEmpty) {
      return 'common.validation.emptyDate'.tr();
    }

    // Matches dd/MM or dd/MM/yyyy
    final regex = RegExp(r'^\d{2}/\d{2}(?:/\d{4})?$');
    if (!regex.hasMatch(v)) {
      return 'common.validation.invalidDate'.tr();
    }

    // If yyyy is provided, parse strictly
    if (v.length == 10) {
      try {
        DateFormat('dd/MM/yyyy').parseStrict(v);
      } catch (_) {
        return 'common.validation.invalidDate'.tr();
      }
      return null;
    }

    // For dd/MM, just range-check day & month
    final parts = v.split('/');
    final day = int.tryParse(parts[0]) ?? -1;
    final month = int.tryParse(parts[1]) ?? -1;
    if (day < 1 || day > 31 || month < 1 || month > 12) {
      return 'common.validation.invalidDate'.tr();
    }

    return null;
  }

  static String? optionalDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!regex.hasMatch(value)) {
      return 'common.validation.invalidDate'.tr();
    }
    return null;
  }

  // Confirm password validation
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'common.validation.confirmPassword'.tr();
    }
    if (value != password) {
      return 'common.validation.passwordMismatch'.tr();
    }
    return null;
  }

  // URL validation
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return 'common.validation.emptyUrl'.tr();
    }
    final regex = RegExp(r'^(http|https)://\S+\.\S+$');
    if (!regex.hasMatch(value)) {
      return 'common.validation.invalidUrl'.tr();
    }
    return null;
  }

  // Equality validation (checks if two fields have the same value)
  static String? equal(String? value, String compareValue) {
    if (value != compareValue) {
      return 'common.validation.notEqual'.tr();
    }
    return null;
  }

  // Limits input to a maximum of 21 digits before the decimal and 6 after.
  static String? limitedNumeric(String? value) {
    if (value == null || value.isEmpty) {
      return 'common.validation.emptyField'.tr();
    }

    final regex = RegExp(r'^\d{1,21}(\.\d{0,6})?$');
    if (!regex.hasMatch(value)) {
      return 'common.validation.enterValidNumber'.tr();
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
          'common.validation.maxLengthExceeded'
              .tr(args: [maxLength.toString()]);
    }
    return null;
  }

  /// InputFormatter that allows typing/deleting “N/A” and numeric values ≤100.00
  /// with up to two decimal places.
  ///       otherwise only allow up to 3 digits, optional "." + up to 2 digits, ≤100
  static TextInputFormatter naOrNumberUpTo100Formatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final txt = newValue.text;
      if (txt.isEmpty) return newValue;
      if (RegExp(r'^[Nn\/Aa]{0,3}$').hasMatch(txt)) {
        return newValue;
      }
      final numericPattern = RegExp(r'^\d{0,3}(\.\d{0,2})?$');
      final parsed = double.tryParse(txt);
      if (parsed != null && parsed <= 100 && numericPattern.hasMatch(txt)) {
        return newValue;
      }
      return oldValue;
    });
  }

  /// Validator that accepts "N/A" or a numeric value ≤100.00
  /// with up to two decimal places.
  static String? naOrNumberUpTo100Validator(String? value) {
    final txt = value?.trim() ?? '';
    if (txt.toUpperCase() == 'N/A') {
      return null;
    }
    final parsed = double.tryParse(txt);
    if (parsed == null) {
      return 'remarks.feeStructure.plsEnterNumberNa'.tr();
    }
    if (parsed > 100) {
      return 'remarks.feeStructure.valueCannotExceed100'.tr();
    }
    if (txt.contains('.')) {
      final fraction = txt.split('.')[1];
      if (fraction.length > 2) {
        return 'common.validation.enterValidNumber'.tr();
      }
    }
    return null;
  }

  // Allows only numbers with up to 2 decimal places
  static String? twoDecimalNumeric(String? value) {
    if (value == null || value.isEmpty) {
      return 'common.validation.emptyField'.tr();
    }

    final regex = RegExp(r'^\d+(\.\d{1,2})?$');
    if (!regex.hasMatch(value)) {
      return 'common.validation.enterValidNumber'.tr();
    }

    return null;
  }
}

class DecimalInputFormatter extends TextInputFormatter {
  final RegExp _regExp = RegExp(r'^\d{0,21}(\.\d{0,6})?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}

class AlphanumericOrTwoDecimalInputFormatter extends TextInputFormatter {
  final RegExp _decimalRegExp = RegExp(r'^\d+(\.\d{0,2})?$');
  final RegExp _regExp = RegExp(r'^[a-zA-Z0-9]*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) return newValue;

    if (_decimalRegExp.hasMatch(text) || _regExp.hasMatch(text)) {
      return newValue;
    }

    return oldValue;
  }
}
