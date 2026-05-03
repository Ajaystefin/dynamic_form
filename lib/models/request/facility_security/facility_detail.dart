import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/models/admin/reference.dart";

enum ConditionType {
  standard,
  nonStandard;

  static ConditionType fromString(String value) {
    switch (value.trim().toUpperCase()) {
      case "STANDARD":
        return ConditionType.standard;
      case "NON-STANDARD":
        return ConditionType.nonStandard;
      default:
        return ConditionType.standard;
    }
  }

  String get name =>
      this == ConditionType.standard ? "STANDARD" : "NON-STANDARD";
}

//TODOD: To be removed
class FacilityDetail {
  FacilityDetail({
    required this.rimNo,
    required this.countryOfRisk,
    required this.seniority,
    required this.sicCode,
    required this.limitAvailabilityPeriod,
    required this.facilityId,
    required this.isSharedLimit,
    required this.isCommitted,
    required this.facilityTitle,
    required this.appRefNo,
    required this.projectName,
    required this.limitNo,
    required this.isProjectFinActivity,
    required this.promissoryNoteTaken,
    required this.controllingLimitNo,
    required this.limitDescription,
    required this.advanceType,
    required this.sectorDescription,
    required this.accountType,
    required this.purpose,
    required this.emirates,
    required this.currency,
    required this.limitAvailabilityDate,
    required this.commitmentAccountNumber,
    required this.presentLimit,
    required this.proposedLimit,
    required this.proposedByCc,
    required this.sustainabilityClassification,
    required this.policyDeviation,
    required this.presentOutstanding,
    required this.originalLimit,
    required this.pastDues,
    required this.isMainLimit,
    required this.facilitySubLimits,
    required this.conditions,
    required this.feeRates,
    required this.additionalDetails,
    this.presentOutstandingCurrency,
    this.presentOutstandingAED,
    this.proposedByCcCurrency,
    this.proposedLimitAED,
    this.counterpartyEquity5Percent,
    this.facilityMasterId,
    this.regulatorySpecification,
    this.isRegulatorySpecialisedLending,
    this.isCollateralDependent,
    this.isCrossBoarderCorporateExposure,
    this.productCode,
    this.limitCapType,
    this.type,
    this.facilitySecurityDetailId,
    this.facilitySecurityId,
    this.propertyType,
    this.tenorUnit,
    this.tenorValue,
    this.propertySubType,
    this.remarks,
    this.excessOverMaxLimitAllowanceByFi,
    this.excessOverMaxLimitAllowanceCurrencyByFi,
    this.cbdEquityTier325Percent,
    this.cbdEquityTier325PercentCurrency,
    this.counterpartyTotalAssets2Percent,
    this.counterpartyTotalAssets2PercentCurrency,
    this.excessOverMaxLimitAllowanceByCredit,
    this.counterpartyEquity5PercentCurrency,
    this.excessOverMaxLimitAllowanceCurrencyByCredit,
  });

