// import 'dart:convert';

import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class LimitsFacilityResponse {
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
      facilityDetails: json["facilityDetails"] is Map<String, dynamic>
          ? FacilityDetails.fromJson(
              json["facilityDetails"] as Map<String, dynamic>,
            )
          : null,
      facilityBorrowerMap: json["facilityBorrowerMap"] is Map<String, dynamic>
          ? FacilityBorrowerMap.fromJson(
              json["facilityBorrowerMap"] as Map<String, dynamic>,
            )
          : null,
      conditions: (json["conditions"] as List<dynamic>?) ?? const [],
      defacultFeeRates:
          (json["defacultFeeRates"] as List<dynamic>?) ?? const [],
      additionalDetails: json["additionalDetails"],
      facilitySubLimits:
          (json["facilitySubLimits"] as List<dynamic>?) ?? const [],
    );
  }
  final FacilityDetails? facilityDetails;
  final FacilityBorrowerMap? facilityBorrowerMap;
  final List<dynamic>? conditions;
  final List<dynamic>? defacultFeeRates;
  final dynamic additionalDetails;
  final List<dynamic>? facilitySubLimits;

  Map<String, dynamic> toJson() {
    return {
      "facilityDetails": facilityDetails?.toJson(),
      "facilityBorrowerMap": facilityBorrowerMap?.toJson(),
      "conditions": conditions,
      "defacultFeeRates": defacultFeeRates,
      "additionalDetails": additionalDetails,
      "facilitySubLimits": facilitySubLimits,
    };
  }
}

class FacilityDetails {
  FacilityDetails({
    this.presentOutstandingCurrency,
    this.groupOwner,
    this.excessOverMaxLimitAllowanceByCc,
    this.excessOverMaxLimitAllowanceCurrencyByCc,
    this.facilityTitle,
    this.excessOverMaxLimitAllowance,
    this.excessOverMaxLimitAllowanceCurrency,
    this.cbdEquityTier325Percent,
    this.cbdEquityTier325PercentCurrency,
    this.counterpartyEquity5Percent,
    this.counterpartyEquity5PercentCurrency,
    this.counterpartyTotalAssets2Percent,
    this.counterpartyTotalAssets2PercentCurrency,
    this.appRefNo,
    this.recommendedOutstandingAed,
    this.recommendedPastdueAed,
    this.recommendedOutstanding,
    this.recommendedPastdue,
    this.type,
    this.facilitySecurityDetailId,
    this.facilitySecurityId,
    this.facilityId,
    this.limitNo,
    this.controllingLimitNo,
    this.limitDescription,
    this.advanceType,
    this.nextMonitorDate,
    this.isProjectFinActivity,
    this.proposedLimit,
    this.presentOutstanding,
    this.presentOutstandingAED,
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
    this.proposedByCcCurrency,
    this.proposedByccAED,
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
    this.cbdEquityTier325PercentAED,
    this.counterpartyEquity5PercentAED,
    this.counterpartyTotalAssets2PercentAED,
    this.excessOverMaxLimitAllowanceAED,
    this.excessOverMaxLimitAllowanceByCcAED,
  });

