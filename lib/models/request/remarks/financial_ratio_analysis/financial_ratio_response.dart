class FinancialRatioAnalysisResponse {
  FinancialRatioAnalysisResponse({
    required this.customerFinancialsId,
    required this.appRefNo,
    required this.rimNo,
    required this.customerName,
    required this.descOfAccounts,
    required this.entityDetails,
    required this.createdBy,
    required this.createdDate,
    required this.updatedBy,
    required this.updatedDate,
  });

  factory FinancialRatioAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return FinancialRatioAnalysisResponse(
      customerFinancialsId: json["customerFinancialsId"] as int?,
      appRefNo: json["appRefNo"] as String,
      rimNo: json["rimNo"] as int,
      customerName: _asString(json["customerName"]),
      descOfAccounts: json["descOfAccounts"] as String?,
      entityDetails: (json["entityDetails"] as List<dynamic>? ?? const [])
          .map((e) => EntityDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdBy: json["createdBy"] as String?,
      createdDate: _parseDate(json["createdDate"]),
      updatedBy: json["updatedBy"] as String?,
      updatedDate: _parseDate(json["updatedDate"]),
    );
  }
  final int? customerFinancialsId;
  final String appRefNo;
  final int rimNo;
  final String? customerName;
  final String? descOfAccounts;

  final List<EntityDetail> entityDetails;

  final String? createdBy;
  final DateTime? createdDate;
  final String? updatedBy;
  final DateTime? updatedDate;

  Map<String, dynamic> toJson() => {
        "customerFinancialsId": customerFinancialsId,
        "appRefNo": appRefNo,
        "rimNo": rimNo,
        "customerName": customerName,
        "descOfAccounts": descOfAccounts,
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

  static String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }
}

class EntityDetail {
  EntityDetail({
    required this.customerFinancialsId,
    required this.entityId,
    required this.entityLongName,
    required this.financialsCategory,
  });

  factory EntityDetail.fromJson(Map<String, dynamic> json) {
    return EntityDetail(
      customerFinancialsId: json["customerFinancialsId"] as int,
      entityId: json["entityId"] as int,
      entityLongName: json["entityLongName"] as String,
      financialsCategory:
          (json["financialsCategory"] as List<dynamic>? ?? const [])
              .map(
                (e) =>
                    FinancialCategoryDetail.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );
  }
  final int? customerFinancialsId;
  final int entityId;
  final String entityLongName;

  final List<FinancialCategoryDetail> financialsCategory;

  Map<String, dynamic> toJson() => {
        "customerFinancialsId": customerFinancialsId,
        "entityId": entityId,
        "entityLongName": entityLongName,
        "financialsCategory":
            financialsCategory.map((c) => c.toJson()).toList(),
      };
}

class FinancialCategoryDetail {
  FinancialCategoryDetail({
    required this.financialsCategory,
    required this.financialsValues,
    required this.financialHealth,
    required this.remarks,
  });

  factory FinancialCategoryDetail.fromJson(Map<String, dynamic> json) {
    return FinancialCategoryDetail(
      financialsCategory: json["financialsCategory"] as int,
      financialsValues: (json["financialsValues"] as List<dynamic>? ?? const [])
          .map((e) => FinancialValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      financialHealth: json["financialHealth"] as int?,
      remarks: json["remarks"] as String?,
    );
  }
  final int financialsCategory;
  final List<FinancialValue> financialsValues;
  final int? financialHealth;
  final String? remarks;

  Map<String, dynamic> toJson() => {
        "financialsCategory": financialsCategory,
        "financialsValues": financialsValues.map((v) => v.toJson()).toList(),
        "financialHealth": financialHealth,
        "remarks": remarks,
      };
}

class FinancialValue {
  FinancialValue({
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

  factory FinancialValue.fromJson(Map<String, dynamic> json) {
    final num? raw = json["value"] as num?;
    return FinancialValue(
      financialsCategory: json["financialsCategory"] as int,
      financialRatioType: json["financialRatioType"] as String,
      userAddedRatioType: json["userAddedRatioType"] as String?,
      statementDate: json["statementDate"] as String?,
      financialYear: json["financialYear"] as int,
      period: json["period"] as String,
      auditMethod: json["auditMethod"] as String,
      auditor: json["auditor"] as String?,
      value: raw?.toDouble(),
    );
  }
  final int financialsCategory;
  final String financialRatioType;
  final String? userAddedRatioType;
  final int financialYear; // e.g., 2024
  final String period; // e.g., "6M", "12M"
  final String auditMethod; // e.g., "Co.Prep'd", "Audited"
  final String? auditor; // may be null
  final double? value;
  final String? statementDate;

  Map<String, dynamic> toJson() => {
        "financialsCategory": financialsCategory,
        "financialRatioType": financialRatioType,
        "userAddedRatioType": userAddedRatioType,
        "financialYear": financialYear,
        "statementDate": statementDate,
        "period": period,
        "auditMethod": auditMethod,
        "auditor": auditor,
        "value": value,
      };
}

class DeleteFinancialRatioAnalysisResult {
  const DeleteFinancialRatioAnalysisResult({required this.message});
  factory DeleteFinancialRatioAnalysisResult.fromJson(dynamic json) {
    if (json is String) {
      return DeleteFinancialRatioAnalysisResult(message: json);
    }
    if (json is Map<String, dynamic>) {
      final msg = json["message"]?.toString() ?? "Unknown";
      return DeleteFinancialRatioAnalysisResult(message: msg);
    }
    return DeleteFinancialRatioAnalysisResult(
      message: json?.toString() ?? "Unknown",
    );
  }
  final String message;
  bool get isSuccess => message.toLowerCase() == "success";

  Map<String, dynamic> toJson() => {"message": message};
}
