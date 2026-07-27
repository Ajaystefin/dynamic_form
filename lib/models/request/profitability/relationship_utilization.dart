/// Represents relationship utilization information
/// for a customer.
class RelationshipUtilization {
  /// Creates a [RelationshipUtilization] instance.
  RelationshipUtilization({
    this.rim,
    this.customerName,
    this.clientTurnover,
    this.throughputToCbdPercentage,
    this.turnoverInCbdCua,
    this.relationshipRevenueDetails,
  });

  /// Creates a [RelationshipUtilization] instance from a JSON map.
  RelationshipUtilization.fromJson(
    Map<String, dynamic> json,
  ) {
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

  /// Customer RIM number.
  int? rim;

  /// Customer name.
  String? customerName;

  /// Client turnover.
  String? clientTurnover;

  /// Throughput to CBD percentage.
  String? throughputToCbdPercentage;

  /// Turnover in CBD CUA.
  String? turnoverInCbdCua;

  /// Relationship revenue details.
  List<RelationshipRevenueDetails>? relationshipRevenueDetails;

  /// Converts this [RelationshipUtilization] instance to a JSON map.
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

/// Represents relationship revenue details
/// for a specific product or commitment.
class RelationshipRevenueDetails {
  /// Creates a [RelationshipRevenueDetails] instance.
  RelationshipRevenueDetails({
    this.product,
    this.accountCommitmentNumber,
    this.accountLimit,
    this.averageUtilization,
    this.utilizationPercent,
  });

  /// Creates a [RelationshipRevenueDetails] instance from a JSON map.
  RelationshipRevenueDetails.fromJson(
    Map<String, dynamic> json,
  ) {
    product = json["product"] as String?;
    accountCommitmentNumber = json["accountCommitmentNumber"] as String?;

    // Parse JSON numbers safely as double
    accountLimit = json["accountLimit"];
    averageUtilization = json["averageUtilization"];
    utilizationPercent = json["utilizationPercent"];
  }

  /// Product name.
  String? product;

  /// Account commitment number.
  String? accountCommitmentNumber;

  /// Account limit.
  String? accountLimit;

  /// Average utilization.
  String? averageUtilization;

  /// Utilization percentage.
  String? utilizationPercent;

  /// Converts this [RelationshipRevenueDetails] instance to a JSON map.
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
