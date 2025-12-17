import 'package:easy_localization/easy_localization.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

// Abstract interfaces for dependency injection
abstract class FilePickerService {
  Future<FilePickerResult?> pickFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool withData = false,
  });
}

abstract class ExcelService {
  Excel decodeBytes(List<int> bytes);
}

// Default implementations
class DefaultFilePickerService implements FilePickerService {
  @override
  Future<FilePickerResult?> pickFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool withData = false,
  }) {
    return FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: allowedExtensions,
      withData: withData,
    );
  }
}

class DefaultExcelService implements ExcelService {
  @override
  Excel decodeBytes(List<int> bytes) {
    return Excel.decodeBytes(bytes);
  }
}

class ExcelParser {
  final FilePickerService _filePickerService;
  final ExcelService _excelService;

  ExcelParser({
    FilePickerService? filePickerService,
    ExcelService? excelService,
  })  : _filePickerService = filePickerService ?? DefaultFilePickerService(),
        _excelService = excelService ?? DefaultExcelService();

  // Static method for backward compatibility
  static Future<Map<String, String>> parseExcelValues(
      Map<String, String> cellPaths) async {
    final parser = ExcelParser();
    return parser.parseExcelValuesWithServices(cellPaths);
  }

  // Instance method that can be properly tested
  Future<Map<String, String>> parseExcelValuesWithServices(
      Map<String, String> cellPaths) async {
    // Open file picker
    final result = await _filePickerService.pickFiles(
        type: FileType.custom, allowedExtensions: ['xlsx'], withData: true);
    if (result == null || result.files.isEmpty) {
      throw "excelParser.fileError".tr();
    }

    final fileBytes = result.files.single.bytes;
    final excel = _excelService.decodeBytes(fileBytes!);

    final Map<String, String> output = {};

    final sheet = excel.tables.keys.first;
    final table = excel.tables[sheet];
    if (table == null) {
      throw "excelParser.fileError".tr();
    }

    for (MapEntry<String, String> entry in cellPaths.entries) {
      try {
        String cellAddress = entry.value.toUpperCase();

        String columnLetter = cellAddress.substring(0, 1);
        int rowNumber = int.parse(cellAddress.substring(1));

        int colIndex = columnLetter.codeUnitAt(0) - 'A'.codeUnitAt(0);
        int rowIndex = rowNumber - 1;

        Data cell = table.rows[rowIndex][colIndex]!;
        output[entry.key] = cell.value!.toString();
      } catch (e) {
        throw "${"excelParser.parseError".tr()} ${entry.key}";
      }
    }

    return output;
  }
}
