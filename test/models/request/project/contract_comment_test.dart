import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/project/contract_comment.dart";

void main() {
  group("ContractComment", () {
    test("constructs with provided values", () {
      final timestamp = DateTime(2024, 6, 1, 12, 30);
      const text = "This is a comment";

      final comment = ContractComment(
        text: text,
        timestamp: timestamp,
      );

      expect(comment.text, text);
      expect(comment.timestamp, timestamp);
    });

    test("toString returns expected formatted value", () {
      final timestamp = DateTime(2024, 6, 1, 12, 30);
      final comment = ContractComment(
        text: "Contract review comment",
        timestamp: timestamp,
      );

      expect(
        comment.toString(),
        "ContractComment(text: Contract review comment, "
        "timestamp: $timestamp)",
      );
    });

    test("equality returns true for identical instance", () {
      final timestamp = DateTime(2024, 6, 1, 12, 30);
      final comment = ContractComment(
        text: "Same instance",
        timestamp: timestamp,
      );

      expect(comment == comment, isTrue);
    });

    test("equality returns true when text and timestamp are same", () {
      final timestamp = DateTime(2024, 6, 1, 12, 30);

      final comment1 = ContractComment(
        text: "Same values",
        timestamp: timestamp,
      );

      final comment2 = ContractComment(
        text: "Same values",
        timestamp: timestamp,
      );

      expect(comment1 == comment2, isTrue);
      expect(comment1, equals(comment2));
    });

    test("equality returns false when text is different", () {
      final timestamp = DateTime(2024, 6, 1, 12, 30);

      final comment1 = ContractComment(
        text: "First comment",
        timestamp: timestamp,
      );

      final comment2 = ContractComment(
        text: "Second comment",
        timestamp: timestamp,
      );

      expect(comment1 == comment2, isFalse);
      expect(comment1, isNot(equals(comment2)));
    });

    test("equality returns false when timestamp is different", () {
      final comment1 = ContractComment(
        text: "Same text",
        timestamp: DateTime(2024, 6, 1, 12, 30),
      );

      final comment2 = ContractComment(
        text: "Same text",
        timestamp: DateTime(2024, 6, 1, 12, 31),
      );

      expect(comment1 == comment2, isFalse);
      expect(comment1, isNot(equals(comment2)));
    });

    test("equality returns false when compared with different object type", () {
      final comment = ContractComment(
        text: "Comment text",
        timestamp: DateTime(2024, 6, 1, 12, 30),
      );

      expect(comment.toString() == "Comment text", isFalse);
    });

    test("hashCode is same when text and timestamp are same", () {
      final timestamp = DateTime(2024, 6, 1, 12, 30);

      final comment1 = ContractComment(
        text: "Same hash",
        timestamp: timestamp,
      );

      final comment2 = ContractComment(
        text: "Same hash",
        timestamp: timestamp,
      );

      expect(comment1.hashCode, comment2.hashCode);
    });

    test("hashCode is different when text is different", () {
      final timestamp = DateTime(2024, 6, 1, 12, 30);

      final comment1 = ContractComment(
        text: "Hash one",
        timestamp: timestamp,
      );

      final comment2 = ContractComment(
        text: "Hash two",
        timestamp: timestamp,
      );

      expect(comment1.hashCode, isNot(comment2.hashCode));
    });

    test("hashCode is different when timestamp is different", () {
      final comment1 = ContractComment(
        text: "Same text",
        timestamp: DateTime(2024, 6, 1, 12, 30),
      );

      final comment2 = ContractComment(
        text: "Same text",
        timestamp: DateTime(2024, 6, 1, 12, 31),
      );

      expect(comment1.hashCode, isNot(comment2.hashCode));
    });

    test("supports empty text value", () {
      final timestamp = DateTime(2024, 6);

      final comment = ContractComment(
        text: "",
        timestamp: timestamp,
      );

      expect(comment.text, "");
      expect(comment.timestamp, timestamp);
      expect(
        comment.toString(),
        "ContractComment(text: , timestamp: $timestamp)",
      );
    });
  });
}
