class RelationshipUtilization {
  int? rim;
  String? customerName;
  double? clientTurnover;
  double? throughputToCbdPercentage;
  double? turnoverInCbdCua;
  List<RelationshipRevenueDetails>? relationshipRevenueDetails;

  RelationshipUtilization(
      {this.rim,
      this.customerName,
      this.clientTurnover,
      this.throughputToCbdPercentage,
      this.turnoverInCbdCua,
      this.relationshipRevenueDetails});

  RelationshipUtilization.fromJson(Map<String, dynamic> json) {
    rim = json['rim'];
    customerName = json['customerName'];
    clientTurnover = json['clientTurnover'];
    throughputToCbdPercentage = json['throughputToCbdPercentage'];
    turnoverInCbdCua = json['turnoverInCbdCua'];
    if (json['relationshipUtilization'] != null) {
      relationshipRevenueDetails = <RelationshipRevenueDetails>[];
      json["relationshipUtilization"].forEach((v) {
        relationshipRevenueDetails!.add(RelationshipRevenueDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rim'] = rim;
    data['customerName'] = customerName;
    data['clientTurnover'] = clientTurnover;
    data['throughputToCbdPercentage'] = throughputToCbdPercentage;
    data['turnoverInCbdCua'] = turnoverInCbdCua;
    if (relationshipRevenueDetails != null) {
      data['relationshipRevenueDetails'] =
          relationshipRevenueDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RelationshipRevenueDetails {
  String? product;
  String? accountCommitmentNumber;
  int? accountLimit;
  double? averageUtilization;
  int? utilizationPercent;

  RelationshipRevenueDetails(
      {this.product,
      this.accountCommitmentNumber,
      this.accountLimit,
      this.averageUtilization,
      this.utilizationPercent});

  RelationshipRevenueDetails.fromJson(Map<String, dynamic> json) {
    product = json['product'];
    accountCommitmentNumber = json['accountCommitmentNumber'];
    accountLimit = json['accountLimit'];
    averageUtilization = json['averageUtilization'];
    utilizationPercent = json['utilizationPercent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product'] = product;
    data['accountCommitmentNumber'] = accountCommitmentNumber;
    data['accountLimit'] = accountLimit;
    data['averageUtilization'] = averageUtilization;
    data['utilizationPercent'] = utilizationPercent;
    return data;
  }
}