  factory FacilityDetail.fromJson(Map<String, dynamic> json) {
    return FacilityDetail(
      facilityMasterId: json["facilityMasterId"] as int?,
      tenorUnit: _toStrOrNull(json["tenorUnit"]),
      tenorValue: _toStrOrNull(json["tenorValue"]),
      presentOutstandingAED: json["presentOutstandingAED"] as num?,
      proposedLimitAED: json["proposedLimitAED"] as num?,
      presentOutstandingCurrency: json["presentOutstandingCurrency"] as String?,
      rimNo: json["rimNo"] ?? 0,
      excessOverMaxLimitAllowanceByFi:
          (json["excessOverMaxLimitAllowance"] as num?)?.toDouble(),
      excessOverMaxLimitAllowanceByCredit:
          (json["excessOverMaxLimitAllowanceByCc"] as num?)?.toDouble(),
      excessOverMaxLimitAllowanceCurrencyByCredit: Reference(
        name: json["excessOverMaxLimitAllowanceCurrencyByCc"] ??
            ServerConstants.aedCurrency,
      ),
      excessOverMaxLimitAllowanceCurrencyByFi: Reference(
        name: json["excessOverMaxLimitAllowanceCurrency"] as String?,
      ),
      cbdEquityTier325Percent:
          (json["cbdEquityTier325Percent"] as num?)?.toDouble(),
      cbdEquityTier325PercentCurrency:
          Reference(name: json["cbdEquityTier325PercentCurrency"] as String?),
      counterpartyEquity5Percent:
          (json["counterpartyEquity5Percent"] as num?)?.toDouble(),
      counterpartyTotalAssets2PercentCurrency: Reference(
        name: json["counterpartyTotalAssets2PercentCurrency"] as String?,
      ),
      counterpartyTotalAssets2Percent:
          (json["counterpartyTotalAssets2Percent"] as num?)?.toDouble(),
      counterpartyEquity5PercentCurrency: Reference(
        name: json["counterpartyEquity5PercentCurrency"] as String?,
      ),
      regulatorySpecification: Reference(
        id: json["regulatorySpecialisedLendingFinanceType"] as int?,
      ),
      seniority: json["seniority"] ?? 0,
      isRegulatorySpecialisedLending:
          json["isRegulatorySpecialisedLending"] == false
              ? Reference(
                  id: ServerConstants.optionNOid,
                  name: "No",
                  isActive: true,
                )
              : Reference(
                  id: ServerConstants.optionYESid,
                  name: "Yes",
                  isActive: true,
                ),
      isCollateralDependent: json["isCollateralDependent"] == false
          ? Reference(
              id: ServerConstants.optionNOid,
              name: "No",
              isActive: true,
            )
          : Reference(
              id: ServerConstants.optionYESid,
              name: "Yes",
              isActive: true,
            ),
      sicCode: json["sicCode"] ?? 0,
      limitCapType: json["limitCapType"] as num?,
      isSharedLimit: _toBoolOrNull(json["isSharedLimit"]),
      isCrossBoarderCorporateExposure:
          _toBoolOrNull(json["isCrossBoarderCorporateExposure"]),
      isCommitted: _toBoolOrNull(json["isCommitted"]),
      isProjectFinActivity: _toBoolOrNull(json["isProjectFinActivity"]), //
      promissoryNoteTaken:
          json["promissoryNoteTaken"] == ServerConstants.optionYESid,
      facilityId: json["facilityId"] ?? 0,
      facilityTitle: json["facilityTitle"] ?? "",
      appRefNo: json["appRefNo"] ?? "",
      limitNo: json["limitNo"] ?? "",
      limitAvailabilityDate: _toDateOrNull(json["limitAvailabilityDate"]), //
      sustainabilityClassification:
          json["sustainabilityClassification"]?.toString() ?? "",
      policyDeviation: json["policyDeviation"] is String
          ? (json["policyDeviation"] as String)
              .split(",")
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .map((e) {
              final maybeId = int.tryParse(e);
              return maybeId != null
                  ? Reference(id: maybeId)
                  : Reference(name: e);
            }).toList()
          : [],
      commitmentAccountNumber: json["commitmentAccountNumber"] ?? "",
      limitAvailabilityPeriod: json["limitAvailabilityPeriod"] ?? "",
      controllingLimitNo: json["controllingLimitNo"] ?? "",
      projectName: json["projectName"] ?? "",
      productCode: json["productCode"] ?? "",
      limitDescription: json["limitDescription"] ?? 0,
      countryOfRisk:
          _toStrOrNull(json["countryOfRisk"] ?? json["Country_of_Risk"]),
      advanceType: json["advanceType"] ?? 0,
      sectorDescription: _toStrOrEmpty(json["sectorDescription"]),
      accountType: _toStrOrEmpty(json["accountType"]),
      purpose: json["purpose"] ?? 0,
      propertyType: json["propertyType"] ?? 0,
      propertySubType: json["propertySubType"] ?? 0,
      emirates: json["emirates"] ?? 0,
      currency: json["currency"] ?? ServerConstants.aedCurrency,
      proposedByCc: _toIntOrNull(json["proposedByCc"]),
      proposedByCcCurrency:
          json["proposedByCcCurrency"] ?? ServerConstants.aedCurrency,
      presentLimit: _toIntOrNull(json["presentLimit"]),
      originalLimit: _toIntOrNull(json["originalLimit"]),
      proposedLimit: _toIntOrNull(json["proposedLimit"]),
      presentOutstanding: _toIntOrNull(json["presentOutstanding"]),
      pastDues: _toIntOrNull(json["pastDues"]),
      isMainLimit: json["isMainLimit"] ?? false,
      facilitySubLimits: (json["facilitySubLimits"] as List? ?? [])
          .map((e) => FacilityDetail.fromJson(e))
          .toList(),
      conditions: (json["conditions"] as List? ?? [])
          .map((e) => Condition.fromJson(e))
          .toList(),
      feeRates: (json["feeRates"] as List? ?? [])
          .map((e) => FeeRate.fromJson(e))
          .toList(),
      additionalDetails: {}, //will be populated from repository
    );
  }
  final String? tenorUnit;
  final String? tenorValue;
//FI fields
  double? excessOverMaxLimitAllowanceByFi;
  Reference? excessOverMaxLimitAllowanceCurrencyByFi;
  double? cbdEquityTier325Percent;
  Reference? cbdEquityTier325PercentCurrency;
  double? counterpartyEquity5Percent;
  Reference? counterpartyEquity5PercentCurrency;
  double? counterpartyTotalAssets2Percent;
  Reference? counterpartyTotalAssets2PercentCurrency;
  double? excessOverMaxLimitAllowanceByCredit;
  Reference? excessOverMaxLimitAllowanceCurrencyByCredit;
  int? facilitySecurityDetailId;
  int? type;
  int? facilitySecurityId;

