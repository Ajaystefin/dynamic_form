import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Defines the available facility condition types.
enum ConditionType {
  /// Standard condition.
  standard,

  /// Non-standard condition.
  nonStandard,

  /// Contracting standard condition.
  contractingStandard;

  /// Creates a [ConditionType] from a string value.
  static ConditionType fromString(String value) {
    switch (value.trim().toUpperCase()) {
      case "STANDARD":
        return ConditionType.standard;
      case "NON-STANDARD":
        return ConditionType.nonStandard;
      case "CONTRACTING-STANDARD_CONDITIONS":
        return ConditionType.contractingStandard;
      default:
        return ConditionType.standard;
    }
  }

  /// Returns the API representation of the condition type.
  String get name => this == ConditionType.standard
      ? "STANDARD"
      : this == ConditionType.nonStandard
          ? "NON-STANDARD"
          : "CONTRACTING-STANDARD_CONDITIONS";
}

/// [TODO]: To be removed.
///
/// Represents facility information, including limits,
/// conditions, fee rates, and facility-specific details.
class FacilityDetail {
  /// Creates a [FacilityDetail] instance.
  FacilityDetail({
    required this.rimNo,
    required this.presentLimitAED,
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
    required this.limitCategory,
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
    this.cbdEquityTier325PercentAED,
    this.counterpartyEquity5PercentAED,
    this.counterpartyTotalAssets2PercentAED,
    this.proposedByCcAED,
    this.excessOverMaxLimitAllowanceByFiAED,
    this.excessOverMaxLimitAllowanceByCreditAED,
  });