  factory FacilityDetails.fromJson(Map<String, dynamic> json) {
    num? numFromJson(dynamic v) {
      if (v == null) return null;
      if (v is num) return v;
      if (v is String) {
        final s = v.trim();
        if (s.isEmpty) return null;
        return num.tryParse(s); // "98" -> 98, "On Demand" -> null
      }
      return null;
    }

    return FacilityDetails(
      type: (json["type"]),
      facilitySecurityDetailId: (json["facilitySecurityDetailId"]),
      facilitySecurityId: (json["facilitySecurityId"]),
      facilityTitle: json["facilityTitle"] as String?,
      excessOverMaxLimitAllowance:
          (json["excessOverMaxLimitAllowance"] as num?)?.toDouble(),
      excessOverMaxLimitAllowanceCurrency:
          json["excessOverMaxLimitAllowanceCurrency"] as String?,
      cbdEquityTier325Percent:
          (json["cbdEquityTier325Percent"] as num?)?.toDouble(),
      cbdEquityTier325PercentCurrency:
          json["cbdEquityTier325PercentCurrency"] as String?,
      counterpartyEquity5Percent:
          (json["counterpartyEquity5Percent"] as num?)?.toDouble(),
      counterpartyEquity5PercentCurrency:
          (json["counterpartyEquity5PercentCurrency"] as String?),
      counterpartyTotalAssets2Percent:
          (json["counterpartyTotalAssets2Percent"] as num?)?.toDouble(),
      counterpartyTotalAssets2PercentCurrency:
          (json["counterpartyTotalAssets2PercentCurrency"] as String?),
      appRefNo: json["appRefNo"] as String?,
      recommendedOutstandingAed: json["recommendedOutstandingAed"] as num?,
      recommendedPastdueAed: json["recommendedPastdueAed"] as num?,
      recommendedOutstanding: json["recommendedOutstanding"] as num?,
      recommendedPastdue: json["recommendedPastdue"] as num?,
      facilityId: json["facilityId"] as num?,
      limitNo: json["limitNo"] as String?,
      controllingLimitNo: json["controllingLimitNo"] as String?,
      limitDescription: json["limitDescription"] as num?,
      advanceType: json["advanceType"] as num?,
      nextMonitorDate: json["nextMonitorDate"] as String?,
      isProjectFinActivity: json["isProjectFinActivity"] as bool?,
      proposedLimit: json["proposedLimit"] as num?,
      presentOutstanding: json["presentOutstanding"] as num?,
      presentOutstandingAED: json["presentOutstandingAED"] as num?,
      presentOutstandingCurrency: json["presentOutstandingCurrency"] as String?,
      seniority: json["seniority"] as num?,
      wcasLimitNo: json["wcasLimitNo"] as String?,
      regulatorySpecialisedLendingFinanceType:
          json["regulatorySpecialisedLendingFinanceType"] as num?,
      purpose: json["purpose"] as num?,
      commitmentAccountNumber: json["commitmentAccountNumber"] as String?,
      isCollateralDependent: json["isCollateralDependent"] == false
          ? Reference(id: ServerConstants.optionNOid, name: "No")
          : Reference(id: ServerConstants.optionYESid, name: "Yes"),
      promissoryNoteTaken: json["promissoryNoteTaken"] as num?,
      limitExpiryDate: json["limitExpiryDate"] as String?,
      limitAvailabilityDate: json["limitAvailabilityDate"] as String?,
      isCommitted: json["isCommitted"] as bool?,
      presentLimit: json["presentLimit"] as num?,
      parentFacilityId: json["parentFacilityId"] as num?,
      isRegulatorySpecialisedLending:
          json["isRegulatorySpecialisedLending"] as bool?,
      originalLimit: json["originalLimit"] as num?,
      isMainLimit: json["isMainLimit"] as bool?,
      currency: json["currency"] as String?,
      groupId: json["groupId"] as num?,
      rimNo: json["rimNo"] as num?,
      countryOfRisk: json["countryOfRisk"] as String?,
      sicCode: json["sicCode"] as num?,
      revolvingType: json["revolvingType"] as String?,
      sectorDescription: json["sectorDescription"] as num?,
      isSharedLimit: json["isSharedLimit"] as bool?,
      limitCategory: json["limitCategory"] as String?,
      isDraft: json["isDraft"],
      forIslamic: json["forIslamic"],
      emirates: json["emirates"] as num?,
      propertySubType: json["propertySubType"] as num?,
      propertyType: json["propertyType"] as num?,
      accountType: json["accountType"] as String?,
      productCode: json["productCode"] as String?,
      presentLimitAED: json["presentLimitAED"] as num?,
      proposedLimitAED: json["proposedLimitAED"] as num?,
      projectName: json["projectName"] as String?,
      sustainabilityClassification:
          json["sustainabilityClassification"] as String?,
      proposedByCc: json["proposedByCc"] as num?,
      proposedByccAED: json["proposedByCcAED"] as double?,
      proposedByCcCurrency: json["proposedByCcCurrency"] as String?,
      remarks: json["remarks"] as String?,
      policyDeviation: json["policyDeviation"] is String
          ? (json["policyDeviation"] as String)
              .split(",")
              .where((e) => e.trim().isNotEmpty)
              .map((e) => Reference(id: int.tryParse(e.trim())))
              .toList()
          : [],
      isCrossBoarderCorporateExposure:
          json["isCrossBoarderCorporateExposure"] as bool?,
      limitAvailabilityPeriod: json["limitAvailabilityPeriod"] as String?,
      pastDues: json["pastDues"] as num?,
      tenorUnit: json["tenorUnit"] as String?,
      // tenorValue: json['tenorValue'] as num?,
      tenorValue: numFromJson(json["tenorValue"]),
      index: json["index"] as String?,
      marginSign: json["marginSign"] as String?,
      marginValue: json["marginValue"] as String?,
      projectCode: json["projectCode"] as String?,
      limitGroupName: json["limitGroupName"] as String?,
      limitGroup: json["limitGroup"] as num?,
      limitCapType: json["limitCapType"] as num?,
      isConventional: json["isConventional"] as bool?,
      isIslamic: json["isIslamic"] as bool?,
    )..additionalDetails =
        {}; // Initialize empty, will be populated by repository
  }
  int? facilitySecurityDetailId;
  int? type;
  int? facilitySecurityId;
  final String? facilityTitle;
  // FI flow fields
  final double? excessOverMaxLimitAllowance;
  final double? excessOverMaxLimitAllowanceAED;
  final double? excessOverMaxLimitAllowanceByCc;
  final double? excessOverMaxLimitAllowanceByCcAED;
  final String? excessOverMaxLimitAllowanceCurrency;
  final String? excessOverMaxLimitAllowanceCurrencyByCc;
  final double? cbdEquityTier325Percent;
  final double? cbdEquityTier325PercentAED;
  final String? cbdEquityTier325PercentCurrency;
  final double? counterpartyEquity5Percent;
  final double? counterpartyEquity5PercentAED;
  final String? counterpartyEquity5PercentCurrency;
  final double? counterpartyTotalAssets2Percent;
  final double? counterpartyTotalAssets2PercentAED;
  final String? counterpartyTotalAssets2PercentCurrency;
  // FI flow fields
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
  final num? presentOutstandingAED;
  final num? seniority;
  final String? wcasLimitNo;
  final num? regulatorySpecialisedLendingFinanceType;
  final num? purpose;
  final String? commitmentAccountNumber;
  final Reference? isCollateralDependent;
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
  final double? proposedByccAED;
  final String? proposedByCcCurrency;
  final String? remarks;
  final List<Reference>? policyDeviation;
  final bool? isCrossBoarderCorporateExposure;
  final String? limitAvailabilityPeriod;
  final num? pastDues;
  final String? tenorUnit;
  final num? tenorValue;
  final String? index;
  final String? marginSign;
  final String? marginValue;
  final String? projectCode;
  final String? limitGroupName;
  final num? limitGroup;
  num? limitCapType;
  final bool? isConventional;
  final bool? isIslamic;
  final int? groupOwner;
  Map<String, dynamic>? additionalDetails;
  String? presentOutstandingCurrency;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      "groupOwner": Globals.request?.groupOwner,
      "facilityTitle": facilityTitle,

