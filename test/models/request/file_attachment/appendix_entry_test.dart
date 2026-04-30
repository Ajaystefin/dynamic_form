import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/file_attachment/appendix_entry.dart";

void main() {
  group("AppendixEntry", () {
    test("should create instance with required id", () {
      final entry = AppendixEntry(id: "1");

      expect(entry.id, "1");
      expect(entry.label, "");
      expect(entry.value, "");
    });

    test("should create instance with all parameters", () {
      final entry = AppendixEntry(
        id: "1",
        label: "Test Label",
        value: "Test Value",
      );

      expect(entry.id, "1");
      expect(entry.label, "Test Label");
      expect(entry.value, "Test Value");
    });

    test("copyWith should update label", () {
      final entry = AppendixEntry(id: "1", label: "Old Label", value: "Value");
      final updated = entry.copyWith(label: "New Label");

      expect(updated.id, "1");
      expect(updated.label, "New Label");
      expect(updated.value, "Value");
    });

    test("copyWith should update value", () {
      final entry = AppendixEntry(id: "1", label: "Label", value: "Old Value");
      final updated = entry.copyWith(value: "New Value");

      expect(updated.id, "1");
      expect(updated.label, "Label");
      expect(updated.value, "New Value");
    });

    test("copyWith should update both label and value", () {
      final entry =
          AppendixEntry(id: "1", label: "Old Label", value: "Old Value");
      final updated = entry.copyWith(label: "New Label", value: "New Value");

      expect(updated.id, "1");
      expect(updated.label, "New Label");
      expect(updated.value, "New Value");
    });

    test(
        "copyWith should return new instance with same"
        " values when no parameters provided", () {
      final entry = AppendixEntry(id: "1", label: "Label", value: "Value");
      final updated = entry.copyWith();

      expect(updated.id, "1");
      expect(updated.label, "Label");
      expect(updated.value, "Value");
    });

    test("copyWith preserves id", () {
      final entry =
          AppendixEntry(id: "unique-id", label: "Label", value: "Value");
      final updated = entry.copyWith(label: "New Label");

      expect(updated.id, "unique-id");
    });
  });
}
