/// Represents the response for financial ratio analysis,
/// including entity financial details and audit information.
class FinancialRatioAnalysisResponse {
  /// Creates a [FinancialRatioAnalysisResponse] instance.
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

  /// Creates a [FinancialRatioAnalysisResponse] instance from a JSON map.
  factory FinancialRatioAnalysisResponse.fromJson(
    Map<String, dynamic> json,
  ) {
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

  /// Customer financial record identifier.
  final int? customerFinancialsId;

  /// Application reference number.
  final String appRefNo;

  /// Customer RIM number.
  final int rimNo;

  /// Customer name.
  final String? customerName;

  /// Description of accounts.
  final String? descOfAccounts;

  /// Financial entities associated with the analysis.
  final List<EntityDetail> entityDetails;

  /// User who created the record.
  final String? createdBy;

  /// Record creation date.
  final DateTime? createdDate;

  /// User who last updated the record.
  final String? updatedBy;

  /// Record last update date.
  final DateTime? updatedDate;

  /// Converts this [FinancialRatioAnalysisResponse] instance to a JSON map.
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

  /// Parses a date value into a [DateTime] instance.
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

  /// Converts a value to its string representation.
  static String? _asString(value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value;
    }
    return value.toString();
  }
}

/// Represents financial details for a customer entity,
/// including financial categories and related values.
class EntityDetail {
  /// Creates an [EntityDetail] instance.
  EntityDetail({
    required this.customerFinancialsId,
    required this.entityId,
    required this.entityLongName,
    required this.financialsCategory,
  });

  /// Creates an [EntityDetail] instance from a JSON map.
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

  /// Customer financial record identifier.
  final int? customerFinancialsId;

  /// Entity identifier.
  final int entityId;

  /// Entity long name.
  final String entityLongName;

  /// Financial categories associated with the entity.
  final List<FinancialCategoryDetail> financialsCategory;

  /// Converts this [EntityDetail] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        "customerFinancialsId": customerFinancialsId,
        "entityId": entityId,
        "entityLongName": entityLongName,
        "financialsCategory":
            financialsCategory.map((c) => c.toJson()).toList(),
      };
}

/// Represents financial category details, including
/// financial values, health assessment, and remarks.
class FinancialCategoryDetail {
  /// Creates a [FinancialCategoryDetail] instance.
  FinancialCategoryDetail({
    required this.financialsCategory,
    required this.financialsValues,
    required this.financialHealth,
    required this.remarks,
  });

  /// Creates a [FinancialCategoryDetail] instance from a JSON map.
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

  /// Financial category identifier.
  final int financialsCategory;

  /// Financial values associated with the category.
  final List<FinancialValue> financialsValues;

  /// Financial health rating.
  final int? financialHealth;

  /// Remarks for the financial category.
  final String? remarks;

  /// Converts this [FinancialCategoryDetail] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        "financialsCategory": financialsCategory,
        "financialsValues": financialsValues.map((v) => v.toJson()).toList(),
        "financialHealth": financialHealth,
        "remarks": remarks,
      };
}

/// Represents a financial value used in financial ratio
/// and financial statement analysis.
class FinancialValue {
  /// Creates a [FinancialValue] instance.
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

  /// Creates a [FinancialValue] instance from a JSON map.
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

  /// Financial category identifier.
  final int financialsCategory;

  /// Financial ratio type.
  final String financialRatioType;

  /// User-defined financial ratio type.
  final String? userAddedRatioType;

  /// Financial year.
  ///
  /// 2024
  final int financialYear;

  /// Financial period.
  ///
  /// "6M", "12M"
  final String period;

  /// Audit method.
  ///
  /// "Co.Prep'd", "Audited"
  final String auditMethod;

  /// Auditor name.
  ///
  /// may be null
  final String? auditor;

  /// Financial value.
  final double? value;

  /// Statement date.
  final String? statementDate;

  /// Converts this [FinancialValue] instance to a JSON map.
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

/// Represents the result of a financial ratio analysis deletion operation.
class DeleteFinancialRatioAnalysisResult {
  /// Creates a [DeleteFinancialRatioAnalysisResult] instance.
  const DeleteFinancialRatioAnalysisResult({
    required this.message,
  });

  /// Creates a [DeleteFinancialRatioAnalysisResult] instance from JSON data.
  factory DeleteFinancialRatioAnalysisResult.fromJson(json) {
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

  /// Result message returned by the operation.
  final String message;

  /// Indicates whether the delete operation completed successfully.
  bool get isSuccess => message.toLowerCase() == "success";

  /// Converts this [DeleteFinancialRatioAnalysisResult] instance to a JSON map.
  Map<String, dynamic> toJson() => {"message": message};
}
