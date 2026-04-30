class GuarantorsExposure {
  GuarantorsExposure({
    this.rimNo,
    this.custName,
    this.fundedPresentLimit,
    this.nonFundedPresentLimit,
    this.tangiblePresentSecurity,
    this.ccPresentSecurity,
    this.totalTangiblePresentSecurity,
    this.totalCCPresentSecurity,
    this.hasFacility,
    this.totalPresentLimits,
    this.presentNetSecurity,
    this.presentNetCC,
    this.totalFundNonfund,
    this.calTotalTangible,
    this.calofWhichCash,
  });

  GuarantorsExposure.fromJson(Map<String, dynamic> json) {
    rimNo = json["rimNo"] as int?;
    custName = json["custName"] as String?;
    fundedPresentLimit = json["fundedPresentLimit"] as int?;
    nonFundedPresentLimit = json["nonFundedPresentLimit"] as int?;
    tangiblePresentSecurity = json["tangiblePresentSecurity"] as int?;
    ccPresentSecurity = json["ccPresentSecurity"] as int?;
    totalTangiblePresentSecurity = json["totalTangiblePresentSecurity"] as int?;
    totalCCPresentSecurity = json["totalCCPresentSecurity"] as int?;
    hasFacility = json["hasFacility"] as bool?;
    totalPresentLimits = json["totalPresentLimits"] as int?;
    presentNetSecurity = json["presentNetSecurity"] as int?;
    presentNetCC = json["presentNetCC"] as int?;
    totalFundNonfund = (fundedPresentLimit ?? 0) + (nonFundedPresentLimit ?? 0);
    calTotalTangible =
        (totalFundNonfund ?? 0) - (totalTangiblePresentSecurity ?? 0);
    calofWhichCash = (totalFundNonfund ?? 0) - (totalCCPresentSecurity ?? 0);
  }
  int? rimNo;
  String? custName;
  int? fundedPresentLimit;
  int? nonFundedPresentLimit;
  int? tangiblePresentSecurity;
  int? ccPresentSecurity;
  int? totalTangiblePresentSecurity;
  int? totalCCPresentSecurity;
  bool? hasFacility;
  int? totalPresentLimits;
  int? presentNetSecurity;
  int? presentNetCC;
  int? totalFundNonfund;
  int? calTotalTangible;
  int? calofWhichCash;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["rimNo"] = rimNo;
    data["custName"] = custName;
    data["fundedPresentLimit"] = fundedPresentLimit;
    data["nonFundedPresentLimit"] = nonFundedPresentLimit;
    data["tangiblePresentSecurity"] = tangiblePresentSecurity;
    data["ccPresentSecurity"] = ccPresentSecurity;
    data["totalTangiblePresentSecurity"] = totalTangiblePresentSecurity;
    data["totalCCPresentSecurity"] = totalCCPresentSecurity;
    data["hasFacility"] = hasFacility;
    data["totalPresentLimits"] = totalPresentLimits;
    data["presentNetSecurity"] = presentNetSecurity;
    data["presentNetCC"] = presentNetCC;
    return data;
  }
}
