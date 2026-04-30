import "package:file_picker/file_picker.dart";

import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/models/request/file_attachment/appendix_entry.dart";

/// ---------------------------------------------------------------------------
/// BASIC & EASY: Appendix (Country Overview + Attachments)
/// ---------------------------------------------------------------------------
class Appendix {
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

  /// Simple from JSON (accepts both List and CSV string for list fields).
  factory Appendix.fromJson(Map<String, dynamic> json) {
    // Local inline splitter: accepts List or CSV String (comma-separated).
    List<String> readList(dynamic value) {
      if (value == null) return <String>[];
      if (value is List) {
        return value
            .whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      final String text = value.toString();
      if (text.trim().isEmpty) return <String>[];
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
      populationText: (json["populationText"]?.toString() ??
          json["population"]?.toString() ??
          ""),
      gdpText: (json["gdpText"]?.toString() ?? json["gdp"]?.toString() ?? ""),
      importPartners: readList(json["importPartners"]),
      exportPartners: readList(json["exportPartners"]),
      strengths: readList(json["strengths"]),
      threats: readList(json["threats"]),
    );
  }

  // -------------------------------------------------------------------------
  // Legacy helpers (kept for repository compatibility)
  // -------------------------------------------------------------------------

  /// Accepts the overview map shape directly (legacy name preserved).
  factory Appendix.fromCountryOverViewJson(Map<String, dynamic> json) {
    return Appendix.fromJson(json);
  }

  /// Accepts a flat item; if it contains `countryOverView`, use it first.
  factory Appendix.fromFlatJson(Map<String, dynamic> json) {
    final Object? nested = json["countryOverView"];
    if (nested is Map) {
      return Appendix.fromJson(nested.cast<String, dynamic>());
    }
    return Appendix.fromJson(json);
  }
  String groupCorporateStructure;

  List<AppendixEntry> entries;
  List<PlatformFile> files;

  String? countryName;
  String? rating;

  /// Store as plain strings because user enters text
  String populationText;
  String gdpText;
  List<String> exportPartners;
  List<String> importPartners;
  List<String> strengths;
  List<String> threats;

  PlatformFile? ratingBarImage;
  PlatformFile? countryMapImage;
  PlatformFile? governmentIndicatorsImage;

  /// Convert to simple JSON (for API) — keeps legacy server key "popuLation".
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

  /// Build business segment payload — keeps legacy server key
  /// "countryOverView".
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
class FiExcelUploadIntent {
  const FiExcelUploadIntent({
    required this.excelFilePath,
    required this.rimNumber,
    required this.userId,
  });
  final String excelFilePath;
  final String rimNumber;
  final String userId;
}

/// ---------------------------------------------------------------------------
/// FI Extract Response (simple version)
/// ---------------------------------------------------------------------------
class AppendixFiExtract {
  const AppendixFiExtract(this.items);

  factory AppendixFiExtract.fromApiResponse(Map<String, dynamic> body) {
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
  final List<AppendixFiItem> items;

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}

/// ---------------------------------------------------------------------------
/// FI Item (simple model – no messy parsing)
/// ---------------------------------------------------------------------------
class AppendixFiItem {
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

  factory AppendixFiItem.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> readList(dynamic value) {
      if (value is List) {
        // Each entry might be Map<dynamic, dynamic>
        return value
            .whereType<Map>()
            .map((m) => m.cast<String, dynamic>())
            .toList();
      }
      return const [];
    }

    Map<String, dynamic>? readMap(dynamic value) {
      if (value is Map) return value.cast<String, dynamic>();
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
  final int rimNo;
  final String appRefNo;

  /// Basic Maps – clean input expected
  final Map<String, dynamic>? keyInformation;
  final List<Map<String, dynamic>> balanceSheet;
  final List<Map<String, dynamic>> liabilities;
  final Map<String, dynamic>? incomeStatement;
  final List<Map<String, dynamic>> capitalAdequacy;
  final List<Map<String, dynamic>> assetQuality;
  final List<Map<String, dynamic>> liquidityAndFunding;
  final List<Map<String, dynamic>> earnings;
}

/// ---------------------------------------------------------------------------
/// Simple Table + KeyValue classes
/// ---------------------------------------------------------------------------
class SectionGrid {
  const SectionGrid({required this.columns, required this.rows});
  final List<String> columns;
  final List<Map<String, String>> rows;
}

class KvRow {
  const KvRow({required this.field, required this.value});
  final String field;
  final String value;
}

/// ---------------------------------------------------------------------------
/// Appendix Excel Rows
/// ---------------------------------------------------------------------------
class FiAppendixXlsxRow {
  FiAppendixXlsxRow({
    required this.rimNo,
    required this.appRefNo,
    this.fileNames,
    this.appendixXlsxId,
  });

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
  final int rimNo;
  final String appRefNo;
  final dynamic fileNames;
  final int? appendixXlsxId;
}

class FiAppendixXlsxResponse {
  FiAppendixXlsxResponse(this.rows);

  factory FiAppendixXlsxResponse.fromResponseData(dynamic raw) {
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
  final List<FiAppendixXlsxRow> rows;
}
