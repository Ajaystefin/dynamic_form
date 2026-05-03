import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/utils.dart";

import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/file_attachment/legacy_files.dart";

void main() {
  group("LegacyFiles.fromJson", () {
    // Helper: create Reference; adapt to your model (constructors,
    // immutability)
    Reference ref(int id, String name) {
      final r = Reference()
        ..id = id
        ..name = name;
      return r;
    }

    // Non-null lists required (factory uses `!` for these when calling
    // DocYearDetail)
    final documentTypes = <Reference>[ref(1, "DocType A"), ref(2, "DocType B")];
    final subTypes = <Reference>[ref(10, "SubType X"), ref(11, "SubType Y")];
    final subSubTypes = <Reference>[ref(20, "SubSubType P")];
    final subSubSubTypes = <Reference>[ref(30, "SubSubSubType M")];
    final languages = <Reference>[ref(100, "English"), ref(101, "Arabic")];

    // You might have an enum or class DocumentType; here we just use a
    // placeholder object.
    // Replace with a real instance as per your app types.
    const DocumentType? docTypeIdStub = null; // or provide a stub if needed

    test("reads cutoff from attributes and maps only year children", () {
      // Arrange
      final json = {
        "attributes": {"cutoff": "2010"},
        "children": [
          {
            "type": "year",
            "name": "2020",
            "children": [], // DocYearDetail will parse this
          },
          {
            "type": "year",
            "name": "2019",
            "children": [],
          },
          {
            "type": "legacy", // should be ignored here
            "name": "legacy bucket",
          },
          {
            "type": "file", // should be ignored here
            "name": "random file",
          },
        ],
      };

      // Act
      final model = LegacyFiles.fromJson(
        json,
        docTypeIdStub,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      // Assert
      expect(model.cutoff, "2010");
      expect(model.docType, docTypeIdStub);

      // Only year children are mapped
      expect(model.years, isNotNull);
      expect(model.years!.length, 2);
      expect(model.years![0].docYear, 2020);
      expect(model.years![1].docYear, 2019);
    });

    test("handles numeric cutoff by converting to string", () {
      // Arrange
      final json = {
        "attributes": {"cutoff": 2005},
        "children": [],
      };

      // Act
      final model = LegacyFiles.fromJson(
        json,
        docTypeIdStub,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      // Assert
      expect(model.cutoff, "2005"); // uses .toString()
      expect(model.years, isEmpty);
    });

    test(
        "attributes missing -> cutoff is null; children missing -> years empty",
        () {
      // Arrange: no attributes, no children
      final json = <String, dynamic>{};

      // Act
      final model = LegacyFiles.fromJson(
        json,
        docTypeIdStub,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      // Assert
      expect(model.cutoff, isNull);
      expect(model.years, isNotNull);
      expect(model.years, isEmpty);
      expect(model.docType, docTypeIdStub);
    });

    test("children present but none are type=year -> years empty", () {
      // Arrange
      final json = {
        "attributes": {"cutoff": "2000"},
        "children": [
          {"type": "file", "name": "x"},
          {"type": "legacy", "name": "y"},
        ],
      };

      // Act
      final model = LegacyFiles.fromJson(
        json,
        docTypeIdStub,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      // Assert
      expect(model.cutoff, "2000");
      expect(model.years, isEmpty);
    });

    test(
      "defensive: children is not a List -> current code will cast error",
      () {
        // Arrange: children is a map, not a list

        // Act & Assert
        // Current implementation does:
        //   final children = json['children'] as List<dynamic>? ?? [];
        // which will throw if not a List. We document this defensive case.
      },
      skip: "Current implementation expects children to be"
          " List<dynamic>; this documents the behavior.",
    );

    test(
      "non-null reference "
      "lists required due to "
      "non-null assertions in nested fromJson calls",
      () {
        // Arrange

        // Act & Assert
        // Passing null for the lists will throw due to `documentTypes!` etc in
        // nested calls.
        // This test documents the requirement rather than executing a failing
        // case.
      },
      skip: "Pass non-null reference lists; nested "
          "code uses `!` (non-null assertions).",
    );
  });
}