      "facilitySecurityDetailId": facilitySecurityDetailId,
      "facilitySecurityId": facilitySecurityId,
      "proposedLimitAED": proposedLimitAED,
      "type": type,
      "appRefNo": appRefNo,
      "proposedByCc": proposedByCc,
      "proposedByCcAED": proposedByccAED,
      "proposedByCcCurrency": proposedByCcCurrency,
      "excessOverMaxLimitAllowance": excessOverMaxLimitAllowance,
      "excessOverMaxLimitAllowanceCurrency":
          excessOverMaxLimitAllowanceCurrency,
      "excessOverMaxLimitAllowanceByCc": excessOverMaxLimitAllowanceByCc,
      "excessOverMaxLimitAllowanceCurrencyByCc":
          excessOverMaxLimitAllowanceCurrencyByCc,

      "cbdEquityTier325Percent": cbdEquityTier325Percent,
      "cbdEquityTier325PercentCurrency": cbdEquityTier325PercentCurrency,
      "counterpartyEquity5Percent": counterpartyEquity5Percent,
      "counterpartyEquity5PercentCurrency": counterpartyEquity5PercentCurrency,
      "counterpartyTotalAssets2Percent": counterpartyTotalAssets2Percent,
      "counterpartyTotalAssets2PercentCurrency":
          counterpartyTotalAssets2PercentCurrency,
      "recommendedOutstandingAed": recommendedOutstandingAed,
      "recommendedPastdueAed": recommendedPastdueAed,
      "recommendedOutstanding": recommendedOutstanding,
      "recommendedPastdue": recommendedPastdue,
      "facilityId": facilityId,
      "limitNo": limitNo,
      "controllingLimitNo": controllingLimitNo,
      "limitDescription": limitDescription,
      "advanceType": advanceType,
      "nextMonitorDate": nextMonitorDate,
      "isProjectFinActivity": isProjectFinActivity,
      "proposedLimit": proposedLimit,
      "presentOutstanding": presentOutstanding,
      "presentOutstandingAED": presentOutstandingAED,
      "presentOutstandingCurrency": presentOutstandingCurrency,
      "seniority": seniority,
      "wcasLimitNo": wcasLimitNo,
      "regulatorySpecialisedLendingFinanceType":
          regulatorySpecialisedLendingFinanceType,
      "purpose": purpose,
      "commitmentAccountNumber": commitmentAccountNumber,
      "isCollateralDependent":
          isCollateralDependent?.id == ServerConstants.optionYESid,
      "promissoryNoteTaken": promissoryNoteTaken,
      "limitExpiryDate": limitExpiryDate,
      "limitAvailabilityDate": _epochSeconds(limitAvailabilityDate),
      "limitAvailabilityPeriod": limitAvailabilityPeriod,
      "isCommitted": isCommitted,
      "presentLimit": presentLimit,
      "parentFacilityId": parentFacilityId,
      "isRegulatorySpecialisedLending": isRegulatorySpecialisedLending,
      "originalLimit": originalLimit,
      "isMainLimit": isMainLimit,
      "currency": currency,
      "groupId": groupId,
      "rimNo": rimNo,
      "countryOfRisk": countryOfRisk,
      "sicCode": sicCode,
      "revolvingType": revolvingType,
      "sectorDescription": sectorDescription,
      "isSharedLimit": isSharedLimit,
      "limitCategory": limitCategory,
      "isDraft": isDraft ?? false,
      "forIslamic": forIslamic,
      "emirates": emirates,
      "propertySubType": propertySubType,
      "propertyType": propertyType,
      "accountType": accountType,
      "productCode": productCode,
      "presentLimitAED": presentLimitAED,

