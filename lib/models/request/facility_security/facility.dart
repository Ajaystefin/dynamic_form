import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/country.dart";
import "package:wcas_frontend/models/request/facility_security/facility_summary_list.dart";

/// Represents facility details including limits, exposure values,
/// facility metadata, reference selections, and FI flow related values.
class Facility {
  /// Creates a [Facility] instance.
  Facility({
    this.facilityMasterId,
    this.proposedByCcCurrency,
    this.presentOutstandingCurrency,
    this.limitCategory,
    this.rimNo,
    this.facilitySummaryId,
    this.excessOverMaxLimitAllowanceByCredit,
    this.excessOverMaxLimitAllowanceCurrencyByCredit,
    this.tenorUnit,
    this.limitCapType,
    this.tenorValue,
    this.productCodeProject,
    this.excessOverMaxLimitAllowanceByFi,
    this.excessOverMaxLimitAllowanceCurrencyByFi,
    this.cbdEquityTier325Percent,
    this.cbdEquityTier325PercentCurrency,
    this.counterpartyEquity5Percent,
    this.counterpartyEquity5PercentCurrency,
    this.counterpartyTotalAssets2Percent,
    this.counterpartyTotalAssets2PercentCurrency,
    this.committedValues,
    this.selectedSustanabilityValue,
    this.countryOfRisk,
    this.isCommitted,
    this.isMainLimit,
    this.index,
    this.marginValue,
    this.sNo,
    this.groupId,
    this.facilityDetails,
    this.subFacilityDetails,
    this.sustainabilityClassification,
    this.existingLimits,
    this.proposedLimits,
    this.outstanding,
    this.tenorDays,
    this.applicablePricing,
    this.marginSign,
    this.limitAvailabilityPeriod,
    this.emirates,
    this.presentOutstandingAmount,
    this.presentOutstandingAED,
    this.limitType = false,
    this.limitNumber,
    this.appRefNo,
    this.controllingLimitNumber,
    this.limitLabel,
    this.limitDescription,
    this.presentLimit,
    this.presentLimitAED,
    this.originalLimit,
    this.limitGroup,
    this.limitGroupName,
    this.limitCode,
    this.productCode,
    this.proposedLimit,
    this.proposedLimitAED,
    this.currency,
    this.facilityId,
    this.remarks,
    this.additionalDetails,
    this.isPolicyDeviation = false,
    this.policyDeviation,
    this.isConditionsStandard = false,
    this.isCrossBoarderExposure = false,
    this.projectName,
    this.selectedCollateralDepantantValue,
    this.selectedProductTypeValue,
    this.selectedProjectFinanceRelatedActivityValue,
    this.selectedpromissoryNoteValue,
    this.selectedRegulatorySpecialisedLandingValue,
    this.selectedCountry,
    this.commitmentAccountNumber,
    this.selectedLimitTypeValue,
    this.sharedLimit,
    this.sicCode,
    this.accountTypeValue,
    this.presentOutstandingCCValue,
    this.limitTypeValue,
    this.proposedLimitValue,
    this.presentLimitValue,
    this.originalLimitCCValue,
    this.seniorityValue,
    this.commitmentAccountNumberValue,
    this.propertyType,
    this.advanceTypeValue,
    this.proposedFacilityAmtCurrency,
    this.purpose,
    this.sector,
    this.facilityTypeSelectedValue,
    this.facilityDescription,
    this.borrowerValue,
    this.pastDues,
    this.limitAmount,
    this.proposedByCc,
    this.regulatorySpecification,
    this.promissoryNoteOptions,
    this.facilityTypeName,
    this.facilityTitle,
    this.type,
    this.facilitySecurityDetailId,
    this.facilitySecurityId,
    this.totalProposedLimit,
    this.isStanbySublimitValidation,
    this.facilitySummaryItem,
  });