  /// Creates a [FacilityDetail] instance from a JSON map.
  factory FacilityDetail.fromJson(Map<String, dynamic> json) {
    return FacilityDetail(
      facilityMasterId: json["facilityMasterId"] as int?,
      presentLimitAED: _toIntOrNull(json["presentLimitAED"]),
      tenorUnit: _toStrOrNull(json["tenorUnit"]),
      tenorValue: _toStrOrNull(json["tenorValue"]),
      presentOutstandingAED: _toDoubleOrNull(json["presentOutstandingAED"]),
      proposedLimitAED: _toDoubleOrNull(json["proposedLimitAED"]),
      cbdEquityTier325PercentAED:
          _toDoubleOrNull(json["cbdEquityTier325PercentAED"]),
      counterpartyEquity5PercentAED:
          _toDoubleOrNull(json["counterpartyEquity5PercentAED"]),
      counterpartyTotalAssets2PercentAED:
          _toDoubleOrNull(json["counterpartyTotalAssets2PercentAED"]),
      proposedByCcAED: _toDoubleOrNull(json["proposedByCcAED"]),
      excessOverMaxLimitAllowanceByFiAED:
          _toDoubleOrNull(json["excessOverMaxLimitAllowanceAED"]),
      excessOverMaxLimitAllowanceByCreditAED:
          _toDoubleOrNull(json["excessOverMaxLimitAllowanceByCcAED"]),
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
        name: json["excessOverMaxLimitAllowanceCurrency"] ??
            ServerConstants.aedCurrency,
      ),
      cbdEquityTier325Percent:
          (json["cbdEquityTier325Percent"] as num?)?.toDouble(),
      cbdEquityTier325PercentCurrency: Reference(
        name: json["cbdEquityTier325PercentCurrency"] ??
            ServerConstants.aedCurrency,
      ),
      counterpartyEquity5Percent:
          (json["counterpartyEquity5Percent"] as num?)?.toDouble(),
      counterpartyTotalAssets2PercentCurrency: Reference(
        name: json["counterpartyTotalAssets2PercentCurrency"] ??
            ServerConstants.aedCurrency,
      ),
      counterpartyTotalAssets2Percent:
          (json["counterpartyTotalAssets2Percent"] as num?)?.toDouble(),
      counterpartyEquity5PercentCurrency: Reference(
        name: json["counterpartyEquity5PercentCurrency"] ??
            ServerConstants.aedCurrency,
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
      limitCategory: json["limitCategory"] ?? "",
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
      presentOutstanding: _toDoubleOrNull(json["presentOutstanding"]),
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

  /// Tenor unit.
  final String? tenorUnit;

  /// Tenor value.
  final String? tenorValue;

  // FI fields

  /// Excess over maximum limit allowance by FI.
  double? excessOverMaxLimitAllowanceByFi;

  /// Currency for excess over maximum limit allowance by FI.
  Reference? excessOverMaxLimitAllowanceCurrencyByFi;

  /// CBD equity tier 3.25 percent.
  double? cbdEquityTier325Percent;

  /// Currency for CBD equity tier 3.25 percent.
  Reference? cbdEquityTier325PercentCurrency;

  /// Counterparty equity 5 percent.
  double? counterpartyEquity5Percent;

  /// Currency for counterparty equity 5 percent.
  Reference? counterpartyEquity5PercentCurrency;

  /// Counterparty total assets 2 percent.
  double? counterpartyTotalAssets2Percent;

  /// Currency for counterparty total assets 2 percent.
  Reference? counterpartyTotalAssets2PercentCurrency;

  /// Excess over maximum limit allowance by Credit.
  double? excessOverMaxLimitAllowanceByCredit;

  /// Currency for excess over maximum limit allowance by Credit.
  Reference? excessOverMaxLimitAllowanceCurrencyByCredit;

  /// Facility security detail identifier.
  int? facilitySecurityDetailId;

  /// Facility type identifier.
  int? type;

  /// Facility security identifier.
  int? facilitySecurityId;

  /// Facility identifier.
  final int facilityId;

  /// Indicates whether the facility is committed.
  final bool? isCommitted;

  /// Indicates whether the facility is shared.
  final bool? isSharedLimit;

  /// Indicates whether the facility is a cross-border corporate exposure.
  final bool? isCrossBoarderCorporateExposure;

  /// Facility title.
  final String facilityTitle;

  /// Country of risk.
  final String? countryOfRisk;

  /// Customer RIM number.
  final int? rimNo;

  /// Application reference number.
  final String appRefNo;

  /// Limit number.
  final String limitNo;

  /// Limit category.
  final String limitCategory;

  /// Controlling limit number.
  final String controllingLimitNo;

  /// Project name.
  final String projectName;

  /// Product code.
  final String? productCode;

  /// Limit cap type.
  num? limitCapType;

  /// Limit description.
  final int limitDescription;

  /// Advance type.
  final int advanceType;

  /// Seniority.
  final int seniority;

  /// SIC code.
  final int sicCode;

  /// Sector description.
  final String sectorDescription;

  /// Account type.
  final String accountType;

  /// Purpose.
  final int purpose;

  /// Property type.
  final int? propertyType;

  /// Property subtype.
  final int? propertySubType;

  /// Emirates identifier.
  final int emirates;

  /// Commitment account number.
  final String commitmentAccountNumber;

  /// Indicates whether the facility is a project finance activity.
  final bool? isProjectFinActivity;

  /// Indicates whether a promissory note has been taken.
  bool? promissoryNoteTaken;

  /// Sustainability classification.
  String sustainabilityClassification;

  /// Policy deviations.
  List<Reference>? policyDeviation;

  /// Collateral dependency indicator.
  Reference? isCollateralDependent;

  /// Currency.
  final String currency;

  /// Present limit.
  final int? presentLimit;
  final int? presentLimitAED;

  /// Limit availability date.
  final DateTime? limitAvailabilityDate;

  /// Limit availability period.
  final String limitAvailabilityPeriod;

  /// Proposed limit.
  final int? proposedLimit;

  /// Proposed amount by CC.
  final int? proposedByCc;

  /// Present outstanding amount.
  final num? presentOutstanding;

  /// Present outstanding amount in AED.
  final num? presentOutstandingAED;

  /// Proposed limit in AED.
  final num? proposedLimitAED;

  /// CBD equity tier 3.25 percent amount in AED.
  final double? cbdEquityTier325PercentAED;

  /// Counterparty equity 5 percent amount in AED.
  final double? counterpartyEquity5PercentAED;

  /// Counterparty total assets 2 percent amount in AED.
  final double? counterpartyTotalAssets2PercentAED;

  /// Proposed amount by CC in AED.
  final double? proposedByCcAED;

  /// Excess over maximum limit allowance proposed by FI, in AED.
  final double? excessOverMaxLimitAllowanceByFiAED;

  /// Excess over maximum limit allowance recommended by credit, in AED.
  final double? excessOverMaxLimitAllowanceByCreditAED;

  /// Present outstanding currency.
  String? presentOutstandingCurrency;

  /// Original limit.
  final int? originalLimit;

  /// Past dues amount.
  final int? pastDues;

  /// Indicates whether this is the main limit.
  final bool isMainLimit;

  /// Facility sub-limits.
  final List<FacilityDetail> facilitySubLimits;

  /// Facility conditions.
  final List<Condition> conditions;

  /// Facility fee rates.
  final List<FeeRate> feeRates;

  /// Additional details.
  Map<String, dynamic>? additionalDetails;

  /// Remarks.
  String? remarks;

  /// Proposed amount by CC currency.
  String? proposedByCcCurrency;

  /// Regulatory specialised lending indicator.
  Reference? isRegulatorySpecialisedLending;

  /// Regulatory specification.
  Reference? regulatorySpecification;

  /// Facility master identifier.
  int? facilityMasterId;

  /// Converts this [FacilityDetail] instance to a JSON map.
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
        "presentLimitAED": presentLimitAED,
        "proposedLimit": proposedLimit,
        "presentOutstanding": presentOutstanding,
        "pastDues": pastDues,
        "isMainLimit": isMainLimit,
        "facilitySubLimits": facilitySubLimits.map((e) => e.toJson()).toList(),
        "conditions": conditions.map((e) => e.toJson()).toList(),
        "feeRates": feeRates.map((e) => e.toJson()).toList(),
        "isCollateralDependent":
            isCollateralDependent?.id == ServerConstants.optionYESid,
        "isSharedLimit": isSharedLimit, //
      };
}

/// Represents a facility condition associated with a limit or facility.
class Condition {
  /// Creates a [Condition] instance.
  Condition({
    this.facilityConditionId,
    this.rimNo,
    this.groupId,
    this.facilityMasterId,
    this.limitType,
    this.facilityType,
    this.conditionId,
    this.description,
    this.conditionType,
    this.isWaivedOff,
    this.isAmended,
    this.isSelected,
    this.isShowAsTextField,
  });

