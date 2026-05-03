class RelationshipUtilization {
  RelationshipUtilization({
    this.rim,
    this.customerName,
    this.clientTurnover,
    this.throughputToCbdPercentage,
    this.turnoverInCbdCua,
    this.relationshipRevenueDetails,
  });

  RelationshipUtilization.fromJson(Map<String, dynamic> json) {
    rim = json["rim"] as int?;
    customerName = json["customerName"] as String?;
    clientTurnover = json["clientTurnover"].toString();
    throughputToCbdPercentage = json["throughputToCbdPercentage"].toString();
    turnoverInCbdCua = json["turnoverInCbdCua"].toString();

    // Accept both backend key and your desired key
    final dynamic detailsRaw = json["relationshipRevenueDetails"] ??
        json["relationShipRevenueDetails"];

    if (detailsRaw is List) {
      relationshipRevenueDetails = detailsRaw
          .where((e) => e != null)
          .map(
            (e) =>
                RelationshipRevenueDetails.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } else {
      relationshipRevenueDetails = <RelationshipRevenueDetails>[];
    }
  }
  int? rim;
  String? customerName;
  String? clientTurnover;
  String? throughputToCbdPercentage;
  String? turnoverInCbdCua;

  /// The list your UI reads
  List<RelationshipRevenueDetails>? relationshipRevenueDetails;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["rim"] = rim;
    data["customerName"] = customerName;
    data["clientTurnover"] = clientTurnover;
    data["throughputToCbdPercentage"] = throughputToCbdPercentage;
    data["turnoverInCbdCua"] = turnoverInCbdCua;

    if (relationshipRevenueDetails != null) {
      data["relationshipRevenueDetails"] =
          relationshipRevenueDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RelationshipRevenueDetails {
  RelationshipRevenueDetails({
    this.product,
    this.accountCommitmentNumber,
    this.accountLimit,
    this.averageUtilization,
    this.utilizationPercent,
  });

  RelationshipRevenueDetails.fromJson(Map<String, dynamic> json) {
    product = json["product"] as String?;
    accountCommitmentNumber = json["accountCommitmentNumber"] as String?;

    // Parse JSON numbers safely as double
    accountLimit = json["accountLimit"];
    averageUtilization = json["averageUtilization"];
    utilizationPercent = json["utilizationPercent"];
  }
  String? product;
  String? accountCommitmentNumber;
  String? accountLimit;
  String? averageUtilization;
  String? utilizationPercent;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["product"] = product;
    data["accountCommitmentNumber"] = accountCommitmentNumber;
    data["accountLimit"] = accountLimit;
    data["averageUtilization"] = averageUtilization;
    data["utilizationPercent"] = utilizationPercent;
    return data;
  }
}