  ///
  final int facilityId;
  final bool? isCommitted;
  final bool? isSharedLimit;
  final bool? isCrossBoarderCorporateExposure;
  final String facilityTitle;
  final String? countryOfRisk;
  final int? rimNo;
  final String appRefNo;
  final String limitNo;
  final String controllingLimitNo;
  final String projectName;
  final String? productCode;
  num? limitCapType;
  final int limitDescription;
  final int advanceType;
  final int seniority;
  final int sicCode;
  final String sectorDescription;
  final String accountType;
  final int purpose;
  final int? propertyType;
  final int? propertySubType;
  final int emirates;
  final String commitmentAccountNumber;
  final bool? isProjectFinActivity;
  bool? promissoryNoteTaken;
  String sustainabilityClassification;
  List<Reference>? policyDeviation;
  Reference? isCollateralDependent;
  final String currency;
  final int? presentLimit;
  final DateTime? limitAvailabilityDate;
  final String limitAvailabilityPeriod;
  final int? proposedLimit;
  final int? proposedByCc;
  final int? presentOutstanding;
  final num? presentOutstandingAED;
  final num? proposedLimitAED;

  String? presentOutstandingCurrency;
  final int? originalLimit;
  final int? pastDues;
  final bool isMainLimit;
  final List<FacilityDetail> facilitySubLimits;
  final List<Condition> conditions;
  final List<FeeRate> feeRates;
  Map<String, dynamic>? additionalDetails;
  String? remarks;
  String? proposedByCcCurrency;
  Reference? isRegulatorySpecialisedLending;
  Reference? regulatorySpecification;

  int? facilityMasterId;

  Map<String, dynamic> toJson() => {
        "facilityId": facilityId,
        "facilityMasterId": facilityMasterId,
        "facilityTitle": facilityTitle,
        "appRefNo": appRefNo,
        "isDraft": false,
        "isProjectFinActivity": isProjectFinActivity,
        "promissoryNoteTaken": promissoryNoteTaken,
        "limitNo": limitNo,
        "controllingLimitNo": controllingLimitNo,
        "limitDescription": limitDescription,
        "limitAvailabilityDate": limitAvailabilityDate?.toIso8601String(), //
        "currency": currency,
        "policyDeviation": policyDeviation?.map((e) => e.id).toList(),
        "presentLimit": presentLimit,
        "proposedLimit": proposedLimit,
        "presentOutstanding": presentOutstanding,
        "pastDues": pastDues,
        "isMainLimit": isMainLimit,
        "facilitySubLimits": facilitySubLimits.map((e) => e.toJson()).toList(),
        "conditions": conditions.map((e) => e.toJson()).toList(),
        "feeRates": feeRates.map((e) => e.toJson()).toList(),
        "isCollateralDependent":
            isCollateralDependent?.id == ServerConstants.optionYESid
                ? true
                : false,
        "isSharedLimit": isSharedLimit, //
      };
}