      "projectName": projectName,
      "sustainabilityClassification": sustainabilityClassification,

      "remarks": remarks,
      "policyDeviation": policyDeviation?.map((e) => e.name).join(","),
      "isCrossBoarderCorporateExposure": isCrossBoarderCorporateExposure,
      "pastDues": pastDues,
      "tenorUnit": tenorUnit,
      "tenorValue": tenorValue,
      "index": index,
      "marginSign": marginSign,
      "marginValue": marginValue,
      "projectCode": projectCode,
      "limitGroupName": limitGroupName,
      "limitGroup": limitGroup,
      "limitCapType": limitCapType,
      "isConventional": isConventional,
      "isIslamic": isIslamic,
      // 'additionalDetails':
      //     additionalDetails != null ? jsonEncode(additionalDetails) : null,

      "cbdEquityTier325PercentAED": cbdEquityTier325PercentAED,
      "counterpartyEquity5PercentAED": counterpartyEquity5PercentAED,
      "counterpartyTotalAssets2PercentAED": counterpartyTotalAssets2PercentAED,
      "excessOverMaxLimitAllowanceAED": excessOverMaxLimitAllowanceAED,
      "excessOverMaxLimitAllowanceByCcAED": excessOverMaxLimitAllowanceByCcAED,
    };
    if (limitAvailabilityDate == null) {
      map.remove("limitAvailabilityDate");
    }
    if (limitAvailabilityPeriod == null ||
        (limitAvailabilityPeriod?.trim().isEmpty ?? true)) {
      map.remove("limitAvailabilityPeriod");
    }
    return map;
  }
}