  /// Creates a [Condition] instance from a JSON map.
  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      facilityConditionId: json["facilityConditionId"] as int?,
      facilityMasterId: json["facilityMasterId"] as int?,
      rimNo: json["rimNo"] as int?,
      groupId: json["groupId"] as int?,
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

  /// Facility condition identifier.
  /// Null for newly created conditions.
  int? facilityConditionId;

  /// Facility master identifier.
  int? facilityMasterId;

  /// Customer RIM number.
  int? rimNo;

  /// Limit type.
  /// e.g. "Main limit" or "Sub limit"
  String? limitType;

  /// Facility type.
  /// e.g. product code or "All"
  String? facilityType;

  /// Condition identifier.
  /// May be null or contain the reference identifier of the condition.
  int? conditionId;

  /// Condition description.
  String? description;

  /// Indicates whether the condition is waived off.
  bool? isWaivedOff;

  /// Indicates whether the condition has been amended.
  bool? isAmended;

  /// Condition type.
  ConditionType? conditionType;

  /// Indicates whether the condition is selected.
  bool? isSelected;

  /// Indicates whether the condition should be displayed as a text field.
  bool? isShowAsTextField;

  /// Group identifier.
  int? groupId;

  /// Converts this [Condition] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        "facilityConditionId": facilityConditionId,
        "rimNo": rimNo,
        "facilityMasterId": facilityMasterId,
        "limitType": limitType,
        "facilityType": facilityType,
        "conditionId": conditionId,
        "description": description ?? " ",
        "isWaivedOff": isWaivedOff ?? false,
        "isAmended": isAmended ?? false,
        "conditionType": conditionType?.name,
        "isSelected": isSelected ?? false,
        "groupId": Globals.request?.groupId,
      };

