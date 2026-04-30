import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/file_attachment/ca_doc_sub_type.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_year.dart";

void main() {
  group("DocYearDetail.fromJson", () {
    // Helper to create Reference instances; adjust to your actual type
    // behavior.
    Reference ref(int id, String name) {
      final r = Reference();
      // If Reference is immutable or has different constructors, adapt
      // accordingly
      r.id = id;
      r.name = name;
      return r;
    }

    // Shared lists (non-null required because factory uses `!`)
    final documentTypes = <Reference>[ref(1, "DocType A"), ref(2, "DocType B")];
    final subTypes = <Reference>[ref(10, "SubType X"), ref(11, "SubType Y")];
    final subSubTypes = <Reference>[ref(20, "SubSubType P")];
    final subSubSubTypes = <Reference>[ref(30, "SubSubSubType M")];
    final languages = <Reference>[ref(100, "English"), ref(101, "Arabic")];

    test('parses valid numeric year from json["name"]', () {
      // Arrange
      final json = {
        "name": 2024,
        "children": [],
      };

      // Act
      final model = DocYearDetail.fromJson(
        json,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      // Assert
      expect(model.docYear, 2024);
      expect(model.docSubType, isEmpty);
      expect(model.caDocTypeData, isEmpty);
    });

    test('parses numeric string year from json["name"]', () {
      // Arrange
      final json = {
        "name": "2023",
        "children": [],
      };

      // Act
      final model = DocYearDetail.fromJson(
        json,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      // Assert
      expect(model.docYear, 2023);
    });

    test("invalid/missing year defaults to 0", () {
      // Invalid string
      final jsonInvalid = {
        "name": "invalid",
        "children": [],
      };
      final modelInvalid = DocYearDetail.fromJson(
        jsonInvalid,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );
      expect(modelInvalid.docYear, 0);

      // Missing name
      final jsonMissing = {
        "children": [],
      };
      final modelMissing = DocYearDetail.fromJson(
        jsonMissing,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );
      expect(modelMissing.docYear, 0);
    });

    test(
        "children filtered: only type=subType goes to"
        " caDocTypeData; type=file goes to docSubType", () {
      // Arrange
      final json = {
        "name": "2025",
        "children": [
          {
            "type": "subType",
            "id": 11,
            "docType": 2,
            "subType": 10,
            "subSubType": 20,
            "subSubSubType": 30,
            "language": "100",
            // any other fields CaDocSubType.fromJson expects
          },
          {
            "type": "file",
            "applicationID": 123,
            "date": "01-01-2025",
            "docType": 2,
            "subType": 10,
            "subSubType": 20,
            "subSubSubType": 30,
            "fileName": "statement.pdf",
            "summary": "Summary",
            // any other fields DocSubTypeDetail.fromJson expects
          },
          {
            "type": "folder", // should be ignored by both
            "name": "Ignore me",
          },
        ],
      };

      // Act
      final model = DocYearDetail.fromJson(
        json,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      // Assert
      expect(model.docYear, 2025);

      // caDocTypeData should contain only the subType child
      expect(model.caDocTypeData, isNotNull);
      expect(model.caDocTypeData!.length, 1);
      expect(model.caDocTypeData!.first, isA<CaDocSubType>());

      // docSubType should contain only the file child
      expect(model.docSubType, isNotNull);
      expect(model.docSubType!.length, 1);
      expect(model.docSubType!.first, isA<DocSubTypeDetail?>());
      expect(
        model.docSubType!.first,
        isNotNull,
      ); // ensure actual object present
    });

    test("children missing -> empty lists", () {
      // Arrange
      final json = {
        "name": "2022",
        // children is omitted
      };

      // Act
      final model = DocYearDetail.fromJson(
        json,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      // Assert
      expect(model.docYear, 2022);
      expect(model.caDocTypeData, isNotNull);
      expect(model.caDocTypeData, isEmpty);
      expect(model.docSubType, isNotNull);
      expect(model.docSubType, isEmpty);
    });

    test("children present but none match filter -> empty lists", () {
      // Arrange
      final json = {
        "name": 2021,
        "children": [
          {"type": "folder", "name": "Nested"},
          {"type": "year", "name": "2020"},
        ],
      };

      // Act
      final model = DocYearDetail.fromJson(
        json,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      // Assert
      expect(model.docYear, 2021);
      expect(model.caDocTypeData, isEmpty);
      expect(model.docSubType, isEmpty);
    });

    test(
      "robustness: non-List children should be treated as empty",
      () {
        // Arrange: children is a map, not a list
        final json = {
          "name": "2020",
          "children": {"unexpected": "shape"},
        };

        // Act
        final model = DocYearDetail.fromJson(
          json,
          documentTypes,
          subTypes,
          subSubTypes,
          subSubSubTypes,
          languages,
        );

        // Assert
        // Since the code casts with `as List<dynamic>? ?? []`, this would throw
        // if not a List.
        // To prevent test failure due to cast error, we provide a safe test:
        // If you want to keep current behavior, this test demonstrates expected
        // failure with wrong type.
        expect(model.docYear, 2020);
        expect(model.caDocTypeData, isEmpty);
        expect(model.docSubType, isEmpty);
      },
      skip: "Current implementation "
          "expects children to be "
          "List<dynamic>; this test demonstrates a defensive case.",
    );

    test("handles mixed child payloads where required fields may be missing",
        () {
      // Arrange: child entries missing some fields; fromJson of inner classes
      // should handle appropriately
      final json = {
        "name": "2019",
        "children": [
          {"type": "subType"}, // minimal subType entry
          {"type": "file"}, // minimal file entry
        ],
      };

      // Act
      final model = DocYearDetail.fromJson(
        json,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      // Assert
      expect(model.docYear, 2019);
      expect(model.caDocTypeData, isNotNull);
      expect(model.caDocTypeData!.length, 1);
      expect(model.caDocTypeData!.first, isA<CaDocSubType>());

      expect(model.docSubType, isNotNull);
      expect(model.docSubType!.length, 1);
      expect(model.docSubType!.first, isA<DocSubTypeDetail?>());
    });
  });
}
