class GroupPosition {
  List<Position>? presentPosition;
  List<Position>? proposedPosition;
  GroupPosition({this.presentPosition, this.proposedPosition});
  GroupPosition.fromJson(Map<String, dynamic> json) {
    if (json['present_position'] != null) {
      presentPosition = <Position>[];
      json['present_position'].forEach((v) {
        presentPosition!.add(Position.fromJson(v));
      });
    }
    if (json['proposed_position'] != null) {
      proposedPosition = <Position>[];
      json['proposed_position'].forEach((v) {
        proposedPosition!.add(Position.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (presentPosition != null) {
      data['present_position'] =
          presentPosition!.map((v) => v.toJson()).toList();
    }
    if (proposedPosition != null) {
      data['proposed_position'] =
          proposedPosition!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Position {
  String? customerName;
  int? modelGeneratedCRR;
  int? overriddenCRR;
  double? fundBasedLimits;
  double? nonFundBasedLimits;
  double? totalLimits;
  double? totalTangibleSecurity;
  double? ofWhichCashCollateral;
  double? totalLimitsNetOfTotalTangibleSecurity;
  double? totalLimitsNetOfCashCollateralOnly;
  Position(
      {this.customerName,
      this.modelGeneratedCRR,
      this.overriddenCRR,
      this.fundBasedLimits,
      this.nonFundBasedLimits,
      this.totalLimits,
      this.totalTangibleSecurity,
      this.ofWhichCashCollateral,
      this.totalLimitsNetOfTotalTangibleSecurity,
      this.totalLimitsNetOfCashCollateralOnly});
  Position.fromJson(Map<String, dynamic> json) {
    customerName = json['customerName'];
    modelGeneratedCRR = json['modelGeneratedCRR'];
    overriddenCRR = json['overriddenCRR'];
    fundBasedLimits = json['fundBasedLimits'];
    nonFundBasedLimits = json['nonFundBasedLimits'];
    totalLimits = json['totalLimits'];
    totalTangibleSecurity = json['totalTangibleSecurity'];
    ofWhichCashCollateral = json['ofWhichCashCollateral'];
    totalLimitsNetOfTotalTangibleSecurity =
        json['totalLimitsNetOfTotalTangibleSecurity'];
    totalLimitsNetOfCashCollateralOnly =
        json['totalLimitsNetOfCashCollateralOnly'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['customerName'] = customerName;
    data['modelGeneratedCRR'] = modelGeneratedCRR;
    data['overriddenCRR'] = overriddenCRR;
    data['fundBasedLimits'] = fundBasedLimits;
    data['nonFundBasedLimits'] = nonFundBasedLimits;
    data['totalLimits'] = totalLimits;
    data['totalTangibleSecurity'] = totalTangibleSecurity;
    data['ofWhichCashCollateral'] = ofWhichCashCollateral;
    data['totalLimitsNetOfTotalTangibleSecurity'] =
        totalLimitsNetOfTotalTangibleSecurity;
    data['totalLimitsNetOfCashCollateralOnly'] =
        totalLimitsNetOfCashCollateralOnly;
    return data;
  }
}

class CustomerPosition {
  final String customerName;
  final List<String> presentRowValues; //  existing CRR values
  final List<String> proposedRowValues; // values for all other columns

  CustomerPosition({
    required this.customerName,
    required this.presentRowValues,
    required this.proposedRowValues,
  });
}
