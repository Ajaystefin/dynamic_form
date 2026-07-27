import "package:file_picker/file_picker.dart";

import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/models/request/file_attachment/appendix_entry.dart";

/// ---------------------------------------------------------------------------
/// BASIC & EASY: Appendix (Country Overview + Attachments)
/// ---------------------------------------------------------------------------

/// Represents appendix information including country overview,
/// attachments, and related business segment data.
class Appendix {
  /// Creates an [Appendix] instance.
  Appendix({
    this.groupCorporateStructure = "",
    List<AppendixEntry> entries = const [],
    List<PlatformFile> files = const [],
    this.countryName,
    this.rating,
    this.populationText = "",
    this.gdpText = "",
    List<String> exportPartners = const [],
    List<String> importPartners = const [],
    List<String> strengths = const [],
    List<String> threats = const [],
    this.ratingBarImage,
    this.countryMapImage,
    this.governmentIndicatorsImage,
  })  : entries = List<AppendixEntry>.of(entries),
        files = List<PlatformFile>.of(files),
        exportPartners = List<String>.of(exportPartners),
        importPartners = List<String>.of(importPartners),
        strengths = List<String>.of(strengths),
        threats = List<String>.of(threats);

  /// Creates an [Appendix] instance from a JSON map.
  factory Appendix.fromJson(Map<String, dynamic> json) {
    // Local inline splitter: accepts List or CSV String (comma-separated).
    List<String> readList(value) {
      if (value == null) {
        return <String>[];
      }
      if (value is List) {
        return value
            .whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      final String text = value.toString();
      if (text.trim().isEmpty) {
        return <String>[];
      }
      return text
          .split(",")
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return Appendix(
      countryName: json["countryName"] as String?,
      rating: json["rating"] as String?,
      // Backend may send numeric. UI text fields expect Strings.
      populationText: json["populationText"]?.toString() ??
          json["population"]?.toString() ??
          "",
      gdpText: json["gdpText"]?.toString() ?? json["gdp"]?.toString() ?? "",
      importPartners: readList(json["importPartners"]),
      exportPartners: readList(json["exportPartners"]),
      strengths: readList(json["strengths"]),
      threats: readList(json["threats"]),
    );
  }

  // -------------------------------------------------------------------------
  // Legacy helpers (kept for repository compatibility)
  // -------------------------------------------------------------------------

  /// Creates an [Appendix] instance from a country overview JSON map.
  factory Appendix.fromCountryOverViewJson(Map<String, dynamic> json) {
    return Appendix.fromJson(json);
  }

  /// Creates an [Appendix] instance from a flat JSON map.
  factory Appendix.fromFlatJson(Map<String, dynamic> json) {
    final Object? nested = json["countryOverView"];
    if (nested is Map) {
      return Appendix.fromJson(nested.cast<String, dynamic>());
    }
    return Appendix.fromJson(json);
  }

  /// Group corporate structure.
  String groupCorporateStructure;

  /// Appendix entries.
  List<AppendixEntry> entries;

  /// Attached files.
  List<PlatformFile> files;

  /// Country name.
  String? countryName;

  /// Country rating.
  String? rating;

  /// Population text.
  String populationText;

  /// GDP text.
  String gdpText;

  /// Export partners.
  List<String> exportPartners;

  /// Import partners.
  List<String> importPartners;

  /// Strengths.
  List<String> strengths;

  /// Threats.
  List<String> threats;

  /// Rating bar image.
  PlatformFile? ratingBarImage;

  /// Country map image.
  PlatformFile? countryMapImage;

  /// Government indicators image.
  PlatformFile? governmentIndicatorsImage;

  /// Converts country overview data to a JSON map.
  Map<String, dynamic> toCountryOverviewJson({String? ratingOverride}) {
    return {
      "countryName": countryName ?? "",
      "popuLation": int.tryParse(populationText) ?? 0, // legacy server key
      "gdp": double.tryParse(gdpText) ?? 0.0,
      "rating": ratingOverride ?? rating ?? "",
      "importPartners": importPartners,
      "exportPartners": exportPartners,
      "strengths": strengths,
      "threats": threats,
    };
  }

  /// Converts appendix data to a business segment request payload.
  Map<String, dynamic> toBusinessSegmentRequestItem({
    required String appRefNo,
    required int rimNo,
    String businessSegement = ServerConstants.corporate,
    String customerType = ServerConstants.country,
    String? appendexRemarks,
    String? categoryId,
    String? createdBy,
    DateTime? createdDate,
    String? updatedBy,
    DateTime? updatedDate,
    String? ratingOverride,
  }) {
    return {
      "appRefNo": appRefNo,
      "businessSegment": businessSegement,
      "customerType": customerType,
      "rimNo": rimNo,
      if (appendexRemarks != null) "appendexRemarks": appendexRemarks,
      if (categoryId != null) "categoryId": categoryId,
      "countryOverView": toCountryOverviewJson(
        ratingOverride: ratingOverride,
      ), // legacy server key
      if (createdBy != null) "createdBy": createdBy,
      if (createdDate != null)
        "createdDate": createdDate.toUtc().toIso8601String(),
      if (updatedBy != null) "updatedBy": updatedBy,
      if (updatedDate != null)
        "updatedDate": updatedDate.toUtc().toIso8601String(),
    };
  }
}

/// ---------------------------------------------------------------------------
/// Excel Upload Intent
/// ---------------------------------------------------------------------------

/// Represents an Excel upload request for FI appendix extraction.
class FiExcelUploadIntent {
  /// Creates a [FiExcelUploadIntent] instance.
  const FiExcelUploadIntent({
    required this.excelFilePath,
    required this.rimNumber,
    required this.userId,
  });

  /// Excel file path.
  final String excelFilePath;

  /// Customer RIM number.
  final String rimNumber;

  /// User identifier.
  final String userId;
}

/// ---------------------------------------------------------------------------
/// FI Extract Response (simple version)
/// ---------------------------------------------------------------------------

/// Represents FI appendix extraction results.
class AppendixFiExtract {
  /// Creates an [AppendixFiExtract] instance.
  const AppendixFiExtract(this.items);

  /// Creates an [AppendixFiExtract] instance from an API response.
  factory AppendixFiExtract.fromApiResponse(
    Map<String, dynamic> body,
  ) {
    final dynamic data = body["responseData"];

    if (data is List) {
      // Each element may be Map<dynamic, dynamic>; cast safely
      final items = data
          .whereType<Map>()
          .map(
            (element) => AppendixFiItem.fromJson(
              element.cast<String, dynamic>(),
            ),
          )
          .toList();
      return AppendixFiExtract(items);
    } else if (data is Map) {
      return AppendixFiExtract([
        AppendixFiItem.fromJson(data.cast<String, dynamic>()),
      ]);
    }

    return const AppendixFiExtract([]);
  }

  /// Extracted FI items.
  final List<AppendixFiItem> items;

  /// Indicates whether the collection is empty.
  bool get isEmpty => items.isEmpty;

  /// Indicates whether the collection contains items.
  bool get isNotEmpty => items.isNotEmpty;
}

/// ---------------------------------------------------------------------------
/// FI Item (simple model – no messy parsing)
/// ---------------------------------------------------------------------------

/// Represents a financial institution appendix item.
class AppendixFiItem {
  /// Creates an [AppendixFiItem] instance.
  AppendixFiItem({
    required this.rimNo,
    required this.appRefNo,
    this.keyInformation,
    this.balanceSheet = const [],
    this.liabilities = const [],
    this.incomeStatement,
    this.capitalAdequacy = const [],
    this.assetQuality = const [],
    this.liquidityAndFunding = const [],
    this.earnings = const [],
  });

  /// Creates an [AppendixFiItem] instance from a JSON map.
  factory AppendixFiItem.fromJson(
    Map<String, dynamic> json,
  ) {
    List<Map<String, dynamic>> readList(value) {
      if (value is List) {
        // Each entry might be Map<dynamic, dynamic>
        return value
            .whereType<Map>()
            .map((m) => m.cast<String, dynamic>())
            .toList();
      }
      return const [];
    }

    Map<String, dynamic>? readMap(value) {
      if (value is Map) {
        return value.cast<String, dynamic>();
      }
      return null;
    }

    return AppendixFiItem(
      rimNo: json["rimNo"] is int
          ? json["rimNo"] as int
          : int.tryParse('${json['rimNo']}') ?? 0,
      appRefNo: (json["appRefNo"] ?? "").toString(),
      keyInformation: readMap(json["keyInformation"]),
      balanceSheet: readList(json["balanceSheet"]),
      liabilities: readList(json["liabilities"]),
      incomeStatement: readMap(json["incomeStatement"]),
      capitalAdequacy: readList(json["capitaladequacy"]),
      assetQuality: readList(json["assetquality"]),
      liquidityAndFunding: readList(json["liguidityandfunding"]),
      earnings: readList(json["earnings"]),
    );
  }

  /// Customer RIM number.
  final int rimNo;

  /// Application reference number.
  final String appRefNo;

  /// Key information.
  final Map<String, dynamic>? keyInformation;

  /// Balance sheet data.
  final List<Map<String, dynamic>> balanceSheet;

  /// Liabilities data.
  final List<Map<String, dynamic>> liabilities;

  /// Income statement data.
  final Map<String, dynamic>? incomeStatement;

  /// Capital adequacy data.
  final List<Map<String, dynamic>> capitalAdequacy;

  /// Asset quality data.
  final List<Map<String, dynamic>> assetQuality;

  /// Liquidity and funding data.
  final List<Map<String, dynamic>> liquidityAndFunding;

  /// Earnings data.
  final List<Map<String, dynamic>> earnings;
}

/// ---------------------------------------------------------------------------
/// Simple Table + KeyValue classes
/// ---------------------------------------------------------------------------

/// Represents a tabular section with columns and rows.
class SectionGrid {
  /// Creates a [SectionGrid] instance.
  const SectionGrid({
    required this.columns,
    required this.rows,
  });

  /// Column names.
  final List<String> columns;

  /// Row data.
  final List<Map<String, String>> rows;
}

/// Represents a key-value row.
class KvRow {
  /// Creates a [KvRow] instance.
  const KvRow({
    required this.field,
    required this.value,
  });

  /// Field name.
  final String field;

  /// Field value.
  final String value;
}

/// ---------------------------------------------------------------------------
/// Appendix Excel Rows
/// ---------------------------------------------------------------------------

/// Represents an appendix Excel file record.
class FiAppendixXlsxRow {
  /// Creates a [FiAppendixXlsxRow] instance.
  FiAppendixXlsxRow({
    required this.rimNo,
    required this.appRefNo,
    this.fileNames,
    this.appendixXlsxId,
  });

  /// Creates a [FiAppendixXlsxRow] instance from a JSON map.
  factory FiAppendixXlsxRow.fromJson(Map<String, dynamic> json) {
    return FiAppendixXlsxRow(
      rimNo: json["rimNo"] is int
          ? json["rimNo"] as int
          : int.tryParse('${json["rimNo"]}') ?? 0,
      appRefNo: (json["appRefNo"] ?? "").toString(),
      fileNames: json["fileNames"],
      appendixXlsxId:
          json["appendixXlsxID"] is int ? json["appendixXlsxID"] as int : null,
    );
  }

  /// Customer RIM number.
  final int rimNo;

  /// Application reference number.
  final String appRefNo;

  /// Uploaded file names.
  final dynamic fileNames;

  /// Appendix XLSX identifier.
  final int? appendixXlsxId;
}

/// Represents appendix XLSX response data.
class FiAppendixXlsxResponse {
  /// Creates a [FiAppendixXlsxResponse] instance.
  FiAppendixXlsxResponse(this.rows);

  /// Creates a [FiAppendixXlsxResponse] instance from response data.
  factory FiAppendixXlsxResponse.fromResponseData(raw) {
    if (raw is List) {
      final rows = raw
          .whereType<Map>()
          .map(
            (element) => FiAppendixXlsxRow.fromJson(
              element.cast<String, dynamic>(),
            ),
          )
          .toList();
      return FiAppendixXlsxResponse(rows);
    }

    if (raw is Map) {
      return FiAppendixXlsxResponse([
        FiAppendixXlsxRow.fromJson(raw.cast<String, dynamic>()),
      ]);
    }

    return FiAppendixXlsxResponse(const []);
  }

  /// Appendix XLSX rows.
  final List<FiAppendixXlsxRow> rows;
}
