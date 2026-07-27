import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/request/file_attachment/legacy_files.dart";

void main() {
  group("LegacyFiles.fromJson", () {
    test("should populate cutoff from attributes", () {
      final result = LegacyFiles.fromJson(
        {
          "attributes": {
            "cutoff": "2024",
          },
          "children": [],
        },
        null,
        null,
        null,
        null,
        null,
        null,
      );

      expect(result.cutoff, "2024");
    });

    test("should convert cutoff to string", () {
      final result = LegacyFiles.fromJson(
        {
          "attributes": {
            "cutoff": 2024,
          },
          "children": [],
        },
        null,
        null,
        null,
        null,
        null,
        null,
      );

      expect(result.cutoff, "2024");
    });

    test("should return null cutoff when attributes is null", () {
      final result = LegacyFiles.fromJson(
        {
          "children": [],
        },
        null,
        null,
        null,
        null,
        null,
        null,
      );

      expect(result.cutoff, isNull);
    });

    test("should map only appRefNo children to apps", () {
      final result = LegacyFiles.fromJson(
        {
          "children": [
            {
              "type": "appRefNo",
              "name": "APP001",
              "children": [],
            },
            {
              "type": "year",
              "name": "2024",
              "children": [],
            },
            {
              "type": "folder",
              "name": "Folder",
            },
          ],
        },
        null,
        null,
        null,
        null,
        null,
        null,
      );

      expect(result.apps, isNotNull);
      expect((result.apps as List).length, 1);
    });

    test("should map only year children to years", () {
      final result = LegacyFiles.fromJson(
        {
          "children": [
            {
              "type": "year",
              "name": "2024",
              "children": [],
            },
            {
              "type": "year",
              "name": "2025",
              "children": [],
            },
            {
              "type": "appRefNo",
              "name": "APP001",
              "children": [],
            },
          ],
        },
        null,
        null,
        null,
        null,
        null,
        null,
      );

      expect(result.years, isNotNull);
      expect(result.years!.length, 2);
    });

    test("should use empty lists when children is null", () {
      final result = LegacyFiles.fromJson(
        {},
        null,
        null,
        null,
        null,
        null,
        null,
      );

      expect(result.apps, isEmpty);
      expect(result.years, isEmpty);
    });

    test("should assign provided document type", () {
      const docType = DocumentType.creditApplication;

      final result = LegacyFiles.fromJson(
        {
          "children": [],
        },
        docType,
        null,
        null,
        null,
        null,
        null,
      );

      expect(result.docType, docType);
    });

    test(
        "should create empty apps and years when no matching child types exist",
        () {
      final result = LegacyFiles.fromJson(
        {
          "children": [
            {"type": "folder"},
            {"type": "file"},
            {"type": "other"},
          ],
        },
        null,
        null,
        null,
        null,
        null,
        null,
      );

      expect(result.apps, isEmpty);
      expect(result.years, isEmpty);
    });
  });
}
