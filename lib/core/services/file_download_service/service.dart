import "dart:convert";
import "dart:typed_data";
import "package:dio/dio.dart";
import "package:file_picker/file_picker.dart";
import "package:file_saver/file_saver.dart";
import "package:flutter/foundation.dart" show kIsWeb;
import "package:wcas_frontend/core/services/api_service/api_manager.dart";

// Conditional imports - load web implementation on web, stub on other platforms
import "package:wcas_frontend/core/services/file_download_service/web.dart"
    if (dart.library.io) "stub.dart";

/// Service for downloading files from the server
/// This service is specifically designed for Flutter web applications
class FileDownloadService {
  FileDownloadService({
    Dio? dio,
    Future<String> Function(Uint8List bytes, String fileName)? fileSaver,
  }) : _customFileSaver = fileSaver {
    _client = dio ??
        Dio(
          BaseOptions(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status != null && status < 500;
            },
          ),
        );
  }
  late Dio _client;
  final APIManager _apiManager = APIManager.instance;
  final Future<String> Function(Uint8List bytes, String fileName)?
      _customFileSaver;

  static FileDownloadService get instance => FileDownloadService();

  /// Save file using custom FileSaver or default FileSaver.instance
  Future<String> _saveFile(Uint8List bytes, String fileName) async {
    if (_customFileSaver != null) {
      return _customFileSaver(bytes, fileName);
    }
    return FileSaver.instance.saveFile(
      name: fileName,
      bytes: bytes,
    );
  }

  /// Downloads a file from the server and triggers browser download
  ///
  /// [endpoint] - The API endpoint to download the file from
  /// [fileName] - The name to save the file as (including extension)
  /// [queryParams] - Optional query parameters for the request
  /// [additionalHeaders] - Optional additional headers for the request
  ///
  /// Returns a Future<AppResponse> with the download result
  ///
  /// Example usage:
  /// ```dart
  /// await FileDownloadService.instance.downloadFile(
  ///   '/api/documents/download',
  ///   'report.pdf',
  ///   queryParams: {'documentId': '123'},
  /// );
  /// ```
  Future<AppResponse> downloadFile(
    String endpoint,
    String fileName, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic> additionalHeaders = const {},
  }) async {
    try {
      // Make the request to download the file
      final response = await _client.get(
        endpoint,
        queryParameters: queryParams,
        options: Options(
          responseType: ResponseType.bytes,
          headers: additionalHeaders,
        ),
      );

      if (response.statusCode == 200) {
        // Get the file data as bytes
        final Uint8List bytes = Uint8List.fromList(response.data);

        // Trigger browser download using file_saver
        await _saveFile(bytes, fileName);

        return AppResponse(
          message: response.statusMessage ?? "",
          body: {"fileName": fileName, "size": bytes.length},
          code: 200,
          status: ResponseStatus.success,
        );
      } else {
        return AppResponse(
          message: "Failed to download file: ${response.statusMessage}",
          code: response.statusCode,
          status: ResponseStatus.error,
        );
      }
    } catch (e) {
      return _apiManager.handleAPIException(e);
    }
  }

  /// Opens a file in a new tab if the browser can display it, otherwise
  /// downloads it
  ///
  /// [bytes] - The file data as bytes
  /// [fileName] - The name of the file (including extension)
  ///
  /// Files that can be opened in browser (PDF, images, text, HTML, etc.) will
  /// open in a new tab.
  /// Files that cannot be displayed (DOCX, XLSX, ZIP, etc.) will be downloaded.
  ///
  /// Note: This method only works on web platforms. On non-web platforms, it
  /// will download the file.
  Future<void> openFileInNewTab(Uint8List bytes, String fileName) async {
    if (!kIsWeb) {
      // On non-web platforms, just download the file
      await _saveFile(bytes, fileName);
      return;
    }

    final mimeType = _getMimeType(fileName);
    final canOpenInBrowser = _canOpenInBrowser(fileName);

    if (canOpenInBrowser) {
      // Open in new tab using platform-specific implementation
      await WebFileDownloader.openFileInNewTab(bytes, fileName, mimeType);
    } else {
      // Download the file
      await _saveFile(bytes, fileName);
    }
  }

  /// Determines if a file type can be opened/displayed in a browser tab
  bool _canOpenInBrowser(String fileName) {
    final extension = fileName.toLowerCase().split(".").last;

    // File types that can be displayed in browser
    const viewableExtensions = {
      // Documents
      "pdf", "txt", "json", "xml", "csv",
      // Images
      "jpg", "jpeg", "png", "gif", "bmp", "webp", "svg", "ico",
      // Web files
      "html", "htm", "css", "js",
      // Media
      "mp4", "webm", "ogg", "mp3", "wav",
    };

    return viewableExtensions.contains(extension);
  }

  /// Gets the MIME type based on file extension
  String _getMimeType(String fileName) {
    final extension = fileName.toLowerCase().split(".").last;

    // Map of file extensions to MIME types
    const mimeTypes = {
      // Documents
      "pdf": "application/pdf",
      "txt": "text/plain",
      "json": "application/json",
      "xml": "application/xml",
      "csv": "text/csv",
      "html": "text/html",
      "htm": "text/html",
      "css": "text/css",
      "js": "application/javascript",

      // Images
      "jpg": "image/jpeg",
      "jpeg": "image/jpeg",
      "png": "image/png",
      "gif": "image/gif",
      "bmp": "image/bmp",
      "webp": "image/webp",
      "svg": "image/svg+xml",
      "ico": "image/x-icon",

      // Audio
      "mp3": "audio/mpeg",
      "wav": "audio/wav",
      "ogg": "audio/ogg",

      // Video
      "mp4": "video/mp4",
      "webm": "video/webm",

      // Microsoft Office formats (for download fallback)
      "doc": "application/msword",
      "docx":
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      "xls": "application/vnd.ms-excel",
      "xlsx":
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      "ppt": "application/vnd.ms-powerpoint",
      "pptx":
          "application/vnd.openxmlformats-officedocument.presentationml.presentation",

      // Archives
      "zip": "application/zip",
      "rar": "application/x-rar-compressed",
      "7z": "application/x-7z-compressed",
      "tar": "application/x-tar",
      "gz": "application/gzip",
    };

    return mimeTypes[extension] ?? "application/octet-stream";
  }

  String fileToBase64(PlatformFile file) {
    final Uint8List? bytes = file.bytes;
    return base64Encode(bytes!.toList());
  }
}
