import "dart:typed_data";

import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/services/file_download_service/stub.dart"
    as file_download_stub;

void main() {
  group("file_download_service WebFileDownloader stub", () {
    test("openFileInNewTab throws UnsupportedError on non-web platform",
        () async {
      final Uint8List bytes = Uint8List.fromList(<int>[1, 2, 3]);

      await expectLater(
        file_download_stub.WebFileDownloader.openFileInNewTab(
          bytes,
          "sample.pdf",
          "application/pdf",
        ),
        throwsA(
          isA<UnsupportedError>().having(
            (UnsupportedError error) => error.message,
            "message",
            "openFileInNewTab is only supported on web platform",
          ),
        ),
      );
    });

    test("openFileInNewTab throws UnsupportedError for empty file bytes",
        () async {
      final Uint8List bytes = Uint8List(0);

      await expectLater(
        file_download_stub.WebFileDownloader.openFileInNewTab(
          bytes,
          "empty.txt",
          "text/plain",
        ),
        throwsA(
          isA<UnsupportedError>().having(
            (UnsupportedError error) => error.message,
            "message",
            "openFileInNewTab is only supported on web platform",
          ),
        ),
      );
    });

    test("openFileInNewTab throws UnsupportedError for different mime type",
        () async {
      final Uint8List bytes = Uint8List.fromList(<int>[10, 20, 30, 40]);

      await expectLater(
        file_download_stub.WebFileDownloader.openFileInNewTab(
          bytes,
          "image.png",
          "image/png",
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test("openFileInNewTab throws UnsupportedError for empty file name",
        () async {
      final Uint8List bytes = Uint8List.fromList(<int>[255]);

      await expectLater(
        file_download_stub.WebFileDownloader.openFileInNewTab(
          bytes,
          "",
          "application/octet-stream",
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test("openFileInNewTab throws UnsupportedError for empty mime type",
        () async {
      final Uint8List bytes = Uint8List.fromList(<int>[100]);

      await expectLater(
        file_download_stub.WebFileDownloader.openFileInNewTab(
          bytes,
          "file.bin",
          "",
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
