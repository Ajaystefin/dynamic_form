/// Represents detailed relationship profitability information
/// for a customer.
class RelationshipProfitabilityDetailed {
  /// Creates a [RelationshipProfitabilityDetailed] instance.
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

  /// Creates a [RelationshipProfitabilityDetailed] instance from a JSON map.
  RelationshipProfitabilityDetailed.fromJson(
    Map<String, dynamic> json,
  ) {
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

  /// Relationship income identifier.
  int? relationshipIncomeId;

  /// Customer RIM number.
  int? rim;

  /// Customer name.
  String? customerName;

  /// Income nature.
  String? incomeNature;

  /// Last year amount.
  String? lastYearAmount;

  /// Next year amount.
  String? nextYearAmount;

  /// Year-after-next amount.
  String? nextYear2Amount;

  /// Last year profitability.
  String? lastYearProfitability;

  /// Next year profitability.
  String? nextYearProfitability;

  /// Year-after-next profitability.
  String? nextYear2Profitability;

  /// User who created the record.
  String? createdBy;

  /// Record creation date.
  String? createdDate;

  /// User who last updated the record.
  String? updatedBy;

  /// Record last update date.
  String? updatedDate;

  /// Relationship profitability details.
  List<RelationshipProfitabilityDetail>? relationshipProfitabilityDetail;

  /// Converts this [RelationshipProfitabilityDetailed]
  /// instance to a JSON map.
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

/// Represents profitability details for a specific
/// nature of business.
class RelationshipProfitabilityDetail {
  /// Creates a [RelationshipProfitabilityDetail] instance.
  RelationshipProfitabilityDetail({
    this.natureOfBusiness,
    this.last12Months,
    this.next12MonthsAmount,
    this.next12MonthsProfitabilityPercent,
    this.next12To24MonthsAmount,
    this.next12To24MonthsProfitabilityPercent,
  });

  /// Creates a [RelationshipProfitabilityDetail] instance from a JSON map.
  RelationshipProfitabilityDetail.fromJson(
    Map<String, dynamic> json,
  ) {
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

  /// Nature of business.
  String? natureOfBusiness;

  /// Last 12 months amount.
  String? last12Months;

  /// Next 12 months amount.
  String? next12MonthsAmount;

  /// Next 12 months profitability percentage.
  String? next12MonthsProfitabilityPercent;

  /// Next 12 to 24 months amount.
  String? next12To24MonthsAmount;

  /// Next 12 to 24 months profitability percentage.
  String? next12To24MonthsProfitabilityPercent;

  /// Converts this [RelationshipProfitabilityDetail]
  /// instance to a JSON map.
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
