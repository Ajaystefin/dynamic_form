/// Represents guarantor financial details including
/// financial categories, entities, and audit information.
class GuarantorFinancialDetailsResponse {
  /// Creates a [GuarantorFinancialDetailsResponse] instance.
  GuarantorFinancialDetailsResponse({
    required this.guarantorFinancialsId,
    required this.appRefNo,
    required this.rimNo,
    required this.customerName,
    // required this.guarantorFinancialsComment,
    required this.entityDetails,
    required this.createdBy,
    required this.createdDate,
    required this.updatedBy,
    required this.updatedDate,
  });

  /// Creates a [GuarantorFinancialDetailsResponse] instance from a JSON map.
  factory GuarantorFinancialDetailsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return GuarantorFinancialDetailsResponse(
      guarantorFinancialsId: json["guarantorFinancialsId"] as int?,
      appRefNo: json["appRefNo"] as String,
      rimNo: json["rimNo"] as int,
      customerName: json["customerName"] as String?,
      // guarantorFinancialsComment: json['guarantorFinancialsComment'] as
      // String?,
      entityDetails: (json["entityDetails"] as List<dynamic>? ?? const [])
          .map((e) => GuarantorEntityDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdBy: json["createdBy"] as String?,
      createdDate: _parseDate(json["createdDate"]),
      updatedBy: json["updatedBy"] as String?,
      updatedDate: _parseDate(json["updatedDate"]),
    );
  }

  /// Guarantor financial record identifier.
  final int? guarantorFinancialsId;

  /// Application reference number.
  final String appRefNo;

  /// Customer RIM number.
  final int rimNo;

  /// Customer name.
  final String? customerName;

  /// Guarantor entity details.
  final List<GuarantorEntityDetail> entityDetails;

  /// User who created the record.
  final String? createdBy;

  /// Record creation date.
  final DateTime? createdDate;

  /// User who last updated the record.
  final String? updatedBy;

  /// Record last update date.
  final DateTime? updatedDate;

  // final String? guarantorFinancialsComment;

  /// Converts this [GuarantorFinancialDetailsResponse] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        "guarantorFinancialsId": guarantorFinancialsId,
        "appRefNo": appRefNo,
        "rimNo": rimNo,
        "customerName": customerName,
        // 'guarantorFinancialsComment': guarantorFinancialsComment,
        "entityDetails": entityDetails.map((e) => e.toJson()).toList(),
        "createdBy": createdBy,
        "createdDate": createdDate?.toIso8601String(),
        "updatedBy": updatedBy,
        "updatedDate": updatedDate?.toIso8601String(),
      };

  /// Parses a value into a [DateTime] instance.
  static DateTime? _parseDate(v) {
    if (v == null) {
      return null;
    }
    try {
      return DateTime.parse(v as String);
    } on Object catch (_) {
      return null;
    }
  }
}

/// Represents guarantor financial details for a specific entity.
class GuarantorEntityDetail {
  /// Creates a [GuarantorEntityDetail] instance.
  GuarantorEntityDetail({
    required this.guarantorFinancialsId,
    required this.entityId,
    required this.entityLongName,
    required this.financialsCategory,
  });