  /// Indicates whether the condition is a standard condition.
  bool get isStandard => conditionType?.name == ConditionType.standard.name;

  /// Indicates whether the condition is a non-standard condition.
  bool get isNonStandard =>
      conditionType?.name == ConditionType.nonStandard.name;

  /// Indicates whether the condition is a contracting standard condition.
  bool get isContractingStandard =>
      conditionType?.name == ConditionType.contractingStandard.name;
}

/// Represents a fee rate configuration associated with a facility.
class FeeRate {
  /// Creates a [FeeRate] instance.
  FeeRate({
    this.feeRateId,
    this.feeType,
    this.amount,
    this.percentage,
    this.frequency,
    this.comment,
  });

  /// Creates a [FeeRate] instance from a JSON map.
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

  /// Fee rate identifier.
  int? feeRateId;

  /// Fee type.
  String? feeType;

  /// Fee amount.
  final double? amount;

  /// Fee percentage.
  final double? percentage;

  /// Fee frequency.
  String? frequency;

  /// Fee comments.
  final String? comment;

  /// Converts this [FeeRate] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        "feeRateId": feeRateId,
        "feeType": feeType,
        "amount": amount,
        "percentage": percentage,
        "frequency": frequency,
        "comment": comment,
      };
}

/// Represents additional facility-specific details and
/// trade finance information.
class AdditionalDetails {
  /// Creates an [AdditionalDetails] instance.
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

  /// Creates an [AdditionalDetails] instance from a JSON map.
  factory AdditionalDetails.fromJson(
    Map<String, dynamic> json,
  ) {
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

  /// Excess amount details.
  final Map<String, dynamic> excessAmount;

  /// Regularization details.
  final String toBeRegularizedBy;

  /// Source of repayment.
  final String sourceOfRepayment;

  /// LC commission details.
  final List<LcCommission> lcCommission;

  /// LC margin.
  final String lcMargin;

  /// Margin extent.
  final String marginExtent;

  /// Usance tenor information.
  final UsanceTenor usanceTenor;

  /// Preferential exchange rate information.
  final PreferentialExchangeRate preferentialExchangeRate;

  /// Indicates whether shipment is by sea or air.
  final bool shipmentBySeaOrAir;

  /// Converts this [AdditionalDetails] instance to a JSON map.
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

/// Represents LC commission information for a specific
/// amount range and validity period.
class LcCommission {
  /// Creates an [LcCommission] instance.
  LcCommission({
    required this.dateFrom,
    required this.dateTo,
    required this.amountFrom,
    required this.amountTo,
    required this.gridCommission,
  });

  /// Creates an [LcCommission] instance from a JSON map.
  factory LcCommission.fromJson(
    Map<String, dynamic> json,
  ) {
    return LcCommission(
      dateFrom: json["dateFrom"]?["formatted"] ?? "",
      dateTo: json["dateTo"]?["formatted"] ?? "",
      amountFrom: (json["amountfrom"] ?? 0).toDouble(),
      amountTo: (json["amountTo"] ?? 0).toDouble(),
      gridCommission: json["gridCommission"] ?? "",
    );
  }

  /// Effective start date.
  final String dateFrom;

  /// Effective end date.
  final String dateTo;

  /// Minimum amount.
  final double amountFrom;

  /// Maximum amount.
  final double amountTo;

  /// Grid commission value.
  final String gridCommission;

  /// Converts this [LcCommission] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        "dateFrom": dateFrom,
        "dateTo": dateTo,
        "amountfrom": amountFrom,
        "amountTo": amountTo,
        "gridCommission": gridCommission,
      };
}

/// Represents usance tenor information.
class UsanceTenor {
  /// Creates a [UsanceTenor] instance.
  UsanceTenor({
    required this.tenorUnit,
    required this.tenorValue,
  });

