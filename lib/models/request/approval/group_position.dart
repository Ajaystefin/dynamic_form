/// Represents group position details with present and proposed positions.
class GroupPosition {
  /// Creates a [GroupPosition] instance.
  GroupPosition({this.presentPosition, this.proposedPosition});

  /// Creates a [GroupPosition] instance from a JSON map.
  GroupPosition.fromJson(Map<String, dynamic> json) {
    if (json["present_position"] != null) {
      presentPosition = <Position>[];
      json["present_position"].forEach((v) {
        presentPosition!.add(Position.fromJson(v));
      });
    }
    if (json["proposed_position"] != null) {
      proposedPosition = <Position>[];
      json["proposed_position"].forEach((v) {
        proposedPosition!.add(Position.fromJson(v));
      });
    }
  }

  /// List of present position details.
  List<Position>? presentPosition;

  /// List of proposed position details.
  List<Position>? proposedPosition;

  /// Converts this [GroupPosition] instance into a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (presentPosition != null) {
      data["present_position"] =
          presentPosition!.map((v) => v.toJson()).toList();
    }
    if (proposedPosition != null) {
      data["proposed_position"] =
          proposedPosition!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

/// Represents customer position details including limits, securities,
/// past dues, outstanding amounts, and related position values.
class Position {
  /// Creates a [Position] instance.
  Position({
    this.customerName,
    this.modelGeneratedCRR,
    this.overriddenCRR,
    this.fundBasedLimits,
    this.nonFundBasedLimits,
    this.totalLimits,
    this.tangibleSecurity,
    this.totalTangibleSecurity,
    this.ofWhichCashCollateral,
    this.totalLimitsNetOfTotalTangibleSecurity,
    this.totalLimitsNetOfCashCollateralOnly,
    this.ccSecurity,
    this.hasFacility,
    this.totalCCSecurity,
    this.netSecurity,
    this.netCC,
    this.isProposed,
    this.linkedCCSecurities,
    this.linkedTangibleSecurities,
    this.order,
    this.fundedPastdues,
    this.nonFundedPastdues,
    this.totalPastdues,
    this.fundedOutstanding,
    this.nonFundedOutstanding,
    this.totalOutstanding,
    this.rimNo,
  });

  /// Creates a [Position] instance from a JSON map.
  Position.fromJson(Map<String, dynamic> json) {
    customerName = json["customerName"];
    modelGeneratedCRR = json["modelGeneratedCRR"];
    overriddenCRR = json["overriddenCRR"];
    fundBasedLimits = json["fundBasedLimits"];
    nonFundBasedLimits = json["nonFundBasedLimits"];
    totalLimits = json["totalLimits"];
    totalTangibleSecurity = json["totalTangibleSecurity"];
    ofWhichCashCollateral = json["totalCCProposedSecurity"];
    totalLimitsNetOfTotalTangibleSecurity =
        json["totalLimitsNetOfTotalTangibleSecurity"];
    totalLimitsNetOfCashCollateralOnly =
        json["totalLimitsNetOfCashCollateralOnly"];
    ccSecurity = json[""];
    hasFacility = json[""];
    totalCCSecurity = json[""];
    netSecurity = json[""];
    netCC = json[""];
    isProposed = json[""];
    linkedCCSecurities = json[""];
    linkedTangibleSecurities = json[""];
    order = json[""];
    fundedPastdues = json[""];
    nonFundedPastdues = json[""];
    totalPastdues = json[""];
    fundedOutstanding = json[""];
    nonFundedOutstanding = json[""];
    totalOutstanding = json[""];
    rimNo = json["rimNo"] ?? 0;
  }

  /// Creates a proposed [Position] instance from a JSON map.
  Position.fromJsonProposed(Map<String, dynamic> json) {
    customerName = json["custName"] ?? "";
    modelGeneratedCRR = json["modelCRR"] ?? 0;
    overriddenCRR = json["overriddenCRR"] ?? 0;
    fundBasedLimits = (json["fundedProposedLimit"] as num?)?.toDouble() ?? 0.0;
    nonFundBasedLimits =
        (json["nonFundedProposedLimit"] as num?)?.toDouble() ?? 0.0;
    totalLimits = (json["totalProposedLimits"] as num?)?.toDouble() ?? 0.0;
    tangibleSecurity =
        (json["tangibleProposedSecurity"] as num?)?.toDouble() ?? 0.0;
    totalTangibleSecurity =
        (json["totalTangibleProposedSecurity"] as num?)?.toDouble() ?? 0.0;
    ofWhichCashCollateral =
        (json["totalCCProposedSecurity"] as num?)?.toDouble() ?? 0.0;
    ccSecurity = (json["ccProposedSecurity"] as num?)?.toDouble() ?? 0.0;
    hasFacility = json["hasFacility"] ?? false;
    totalCCSecurity =
        (json["totalCCProposedSecurity"] as num?)?.toDouble() ?? 0.0;
    totalLimitsNetOfTotalTangibleSecurity =
        (json["proposedNetSecurity"] as num?)?.toDouble() ?? 0.0;
    totalLimitsNetOfCashCollateralOnly =
        (json["proposedNetCC"] as num?)?.toDouble() ?? 0.0;
    netSecurity = (json["proposedNetSecurity"] as num?)?.toDouble() ?? 0.0;
    netCC = (json["proposedNetCC"] as num?)?.toDouble() ?? 0.0;
    isProposed = json["isProposed"] ?? false;
    linkedCCSecurities = json["linkedCCSecurities"] ?? 0;
    linkedTangibleSecurities = json["linkedTangibleSecurities"] ?? 0;
    order = json["order"] ?? 0;
    fundedPastdues = (json["fundedPastdues"] as num?)?.toDouble() ?? 0.0;
    nonFundedPastdues = (json["nonFundedPastdues"] as num?)?.toDouble() ?? 0.0;
    totalPastdues = (json["totalPastdues"] as num?)?.toDouble() ?? 0.0;
    fundedOutstanding = (json["fundedOutstanding"] as num?)?.toDouble() ?? 0.0;
    nonFundedOutstanding =
        (json["nonFundedOutstanding"] as num?)?.toDouble() ?? 0.0;
    totalOutstanding = (json["totalOutstanding"] as num?)?.toDouble() ?? 0.0;
    rimNo = json["rimNo"] ?? 0;
  }

  /// Creates a present [Position] instance from a JSON map.
  Position.fromJsonPresent(Map<String, dynamic> json) {
    customerName = json["custName"] ?? "";
    modelGeneratedCRR = json["modelCRR"] ?? 0;
    overriddenCRR = json["overriddenCRR"] ?? 0;
    fundBasedLimits = (json["fundedPresentLimit"] as num?)?.toDouble() ?? 0.0;
    nonFundBasedLimits =
        (json["nonFundedPresentLimit"] as num?)?.toDouble() ?? 0.0;
    totalLimits = (json["totalPresentLimits"] as num?)?.toDouble() ?? 0.0;
    tangibleSecurity =
        (json["tangiblePresentSecurity"] as num?)?.toDouble() ?? 0.0;
    totalTangibleSecurity =
        (json["totalTangiblePresentSecurity"] as num?)?.toDouble() ?? 0.0;
    ofWhichCashCollateral =
        (json["totalCCPresentSecurity"] as num?)?.toDouble() ?? 0.0;
    totalLimitsNetOfTotalTangibleSecurity =
        (json["presentNetSecurity"] as num?)?.toDouble() ?? 0.0;
    totalLimitsNetOfCashCollateralOnly =
        (json["presentNetCC"] as num?)?.toDouble() ?? 0.0;
    ccSecurity = (json["ccPresentSecurity"] as num?)?.toDouble() ?? 0.0;
    hasFacility = json["hasFacility"] ?? false;
    ccSecurity = (json["ccPresentSecurity"] as num?)?.toDouble() ?? 0.0;
    totalCCSecurity =
        (json["totalCCPresentSecurity"] as num?)?.toDouble() ?? 0.0;
    netSecurity = (json["presentNetSecurity"] as num?)?.toDouble() ?? 0.0;
    netCC = (json["presentNetCC"] as num?)?.toDouble() ?? 0.0;
    isProposed = json["isProposed"] ?? false;
    linkedCCSecurities = json["linkedCCSecurities"] ?? 0;
    linkedTangibleSecurities = json["linkedTangibleSecurities"] ?? 0;
    order = json["order"] ?? 0;
    fundedPastdues = (json["fundedPastdues"] as num?)?.toDouble() ?? 0.0;
    nonFundedPastdues = (json["nonFundedPastdues"] as num?)?.toDouble() ?? 0.0;
    totalPastdues = (json["totalPastdues"] as num?)?.toDouble() ?? 0.0;
    fundedOutstanding = (json["fundedOutstanding"] as num?)?.toDouble() ?? 0.0;
    nonFundedOutstanding =
        (json["nonFundedOutstanding"] as num?)?.toDouble() ?? 0.0;
    totalOutstanding = (json["totalOutstanding"] as num?)?.toDouble() ?? 0.0;
    rimNo = json["rimNo"] ?? 0;
  }

  /// Customer name.
  String? customerName;

  /// Model generated CRR value.
  int? modelGeneratedCRR;

  /// Overridden CRR value.
  int? overriddenCRR;

  /// Fund based limits amount.
  double? fundBasedLimits;

  /// Non-fund based limits amount.
  double? nonFundBasedLimits;

  /// Total limits amount.
  double? totalLimits;

  /// Tangible security amount.
  double? tangibleSecurity;

  /// Total tangible security amount.
  double? totalTangibleSecurity;

  /// Cash collateral amount.
  double? ofWhichCashCollateral;

  /// Total limits net of total tangible security amount.
  double? totalLimitsNetOfTotalTangibleSecurity;

  /// Total limits net of cash collateral only amount.
  double? totalLimitsNetOfCashCollateralOnly;

  /// Cash collateral security amount.
  double? ccSecurity;

  /// Indicates whether the customer has a facility.
  bool? hasFacility;

  /// Total cash collateral security amount.
  double? totalCCSecurity;

  /// Net security amount.
  double? netSecurity;

  /// Net cash collateral amount.
  double? netCC;

  /// Indicates whether the position is proposed.
  bool? isProposed;

  /// Linked cash collateral securities.
  dynamic linkedCCSecurities;

  /// Linked tangible securities.
  dynamic linkedTangibleSecurities;

  /// Display order of the position.
  int? order;

  /// Funded past dues amount.
  double? fundedPastdues;

  /// Non-funded past dues amount.
  double? nonFundedPastdues;

  /// Total past dues amount.
  double? totalPastdues;

  /// Funded outstanding amount.
  double? fundedOutstanding;

  /// Non-funded outstanding amount.
  double? nonFundedOutstanding;

  /// Total outstanding amount.
  double? totalOutstanding;

  /// Customer RIM number.
  int? rimNo;

  /// Converts this [Position] instance into a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["customerName"] = customerName;
    data["modelGeneratedCRR"] = modelGeneratedCRR;
    data["overriddenCRR"] = overriddenCRR;
    data["fundBasedLimits"] = fundBasedLimits;
    data["nonFundBasedLimits"] = nonFundBasedLimits;
    data["totalLimits"] = totalLimits;
    data["totalTangibleSecurity"] = totalTangibleSecurity;
    data["ofWhichCashCollateral"] = ofWhichCashCollateral;
    data["totalLimitsNetOfTotalTangibleSecurity"] =
        totalLimitsNetOfTotalTangibleSecurity;
    data["totalLimitsNetOfCashCollateralOnly"] =
        totalLimitsNetOfCashCollateralOnly;
    return data;
  }
}

/// Represents customer position row values for present and proposed positions.
class CustomerPosition {
  // values for all other columns

  /// Creates a [CustomerPosition] instance.
  CustomerPosition({
    required this.customerName,
    required this.rimNo,
    required this.order,
    required this.presentRowValues,
    required this.proposedRowValues,
  });

  /// Customer name.
  final String customerName;

  /// Customer RIM number.
  final String rimNo;

  /// Display order of the customer position.
  final int? order;

  /// Present row values.
  final List<String> presentRowValues; //  existing CRR values

  /// Proposed row values.
  final List<String> proposedRowValues;
}
