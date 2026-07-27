import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Represents the complete facility response payload,
/// including facility details, borrower mappings,
/// conditions, fee rates, and sub-limit information.
class LimitsFacilityResponse {
  /// Creates a [LimitsFacilityResponse] instance.
  const LimitsFacilityResponse({
    this.facilityDetails,
    this.facilityBorrowerMap,
    this.conditions,
    this.defacultFeeRates,
    this.additionalDetails,
    this.facilitySubLimits,
  });

  /// Creates a [LimitsFacilityResponse] instance from a JSON map.
  factory LimitsFacilityResponse.fromJson(
    Map<String, dynamic> json,
  ) {
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

  /// Facility details.
  final FacilityDetails? facilityDetails;

  /// Facility borrower mapping information.
  final FacilityBorrowerMap? facilityBorrowerMap;

  /// Facility conditions.
  final List<dynamic>? conditions;

  /// Default fee rates.
  final List<dynamic>? defacultFeeRates;

  /// Additional facility details.
  final dynamic additionalDetails;

  /// Facility sub-limit information.
  final List<dynamic>? facilitySubLimits;

  /// Converts this [LimitsFacilityResponse] instance to a JSON map.
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

/// Represents facility details including limits, exposures,
/// regulatory information, and related facility metadata.
class FacilityDetails {
  /// Creates a [FacilityDetails] instance.
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
    this.facilityMasterId,
  });

