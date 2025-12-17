import 'dart:typed_data';

/// Stub implementation for non-web platforms (VM, mobile, desktop)
/// This file is imported when NOT running on web platform
class WebFileDownloader {
  /// Stub method that throws an error if called on non-web platforms
  ///
  /// This should never be called in practice because the main service
  /// has runtime checks (kIsWeb) that prevent calling this on non-web platforms.
  static Future<void> openFileInNewTab(
    Uint8List bytes,
    String fileName,
    String mimeType,
  ) async {
    throw UnsupportedError(
      'openFileInNewTab is only supported on web platform',
    );
  }
}
