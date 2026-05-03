class GuarantorFinancialDetailsResponse {
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
  final int? guarantorFinancialsId;
  final String appRefNo;
  final int rimNo;
  final String? customerName;
  // final String? guarantorFinancialsComment;

  final List<GuarantorEntityDetail> entityDetails;

  final String? createdBy;
  final DateTime? createdDate;
  final String? updatedBy;
  final DateTime? updatedDate;

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

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v as String);
    } catch (_) {
      return null;
    }
  }
}

class GuarantorEntityDetail {
  GuarantorEntityDetail({
    required this.guarantorFinancialsId,
    required this.entityId,
    required this.entityLongName,
    required this.financialsCategory,
  });

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
  final int? guarantorFinancialsId;
  final int entityId;
  final String entityLongName;

  final List<GuarantorCategoryDetail> financialsCategory;

  Map<String, dynamic> toJson() => {
        "guarantorFinancialsId": guarantorFinancialsId,
        "entityId": entityId,
        "entityLongName": entityLongName,
        "financialsCategory":
            financialsCategory.map((c) => c.toJson()).toList(),
      };
}

class GuarantorCategoryDetail {
  GuarantorCategoryDetail({
    required this.financialsCategory,
    required this.financialsValues,
    required this.guarantorHealth,
    required this.remarks,
  });

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
  final int financialsCategory;
  final List<GuarantorFinancialValue> financialsValues;
  int? guarantorHealth;
  String? remarks;

  Map<String, dynamic> toJson() => {
        "financialsCategory": financialsCategory,
        "financialsValues": financialsValues.map((v) => v.toJson()).toList(),
        "guarantorHealth": guarantorHealth,
        "remarks": remarks,
      };
}

class GuarantorFinancialValue {
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
  final int financialsCategory;
  final String? financialRatioType;
  final String? userAddedRatioType;
  final int financialYear;
  final String period;
  final String auditMethod;
  final String? auditor;
  final double? value;
  final String? statementDate;

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