  /// Creates a [FacilityDetails] instance from a JSON map.
  factory FacilityDetails.fromJson(Map<String, dynamic> json) {
    num? numFromJson(v) {
      if (v == null) {
        return null;
      }
      if (v is num) {
        return v;
      }
      if (v is String) {
        final s = v.trim();
        if (s.isEmpty) {
          return null;
        }
        return num.tryParse(s); // "98" -> 98, "On Demand" -> null
      }
      return null;
    }

    return FacilityDetails(
      facilityMasterId: json["facilityMasterId"] as int?,
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

  /// Facility security detail identifier.
  int? facilitySecurityDetailId;

  /// Facility type identifier.
  int? type;

  /// Facility security identifier.
  int? facilitySecurityId;

  /// Facility title.
  final String? facilityTitle;

  /// Excess over maximum limit allowance.
  final double? excessOverMaxLimitAllowance;

  /// Excess over maximum limit allowance in AED.
  final double? excessOverMaxLimitAllowanceAED;

  /// Excess over maximum limit allowance approved by CC.
  final double? excessOverMaxLimitAllowanceByCc;

  /// Excess over maximum limit allowance approved by CC in AED.
  final double? excessOverMaxLimitAllowanceByCcAED;

  /// Currency for excess over maximum limit allowance.
  final String? excessOverMaxLimitAllowanceCurrency;

  /// Currency for excess over maximum limit allowance approved by CC.
  final String? excessOverMaxLimitAllowanceCurrencyByCc;

  /// CBD equity tier 3.25 percent amount.
  final double? cbdEquityTier325Percent;

  /// CBD equity tier 3.25 percent amount in AED.
  final double? cbdEquityTier325PercentAED;

  /// Currency for CBD equity tier 3.25 percent amount.
  final String? cbdEquityTier325PercentCurrency;

  /// Counterparty equity 5 percent amount.
  final double? counterpartyEquity5Percent;

  /// Counterparty equity 5 percent amount in AED.
  final double? counterpartyEquity5PercentAED;

  /// Currency for counterparty equity 5 percent amount.
  final String? counterpartyEquity5PercentCurrency;

  /// Counterparty total assets 2 percent amount.
  final double? counterpartyTotalAssets2Percent;

  /// Counterparty total assets 2 percent amount in AED.
  final double? counterpartyTotalAssets2PercentAED;

  /// Currency for counterparty total assets 2 percent amount.
  final String? counterpartyTotalAssets2PercentCurrency;

  /// Application reference number.
  final String? appRefNo;

  /// Recommended outstanding amount in AED.
  final num? recommendedOutstandingAed;

  /// Recommended past due amount in AED.
  final num? recommendedPastdueAed;

  /// Recommended outstanding amount.
  final num? recommendedOutstanding;

  /// Recommended past due amount.
  final num? recommendedPastdue;

  /// Facility identifier.
  final num? facilityId;

  /// Limit number.
  final String? limitNo;

  /// Controlling limit number.
  final String? controllingLimitNo;

  /// Limit description.
  final num? limitDescription;

  /// Advance type.
  final num? advanceType;

  /// Next monitoring date.
  final String? nextMonitorDate;

  /// Indicates whether the facility is project finance related.
  final bool? isProjectFinActivity;

  /// Proposed limit.
  final num? proposedLimit;

  /// Present outstanding amount.
  final num? presentOutstanding;

  /// Present outstanding amount in AED.
  final num? presentOutstandingAED;

  /// Seniority.
  final num? seniority;

  /// WCAS limit number.
  final String? wcasLimitNo;

  /// Regulatory specialised lending finance type.
  final num? regulatorySpecialisedLendingFinanceType;

  /// Purpose identifier.
  final num? purpose;

  /// Commitment account number.
  final String? commitmentAccountNumber;

  /// Indicates whether the facility is collateral dependent.
  final Reference? isCollateralDependent;

  /// Promissory note indicator.
  final num? promissoryNoteTaken;

  /// Limit expiry date.
  final String? limitExpiryDate;

  /// Limit availability date.
  final String? limitAvailabilityDate;

  /// Indicates whether the facility is committed.
  final bool? isCommitted;

  /// Present limit.
  final num? presentLimit;

  /// Parent facility identifier.
  final num? parentFacilityId;

  /// Indicates whether the facility is regulatory specialised lending.
  final bool? isRegulatorySpecialisedLending;

  /// Original limit.
  final num? originalLimit;

  /// Indicates whether this is the main limit.
  final bool? isMainLimit;

  /// Currency code.
  String? currency;

  /// Group identifier.
  final num? groupId;

  /// Customer RIM number.
  final num? rimNo;

  /// Country of risk.
  final String? countryOfRisk;

  /// SIC code.
  final num? sicCode;

  /// Revolving type.
  final String? revolvingType;

  /// Sector description identifier.
  final num? sectorDescription;
  final int? facilityMasterId;

  /// Indicates whether the limit is shared.
  final bool? isSharedLimit;

  /// Limit category.
  final String? limitCategory;

  /// Draft status.
  final dynamic isDraft;

  /// Islamic banking indicator.
  final dynamic forIslamic;

  /// Emirates identifier.
  final num? emirates;

  /// Property subtype.
  final num? propertySubType;

  /// Property type.
  final num? propertyType;

  /// Account type.
  final String? accountType;

  /// Product code.
  final String? productCode;

  /// Present limit in AED.
  final num? presentLimitAED;

  /// Proposed limit in AED.
  final num? proposedLimitAED;

  /// Project name.
  final String? projectName;

  /// Sustainability classification.
  final String? sustainabilityClassification;

  /// Proposed amount by CC.
  final num? proposedByCc;

  /// Proposed amount by CC in AED.
  final double? proposedByccAED;

  /// Currency of the proposed amount by CC.
  final String? proposedByCcCurrency;

  /// Remarks.
  final String? remarks;

  /// Policy deviations.
  final List<Reference>? policyDeviation;

  /// Indicates whether exposure is cross-border corporate exposure.
  final bool? isCrossBoarderCorporateExposure;

  /// Limit availability period.
  final String? limitAvailabilityPeriod;

  /// Past dues amount.
  final num? pastDues;

  /// Tenor unit.
  final String? tenorUnit;

  /// Tenor value.
  final num? tenorValue;

  /// Index value.
  final String? index;

  /// Margin sign.
  final String? marginSign;

  /// Margin value.
  final String? marginValue;

  /// Project code.
  final String? projectCode;

  /// Limit group name.
  final String? limitGroupName;

  /// Limit group identifier.
  final num? limitGroup;

  /// Limit cap type.
  num? limitCapType;

  /// Indicates whether the facility is conventional.
  final bool? isConventional;

  /// Indicates whether the facility is Islamic.
  final bool? isIslamic;

  /// Group owner identifier.
  final int? groupOwner;

  /// Additional details.
  Map<String, dynamic>? additionalDetails;

  /// Present outstanding currency.
  String? presentOutstandingCurrency;

  /// Converts this [FacilityDetails] instance to a JSON map.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      "groupOwner": Globals.request?.groupOwner,
      "facilityTitle": facilityTitle,
      "facilityMasterId": facilityMasterId,

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

/// Represents borrower mapping information for a facility,
/// including borrower and company borrower allocations.
class FacilityBorrowerMap {
  /// Creates a [FacilityBorrowerMap] instance.
  const FacilityBorrowerMap({
    this.borrowerList,
    this.companyBorrowerList,
  });

  /// Creates a [FacilityBorrowerMap] instance from a JSON map.
  factory FacilityBorrowerMap.fromJson(
    Map<String, dynamic> json,
  ) {
    return FacilityBorrowerMap(
      borrowerList: json["borrowerList"] as List<dynamic>?,
      companyBorrowerList: json["companyBorrowerList"] as List<dynamic>?,
    );
  }

  /// Borrower allocation list.
  final List<dynamic>? borrowerList;

  /// Company borrower allocation list.
  final List<dynamic>? companyBorrowerList;

  /// Converts this [FacilityBorrowerMap] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "borrowerList": borrowerList,
    };
  }
}

/// Represents a facility sub-limit block containing
/// facility details, borrower mappings, and conditions.
class FacilitySubLimitBlock {
  /// Creates a [FacilitySubLimitBlock] instance.
  FacilitySubLimitBlock({
    required this.facilityDetails,
    this.facilityBorrowerMap,
    this.conditions = const [],
  });

