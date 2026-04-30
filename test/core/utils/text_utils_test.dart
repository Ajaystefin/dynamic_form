import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:intl/intl.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";

// Mock example (though not required for these formatters)
class MockTextEditingValue extends Mock implements TextEditingValue {}

void main() {
  group("StringExtension", () {
    group("capitalizeFirstLetter", () {
      test("should capitalize first letter of normal string", () {
        final result = "hello world".capitalizeFirstLetter();
        expect(result, equals("Hello world"));
      });

      test("should handle single character", () {
        final result = "a".capitalizeFirstLetter();
        expect(result, equals("A"));
      });

      test("should handle already capitalized string", () {
        final result = "Hello World".capitalizeFirstLetter();
        expect(result, equals("Hello world"));
      });

      test("should handle string with numbers", () {
        final result = "123abc".capitalizeFirstLetter();
        expect(result, equals("123abc")); // Numbers don't change
      });

      test("should handle string with special characters", () {
        final result = "!hello".capitalizeFirstLetter();
        expect(result, equals("!hello")); // Special characters don't change
      });

      test("should handle string with spaces at beginning", () {
        final result = " hello".capitalizeFirstLetter();
        expect(result, equals(" hello")); // Space doesn't change
      });

      test("should handle string with tabs at beginning", () {
        final result = "\thello".capitalizeFirstLetter();
        expect(result, equals("\thello")); // Tab doesn't change
      });

      test("should handle string with newlines at beginning", () {
        final result = "\nhello".capitalizeFirstLetter();
        expect(result, equals("\nhello")); // Newline doesn't change
      });

      test("should handle empty string", () {
        final result = "".capitalizeFirstLetter();
        expect(result, equals(""));
      });

      test("should handle string with only spaces", () {
        final result = "   ".capitalizeFirstLetter();
        expect(result, equals("   "));
      });

      test("should handle string with only special characters", () {
        final result = "!@#".capitalizeFirstLetter();
        expect(result, equals("!@#"));
      });

      test("should handle string with only numbers", () {
        final result = "123".capitalizeFirstLetter();
        expect(result, equals("123"));
      });

      test("should handle string with mixed case", () {
        final result = "hElLo WoRlD".capitalizeFirstLetter();
        expect(result, equals("Hello world"));
      });

      test("should handle string with unicode characters", () {
        final result = "你好world".capitalizeFirstLetter();
        expect(result, equals("你好world")); // Unicode characters don't change
      });

      test("should handle string with emojis", () {
        final result = "🚀hello".capitalizeFirstLetter();
        expect(result, equals("🚀hello")); // Emojis don't change
      });

      test("should handle very long string", () {
        final longString = 'a${'b' * 1000}';
        final result = longString.capitalizeFirstLetter();
        expect(result, equals('A${'b' * 1000}'));
      });

      test("should handle string with multiple words", () {
        final result = "hello world test".capitalizeFirstLetter();
        expect(result, equals("Hello world test"));
      });

      test("should handle string with punctuation", () {
        final result = "hello, world!".capitalizeFirstLetter();
        expect(result, equals("Hello, world!"));
      });

      test("should handle string with quotes", () {
        final result = '"hello world"'.capitalizeFirstLetter();
        expect(result, equals('"hello world"'));
      });

      test("should handle string with parentheses", () {
        final result = "(hello world)".capitalizeFirstLetter();
        expect(result, equals("(hello world)"));
      });

      test("should handle string with brackets", () {
        final result = "[hello world]".capitalizeFirstLetter();
        expect(result, equals("[hello world]"));
      });

      test("should handle string with braces", () {
        final result = "{hello world}".capitalizeFirstLetter();
        expect(result, equals("{hello world}"));
      });

      test("should handle string with backticks", () {
        final result = "`hello world`".capitalizeFirstLetter();
        expect(result, equals("`hello world`"));
      });

      test("should handle string with forward slashes", () {
        final result = "/hello world/".capitalizeFirstLetter();
        expect(result, equals("/hello world/"));
      });

      test("should handle string with backslashes", () {
        final result = r"\hello world".capitalizeFirstLetter();
        expect(result, equals(r"\hello world"));
      });

      test("should handle string with pipe characters", () {
        final result = "|hello world|".capitalizeFirstLetter();
        expect(result, equals("|hello world|"));
      });

      test("should handle string with asterisks", () {
        final result = "*hello world*".capitalizeFirstLetter();
        expect(result, equals("*hello world*"));
      });

      test("should handle string with plus signs", () {
        final result = "+hello world+".capitalizeFirstLetter();
        expect(result, equals("+hello world+"));
      });

      test("should handle string with minus signs", () {
        final result = "-hello world-".capitalizeFirstLetter();
        expect(result, equals("-hello world-"));
      });

      test("should handle string with equals signs", () {
        final result = "=hello world=".capitalizeFirstLetter();
        expect(result, equals("=hello world="));
      });

      test("should handle string with percent signs", () {
        final result = "%hello world%".capitalizeFirstLetter();
        expect(result, equals("%hello world%"));
      });

      test("should handle string with dollar signs", () {
        final result = r"$hello world$".capitalizeFirstLetter();
        expect(result, equals(r"$hello world$"));
      });

      test("should handle string with ampersands", () {
        final result = "&hello world&".capitalizeFirstLetter();
        expect(result, equals("&hello world&"));
      });

      test("should handle string with carets", () {
        final result = "^hello world^".capitalizeFirstLetter();
        expect(result, equals("^hello world^"));
      });

      test("should handle string with tildes", () {
        final result = "~hello world~".capitalizeFirstLetter();
        expect(result, equals("~hello world~"));
      });

      test("should handle string with underscores", () {
        final result = "_hello world_".capitalizeFirstLetter();
        expect(result, equals("_hello world_"));
      });

      test("should handle string with dots", () {
        final result = ".hello world.".capitalizeFirstLetter();
        expect(result, equals(".hello world."));
      });

      test("should handle string with commas", () {
        final result = ",hello world,".capitalizeFirstLetter();
        expect(result, equals(",hello world,"));
      });

      test("should handle string with semicolons", () {
        final result = ";hello world;".capitalizeFirstLetter();
        expect(result, equals(";hello world;"));
      });

      test("should handle string with colons", () {
        final result = ":hello world:".capitalizeFirstLetter();
        expect(result, equals(":hello world:"));
      });

      test("should handle string with question marks", () {
        final result = "?hello world?".capitalizeFirstLetter();
        expect(result, equals("?hello world?"));
      });

      test("should handle string with exclamation marks", () {
        final result = "!hello world!".capitalizeFirstLetter();
        expect(result, equals("!hello world!"));
      });

      test("should handle string with at symbols", () {
        final result = "@hello world@".capitalizeFirstLetter();
        expect(result, equals("@hello world@"));
      });

      test("should handle string with hash symbols", () {
        final result = "#hello world#".capitalizeFirstLetter();
        expect(result, equals("#hello world#"));
      });
    });
  });
  test("should handle value and format it ", () {
    final result = "1000".formatNumber();
    expect(result, equals("1,000"));
  });

  group("StringExtension - capitalizeFirstLetter", () {
    test("returns empty string unchanged", () {
      expect("".capitalizeFirstLetter(), "");
    });

    test("capitalizes first letter and lowercases the rest", () {
      expect("hello".capitalizeFirstLetter(), "Hello");
      expect("hELLo".capitalizeFirstLetter(), "Hello");
    });

    test("single character", () {
      expect("a".capitalizeFirstLetter(), "A");
      expect("A".capitalizeFirstLetter(), "A");
    });
  });

  group("StringExtension - formatNumber", () {
    test("formats valid number using en_IN format", () {
      expect(
        "1234567".formatNumber(),
        NumberFormat.decimalPattern("en_IN").format(1234567),
      );
    });

    test("returns original string when parsing fails", () {
      expect("abc".formatNumber(), "abc");
      expect("12a34".formatNumber(), "12a34");
    });
  });

  group("DecimalInputFormatter216", () {
    final formatter = DecimalInputFormatter216();

    TextEditingValue v(String text) => TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );

    test("allows valid decimal patterns", () {
      expect(formatter.formatEditUpdate(v(""), v("123")), v("123"));
      expect(
        formatter.formatEditUpdate(v("1"), v("12345.123456")),
        v("12345.123456"),
      );
    });

    test("rejects invalid input and returns oldValue", () {
      expect(formatter.formatEditUpdate(v("123"), v("123.1234567")), v("123"));
      expect(formatter.formatEditUpdate(v("123"), v("abc")), v("123"));
      expect(formatter.formatEditUpdate(v("123"), v("12.3.4")), v("123"));
    });
  });

  group("ThousandsWithMaxDigitsFormatter", () {
    final formatter = ThousandsWithMaxDigitsFormatter(maxDigits: 5);

    TextEditingValue v(String text) => TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );

    test("formats digits with thousands separators", () {
      final result = formatter.formatEditUpdate(v(""), v("12345"));
      expect(result.text, "12,345");
    });

    test("enforces max digits", () {
      final result = formatter.formatEditUpdate(v(""), v("123456789"));
      expect(result.text, "12,345"); // max 5 digits
    });

    test("returns empty value when all digits are removed", () {
      final result = formatter.formatEditUpdate(v("123"), v(""));
      expect(result.text, "");
    });
  });

  group("ThousandsSeparatorFormatter", () {
    final formatter = ThousandsSeparatorFormatter();

    TextEditingValue v(String text) => TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );

    test("formats with comma separators", () {
      final result = formatter.formatEditUpdate(v(""), v("1234567"));
      expect(result.text, "1,234,567");
    });

    test("returns empty text for empty input", () {
      final result = formatter.formatEditUpdate(v(""), v(""));
      expect(result.text, "");
    });

    test("blocks non-digits and returns oldValue", () {
      final oldValue = v("123");
      final result = formatter.formatEditUpdate(oldValue, v("12a3"));
      expect(result, oldValue);
    });
  });
}
