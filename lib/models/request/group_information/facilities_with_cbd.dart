/// Represents facilities with CBD information for a customer,
/// including limits, outstanding amounts, and risk classifications.
class FacilitiesWithCbd {
  /// Creates a [FacilitiesWithCbd] instance.
  FacilitiesWithCbd({
    this.customerName,
    this.customerRim,
    this.cbrbClassification,
    this.crr,
    this.fundedCurrentLimit,
    this.nonFundedCurrentLimit,
    this.fundedProposedLimit,
    this.nonFundedProposedLimit,
    this.fundedOutstanding,
    this.fundedPastDues,
    this.nonFundedOutstanding,
    this.nonFundedPastDues,
    this.category,
    this.previousApprovedCrr,
  });

  /// Creates a [FacilitiesWithCbd] instance from a JSON map.
  FacilitiesWithCbd.fromJson(Map<String, dynamic> json) {
    customerName = json["customerName"];
    customerRim = json["customerRim"];
    cbrbClassification = json["cbrbClassification"];
    crr = json["crr"];
    fundedCurrentLimit = json["fundedCurrentLimit"];
    nonFundedCurrentLimit = json["nonFundedCurrentLimit"];
    fundedProposedLimit = json["fundedProposedLimit"];
    nonFundedProposedLimit = json["nonFundedProposedLimit"];
    fundedOutstanding = json["fundedOutstanding"];
    fundedPastDues = json["fundedPastDues"];
    nonFundedOutstanding = json["nonFundedOutstanding"];
    nonFundedPastDues = json["nonFundedPastDues"];
    category = json["category"];
    previousApprovedCrr = json["previousApprovedCrr"];
  }

  /// Customer name.
  String? customerName;

  /// Customer RIM number.
  int? customerRim;

  /// CBRB classification.
  String? cbrbClassification;

  /// Current risk rating.
  double? crr;

  /// Current funded limit.
  double? fundedCurrentLimit;

  /// Current non-funded limit.
  double? nonFundedCurrentLimit;

  /// Proposed funded limit.
  double? fundedProposedLimit;

  /// Proposed non-funded limit.
  double? nonFundedProposedLimit;

  /// Funded outstanding amount.
  double? fundedOutstanding;

  /// Funded past dues amount.
  double? fundedPastDues;

  /// Non-funded outstanding amount.
  double? nonFundedOutstanding;

  /// Non-funded past dues amount.
  double? nonFundedPastDues;

  /// Customer category.
  String? category;

  /// Previously approved CRR.
  double? previousApprovedCrr;

  /// Converts this [FacilitiesWithCbd] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["customerName"] = customerName;
    data["customerRim"] = customerRim;
    data["cbrbClassification"] = cbrbClassification;
    data["crr"] = crr;
    data["fundedCurrentLimit"] = fundedCurrentLimit;
    data["nonFundedCurrentLimit"] = nonFundedCurrentLimit;
    data["fundedProposedLimit"] = fundedProposedLimit;
    data["nonFundedProposedLimit"] = nonFundedProposedLimit;
    data["fundedOutstanding"] = fundedOutstanding;
    data["fundedPastDues"] = fundedPastDues;
    data["nonFundedOutstanding"] = nonFundedOutstanding;
    data["nonFundedPastDues"] = nonFundedPastDues;
    data["category"] = category;
    data["previousApprovedCrr"] = previousApprovedCrr;
    return data;
  }
}
