class RelationshipProfitabilityDetailed {
  RelationshipProfitabilityDetailed({
    this.relationshipIncomeId,
    this.rim,
    this.customerName,
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
    this.relationshipProfitabilityDetail,
  });

  RelationshipProfitabilityDetailed.fromJson(Map<String, dynamic> json) {
    relationshipIncomeId = (json["relationshipIncomeId"] as num?)?.toInt();
    rim = (json["rim"] as num?)?.toInt() ?? (json["rimNo"] as num?)?.toInt();
    customerName =
        json["customerName"] as String? ?? json["custName"] as String?;
    incomeNature =
        json["incomeNature"] as String? ?? json["natureOfBusiness"] as String?;

    lastYearAmount = json[
        "lastYearAmount"]; // (json['lastYearAmount'] as num?)?.toDouble() ??
    (json["last12Months"] as num?)?.toDouble();
    nextYearAmount = json["nextYearAmount"];
    // (json['nextYearAmount'] as num?)?.toDouble();
    nextYear2Amount = json["nextYear2Amount"];
    // (json['nextYear2Amount'] as num?)?.toDouble();
    lastYearProfitability = json["lastYearProfitability"];
    // (json['lastYearProfitability'] as num?)?.toDouble();
    nextYearProfitability = json["nextYearProfitability"] ??
        json["next12MonthsProfitabilityPercent"];
    // (json['nextYearProfitability'] as num?)?.toDouble() ??
    // (json['next12MonthsProfitabilityPercent'] as num?)?.toDouble();
    nextYear2Profitability = json["nextYear2Profitability"] ??
        json["next12To24MonthsProfitabilityPercent"];
    // (json['nextYear2Profitability'] as num?)?.toDouble() ??
    // (json['next12To24MonthsProfitabilityPercent'] as num?)?.toDouble();

    createdBy = json["createdBy"] as String?;
    createdDate = json["createdDate"] as String?;
    updatedBy = json["updatedBy"] as String?;
    updatedDate = json["updatedDate"] as String?;

    if (json["relationshipProfitabilityDetail"] is List) {
      final list = (json["relationshipProfitabilityDetail"] as List)
          .whereType<Map<String, dynamic>>()
          .map(RelationshipProfitabilityDetail.fromJson)
          .toList();
      relationshipProfitabilityDetail = list;
    } else {
      final detail = RelationshipProfitabilityDetail(
        natureOfBusiness: incomeNature,
        last12Months: lastYearAmount,
        next12MonthsAmount: nextYearAmount,
        next12MonthsProfitabilityPercent: nextYearProfitability,
        next12To24MonthsAmount: nextYear2Amount,
        next12To24MonthsProfitabilityPercent: nextYear2Profitability,
      );
      relationshipProfitabilityDetail = [detail];
    }
  }
  int? relationshipIncomeId;
  int? rim;
  String? customerName;
  String? incomeNature;
  String? lastYearAmount;
  String? nextYearAmount;
  String? nextYear2Amount;
  String? lastYearProfitability;
  String? nextYearProfitability;
  String? nextYear2Profitability;
  String? createdBy;
  String? createdDate;
  String? updatedBy;
  String? updatedDate;
  List<RelationshipProfitabilityDetail>? relationshipProfitabilityDetail;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["relationshipIncomeId"] = relationshipIncomeId;
    data["rim"] = rim;
    data["customerName"] = customerName;
    data["incomeNature"] = incomeNature;
    data["lastYearAmount"] = lastYearAmount;
    data["nextYearAmount"] = nextYearAmount;
    data["nextYear2Amount"] = nextYear2Amount;
    data["lastYearProfitability"] = lastYearProfitability;
    data["nextYearProfitability"] = nextYearProfitability;
    data["nextYear2Profitability"] = nextYear2Profitability;
    data["createdBy"] = createdBy;
    data["createdDate"] = createdDate;
    data["updatedBy"] = updatedBy;
    data["updatedDate"] = updatedDate;
    if (relationshipProfitabilityDetail != null) {
      data["relationshipProfitabilityDetail"] =
          relationshipProfitabilityDetail!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RelationshipProfitabilityDetail {
  RelationshipProfitabilityDetail({
    this.natureOfBusiness,
    this.last12Months,
    this.next12MonthsAmount,
    this.next12MonthsProfitabilityPercent,
    this.next12To24MonthsAmount,
    this.next12To24MonthsProfitabilityPercent,
  });

  RelationshipProfitabilityDetail.fromJson(Map<String, dynamic> json) {
    natureOfBusiness =
        json["natureOfBusiness"] as String? ?? json["incomeNature"] as String?;
    last12Months = json["last12Months"] ?? json["lastYearAmount"];
    next12MonthsAmount = json["next12MonthsAmount"] ?? json["nextYearAmount"];
    next12MonthsProfitabilityPercent =
        json["next12MonthsProfitabilityPercent"] ??
            json["nextYearProfitability"];
    next12To24MonthsAmount =
        json["next12To24MonthsAmount"] ?? json["nextYear2Amount"];
    next12To24MonthsProfitabilityPercent =
        json["next12To24MonthsProfitabilityPercent"] ??
            json["nextYear2Profitability"];
  }
  String? natureOfBusiness;
  String? last12Months;
  String? next12MonthsAmount;
  String? next12MonthsProfitabilityPercent;
  String? next12To24MonthsAmount;
  String? next12To24MonthsProfitabilityPercent;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["natureOfBusiness"] = natureOfBusiness;
    data["last12Months"] = last12Months;
    data["next12MonthsAmount"] = next12MonthsAmount;
    data["next12MonthsProfitabilityPercent"] = next12MonthsProfitabilityPercent;
    data["next12To24MonthsAmount"] = next12To24MonthsAmount;
    data["next12To24MonthsProfitabilityPercent"] =
        next12To24MonthsProfitabilityPercent;
    return data;
  }
}
