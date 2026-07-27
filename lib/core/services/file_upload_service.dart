import "package:file_picker/file_picker.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// File Picker Interface
///
/// Defines file picking operations for file selection implementations.
abstract class FilePickerInterface {
  /// Opens a file picker and returns the selected files.
  Future<FilePickerResult?> pickFiles({
    bool? allowMultiple,
    FileType? type,
    List<String>? allowedExtensions,
  });
}

/// Disallowed file extensions.
const List<String> disallowedExtensions = [
  "exe",
  "com",
  "bat",
  "cmd",
  "msi",
  "scr",
  "pif",
  "cpl",
  "sh",
  "bash",
  "zsh",
  "ksh",
  "jar",
  "war",
  "apk",
  "js",
  "jsx",
  "ts",
  "tsx",
  "html",
  "htm",
  "xhtml",
  "xml",
  "svg",
  "php",
  "php5",
  "php7",
  "phtml",
  "asp",
  "aspx",
  "jsp",
  "jspx",
  "py",
  "pyc",
  "rb",
  "pl",
  "cgi",
  "go",
  "cs",
  "vb",
  "class",
  "vbs",
  "wsf",
  "lnk",
  // "link",
  "iso",
  "img",
  "bin",
  "dmg",
  "torrent",
  "reg",
];

/// File Picker Implementation
///
/// Uses the FilePicker package to select files.
class FilePickerImpl implements FilePickerInterface {
  /// Opens the file picker and returns the selected files.
  @override
  Future<FilePickerResult?> pickFiles({
    bool? allowMultiple,
    FileType? type,
    List<String>? allowedExtensions,
  }) async {
    final bool multi = allowMultiple ?? false;

    // Guard: if FileType.custom is requested but allowedExtensions is empty,
    // fall back to FileType.any to avoid web errors.
    final bool customRequested = (type == FileType.custom);
    final bool hasExtensions =
        allowedExtensions != null && allowedExtensions.isNotEmpty;
    final FileType effectiveType = (customRequested && !hasExtensions)
        ? FileType.any
        : (type ?? FileType.any);

    return FilePicker.platform.pickFiles(
      allowMultiple: multi,
      type: effectiveType,
      allowedExtensions: hasExtensions ? allowedExtensions : null,
      withData: true, // critical for Web so PlatformFile.bytes is populated
      // withReadStream: true, // optional if you want streaming for huge files
    );
  }
}

/// File Upload Service
///
/// Provides file selection and validation functionality.
class FileUploadService {
  static final _singleton = FileUploadService();

  /// Returns the singleton instance.
  static FileUploadService get instance => _singleton;

  /// Maximum allowed file size in bytes (100 MB).
  static const double maxFileSize = 100 * 1024 * 1024;

  /// Validation error message.
  String errorMessage = "";

  // Dependencies for testing
  FilePickerInterface? _filePicker;

  /// Set file picker dependency for testing
  set filePicker(FilePickerInterface filePicker) {
    _filePicker = filePicker;
  }

  /// Returns the configured file picker implementation.
  FilePickerInterface get filePicker => _filePicker ?? FilePickerImpl();

  /// Opens a file picker and returns a validated single file.
  Future<PlatformFile?> pickSingleFile(List<Reference> fileType) async {
    try {
      final FilePickerResult? result = await filePicker.pickFiles(
        allowMultiple: false,
      );

      if (result != null) {
        final PlatformFile fileData = result.files.single;
        return _validateAndReturnFile(fileData, fileType);
      } else {
        return null;
      }
    } on Object {
      rethrow;
    }
  }

  /// Opens a file picker and returns selected files.
  Future<FilePickerResult?> pickFiles({
    bool? allowMultiple,
    FileType? type,
    List<String>? allowedExtensions,
  }) async {
    return FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple ?? false,
      type: type ?? FileType.any,
      allowedExtensions: allowedExtensions,
      withData: true, // <-- CRITICAL for Web so PlatformFile.bytes is populated
    );
  }

  /// Opens a file picker and returns validated multiple files.
  Future<List<PlatformFile>?> pickMultipleFiles(
    List<Reference> fileType,
  ) async {
    try {
      final FilePickerResult? result = await filePicker.pickFiles(
        allowMultiple: true,
      );

      if (result != null) {
        final List<PlatformFile> files = [];
        for (final PlatformFile element in result.files) {
          final PlatformFile? validatedFile =
              _validateAndReturnFile(element, fileType);
          if (validatedFile != null) {
            files.add(validatedFile);
          }
        }
        return files.isNotEmpty ? files : null;
      } else {
        return null;
      }
    } on Object {
      rethrow;
    }
  }

  /// Opens a custom file picker and returns a validated single file.
  Future<PlatformFile?> customPickSingleFile({
    required List<Reference> fileType,
    List<String>? allowedExtensions,
  }) async {
    try {
      final FilePickerResult? result = await filePicker.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        // allowedExtensions: allowedExtensions,
      );

      if (result != null) {
        final PlatformFile fileData = result.files.single;
        return _validateAndReturnFile(fileData, fileType);
      } else {
        return null;
      }
    } on Object {
      rethrow;
    }
  }

  /// Opens a custom file picker and returns validated multiple files.
  Future<List<PlatformFile>?> customPickMultipleFiles({
    required List<Reference> fileType,
    List<String>? allowedExtensions,
  }) async {
    try {
      final FilePickerResult? result = await filePicker.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        // allowedExtensions: allowedExtensions,
      );

      if (result != null) {
        final List<PlatformFile> files = [];
        for (final PlatformFile element in result.files) {
          final PlatformFile? validatedFile =
              _validateAndReturnFile(element, fileType);
          if (validatedFile != null) {
            files.add(validatedFile);
          }
        }
        return files.isNotEmpty ? files : null;
      } else {
        return null;
      }
    } on Object {
      rethrow;
    }
  }

  /// Validate file size and extension, return file if valid, throw exception if
  /// invalid
  PlatformFile? _validateAndReturnFile(
    PlatformFile file,
    List<Reference> fileType,
  ) {
    // Check file size
    if (file.size > maxFileSize) {
      errorMessage = "File is too large. Max size is 100 MB.";
      throw FileValidationException(errorMessage);
    }

    // Check file extension only if non allowedExtensions has values
    if (fileType.isNotEmpty) {
      final ext = file.extension?.toLowerCase();

      if (ext != null &&
          !fileType.map((e) => e.name?.toLowerCase()).contains(ext)) {
        errorMessage = "File type .$ext is not allowed.";
        throw FileValidationException(errorMessage);
      }
    }

    return file;
  }
}

/// File Validation Exception
///
/// Thrown when file validation fails.
class FileValidationException implements Exception {
  /// Creates a file validation exception.
  FileValidationException(this.message);

  /// Validation error message.
  final String message;

  @override
  String toString() => message;
}
