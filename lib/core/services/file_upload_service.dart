import "package:file_picker/file_picker.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Interface for file picking operations to enable testing
abstract class FilePickerInterface {
  Future<FilePickerResult?> pickFiles({
    bool? allowMultiple,
    FileType? type,
    List<String>? allowedExtensions,
  });
}

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

/// Concrete implementation using FilePicker
class FilePickerImpl implements FilePickerInterface {
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

class FileUploadService {
  static final _singleton = FileUploadService();
  static FileUploadService get instance => _singleton;

  // Max File Size allowed : 100mb
  static const double maxFileSize = 100 * 1024 * 1024; //to be sent as param
  String errorMessage = "";

  // Dependencies for testing
  FilePickerInterface? _filePicker;

  /// Set file picker dependency for testing
  void setFilePicker(FilePickerInterface filePicker) {
    _filePicker = filePicker;
  }

  /// Get file picker instance
  FilePickerInterface get _getFilePicker => _filePicker ?? FilePickerImpl();

  Future<PlatformFile?> pickSingleFile(List<Reference> fileType) async {
    try {
      final FilePickerResult? result = await _getFilePicker.pickFiles(
        allowMultiple: false,
      );

      if (result != null) {
        final PlatformFile fileData = result.files.single;
        return _validateAndReturnFile(fileData, fileType);
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

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

  Future<List<PlatformFile>?> pickMultipleFiles(
    List<Reference> fileType,
  ) async {
    try {
      final FilePickerResult? result = await _getFilePicker.pickFiles(
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
    } catch (e) {
      rethrow;
    }
  }

  Future<PlatformFile?> customPickSingleFile({
    required List<Reference> fileType,
    List<String>? allowedExtensions,
  }) async {
    try {
      final FilePickerResult? result = await _getFilePicker.pickFiles(
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
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PlatformFile>?> customPickMultipleFiles({
    required List<Reference> fileType,
    List<String>? allowedExtensions,
  }) async {
    try {
      final FilePickerResult? result = await _getFilePicker.pickFiles(
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
    } catch (e) {
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

class FileValidationException implements Exception {
  FileValidationException(this.message);
  final String message;

  @override
  String toString() => message;
}