class Condition {
  Condition({
    this.facilityConditionId,
    this.rimNo,
    this.limitType,
    this.facilityType,
    this.conditionId,
    this.description,
    this.conditionType,
    this.isWaivedOff,
    this.isAmended,
    this.isSelected,
  });

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      facilityConditionId: json["facilityConditionId"] as int?,
      rimNo: json["rimNo"] as int?,
      limitType: json["limitType"] as String?,
      facilityType: json["facilityType"] as String?,
      conditionId: json["conditionId"] as int?,
      conditionType: ConditionType.fromString((json["conditionType"]) ?? ""),
      description: json["description"] as String? ?? "",
      isWaivedOff: json["isWaivedOff"] as bool? ?? false,
      isAmended: json["isAmended"] as bool? ?? false,
      isSelected: json["isSelected"] as bool? ?? false,
    );
  }
  int? facilityConditionId; // null for newly creating condition
  int? rimNo;
  String? limitType; //  "Main limit" / "Sub limit"
  String? facilityType; //  product code or "All"
  int? conditionId; // null or referecne ID of condition
  String? description;
  bool? isWaivedOff;
  bool? isAmended;
  ConditionType? conditionType;
  bool? isSelected;

  Map<String, dynamic> toJson() => {
        "facilityConditionId": facilityConditionId,
        "rimNo": rimNo,
        "limitType": limitType,
        "facilityType": facilityType,
        "conditionId": conditionId,
        "description": description ?? " ",
        "isWaivedOff": isWaivedOff ?? false,
        "isAmended": isAmended ?? false,
        "conditionType": conditionType?.name,
        "isSelected": isSelected ?? false,
      };

  bool get isStandard => conditionType?.name == ConditionType.standard.name;
  bool get isNonStandard =>
      conditionType?.name == ConditionType.nonStandard.name;
}

class FeeRate {
  FeeRate({
    this.feeRateId,
    this.feeType,
    this.amount,
    this.percentage,
    this.frequency,
    this.comment,
  });

  factory FeeRate.fromJson(Map<String, dynamic> json) {
    return FeeRate(
      feeRateId: json["feeRateId"] ?? 0,
      feeType: json["feeType"] ?? "",
      amount: (json["amount"] ?? 0).toDouble(),
      percentage: (json["percentage"] ?? 0).toDouble(),
      frequency: json["frequency"] ?? "",
      comment: json["comment"] ?? "",
    );
  }
  int? feeRateId;
  String? feeType;
  final double? amount;
  final double? percentage;
  String? frequency;
  final String? comment;

  Map<String, dynamic> toJson() => {
        "feeRateId": feeRateId,
        "feeType": feeType,
        "amount": amount,
        "percentage": percentage,
        "frequency": frequency,
        "comment": comment,
      };
}

class AdditionalDetails {
  AdditionalDetails({
    required this.excessAmount,
    required this.toBeRegularizedBy,
    required this.sourceOfRepayment,
    required this.lcCommission,
    required this.lcMargin,
    required this.marginExtent,
    required this.usanceTenor,
    required this.preferentialExchangeRate,
    required this.shipmentBySeaOrAir,
  });

