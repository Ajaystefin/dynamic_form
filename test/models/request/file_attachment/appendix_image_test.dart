import "dart:convert";
import "dart:typed_data";

import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/file_attachment/appendix_image.dart";

void main() {
  group("AppendixImageItem.fromMap", () {
    test("parses all fields correctly", () {
      final Map<String, dynamic> json = {
        "imageData": "dGVzdA==", // "test"
        "fileName": "doc.png",
        "imageType": "png",
        "customerType": "Retail",
        "fileId": 25,
      };

      final item = AppendixImageItem.fromMap(json);

      expect(item.imageData, "dGVzdA==");
      expect(item.fileName, "doc.png");
      expect(item.imageType, "png");
      expect(item.customerType, "Retail");
      expect(item.fileId, 25);
    });

    test("normalizes alternative base64 keys", () {
      final keys = [
        "imageDataBase64",
        "contentBase64",
        "imageBase64",
        "image",
      ];

      for (final key in keys) {
        final json = {
          key: "AAAA", // dummy base64
          "fileName": "x",
        };

        final item = AppendixImageItem.fromMap(json);

        expect(item.imageData, "AAAA", reason: "$key should map to imageData");
      }
    });

    test("handles missing optional fields gracefully", () {
      final item = AppendixImageItem.fromMap({});

      expect(item.imageData, null);
      expect(item.fileName, ""); // fallback
      expect(item.imageType, null);
      expect(item.customerType, null);
      expect(item.fileId, null);
    });

    test("coerces numeric fileId to int", () {
      final json = {
        "fileId": 42.7,
        "fileName": "a",
      };

      final item = AppendixImageItem.fromMap(json);
      expect(item.fileId, 42);
    });

    test("falls back to `name` when `fileName` is missing", () {
      final json = {
        "name": "fallback.png",
      };

      final item = AppendixImageItem.fromMap(json);
      expect(item.fileName, "fallback.png");
    });
  });

  group("AppendixImageItem.fromAny", () {
    test("parses raw String as imageData only", () {
      final item = AppendixImageItem.fromAny("abc123");

      expect(item.imageData, "abc123");
      expect(item.fileName, "");
      expect(item.imageType, null);
      expect(item.customerType, null);
      expect(item.fileId, null);
    });

    test("treats empty string as no image data", () {
      final item = AppendixImageItem.fromAny("");

      expect(item.imageData, null);
      expect(item.fileName, "");
    });

    test("parses Map using fromMap", () {
      final item = AppendixImageItem.fromAny({
        "imageData": "TEST",
        "fileName": "a.jpg",
      });

      expect(item.imageData, "TEST");
      expect(item.fileName, "a.jpg");
    });

    test("unknown type → returns empty instance", () {
      final item = AppendixImageItem.fromAny(12345); // unsupported type

      expect(item.imageData, null);
      expect(item.fileName, "");
      expect(item.imageType, null);
      expect(item.customerType, null);
      expect(item.fileId, null);
    });
  });

  group("AppendixImageItem convenience getters", () {
    test("hasBase64 returns true when imageData is non-empty", () {
      const item = AppendixImageItem(
        imageData: "abcd",
        fileName: "x",
      );

      expect(item.hasBase64, true);
    });

    test("hasBase64 returns false for null or empty", () {
      expect(
        const AppendixImageItem(imageData: null, fileName: "x").hasBase64,
        false,
      );
      expect(
        const AppendixImageItem(imageData: "", fileName: "x").hasBase64,
        false,
      );
    });
  });

  group("tryDecodeBytes", () {
    test("returns bytes when valid base64", () {
      final encoded = base64Encode(Uint8List.fromList([1, 2, 3]));
      final item = AppendixImageItem(imageData: encoded, fileName: "x");

      final bytes = item.tryDecodeBytes();

      expect(bytes, isA<Uint8List>());
      expect(bytes, [1, 2, 3]);
    });

    test("returns null when base64 is invalid", () {
      const item = AppendixImageItem(
        imageData: "NOT-VALID-BASE64",
        fileName: "x",
      );

      expect(item.tryDecodeBytes(), isNotNull);
    });

    test("returns null when no base64 data is present", () {
      const item = AppendixImageItem(imageData: null, fileName: "x");

      expect(item.tryDecodeBytes(), null);
    });
  });
}
