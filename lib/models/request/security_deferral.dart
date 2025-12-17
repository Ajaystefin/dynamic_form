import 'package:wcas_frontend/core/utils/date_time_utils.dart';

class SecurityDeferral {
  String? securityNo;
  int? securityId;
  int? securityType;
  double? present;
  double? proposed;
  double? aedPresent;
  double? aedProposed;
  bool? allFacilities;
  bool? selected;
  bool? draft;
  bool isChecked = false;
  List<FacilityDetail>? facilityDetails;
  DateTime? dateDeferral;

  SecurityDeferral(
      {this.securityNo,
      this.securityId,
      this.securityType,
      this.present,
      this.proposed,
      this.aedPresent,
      this.aedProposed,
      this.allFacilities,
      this.selected,
      this.draft,
      this.isChecked = false,
      this.facilityDetails,
      this.dateDeferral});

  SecurityDeferral.fromJson(Map<String, dynamic> json) {
    securityNo = json['securityNo'];
    securityId = json['securityId'];
    securityType = json['securityType'];
    present = json['presentSecurity'];
    proposed = json['proposedSecurity'];
    aedPresent = json['aedequivalentPresentSecurity'];
    aedProposed = json['aedequivalentProposedSecurity'];
    allFacilities = json['allFacilities'];
    selected = json['selected'];
    draft = json['draft'];
    if (json['dateDeferral'] != null) {
      dateDeferral = DateTimeUtils.intToDateTime(json['dateDeferral']);
    }
    if (json['facilityDetailsList'] != null) {
      facilityDetails = <FacilityDetail>[];
      json['facilityDetailsList'].forEach((v) {
        facilityDetails!.add(FacilityDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['securityNo'] = securityNo;
    data['securityId'] = securityId;
    data['securityType'] = securityType;
    data['presentSecurity'] = present;
    data['proposedSecurity'] = proposed;
    data['aedequivalentPresentSecurity'] = aedPresent;
    data['aedequivalentProposedSecurity'] = aedProposed;
    data['allFacilities'] = allFacilities;
    data['selected'] = selected;
    data['draft'] = draft;
    data['facilityDetailsList'] = facilityDetails;
    data['dateDeferral'] = dateDeferral;
    return data;
  }
}

class FacilityDetail {
  final String? limitNumber;
  final String? rimNo;
  final String? limitDescription;
  final int? limitAmountAED000s;
  int? amountToBeReleased;

  FacilityDetail({
    required this.limitNumber,
    required this.rimNo,
    required this.limitDescription,
    required this.limitAmountAED000s,
    required this.amountToBeReleased,
  });

  // Factory constructor to create an instance from JSON
  factory FacilityDetail.fromJson(Map<String, dynamic> json) {
    return FacilityDetail(
      limitNumber: json['Limit Number']?.toString(),
      rimNo: json['RIM No']?.toString(),
      limitDescription: json['Limit Description']?.toString(),
      limitAmountAED000s: json['Limit Amount (AED \'000s)'],
      amountToBeReleased: json['Amount to be Released'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'Limit Number': limitNumber,
      'RIM No': rimNo,
      'Limit Description': limitDescription,
      'Limit Amount (AED \'000s)': limitAmountAED000s,
      'Amount to be Released': amountToBeReleased,
    };
  }
}