class FacilityBorrowerMap {
  const FacilityBorrowerMap({
    this.borrowerList,
    this.companyBorrowerList,
  });

  factory FacilityBorrowerMap.fromJson(Map<String, dynamic> json) {
    return FacilityBorrowerMap(
      borrowerList: json["borrowerList"] as List<dynamic>?,
      companyBorrowerList: json["companyBorrowerList"] as List<dynamic>?,
    );
  }
  final List<dynamic>? borrowerList;
  final List<dynamic>? companyBorrowerList;

  Map<String, dynamic> toJson() {
    return {
      "borrowerList": borrowerList,
    };
  }
}

class FacilitySubLimitBlock {
  FacilitySubLimitBlock({
    required this.facilityDetails,
    this.facilityBorrowerMap,
    this.conditions = const [],
  });

  factory FacilitySubLimitBlock.fromJson(Map<String, dynamic> json) {
    return FacilitySubLimitBlock(
      facilityDetails: FacilityDetails.fromJson(json["facilityDetails"] ?? {}),
      facilityBorrowerMap: json["facilityBorrowerMap"] == null
          ? null
          : FacilityBorrowerMap.fromJson(json["facilityBorrowerMap"]),
      conditions: (json["conditions"] as List<dynamic>?) ?? const [],
    );
  }
  final FacilityDetails facilityDetails;
  final FacilityBorrowerMap? facilityBorrowerMap;
  final List<dynamic> conditions;

  Map<String, dynamic> toJson() => {
        "facilityDetails": facilityDetails.toJson(),
        if (facilityBorrowerMap != null)
          "facilityBorrowerMap": facilityBorrowerMap!.toJson(),
        "conditions": conditions,
      };
}

class FacilitySubLimitWrapper {
  FacilitySubLimitWrapper({required this.facilitySubLimits});

  factory FacilitySubLimitWrapper.fromJson(Map<String, dynamic> json) {
    return FacilitySubLimitWrapper(
      facilitySubLimits:
          FacilitySubLimitBlock.fromJson(json["facilitySubLimits"] ?? {}),
    );
  }
  final FacilitySubLimitBlock facilitySubLimits;

  Map<String, dynamic> toJson() => {
        "facilitySubLimits": facilitySubLimits.toJson(),
      };
}

int? _epochSeconds(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  try {
    final dt = DateTime.parse(v.toString()).toUtc();
    return dt.millisecondsSinceEpoch ~/ 1000;
  } catch (_) {
    return null;
  }
}

