import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/utils/percentage_input_formatter.dart";

void main() {
  TextEditingValue tv(String s) => TextEditingValue(text: s);

  group("PercentageInputFormatter", () {
    final fmt = PercentageInputFormatter();

    test("empty -> returns newValue (allow deletion)", () {
      final out = fmt.formatEditUpdate(tv("12"), tv(""));
      expect(out.text, "");
    });

    test("valid integer within 3 digits -> returns new", () {
      final out = fmt.formatEditUpdate(tv(""), tv("12"));
      expect(out.text, "12");
    });

    test("invalid integer length (>3) -> returns old", () {
      final out = fmt.formatEditUpdate(tv("123"), tv("1234"));
      expect(out.text, "123"); // old
    });

    test("valid decimals up to 4 places -> returns new", () {
      final out = fmt.formatEditUpdate(tv(""), tv("12.3456"));
      expect(out.text, "12.3456");
    });

    test("invalid decimals (>4 places) -> returns old", () {
      final out = fmt.formatEditUpdate(tv("12.3456"), tv("12.34567"));
      expect(out.text, "12.3456"); // old
    });

    test('block "100." (starts with dot_100) -> returns old', () {
      final out = fmt.formatEditUpdate(tv("100"), tv(ServerConstants.dot_100));
      expect(out.text, "100"); // old
    });

    test('block "100.x" (starts with dot_100) -> returns old', () {
      final out =
          fmt.formatEditUpdate(tv("100"), tv("${ServerConstants.dot_100}1"));
      expect(out.text, "100"); // old
    });

    test('exact "100" -> allowed (returns new)', () {
      final out = fmt.formatEditUpdate(tv("99"), tv(ServerConstants.max_100));
      expect(out.text, ServerConstants.max_100);
    });

    test('> 100 (e.g., "101") -> returns old', () {
      final out = fmt.formatEditUpdate(tv("99"), tv("101"));
      expect(out.text, "99"); // old
    });

    test('parse null branch: "." matches regex but parse fails -> returns old',
        () {
      // The regex ^\d{0,3}(\.\d{0,4})?$ allows "." (0 digits + "." + 0 digits)
      final out = fmt.formatEditUpdate(tv("1"), tv("."));
      expect(out.text, "1"); // old
    });

    test("invalid shape (letters) -> returns old", () {
      final out = fmt.formatEditUpdate(tv("12"), tv("1a"));
      expect(out.text, "12"); // old
    });
  });

  group(
      "createPercentageFormatter (defaults: max=100,"
      " no decimals, 3 int digits)", () {
    test(
        "assertions: maxValue >= "
        "0, maxDecimalPlaces "
        ">= 0, maxIntegerDigits > 0", () {
      expect(
        () => createPercentageFormatter(maxValue: -1),
        throwsAssertionError,
      );
      expect(
        () => createPercentageFormatter(maxDecimalPlaces: -1),
        throwsAssertionError,
      );
      expect(
        () => createPercentageFormatter(maxIntegerDigits: 0),
        throwsAssertionError,
      );
    });

    test("empty -> returns newValue (allow deletion)", () {
      final f = createPercentageFormatter();
      final out = f.formatEditUpdate(tv("12"), tv(""));
      expect(out.text, "");
    });

    test('leading "." rejected when decimals disabled', () {
      final f = createPercentageFormatter();
      final out = f.formatEditUpdate(tv("1"), tv("."));
      expect(out.text, "1"); // old
    });

    test("decimal char rejected when decimals disabled", () {
      final f = createPercentageFormatter();
      final out = f.formatEditUpdate(tv("12"), tv("12.3"));
      expect(out.text, "12"); // old
    });

    test("too many digits (> maxIntegerDigits=3) -> old", () {
      final f = createPercentageFormatter();
      final out = f.formatEditUpdate(tv("123"), tv("1234"));
      expect(out.text, "123"); // old
    });

    test("above max (default 100) -> old", () {
      final f = createPercentageFormatter();
      final out = f.formatEditUpdate(tv("100"), tv("101"));
      expect(out.text, "100"); // old
    });

    test("exact 100 -> allowed", () {
      final f = createPercentageFormatter();
      final out = f.formatEditUpdate(tv("99"), tv("100"));
      expect(out.text, "100");
    });

    test("valid integer within range -> allowed", () {
      final f = createPercentageFormatter();
      final out = f.formatEditUpdate(tv(""), tv("55"));
      expect(out.text, "55");
    });
  });

  group("createPercentageFormatter with decimals enabled", () {
    test("valid decimal up to maxDecimalPlaces -> allowed", () {
      final f = createPercentageFormatter(allowDecimal: true);
      final out = f.formatEditUpdate(tv(""), tv("12.34"));
      expect(out.text, "12.34");
    });

    test("too many decimals (> maxDecimalPlaces) -> old", () {
      final f = createPercentageFormatter(allowDecimal: true);
      final out = f.formatEditUpdate(tv("12.34"), tv("12.345"));
      expect(out.text, "12.34"); // old
    });

    test('leading "." rejected even if decimals allowed', () {
      final f = createPercentageFormatter(allowDecimal: true);
      final out = f.formatEditUpdate(tv("0"), tv(".5"));
      expect(out.text, "0"); // old
    });

    test('"100." or "100.x" blocked for max=100', () {
      final f = createPercentageFormatter(allowDecimal: true);
      expect(f.formatEditUpdate(tv("100"), tv("100.")), tv("100")); // old
      expect(f.formatEditUpdate(tv("100"), tv("100.0")), tv("100")); // old
    });

    test("value > max -> old", () {
      final f = createPercentageFormatter(allowDecimal: true);
      final out = f.formatEditUpdate(tv("100"), tv("100.01"));
      expect(out.text, "100"); // old
    });

    test('custom maxValue allows "100.01" when max=120', () {
      final f = createPercentageFormatter(
        maxValue: 120,
        allowDecimal: true,
      );
      final out = f.formatEditUpdate(tv("100"), tv("100.01"));
      expect(out.text, "100.01");
    });

    test("maxIntegerDigits respected (2 digits only)", () {
      final f = createPercentageFormatter(
        allowDecimal: true,
        maxIntegerDigits: 2,
      );
      final out = f.formatEditUpdate(tv("12"), tv("123"));
      expect(out.text, "12"); // old
    });

    test(
        "allowDecimal true but maxDecimalPlaces=0 "
        "-> no decimals allowed effectively", () {
      final f =
          createPercentageFormatter(allowDecimal: true, maxDecimalPlaces: 0);
      expect(f.formatEditUpdate(tv("1"), tv("12")), tv("12")); // ok
      // Decimal disallowed as pattern has no decimal part
      expect(f.formatEditUpdate(tv("12"), tv("12.")), tv("12")); // old
      expect(f.formatEditUpdate(tv("12"), tv("12.3")), tv("12")); // old
    });
  });
}