  /// Creates a [FacilitySubLimitBlock] instance from a JSON map.
  factory FacilitySubLimitBlock.fromJson(
    Map<String, dynamic> json,
  ) {
    return FacilitySubLimitBlock(
      facilityDetails: FacilityDetails.fromJson(json["facilityDetails"] ?? {}),
      facilityBorrowerMap: json["facilityBorrowerMap"] == null
          ? null
          : FacilityBorrowerMap.fromJson(json["facilityBorrowerMap"]),
      conditions: (json["conditions"] as List<dynamic>?) ?? const [],
    );
  }

  /// Facility details.
  final FacilityDetails facilityDetails;

  /// Facility borrower mapping information.
  final FacilityBorrowerMap? facilityBorrowerMap;

  /// Associated conditions.
  final List<dynamic> conditions;

  /// Converts this [FacilitySubLimitBlock] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        "facilityDetails": facilityDetails.toJson(),
        if (facilityBorrowerMap != null)
          "facilityBorrowerMap": facilityBorrowerMap!.toJson(),
        "conditions": conditions,
      };
}

/// Wraps facility sub-limit information for request
/// and response serialization.
class FacilitySubLimitWrapper {
  /// Creates a [FacilitySubLimitWrapper] instance.
  FacilitySubLimitWrapper({
    required this.facilitySubLimits,
  });

  /// Creates a [FacilitySubLimitWrapper] instance from a JSON map.
  factory FacilitySubLimitWrapper.fromJson(
    Map<String, dynamic> json,
  ) {
    return FacilitySubLimitWrapper(
      facilitySubLimits:
          FacilitySubLimitBlock.fromJson(json["facilitySubLimits"] ?? {}),
    );
  }

  /// Facility sub-limit details.
  final FacilitySubLimitBlock facilitySubLimits;

  /// Converts this [FacilitySubLimitWrapper] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        "facilitySubLimits": facilitySubLimits.toJson(),
      };
}

/// Converts a value to Unix epoch seconds.
///
/// Supports:
/// - Numeric epoch values.
/// - Date strings parseable by [DateTime.parse].
///
/// Returns `null` if the value cannot be converted.
int? _epochSeconds(v) {
  if (v == null) {
    return null;
  }
  if (v is num) {
    return v.toInt();
  }
  try {
    final dt = DateTime.parse(v.toString()).toUtc();
    return dt.millisecondsSinceEpoch ~/ 1000;
  } on Object catch (_) {
    return null;
  }
}

/// Facility details JSON payload for
/// Single Borrower Limit Cap information.
extension FacilityDetailsSingleBorrowerX on FacilityDetails {
  /// Converts this [FacilityDetails] instance into a request payload
  /// used for saving Single Borrower Limit Cap data.
  Map<String, dynamic> toSingleBorrowerJson() {
    final map = <String, dynamic>{
      "rimNo": rimNo,
      "groupId": groupId,
      "productCode": productCode,
      "appRefNo": appRefNo,
      "limitCategory": " ", // need to pass space string for limit caps
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
      "facilityMasterId": facilityMasterId,
      "isDraft": isDraft ?? false,
      "limitNo": limitNo,
    };
    return map;
  }
}

/// Facility details JSON payload for
/// Group Borrower Limit Cap information.
extension FacilityDetailsGroupBorrowerX on FacilityDetails {
  /// Converts this [FacilityDetails] instance into a request payload
  /// used for saving Group Borrower Limit Cap data.
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
      "limitNo": limitNo,
    };
    return map;
  }
}

/// Facility borrower mapping JSON payload for
/// Group Borrower company-level allocation data.
extension FacilityBorrowerMapCompanyX on FacilityBorrowerMap {
  /// Converts this [FacilityBorrowerMap] instance into a
  /// company borrower allocation request payload.
  Map<String, dynamic> toCompanyBorrowerJson() {
    return {
      "companyBorrowerList": companyBorrowerList ?? const [],
    };
  }
}

/// Facility details JSON payload for Single Borrower Limit Caps.
extension FacilityDetailsProjectX on FacilityDetails {
  /// Converts this [FacilityDetails] instance into a request payload
  /// used for saving Single Borrower Limit Cap information.
  Map<String, dynamic> toSaveProjectJson() {
    final map = <String, dynamic>{
      "groupOwner": Globals.request?.groupOwner,
      "rimNo": rimNo,
      "facilityMasterId": facilityMasterId,
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
      if ((limitNo ?? "").trim().isNotEmpty) "limitNo": limitNo,
    };
    return map;
  }
}

/// Represents metadata associated with a sub-limit.
class SubLimitMeta {
  /// Currency code or description.
  /// e.g., "AED"
  String? currency;

  /// Tenor unit description.
  /// e.g., "12 Months"
  String? tenorUnit;

  /// Tenor value.
  /// e.g., 12
  int? tenorValue;

  /// Reference index value.
  /// e.g., "13912"
  String? index;

  /// Margin sign.
  /// e.g., "+", "-"
  String? marginSign;

  /// Margin value.
  /// e.g., 2.5
  num? marginValue;
}
