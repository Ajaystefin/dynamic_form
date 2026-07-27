// lib/models/request/file_attachment/business_segment_payload.dart
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";

/// Represents a business segment payload for country overview data.
class BusinessSegmentPayload {
  /// Creates a [BusinessSegmentPayload] instance.
  const BusinessSegmentPayload({
    required this.appRefNo,
    required this.rimNo,
    required this.countryName,
    required this.populationText,
    required this.gdpText,
    required this.exportPartners,
    required this.importPartners,
    required this.strengths,
    required this.threats,
    required this.createdBy,
    required this.updatedBy,
    this.customerType = ServerConstants.country,
    this.businessSegment = ServerConstants.corporate,
    this.rating,
    this.createdDate,
    this.updatedDate,
  });

  /// Creates a [BusinessSegmentPayload] instance using
  /// application context and default audit information.
  factory BusinessSegmentPayload.fromContext({
    required String appRefNo,
    required int rimNo,
    required String countryName,
    required String populationText,
    required String gdpText,
    required List<String> exportPartners,
    required List<String> importPartners,
    required List<String> strengths,
    required List<String> threats,
    String customerType = ServerConstants.country,
    String businessSegment = ServerConstants.corporate,
    String? rating,
  }) {
    final String userName = (Globals.user?.name?.trim().isNotEmpty ?? false
        ? Globals.user!.name!
        : "system");
    final DateTime nowUtc = DateTime.now().toUtc();
    return BusinessSegmentPayload(
      appRefNo: appRefNo,
      rimNo: rimNo,
      customerType: customerType,
      businessSegment: businessSegment,
      countryName: countryName,
      rating: rating,
      populationText: populationText,
      gdpText: gdpText,
      exportPartners: exportPartners,
      importPartners: importPartners,
      strengths: strengths,
      threats: threats,
      createdBy: userName,
      createdDate: nowUtc,
      updatedBy: userName,
      updatedDate: nowUtc,
    );
  }

  /// Application reference number.
  final String appRefNo;

  /// Customer RIM number.
  final int rimNo;

  /// Customer type.
  ///
  /// e.g. "Country"
  final String customerType;

  /// Business segment.
  ///
  /// e.g. "corporate"
  final String businessSegment;

  /// Country name.
  final String countryName;

  /// Country rating.
  ///
  /// API treats rating as string ("A", "2", etc.)
  final String? rating;

  /// Population value as text.
  ///
  /// UI provides as string; we'll parse to int in toJson
  final String populationText;

  /// GDP value as text.
  ///
  /// UI provides as string; we'll parse to int in toJson
  final String gdpText;

  /// Export partners.
  ///
  /// required as arrays
  final List<String> exportPartners;

  /// Import partners.
  final List<String> importPartners;

  /// Country strengths.
  final List<String> strengths;

  /// Country threats.
  final List<String> threats;

  /// User who created the record.
  final String createdBy;

  /// Record creation date.
  ///
  /// Keep as DateTime in model; serialize to ISO-8601 in toJson
  final DateTime? createdDate;

  /// User who last updated the record.
  final String updatedBy;

  /// Record last update date.
  final DateTime? updatedDate;

  /// Converts this [BusinessSegmentPayload] instance
  /// to the backend request format.
  Map<String, dynamic> toJson() {
    int? toInt(String? s) => (s == null) ? null : int.tryParse(s.trim());

    return {
      "appRefNo": appRefNo,
      "rimNo": rimNo,
      "businessSegment": businessSegment, // correct spelling per backend
      "customerType": customerType,

      // audit: top-level, NOT inside countryOverView
      "createdBy": createdBy,
      "createdDate": createdDate?.toUtc().toIso8601String(),
      "updatedBy": updatedBy,
      "updatedDate": updatedDate?.toUtc().toIso8601String(),

      // nested structure with arrays + numeric fields
      "countryOverView": {
        "countryName": countryName,
        if (rating != null) "rating": rating,
        if (toInt(populationText) != null)
          "popuLation": toInt(populationText), // backend's quirky casing
        "gdp": gdpText,
        "exportPartners": exportPartners,
        "importPartners": importPartners,
        "strengths": strengths,
        "threats": threats,
      },
    };
  }
}