  /// Creates a [Facility] instance from linkage JSON data.
  factory Facility.fromJsonLinkage(Map<String, dynamic> json) {
    int parseInt(value) {
      if (value is int) {
        return value;
      }
      if (value is double) {
        return value.toInt();
      }
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    String parseString(value, {String defaultValue = ""}) {
      if (value == null) {
        return defaultValue;
      }

      if (value is String) {
        return value.trim();
      }
      if (value is int || value is double) {
        return value.toString();
      }

      return defaultValue;
    }

    return Facility(
      facilitySummaryId: (json["facilitySummaryId"] != null)
          ? parseInt(json["facilitySummaryId"])
          : null,
      rimNo: parseInt(json["rimNo"]),
      limitLabel: json["limitLabel"] ?? json["projectName"] as String?,
      limitNumber: json["limitNumber"] ?? json["limitNo"],
      limitGroup: parseInt(json["limitGroup"]),
      limitCode: parseInt(json["limitCode"]),
      productCode: json["productCode"] as String?,
      appRefNo: json["appRefNo"] as String?,
      controllingLimitNumber: json["controllingLimitNumber"],
      limitDescription: parseString(json["limitDescription"]),
      proposedLimit: json["proposedLimit"],
      proposedLimitAED: json["proposedLimitAED"],
      currency: json["currency"] ?? ServerConstants.aedCurrency,
      isMainLimit: json["isMainLimit"],
      marginSign: json["marginSign"],
      marginValue: json["marginValue"],
      facilityId: json["facilityId"],
      projectName: (json["projectName"] != null)
          ? Reference(name: json["projectName"])
          : null,
    );
  }

  /// Creates a [Facility] instance from a JSON map.
  factory Facility.fromJson(Map<String, dynamic> json) {
    int parseInt(value) {
      if (value is int) {
        return value;
      }
      if (value is double) {
        return value.toInt();
      }
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

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

    return Facility(
      selectedRegulatorySpecialisedLandingValue: Reference(
        id: json["isRegulatorySpecialisedLending"] ?? false
            ? ServerConstants.optionYESid
            : ServerConstants.optionNOid,
      ),
      proposedLimitValue:
          Reference(name: json["currency"] ?? ServerConstants.aedCurrency),
      facilityMasterId: json["facilityMasterId"] as int?,
      facilitySummaryId: json["facilitySummaryId"] as int?,
      rimNo: parseInt(json["rimNo"]),
      type: parseInt(json["type"]),
      facilitySecurityDetailId: parseInt(json["facilitySecurityDetailId"]),
      facilitySecurityId: parseInt(json["facilitySecurityId"]),
      regulatorySpecification: Reference(
        id: json["regulatorySpecialisedLendingFinanceType"] as int?,
      ),
      tenorUnit: Reference(name: json["tenorUnit"] as String?),
      // tenorValue: json['tenorValue'] as num?,
      tenorValue: numFromJson(json["tenorValue"]),
      excessOverMaxLimitAllowanceByFi:
          (json["excessOverMaxLimitAllowance"] as num?)?.toDouble(),
      excessOverMaxLimitAllowanceCurrencyByFi: Reference(
        name: json["excessOverMaxLimitAllowanceCurrency"] as String?,
      ),
      cbdEquityTier325Percent:
          (json["cbdEquityTier325Percent"] as num?)?.toDouble(),
      cbdEquityTier325PercentCurrency:
          Reference(name: json["cbdEquityTier325PercentCurrency"] as String?),
      counterpartyEquity5Percent:
          (json["counterpartyEquity5Percent"] as num?)?.toDouble(),
      counterpartyEquity5PercentCurrency: Reference(
        name: json["counterpartyEquity5PercentCurrency"] as String?,
      ),
      counterpartyTotalAssets2Percent:
          (json["counterpartyTotalAssets2Percent"] as num?)?.toDouble(),
      counterpartyTotalAssets2PercentCurrency: Reference(
        name: json["counterpartyTotalAssets2PercentCurrency"] as String?,
      ),
      index: json["index"] as String?,
      marginValue: json["marginValue"] as String?,
      limitGroup: parseInt(json["limitGroup"]),
      limitGroupName: json["limitGroupName"] as String?,
      productCode: json["productCode"] as String?,
      limitCode: parseInt(json["limitCode"]),
      limitNumber: (json["limitNumber"] ?? json["limitNo"]) as String?,
      appRefNo: json["appRefNo"] as String?,
      controllingLimitNumber: json["controllingLimitNo"] as String?,
      limitLabel: json["limitLabel"] ?? json["projectName"] as String?,
      limitDescription:
          json["limitDescription"] ?? json["facilityTypeName"].toString(),
      countryOfRisk:
          (json["countryOfRisk"] ?? json["Country_of_Risk"]) as String?,
      presentLimit: json["presentLimit"],
      presentLimitAED: int.tryParse(json["presentLimitAED"] ?? 0),
      originalLimit: json["originalLimit"],
      proposedLimit: json["proposedLimit"],
      facilityId: json["facilityID"],
      limitCapType: json["limitCapType"],
      groupId: json["groupId"],
      remarks: json["remarks"] as String?,
      additionalDetails: json["additionalDetails"] as String?,
      sNo: json["S_No"],
      proposedFacilityAmtCurrency: Reference(name: json["currency"]),
      facilityDetails: json["Facility_Details"],
      subFacilityDetails: json["Sub_Facility_Details"],
      sustainabilityClassification:
          (json["Sustainability_Classification"] as List?)
                  ?.map((e) => Reference(name: e.toString()))
                  .toList() ??
              [],
      policyDeviation: (json["policyDeviation"] as String?)
          ?.split(",")
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .map((e) {
        final maybeId = int.tryParse(e);
        return maybeId != null ? Reference(id: maybeId) : Reference(name: e);
      }).toList(),
      presentOutstandingCCValue:
          Reference(description: json["presentOutstanding"]),
      presentOutstandingCurrency:
          Reference(name: json["presentOutstandingCurrency"]),
      presentOutstandingAmount: json["presentOutstanding"],
      presentOutstandingAED: json["presentOutstandingAED"],
      isMainLimit: json["isMainLimit"],
      existingLimits: json["Existing_Limits"],
      proposedLimits: json["Proposed_Limits"],
      outstanding: json["Outstanding"],
      tenorDays: json["Tenor_Days"],
      applicablePricing: json["Applicable_Pricing"],
      marginSign: json["marginSign"],
      seniorityValue: Reference(id: json["seniority"]),
      limitAvailabilityPeriod: json["limitAvailabilityPeriod"],
      projectName: (json["projectName"] != null)
          ? Reference(name: json["projectName"])
          : null,
      facilityTypeName: json["facilityTypeName"],
      selectedCollateralDepantantValue: json["isCollateralDependent"] == false
          ? Reference(id: ServerConstants.optionNOid, name: "No")
          : Reference(id: ServerConstants.optionYESid, name: "Yes"),
    );
  }

  /// Facility summary item details.
  FacilitySummaryNew? facilitySummaryItem;

  /// Indicates whether standby sublimit validation is enabled.
  bool? isStanbySublimitValidation;

  /// Facility identifier.
  int? facilityId;

  // FI flow fields

  /// Excess over maximum limit allowance by credit.
  double? excessOverMaxLimitAllowanceByCredit;

  /// Excess over maximum limit allowance currency by credit.
  Reference? excessOverMaxLimitAllowanceCurrencyByCredit;

  /// Excess over maximum limit allowance by FI.
  double? excessOverMaxLimitAllowanceByFi;

  /// Excess over maximum limit allowance currency by FI.
  Reference? excessOverMaxLimitAllowanceCurrencyByFi;

  /// CBD equity tier 3 twenty-five percent value.
  double? cbdEquityTier325Percent;

  /// CBD equity tier 3 twenty-five percent currency.
  Reference? cbdEquityTier325PercentCurrency;

  /// Counterparty equity five percent value.
  double? counterpartyEquity5Percent;

  /// Counterparty equity five percent currency.
  Reference? counterpartyEquity5PercentCurrency;

  /// Counterparty total assets two percent value.
  double? counterpartyTotalAssets2Percent;

  /// Counterparty total assets two percent currency.
  Reference? counterpartyTotalAssets2PercentCurrency;

  // FI flow fields

  /// Facility summary identifier.
  int? facilitySummaryId;

  /// Facility type name.
  String? facilityTypeName;

  /// Limit number.
  String? limitNumber;

  /// Application reference number.
  String? appRefNo;

  /// Controlling limit number.
  String? controllingLimitNumber;

  /// Limit label.
  String? limitLabel;

  /// Limit description.
  String? limitDescription;

  /// Facility remarks.
  String? remarks;

  /// Additional facility details.
  String? additionalDetails;

  /// Facility title.
  String? facilityTitle;

  /// Limit allocation value.
  String? limitAllocation;

  /// Limit allocation customer RIM value.
  String? limitAllocationCustomerRIM;

  /// Facility details value.
  String? facilityDetails;

  /// Sub facility details value.
  String? subFacilityDetails;

  /// Applicable pricing value.
  String? applicablePricing;

  /// Margin sign value.
  String? marginSign;

  /// Margin value.
  String? marginValue;

  /// Limit availability date.
  DateTime? limitAvailabilityDate;

  /// Limit availability period.
  String? limitAvailabilityPeriod;

  /// Limit expiry date.
  DateTime? limitExpireDate;

  /// Limit group identifier.
  int? limitGroup;

  /// Limit code identifier.
  int? limitCode;

  /// Product code.
  String? productCode;

  /// Index value.
  String? index;

  /// Limit group name.
  String? limitGroupName;

  /// Selected country.
  Country? selectedCountry;

  /// Country risk list.
  List<Country>? countryRiskWith;

  /// Group identifier.
  int? groupId;

  /// Serial number.
  int? sNo;

  /// Customer RIM number.
  int? rimNo;

  /// Present limit amount.
  int? presentLimit;

  /// Original limit amount.
  int? originalLimit;

  /// Proposed limit amount.
  int? proposedLimit;

  /// Proposed limit amount in AED.
  int? proposedLimitAED;

  /// Existing limits amount.
  int? existingLimits;

  /// Proposed limits amount.
  int? proposedLimits;

  /// Outstanding amount.
  int? outstanding;

  /// Tenor days value.
  int? tenorDays;

  /// Facility security detail identifier.
  int? facilitySecurityDetailId;

  /// Facility type identifier.
  int? type;

  /// Facility security identifier.
  int? facilitySecurityId;

  /// Total proposed limit amount.
  int? totalProposedLimit;

  // Boolean flags

  /// Indicates whether policy deviation exists.
  bool isPolicyDeviation;

  /// Indicates whether conditions are standard.
  bool isConditionsStandard;

  /// Indicates whether cross-border exposure exists.
  bool isCrossBoarderExposure;

  /// Indicates the limit type flag.
  bool limitType;

  // Reference fields

  /// Project name reference.
  Reference? projectName;

  /// Selected collateral dependent value.
  Reference? selectedCollateralDepantantValue;

  /// Selected product type value.
  Reference? selectedProductTypeValue;

  /// Selected project finance related activity value.
  Reference? selectedProjectFinanceRelatedActivityValue;

  /// Selected promissory note value.
  Reference? selectedpromissoryNoteValue;

  /// Selected regulatory specialised lending value.
  Reference? selectedRegulatorySpecialisedLandingValue;

  /// Commitment account number reference.
  Reference? commitmentAccountNumber;

  /// Selected limit type value.
  Reference? selectedLimitTypeValue;

  /// Shared limit reference.
  Reference? sharedLimit;

  /// SIC code reference.
  Reference? sicCode;

  /// Account type value.
  Reference? accountTypeValue;

  /// Present outstanding CC value.
  Reference? presentOutstandingCCValue;

  /// Present outstanding currency reference.
  Reference? presentOutstandingCurrency;

  /// Present outstanding amount.
  int? presentOutstandingAmount;

  /// Present outstanding amount in AED.
  int? presentOutstandingAED;

  /// Limit type value.
  Reference? limitTypeValue;

  /// Proposed limit value.
  Reference? proposedLimitValue;

  /// Present limit value.
  Reference? presentLimitValue;

  /// Original limit CC value.
  Reference? originalLimitCCValue;

  /// Seniority value.
  Reference? seniorityValue;

  /// Commitment account number value.
  Reference? commitmentAccountNumberValue;

  /// Property type reference.
  Reference? propertyType;

  /// Advance type value.
  Reference? advanceTypeValue;

  /// Limit cap type.
  int? limitCapType;

  /// Purpose reference.
  Reference? purpose;

  /// Sector reference.
  Reference? sector;

  /// Facility type selected value.
  Reference? facilityTypeSelectedValue;

  /// Facility description reference.
  Reference? facilityDescription;

  /// Borrower value.
  Reference? borrowerValue;

  /// Past dues reference.
  Reference? pastDues;

  /// Limit amount reference.
  Reference? limitAmount;

  /// Proposed by CC amount.
  double? proposedByCc;

  /// Proposed by CC currency.
  String? proposedByCcCurrency;

  /// Regulatory specification reference.
  Reference? regulatorySpecification;

  /// Promissory note options.
  Reference? promissoryNoteOptions;

  /// Property subtype reference.
  Reference? propertySubType;

  /// Emirates reference.
  Reference? emirates;

  /// Selected sustainability value.
  Reference? selectedSustanabilityValue;

  /// Committed values reference.
  Reference? committedValues;

  /// Country of risk.
  String? countryOfRisk;

  /// Facility currency.
  String? currency;

  /// Indicates whether the facility is committed.
  bool? isCommitted;

  /// Indicates whether this facility is main limit.
  bool? isMainLimit;

  /// Product code project value.
  String? productCodeProject;

  /// Sustainability classification references.
  List<Reference>? sustainabilityClassification;

  /// Proposed facility amount currency.
  Reference? proposedFacilityAmtCurrency;

  /// Policy deviation references.
  List<Reference>? policyDeviation;

  /// Tenor unit reference.
  Reference? tenorUnit;

  /// Tenor value.
  num? tenorValue;

  /// Limit category.
  String? limitCategory;

  /// Facility master identifier.
  int? facilityMasterId;
  int? presentLimitAED;

  /// Converts this [Facility] instance into a JSON map.
  Map<String, dynamic> toJson() {
    String? fetchValueFromReference(Reference? r) => r?.name;
    int? fetchIdFromReference(Reference? r) => r?.id;
    bool fetchBoolValue(Reference? r) => r?.id == ServerConstants.optionYESid;

    return {
      "facilitySecurityDetailId": facilitySecurityDetailId,
      "presentOutstandingCurrency":
          fetchValueFromReference(presentOutstandingCurrency),
      "facilityMasterId": facilityMasterId,
      "facilitySecurityId": facilitySecurityId,
      "type": type,
      "rimNo": rimNo,
      "excessOverMaxLimitAllowanceByCc": excessOverMaxLimitAllowanceByCredit,
      "excessOverMaxLimitAllowanceCurrencyByCc":
          excessOverMaxLimitAllowanceCurrencyByCredit?.name,
      "excessOverMaxLimitAllowance": excessOverMaxLimitAllowanceByFi,
      "excessOverMaxLimitAllowanceCurrency":
          fetchValueFromReference(excessOverMaxLimitAllowanceCurrencyByFi),
      "cbdEquityTier325Percent": cbdEquityTier325Percent,
      "cbdEquityTier325PercentCurrency":
          fetchValueFromReference(cbdEquityTier325PercentCurrency),
      "counterpartyEquity5Percent": counterpartyEquity5Percent,
      "counterpartyEquity5PercentCurrency":
          fetchValueFromReference(counterpartyEquity5PercentCurrency),
      "counterpartyTotalAssets2Percent": counterpartyTotalAssets2Percent,
      "counterpartyTotalAssets2PercentCurrency":
          fetchValueFromReference(counterpartyTotalAssets2PercentCurrency) ??
              ServerConstants.aedCurrency,
      "index": index,
      "groupId": 0,
      "limitGroup": limitGroup,
      "isConventional": fetchBoolValue(selectedProductTypeValue) ? false : null,
      "limitGroupName": limitGroupName,
      "limitCategory": fetchValueFromReference(limitTypeValue),
      "productCode": fetchValueFromReference(selectedProductTypeValue),
      "productType": fetchIdFromReference(selectedProductTypeValue),
      "promissoryNoteTaken": fetchBoolValue(selectedpromissoryNoteValue),
      "advanceType": fetchIdFromReference(advanceTypeValue),
      "purpose": fetchIdFromReference(purpose),
      "sharedLimit": fetchBoolValue(sharedLimit),
      "limitDescription": fetchIdFromReference(facilityDescription),
      "isCommitted": isCommitted,
      "isMainLimit": isMainLimit,
      "limitAvailabilityPeriod": limitAvailabilityPeriod,
      "proposedLimit": proposedLimit,
      "proposedLimitAED": proposedLimitAED,
      "proposedByCc": proposedByCc,
      "proposedByCcCurrency":
          proposedByCcCurrency ?? ServerConstants.aedCurrency,
      "limitExpiryDate":
          limitExpireDate, // Add DateTime conversion if needed for backend
      "limitAvailabilityDate":
          // Add DateTime conversion if needed for backend
          limitAvailabilityDate,
      "financialActivity":
          fetchBoolValue(selectedProjectFinanceRelatedActivityValue),
      "limitLabel": limitLabel,
      "isRegulatorySpecialisedLending":
          fetchBoolValue(selectedRegulatorySpecialisedLandingValue),
      "regulatorySpecialisedLendingFinanceType": regulatorySpecification?.id,
      "countryOfRisk": selectedCountry?.description,
      "committed": fetchBoolValue(commitmentAccountNumberValue),
      "seniority": fetchIdFromReference(seniorityValue),
      "accountType": accountTypeValue != null
          ? [fetchIdFromReference(accountTypeValue)]
          : [],
      "sectorDescription": fetchIdFromReference(sector),
      "sicCode": fetchIdFromReference(sicCode),
      "revolvingType": "",
      // "controllingLimitNo": json['controllingLimitNo'] as String?,
      "isCollateralDependent": fetchBoolValue(selectedCollateralDepantantValue),
      "commitmentAcctNo": commitmentAccountNumber?.name,
      "conditions": "",
      "remarks": remarks,
      "marginSign": marginSign,
      "marginValue": marginValue,
      "forIslamicCust": [""],
      "propertyType": fetchValueFromReference(propertyType),
      "propertySubType": "",
      "emirates": fetchIdFromReference(emirates),
      // 'emirates': fetchIdFromReference(emirates),
      "outStandingAmount": fetchValueFromReference(presentOutstandingCCValue),
      "presentOutstanding": presentOutstandingAmount,
      "presentOutstandingAED": presentOutstandingAED,
      "additionalDetails": additionalDetails,
      "draft": false,
      "limitNo": limitNumber,
      "facilityTypeName": facilityTypeName,
      // "facilityTypeName": facilityTypeName,
      "projectName": projectName?.name,
      "tenorValue": tenorValue,
      "tenorUnit": tenorUnit?.name ?? "",
      "policyDeviation": policyDeviation?.map((e) => e.name).join(","),
    };
  }
}

/// Represents facility subtype details including outstanding,
/// limits, tenor, commission, and pricing values.
class FacilitySubTypes {
  /// Creates a [FacilitySubTypes] instance.
  FacilitySubTypes({
    this.subTypeSelected,
    this.subType,
    this.commitmentAccountNumber,
    this.currentOutstanding,
    this.pastDues,
    this.limitAmount,
    this.outstandingAmount,
    this.originalLimitCCValue,
    this.existingAmounts,
    this.proposedLimit,
    this.tenor,
    this.facilityId,
    this.commission,
    this.currency,
    this.tenorUnit,
    this.tenorValue,
    this.index,
    this.marginSign,
    this.marginValue,
    this.limitCode,
    this.alreadyExistingSubType,
  });

  /// Creates a [FacilitySubTypes] instance from a JSON map.
  FacilitySubTypes.fromJson(Map<String, dynamic> json) {
    subTypeSelected = json["subTypeSelected"];
    subType = json["subType"];
    facilityId = json["facilityId"];
    commitmentAccountNumber = json["commitmentAccountNumber"];
    currentOutstanding = json["currentOutstanding"];
    pastDues = json["pastDues"];
    limitAmount = json["limitAmount"];
    outstandingAmount = json["outstandingAmount"];
    originalLimitCCValue = json["originalLimit"];
    existingAmounts = json["existingAmounts"];
    proposedLimit = json["proposedLimit"];
    tenor = json["tenor"];
    currency = json["currency"] ?? ServerConstants.aedCurrency;
    tenorUnit = json["tenorUnit"];
    tenorValue = json["tenorValue"];
    index = json["index"];
    marginSign = json["marginSign"];
    marginValue = json["marginValue"];
  }

  /// Indicates whether subtype is selected.
  bool? subTypeSelected;

  /// Indicates whether subtype already exists.
  bool? alreadyExistingSubType;

  /// Facility subtype value.
  String? subType;

  /// Commitment account number.
  String? commitmentAccountNumber;

  /// Current outstanding amount.
  int? currentOutstanding;

  /// Past dues amount.
  int? pastDues;

  /// Limit amount.
  int? limitAmount;

  /// Facility identifier.
  int? facilityId;

  /// Outstanding amount.
  int? outstandingAmount;

  /// Original limit CC value.
  int? originalLimitCCValue;

  /// Existing amounts.
  int? existingAmounts;

  /// Proposed limit amount.
  int? proposedLimit;

  /// Tenor value.
  int? tenor;

  /// Commission value.
  int? commission;

  /// Currency value.
  String? currency;

  /// Tenor unit value.
  String? tenorUnit;

  /// Tenor value.
  int? tenorValue;

  /// Index value.
  String? index;

  /// Margin sign value.
  String? marginSign;

  /// Margin value.
  String? marginValue;

  /// Limit code.
  String? limitCode;

  /// Converts this [FacilitySubTypes] instance into a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["subTypeSelected"] = subTypeSelected;
    data["subType"] = subType;
    data["commitmentAccountNumber"] = commitmentAccountNumber;
    data["currentOutstanding"] = currentOutstanding;
    data["pastDues"] = pastDues;
    data["limitAmount"] = limitAmount;
    data["outstandingAmount"] = outstandingAmount;
    data["originalLimit"] = originalLimitCCValue;
    data["existingAmounts"] = existingAmounts;
    data["proposedLimit"] = proposedLimit;
    data["proposedLimitAED"] = proposedLimit;
    data["tenor"] = tenor;
    data["commission"] = commission;
    data["currency"] = currency;
    data["tenorUnit"] = tenorUnit;
    data["tenorValue"] = tenorValue;
    data["index"] = index;
    data["marginSign"] = marginSign;
    data["marginValue"] = marginValue;

    return data;
  }
}

/// Minimal shim to expose UI-friendly getters for [FacilitySubTypes].
extension FacilitySubTypesX on FacilitySubTypes {
  /// Currency display value.
  String? get currency => null;

