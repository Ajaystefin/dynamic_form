enum ConditionType {
  standard,
  nonStandard;

  static ConditionType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'STANDARD':
        return ConditionType.standard;
      case 'NON_STANDARD':
        return ConditionType.nonStandard;
      default:
        return ConditionType.standard;
    }
  }

  String get name =>
      this == ConditionType.standard ? 'STANDARD' : 'NON_STANDARD';
}

class FacilityDetail {
  final int facilityId;
  final bool? isCommitted;
  final bool? isSharedLimit;
  final String facilityTitle;
  final String? countryOfRisk;
  final int? rimNo;
  final String appRefNo;
  final String limitNo;
  final String controllingLimitNo;
  final String projectName;
  final int limitDescription;
  final int advanceType;
  final int seniority;
  final int sicCode;
  final int sectorDescription;
  final String accountType;
  final int purpose;
  final int emirates;
  final String commitmentAccountNumber;
  final bool? isProjectFinActivity;
  String sustainabilityClassification;
  final String currency;
  final int? presentLimit;
  final DateTime? limitAvailabilityDate;
  final String limitAvailabilityPeriod;
  final int? proposedLimit;
  final int? proposedByCc;
  final int? presentOutstanding;
  final int? originalLimit;
  final int? pastDues;
  final bool isMainLimit;
  final List<FacilityDetail> facilitySubLimits;
  final List<Condition> conditions;
  final List<FeeRate> feeRates;
  final AdditionalDetails additionalDetails;
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
    required this.presentOutstanding,
    required this.originalLimit,
    required this.pastDues,
    required this.isMainLimit,
    required this.facilitySubLimits,
    required this.conditions,
    required this.feeRates,
    required this.additionalDetails,
  });

  factory FacilityDetail.fromJson(Map<String, dynamic> json) {
    return FacilityDetail(
      rimNo: json['rimNo'] ?? 0,
      seniority: json['seniority'] ?? 0,
      sicCode: json['sicCode'] ?? 0,
      isSharedLimit: _toBoolOrNull(json['isSharedLimit']),
      isCommitted: _toBoolOrNull(json['isCommitted']),
      isProjectFinActivity: _toBoolOrNull(json['isProjectFinActivity']), //
      facilityId: json['facilityId'] ?? 0,
      facilityTitle: json['facilityTitle'] ?? '',
      appRefNo: json['appRefNo'] ?? '',
      limitNo: json['limitNo'] ?? '',
      limitAvailabilityDate: _toDateOrNull(json['limitAvailabilityDate']), //
      sustainabilityClassification:
          json['sustainabilityClassification']?.toString() ?? '',
      commitmentAccountNumber: json['commitmentAccountNumber'] ?? '',
      limitAvailabilityPeriod: json['limitAvailabilityPeriod'] ?? '',
      controllingLimitNo: json['controllingLimitNo'] ?? "",
      projectName: json['projectName'] ?? "",
      limitDescription: json['limitDescription'] ?? 0,
      countryOfRisk:
          (json['countryOfRisk'] ?? json['Country_of_Risk']) as String?,
      advanceType: json['advanceType'] ?? 0,
      sectorDescription: json['sectorDescription'] ?? 0,
      accountType: json['accountType'] ?? 0,
      purpose: json['purpose'] ?? 0,
      emirates: json['emirates'] ?? 0,
      currency: json['currency'] ?? '',
      proposedByCc: _toIntOrNull(json['proposedByCc']),
      presentLimit: _toIntOrNull(json['presentLimit']),
      originalLimit: _toIntOrNull(json['originalLimit']),
      proposedLimit: _toIntOrNull(json['proposedLimit']),
      presentOutstanding: _toIntOrNull(json['presentOutstanding']),
      pastDues: _toIntOrNull(json['pastDues']),
      isMainLimit: json['isMainLimit'] ?? false,
      facilitySubLimits: (json['facilitySubLimits'] as List? ?? [])
          .map((e) => FacilityDetail.fromJson(e))
          .toList(),
      conditions: (json['conditions'] as List? ?? [])
          .map((e) => Condition.fromJson(e))
          .toList(),
      feeRates: (json['feeRates'] as List? ?? [])
          .map((e) => FeeRate.fromJson(e))
          .toList(),
      additionalDetails:
          AdditionalDetails.fromJson(json['additionalDetails'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'facilityId': facilityId,
        'facilityTitle': facilityTitle,
        'appRefNo': appRefNo,
        'isProjectFinActivity': isProjectFinActivity,
        'limitNo': limitNo,
        'controllingLimitNo': controllingLimitNo,
        'limitDescription': limitDescription,
        'limitAvailabilityDate': limitAvailabilityDate?.toIso8601String(), //
        'currency': currency,
        'presentLimit': presentLimit,
        'proposedLimit': proposedLimit,
        'presentOutstanding': presentOutstanding,
        'pastDues': pastDues,
        'isMainLimit': isMainLimit,
        'facilitySubLimits': facilitySubLimits.map((e) => e.toJson()).toList(),
        'conditions': conditions.map((e) => e.toJson()).toList(),
        'feeRates': feeRates.map((e) => e.toJson()).toList(),
        'additionalDetails': additionalDetails.toJson(),
        'isSharedLimit': isSharedLimit, //
      };
}

class Condition {
  int? conditionId;
  String? description;
  bool? isWaivedOff;
  bool? isAmended;
  ConditionType? conditionType;

  Condition({
    this.conditionId,
    this.description,
    this.conditionType,
    this.isWaivedOff,
    this.isAmended,
  });

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      conditionId: json['conditionId'] ?? 0,
      conditionType: ConditionType.fromString(json['conditionType'] ?? ''),
      description: json['description'] ?? '',
      isWaivedOff: json['isWaivedOff'] ?? false,
      isAmended: json['isAmended'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'conditionId': conditionId,
        'description': description,
        'isWaivedOff': isWaivedOff,
        'isAmended': isAmended,
        'conditionType': conditionType?.name,
      };

  bool get isStandard => conditionType == ConditionType.standard;
  bool get isNonStandard => conditionType == ConditionType.nonStandard;
}

class FeeRate {
  int? feeRateId;
  String? feeType;
  final double? amount;
  final double? percentage;
  String? frequency;
  final String? comment;

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
      feeRateId: json['feeRateId'] ?? 0,
      feeType: json['feeType'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
      frequency: json['frequency'] ?? '',
      comment: json['comment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'feeRateId': feeRateId,
        'feeType': feeType,
        'amount': amount,
        'percentage': percentage,
        'frequency': frequency,
        'comment': comment,
      };
}

class AdditionalDetails {
  final Map<String, dynamic> excessAmount;
  final String toBeRegularizedBy;
  final String sourceOfRepayment;
  final List<LcCommission> lcCommission;
  final String lcMargin;
  final String marginExtent;
  final UsanceTenor usanceTenor;
  final PreferentialExchangeRate preferentialExchangeRate;
  final bool shipmentBySeaOrAir;

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
      excessAmount: json['excessAmount'] ?? {},
      toBeRegularizedBy: json['toBeRegularizedBy'] ?? '',
      sourceOfRepayment: json['sourceOfRepayment'] ?? '',
      lcCommission: (json['lcCommission'] as List? ?? [])
          .map((e) => LcCommission.fromJson(e))
          .toList(),
      lcMargin: json['lcMargin'] ?? '',
      marginExtent: json['marginExtent'] ?? '',
      usanceTenor: UsanceTenor.fromJson(json['usanceTenor'] ?? {}),
      preferentialExchangeRate: PreferentialExchangeRate.fromJson(
          json['preferentialExchangeRate'] ?? {}),
      shipmentBySeaOrAir: json['shipmentBySeaOrAir'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'excessAmount': excessAmount,
        'toBeRegularizedBy': toBeRegularizedBy,
        'sourceOfRepayment': sourceOfRepayment,
        'lcCommission': lcCommission.map((e) => e.toJson()).toList(),
        'lcMargin': lcMargin,
        'marginExtent': marginExtent,
        'usanceTenor': usanceTenor.toJson(),
        'preferentialExchangeRate': preferentialExchangeRate.toJson(),
        'shipmentBySeaOrAir': shipmentBySeaOrAir,
      };
}

class LcCommission {
  final String dateFrom;
  final String dateTo;
  final double amountFrom;
  final double amountTo;
  final String gridCommission;

  LcCommission({
    required this.dateFrom,
    required this.dateTo,
    required this.amountFrom,
    required this.amountTo,
    required this.gridCommission,
  });

  factory LcCommission.fromJson(Map<String, dynamic> json) {
    return LcCommission(
      dateFrom: json['dateFrom']?['formatted'] ?? '',
      dateTo: json['dateTo']?['formatted'] ?? '',
      amountFrom: (json['amountfrom'] ?? 0).toDouble(),
      amountTo: (json['amountTo'] ?? 0).toDouble(),
      gridCommission: json['gridCommission'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'dateFrom': dateFrom,
        'dateTo': dateTo,
        'amountfrom': amountFrom,
        'amountTo': amountTo,
        'gridCommission': gridCommission,
      };
}

class UsanceTenor {
  final String tenorUnit;
  final String tenorValue;

  UsanceTenor({required this.tenorUnit, required this.tenorValue});

  factory UsanceTenor.fromJson(Map<String, dynamic> json) {
    return UsanceTenor(
      tenorUnit: json['tenorUnit'] ?? '',
      tenorValue: json['tenorValue'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'tenorUnit': tenorUnit,
        'tenorValue': tenorValue,
      };
}

class PreferentialExchangeRate {
  final String exchangeRateCurrency;
  final String percentage;

  PreferentialExchangeRate({
    required this.exchangeRateCurrency,
    required this.percentage,
  });

  factory PreferentialExchangeRate.fromJson(Map<String, dynamic> json) {
    return PreferentialExchangeRate(
      exchangeRateCurrency: json['exchangeRateCurrency'] ?? '',
      percentage: json['percentage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'exchangeRateCurrency': exchangeRateCurrency,
        'percentage': percentage,
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
  if (s == 'true') return true;
  if (s == 'false') return false;
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