  factory AdditionalDetails.fromJson(Map<String, dynamic> json) {
    return AdditionalDetails(
      excessAmount: json["excessAmount"] ?? {},
      toBeRegularizedBy: json["toBeRegularizedBy"] ?? "",
      sourceOfRepayment: json["sourceOfRepayment"] ?? "",
      lcCommission: (json["lcCommission"] as List? ?? [])
          .map((e) => LcCommission.fromJson(e))
          .toList(),
      lcMargin: json["lcMargin"] ?? "",
      marginExtent: json["marginExtent"] ?? "",
      usanceTenor: UsanceTenor.fromJson(json["usanceTenor"] ?? {}),
      preferentialExchangeRate: PreferentialExchangeRate.fromJson(
        json["preferentialExchangeRate"] ?? {},
      ),
      shipmentBySeaOrAir: json["shipmentBySeaOrAir"] ?? false,
    );
  }
  final Map<String, dynamic> excessAmount;
  final String toBeRegularizedBy;
  final String sourceOfRepayment;
  final List<LcCommission> lcCommission;
  final String lcMargin;
  final String marginExtent;
  final UsanceTenor usanceTenor;
  final PreferentialExchangeRate preferentialExchangeRate;
  final bool shipmentBySeaOrAir;

  Map<String, dynamic> toJson() => {
        "excessAmount": excessAmount,
        "toBeRegularizedBy": toBeRegularizedBy,
        "sourceOfRepayment": sourceOfRepayment,
        "lcCommission": lcCommission.map((e) => e.toJson()).toList(),
        "lcMargin": lcMargin,
        "marginExtent": marginExtent,
        "usanceTenor": usanceTenor.toJson(),
        "preferentialExchangeRate": preferentialExchangeRate.toJson(),
        "shipmentBySeaOrAir": shipmentBySeaOrAir,
      };
}

class LcCommission {
  LcCommission({
    required this.dateFrom,
    required this.dateTo,
    required this.amountFrom,
    required this.amountTo,
    required this.gridCommission,
  });

  factory LcCommission.fromJson(Map<String, dynamic> json) {
    return LcCommission(
      dateFrom: json["dateFrom"]?["formatted"] ?? "",
      dateTo: json["dateTo"]?["formatted"] ?? "",
      amountFrom: (json["amountfrom"] ?? 0).toDouble(),
      amountTo: (json["amountTo"] ?? 0).toDouble(),
      gridCommission: json["gridCommission"] ?? "",
    );
  }
  final String dateFrom;
  final String dateTo;
  final double amountFrom;
  final double amountTo;
  final String gridCommission;

  Map<String, dynamic> toJson() => {
        "dateFrom": dateFrom,
        "dateTo": dateTo,
        "amountfrom": amountFrom,
        "amountTo": amountTo,
        "gridCommission": gridCommission,
      };
}

class UsanceTenor {
  UsanceTenor({required this.tenorUnit, required this.tenorValue});

  factory UsanceTenor.fromJson(Map<String, dynamic> json) {
    return UsanceTenor(
      tenorUnit: json["tenorUnit"] ?? "",
      tenorValue: json["tenorValue"] ?? "",
    );
  }
  final String tenorUnit;
  final String tenorValue;

  Map<String, dynamic> toJson() => {
        "tenorUnit": tenorUnit,
        "tenorValue": tenorValue,
      };
}

class PreferentialExchangeRate {
  PreferentialExchangeRate({
    required this.exchangeRateCurrency,
    required this.percentage,
  });

  factory PreferentialExchangeRate.fromJson(Map<String, dynamic> json) {
    return PreferentialExchangeRate(
      exchangeRateCurrency: json["exchangeRateCurrency"] ?? "",
      percentage: json["percentage"] ?? "",
    );
  }
  final String exchangeRateCurrency;
  final String percentage;

  Map<String, dynamic> toJson() => {
        "exchangeRateCurrency": exchangeRateCurrency,
        "percentage": percentage,
      };
}

int? _toIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()); // handles "123" strings if ever returned
}

bool? _toBoolOrNull(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  final s = v.toString().trim().toLowerCase();
  if (s == "true") return true;
  if (s == "false") return false;
  return null;
}

DateTime? _toDateOrNull(dynamic v) {
  if (v == null) return null;
  // expects ISO-8601 like "2025-10-03T09:02:49"
  try {
    return DateTime.tryParse(v.toString());
  } catch (_) {
    return null;
  }
}

String _toStrOrEmpty(dynamic v) => v?.toString() ?? "";
String? _toStrOrNull(dynamic v) => v?.toString();
