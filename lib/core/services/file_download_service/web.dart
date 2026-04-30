import "dart:js_interop";
import "dart:typed_data";
import "package:web/web.dart" as web;

/// Web-specific implementation for opening files in new browser tabs
/// This file is only imported when running on web platform
class WebFileDownloader {
  /// Opens a file in a new browser tab using web APIs
  ///
  /// [bytes] - The file data as bytes
  /// [fileName] - The name of the file (for reference, not used in this
  /// implementation)
  /// [mimeType] - The MIME type of the file (e.g., 'application/pdf', 'image/png')
  static Future<void> openFileInNewTab(
    Uint8List bytes,
    String fileName,
    String mimeType,
  ) async {
    // Create a Blob from the bytes with the appropriate MIME type
    final blob =
        web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mimeType));

    // Create an object URL for the blob
    final url = web.URL.createObjectURL(blob);

    // Open the URL in a new tab
    web.window.open(url, "_blank");

    // Clean up the object URL to free memory
    web.URL.revokeObjectURL(url);
  }
}
