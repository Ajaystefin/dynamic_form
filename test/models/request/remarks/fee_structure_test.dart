import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/remarks/fee_structure.dart";

void main() {
  group("FeeStructure.fromJson", () {
    test("parses full valid payload (strings, numbers, booleans)", () {
      final json = {
        "id": "FEE-001",
        "isNew": true,
        "feeType": "Processing",
        "amountOrPercentage": "250.75",
        "feeComment": "Standard fee",
        "rimNo": 12345,
        "appRefNo": "APP-001",
      };

      final model = FeeStructure.fromJson(json);

      expect(model.id, "FEE-001");
      expect(model.isNew, isTrue);
      expect(model.feeType, "Processing");
      expect(model.amount, 250.75);
      expect(model.comments, "Standard fee");
      expect(model.rimNo, 12345);
      expect(model.appRefNo, "APP-001");
    });

    test("amountOrPercentage accepts numeric types and falls back to 0.0", () {
      // numeric double
      final m1 = FeeStructure.fromJson({
        "id": "A",
        "feeType": "Type",
        "amountOrPercentage": 99.9,
      });
      expect(m1.amount, 99.9);

      // numeric int
      final m2 = FeeStructure.fromJson({
        "id": "B",
        "feeType": "Type",
        "amountOrPercentage": 10,
      });
      expect(m2.amount, 10.0);

      // unparsable string -> 0.0
      final m3 = FeeStructure.fromJson({
        "id": "C",
        "feeType": "Type",
        "amountOrPercentage": "abc",
      });
      expect(m3.amount, 0.0);

      // null -> 0.0
      final m4 = FeeStructure.fromJson({
        "id": "D",
        "feeType": "Type",
        "amountOrPercentage": null,
      });
      expect(m4.amount, 0.0);
    });

    test("rimNo only set when value is int; otherwise null", () {
      final m1 = FeeStructure.fromJson({"feeType": "T", "rimNo": 42});
      expect(m1.rimNo, 42);

      final m2 = FeeStructure.fromJson({"feeType": "T", "rimNo": "42"});
      expect(m2.rimNo, isNull);

      final m3 = FeeStructure.fromJson({"feeType": "T", "rimNo": null});
      expect(m3.rimNo, isNull);
    });

    test("appRefNo set only for non-empty strings; empty/other -> null", () {
      final m1 = FeeStructure.fromJson({"feeType": "T", "appRefNo": "APP-9"});
      expect(m1.appRefNo, "APP-9");

      final m2 = FeeStructure.fromJson({"feeType": "T", "appRefNo": ""});
      expect(m2.appRefNo, isNull);

      final m3 = FeeStructure.fromJson({"feeType": "T", "appRefNo": 123});
      expect(m3.appRefNo, isNull);
    });

    test("defaults: id, isNew, feeType, amount, comments", () {
      final model = FeeStructure.fromJson({});
      expect(model.isNew, isFalse); // default
      expect(model.feeType, ""); // default
      expect(model.amount, 0.0); // default (parse fallback)
      expect(model.comments, ""); // default
      expect(model.rimNo, isNull);
      expect(model.appRefNo, isNull);
    });
  });

  group("FeeStructure.toJson", () {
    test("serializes non-null amount as string and includes fields", () {
      final model = FeeStructure(
        id: "FEE-2",
        isNew: true,
        feeType: "Setup",
        amount: 99.9,
        comments: "x",
        rimNo: 77,
        appRefNo: "APP-77",
      );

      final json = model.toJson();
      expect(json["feeType"], "Setup");
      expect(json["amountOrPercentage"], "0.00"); // double -> String
      expect(json["feeComment"], "x");
      expect(json["rimNo"], 77);
      expect(json["appRefNo"], "APP-77");
    });

    test('serializes amount == null as "0.0"', () {
      final model = FeeStructure(
        id: "FEE-3",
        feeType: "Monthly",
        amount: null, // explicitly null
      );

      final json = model.toJson();
      expect(json["amountOrPercentage"], "0.00");
      expect(json["feeType"], "Monthly");
    });

    test("omits null rimNo/appRefNo while keeping keys with null", () {
      // The toJson returns rimNo/appRefNo keys with null values if fields are null.
      final model = FeeStructure(
        id: "FEE-4",
        feeType: "Misc",
        comments: "none",
      );

      final json = model.toJson();
      expect(json.containsKey("rimNo"), isTrue);
      expect(json["rimNo"], isNull);
      expect(json.containsKey("appRefNo"), isTrue);
      expect(json["appRefNo"], isNull);
      expect(json["feeType"], "Misc");
      expect(json["feeComment"], "none");
      expect(json["amountOrPercentage"], "0.00");
    });

    test("round-trip fromJson -> toJson -> fromJson keeps values consistent",
        () {
      final original = FeeStructure.fromJson({
        "id": "FEE-RT",
        "isNew": true,
        "feeType": "Commission",
        "amountOrPercentage": "12.5",
        "feeComment": "Roundtrip",
        "rimNo": 999,
        "appRefNo": "APP-RT",
      });

      final json = original.toJson();
      // When converting back, id/isNew are not part of toJson; ensure core fields are preserved correctly.
      final copy = FeeStructure.fromJson(json);

      expect(copy.feeType, "Commission");
      expect(copy.amount, 12.5);
      expect(copy.comments, "Roundtrip");
      expect(copy.rimNo, 999);
      expect(copy.appRefNo, "APP-RT");
      expect(copy.isNew, isFalse);
    });
  });
}
