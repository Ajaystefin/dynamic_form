import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/file_attachment/ca_doc_category.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type.dart";

void main() {
  group("CaDocCategory.fromJson", () {
    test("creates CaDocCategory from json and filters only file children", () {
      // Arrange
      final json = {
        "name": "Credit Application",
        "children": [
          {
            "type": "file",
            "id": 1,
            "name": "Test File 1",
          },
          {
            "type": "folder",
            "id": 2,
            "name": "Ignored Folder",
          },
          {
            "type": "file",
            "id": 3,
            "name": "Test File 2",
          },
        ],
      };

      final documentTypes = <Reference>[];
      final subTypes = <Reference>[];
      final subSubTypes = <Reference>[];
      final subSubSubTypes = <Reference>[];
      final languages = <Reference>[];

      // Act
      final result = CaDocCategory.fromJson(
        json,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      // Assert
      expect(result.categoryName, equals("Credit Application"));
      expect(result.docSubType, isNotNull);
      expect(result.docSubType!.length, equals(2));
      expect(result.docSubType, everyElement(isA<DocSubTypeDetail>()));
    });

    test("creates empty docSubType list when no file children exist", () {
      // Arrange
      final json = {
        "name": "Empty Category",
        "children": [
          {"type": "folder", "id": 1},
          {"type": "image", "id": 2},
        ],
      };

      // Act
      final result = CaDocCategory.fromJson(
        json,
        [],
        [],
        [],
        [],
        [],
      );

      // Assert
      expect(result.categoryName, "Empty Category");
      expect(result.docSubType, isEmpty);
    });

    test("handles missing children field gracefully", () {
      // Arrange
      final json = {
        "name": "No Children Category",
      };

      // Act
      final result = CaDocCategory.fromJson(
        json,
        [],
        [],
        [],
        [],
        [],
      );

      // Assert
      expect(result.categoryName, "No Children Category");
      expect(result.docSubType, isEmpty);
    });
  });
}
