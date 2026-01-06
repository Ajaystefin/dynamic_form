import 'dart:convert';

class LimitsFacilityResponse {
  final FacilityDetails? facilityDetails;
  final FacilityBorrowerMap? facilityBorrowerMap;
  final List<dynamic>? conditions;
  final List<dynamic>? defacultFeeRates;
  final dynamic additionalDetails;
  final List<dynamic>? facilitySubLimits;

  const LimitsFacilityResponse({
    this.facilityDetails,
    this.facilityBorrowerMap,
    this.conditions,
    this.defacultFeeRates,
    this.additionalDetails,
    this.facilitySubLimits,
  });

  factory LimitsFacilityResponse.fromJson(Map<String, dynamic> json) {
    return LimitsFacilityResponse(
      facilityDetails: json['facilityDetails'] is Map<String, dynamic>
          ? FacilityDetails.fromJson(
              json['facilityDetails'] as Map<String, dynamic>)
          : null,
      facilityBorrowerMap: json['facilityBorrowerMap'] is Map<String, dynamic>
          ? FacilityBorrowerMap.fromJson(
              json['facilityBorrowerMap'] as Map<String, dynamic>)
          : null,
      conditions: (json['conditions'] as List<dynamic>?) ?? const [],
      defacultFeeRates:
          (json['defacultFeeRates'] as List<dynamic>?) ?? const [],
      additionalDetails: json['additionalDetails'],
      facilitySubLimits:
          (json['facilitySubLimits'] as List<dynamic>?) ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facilityDetails': facilityDetails?.toJson(),
      'facilityBorrowerMap': facilityBorrowerMap?.toJson(),
      'conditions': conditions,
      'defacultFeeRates': defacultFeeRates,
      'additionalDetails': additionalDetails,
      'facilitySubLimits': facilitySubLimits,
    };
  }
}

class FacilityDetails {
  final String? facilityTitle;
  final String? appRefNo;
  final num? recommendedOutstandingAed;
  final num? recommendedPastdueAed;
  final num? recommendedOutstanding;
  final num? recommendedPastdue;
  final num? facilityId;
  final String? limitNo;
  final String? controllingLimitNo;
  final num? limitDescription;
  final num? advanceType;
  final String? nextMonitorDate;
  final bool? isProjectFinActivity;
  final num? proposedLimit;
  final num? presentOutstanding;
  final num? seniority;
  final String? wcasLimitNo;
  final num? regulatorySpecialisedLendingFinanceType;
  final num? purpose;
  final String? commitmentAccountNumber;
  final bool? isCollateralDependent;
  final num? promissoryNoteTaken;
  final String? limitExpiryDate;
  final String? limitAvailabilityDate;
  final bool? isCommitted;
  final num? presentLimit;
  final num? parentFacilityId;
  final bool? isRegulatorySpecialisedLending;
  final num? originalLimit;
  final bool? isMainLimit;
  String? currency;
  final num? groupId;
  final num? rimNo;
  final String? countryOfRisk;
  final num? sicCode;
  final String? revolvingType;
  final num? sectorDescription;
  final bool? isSharedLimit;
  final String? limitCategory;
  final dynamic isDraft;
  final dynamic forIslamic;
  final num? emirates;
  final num? propertySubType;
  final num? propertyType;
  final String? accountType;
  final String? productCode;
  final num? presentLimitAED;
  final num? proposedLimitAED;
  final String? projectName;
  final String? sustainabilityClassification;
  final num? proposedByCc;
  final String? remarks;
  final String? policyDeviation;
  final bool? isCrossBoarderCorporateExposure;
  final String? limitAvailabilityPeriod;
  final num? pastDues;
  final String? tenorUnit;
  final num? tenorValue;
  final String? index;
  final String? marginSign;
  final num? marginValue;
  final String? projectCode;
  final String? limitGroupName;
  final num? limitGroup;
  final num? limitCapType;
  final bool? isConventional;
  final bool? isIslamic;
  Map<String, dynamic>? additionalDetails;

