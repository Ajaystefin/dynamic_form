class RelationshipProfitabilityDetailed {
  int? rim;
  String? customerName;
  List<RelationshipProfitabilityDetail>? relationshipProfitabilityDetail;

  RelationshipProfitabilityDetailed(
      {this.rim, this.customerName, this.relationshipProfitabilityDetail});

  RelationshipProfitabilityDetailed.fromJson(Map<String, dynamic> json) {
    rim = json['rim'];
    customerName = json['customerName'];
    if (json['relationshipProfitabilityDetail'] != null) {
      relationshipProfitabilityDetail = <RelationshipProfitabilityDetail>[];
      json['relationshipProfitabilityDetail'].forEach((v) {
        relationshipProfitabilityDetail!
            .add(RelationshipProfitabilityDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rim'] = rim;
    data['customerName'] = customerName;
    if (relationshipProfitabilityDetail != null) {
      data['relationshipProfitabilityDetail'] =
          relationshipProfitabilityDetail!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RelationshipProfitabilityDetail {
  String? natureOfBusiness;
  int? last12Months;
  double? next12MonthsAmount;
  double? next12MonthsProfitabilityPercent;
  double? next12To24MonthsAmount;
  double? next12To24MonthsProfitabilityPercent;

  RelationshipProfitabilityDetail(
      {this.natureOfBusiness,
      this.last12Months,
      this.next12MonthsAmount,
      this.next12MonthsProfitabilityPercent,
      this.next12To24MonthsAmount,
      this.next12To24MonthsProfitabilityPercent});

  RelationshipProfitabilityDetail.fromJson(Map<String, dynamic> json) {
    natureOfBusiness = json['natureOfBusiness'];
    last12Months = json['last12Months'];
    next12MonthsAmount = json['next12MonthsAmount'];
    next12MonthsProfitabilityPercent = json['next12MonthsProfitabilityPercent'];
    next12To24MonthsAmount = json['next12To24MonthsAmount'];
    next12To24MonthsProfitabilityPercent =
        json['next12To24MonthsProfitabilityPercent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['natureOfBusiness'] = natureOfBusiness;
    data['last12Months'] = last12Months;
    data['next12MonthsAmount'] = next12MonthsAmount;
    data['next12MonthsProfitabilityPercent'] = next12MonthsProfitabilityPercent;
    data['next12To24MonthsAmount'] = next12To24MonthsAmount;
    data['next12To24MonthsProfitabilityPercent'] =
        next12To24MonthsProfitabilityPercent;
    return data;
  }
}
