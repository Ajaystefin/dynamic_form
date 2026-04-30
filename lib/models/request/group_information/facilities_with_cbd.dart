class FacilitiesWithCbd {
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
  String? customerName;
  int? customerRim;
  String? cbrbClassification;
  double? crr;
  double? fundedCurrentLimit;
  double? nonFundedCurrentLimit;
  double? fundedProposedLimit;
  double? nonFundedProposedLimit;
  double? fundedOutstanding;
  double? fundedPastDues;
  double? nonFundedOutstanding;
  double? nonFundedPastDues;
  String? category;
  double? previousApprovedCrr;

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