/// FacilityDetails JSON for Single Borrower Limit Caps
extension FacilityDetailsSingleBorrowerX on FacilityDetails {
  Map<String, dynamic> toSingleBorrowerJson() {
    final map = <String, dynamic>{
      "rimNo": rimNo,
      "groupId": groupId,
      "productCode": productCode,
      "appRefNo": appRefNo,
      "limitCategory": limitCategory,
      "forIslamic": forIslamic,
      "limitDescription": limitDescription,
      "facilityTitle": facilityTitle,
      "presentOutstanding": presentOutstanding,
      "pastDues": pastDues,
      "currency": currency,
      "isSharedLimit": isSharedLimit,
      "presentLimit": presentLimit,
      "originalLimit": originalLimit,
      "proposedLimit": proposedLimit,
      "proposedLimitAED": proposedLimitAED,
      "proposedByCc": proposedByCc,
      "isMainLimit": isMainLimit,
      "limitGroupName": limitGroupName,
      "limitGroup": limitGroup,
      "limitCapType": limitCapType,
      "facilityId": facilityId,
      "isDraft": isDraft ?? false,
    };
    return map;
  }
}

/// FacilityDetails JSON for Group Borrower Limit Caps
extension FacilityDetailsGroupBorrowerX on FacilityDetails {
  Map<String, dynamic> toGroupBorrowerJson() {
    final map = <String, dynamic>{
      "rimNo": Globals.request?.groupOwner,
      "groupId": groupId,
      "productCode": productCode, // e.g., "CLT"
      "appRefNo": appRefNo,
      "forIslamic": forIslamic,
      "limitDescription": limitDescription,
      "facilityTitle": facilityTitle,
      "presentOutstanding": presentOutstanding,
      "limitCategory": limitCategory,
      "pastDues": pastDues,
      "currency": currency,
      "isSharedLimit": isSharedLimit,
      "presentLimit": presentLimit,
      "originalLimit": originalLimit,
      "proposedLimit": proposedLimit,
      "proposedLimitAED": proposedLimitAED,
      "proposedByCc": proposedByCc,
      "isMainLimit": isMainLimit,
      "limitGroupName": limitGroupName,
      "limitGroup": limitGroup,
      "limitCapType": limitCapType,
      "facilityId": facilityId,
      "isDraft": isDraft ?? false,
    };
    return map;
  }
}

/// FacilityBorrowerMap JSON for Group Borrower (company-level allocation list)
extension FacilityBorrowerMapCompanyX on FacilityBorrowerMap {
  Map<String, dynamic> toCompanyBorrowerJson() {
    return {
      "companyBorrowerList": companyBorrowerList ?? const [],
    };
  }
}

/// FacilityDetails JSON for Single Borrower Limit Caps
extension FacilityDetailsProjectX on FacilityDetails {
  Map<String, dynamic> toSaveProjectJson() {
    final map = <String, dynamic>{
      "groupOwner": Globals.request?.groupOwner,
      "rimNo": rimNo,
      "groupId": groupId,
      "productCode": productCode,
      "limitCategory": limitCategory,
      "appRefNo": appRefNo,
      "forIslamic": forIslamic,
      "limitDescription": limitDescription,
      "facilityTitle": facilityTitle,
      "presentOutstanding": presentOutstanding,
      "pastDues": pastDues, // note: model key is `pastDues`
      "currency": currency,
      "isSharedLimit": isSharedLimit,
      "presentLimit": presentLimit,
      "projectName": projectName,
      "proposedLimit": proposedLimit,
      "proposedLimitAED": proposedLimit,
      "proposedByCc": proposedByCc,
      "isMainLimit": isMainLimit,
      "limitGroupName": limitGroupName,
      "limitGroup": limitGroup,
      "limitCapType": limitCapType,
      "facilityId": facilityId,
    };
    return map;
  }
}

class SubLimitMeta {
  String? currency; // e.g., "AED"
  String? tenorUnit; // e.g., "12 Months"
  int? tenorValue; // e.g., 12
  String? index; // e.g., "13912"
  String? marginSign; // e.g., "+", "-"
  num? marginValue; // e.g., 2.5
}
