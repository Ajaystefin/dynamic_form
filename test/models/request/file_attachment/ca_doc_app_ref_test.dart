import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/file_attachment/ca_doc_app_ref.dart";
import "package:wcas_frontend/models/request/file_attachment/ca_doc_category.dart";

void main() {
  group("CaDocAppRef.fromJson", () {
    test("creates CaDocAppRef from json and filters only category children",
        () {
      // Arrange
      final json = {
        "name": "202603FULLAR00733",
        "children": [
          {
            "type": "category",
            "name": "Category 1",
            "children": [],
          },
          {
            "type": "file",
            "name": "Ignored File",
          },
          {
            "type": "category",
            "name": "Category 2",
            "children": [],
          },
        ],
      };

      final documentTypes = <Reference>[];
      final subTypes = <Reference>[];
      final subSubTypes = <Reference>[];
      final subSubSubTypes = <Reference>[];
      final languages = <Reference>[];

      // Act
      final result = CaDocAppRef.fromJson(
        json,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      // Assert
      expect(result.appRefNo, equals("202603FULLAR00733"));
      expect(result.caDocCategory, isNotNull);
      expect(result.caDocCategory!.length, equals(2));
      expect(result.caDocCategory, everyElement(isA<CaDocCategory>()));
    });

    test("creates empty category list when no category children exist", () {
      // Arrange
      final json = {
        "name": "APP_NO_CATEGORY",
        "children": [
          {"type": "file", "name": "File 1"},
          {"type": "folder", "name": "Folder 1"},
        ],
      };

      // Act
      final result = CaDocAppRef.fromJson(
        json,
        [],
        [],
        [],
        [],
        [],
      );

      // Assert
      expect(result.appRefNo, equals("APP_NO_CATEGORY"));
      expect(result.caDocCategory, isEmpty);
    });

    test("handles missing children field gracefully", () {
      // Arrange
      final json = {
        "name": "APP_WITHOUT_CHILDREN",
      };

      // Act
      final result = CaDocAppRef.fromJson(
        json,
        [],
        [],
        [],
        [],
        [],
      );

      // Assert
      expect(result.appRefNo, equals("APP_WITHOUT_CHILDREN"));
      expect(result.caDocCategory, isEmpty);
    });
  });
}
