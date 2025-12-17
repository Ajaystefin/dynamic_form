import 'package:file_picker/file_picker.dart';

/// Interface for file picking operations to enable testing
abstract class FilePickerInterface {
  Future<FilePickerResult?> pickFiles({
    bool? allowMultiple,
    FileType? type,
    List<String>? allowedExtensions,
  });
}

List<String>? disallowedExtensions = [
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
  "iso",
  "img",
  "bin",
  "dmg",
  "torrent",
  "reg"
];

/// Concrete implementation using FilePicker
class FilePickerImpl implements FilePickerInterface {
  @override
  Future<FilePickerResult?> pickFiles({
    bool? allowMultiple,
    FileType? type,
    List<String>? allowedExtensions,
  }) async {
    return await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple ?? false,
      type: type ?? FileType.any,
      // allowedExtensions: allowedExtensions
    );
  }
}

class FileUploadService {
  static final _singleton = FileUploadService();
  static FileUploadService get instance => _singleton;

  // Max File Size allowed : 100mb
  static const double maxFileSize = 100 * 1024 * 1024; //to be sent as param
  String errorMessage = '';

  // Dependencies for testing
  FilePickerInterface? _filePicker;

  /// Set file picker dependency for testing
  void setFilePicker(FilePickerInterface filePicker) {
    _filePicker = filePicker;
  }

  /// Get file picker instance
  FilePickerInterface get _getFilePicker => _filePicker ?? FilePickerImpl();

  Future<PlatformFile?> pickSingleFile() async {
    try {
      FilePickerResult? result = await _getFilePicker.pickFiles(
        allowMultiple: false,
      );

      if (result != null) {
        PlatformFile fileData = result.files.single;
        return _validateAndReturnFile(fileData);
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PlatformFile>?> pickMultipleFiles() async {
    try {
      FilePickerResult? result = await _getFilePicker.pickFiles(
        allowMultiple: true,
      );

      if (result != null) {
        List<PlatformFile> files = [];
        for (PlatformFile element in result.files) {
          PlatformFile? validatedFile = _validateAndReturnFile(element);
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

  Future<PlatformFile?> customPickSingleFile(
      {List<String>? allowedExtensions}) async {
    try {
      FilePickerResult? result = await _getFilePicker.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        // allowedExtensions: allowedExtensions,
      );

      if (result != null) {
        PlatformFile fileData = result.files.single;
        return _validateAndReturnFile(fileData);
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PlatformFile>?> customPickMultipleFiles(
      {List<String>? allowedExtensions}) async {
    try {
      FilePickerResult? result = await _getFilePicker.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        // allowedExtensions: allowedExtensions,
      );

      if (result != null) {
        List<PlatformFile> files = [];
        for (PlatformFile element in result.files) {
          PlatformFile? validatedFile = _validateAndReturnFile(element);
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

  /// Validate file size and extension, return file if valid, throw exception if invalid
  PlatformFile? _validateAndReturnFile(PlatformFile file) {
    // Check file size
    if (file.size > maxFileSize) {
      errorMessage = "File is too large. Max size is 100 MB.";
      throw FileValidationException(errorMessage);
    }

    // Check file extension if allowedExtensions is not empty
    if (disallowedExtensions!.isNotEmpty) {
      String? extension = file.extension?.toLowerCase();
      if (extension != null && disallowedExtensions!.contains(extension)) {
        errorMessage = "File type .$extension is not allowed.";
        throw FileValidationException(errorMessage);
      }
    }

    return file;
  }
}

class FileValidationException implements Exception {
  final String message;

  FileValidationException(this.message);

  @override
  String toString() => message; 
}
