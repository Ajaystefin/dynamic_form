/// Represents guarantor exposure details including present limits,
/// securities, calculated totals, and facility information.
class GuarantorsExposure {
  /// Creates a [GuarantorsExposure] instance.
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

  /// Creates a [GuarantorsExposure] instance from a JSON map.
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

  /// Customer RIM number.
  int? rimNo;

  /// Customer name.
  String? custName;

  /// Funded present limit amount.
  int? fundedPresentLimit;

  /// Non-funded present limit amount.
  int? nonFundedPresentLimit;

  /// Tangible present security amount.
  int? tangiblePresentSecurity;

  /// Cash collateral present security amount.
  int? ccPresentSecurity;

  /// Total tangible present security amount.
  int? totalTangiblePresentSecurity;

  /// Total cash collateral present security amount.
  int? totalCCPresentSecurity;

  /// Indicates whether the guarantor has a facility.
  bool? hasFacility;

  /// Total present limits amount.
  int? totalPresentLimits;

  /// Present net security amount.
  int? presentNetSecurity;

  /// Present net cash collateral amount.
  int? presentNetCC;

  /// Total funded and non-funded present limit amount.
  int? totalFundNonfund;

  /// Calculated total tangible exposure amount.
  int? calTotalTangible;

  /// Calculated cash collateral exposure amount.
  int? calofWhichCash;

  /// Converts this [GuarantorsExposure] instance into a JSON map.
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
