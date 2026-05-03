import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/country.dart";
import "package:wcas_frontend/models/request/facility_security/facility_summary_list.dart";

class Facility {
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
    this.originalLimit,
    this.limitGroup,
    this.limitGroupName,
    this.limitCode,
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
  factory Facility.fromJsonLinkage(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    String parseString(dynamic value, {String defaultValue = ""}) {
      if (value == null) return defaultValue;

      if (value is String) return value.trim();
      if (value is int || value is double) return value.toString();

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
  factory Facility.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

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
  FacilitySummaryNew? facilitySummaryItem;
  bool? isStanbySublimitValidation;
  int? facilityId;
  // FI flow fields
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
  // FI flow fields
  int? facilitySummaryId;
  String? facilityTypeName;
  String? limitNumber;
  String? appRefNo;
  String? controllingLimitNumber;
  String? limitLabel;
  String? limitDescription;
  String? remarks;
  String? additionalDetails;
  String? facilityTitle;
  String? limitAllocation;
  String? limitAllocationCustomerRIM;
  String? facilityDetails;
  String? subFacilityDetails;
  String? applicablePricing;
  String? marginSign;
  String? marginValue;
  DateTime? limitAvailabilityDate;
  String? limitAvailabilityPeriod;

  DateTime? limitExpireDate;
  int? limitGroup;
  int? limitCode;
  String? index;
  String? limitGroupName;
  Country? selectedCountry;
  List<Country>? countryRiskWith;
  int? groupId;
  int? sNo;
  int? rimNo;
  int? presentLimit;
  int? originalLimit;
  int? proposedLimit;
  int? proposedLimitAED;
  int? existingLimits;
  int? proposedLimits;
  int? outstanding;
  int? tenorDays;
  int? facilitySecurityDetailId;
  int? type;
  int? facilitySecurityId;
  int? totalProposedLimit;
  // Boolean flags
  bool isPolicyDeviation;
  bool isConditionsStandard;
  bool isCrossBoarderExposure;
  bool limitType;

  // Reference fields
  Reference? projectName;
  Reference? selectedCollateralDepantantValue;
  Reference? selectedProductTypeValue;
  Reference? selectedProjectFinanceRelatedActivityValue;
  Reference? selectedpromissoryNoteValue;
  Reference? selectedRegulatorySpecialisedLandingValue;
  Reference? commitmentAccountNumber;
  Reference? selectedLimitTypeValue;
  Reference? sharedLimit;
  Reference? sicCode;
  Reference? accountTypeValue;
  Reference? presentOutstandingCCValue;
  Reference? presentOutstandingCurrency;
  int? presentOutstandingAmount;
  int? presentOutstandingAED;
  Reference? limitTypeValue;
  Reference? proposedLimitValue;
  Reference? presentLimitValue;
  Reference? originalLimitCCValue;
  Reference? seniorityValue;
  Reference? commitmentAccountNumberValue;
  Reference? propertyType;
  Reference? advanceTypeValue;
  int? limitCapType;
  Reference? purpose;

  Reference? sector;
  Reference? facilityTypeSelectedValue;
  Reference? facilityDescription;
  Reference? borrowerValue;
  Reference? pastDues;
  Reference? limitAmount;

  double? proposedByCc;
  String? proposedByCcCurrency;
  Reference? regulatorySpecification;
  Reference? promissoryNoteOptions;
  Reference? propertySubType;
  Reference? emirates;
  Reference? selectedSustanabilityValue;
  Reference? committedValues;
  String? countryOfRisk;
  String? currency;
  bool? isCommitted;
  bool? isMainLimit;
  String? productCodeProject;

  List<Reference>? sustainabilityClassification;
  Reference? proposedFacilityAmtCurrency;
  List<Reference>? policyDeviation;
  Reference? tenorUnit;
  num? tenorValue;
  String? limitCategory;

  int? facilityMasterId;

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

class FacilitySubTypes {
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
  });

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
  bool? subTypeSelected;
  String? subType;
  String? commitmentAccountNumber;
  int? currentOutstanding;
  int? pastDues;
  int? limitAmount;
  int? facilityId;
  int? outstandingAmount;
  int? originalLimitCCValue;
  int? existingAmounts;
  int? proposedLimit;
  int? tenor;
  int? commission;
  String? currency;
  String? tenorUnit;
  int? tenorValue;
  String? index;
  String? marginSign;
  String? marginValue;

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

/// Minimal shim to expose UI-friendly getters for FacilitySubTypes
extension FacilitySubTypesX on FacilitySubTypes {
  String? get currency => null;
  String? get tenorUnit => null;
  int? get tenorValue => tenor;
  String? get indexKey => null;
  String? get marginSign => null;
  num? get marginValue => commission;
}

class FeeDefaultRate {
  FeeDefaultRate({
    this.defaultRate,
    this.amount,
    this.percentage,
    this.frequency,
    this.comments,
    this.frequencies,
    this.feeID,
  });

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
  String? defaultRate;
  int? percentage;
  int? amount;
  int? feeID;
  List<String>? frequencies = [];
  String? comments;
  String? frequency;

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

class StandardCondition {
  StandardCondition({
    this.standardCondition,
    this.actions,
  });

  StandardCondition.fromJson(Map<String, dynamic> json) {
    standardCondition = json["standardCondition"];
    actions = json["actions"];
  }
  String? standardCondition;
  String? actions;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["standardCondition"] = standardCondition;
    data["actions"] = actions;

    return data;
  }
}

class CreateFacilityArgs {
  const CreateFacilityArgs({
    required this.facility,
    required this.showCreateFacilityForm,
    this.facilityId,
    this.facilityMasterId,
  });
  final int? facilityId; // or int?, depending on your data
  final Facility facility;
  final bool showCreateFacilityForm;
  final int? facilityMasterId;
}