  /// Tenor unit display value.
  String? get tenorUnit => null;

  /// Tenor value display value.
  int? get tenorValue => tenor;

  /// Index key value.
  String? get indexKey => null;

  /// Margin sign display value.
  String? get marginSign => null;

  /// Margin value display value.
  num? get marginValue => commission;
}

/// Represents default fee rate details.
class FeeDefaultRate {
  /// Creates a [FeeDefaultRate] instance.
  FeeDefaultRate({
    this.defaultRate,
    this.amount,
    this.percentage,
    this.frequency,
    this.comments,
    this.frequencies,
    this.feeID,
  });

  /// Creates a [FeeDefaultRate] instance from a JSON map.
  FeeDefaultRate.fromJson(Map<String, dynamic> json) {
    percentage = json["percentage"];
    frequency = json["frequency"];
    defaultRate = json["defaultRate"];
    amount = json["amount"];
    comments = json["comments"];
    // feeID = json['comments'];
    frequencies = (json["frequencies"] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList();
  }

  /// Default rate value.
  String? defaultRate;

  /// Percentage value.
  int? percentage;

  /// Amount value.
  int? amount;

  /// Fee identifier.
  int? feeID;

  /// List of frequency values.
  List<String>? frequencies = [];

  /// Comments value.
  String? comments;

  /// Frequency value.
  String? frequency;

  /// Converts this [FeeDefaultRate] instance into a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["percentage"] = percentage;
    data["frequency"] = frequency;
    data["defaultRate"] = defaultRate;
    data["amount"] = amount;
    data["comments"] = comments;
    return data;
  }
}

/// Represents a standard condition and its related action.
class StandardCondition {
  /// Creates a [StandardCondition] instance.
  StandardCondition({
    this.standardCondition,
    this.actions,
  });

  /// Creates a [StandardCondition] instance from a JSON map.
  StandardCondition.fromJson(Map<String, dynamic> json) {
    standardCondition = json["standardCondition"];
    actions = json["actions"];
  }

  /// Standard condition value.
  String? standardCondition;

  /// Actions value.
  String? actions;

  /// Converts this [StandardCondition] instance into a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["standardCondition"] = standardCondition;
    data["actions"] = actions;

    return data;
  }
}

/// Represents arguments required to create or edit a facility.
class CreateFacilityArgs {
  /// Creates a [CreateFacilityArgs] instance.
  const CreateFacilityArgs({
    required this.facility,
    required this.showCreateFacilityForm,
    this.facilityId,
    this.facilityMasterId,
  });

  /// Facility identifier.
  final int? facilityId; // or int?, depending on your data

  /// Facility details.
  final Facility facility;

  /// Indicates whether create facility form should be shown.
  final bool showCreateFacilityForm;

  /// Facility master identifier.
  final int? facilityMasterId;
}