  FacilityDetails({
    this.facilityTitle,
    this.appRefNo,
    this.recommendedOutstandingAed,
    this.recommendedPastdueAed,
    this.recommendedOutstanding,
    this.recommendedPastdue,
    this.facilityId,
    this.limitNo,
    this.controllingLimitNo,
    this.limitDescription,
    this.advanceType,
    this.nextMonitorDate,
    this.isProjectFinActivity,
    this.proposedLimit,
    this.presentOutstanding,
    this.seniority,
    this.wcasLimitNo,
    this.regulatorySpecialisedLendingFinanceType,
    this.purpose,
    this.commitmentAccountNumber,
    this.isCollateralDependent,
    this.promissoryNoteTaken,
    this.limitExpiryDate,
    this.limitAvailabilityDate,
    this.isCommitted,
    this.presentLimit,
    this.parentFacilityId,
    this.isRegulatorySpecialisedLending,
    this.originalLimit,
    this.isMainLimit,
    this.currency,
    this.groupId,
    this.rimNo,
    this.countryOfRisk,
    this.sicCode,
    this.revolvingType,
    this.sectorDescription,
    this.isSharedLimit,
    this.limitCategory,
    this.isDraft,
    this.forIslamic,
    this.emirates,
    this.propertySubType,
    this.propertyType,
    this.accountType,
    this.productCode,
    this.presentLimitAED,
    this.proposedLimitAED,
    this.projectName,
    this.sustainabilityClassification,
    this.proposedByCc,
    this.remarks,
    this.policyDeviation,
    this.isCrossBoarderCorporateExposure,
    this.limitAvailabilityPeriod,
    this.pastDues,
    this.tenorUnit,
    this.tenorValue,
    this.index,
    this.marginSign,
    this.marginValue,
    this.projectCode,
    this.limitGroupName,
    this.limitGroup,
    this.limitCapType,
    this.isConventional,
    this.isIslamic,
    this.additionalDetails,
  });

  factory FacilityDetails.fromJson(Map<String, dynamic> json) {
    return FacilityDetails(
      facilityTitle: json['facilityTitle'] as String?,
      appRefNo: json['appRefNo'] as String?,
      recommendedOutstandingAed: json['recommendedOutstandingAed'] as num?,
      recommendedPastdueAed: json['recommendedPastdueAed'] as num?,
      recommendedOutstanding: json['recommendedOutstanding'] as num?,
      recommendedPastdue: json['recommendedPastdue'] as num?,
      facilityId: json['facilityId'] as num?,
      limitNo: json['limitNo'] as String?,
      controllingLimitNo: json['controllingLimitNo'] as String?,
      limitDescription: json['limitDescription'] as num?,
      advanceType: json['advanceType'] as num?,
      nextMonitorDate: json['nextMonitorDate'] as String?,
      isProjectFinActivity: json['isProjectFinActivity'] as bool?,
      proposedLimit: json['proposedLimit'] as num?,
      presentOutstanding: json['presentOutstanding'] as num?,
      seniority: json['seniority'] as num?,
      wcasLimitNo: json['wcasLimitNo'] as String?,
      regulatorySpecialisedLendingFinanceType:
          json['regulatorySpecialisedLendingFinanceType'] as num?,
      purpose: json['purpose'] as num?,
      commitmentAccountNumber: json['commitmentAccountNumber'] as String?,
      isCollateralDependent: json['isCollateralDependent'] as bool?,
      promissoryNoteTaken: json['promissoryNoteTaken'] as num?,
      limitExpiryDate: json['limitExpiryDate'] as String?,
      limitAvailabilityDate: json['limitAvailabilityDate'] as String?,
      isCommitted: json['isCommitted'] as bool?,
      presentLimit: json['presentLimit'] as num?,
      parentFacilityId: json['parentFacilityId'] as num?,
      isRegulatorySpecialisedLending:
          json['isRegulatorySpecialisedLending'] as bool?,
      originalLimit: json['originalLimit'] as num?,
      isMainLimit: json['isMainLimit'] as bool?,
      currency: json['currency'] as String?,
      groupId: json['groupId'] as num?,
      rimNo: json['rimNo'] as num?,
      countryOfRisk: json['countryOfRisk'] as String?,
      sicCode: json['sicCode'] as num?,
      revolvingType: json['revolvingType'] as String?,
      sectorDescription: json['sectorDescription'] as num?,
      isSharedLimit: json['isSharedLimit'] as bool?,
      limitCategory: json['limitCategory'] as String?,
      isDraft: json['isDraft'],
      forIslamic: json['forIslamic'],
      emirates: json['emirates'] as num?,
      propertySubType: json['propertySubType'] as num?,
      propertyType: json['propertyType'] as num?,
      accountType: json['accountType'] as String?,
      productCode: json['productCode'] as String?,
      presentLimitAED: json['presentLimitAED'] as num?,
      proposedLimitAED: json['proposedLimitAED'] as num?,
      projectName: json['projectName'] as String?,
      sustainabilityClassification:
          json['sustainabilityClassification'] as String?,
      proposedByCc: json['proposedByCc'] as num?,
      remarks: json['remarks'] as String?,
      policyDeviation: json['policyDeviation'] as String?,
      isCrossBoarderCorporateExposure:
          json['isCrossBoarderCorporateExposure'] as bool?,
      limitAvailabilityPeriod: json['limitAvailabilityPeriod'] as String?,
      pastDues: json['pastDues'] as num?,
      tenorUnit: json['tenorUnit'] as String?,
      tenorValue: json['tenorValue'] as num?,
      index: json['index'] as String?,
      marginSign: json['marginSign'] as String?,
      marginValue: json['marginValue'] as num?,
      projectCode: json['projectCode'] as String?,
      limitGroupName: json['limitGroupName'] as String?,
      limitGroup: json['limitGroup'] as num?,
      limitCapType: json['limitCapType'] as num?,
      isConventional: json['isConventional'] as bool?,
      isIslamic: json['isIslamic'] as bool?,
    )..additionalDetails =
        {}; // Initialize empty, will be populated by repository
  }