  /// Creates a [GuarantorEntityDetail] instance from a JSON map.
  factory GuarantorEntityDetail.fromJson(Map<String, dynamic> json) {
    return GuarantorEntityDetail(
      guarantorFinancialsId: json["guarantorFinancialsId"] as int?,
      entityId: json["entityId"] as int,
      // entityLongName: json['entityLongName'] as String,
      entityLongName: (json["entityLongName"] as String?) ?? "",
      financialsCategory:
          (json["financialsCategory"] as List<dynamic>? ?? const [])
              .map(
                (e) =>
                    GuarantorCategoryDetail.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  /// Guarantor financial record identifier.
  final int? guarantorFinancialsId;

  /// Entity identifier.
  final int entityId;

  /// Entity long name.
  final String entityLongName;

  /// Financial categories associated with the entity.
  final List<GuarantorCategoryDetail> financialsCategory;

  /// Converts this [GuarantorEntityDetail] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        "guarantorFinancialsId": guarantorFinancialsId,
        "entityId": entityId,
        "entityLongName": entityLongName,
        "financialsCategory":
            financialsCategory.map((c) => c.toJson()).toList(),
      };
}

/// Represents guarantor financial category details.
class GuarantorCategoryDetail {
  /// Creates a [GuarantorCategoryDetail] instance.
  GuarantorCategoryDetail({
    required this.financialsCategory,
    required this.financialsValues,
    required this.guarantorHealth,
    required this.remarks,
  });

  /// Creates a [GuarantorCategoryDetail] instance from a JSON map.
  factory GuarantorCategoryDetail.fromJson(Map<String, dynamic> json) {
    return GuarantorCategoryDetail(
      financialsCategory: json["financialsCategory"] as int,
      financialsValues: (json["financialsValues"] as List<dynamic>? ?? const [])
          .map(
            (e) => GuarantorFinancialValue.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      guarantorHealth: json["guarantorHealth"] as int?,
      remarks: json["remarks"] as String?,
    );
  }

  /// Financial category identifier.
  final int financialsCategory;

  /// Financial values associated with the category.
  final List<GuarantorFinancialValue> financialsValues;

  /// Guarantor health rating.
  int? guarantorHealth;

  /// Remarks for the financial category.
  String? remarks;

  /// Converts this [GuarantorCategoryDetail] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        "financialsCategory": financialsCategory,
        "financialsValues": financialsValues.map((v) => v.toJson()).toList(),
        "guarantorHealth": guarantorHealth,
        "remarks": remarks,
      };
}

/// Represents a guarantor financial value used in
/// financial ratio and category analysis.
class GuarantorFinancialValue {
  /// Creates a [GuarantorFinancialValue] instance.
  GuarantorFinancialValue({
    required this.financialsCategory,
    required this.financialRatioType,
    required this.userAddedRatioType,
    required this.financialYear,
    required this.period,
    required this.auditMethod,
    required this.auditor,
    required this.value,
    required this.statementDate,
  });

  /// Creates a [GuarantorFinancialValue] instance from a JSON map.
  factory GuarantorFinancialValue.fromJson(Map<String, dynamic> json) {
    // Handle "null" (string) and actual null gracefully
    final dynamic frtRaw = json["financialRatioType"];
    final String? frt = frtRaw == null
        ? null
        : (frtRaw is String
            ? (frtRaw.toLowerCase() == "null" ? null : frtRaw)
            : frtRaw.toString());

    final num? rawValue = json["value"] as num?;
    return GuarantorFinancialValue(
      financialsCategory: json["financialsCategory"] as int,
      financialRatioType: frt,
      statementDate: json["statementDate"] as String?,
      userAddedRatioType: json["userAddedRatioType"] as String?,
      financialYear: json["financialYear"] as int,
      period: json["period"] as String,
      auditMethod: json["auditMethod"] as String,
      auditor: json["auditor"] as String?,
      value: rawValue?.toDouble(),
    );
  }

  /// Financial category identifier.
  final int financialsCategory;

  /// Financial ratio type.
  final String? financialRatioType;

  /// User-defined financial ratio type.
  final String? userAddedRatioType;

  /// Financial year.
  final int financialYear;

  /// Financial period.
  final String period;

  /// Audit method.
  final String auditMethod;

  /// Auditor name.
  final String? auditor;

  /// Financial value.
  final double? value;

  /// Statement date.
  final String? statementDate;

  /// Converts this [GuarantorFinancialValue] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        "financialsCategory": financialsCategory,
        "financialRatioType": financialRatioType,
        "userAddedRatioType": userAddedRatioType,
        "financialYear": financialYear,
        "period": period,
        "auditMethod": auditMethod,
        "statementDate": statementDate,
        "auditor": auditor,
        "value": value,
      };
}