  /// Creates a [UsanceTenor] instance from a JSON map.
  factory UsanceTenor.fromJson(
    Map<String, dynamic> json,
  ) {
    return UsanceTenor(
      tenorUnit: json["tenorUnit"] ?? "",
      tenorValue: json["tenorValue"] ?? "",
    );
  }

  /// Tenor unit.
  final String tenorUnit;

  /// Tenor value.
  final String tenorValue;

  /// Converts this [UsanceTenor] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        "tenorUnit": tenorUnit,
        "tenorValue": tenorValue,
      };
}

/// Represents a preferential exchange rate configuration.
class PreferentialExchangeRate {
  /// Creates a [PreferentialExchangeRate] instance.
  PreferentialExchangeRate({
    required this.exchangeRateCurrency,
    required this.percentage,
  });

  /// Creates a [PreferentialExchangeRate] instance from a JSON map.
  factory PreferentialExchangeRate.fromJson(
    Map<String, dynamic> json,
  ) {
    return PreferentialExchangeRate(
      exchangeRateCurrency: json["exchangeRateCurrency"] ?? "",
      percentage: json["percentage"] ?? "",
    );
  }

  /// Exchange rate currency.
  final String exchangeRateCurrency;

  /// Preferential percentage.
  final String percentage;

  /// Converts this [PreferentialExchangeRate] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        "exchangeRateCurrency": exchangeRateCurrency,
        "percentage": percentage,
      };
}

/// Converts a value to an integer if possible.
///
/// Returns `null` if the value cannot be converted.
int? _toIntOrNull(v) {
  if (v == null) {
    return null;
  }
  if (v is int) {
    return v;
  }
  if (v is double) {
    return v.toInt();
  }
  return int.tryParse(v.toString()); // handles "123" strings if ever returned
}

/// Converts a value to a double if possible.
///
/// Returns `null` if the value cannot be converted. The AED amounts arrive as
/// an `int` whenever the backend has nothing after the decimal point
/// (`"proposedLimitAED": 7`), and quoted amounts are accepted too.
double? _toDoubleOrNull(v) {
  if (v == null) {
    return null;
  }
  if (v is num) {
    return v.toDouble();
  }
  return double.tryParse(v.toString());
}

/// Converts a value to a boolean if possible.
///
/// Returns `null` if the value cannot be converted.
bool? _toBoolOrNull(v) {
  if (v == null) {
    return null;
  }
  if (v is bool) {
    return v;
  }
  final s = v.toString().trim().toLowerCase();
  if (s == "true") {
    return true;
  }
  if (s == "false") {
    return false;
  }
  return null;
}

/// Converts a value to a [DateTime] if possible.
///
/// Returns `null` if the value cannot be parsed.
DateTime? _toDateOrNull(v) {
  if (v == null) {
    return null;
  }
  // expects ISO-8601 like "2025-10-03T09:02:49"
  try {
    return DateTime.tryParse(v.toString());
  } on Object catch (_) {
    return null;
  }
}

/// Converts a value to a string.
///
/// Returns an empty string if the value is `null`.
String _toStrOrEmpty(v) => v?.toString() ?? "";

/// Converts a value to a string.
///
/// Returns `null` if the value is `null`.
String? _toStrOrNull(v) => v?.toString();
