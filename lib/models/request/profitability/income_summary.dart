/// Represents income summary information for a customer.
class IncomeSummary {
  /// Creates an [IncomeSummary] instance.
  IncomeSummary({
    this.relationshipIncomeId,
    this.rimNo,
    this.custName,
    this.incomeNature,
    this.lastYearAmount,
    this.nextYearAmount,
    this.nextYear2Amount,
    this.lastYearProfitability,
    this.nextYearProfitability,
    this.nextYear2Profitability,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
  });

  /// Creates an [IncomeSummary] instance from a JSON map.
  factory IncomeSummary.fromJson(Map<String, dynamic> json) {
    // double? toDouble(dynamic v) =>
    //     v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));

    DateTime? toDate(v) => v == null ? null : DateTime.tryParse(v as String);

    return IncomeSummary(
      relationshipIncomeId: json["relationshipIncomeId"] as int?,
      rimNo: json["rimNo"] as int?,
      custName: json["custName"] as String?,
      incomeNature: json["incomeNature"] as String?,
      lastYearAmount: json["lastYearAmount"],
      nextYearAmount: json["nextYearAmount"],
      nextYear2Amount: json["nextYear2Amount"],
      lastYearProfitability: json["lastYearProfitability"],
      nextYearProfitability: json["nextYearProfitability"],
      nextYear2Profitability: json["nextYear2Profitability"],
      createdBy: json["createdBy"] as String?,
      createdDate: toDate(json["createdDate"]),
      updatedBy: json["updatedBy"] as String?,
      updatedDate: toDate(json["updatedDate"]),
    );
  }

  /// Relationship income identifier.
  final int? relationshipIncomeId;

  /// Customer RIM number.
  final int? rimNo;

  /// Customer name.
  final String? custName;

  /// Nature of income.
  final String? incomeNature;

  /// Last year amount.
  final String? lastYearAmount;

  /// Next year amount.
  final String? nextYearAmount;

  /// Amount for year after next.
  final String? nextYear2Amount;

  /// Last year profitability.
  final String? lastYearProfitability;

  /// Next year profitability.
  final String? nextYearProfitability;

  /// Profitability for year after next.
  final String? nextYear2Profitability;

  /// User who created the record.
  final String? createdBy;

  /// Record creation date.
  final DateTime? createdDate;

  /// User who last updated the record.
  final String? updatedBy;

  /// Record last update date.
  final DateTime? updatedDate;

  /// Converts this [IncomeSummary] instance to a JSON map.
  Map<String, dynamic> toJson() {
    String? fmt(DateTime? d) => d?.toUtc().toIso8601String();
    return {
      "relationshipIncomeId": relationshipIncomeId,
      "rimNo": rimNo,
      "custName": custName,
      "incomeNature": incomeNature,
      "lastYearAmount": lastYearAmount,
      "nextYearAmount": nextYearAmount,
      "nextYear2Amount": nextYear2Amount,
      "lastYearProfitability": lastYearProfitability,
      "nextYearProfitability": nextYearProfitability,
      "nextYear2Profitability": nextYear2Profitability,
      "createdBy": createdBy,
      "createdDate": fmt(createdDate),
      "updatedBy": updatedBy,
      "updatedDate": fmt(updatedDate),
    };
  }
}

/// Represents a comment associated with income summary data.
class IncomeComment {
  /// Creates an [IncomeComment] instance.
  IncomeComment({
    this.appRefNo,
    this.userId,
    this.userRole,
    this.commentCategoryId,
    this.comment,
    this.reasonList,
    this.isDraft,
    this.userAction,
    this.updatedDate,
    this.updatedBy,
    this.createdDate,
    this.createdBy,
  });

  /// Creates an [IncomeComment] instance from a JSON map.
  factory IncomeComment.fromJson(Map<String, dynamic> json) {
    DateTime? toDate(v) => v == null ? null : DateTime.tryParse(v as String);

    return IncomeComment(
      appRefNo: json["appRefNo"] as String?,
      userId: json["userId"] as String?,
      userRole: json["userRole"] as int?,
      commentCategoryId: json["commentCategoryId"] as int?,
      comment: json["comment"] as String?,
      reasonList: json["reasonList"] as List<dynamic>?, // could be null
      isDraft: json["isDraft"] as int?,
      userAction: json["userAction"] as int?,
      updatedDate: toDate(json["updatedDate"]),
      updatedBy: json["updatedBy"] as String?,
      createdDate: toDate(json["createdDate"]),
      createdBy: json["createdBy"] as String?,
    );
  }

  /// Application reference number.
  final String? appRefNo;

  /// User identifier.
  final String? userId;

  /// User role identifier.
  final int? userRole;

  /// Comment category identifier.
  final int? commentCategoryId;

  /// Comment text.
  final String? comment;

  /// List of comment reasons.
  ///
  /// keep dynamic if API returns mixed shapes
  final List<dynamic>? reasonList;

  /// Draft indicator.
  final int? isDraft;

  /// User action identifier.
  final int? userAction;

  /// Last update date.
  final DateTime? updatedDate;

  /// User who last updated the comment.
  final String? updatedBy;

  /// Comment creation date.
  final DateTime? createdDate;

  /// User who created the comment.
  final String? createdBy;

  /// Converts this [IncomeComment] instance to a JSON map.
  Map<String, dynamic> toJson() {
    String? fmt(DateTime? d) => d?.toUtc().toIso8601String();
    return {
      "appRefNo": appRefNo,
      "userId": userId,
      "userRole": userRole,
      "commentCategoryId": commentCategoryId,
      "comment": comment,
      "reasonList": reasonList,
      "isDraft": isDraft,
      "userAction": userAction,
      "updatedDate": fmt(updatedDate),
      "updatedBy": updatedBy,
      "createdDate": fmt(createdDate),
      "createdBy": createdBy,
    };
  }
}

/// Represents income summary response data.
class IncomeSummaryResponseData {
  /// Creates an [IncomeSummaryResponseData] instance.
  IncomeSummaryResponseData({
    required this.incomeSummaryDataList,
    this.appRefNo,
    this.comment,
  });

  /// Creates an [IncomeSummaryResponseData] instance from a JSON map.
  factory IncomeSummaryResponseData.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<dynamic>? rawList =
        json["incomeSummaryDataList"] as List<dynamic>?;
    return IncomeSummaryResponseData(
      appRefNo: json["appRefNo"] as String?,
      incomeSummaryDataList: (rawList ?? [])
          .map((e) => IncomeSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      comment: json["comment"] == null
          ? null
          : IncomeComment.fromJson(json["comment"] as Map<String, dynamic>),
    );
  }

  /// Application reference number.
  final String? appRefNo;

  /// Income summary records.
  final List<IncomeSummary> incomeSummaryDataList;

  /// Income summary comment.
  final IncomeComment? comment;

  /// Converts this [IncomeSummaryResponseData] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        "appRefNo": appRefNo,
        "incomeSummaryDataList":
            incomeSummaryDataList.map((e) => e.toJson()).toList(),
        "comment": comment?.toJson(),
      };
}
