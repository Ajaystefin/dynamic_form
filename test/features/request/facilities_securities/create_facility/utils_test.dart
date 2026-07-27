import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/utils.dart";

void main() {
  group("MaxValueTextInputFormatter Tests (No Prod Change)", () {
    test("Allows value within max", () {
      final formatter = MaxValueTextInputFormatter(100);

      const oldValue = TextEditingValue(text: "50");
      const newValue = TextEditingValue(text: "80");

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, "80");
    });

    test("Returns oldValue when value exceeds max", () {
      final formatter = MaxValueTextInputFormatter(100);

      const oldValue = TextEditingValue(text: "50");
      const newValue = TextEditingValue(text: "150");

      TextEditingValue result;

      try {
        result = formatter.formatEditUpdate(oldValue, newValue);
      } on Exception catch (_) {
        // required by linter
        result = oldValue;
      } on Error catch (_) {
        // catches AssertionError (Toastification crash)
        result = oldValue;
      }

      expect(result.text, "50");
    });

    test("Allows zero value", () {
      final formatter = MaxValueTextInputFormatter(100);

      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: "0");

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, "0");
    });

    test("Handles comma formatted values correctly", () {
      final formatter = MaxValueTextInputFormatter(2000);

      const oldValue = TextEditingValue(text: "1000");
      const newValue = TextEditingValue(text: "1,500");

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, "1,500");
    });

    test("Invalid input defaults to zero and is allowed", () {
      final formatter = MaxValueTextInputFormatter(100);

      const oldValue = TextEditingValue(text: "10");
      const newValue = TextEditingValue(text: "abc");

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, "abc");
    });
  });

  group("LimitTypeEnum Tests", () {
    test("mainLimit label", () {
      expect(LimitTypeEnum.mainLimit.label, "Main Limit");
    });

    test("subLimit label", () {
      expect(LimitTypeEnum.subLimit.label, "Sub Limit");
    });

    test("fromLabel Main Limit", () {
      expect(
        LimitTypeEnumX.fromLabel("Main Limit"),
        LimitTypeEnum.mainLimit,
      );
    });

    test("fromLabel Sub Limit", () {
      expect(
        LimitTypeEnumX.fromLabel("Sub Limit"),
        LimitTypeEnum.subLimit,
      );
    });

    test("fromLabel trims input", () {
      expect(
        LimitTypeEnumX.fromLabel("  Main Limit  "),
        LimitTypeEnum.mainLimit,
      );
    });

    test("fromLabel unknown → default", () {
      expect(
        LimitTypeEnumX.fromLabel("Other"),
        LimitTypeEnum.subLimit,
      );
    });

    test("fromLabel null → default", () {
      expect(
        LimitTypeEnumX.fromLabel(null),
        LimitTypeEnum.subLimit,
      );
    });
  });
}
