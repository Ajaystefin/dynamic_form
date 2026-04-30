class IncomeSummary {
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

  factory IncomeSummary.fromJson(Map<String, dynamic> json) {
    // double? toDouble(dynamic v) =>
    //     v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));

    DateTime? toDate(dynamic v) =>
        v == null ? null : DateTime.tryParse(v as String);

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
  final int? relationshipIncomeId;
  final int? rimNo;
  final String? custName;
  final String? incomeNature;
  final String? lastYearAmount;
  final String? nextYearAmount;
  final String? nextYear2Amount;
  final String? lastYearProfitability;
  final String? nextYearProfitability;
  final String? nextYear2Profitability;
  final String? createdBy;
  final DateTime? createdDate;
  final String? updatedBy;
  final DateTime? updatedDate;

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

class IncomeComment {
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

  factory IncomeComment.fromJson(Map<String, dynamic> json) {
    DateTime? toDate(dynamic v) =>
        v == null ? null : DateTime.tryParse(v as String);

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
  final String? appRefNo;
  final String? userId;
  final int? userRole;
  final int? commentCategoryId;
  final String? comment;
  final List<dynamic>? reasonList; // keep dynamic if API returns mixed shapes
  final int? isDraft;
  final int? userAction;
  final DateTime? updatedDate;
  final String? updatedBy;
  final DateTime? createdDate;
  final String? createdBy;

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

class IncomeSummaryResponseData {
  IncomeSummaryResponseData({
    required this.incomeSummaryDataList,
    this.appRefNo,
    this.comment,
  });

  factory IncomeSummaryResponseData.fromJson(Map<String, dynamic> json) {
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
  final String? appRefNo;
  final List<IncomeSummary> incomeSummaryDataList;
  final IncomeComment? comment;

  Map<String, dynamic> toJson() => {
        "appRefNo": appRefNo,
        "incomeSummaryDataList":
            incomeSummaryDataList.map((e) => e.toJson()).toList(),
        "comment": comment?.toJson(),
      };
}
