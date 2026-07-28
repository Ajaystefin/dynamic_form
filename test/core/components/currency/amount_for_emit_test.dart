import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/currency/defaults.dart";

void main() {
  group("amountForEmit", () {
    test("returns the untouched original when the text still matches it", () {
      // The field displays the rounded value; saving must not push that
      // rounding into the payload.
      expect(amountForEmit("1,235", 1234.6), 1234.6);
    });

    test("parses the text once the user has edited it", () {
      expect(amountForEmit("2,000", 1234.6), 2000.0);
    });

    test("parses the text when there is no original to preserve", () {
      expect(amountForEmit("1,234", null), 1234.0);
    });

    test("handles an integral original with no fractional part to keep", () {
      expect(amountForEmit("1,234", 1234), 1234.0);
    });

    test("returns null for empty or unparseable text", () {
      expect(amountForEmit("", null), isNull);
      expect(amountForEmit(null, null), isNull);
      expect(amountForEmit("abc", 10), isNull);
    });

    test("rounds half away from zero when comparing, matching the display", () {
      // 1234.5 displays as "1,235", so that text means "untouched".
      expect(amountForEmit("1,235", 1234.5), 1234.5);
      // "1,234" is what a truncating display would have shown — treat it as
      // user input and parse it.
      expect(amountForEmit("1,234", 1234.5), 1234.0);
    });
  });
}
