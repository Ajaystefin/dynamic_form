// lib/models/request/file_attachment/business_segment_payload.dart
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";

class BusinessSegmentPayload {
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

  /// Minimal helper to create with sensible audit defaults from context.
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
    final String userName = (Globals.user?.name?.trim().isNotEmpty == true
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
  final String appRefNo;
  final int rimNo;
  final String customerType; // e.g. "Country"
  final String businessSegment; // e.g. "corporate"

  // Country overview fields (UI fields)
  final String countryName;
  final String? rating; // API treats rating as string ("A", "2", etc.)
  final String
      populationText; // UI provides as string; we'll parse to int in toJson
  final String gdpText; // UI provides as string; we'll parse to int in toJson
  final List<String> exportPartners; // required as arrays
  final List<String> importPartners;
  final List<String> strengths;
  final List<String> threats;

  // Audit fields (DB requires NOT NULL)
  final String createdBy;
  final DateTime?
      createdDate; // Keep as DateTime in model; serialize to ISO-8601 in toJson
  final String updatedBy;
  final DateTime? updatedDate;

  /// Serialize exactly to backend contract.
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
