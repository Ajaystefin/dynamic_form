import "package:test/test.dart";
import "package:wcas_frontend/models/request/project/contract_comment.dart";

void main() {
  group("ContractComment", () {
    test("constructs with provided values", () {
      // Arrange
      final now = DateTime.now();
      const message = "This is a comment";

      // Act
      final comment = ContractComment(text: message, timestamp: now);

      // Assert
      expect(comment.text, equals(message));
      expect(comment.timestamp, equals(now));
    });

    test("fields are immutable (final)", () {
      final comment = ContractComment(
        text: "immutable check",
        timestamp: DateTime(2024, 01, 01),
      );

      // Accessing fields should work
      expect(comment.text, "immutable check");
      expect(comment.timestamp, DateTime(2024, 01, 01));

      // This is a compile-time property in Dart; we can’t reassign:
      // comment.text = 'new'; // <-- would not compile.
      // So we just verify behavior through reads.
    });

    test("supports different timestamps and texts", () {
      final comment1 = ContractComment(
        text: "alpha",
        timestamp: DateTime(2023, 06, 01, 12, 30),
      );

      final comment2 = ContractComment(
        text: "beta",
        timestamp: DateTime(2023, 06, 01, 12, 31),
      );

      expect(comment1.text, "alpha");
      expect(comment2.text, "beta");
      expect(comment1.timestamp.isBefore(comment2.timestamp), isTrue);
    });
  });
}
