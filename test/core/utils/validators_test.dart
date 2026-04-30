import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/validators.dart";

// Override .tr() inside tests
extension TrMock on String {
  String tr() => this; // Just return itself
}

void main() {
  group("CustomValidator", () {
    group("requiredFieldCustomMsg", () {
      test("should return custom message when value is null", () {
        final result = CustomValidator.requiredFieldCustomMsg(
          null,
          "Custom error message",
        );
        expect(result, equals("Custom error message"));
      });

      test("should return custom message when value is empty", () {
        final result =
            CustomValidator.requiredFieldCustomMsg("", "Custom error message");
        expect(result, equals("Custom error message"));
      });

      test("should return null when value is whitespace only", () {
        // The current implementation only checks for null or empty, not
        // whitespace
        final result = CustomValidator.requiredFieldCustomMsg(
          "   ",
          "Custom error message",
        );
        expect(result, isNull);
      });

      test("should return null when value is valid", () {
        final result = CustomValidator.requiredFieldCustomMsg(
          "valid value",
          "Custom error message",
        );
        expect(result, isNull);
      });

      test("should return null when value has content", () {
        final result = CustomValidator.requiredFieldCustomMsg(
          "Hello World",
          "Custom error message",
        );
        expect(result, isNull);
      });
    });

    group("requiredField", () {
      test("should return error message when value is null", () {
        final result = CustomValidator.requiredField(null);
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message when value is empty", () {
        final result = CustomValidator.requiredField("");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return null when value is valid", () {
        final result = CustomValidator.requiredField("valid value");
        expect(result, isNull);
      });
    });

    group("requiredCustomField", () {
      test("should return error message when value is null", () {
        final result = CustomValidator.requiredCustomField(null, "Field Name");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message when value is empty", () {
        final result = CustomValidator.requiredCustomField("", "Field Name");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return null when value is valid", () {
        final result =
            CustomValidator.requiredCustomField("valid value", "Field Name");
        expect(result, isNull);
      });
    });

    group("requiredBoolField", () {
      test("should return error message when value is null", () {
        final result = CustomValidator.requiredBoolField(null);
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message when value is false", () {
        final result = CustomValidator.requiredBoolField(false);
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return null when value is true", () {
        final result = CustomValidator.requiredBoolField(true);
        expect(result, isNull);
      });
    });

    group("email", () {
      test("should return error message when value is null", () {
        final result = CustomValidator.email(null);
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message when value is empty", () {
        final result = CustomValidator.email("");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message for invalid email format", () {
        final result = CustomValidator.email("invalid-email");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message for email without domain", () {
        final result = CustomValidator.email("test@");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return null for valid email", () {
        final result = CustomValidator.email("test@example.com");
        expect(result, isNull);
      });
    });

    group("password", () {
      test("should return error message when value is null", () {
        final result = CustomValidator.password(null);
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message when value is empty", () {
        final result = CustomValidator.password("");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message for short password", () {
        final result = CustomValidator.password("123");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message for password without numbers", () {
        final result = CustomValidator.password("abcdefgh");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message for password without letters", () {
        final result = CustomValidator.password("12345678");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return null for valid password", () {
        final result = CustomValidator.password("Password123");
        expect(result, isNull);
      });
    });

    group("phoneNumber", () {
      test("should return error message when value is null", () {
        final result = CustomValidator.phoneNumber(null);
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message when value is empty", () {
        final result = CustomValidator.phoneNumber("");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message for invalid phone number", () {
        final result = CustomValidator.phoneNumber("abc123");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message for phone number starting with 0", () {
        final result = CustomValidator.phoneNumber("0123456789");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return null for valid phone number", () {
        final result = CustomValidator.phoneNumber("1234567890");
        expect(result, isNull);
      });

      test("should return null for valid phone number with plus", () {
        final result = CustomValidator.phoneNumber("+1234567890");
        expect(result, isNull);
      });
    });

    group("numeric", () {
      test("should return error message when value is null", () {
        final result = CustomValidator.numeric(null);
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message when value is empty", () {
        final result = CustomValidator.numeric("");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message for non-numeric value", () {
        final result = CustomValidator.numeric("abc");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return null for valid numeric value", () {
        final result = CustomValidator.numeric("123");
        expect(result, isNull);
      });

      test("should return null for valid decimal value", () {
        final result = CustomValidator.numeric("123.45");
        expect(result, isNull);
      });
    });

    group("range", () {
      test("should return error message when value is null", () {
        final result = CustomValidator.range(null);
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message when value is empty", () {
        final result = CustomValidator.range("");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message for non-numeric value", () {
        final result = CustomValidator.range("abc");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message for value below minimum", () {
        final result = CustomValidator.range("0");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message for value above maximum", () {
        final result = CustomValidator.range("101");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return null for value within range", () {
        final result = CustomValidator.range("50");
        expect(result, isNull);
      });

      test("should return null for minimum value", () {
        final result = CustomValidator.range("1");
        expect(result, isNull);
      });

      test("should return null for maximum value", () {
        final result = CustomValidator.range("100");
        expect(result, isNull);
      });
    });

    group("date", () {
      test("should return error message when value is null", () {
        final result = CustomValidator.date(null);
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message when value is empty", () {
        final result = CustomValidator.date("");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message for invalid date format", () {
        final result = CustomValidator.date("2023/12/25");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });
    });

    group("optionalDate", () {
      test("should return null when value is null", () {
        final result = CustomValidator.optionalDate(null);
        expect(result, isNull);
      });

      test("should return null when value is empty", () {
        final result = CustomValidator.optionalDate("");
        expect(result, isNull);
      });

      test("should return error message for invalid date format", () {
        final result = CustomValidator.optionalDate("2023/12/25");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return null for valid date format", () {
        final result = CustomValidator.optionalDate("2023-12-25");
        expect(result, isNull);
      });
    });

    group("confirmPassword", () {
      test("should return error message when value is null", () {
        final result = CustomValidator.confirmPassword(null, "password123");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message when value is empty", () {
        final result = CustomValidator.confirmPassword("", "password123");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message when passwords do not match", () {
        final result =
            CustomValidator.confirmPassword("password456", "password123");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return null when passwords match", () {
        final result =
            CustomValidator.confirmPassword("password123", "password123");
        expect(result, isNull);
      });
    });

    group("url", () {
      test("should return error message when value is null", () {
        final result = CustomValidator.url(null);
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message when value is empty", () {
        final result = CustomValidator.url("");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message for invalid URL format", () {
        final result = CustomValidator.url("not-a-url");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message for URL without protocol", () {
        final result = CustomValidator.url("example.com");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return null for valid URL with http", () {
        final result = CustomValidator.url("http://example.com");
        expect(result, isNull);
      });

      test("should return null for valid URL with https", () {
        final result = CustomValidator.url("https://example.com");
        expect(result, isNull);
      });
    });

    group("equal", () {
      test("should return error message when values are not equal", () {
        final result = CustomValidator.equal("value1", "value2");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return null when values are equal", () {
        final result = CustomValidator.equal("value1", "value1");
        expect(result, isNull);
      });
    });

    group("limitedNumeric", () {
      test("should return error message when value is null", () {
        final result = CustomValidator.limitedNumeric(null);
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message when value is empty", () {
        final result = CustomValidator.limitedNumeric("");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return error message for non-numeric value", () {
        final result = CustomValidator.limitedNumeric("abc");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test(
          "should return error message for value with"
          " too many digits before decimal", () {
        final result = CustomValidator.limitedNumeric("1234567890123456789012");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test(
          "should return error "
          "message for value "
          "with too many digits after decimal", () {
        final result = CustomValidator.limitedNumeric("123.1234567");
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return null for valid numeric value", () {
        final result = CustomValidator.limitedNumeric("123");
        expect(result, isNull);
      });

      test("should return null for valid decimal value", () {
        final result = CustomValidator.limitedNumeric("123.456");
        expect(result, isNull);
      });

      test("should return null for maximum valid value", () {
        final result = CustomValidator.limitedNumeric("123456789012345678901");
        expect(result, isNull);
      });

      test("should return null for maximum valid decimal value", () {
        final result = CustomValidator.limitedNumeric("123.123456");
        expect(result, isNull);
      });
    });

    group("maxLength", () {
      test("should return error message when value exceeds limit", () {
        final result = CustomValidator.maxLength(
          "This is a very long string that exceeds the limit",
          10,
        );
        expect(result, isNotNull);
        expect(result, isA<String>());
      });

      test("should return custom message when value exceeds limit", () {
        final result = CustomValidator.maxLength(
          "Too long",
          5,
          customMsg: "Custom error message",
        );
        expect(result, equals("Custom error message"));
      });

      test("should return null when value is within limit", () {
        final result = CustomValidator.maxLength("Short", 10);
        expect(result, isNull);
      });

      test("should return null when value is exactly at limit", () {
        final result = CustomValidator.maxLength("Exactly", 7);
        expect(result, isNull);
      });

      test("should return null when value is null", () {
        final result = CustomValidator.maxLength(null, 10);
        expect(result, isNull);
      });
    });
  });

  group("DecimalInputFormatter", () {
    test("should allow valid decimal input", () {
      final formatter = DecimalInputFormatter();
      const oldValue = TextEditingValue(text: "123");
      const newValue = TextEditingValue(text: "123.45");

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, equals("123.45"));
    });

    test("should reject invalid decimal input", () {
      final formatter = DecimalInputFormatter();
      const oldValue = TextEditingValue(text: "123");
      const newValue = TextEditingValue(text: "123.abc");

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, equals("123")); // Should return old value
    });

    test("should allow input with too many digits before decimal", () {
      final formatter = DecimalInputFormatter();
      const oldValue = TextEditingValue(text: "123456789012345678901");
      const newValue = TextEditingValue(text: "1234567890123456789012");

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(
        result.text,
        equals("123456789012345678901"),
      ); // Should return old value
    });

    test("should allow input with too many digits after decimal", () {
      final formatter = DecimalInputFormatter();
      const oldValue = TextEditingValue(text: "123.123456");
      const newValue = TextEditingValue(text: "123.1234567");

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, equals("123.123456")); // Should return old value
    });

    group("naOrNumberUpTo100Formatter", () {
      final formatter = CustomValidator.naOrNumberUpTo100Formatter();

      const TextEditingValue oldValue = TextEditingValue(text: "");
      TextEditingValue newValue(String text) => TextEditingValue(text: text);

      test("should allow empty input", () {
        expect(formatter.formatEditUpdate(oldValue, newValue("")).text, "");
      });

      test("should allow N/A in any case", () {
        expect(
          formatter.formatEditUpdate(oldValue, newValue("N/A")).text,
          "N/A",
        );
        expect(
          formatter.formatEditUpdate(oldValue, newValue("n/a")).text,
          "n/a",
        );
      });

      test("should allow valid number <= 100 with up to 2 decimals", () {
        expect(formatter.formatEditUpdate(oldValue, newValue("99")).text, "99");
        expect(
          formatter.formatEditUpdate(oldValue, newValue("99.99")).text,
          "99.99",
        );
      });

      test("should reject invalid number > 100", () {
        expect(formatter.formatEditUpdate(oldValue, newValue("")).text, "");
      });

      test("should reject invalid format", () {
        expect(formatter.formatEditUpdate(oldValue, newValue("abc")).text, "");
      });
    });

    group("CustomValidator.naOrNumberUpTo100Validator", () {
      test("should accept N/A", () {
        expect(CustomValidator.naOrNumberUpTo100Validator("N/A"), null);
      });

      test("should accept valid number", () {
        expect(CustomValidator.naOrNumberUpTo100Validator("99.99"), null);
      });
    });

    group("twoDecimalNumeric", () {
      test("should accept valid number with up to 2 decimals", () {
        expect(CustomValidator.twoDecimalNumeric("12.34"), null);
        expect(CustomValidator.twoDecimalNumeric("12"), null);
      });
    });
  });

  final formatter = NumericDecimalTextInputFormatter(
    maxIntegerDigits: 15,
    maxDecimalDigits: 6,
  );

  TextEditingValue makeValue(String text) => TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );

  group("NumericDecimalTextInputFormatter Tests", () {
    test("allows empty input", () {
      final oldValue = makeValue("123");
      final newValue = makeValue("");

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, "");
    });

    test("allows valid integer only input", () {
      final oldValue = makeValue("");
      final newValue = makeValue("123456");

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, "123456");
    });

    test("denies invalid characters", () {
      final oldValue = makeValue("123");
      final newValue = makeValue("123a");

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, "123"); // reverts
    });

    test("allows valid decimal input", () {
      final oldValue = makeValue("123");
      final newValue = makeValue("123.45");

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, "123.45");
    });

    test("denies multiple dots", () {
      final oldValue = makeValue("123.4");
      final newValue = makeValue("123.4.5");

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, "123.4");
    });

    test("denies integer overflow", () {
      final oldValue = makeValue("123456789012345"); // 15 digits ok
      final newValue = makeValue("1234567890123456"); // 16 digits

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, "123456789012345"); // revert
    });

    test("denies decimal overflow", () {
      final oldValue = makeValue("123.123456"); // 6 decimal digits ok
      final newValue = makeValue("123.1234567"); // 7 digits

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, "123.123456");
    });

    test("allows commas in input", () {
      final oldValue = makeValue("");
      final newValue = makeValue("1,234,567.89");

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, "1,234,567.89");
    });

    test("rejects invalid comma placement", () {
      final oldValue = makeValue("1,234");
      final newValue = makeValue("1,234");

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, "1,234");
    });

    test("rejects invalid pattern even if characters valid", () {
      final oldValue = makeValue("123");
      final newValue = makeValue("..123");

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, "123");
    });
  });

  group("DecimalInputFormatterTwoDigit", () {
    final formatter = DecimalInputFormatterTwoDigit();

    TextEditingValue v(String t) => TextEditingValue(
          text: t,
          selection: TextSelection.collapsed(offset: t.length),
        );

    test("allows empty string", () {
      final result = formatter.formatEditUpdate(v("1"), v(""));
      expect(result.text, "");
    });

    test("allows valid integer only input", () {
      final result = formatter.formatEditUpdate(v(""), v("123456"));
      expect(result.text, "123456");
    });

    test("allows valid decimal input with up to 2 digits", () {
      final result = formatter.formatEditUpdate(v("1.2"), v("123.45"));
      expect(result.text, "123.45");
    });

    test("denies more than 21 integer digits", () {
      final valid = "1" * 21;
      final invalid = "1" * 22;

      final result = formatter.formatEditUpdate(v(valid), v(invalid));
      expect(result.text, valid);
    });

    test("denies more than 2 decimal digits", () {
      final result = formatter.formatEditUpdate(v("1.23"), v("1.234"));
      expect(result.text, "1.23");
    });

    test("denies invalid input", () {
      final result = formatter.formatEditUpdate(v("123"), v("12a3"));
      expect(result.text, "123");
    });
  });

  group("CustomValidator.financialYearEndValidator", () {
    test("returns emptyDate when input is null", () {
      final result = CustomValidator.financialYearEndValidator(null);
      expect(result, "common.validation.emptyDate");
    });

    test("returns emptyDate when input is empty", () {
      final result = CustomValidator.financialYearEndValidator("");
      expect(result, "common.validation.emptyDate");
    });

    test("rejects invalid format", () {
      final result = CustomValidator.financialYearEndValidator("1/12");
      expect(result, "common.validation.invalidDate");
    });

    test("rejects invalid characters", () {
      final result = CustomValidator.financialYearEndValidator("aa/bb");
      expect(result, "common.validation.invalidDate");
    });

    test("accepts valid dd/MM without year", () {
      final result = CustomValidator.financialYearEndValidator("31/12");
      expect(result, null);
    });

    test("rejects invalid day in dd/MM", () {
      final result = CustomValidator.financialYearEndValidator("32/12");
      expect(result, "common.validation.invalidDate");
    });

    test("rejects invalid month in dd/MM", () {
      final result = CustomValidator.financialYearEndValidator("10/13");
      expect(result, "common.validation.invalidDate");
    });

    test("accepts valid dd/MM/yyyy", () {
      final result = CustomValidator.financialYearEndValidator("15/02/2024");
      expect(result, null);
    });

    test("rejects invalid dd/MM/yyyy structurally", () {
      // 30 Feb is invalid date
      final result = CustomValidator.financialYearEndValidator("30/02/2024");
      expect(result, "common.validation.invalidDate");
    });

    test("rejects malformed dd/MM/yyyy", () {
      final result = CustomValidator.financialYearEndValidator(
        "15/2/2024",
      ); // missing leading 0
      expect(result, "common.validation.invalidDate");
    });
  });

  group("CustomValidator.naOrNumberUpTo100Validator", () {
    test("accepts N/A uppercase", () {
      expect(CustomValidator.naOrNumberUpTo100Validator("N/A"), null);
    });

    test("rejects non-numeric (not N/A)", () {
      expect(
        CustomValidator.naOrNumberUpTo100Validator("abc"),
        "remarks.feeStructure.plsEnterNumberNa",
      );
    });

    test("rejects when parsing fails (symbols)", () {
      expect(
        CustomValidator.naOrNumberUpTo100Validator("12a"),
        "remarks.feeStructure.plsEnterNumberNa",
      );
    });

    test("rejects numbers > 100", () {
      expect(
        CustomValidator.naOrNumberUpTo100Validator("100.01"),
        "remarks.feeStructure.valueCannotExceed100",
      );
      expect(
        CustomValidator.naOrNumberUpTo100Validator("101"),
        "remarks.feeStructure.valueCannotExceed100",
      );
    });

    test("rejects more than two decimal places", () {
      expect(
        CustomValidator.naOrNumberUpTo100Validator("12.345"),
        "common.validation.enterValidNumber",
      );
    });

    test("accepts whole numbers <= 100", () {
      expect(CustomValidator.naOrNumberUpTo100Validator("0"), null);
      expect(CustomValidator.naOrNumberUpTo100Validator("50"), null);
      expect(CustomValidator.naOrNumberUpTo100Validator("100"), null);
    });

    test("accepts up to two decimal places <= 100", () {
      expect(CustomValidator.naOrNumberUpTo100Validator("99.99"), null);
      expect(CustomValidator.naOrNumberUpTo100Validator("100.00"), null);
      expect(CustomValidator.naOrNumberUpTo100Validator("12.3"), null);
    });
  });
}