  Map<String, dynamic> toJson() {
    return {
      'facilityTitle': facilityTitle,
      'appRefNo': appRefNo,
      'recommendedOutstandingAed': recommendedOutstandingAed,
      'recommendedPastdueAed': recommendedPastdueAed,
      'recommendedOutstanding': recommendedOutstanding,
      'recommendedPastdue': recommendedPastdue,
      'facilityId': facilityId,
      'limitNo': limitNo,
      'controllingLimitNo': controllingLimitNo,
      'limitDescription': limitDescription,
      'advanceType': advanceType,
      'nextMonitorDate': nextMonitorDate,
      'isProjectFinActivity': isProjectFinActivity,
      'proposedLimit': proposedLimit,
      'presentOutstanding': presentOutstanding,
      'seniority': seniority,
      'wcasLimitNo': wcasLimitNo,
      'regulatorySpecialisedLendingFinanceType':
          regulatorySpecialisedLendingFinanceType,
      'purpose': purpose,
      'commitmentAccountNumber': commitmentAccountNumber,
      'isCollateralDependent': isCollateralDependent,
      'promissoryNoteTaken': promissoryNoteTaken,
      'limitExpiryDate': limitExpiryDate,
      // 'limitAvailabilityDate': limitAvailabilityDate,
      'limitAvailabilityDate': _epochSeconds(limitAvailabilityDate),
      'isCommitted': isCommitted,
      'presentLimit': presentLimit,
      'parentFacilityId': parentFacilityId,
      'isRegulatorySpecialisedLending': isRegulatorySpecialisedLending,
      'originalLimit': originalLimit,
      'isMainLimit': isMainLimit,
      'currency': currency,
      'groupId': groupId,
      'rimNo': rimNo,
      'countryOfRisk': countryOfRisk,
      'sicCode': sicCode,
      'revolvingType': revolvingType,
      'sectorDescription': sectorDescription,
      'isSharedLimit': isSharedLimit,
      'limitCategory': limitCategory,
      'isDraft': isDraft,
      'forIslamic': forIslamic,
      'emirates': emirates,
      'propertySubType': propertySubType,
      'propertyType': propertyType,
      'accountType': accountType,
      'productCode': productCode,
      'presentLimitAED': presentLimitAED,
      'proposedLimitAED': proposedLimitAED,
      'projectName': projectName,
      'sustainabilityClassification': sustainabilityClassification,
      'proposedByCc': proposedByCc,
      'remarks': remarks,
      'policyDeviation': policyDeviation,
      'isCrossBoarderCorporateExposure': isCrossBoarderCorporateExposure,
      'limitAvailabilityPeriod': limitAvailabilityPeriod,
      'pastDues': pastDues,
      'tenorUnit': tenorUnit,
      'tenorValue': tenorValue,
      'index': index,
      'marginSign': marginSign,
      'marginValue': marginValue,
      'projectCode': projectCode,
      'limitGroupName': limitGroupName,
      'limitGroup': limitGroup,
      'limitCapType': limitCapType,
      'isConventional': isConventional,
      'isIslamic': isIslamic,
      'additionalDetails':
          additionalDetails != null ? jsonEncode(additionalDetails) : null,
    };
  }
}

class FacilityBorrowerMap {
  final List<dynamic>? borrowerList;
  final List<dynamic>? companyBorrowerList;

  const FacilityBorrowerMap({
    this.borrowerList,
    this.companyBorrowerList,
  });

  factory FacilityBorrowerMap.fromJson(Map<String, dynamic> json) {
    return FacilityBorrowerMap(
      borrowerList: json['borrowerList'] as List<dynamic>?,
      companyBorrowerList: json['companyBorrowerList'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'borrowerList': borrowerList,
      // 'companyBorrowerList': companyBorrowerList,
    };
  }
}

int? _epochSeconds(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt(); // already numeric
  // try parsing ISO-8601, e.g., "2025-10-03T09:02:49"
  try {
    final dt = DateTime.parse(v.toString()).toUtc();
    return (dt.millisecondsSinceEpoch ~/ 1000); // epoch seconds
  } catch (_) {
    return null; // let backend handle default if any
  }
}
