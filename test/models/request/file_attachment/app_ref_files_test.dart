import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/file_attachment/app_ref_files.dart";

void main() {
  group("AppRefFiles.fromJson", () {
    test("should map file children to DocSubTypeDetail list", () {
      final json = <String, dynamic>{
        "name": "APP-123",
        "children": [
          {
            "type": "file",
            "name": "Document 1",
            "id": 1,
          },
          {
            "type": "folder",
            "name": "Folder 1",
          },
          {
            "type": "file",
            "name": "Document 2",
            "id": 2,
          },
        ],
      };

      final result = AppRefFiles.fromJson(
        json,
        null,
        null,
        null,
        null,
        null,
      );

      expect(result.appRefNo, "APP-123");
      expect(result.docSubType, isNotNull);
      expect(result.docSubType!.length, 2);
    });

    test("should use empty list when children is null", () {
      final json = <String, dynamic>{
        "name": "APP-123",
      };

      final result = AppRefFiles.fromJson(
        json,
        null,
        null,
        null,
        null,
        null,
      );

      expect(result.appRefNo, "APP-123");
      expect(result.docSubType, isEmpty);
    });

    test("should default appRefNo to 0 when name is null", () {
      final json = <String, dynamic>{
        "name": null,
        "children": [],
      };

      final result = AppRefFiles.fromJson(
        json,
        null,
        null,
        null,
        null,
        null,
      );

      expect(result.appRefNo, "0");
      expect(result.docSubType, isEmpty);
    });

    test("should only include children with type file", () {
      final json = <String, dynamic>{
        "name": "APP-123",
        "children": [
          {"type": "folder"},
          {"type": "document"},
          {
            "type": "file",
            "name": "Valid File",
            "id": 1,
          },
        ],
      };

      final result = AppRefFiles.fromJson(
        json,
        null,
        null,
        null,
        null,
        null,
      );

      expect(result.docSubType!.length, 1);
    });
  });
}
